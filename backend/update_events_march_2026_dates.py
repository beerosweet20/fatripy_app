import argparse
import os
import random
from calendar import monthrange
from datetime import date
from typing import Dict, List, Tuple

import firebase_admin
from firebase_admin import credentials, firestore


TARGET_COLLECTION = "events"
TARGET_MONTHS: Tuple[Tuple[int, int], ...] = (
    (2026, 3),  # March
    (2026, 4),  # April
    (2026, 5),  # May
)
# Enforce custom minimum day inside specific month buckets.
# Requirement update: March dates must be from 20th and above.
MONTH_MIN_DAY: Dict[Tuple[int, int], int] = {
    (2026, 3): 20,
}


def _init_firestore(cred_path: str):
    if not firebase_admin._apps:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    return firestore.client()


def _resolve_credentials_path(path_from_cli: str | None) -> str:
    cred_path = path_from_cli or os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not cred_path:
        raise SystemExit(
            "Service account path is required. "
            "Pass it as an argument or set GOOGLE_APPLICATION_CREDENTIALS."
        )
    if not os.path.exists(cred_path):
        raise SystemExit(f"Service account file not found: {cred_path}")
    return cred_path


def _month_quotas(total: int, month_count: int) -> List[int]:
    base = total // month_count
    remainder = total % month_count
    quotas = [base] * month_count
    for i in range(remainder):
        quotas[i] += 1
    return quotas


def _spread_days_in_month(
    year: int,
    month: int,
    count: int,
    *,
    min_day: int = 1,
) -> List[int]:
    if count <= 0:
        return []

    days_in_month = monthrange(year, month)[1]
    min_day = max(1, min(min_day, days_in_month))
    available_span = days_in_month - min_day + 1
    if available_span <= 0:
        return []

    if count > available_span:
        raise ValueError(
            f"Cannot spread {count} events in {year}-{month:02d} "
            f"from day {min_day} to {days_in_month}."
        )

    used = set()
    result: List[int] = []

    # Spread days across the allowed month range.
    for i in range(count):
        day = int(round(((i + 1) * (available_span + 1)) / (count + 1)))
        day = min_day + day - 1
        day = max(min_day, min(day, days_in_month))

        # Ensure unique days when rounding collides.
        if day in used:
            forward = day + 1
            while forward <= days_in_month and forward in used:
                forward += 1
            if forward <= days_in_month:
                day = forward
            else:
                backward = day - 1
                while backward >= min_day and backward in used:
                    backward -= 1
                if backward >= min_day:
                    day = backward

        used.add(day)
        result.append(day)

    return result


def _prepare_assignments(
    doc_ids: List[str],
    *,
    mode: str,
    seed: int,
) -> Dict[str, str]:
    ordered_ids = sorted(doc_ids)
    rng = random.Random(seed)

    if mode == "random":
        rng.shuffle(ordered_ids)

    quotas = _month_quotas(len(ordered_ids), len(TARGET_MONTHS))
    assignments: Dict[str, str] = {}

    cursor = 0
    for (year, month), quota in zip(TARGET_MONTHS, quotas):
        bucket_ids = ordered_ids[cursor : cursor + quota]
        cursor += quota

        min_day = MONTH_MIN_DAY.get((year, month), 1)
        days = _spread_days_in_month(
            year,
            month,
            len(bucket_ids),
            min_day=min_day,
        )
        if mode == "random":
            rng.shuffle(days)

        for doc_id, day in zip(bucket_ids, days):
            assignments[doc_id] = date(year, month, day).isoformat()

    return assignments


def _assignment_counts(assignments: Dict[str, str]) -> Dict[str, int]:
    counts: Dict[str, int] = {}
    for value in assignments.values():
        month_key = value[:7]  # YYYY-MM
        counts[month_key] = counts.get(month_key, 0) + 1
    return dict(sorted(counts.items()))


def _update_events_dates(
    db,
    *,
    dry_run: bool,
    batch_size: int,
    mode: str,
    seed: int,
) -> Tuple[int, int, int, int]:
    col_ref = db.collection(TARGET_COLLECTION)
    docs = list(col_ref.stream())
    total = len(docs)

    if total == 0:
        print("No documents found in 'events'. Nothing to update.")
        return 0, 0, 0, 0

    assignments = _prepare_assignments(
        [doc.id for doc in docs],
        mode=mode,
        seed=seed,
    )
    month_counts = _assignment_counts(assignments)
    print("Planned distribution by month:")
    for month_key, count in month_counts.items():
        print(f"  {month_key}: {count}")
    print("")

    to_update = 0
    unchanged = 0
    commits = 0

    batch = db.batch()
    pending_ops = 0
    docs_sorted = sorted(docs, key=lambda d: d.id)

    for doc in docs_sorted:
        data = doc.to_dict() or {}
        old_raw = data.get("date")
        old_date = old_raw if isinstance(old_raw, str) else str(old_raw)
        new_date = assignments[doc.id]

        if old_date == new_date:
            unchanged += 1
            continue

        to_update += 1
        print(f"{doc.id}: {old_date!r} -> '{new_date}'")

        if dry_run:
            continue

        payload = {
            "date": new_date,
            "updatedAt": firestore.SERVER_TIMESTAMP,
        }
        batch.set(doc.reference, payload, merge=True)
        pending_ops += 1

        if pending_ops >= batch_size:
            batch.commit()
            commits += 1
            batch = db.batch()
            pending_ops = 0

    if not dry_run and pending_ops > 0:
        batch.commit()
        commits += 1

    return total, to_update, unchanged, commits


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Update ALL events.date values and distribute them across "
            "March, April, and May 2026 using YYYY-MM-DD format. "
            "Only touches the 'events' collection."
        )
    )
    parser.add_argument(
        "service_account",
        nargs="?",
        help=(
            "Path to Firebase service account JSON. "
            "Can be provided via GOOGLE_APPLICATION_CREDENTIALS."
        ),
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview updates without writing changes.",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=400,
        help="Max writes per batch commit (default: 400, max: 500).",
    )
    parser.add_argument(
        "--mode",
        choices=["ordered", "random"],
        default="ordered",
        help=(
            "Date assignment strategy. "
            "'ordered' keeps deterministic ordering, "
            "'random' shuffles event IDs before assignment."
        ),
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=2026,
        help="Random seed used only when --mode random (default: 2026).",
    )
    args = parser.parse_args()

    if args.batch_size <= 0 or args.batch_size > 500:
        raise SystemExit("--batch-size must be between 1 and 500.")

    cred_path = _resolve_credentials_path(args.service_account)
    db = _init_firestore(cred_path)

    print("Starting events date normalization...")
    print(f"Target collection: {TARGET_COLLECTION}")
    print("Target range: 2026-03-20 -> 2026-05-31")
    print("Target months: 2026-03, 2026-04, 2026-05")
    print("March rule: dates are restricted to day 20..31")
    print(f"Mode: {args.mode}")
    print(f"Dry run: {args.dry_run}")
    if args.mode == "random":
        print(f"Seed: {args.seed}")
    print("")

    total, updated, unchanged, commits = _update_events_dates(
        db,
        dry_run=args.dry_run,
        batch_size=args.batch_size,
        mode=args.mode,
        seed=args.seed,
    )

    print("")
    print("== Summary ==")
    print(f"Total documents in '{TARGET_COLLECTION}': {total}")
    print(f"Documents updated: {updated}")
    print(f"Documents already matching assigned date: {unchanged}")
    print(f"Batch commits: {commits}")

    if args.dry_run:
        print("Dry-run finished. Re-run without --dry-run to apply updates.")
    else:
        print("Events dates updated successfully.")
        print(
            "All events now use normalized string dates (YYYY-MM-DD) "
            "distributed across March, April, and May 2026."
        )


if __name__ == "__main__":
    main()

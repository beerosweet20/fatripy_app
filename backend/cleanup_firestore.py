import argparse
import os
from typing import Dict, Tuple

import firebase_admin
from firebase_admin import credentials, firestore


COLLECTION_MIGRATIONS: Tuple[Tuple[str, str], ...] = (
    ("Hotels", "hotels"),
    ("Activities", "activities"),
)


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


def _copy_with_merge(
    db,
    source_collection: str,
    target_collection: str,
    *,
    dry_run: bool,
    batch_size: int,
) -> Dict[str, int]:
    source_ref = db.collection(source_collection)
    target_ref = db.collection(target_collection)

    processed = 0
    merged = 0
    commits = 0

    if dry_run:
        for doc in source_ref.stream():
            processed += 1
            print(
                f"[DRY-RUN] {source_collection}/{doc.id} -> "
                f"{target_collection}/{doc.id}"
            )
        return {
            "processed": processed,
            "merged": merged,
            "commits": commits,
        }

    batch = db.batch()
    pending_ops = 0

    for doc in source_ref.stream():
        data = doc.to_dict() or {}
        # Keep the same document ID and keep all fields as-is.
        batch.set(target_ref.document(doc.id), data, merge=True)
        processed += 1
        merged += 1
        pending_ops += 1

        if pending_ops >= batch_size:
            batch.commit()
            commits += 1
            batch = db.batch()
            pending_ops = 0

    if pending_ops > 0:
        batch.commit()
        commits += 1

    return {
        "processed": processed,
        "merged": merged,
        "commits": commits,
    }


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Merge uppercase Firestore collections into lowercase ones "
            "using identical document IDs."
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
        help="Preview planned operations without writing any data.",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=400,
        help="Max writes per batch commit (default: 400).",
    )
    args = parser.parse_args()

    if args.batch_size <= 0 or args.batch_size > 500:
        raise SystemExit("--batch-size must be between 1 and 500.")

    cred_path = _resolve_credentials_path(args.service_account)
    db = _init_firestore(cred_path)

    print("Starting Firestore cleanup...")
    print(f"Dry run: {args.dry_run}")
    print("")

    for source_collection, target_collection in COLLECTION_MIGRATIONS:
        print(f"== {source_collection} -> {target_collection} ==")
        summary = _copy_with_merge(
            db,
            source_collection,
            target_collection,
            dry_run=args.dry_run,
            batch_size=args.batch_size,
        )
        print(
            f"Processed: {summary['processed']} | "
            f"Merged: {summary['merged']} | "
            f"Batch commits: {summary['commits']}"
        )
        print("")

    if args.dry_run:
        print(
            "Dry-run finished. Re-run without --dry-run to apply changes."
        )
    else:
        print(
            "Cleanup finished successfully. "
            "After validating data, you can delete 'Hotels' and 'Activities' "
            "manually from Firebase Console."
        )


if __name__ == "__main__":
    main()

import argparse
import os
from typing import Dict, Tuple

import firebase_admin
from firebase_admin import credentials, firestore


LEGACY_COLLECTIONS: Tuple[str, ...] = (
    "Hotels",
    "Activities",
    "Guides",
    "plans",
    "test",
)

PROTECTED_COLLECTIONS: Tuple[str, ...] = (
    "hotels",
    "activities",
    "bookings",
    "events",
    "tripPlans",
    "users",
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


def _validate_targets() -> None:
    overlap = set(LEGACY_COLLECTIONS).intersection(PROTECTED_COLLECTIONS)
    if overlap:
        raise SystemExit(
            f"Safety check failed. Target collections overlap with protected: {sorted(overlap)}"
        )


def _delete_collection(
    db,
    collection_name: str,
    *,
    dry_run: bool,
    batch_size: int,
) -> Dict[str, int]:
    collection_ref = db.collection(collection_name)
    docs = list(collection_ref.stream())
    total_docs = len(docs)

    print(f"== Collection: {collection_name} ==")
    print(f"Documents found: {total_docs}")

    if dry_run:
        print(f"[DRY-RUN] Would delete {total_docs} documents from '{collection_name}'.")
        print("")
        return {"found": total_docs, "deleted": 0, "commits": 0}

    if total_docs == 0:
        print("No documents to delete.")
        print("")
        return {"found": 0, "deleted": 0, "commits": 0}

    deleted = 0
    commits = 0
    batch = db.batch()
    pending_ops = 0

    for doc in docs:
        batch.delete(doc.reference)
        deleted += 1
        pending_ops += 1

        if pending_ops >= batch_size:
            batch.commit()
            commits += 1
            batch = db.batch()
            pending_ops = 0

    if pending_ops > 0:
        batch.commit()
        commits += 1

    print(f"Deleted: {deleted}")
    print(f"Batch commits: {commits}")
    print("")

    return {"found": total_docs, "deleted": deleted, "commits": commits}


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Delete legacy Firestore collections safely. "
            "Targets only: Hotels, Activities, Guides, plans, test."
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
        help="Preview deletions without writing changes.",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=400,
        help="Max delete operations per batch commit (default: 400).",
    )
    args = parser.parse_args()

    if args.batch_size <= 0 or args.batch_size > 500:
        raise SystemExit("--batch-size must be between 1 and 500.")

    _validate_targets()
    cred_path = _resolve_credentials_path(args.service_account)
    db = _init_firestore(cred_path)

    print("Starting legacy collections cleanup...")
    print(f"Dry run: {args.dry_run}")
    print(f"Target collections: {', '.join(LEGACY_COLLECTIONS)}")
    print("")

    total_found = 0
    total_deleted = 0
    total_commits = 0

    for collection_name in LEGACY_COLLECTIONS:
        summary = _delete_collection(
            db,
            collection_name,
            dry_run=args.dry_run,
            batch_size=args.batch_size,
        )
        total_found += summary["found"]
        total_deleted += summary["deleted"]
        total_commits += summary["commits"]

    print("== Summary ==")
    print(f"Total documents found: {total_found}")
    print(f"Total documents deleted: {total_deleted}")
    print(f"Total batch commits: {total_commits}")

    if args.dry_run:
        print("Dry-run finished. Re-run without --dry-run to apply deletions.")
    else:
        print("Legacy collections deletion finished successfully.")
        print(
            "Protected collections were not touched: "
            + ", ".join(PROTECTED_COLLECTIONS)
        )


if __name__ == "__main__":
    main()

import argparse
import os
from typing import Dict, Iterable, Optional

import firebase_admin
from firebase_admin import credentials, firestore


CITY_KEYWORDS: Dict[str, Iterable[str]] = {
    "Riyadh": (
        "riyadh",
        "diriyah",
        "al olaya",
        "olaya",
        "murabba",
        "hittin",
        "sudus",
        "wadi hanifa",
        "boulevard",
    ),
    "Jeddah": ("jeddah", "al balad"),
    "Mecca": ("mecca", "makkah"),
    "Medina": ("medina", "madinah"),
    "Dammam": ("dammam",),
    "Khobar": ("khobar", "alkhobar"),
    "Abha": ("abha", "soudah", "muftaha"),
    "Taif": ("taif", "al hada", "al shafa"),
    "Jazan": ("jazan", "jizan"),
}


def _init_firestore(cred_path: str):
    if not firebase_admin._apps:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    return firestore.client()


def _detect_city(data: dict, doc_id: str) -> Optional[str]:
    current_city = str(data.get("city") or "").strip()
    if current_city:
        return current_city

    haystack = " ".join(
        str(data.get(key) or "")
        for key in ("location", "title", "name")
    )
    haystack = f"{haystack} {doc_id}".lower()

    for city, keywords in CITY_KEYWORDS.items():
        for keyword in keywords:
            if keyword in haystack:
                return city
    return None


def main():
    parser = argparse.ArgumentParser(
        description="Backfill missing city field in Firestore activities."
    )
    parser.add_argument(
        "service_account",
        nargs="?",
        help="Path to Firebase service account JSON. "
        "Can be set via GOOGLE_APPLICATION_CREDENTIALS.",
    )
    parser.add_argument(
        "--collection",
        default="activities",
        help="Collection name to update (default: activities).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print intended updates without writing.",
    )
    args = parser.parse_args()

    cred_path = args.service_account or os.environ.get(
        "GOOGLE_APPLICATION_CREDENTIALS"
    )
    if not cred_path or not os.path.exists(cred_path):
        raise SystemExit(
            "Service account JSON not found. Provide a path or set "
            "GOOGLE_APPLICATION_CREDENTIALS."
        )

    db = _init_firestore(cred_path)
    docs = db.collection(args.collection).stream()

    updated = 0
    skipped = 0
    unresolved = 0

    for doc in docs:
        data = doc.to_dict() or {}
        current_city = str(data.get("city") or "").strip()
        if current_city:
            skipped += 1
            continue

        inferred_city = _detect_city(data, doc.id)
        if inferred_city is None:
            unresolved += 1
            continue

        if args.dry_run:
            print(f"[DRY-RUN] {doc.id} -> city={inferred_city}")
        else:
            doc.reference.set(
                {
                    "city": inferred_city,
                    "updatedAt": firestore.SERVER_TIMESTAMP,
                },
                merge=True,
            )
            print(f"[UPDATED] {doc.id} -> city={inferred_city}")
        updated += 1

    print(
        f"\nDone. collection={args.collection} "
        f"updated={updated} skipped={skipped} unresolved={unresolved}"
    )


if __name__ == "__main__":
    main()

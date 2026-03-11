import argparse
import datetime as dt
import json
import datetime as dt
import os
from typing import Dict, Any, Iterable, List

import firebase_admin
from firebase_admin import credentials, firestore


def _init_firestore(cred_path: str):
    if not firebase_admin._apps:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    return firestore.client()


def _serialize_value(value: Any) -> Any:
    if isinstance(value, (dict, list)):
        return json.dumps(
            value,
            ensure_ascii=False,
            default=_json_default,
        )
    if hasattr(value, "isoformat"):
        try:
            return value.isoformat()
        except Exception:
            return str(value)
    return value


def _json_default(value: Any) -> Any:
    if hasattr(value, "isoformat"):
        try:
            return value.isoformat()
        except Exception:
            return str(value)
    return str(value)


def _write_json(path: str, docs: List[Dict[str, Any]]):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(
            docs,
            f,
            ensure_ascii=False,
            indent=2,
            default=_json_default,
        )


def _write_csv(path: str, docs: List[Dict[str, Any]]):
    import csv

    if not docs:
        with open(path, "w", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["id"])
        return

    fieldnames = set()
    for d in docs:
        fieldnames.update(d.keys())
    fieldnames = ["id"] + [k for k in sorted(fieldnames) if k != "id"]

    with open(path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for d in docs:
            row = {k: _serialize_value(v) for k, v in d.items()}
            writer.writerow(row)


def _export_collection(
    db, collection_name: str, out_dir: str, fmt: str
) -> Dict[str, int]:
    docs_out: List[Dict[str, Any]] = []
    for doc in db.collection(collection_name).stream():
        data = doc.to_dict() or {}
        data["id"] = doc.id
        docs_out.append(data)

    count = len(docs_out)
    if fmt in ("json", "both"):
        _write_json(os.path.join(out_dir, f"{collection_name}.json"), docs_out)
    if fmt in ("csv", "both"):
        _write_csv(os.path.join(out_dir, f"{collection_name}.csv"), docs_out)

    return {"collection": collection_name, "count": count}


def _list_collections(db) -> Iterable[str]:
    return [c.id for c in db.collections()]


def main():
    parser = argparse.ArgumentParser(
        description="Export Firestore collections to JSON/CSV."
    )
    parser.add_argument(
        "service_account",
        nargs="?",
        help="Path to Firebase service account JSON. "
        "Can be set via GOOGLE_APPLICATION_CREDENTIALS.",
    )
    parser.add_argument(
        "--collections",
        help="Comma-separated list of collections to export. "
        "If omitted, exports all collections.",
    )
    parser.add_argument(
        "--out",
        help="Output directory. Default: backend/exports/<timestamp>",
    )
    parser.add_argument(
        "--format",
        choices=["json", "csv", "both"],
        default="both",
        help="Export format (default: both).",
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

    out_dir = args.out
    if not out_dir:
        ts = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
        out_dir = os.path.join(os.path.dirname(__file__), "exports", ts)
    os.makedirs(out_dir, exist_ok=True)

    db = _init_firestore(cred_path)
    if args.collections:
        collections = [c.strip() for c in args.collections.split(",") if c.strip()]
    else:
        collections = list(_list_collections(db))

    results = []
    for name in collections:
        results.append(_export_collection(db, name, out_dir, args.format))

    print(f"Exported to: {out_dir}")
    for r in results:
        print(f"{r['collection']}: {r['count']} docs")


if __name__ == "__main__":
    main()

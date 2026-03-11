import json
import os
import sys

import firebase_admin
from firebase_admin import credentials, firestore


def _usage():
  print(
    "Usage: python seed_booking_links.py <service_account.json> [links.json]\n"
    "Env: GOOGLE_APPLICATION_CREDENTIALS can replace first argument."
  )


def _load_json(path):
  with open(path, "r", encoding="utf-8") as f:
    return json.load(f)


def _init_firestore(cred_path):
  cred = credentials.Certificate(cred_path)
  if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)
  return firestore.client()


def _update_collection(db, collection, id_field, items):
  updated = 0
  missing = 0
  for item in items:
    if not isinstance(item, dict):
      continue
    doc_id = item.get("docId")
    if doc_id:
      doc_ref = db.collection(collection).document(doc_id)
      doc = doc_ref.get()
      if not doc.exists:
        missing += 1
        continue
    else:
      id_value = item.get(id_field)
      if not id_value:
        missing += 1
        continue
      q = (
        db.collection(collection)
        .where(id_field, "==", id_value)
        .limit(1)
        .stream()
      )
      doc = next(q, None)
      if doc is None:
        missing += 1
        continue
      doc_ref = doc.reference

    payload = {}
    if item.get("bookingUrl"):
      payload["bookingUrl"] = item["bookingUrl"]
    if item.get("mapsUrl"):
      payload["mapsUrl"] = item["mapsUrl"]
    if not payload:
      continue

    doc_ref.set(payload, merge=True)
    updated += 1

  return updated, missing


def _update_collections(db, collections, id_field, items):
  total_updated = 0
  total_missing = 0
  for collection in collections:
    updated, missing = _update_collection(db, collection, id_field, items)
    total_updated += updated
    total_missing += missing
  return total_updated, total_missing


def main():
  cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
  links_path = None

  if len(sys.argv) >= 2:
    cred_path = cred_path or sys.argv[1]
  if len(sys.argv) >= 3:
    links_path = sys.argv[2]

  if not cred_path:
    _usage()
    sys.exit(2)

  if not links_path:
    links_path = os.path.join(os.path.dirname(__file__), "booking_links.json")

  if not os.path.exists(links_path):
    print(f"Links file not found: {links_path}")
    sys.exit(2)

  data = _load_json(links_path)
  db = _init_firestore(cred_path)

  hotels = data.get("hotels", [])
  activities = data.get("activities", [])

  h_updated, h_missing = _update_collections(
    db,
    ["hotels"],
    "hotelId",
    hotels,
  )
  a_updated, a_missing = _update_collections(
    db,
    ["activities"],
    "activityId",
    activities,
  )

  print(
    f"Hotels updated: {h_updated}, missing: {h_missing}\n"
    f"Activities updated: {a_updated}, missing: {a_missing}"
  )


if __name__ == "__main__":
  main()

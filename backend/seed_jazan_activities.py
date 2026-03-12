import math
import os
import sys
from typing import Dict, List, Tuple

import firebase_admin
from firebase_admin import credentials, firestore


def _usage() -> None:
    print(
        'Usage: python seed_jazan_activities.py <service_account.json>\n'
        'Env: GOOGLE_APPLICATION_CREDENTIALS can replace the argument.'
    )


def _init_firestore(cred_path: str):
    cred = credentials.Certificate(cred_path)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    return firestore.client()


def _slug(text: str) -> str:
    return (
        text.lower()
        .replace('&', 'and')
        .replace('/', '-')
        .replace(',', '')
        .replace('.', '')
        .replace('  ', ' ')
        .strip()
        .replace(' ', '_')
    )


def _jitter(lat: float, lng: float, i: int) -> Tuple[float, float]:
    angle = (i * 29) % 360
    radius = 0.006 + (i % 5) * 0.002
    dlat = radius * math.cos(math.radians(angle))
    dlng = radius * math.sin(math.radians(angle))
    return lat + dlat, lng + dlng


JAZAN_ACTIVITY_DATA: List[Dict[str, str]] = [
    {'theme': 'Farasan Islands', 'price': '120-220', 'open': '8 AM', 'close': '5 PM'},
    {'theme': 'Jazan Corniche', 'price': 'Free', 'open': '6 AM', 'close': '12 AM'},
    {'theme': 'Fayfa Mountains', 'price': 'Free', 'open': '7 AM', 'close': '7 PM'},
    {'theme': 'Al-Dosariyah Castle', 'price': '20-40', 'open': '9 AM', 'close': '9 PM'},
    {'theme': 'Heritage Village', 'price': '25-60', 'open': '4 PM', 'close': '11 PM'},
    {'theme': 'Sabya Market', 'price': 'Free', 'open': '5 PM', 'close': '11 PM'},
    {'theme': 'Jazan Waterfront', 'price': 'Free', 'open': '6 AM', 'close': '11 PM'},
    {'theme': 'Wadi Lajab', 'price': '50-120', 'open': '7 AM', 'close': '6 PM'},
]


def _build_jazan_activities(base_lat: float, base_lng: float) -> List[Dict[str, object]]:
    activities: List[Dict[str, object]] = []
    for i, item in enumerate(JAZAN_ACTIVITY_DATA):
        theme = item['theme']
        name = f'Visit {theme}'
        doc_id = _slug(f'{name}_Jazan')
        lat, lng = _jitter(base_lat, base_lng, i + 1)
        rating = round(4.1 + (i % 4) * 0.2, 1)

        activities.append(
            {
                'id': doc_id,
                'activityId': doc_id,
                'name': name,
                'location': f'{theme}, Jazan',
                'city': 'Jazan',
                'price': item['price'],
                'rating': rating,
                'openHours': item['open'],
                'closeHours': item['close'],
                'googleMaps': f'https://maps.google.com/?q={name.replace(" ", "+")}',
                'mapsUrl': f'https://maps.google.com/?q={name.replace(" ", "+")}',
                'lat': lat,
                'lng': lng,
            }
        )
    return activities


def main() -> None:
    cred_path = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
    if len(sys.argv) >= 2:
        cred_path = cred_path or sys.argv[1]

    if not cred_path or not os.path.exists(cred_path):
        _usage()
        sys.exit(2)

    db = _init_firestore(cred_path)
    activities_ref = db.collection('activities')
    jazan_lat = 16.8892
    jazan_lng = 42.5707

    activities = _build_jazan_activities(jazan_lat, jazan_lng)
    for activity in activities:
        activities_ref.document(activity['id']).set(activity, merge=True)

    print(f'Seeded/updated {len(activities)} activities for Jazan in "activities".')


if __name__ == '__main__':
    main()

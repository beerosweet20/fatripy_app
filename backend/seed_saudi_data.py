import math
import os
import sys
from typing import Dict, List, Tuple

import firebase_admin
from firebase_admin import credentials, firestore


def _usage():
    print(
        "Usage: python seed_saudi_data.py <service_account.json>\n"
        "Env: GOOGLE_APPLICATION_CREDENTIALS can replace the argument."
    )


def _init_firestore(cred_path: str):
    cred = credentials.Certificate(cred_path)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    return firestore.client()


def _slug(text: str) -> str:
    return (
        text.lower()
        .replace("&", "and")
        .replace("/", "-")
        .replace(",", "")
        .replace(".", "")
        .replace("  ", " ")
        .strip()
        .replace(" ", "_")
    )


def _jitter(lat: float, lng: float, i: int) -> Tuple[float, float]:
    # deterministic small offset
    angle = (i * 37) % 360
    radius = 0.01 + (i % 5) * 0.003
    dlat = radius * math.cos(math.radians(angle))
    dlng = radius * math.sin(math.radians(angle))
    return lat + dlat, lng + dlng


CITY_DATA: Dict[str, Dict] = {
    "Riyadh": {
        "lat": 24.7136,
        "lng": 46.6753,
        "themes": [
            "Diriyah",
            "Al Turaif",
            "King Abdulaziz Center",
            "Boulevard City",
            "Al Masmak",
            "Wadi Hanifa",
            "Murabba",
            "King Fahd Library",
            "Riyadh Front",
        ],
        "districts": ["Al Olaya", "Al Murabba", "Diriyah", "King Fahd Rd"],
    },
    "Jeddah": {
        "lat": 21.4858,
        "lng": 39.1925,
        "themes": [
            "Jeddah Corniche",
            "Al Balad",
            "Al Rahma Mosque",
            "Jeddah Yacht Club",
            "Red Sea Mall",
            "Fakieh Aquarium",
            "Al Tayebat Museum",
            "Historic Jeddah",
        ],
        "districts": ["Al Hamra", "Al Balad", "Corniche", "Al Zahra"],
    },
    "Mecca": {
        "lat": 21.3891,
        "lng": 39.8579,
        "themes": [
            "Masjid al-Haram",
            "Mina",
            "Arafat",
            "Clock Tower",
            "Hira Cave",
            "Jabal Al Noor",
            "Zamzam Museum",
        ],
        "districts": ["Ajyad", "Al Aziziyah", "Mina", "Al Misfalah"],
    },
    "Medina": {
        "lat": 24.5247,
        "lng": 39.5692,
        "themes": [
            "Al-Masjid an-Nabawi",
            "Quba Mosque",
            "Uhud Mountain",
            "Qiblatain Mosque",
            "Hejaz Railway Museum",
            "Yanbu Road",
        ],
        "districts": ["Central Area", "Quba", "Uhud", "Al Khalidiyah"],
    },
    "Dammam": {
        "lat": 26.4207,
        "lng": 50.0888,
        "themes": [
            "Dammam Corniche",
            "Heritage Village",
            "Marjan Island",
            "Half Moon Bay",
            "King Fahd Park",
            "Marina Mall",
        ],
        "districts": ["Corniche", "Al Faisaliyah", "Al Shati", "Al Aziziyah"],
    },
    "Khobar": {
        "lat": 26.2172,
        "lng": 50.1971,
        "themes": [
            "Khobar Corniche",
            "Al Rashid Mall",
            "Half Moon Bay",
            "Scitech",
            "Waterfront Walk",
            "Sunset Beach",
        ],
        "districts": ["Corniche", "Al Ulaya", "Al Aqrabiyah", "Al Bandariyah"],
    },
    "Abha": {
        "lat": 18.2465,
        "lng": 42.5117,
        "themes": [
            "Al Soudah",
            "Habala Village",
            "Abha Dam",
            "Al Muftaha",
            "Green Mountain",
            "Shada Castle",
        ],
        "districts": ["Al Soudah", "Al Muftaha", "Al Nuzhah", "Downtown"],
    },
    "Taif": {
        "lat": 21.2703,
        "lng": 40.4158,
        "themes": [
            "Al Shafa",
            "Al Hada",
            "Taif Rose Gardens",
            "Al Rudaf Park",
            "Souq Okaz",
            "Al Wahbah Crater",
        ],
        "districts": ["Al Hada", "Al Shafa", "Al Rudaf", "Downtown"],
    },
    "Jazan": {
        "lat": 16.8892,
        "lng": 42.5707,
        "themes": [
            "Jazan Corniche",
            "Farasan Islands",
            "Fayfa Mountains",
            "Heritage Village",
            "Al-Dosariyah Castle",
            "Sabya",
        ],
        "districts": ["Corniche", "Sabya", "Al Shati", "Downtown"],
    },
}


HOTEL_TEMPLATES = [
    "Grand {city} Hotel",
    "{city} Heritage Palace",
    "{city} Skyline Suites",
    "{city} Oasis Resort",
    "{city} Gate Boutique",
    "{city} Royal Gardens",
    "{city} Cityline Hotel",
    "{city} Horizon Suites",
]


ACTIVITY_TEMPLATES = [
    ("Visit {theme}", "Free", "8 AM", "10 PM"),
    ("{theme} Walk", "Free", "6 AM", "11 PM"),
    ("{theme} Museum", "40-90", "9 AM", "9 PM"),
    ("{theme} Park", "Free", "7 AM", "11 PM"),
    ("{theme} Market", "20-80", "4 PM", "11 PM"),
    ("{theme} Cafe", "25-70", "8 AM", "12 AM"),
    ("{theme} Viewpoint", "Free", "6 AM", "10 PM"),
    ("{theme} Waterfront", "Free", "6 AM", "11 PM"),
    ("{theme} Cultural Center", "30-100", "9 AM", "9 PM"),
    ("{theme} Family Zone", "40-140", "10 AM", "11 PM"),
    ("{theme} Trail", "Free", "6 AM", "8 PM"),
    ("{theme} Gallery", "30-90", "10 AM", "8 PM"),
]

EVENT_TEMPLATES = [
    ("{city} Cultural Nights", "December", "6 PM - 10 PM"),
    ("{city} Food Festival", "November", "4 PM - 11 PM"),
    ("{city} Heritage Week", "January", "5 PM - 9 PM"),
]


def _build_hotels(city: str, base_lat: float, base_lng: float):
    hotels = []
    districts = CITY_DATA[city]["districts"]
    for i, tpl in enumerate(HOTEL_TEMPLATES):
        name = tpl.format(city=city)
        doc_id = _slug(f"{name}_{city}")
        lat, lng = _jitter(base_lat, base_lng, i + 1)
        price_min = 350 + (i * 80)
        price_max = price_min + 200
        rating = round(4.1 + (i % 5) * 0.15, 1)
        facilities = [
            "Family rooms",
            "Wi‑Fi",
            "Restaurant",
            "Parking",
        ]
        if i % 2 == 0:
            facilities.append("Pool")
        if i % 3 == 0:
            facilities.append("Gym")
        location = f"{districts[i % len(districts)]}, {city}"
        hotels.append(
            {
                "id": doc_id,
                "hotelId": doc_id,
                "name": name,
                "location": location,
                "city": city,
                "priceMin": price_min,
                "priceMax": price_max,
                "pricePerNight": (price_min + price_max) / 2,
                "rating": rating,
                "planType": ["cultural", "adventure", "family relax"][i % 3],
                "facilities": facilities,
                "amenities": ", ".join(facilities),
                "lat": lat,
                "lng": lng,
                "googleMaps": f"https://maps.google.com/?q={name.replace(' ', '+')}",
                "mapsUrl": f"https://maps.google.com/?q={name.replace(' ', '+')}",
            }
        )
    return hotels


def _build_activities(city: str, base_lat: float, base_lng: float):
    activities = []
    themes = CITY_DATA[city]["themes"]
    for i, tpl in enumerate(ACTIVITY_TEMPLATES):
        theme = themes[i % len(themes)]
        name = tpl[0].format(theme=theme)
        doc_id = _slug(f"{name}_{city}")
        lat, lng = _jitter(base_lat, base_lng, 100 + i)
        price, open_h, close_h = tpl[1], tpl[2], tpl[3]
        rating = round(4.0 + (i % 6) * 0.12, 1)
        location = f"{theme}, {city}"
        activities.append(
            {
                "id": doc_id,
                "activityId": doc_id,
                "name": name,
                "location": location,
                "city": city,
                "price": price,
                "rating": rating,
                "openHours": open_h,
                "closeHours": close_h,
                "googleMaps": f"https://maps.google.com/?q={name.replace(' ', '+')}",
                "mapsUrl": f"https://maps.google.com/?q={name.replace(' ', '+')}",
                "lat": lat,
                "lng": lng,
            }
        )
    return activities


def _build_events(city: str):
    events = []
    themes = CITY_DATA[city]["themes"]
    for i, tpl in enumerate(EVENT_TEMPLATES):
        title = tpl[0].format(city=city)
        doc_id = _slug(f"{title}_{city}")
        location = themes[i % len(themes)]
        events.append(
            {
                "id": doc_id,
                "eventId": doc_id,
                "title": title,
                "date": tpl[1],
                "time": tpl[2],
                "location": f"{location}, {city}",
                "description": f"A seasonal event in {city} featuring culture, food, and family activities.",
                "city": city,
                "mapsUrl": f"https://maps.google.com/?q={title.replace(' ', '+')}",
            }
        )
    return events


def main():
    cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if len(sys.argv) >= 2:
        cred_path = cred_path or sys.argv[1]
    if not cred_path or not os.path.exists(cred_path):
        _usage()
        sys.exit(2)

    db = _init_firestore(cred_path)

    hotels_ref = db.collection("hotels")
    activities_ref = db.collection("activities")
    events_ref = db.collection("events")

    hotel_count = 0
    activity_count = 0
    event_count = 0

    for city, meta in CITY_DATA.items():
        hotels = _build_hotels(city, meta["lat"], meta["lng"])
        activities = _build_activities(city, meta["lat"], meta["lng"])
        events = _build_events(city)

        for h in hotels:
            hotels_ref.document(h["id"]).set(h, merge=True)
            hotel_count += 1
        for a in activities:
            activities_ref.document(a["id"]).set(a, merge=True)
            activity_count += 1
        for e in events:
            events_ref.document(e["id"]).set(e, merge=True)
            event_count += 1

    print(
        f"Seed complete. Hotels: {hotel_count}, Activities: {activity_count}, "
        f"Events: {event_count} "
        f"across {len(CITY_DATA)} cities."
    )


if __name__ == "__main__":
    main()

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
    "{city} Waterfront Residence",
    "{city} Panorama Stay",
    "{city} Park View Hotel",
    "{city} Family Comfort Inn",
    "{city} Executive Suites",
    "{city} Corniche Hotel",
    "{city} Downtown Residence",
    "{city} Landmark Hotel",
    "{city} Elite Palace",
    "{city} Vista Resort",
    "{city} Rose Boutique Hotel",
    "{city} Marina Suites",
    "{city} Palm Residency",
    "{city} Horizon Palace",
    "{city} Signature Stay",
    "{city} Pearl Resort",
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
    ("{theme} View Deck", "25-60", "8 AM", "10 PM"),
    ("{theme} Heritage House", "20-50", "9 AM", "8 PM"),
    ("{theme} Adventure Park", "60-180", "3 PM", "11 PM"),
    ("{theme} Food Street", "35-120", "4 PM", "12 AM"),
    ("{theme} Family Garden", "Free", "7 AM", "11 PM"),
    ("{theme} Art Experience", "45-110", "10 AM", "9 PM"),
    ("{theme} Eco Trail", "Free", "6 AM", "7 PM"),
    ("{theme} Scenic Ride", "55-140", "4 PM", "10 PM"),
    ("{theme} Kids Discovery", "50-120", "10 AM", "10 PM"),
    ("{theme} Observation Point", "Free", "6 AM", "10 PM"),
    ("{theme} Marina Walk", "Free", "5 PM", "12 AM"),
    ("{theme} Storytelling Center", "25-70", "9 AM", "8 PM"),
    ("{theme} Science Hub", "35-95", "10 AM", "9 PM"),
    ("{theme} Wellness Escape", "80-220", "9 AM", "11 PM"),
    ("{theme} Heritage Market", "Free", "5 PM", "11 PM"),
    ("{theme} Cultural Plaza", "Free", "6 PM", "11 PM"),
    ("{theme} Sunset Lounge", "60-180", "5 PM", "1 AM"),
    ("{theme} Experience Center", "45-130", "11 AM", "10 PM"),
    ("{theme} Interactive Museum", "35-110", "10 AM", "9 PM"),
    ("{theme} Family Theater", "45-150", "4 PM", "11 PM"),
    ("{theme} Nature Retreat", "70-190", "8 AM", "8 PM"),
    ("{theme} Heritage Walk", "Free", "5 PM", "10 PM"),
    ("{theme} Discovery Tour", "40-120", "9 AM", "7 PM"),
    ("{theme} Local Taste Stop", "30-95", "1 PM", "11 PM"),
    ("{theme} Panorama Trail", "Free", "6 AM", "6 PM"),
    ("{theme} Creative Studio", "35-100", "11 AM", "9 PM"),
    ("{theme} Weekend Bazaar", "Free", "4 PM", "11 PM"),
    ("{theme} Leisure Hub", "50-160", "10 AM", "12 AM"),
]

EVENT_TEMPLATES = [
    ("{city} Winter Festival", "2026-01-12", "5 PM - 11 PM"),
    ("{city} Family Weekend", "2026-02-18", "4 PM - 10 PM"),
    ("{city} Spring Market", "2026-03-14", "5 PM - 11 PM"),
    ("{city} Heritage Nights", "2026-04-09", "6 PM - 11 PM"),
    ("{city} Food Street Festival", "2026-05-21", "6 PM - 12 AM"),
    ("{city} Summer Nights", "2026-06-25", "5 PM - 11 PM"),
    ("{city} Waterfront Festival", "2026-07-17", "5 PM - 11 PM"),
    ("{city} Cultural Week", "2026-08-20", "4 PM - 10 PM"),
    ("{city} Art & Music Nights", "2026-09-18", "6 PM - 11 PM"),
    ("{city} Outdoor Adventure Expo", "2026-10-22", "4 PM - 10 PM"),
    ("{city} Local Crafts Fair", "2026-11-13", "5 PM - 10 PM"),
    ("{city} Year End Celebration", "2026-12-18", "6 PM - 11 PM"),
    ("{city} Heritage Weekend", "2026-01-29", "4 PM - 10 PM"),
    ("{city} Ramadan Nights", "2026-03-27", "8 PM - 1 AM"),
    ("{city} Eid Festivities", "2026-04-04", "5 PM - 12 AM"),
    ("{city} Back to Summer Fest", "2026-06-12", "6 PM - 11 PM"),
    ("{city} National Day Countdown", "2026-09-22", "5 PM - 12 AM"),
    ("{city} Weekend Waterfront Live", "2026-11-27", "6 PM - 11 PM"),
]


CITY_GUIDES = {
    "Riyadh": ("Mohammed Atef", "5", "Arabic-English", "0511111999", 4.4),
    "Jeddah": ("Lina Hassan", "8", "Arabic-English", "0522222888", 4.8),
    "Mecca": ("Abdulrahman Al Harbi", "9", "Arabic-English-Urdu", "0533200441", 4.9),
    "Medina": ("Sara Al Zahrani", "6", "Arabic-English", "0541188332", 4.7),
    "Dammam": ("Yousef Al Qahtani", "7", "Arabic-English", "0551177334", 4.6),
    "Khobar": ("Norah Al Dosari", "6", "Arabic-English", "0561144221", 4.7),
    "Abha": ("Aisha Asiri", "8", "Arabic-English", "0504411882", 4.9),
    "Taif": ("Faisal Al Thaqafi", "7", "Arabic-English", "0509933772", 4.8),
    "Jazan": ("Huda Al Hakami", "6", "Arabic-English", "0537711008", 4.6),
}


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
        if i % 5 == 0:
            lat += 0.17
            lng += 0.11
        elif i % 5 == 3:
            lat -= 0.14
            lng += 0.09
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
                "description": f"A curated 2026 event in {city} featuring culture, food, family entertainment, and local experiences near {location}.",
                "city": city,
                "mapsUrl": f"https://maps.google.com/?q={title.replace(' ', '+')}",
            }
        )
    return events


def _build_guide(city: str):
    name, experience_years, languages, phone, rating = CITY_GUIDES[city]
    doc_id = _slug(f"{city}_{name}_guide")
    return {
        "id": doc_id,
        "name": name,
        "experienceYears": experience_years,
        "languages": languages,
        "phone": phone,
        "rating": rating,
        "city": city,
        "description": f"Local certified guide for {city} cultural experiences, landmarks, and family-friendly storytelling routes.",
    }


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
    guides_ref = db.collection("guides")

    hotel_count = 0
    activity_count = 0
    event_count = 0
    guide_count = 0

    for city, meta in CITY_DATA.items():
        hotels = _build_hotels(city, meta["lat"], meta["lng"])
        activities = _build_activities(city, meta["lat"], meta["lng"])
        events = _build_events(city)
        guide = _build_guide(city)

        for h in hotels:
            hotels_ref.document(h["id"]).set(h, merge=True)
            hotel_count += 1
        for a in activities:
            activities_ref.document(a["id"]).set(a, merge=True)
            activity_count += 1
        for e in events:
            events_ref.document(e["id"]).set(e, merge=True)
            event_count += 1
        guides_ref.document(guide["id"]).set(guide, merge=True)
        guide_count += 1

    print(
        f"Seed complete. Hotels: {hotel_count}, Activities: {activity_count}, "
        f"Events: {event_count}, Guides: {guide_count} "
        f"across {len(CITY_DATA)} cities."
    )


if __name__ == "__main__":
    main()

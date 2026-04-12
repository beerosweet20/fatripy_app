from fastapi import FastAPI
from pydantic import BaseModel
from typing import Any, Dict, List, Optional, Union
from datetime import date, datetime, timezone
import time
import re

from ai_recommender import (
    build_user_profile,
    rank_accommodations_ml,
    rank_activities_dl,
    accommodation_price_per_night,
    split_nearby_distant,
)

app = FastAPI()

# Input Models matching the Firestore schema DTOs coming from Flutter
class Accommodation(BaseModel):
    accommodationId: Optional[str] = None
    id: Optional[str] = None
    name: str
    pricePerNight: Optional[Union[float, int, str]] = None
    priceMin: Optional[Union[float, int, str]] = None
    priceMax: Optional[Union[float, int, str]] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    rating: Optional[Union[float, int, str]] = None
    location: Optional[str] = None
    amenities: Optional[Union[str, List[str]]] = None
    facilities: Optional[List[str]] = None
    planType: Optional[str] = None
    googleMaps: Optional[str] = None
    bookingUrl: Optional[str] = None
    mapsUrl: Optional[str] = None

    class Config:
        extra = "allow"

class Activity(BaseModel):
    activityId: Optional[str] = None
    id: Optional[str] = None
    name: str
    price: Optional[Union[float, int, str]] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    rating: Optional[Union[float, int, str]] = None
    location: Optional[str] = None
    open: Optional[str] = None
    close: Optional[str] = None
    time: Optional[str] = None
    openHours: Optional[str] = None
    closeHours: Optional[str] = None
    googleMaps: Optional[str] = None
    bookingUrl: Optional[str] = None
    mapsUrl: Optional[str] = None
    distanceType: Optional[str] = None

    class Config:
        extra = "allow"


class Event(BaseModel):
    title: str
    date: Optional[str] = None
    time: Optional[str] = None
    location: Optional[str] = None
    description: Optional[str] = None
    city: Optional[str] = None
    mapsUrl: Optional[str] = None

    class Config:
        extra = "allow"

class GenerateRequest(BaseModel):
    city: str
    budget: float
    days: int
    familyAges: List[str]
    accommodations: List[Accommodation]
    activities: List[Activity]
    events: List[Event] = []
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    # Backward-compatible aliases in case the client sends camelCase.
    startDate: Optional[str] = None
    endDate: Optional[str] = None


def _to_payload(model):
    if model is None:
        return None
    if hasattr(model, "model_dump"):
        return model.model_dump()
    return model.dict()


def _safe_float(value, default=0.0):
    try:
        if value is None:
            return default
        return float(value)
    except Exception:
        text = str(value).strip().lower() if value is not None else ""
        if not text:
            return default
        if "free" in text:
            return 0.0
        cleaned = text.replace(",", " ").replace("sar", " ").replace("sr", " ")
        numbers = []
        for token in cleaned.replace("-", " ").split():
            try:
                numbers.append(float(token))
            except Exception:
                continue
        if not numbers:
            return default
        if len(numbers) == 1:
            return numbers[0]
        return (numbers[0] + numbers[1]) / 2.0


def _robust_accommodation_price_per_night(accommodation):
    if accommodation is None:
        return None

    # Primary source from recommender helper.
    price = accommodation_price_per_night(accommodation)
    if price is not None:
        return price

    # Fallback for string prices like "300 SAR" or ranges.
    p = _safe_float(getattr(accommodation, "pricePerNight", None), None)
    if p is not None:
        return p
    pmin = _safe_float(getattr(accommodation, "priceMin", None), None)
    pmax = _safe_float(getattr(accommodation, "priceMax", None), None)
    if pmin is not None and pmax is not None:
        return (pmin + pmax) / 2.0
    if pmin is not None:
        return pmin
    if pmax is not None:
        return pmax
    return None


def _to_date(value) -> Optional[date]:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, date):
        return value
    if isinstance(value, (int, float)):
        # Accept Unix seconds or milliseconds.
        ts = float(value)
        if ts > 1_000_000_000_000:
            ts /= 1000.0
        try:
            return datetime.fromtimestamp(ts, tz=timezone.utc).date()
        except Exception:
            return None

    text = str(value).strip()
    if not text:
        return None

    # Firestore Timestamp string from some clients:
    # "Timestamp(seconds=1714521600, nanoseconds=0)"
    ts_match = re.search(r"seconds\s*=\s*(\d+)", text)
    if ts_match:
        try:
            ts = int(ts_match.group(1))
            return datetime.fromtimestamp(ts, tz=timezone.utc).date()
        except Exception:
            pass

    # Common normalized formats: YYYY-MM-DD or full ISO datetime.
    iso_candidate = text.replace("Z", "+00:00")
    try:
        return datetime.fromisoformat(iso_candidate).date()
    except Exception:
        pass
    try:
        return date.fromisoformat(iso_candidate[:10])
    except Exception:
        pass

    # Fallback regex captures common date forms.
    ymd = re.search(r"(\d{4})[-/](\d{1,2})[-/](\d{1,2})", text)
    if ymd:
        try:
            y, m, d = map(int, ymd.groups())
            return date(y, m, d)
        except Exception:
            return None

    dmy = re.search(r"(\d{1,2})[-/](\d{1,2})[-/](\d{4})", text)
    if dmy:
        try:
            d, m, y = map(int, dmy.groups())
            return date(y, m, d)
        except Exception:
            return None

    return None


def _trip_window(req: GenerateRequest):
    start_raw = req.start_date or req.startDate
    end_raw = req.end_date or req.endDate

    start = _to_date(start_raw)
    end = _to_date(end_raw)

    if start is not None and end is not None and start > end:
        start, end = end, start
    return start, end


CITY_GUIDES: Dict[str, Dict[str, str]] = {
    "Riyadh": {
        "name": "Mohammed Atef",
        "experienceYears": "5",
        "languages": "Arabic - English",
        "phone": "0511111999",
        "rating": "4.4",
        "description": "Certified guide for Riyadh heritage districts, museums, and local cultural experiences.",
    },
    "Jeddah": {
        "name": "Lina Hassan",
        "experienceYears": "8",
        "languages": "Arabic - English",
        "phone": "0522222888",
        "rating": "4.8",
        "description": "Specializes in Historic Jeddah tours, art walks, and family-friendly cultural stops by the waterfront.",
    },
    "Mecca": {
        "name": "Abdulrahman Al Harbi",
        "experienceYears": "9",
        "languages": "Arabic - English - Urdu",
        "phone": "0533200441",
        "rating": "4.9",
        "description": "Experienced cultural guide for museums, exhibitions, and visitor-friendly landmarks in Makkah.",
    },
    "Medina": {
        "name": "Sara Al Zahrani",
        "experienceYears": "6",
        "languages": "Arabic - English",
        "phone": "0541188332",
        "rating": "4.7",
        "description": "Focuses on Madinah history, museums, and calm family cultural experiences.",
    },
    "Dammam": {
        "name": "Yousef Al Qahtani",
        "experienceYears": "7",
        "languages": "Arabic - English",
        "phone": "0551177334",
        "rating": "4.6",
        "description": "Guides visitors through Eastern Province heritage spots, corniche culture, and local family attractions.",
    },
    "Khobar": {
        "name": "Norah Al Dosari",
        "experienceYears": "6",
        "languages": "Arabic - English",
        "phone": "0561144221",
        "rating": "4.7",
        "description": "Curates relaxed cultural walks across Khobar waterfronts, galleries, and family-friendly districts.",
    },
    "Abha": {
        "name": "Aisha Asiri",
        "experienceYears": "8",
        "languages": "Arabic - English",
        "phone": "0504411882",
        "rating": "4.9",
        "description": "Mountain culture expert for heritage villages, art districts, and scenic experiences in Abha.",
    },
    "Taif": {
        "name": "Faisal Al Thaqafi",
        "experienceYears": "7",
        "languages": "Arabic - English",
        "phone": "0509933772",
        "rating": "4.8",
        "description": "Known for Taif rose routes, heritage markets, and scenic cultural itineraries for families.",
    },
    "Jazan": {
        "name": "Huda Al Hakami",
        "experienceYears": "6",
        "languages": "Arabic - English",
        "phone": "0537711008",
        "rating": "4.6",
        "description": "Designs cultural programs around Jazan heritage, local crafts, coastal life, and family-oriented stops.",
    },
}


def _safe_id(value: Any, fallback: str) -> str:
    text = str(value).strip() if value is not None else ""
    return text or fallback


def _dedupe_accommodations(accommodations: List[Accommodation]) -> List[Accommodation]:
    seen = set()
    unique = []
    for accommodation in accommodations:
        key = _safe_id(
            getattr(accommodation, "accommodationId", None)
            or getattr(accommodation, "hotelId", None)
            or getattr(accommodation, "id", None)
            or getattr(accommodation, "name", None),
            "hotel",
        )
        if key in seen:
            continue
        seen.add(key)
        unique.append(accommodation)
    return unique


def _plan_reasons(kind: str, req: GenerateRequest, events_count: int) -> List[str]:
    reasons = []
    if kind == "cultural":
        reasons.append("Prioritizes museums, heritage districts, and local culture.")
    elif kind == "adventure":
        reasons.append("Prioritizes active attractions and outdoor experiences.")
    else:
        reasons.append("Balanced pacing for families with a more relaxed rhythm.")

    if req.budget > 0:
        reasons.append("Keeps the plan aligned with the selected budget.")

    if req.days >= 5:
        reasons.append("Spreads activities across multiple days to reduce rush.")
    else:
        reasons.append("Concentrates the highest-value stops into a shorter trip.")

    if events_count > 0:
        reasons.append("Includes events available during the selected travel dates.")

    return reasons


def _hotel_reasons(accommodation, budget: float, days: int, kind: str, rank_index: int) -> List[str]:
    reasons = []
    price_per_night = _robust_accommodation_price_per_night(accommodation) or 0.0
    total_cost = price_per_night * max(days, 1)
    rating = _safe_float(getattr(accommodation, "rating", None), 0.0)
    plan_type = str(getattr(accommodation, "planType", "") or "").lower()

    if rank_index == 0:
        reasons.append("Best overall match for this plan.")
    elif rank_index == 1:
        reasons.append("Strong alternative with a balanced score.")
    else:
        reasons.append("Useful backup option with a different cost and location profile.")

    if total_cost and budget and total_cost <= budget * 0.35:
        reasons.append("Better fit for the budget.")
    elif total_cost and budget and total_cost <= budget * 0.55:
        reasons.append("Balanced price for the available budget.")
    elif total_cost and budget:
        reasons.append("Higher-cost option with stronger stay quality.")

    if rating >= 4.6:
        reasons.append("High guest rating.")
    elif rating >= 4.3:
        reasons.append("Solid guest rating.")

    if kind and kind in plan_type:
        reasons.append("Matches the style of this plan.")

    return reasons


def _build_schedule(activities_payload: List[Dict[str, Any]], days: int) -> List[Dict[str, Any]]:
    schedule = []
    total = len(activities_payload)
    for d in range(1, days + 1):
        if total == 0:
            morning = []
            afternoon = []
            evening = []
        else:
            morning = [activities_payload[(d - 1) % total]]
            afternoon = [activities_payload[d % total]] if total > 1 else []
            evening = [activities_payload[(d + 1) % total]] if total > 2 else []
        schedule.append(
            {
                "label": f"Day {d}:",
                "morning": morning,
                "afternoon": afternoon,
                "evening": evening,
            }
        )
    return schedule


def _city_tour_guide(city: str, kind: str):
    if kind != "cultural":
        return None
    return CITY_GUIDES.get(city.strip()) or CITY_GUIDES["Riyadh"]

@app.post("/generate-plans")
def generate_plans(req: GenerateRequest):
    """
    Takes in available catalog and generates EXACTLY 3 plans based on budget.
    Automatically assigns activities to 'nearby' or 'distant' via Lat/Lng.
    """
    start_time = time.perf_counter()
    
    # Filter hotels within budget (cost = pricePerNight * days).
    # If budget is tight, we pick the cheapest. If generous, pick highest rated.
    valid_accommodations = []
    for h in req.accommodations:
        price_per_night = _robust_accommodation_price_per_night(h)
        if price_per_night is None:
            continue
        if price_per_night * req.days <= req.budget:
            valid_accommodations.append(h)
    if len(valid_accommodations) < 3 and req.accommodations:
        existing_ids = {
            _safe_id(
                getattr(accommodation, "accommodationId", None)
                or getattr(accommodation, "hotelId", None)
                or getattr(accommodation, "id", None)
                or getattr(accommodation, "name", None),
                "hotel",
            )
            for accommodation in valid_accommodations
        }
        supplemental = []
        for accommodation in req.accommodations:
            accommodation_id = _safe_id(
                getattr(accommodation, "accommodationId", None)
                or getattr(accommodation, "hotelId", None)
                or getattr(accommodation, "id", None)
                or getattr(accommodation, "name", None),
                "hotel",
            )
            if accommodation_id in existing_ids:
                continue
            supplemental.append(accommodation)
            existing_ids.add(accommodation_id)
            if len(valid_accommodations) + len(supplemental) >= 3:
                break
        valid_accommodations.extend(supplemental)
    if not valid_accommodations:
        valid_accommodations = req.accommodations if req.accommodations else []

    plan_types = [
        {"kind": "cultural", "title": "Cultural Plan."},
        {"kind": "adventure", "title": "Adventure Plan."},
        {"kind": "family", "title": "Family Relax Plan."}
    ]
    
    generated_plans = []
    user_profile = build_user_profile(req.familyAges, req.budget, req.days)

    trip_start, trip_end = _trip_window(req)
    filtered_events = []
    if req.events:
        for event in req.events:
            event_date = _to_date(getattr(event, "date", None))
            if trip_start is not None and trip_end is not None:
                if event_date is None:
                    continue
                if not (trip_start <= event_date <= trip_end):
                    continue
            filtered_events.append(event)
    events_payload = [_to_payload(event) for event in filtered_events[:6]]

    ranked_activity_pool = []
    if req.activities:
        activity_pool = req.activities
        if len(activity_pool) > 200:
            activity_pool = sorted(
                activity_pool,
                key=lambda activity: _safe_float(activity.rating),
                reverse=True,
            )[:200]
        ranked_activity_pool = activity_pool

    for p_type in plan_types:
        unique_accommodations = _dedupe_accommodations(valid_accommodations)
        ranked_accommodations = []
        if unique_accommodations:
            ranked_accommodations = rank_accommodations_ml(
                unique_accommodations,
                user_profile,
                req.budget,
                req.days,
                p_type["kind"],
            )
        ranked_accommodations = _dedupe_accommodations(
            ranked_accommodations or unique_accommodations
        )
        top_accommodations = ranked_accommodations[:3]
        if not top_accommodations and req.accommodations:
            top_accommodations = _dedupe_accommodations(req.accommodations)[:3]

        ranked_activities = []
        if ranked_activity_pool:
            ranked_activities = rank_activities_dl(
                ranked_activity_pool,
                user_profile,
                p_type["kind"],
            )

        hotel_options = []
        for hotel_index, accommodation in enumerate(top_accommodations):
            price_per_night = _robust_accommodation_price_per_night(accommodation)
            total_accommodation_cost = price_per_night * req.days if price_per_night else 0.0

            nearby, distant = split_nearby_distant(accommodation, ranked_activities)
            nearby_payload = nearby[:5]
            distant_payload = distant[:5]
            schedule_pool = (nearby[:6] + distant[:6])[:9]
            schedule = _build_schedule(schedule_pool, req.days)

            hotel_options.append(
                {
                    "hotelIndex": hotel_index,
                    "hotelReasons": _hotel_reasons(
                        accommodation,
                        req.budget,
                        req.days,
                        p_type["kind"],
                        hotel_index,
                    ),
                    "accommodation": _to_payload(accommodation),
                    "hotel": _to_payload(accommodation),
                    "totalCost": float(total_accommodation_cost or 0.0),
                    "nearby": nearby_payload,
                    "distant": distant_payload,
                    "schedule": schedule,
                    "itinerary": schedule,
                }
            )

        primary_option = hotel_options[0] if hotel_options else None
        primary_total_cost = float(primary_option["totalCost"]) if primary_option else 0.0

        generated_plans.append(
            {
                **(
                    {
                        "budget_status": "low",
                        "budgetStatus": "low",
                        "minimum_required": float(primary_total_cost),
                        "minimumRequired": float(primary_total_cost),
                    }
                    if req.budget < primary_total_cost
                    else {}
                ),
                "kind": p_type["kind"],
                "title": p_type["title"],
                "selectionReasons": _plan_reasons(
                    p_type["kind"],
                    req,
                    len(events_payload),
                ),
                "tourGuide": _city_tour_guide(req.city, p_type["kind"]),
                "selectedHotelIndex": 0,
                "hotelOptions": hotel_options,
                "accommodation": primary_option["accommodation"] if primary_option else None,
                "hotel": primary_option["hotel"] if primary_option else None,
                "totalCost": primary_total_cost,
                "nearby": primary_option["nearby"] if primary_option else [],
                "distant": primary_option["distant"] if primary_option else [],
                "schedule": primary_option["schedule"] if primary_option else _build_schedule([], req.days),
                "itinerary": primary_option["itinerary"] if primary_option else _build_schedule([], req.days),
                "events": events_payload,
            }
        )

    elapsed = (time.perf_counter() - start_time) * 1000
    return {
        "generatedPlans": generated_plans,
        "aiElapsedMs": round(elapsed, 2),
    }

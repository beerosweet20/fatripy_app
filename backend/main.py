from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional, Union
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
    if not valid_accommodations:
        # Fallback if no hotel matches budget: just take the top one
        valid_accommodations = req.accommodations if req.accommodations else []

    plan_types = [
        {"kind": "cultural", "title": "Cultural Plan."},
        {"kind": "adventure", "title": "Adventure Plan."},
        {"kind": "family", "title": "Family Relax Plan."}
    ]
    
    generated_plans = []
    user_profile = build_user_profile(req.familyAges, req.budget, req.days)

    for idx, p_type in enumerate(plan_types):
        # Pick an accommodation (cycle through if multiple, or just take first)
        if valid_accommodations:
            ranked_accommodations = rank_accommodations_ml(
                valid_accommodations, user_profile, req.budget, req.days, p_type["kind"]
            )
            accommodation = ranked_accommodations[0] if ranked_accommodations else valid_accommodations[0]
        else:
            accommodation = None

        price_per_night = _robust_accommodation_price_per_night(accommodation) if accommodation else None
        total_accommodation_cost = (
            price_per_night * req.days if price_per_night else 0.0
        )

        nearby = []
        distant = []

        if req.activities:
            # Performance guard: keep activity set manageable
            activity_pool = req.activities
            if len(activity_pool) > 200:
                activity_pool = sorted(
                    activity_pool,
                    key=lambda a: _safe_float(a.rating),
                    reverse=True,
                )[:200]

            ranked_activities = rank_activities_dl(
                activity_pool, user_profile, p_type["kind"]
            )
            # If accommodation is missing, split_nearby_distant falls back to
            # an order-based split (top half nearby, rest distant).
            nearby, distant = split_nearby_distant(accommodation, ranked_activities)
        
        # Build Day By Day Schedule Mocks for testing (Distributing nearby/distant)
        schedule = []
        act_pool = nearby + distant
        for d in range(1, req.days + 1):
            morning = [act_pool[d % len(act_pool)]] if act_pool else []
            afternoon = [act_pool[(d+1) % len(act_pool)]] if len(act_pool) > 1 else []
            evening = [act_pool[(d+2) % len(act_pool)]] if len(act_pool) > 2 else []
            
            schedule.append({
                "label": f"Day {d}:",
                "morning": morning,
                "afternoon": afternoon,
                "evening": evening
            })

        events_payload = []
        if req.events:
            trip_start, trip_end = _trip_window(req)
            filtered_events = []
            for e in req.events:
                event_date = _to_date(getattr(e, "date", None))
                if trip_start is not None and trip_end is not None:
                    # Include only events that are inside trip date range
                    # (inclusive): start <= event_date <= end.
                    if event_date is None:
                        continue
                    if not (trip_start <= event_date <= trip_end):
                        continue
                filtered_events.append(e)

            # Keep top 3 events after date filtering.
            events_payload = [_to_payload(e) for e in filtered_events[:3]]

        total_estimated_cost = float(total_accommodation_cost or 0.0)

        generated_plans.append({
            **(
                {
                    "budget_status": "low",
                    "budgetStatus": "low",
                    "minimum_required": float(total_estimated_cost),
                    "minimumRequired": float(total_estimated_cost),
                }
                if req.budget < total_estimated_cost
                else {}
            ),
            "kind": p_type["kind"],
            "title": p_type["title"],
            # Keep both keys for backward compatibility with existing parsers.
            "accommodation": _to_payload(accommodation),
            "hotel": _to_payload(accommodation),
            "totalCost": float(total_accommodation_cost or 0.0),
            "nearby": nearby[:3], # Limit to 3 visual items
            "distant": distant[:3], 
            "schedule": schedule,
            "itinerary": schedule,
            "events": events_payload,
        })

    elapsed = (time.perf_counter() - start_time) * 1000
    return {
        "generatedPlans": generated_plans,
        "aiElapsedMs": round(elapsed, 2),
    }

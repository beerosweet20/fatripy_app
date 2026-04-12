import json
import math
import os
from typing import Any, Dict, List, Tuple


def _safe_float(value, default=None):
    try:
        if value is None:
            return default
        return float(value)
    except Exception:
        return default


def _parse_price(value):
    if value is None:
        return None
    if isinstance(value, (int, float)):
        return float(value)
    text = str(value).strip().lower()
    if "free" in text:
        return 0.0
    # handle range like "40-80"
    parts = (
        text.replace("sar", "")
        .replace("sr", "")
        .replace("ريال", "")
        .replace(",", " ")
    )
    nums = []
    for token in parts.replace("-", " ").split():
        try:
            nums.append(float(token))
        except Exception:
            pass
    if not nums:
        return None
    if len(nums) == 1:
        return nums[0]
    return sum(nums[:2]) / 2.0


def build_user_profile(family_ages: List[str], budget: float, days: int) -> Dict[str, Any]:
    adults = sum(1 for a in family_ages if str(a).lower().startswith("adult"))
    children = sum(1 for a in family_ages if str(a).lower().startswith("child"))
    infants = sum(1 for a in family_ages if str(a).lower().startswith("infant"))
    return {
        "adults": adults,
        "children": children,
        "infants": infants,
        "budget": budget,
        "days": days,
    }


def accommodation_price_per_night(accommodation):
    if accommodation is None:
        return None
    p = _safe_float(getattr(accommodation, "pricePerNight", None))
    if p is not None:
        return p
    pmin = _safe_float(getattr(accommodation, "priceMin", None))
    pmax = _safe_float(getattr(accommodation, "priceMax", None))
    if pmin is not None and pmax is not None:
        return (pmin + pmax) / 2.0
    if pmin is not None:
        return pmin
    if pmax is not None:
        return pmax
    return None


def _normalize(value, min_v, max_v):
    if value is None:
        return 0.0
    if max_v == min_v:
        return 0.0
    return max(0.0, min(1.0, (value - min_v) / (max_v - min_v)))


def _plan_match(plan_type: str, desired: str) -> float:
    if not plan_type:
        return 0.2
    p = str(plan_type).lower().strip()
    d = str(desired).lower().strip()
    if d in p:
        return 1.0
    return 0.4


def rank_accommodations_ml(accommodations, profile, budget, days, desired_kind):
    # Simple ML-like scoring (weighted features)
    scores = []
    for h in accommodations:
        rating = _safe_float(getattr(h, "rating", None), 0.0)
        price = accommodation_price_per_night(h) or 0.0
        total = price * days

        rating_n = _normalize(rating, 0.0, 5.0)
        price_afford = 1.0 if total <= budget else max(0.0, 1.0 - (total - budget) / budget)
        plan_match = _plan_match(getattr(h, "planType", None), desired_kind)
        family_weight = 1.0 + 0.05 * profile["children"]

        score = (
            0.45 * rating_n
            + 0.35 * price_afford
            + 0.15 * plan_match
            + 0.05 * family_weight
        )
        scores.append((score, h))

    if not scores:
        return []

    # Reliability fallback: if all scores equal, fallback to rating desc
    min_s = min(s for s, _ in scores)
    max_s = max(s for s, _ in scores)
    if max_s - min_s < 1e-6:
        return sorted(
            accommodations,
            key=lambda h: _safe_float(getattr(h, "rating", None), 0.0),
            reverse=True,
        )

    scores.sort(key=lambda x: x[0], reverse=True)
    return [h for _, h in scores]


def _relu(x):
    return max(0.0, x)


def _mlp_forward(x, w1, b1, w2, b2):
    # x: list[float]
    h = [0.0] * len(b1)
    for i in range(len(b1)):
        s = b1[i]
        for j in range(len(x)):
            s += x[j] * w1[i][j]
        h[i] = _relu(s)
    out = b2
    for i in range(len(h)):
        out += h[i] * w2[i]
    return out


_BASE_W1 = [
    [0.12, 0.08, 0.05, 0.20, 0.15, 0.10],
    [0.05, 0.12, 0.15, 0.10, 0.20, 0.08],
    [0.18, 0.04, 0.06, 0.12, 0.10, 0.14],
]
_BASE_B1 = [0.1, 0.05, 0.08]
_BASE_W2 = [0.35, 0.40, 0.25]
_BASE_B2 = 0.0

_WEIGHTS_FILE = os.path.join(os.path.dirname(__file__), "model_weights.json")
_HISTORY_FILE = os.path.join(
    os.path.dirname(__file__), "historical_preferences.json"
)


def _copy_matrix(matrix):
    return [row[:] for row in matrix]


def _safe_read_json(path):
    try:
        with open(path, "r", encoding="utf-8") as file:
            return json.load(file)
    except Exception:
        return None


def _coerce_vector(raw, expected_len, fallback):
    if not isinstance(raw, list) or len(raw) != expected_len:
        return fallback[:]
    out = []
    for value in raw:
        parsed = _safe_float(value)
        if parsed is None:
            return fallback[:]
        out.append(parsed)
    return out


def _coerce_matrix(raw, rows, cols, fallback):
    if not isinstance(raw, list) or len(raw) != rows:
        return _copy_matrix(fallback)
    out = []
    for i in range(rows):
        row = _coerce_vector(raw[i], cols, fallback[i])
        out.append(row)
    return out


def _extract_logs(history_payload):
    if history_payload is None:
        return []
    if isinstance(history_payload, list):
        return history_payload
    if isinstance(history_payload, dict):
        logs = history_payload.get("logs")
        if isinstance(logs, list):
            return logs
    return []


def _label_from_log(log):
    for key in ("booked", "is_booked", "isBooked", "success", "label"):
        if key in log:
            return 1.0 if bool(log.get(key)) else 0.0
    return 0.0


def _feature_vector_from_log(log):
    raw_features = log.get("features")
    if isinstance(raw_features, list) and raw_features:
        parsed = []
        for value in raw_features[:6]:
            parsed.append(_safe_float(value, 0.0))
        while len(parsed) < 6:
            parsed.append(1.0 if len(parsed) == 5 else 0.0)
        parsed[0] = max(0.0, min(1.0, parsed[0]))
        parsed[1] = max(0.0, min(1.0, parsed[1]))
        parsed[2] = max(0.0, min(1.0, parsed[2]))
        parsed[3] = max(0.0, min(1.0, parsed[3]))
        parsed[4] = max(0.0, min(1.0, parsed[4]))
        parsed[5] = 1.0
        return parsed

    rating = _safe_float(log.get("rating"), 0.0)
    price = _parse_price(log.get("price"))
    price_n = _safe_float(log.get("price_n"))
    if price_n is None:
        budget_per_day = _safe_float(log.get("budget_per_day"), 150.0) or 150.0
        if price is None:
            price_n = 0.5
        else:
            price_n = 1.0 - _normalize(price, 0.0, max(1.0, budget_per_day))
    adults = (_safe_float(log.get("adults"), 2.0) or 2.0) / 6.0
    kids = (_safe_float(log.get("children"), 0.0) or 0.0) / 6.0
    infants = (_safe_float(log.get("infants"), 0.0) or 0.0) / 6.0
    rating_n = _normalize(rating, 0.0, 5.0)
    return [
        max(0.0, min(1.0, rating_n)),
        max(0.0, min(1.0, price_n)),
        max(0.0, min(1.0, adults)),
        max(0.0, min(1.0, kids)),
        max(0.0, min(1.0, infants)),
        1.0,
    ]


def _apply_historical_bias(w1, b1, w2, b2, history_payload):
    logs = _extract_logs(history_payload)
    if not logs:
        return w1, b1, w2, b2

    successful_features = []
    labels = []
    for log in logs:
        if not isinstance(log, dict):
            continue
        label = _label_from_log(log)
        labels.append(label)
        if label >= 0.5:
            successful_features.append(_feature_vector_from_log(log))

    if len(successful_features) < 8:
        return w1, b1, w2, b2

    feature_count = len(successful_features[0])
    avg_success = [0.0] * feature_count
    for features in successful_features:
        for idx, value in enumerate(features):
            avg_success[idx] += value
    avg_success = [v / len(successful_features) for v in avg_success]
    conversion_rate = (sum(labels) / len(labels)) if labels else 0.0

    blend = min(0.35, 0.10 + (len(successful_features) / 2500.0))
    reference = [
        [0.42, 0.24, 0.11, 0.28, 0.18],
        [0.24, 0.39, 0.13, 0.18, 0.14],
        [0.30, 0.20, 0.20, 0.24, 0.18],
    ]
    for i in range(len(w1)):
        for j in range(5):
            target = reference[i][j] * (0.7 + avg_success[j])
            w1[i][j] = (1.0 - blend) * w1[i][j] + blend * target
        w1[i][5] = (1.0 - blend) * w1[i][5] + blend * 0.08

    b1_shift = 0.03 * ((avg_success[0] + avg_success[3]) - 0.9)
    b1 = [bias + blend * b1_shift for bias in b1]

    w2[0] += blend * 0.12 * (avg_success[0] - 0.5)
    w2[1] += blend * 0.10 * (avg_success[1] - 0.5)
    w2[2] += blend * 0.10 * (avg_success[3] - 0.2)
    b2 += blend * 0.08 * (conversion_rate - 0.5)

    return w1, b1, w2, b2


def _load_dynamic_weights():
    w1 = _copy_matrix(_BASE_W1)
    b1 = _BASE_B1[:]
    w2 = _BASE_W2[:]
    b2 = _BASE_B2

    model_payload = _safe_read_json(_WEIGHTS_FILE)
    if isinstance(model_payload, dict):
        w1 = _coerce_matrix(model_payload.get("W1"), 3, 6, w1)
        b1 = _coerce_vector(model_payload.get("B1"), 3, b1)
        w2 = _coerce_vector(model_payload.get("W2"), 3, w2)
        parsed_b2 = _safe_float(model_payload.get("B2"))
        if parsed_b2 is not None:
            b2 = parsed_b2

    history_payload = _safe_read_json(_HISTORY_FILE)
    if history_payload is not None:
        w1, b1, w2, b2 = _apply_historical_bias(w1, b1, w2, b2, history_payload)

    return w1, b1, w2, b2


_W1, _B1, _W2, _B2 = _load_dynamic_weights()


def _activity_features(activity, profile):
    price = _parse_price(getattr(activity, "price", None)) or 0.0
    rating = _safe_float(getattr(activity, "rating", None), 0.0)
    # Normalize
    price_n = 1.0 - _normalize(price, 0.0, max(1.0, profile["budget"] / max(1, profile["days"])))
    rating_n = _normalize(rating, 0.0, 5.0)
    kids = profile["children"]
    infants = profile["infants"]
    adults = profile["adults"]
    return [rating_n, price_n, adults / 6.0, kids / 6.0, infants / 6.0, 1.0]


def rank_activities_dl(activities, profile, desired_kind):
    scored = []
    for a in activities:
        features = _activity_features(a, profile)
        score = _mlp_forward(features, _W1, _B1, _W2, _B2)
        # small boost for family plan
        if desired_kind == "family":
            score += 0.05 * profile["children"]
        scored.append((score, a))
    if not scored:
        return []
    min_s = min(s for s, _ in scored)
    max_s = max(s for s, _ in scored)
    if max_s - min_s < 1e-6:
        return sorted(
            activities,
            key=lambda a: _safe_float(getattr(a, "rating", None), 0.0),
            reverse=True,
        )

    scored.sort(key=lambda x: x[0], reverse=True)
    return [a for _, a in scored]


def _haversine(lat1, lon1, lat2, lon2):
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(
        math.radians(lat2)
    ) * math.sin(dlon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c


def split_nearby_distant(accommodation, activities) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    nearby = []
    distant = []
    hlat = getattr(accommodation, "lat", None)
    hlng = getattr(accommodation, "lng", None)

    # If coordinates exist, use distance. Otherwise split by score/order.
    if hlat is not None and hlng is not None:
        for act in activities:
            alat = getattr(act, "lat", None)
            alng = getattr(act, "lng", None)
            if alat is None or alng is None:
                distant.append(act.dict())
                continue
            dist = _haversine(hlat, hlng, alat, alng)
            act_dict = act.dict()
            act_dict["distance_km"] = round(dist, 2)
            if dist <= 15.0:
                nearby.append(act_dict)
            else:
                distant.append(act_dict)
        if not distant and len(nearby) > 4:
            nearby.sort(key=lambda item: item.get("distance_km", 0.0), reverse=True)
            promote_count = min(3, max(1, len(nearby) // 3))
            distant = nearby[:promote_count]
            nearby = nearby[promote_count:]
            nearby.sort(key=lambda item: item.get("distance_km", 0.0))
            distant.sort(key=lambda item: item.get("distance_km", 0.0))
        return nearby, distant

    # Fallback: top half nearby, rest distant
    for i, act in enumerate(activities):
        act_dict = act.dict()
        if i < max(1, len(activities) // 2):
            nearby.append(act_dict)
        else:
            distant.append(act_dict)
    return nearby, distant

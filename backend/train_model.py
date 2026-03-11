import json
import math
import os
import random
from datetime import datetime, timezone

WEIGHTS_FILE = os.path.join(os.path.dirname(__file__), "model_weights.json")
HISTORY_FILE = os.path.join(os.path.dirname(__file__), "historical_preferences.json")


def _clamp01(value):
    return max(0.0, min(1.0, float(value)))


def _sigmoid(x):
    if x < -40:
        return 0.0
    if x > 40:
        return 1.0
    return 1.0 / (1.0 + math.exp(-x))


def _relu(x):
    return x if x > 0 else 0.0


def _normalize_record(record):
    if not isinstance(record, dict):
        return None

    raw_features = record.get("features")
    if isinstance(raw_features, list) and raw_features:
        features = [_clamp01(raw_features[i]) if i < len(raw_features) else 0.0 for i in range(5)]
    else:
        rating = float(record.get("rating", 0.0))
        rating_n = _clamp01(rating / 5.0)
        price_n = record.get("price_n")
        if price_n is None:
            budget_per_day = float(record.get("budget_per_day", 150.0))
            price = float(record.get("price", budget_per_day * 0.5))
            price_n = 1.0 - _clamp01(price / max(1.0, budget_per_day))
        adults = _clamp01(float(record.get("adults", 2.0)) / 6.0)
        children = _clamp01(float(record.get("children", 0.0)) / 6.0)
        infants = _clamp01(float(record.get("infants", 0.0)) / 6.0)
        features = [_clamp01(rating_n), _clamp01(price_n), adults, children, infants]

    label = record.get("booked")
    if label is None:
        label = record.get("success")
    if label is None:
        label = record.get("isBooked")
    label = 1.0 if bool(label) else 0.0

    return {"features": features + [1.0], "booked": label}


def generate_simulated_user_data(num_samples=900):
    data = []
    for _ in range(num_samples):
        rating_n = random.uniform(0.25, 1.0)
        price_n = random.uniform(0.15, 1.0)
        adults = random.randint(1, 4) / 6.0
        kids = random.randint(0, 4) / 6.0
        infants = random.randint(0, 2) / 6.0
        noise = random.uniform(-0.18, 0.18)
        score = (0.50 * rating_n) + (0.30 * price_n) + (0.20 * kids) + (0.08 * adults) - (0.05 * infants) + noise
        booked = 1.0 if score > 0.58 else 0.0
        data.append({
            "features": [rating_n, price_n, adults, kids, infants, 1.0],
            "booked": booked,
        })
    return data


def load_or_build_historical_data():
    if os.path.exists(HISTORY_FILE):
        try:
            with open(HISTORY_FILE, "r", encoding="utf-8") as file:
                payload = json.load(file)
            logs = payload if isinstance(payload, list) else payload.get("logs", [])
            normalized = [_normalize_record(log) for log in logs]
            normalized = [record for record in normalized if record is not None]
            if normalized:
                return normalized, "historical_preferences.json"
        except Exception as exc:
            print(f"Warning: could not parse historical data ({exc}). Falling back to simulated logs.")

    simulated = generate_simulated_user_data()
    payload = {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "source": "simulated",
        "logs": simulated,
    }
    with open(HISTORY_FILE, "w", encoding="utf-8") as file:
        json.dump(payload, file, indent=2)
    return simulated, "simulated"


def train_neural_network(data, epochs=140, lr=0.06):
    random.seed(42)
    print(f"Training model on {len(data)} booking interaction logs...")

    w1 = [[random.uniform(-0.10, 0.24) for _ in range(6)] for _ in range(3)]
    b1 = [random.uniform(-0.04, 0.12) for _ in range(3)]
    w2 = [random.uniform(0.10, 0.40) for _ in range(3)]
    b2 = random.uniform(-0.05, 0.08)

    losses = []
    for epoch in range(1, epochs + 1):
        random.shuffle(data)
        total_loss = 0.0

        for sample in data:
            x = sample["features"]
            y = float(sample["booked"])

            hidden_pre = []
            hidden = []
            for i in range(3):
                z = b1[i] + sum(x[j] * w1[i][j] for j in range(6))
                hidden_pre.append(z)
                hidden.append(_relu(z))

            logit = b2 + sum(hidden[i] * w2[i] for i in range(3))
            pred = _sigmoid(logit)

            loss = -(y * math.log(max(pred, 1e-8)) + (1.0 - y) * math.log(max(1.0 - pred, 1e-8)))
            total_loss += loss

            dlogit = pred - y
            grad_w2 = [dlogit * hidden[i] for i in range(3)]
            grad_b2 = dlogit

            grad_hidden = [dlogit * w2[i] for i in range(3)]
            grad_hidden_pre = [grad_hidden[i] if hidden_pre[i] > 0.0 else 0.0 for i in range(3)]

            grad_w1 = []
            for i in range(3):
                grad_w1.append([grad_hidden_pre[i] * x[j] for j in range(6)])
            grad_b1 = grad_hidden_pre

            for i in range(3):
                w2[i] -= lr * grad_w2[i]
            b2 -= lr * grad_b2

            for i in range(3):
                for j in range(6):
                    w1[i][j] -= lr * grad_w1[i][j]
                b1[i] -= lr * grad_b1[i]

        epoch_loss = total_loss / max(1, len(data))
        losses.append(epoch_loss)
        if epoch % 20 == 0 or epoch == 1:
            print(f"Epoch {epoch}/{epochs} - loss: {epoch_loss:.4f}")

    correct = 0
    for sample in data:
        x = sample["features"]
        y = sample["booked"]
        hidden = [_relu(b1[i] + sum(x[j] * w1[i][j] for j in range(6))) for i in range(3)]
        pred = _sigmoid(b2 + sum(hidden[i] * w2[i] for i in range(3)))
        predicted_label = 1.0 if pred >= 0.5 else 0.0
        if predicted_label == y:
            correct += 1
    accuracy = correct / max(1, len(data))

    learned_weights = {
        "W1": [[round(value, 6) for value in row] for row in w1],
        "B1": [round(value, 6) for value in b1],
        "W2": [round(value, 6) for value in w2],
        "B2": round(b2, 6),
        "metadata": {
            "model": "Fatripy_Recommender_DNN_v2",
            "samples_trained": len(data),
            "epochs": epochs,
            "learning_rate": lr,
            "final_loss": round(losses[-1], 6) if losses else None,
            "accuracy": round(accuracy, 4),
            "trainedAt": datetime.now(timezone.utc).isoformat(),
        },
    }
    return learned_weights


def main():
    print("Initializing Deep Learning Personalization Pipeline...")
    historical_data, source = load_or_build_historical_data()
    model = train_neural_network(historical_data)
    model["metadata"]["training_source"] = source

    with open(WEIGHTS_FILE, "w", encoding="utf-8") as file:
        json.dump(model, file, indent=2)

    print(f"\nTraining complete. Weights saved to: {WEIGHTS_FILE}")
    print(f"Historical logs source: {source}")
    print(f"Training accuracy: {round(model['metadata']['accuracy'] * 100, 2)}%")


if __name__ == "__main__":
    main()

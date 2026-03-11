# Fatripy

Intelligent mobile tourism application for family trip planning in Saudi Arabia (graduation project).

## Overview
Fatripy is a Flutter mobile app connected to Firebase (Auth + Firestore) with a Python FastAPI recommendation service.
The app collects family trip inputs, generates 3 plan options, lets users review/select one, and records booking actions.

## Problem Statement
Family trip planning is time-consuming when balancing:
- family composition and age groups
- budget constraints
- destination/activity/hotel choices
- daily itinerary structure

This project aims to reduce planning effort by generating ready-to-review alternatives.

## Current Features (Implemented)
- Email/password authentication with Firebase Auth:
  - login, register, logout
  - password reset dialog
- User profile in Firestore (`users` collection)
- Family/trip input form:
  - adults/children/infants counts
  - age lists
  - budget, city, duration, start/end date
- Trip plan generation:
  - Calls FastAPI `/generate-plans`
  - Returns and stores exactly 3 generated plans per trip
  - Stores `aiElapsedMs` timing in each `tripPlans` document
- Plans UI:
  - main plans screen with custom visual design
  - dedicated plan comparison screen (`/plans/compare`)
  - selected plan persistence (`selected`, `selectedPlanIndex`, `selectedPlanTitle`, `selectedAt`)
- Plan details:
  - hotel info
  - day-by-day schedule (morning/afternoon/evening)
  - nearby vs distant attractions
  - event section
  - map deep links (`url_launcher`)
- Booking flow (without in-app payment):
  - opens external booking/maps links
  - stores booking record in Firestore (`bookings`)
  - success/receipt screens
- Admin screens:
  - dashboard with counts
  - manage Hotels/Activities CRUD UI
- Localization:
  - Arabic + English ARB setup
  - most auth/profile/plans/admin/booking/settings/help/privacy strings localized

## Partially Implemented / Incomplete
- Plan comparison entry point:
  - route exists (`/plans/compare`) but no clear CTA wired from plans screen.
- AI latency requirement behavior:
  - app currently blocks saving plans when `aiElapsedMs > 3000` instead of warning-only behavior.
- Admin authorization:
  - UI checks Firestore `role` or token claim, but Firestore rules require custom claim `admin=true` for writes.
  - seeded admin logic in client is not a reliable production admin setup.
- Localization coverage:
  - blog screen remains hardcoded English content.
  - some defaults/city values in dependents screen are hardcoded English.
- Booking record quality:
  - `itemTitle` and `bookingReference` are not consistently populated.
  - fallback flows can create bookings with `planId = mock_plan_id`.

## Planned / Future Features
- Full localization cleanup (remove remaining hardcoded strings)
- Robust admin provisioning via secure backend/Cloud Function custom claims
- Better booking lifecycle (pending/confirmed/cancelled + references)
- Real event management in admin panel
- Real notifications (FCM integration)
- Better recommendation quality with real historical dataset and validated models
- Plan editing/customization after generation

## Tech Stack
- Mobile: Flutter (Dart 3), Riverpod, GoRouter
- Backend recommendation API: Python, FastAPI, Pydantic
- Backend data: Firebase Auth + Cloud Firestore
- Integrations: Google Maps deep links (`url_launcher`)
- Local storage: `shared_preferences` (splash flag only)

## Architecture / Project Structure
Current codebase is a mixed layered + feature organization:
- `lib/domain/entities`: core entities (`TripPlan`, `Booking`, `UserProfile`)
- `lib/data/repositories`: Firestore repositories
- `lib/data/api`: API client for recommendation service
- `lib/presentation`: screens/router/theme/state/widgets
- `backend/`: FastAPI service + recommendation logic + seeding/export scripts

This is not strict Clean Architecture (business logic still appears in UI/stateful screens), but includes partial layering.

## Database Overview (Firestore)
Main collections used by app:
- `users`
  - profile fields (`fullName`, `username`, `email`, `role`, timestamps)
  - nested `family` map for dependents/trip preferences
- `tripPlans`
  - owner + trip input summary
  - generated plans payload (`generatedPlans`: list of maps)
  - selection metadata (`selected*`)
  - AI timing (`aiElapsedMs`)
- `bookings`
  - user booking actions linked to `planId`, `itemType`, `itemId`
- Catalog collections:
  - `Hotels` / `Activities` / `events`
  - lowercase compatibility also appears in code/rules (`hotels`, `activities`, `events`)

Observed legacy/exported collections (not part of current app flow): `plans`, `Guides`, `test`.

## Recommendation Logic Summary
Implemented logic is rule/scoring based with a lightweight NN scoring component:
- API endpoint: `POST /generate-plans`
- always produces 3 plan types: `cultural`, `adventure`, `family`
- hotel ranking: weighted scoring (`rating`, affordability, plan-type match)
- activity ranking: small MLP forward pass using stored weights (`model_weights.json`)
- nearby/distant split: Haversine distance from selected hotel
- schedule generation: cyclic assignment of ranked activities across days

Important: this is not a full production ML pipeline with real training data in the repository. Current bundled training source is simulated.

## Setup Instructions
### 1) Flutter app
```bash
flutter pub get
```

### 2) Python backend API
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 3) Firebase
- Ensure project config exists for your platform (Android file already included).
- Deploy/update Firestore rules when needed:
```bash
firebase deploy --only firestore:rules
```

### 4) Run app
```bash
flutter run
```

## Environment / Configuration Notes
- `PlanApiClient` base URL is fixed to Android emulator host:
  - `http://10.0.2.2:8000`
- For physical devices or other targets, update the base URL accordingly.
- Backend seeding/export scripts require Firebase Admin SDK credentials (service account).
- `backend/requirements.txt` currently covers API runtime only; admin scripts may need extra packages like `firebase-admin`.

## Current Limitations
- Recommendation API is local/manual (not deployed backend in repo).
- No in-app payment.
- No true notification pipeline.
- Some screens are placeholders (`favorites`, `cart`, `shop`, debug explorer).
- Blog content is static and not fully localized.
- No persistent settings storage for theme/language (state resets on app restart).
- Firestore query ordering/index strategy is incomplete (comments indicate index workarounds).

## Known Issues
- Windows desktop builds with Firestore may fail in this project state (Firebase C++ SDK extraction/linking errors reported).
- Admin CRUD can fail if user lacks Firebase custom claim `admin=true`, even if Firestore `role` says `admin`.
- Data quality inconsistencies in catalog docs (naming/typos/field variants) affect recommendation consistency.

## Security Notes
- Do not commit service-account private keys or hardcoded credentials in production repositories.
- The current repository contains sensitive configuration artifacts that must be rotated/secured before any public release.

## Future Improvements
- Unify collection naming (remove upper/lowercase dual paths)
- Add schema validation and migration strategy for catalog/trip documents
- Add integration tests for:
  - plan selection persistence
  - booking payload correctness
  - admin write permissions under real rules
- Move admin bootstrap and claims management to secure backend tooling
- Add proper environment configuration (`--dart-define` / `.env`) for API endpoints

## Repository Status (Honest Snapshot)
This codebase already demonstrates the core graduation-project flow (input -> 3 plans -> compare/select -> details -> booking record), but still has important production-readiness and consistency gaps. It is suitable as an academic prototype, not as a hardened production system.

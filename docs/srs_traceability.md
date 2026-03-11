# Fatripy SRS Traceability Matrix

This document maps the implemented scope against the graduation report requirements.

## Functional Requirements

| Functional Requirement | Status | Implementation Reference |
|---|---|---|
| User management (email login/logout/password recovery) | Implemented | `auth_service.dart`, `login_screen.dart`, `register_screen.dart`, `profile_screen.dart` |
| Family profile management (members + ages) | Implemented | `dependents_screen.dart`, Firestore `users/{uid}.family` |
| Trip preferences input (budget/duration/destination) | Implemented | `dependents_screen.dart` |
| Generate multiple plans (3 options) | Implemented | `backend/main.py` (`/generate-plans`), `plan_api_client.dart`, `dependents_screen.dart` |
| Plan comparison feature | Implemented | `plan_comparison_screen.dart`, route `/plans/compare` |
| Select one plan and persist selection | Implemented | `trip_repository.dart` (`markPlanSelection`), plans screens |
| Hotel recommendations with pricing | Implemented | `backend/main.py`, `plans_screen.dart`, `plan_detail_screen.dart` |
| Activity categorization (nearby/distant) | Implemented | `ai_recommender.py` (`split_nearby_distant`), plan screens |
| Daily schedule creation | Implemented | `backend/main.py` (`schedule` generation), `plan_detail_screen.dart` |
| Booking system (without in-app payment) | Implemented | `plan_detail_screen.dart`, `booking_repository.dart`, `bookings_screen.dart` |
| Booking confirmation messages | Implemented | `booking_success_screen.dart`, booking dialog/snackbars |
| Admin dashboard access control | Implemented | `auth_service.dart` (`isAdmin`), `app_router.dart`, `admin_dashboard.dart` |
| Admin content management (hotels/activities CRUD) | Implemented | `manage_content_screen.dart`, Firestore `Hotels`/`Activities` |
| AI-based recommendation engine (ML + DL) | Implemented | `ai_recommender.py` (`rank_hotels_ml`, `rank_activities_dl`), `train_model.py` |

## Non-Functional / Compliance Tracking

| Requirement | Status | Notes |
|---|---|---|
| AI response target <= 3 seconds | Implemented | Generation now enforces SLA in app flow: plans are not persisted when `aiElapsedMs` is missing/over 3000 ms. |
| Arabic/English localization for core auth and admin flows | Implemented | Login/register/reset password and admin dashboard/manage-content are localized. |
| Full app-wide localization coverage | Implemented | Home, plans, plan details, bookings, help, settings, and privacy flows now use `l10n` keys (ar/en). |

## Notes

- AI response time is stored with each generated trip (`aiElapsedMs`) and enforced against 3000 ms before persisting generated trips.
- Selected plan metadata is persisted (`selectedPlanIndex`, `selectedPlanTitle`, `selected`, `selectedAt`).
- Booking records persist the selected `planId`.

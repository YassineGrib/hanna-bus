# Hanna Bus Parent — Full-Stack Design Specification (Laravel + Flutter)

**Date:** 2026-11-10  
**Backend Target:** `/Users/bmg/Documents/ui/backend` (Fresh Laravel + Sanctum + SQLite API at `/api/v1`)  
**Frontend Target:** `/Users/bmg/Documents/ui/hanna_bus_parent` (Fresh Flutter App)  
**Design Source of Truth:** `/Users/bmg/Documents/ui/output/hanna-bus.figcraft`, `/Users/bmg/Documents/ui/design/palettes/`, `/Users/bmg/Documents/ui/design/assets/brand/hanna-bus-logo.png`.

---

## 1. Intent & Why

Build a complete, fresh full-stack **Hanna Bus Parent** platform directly from the FigCraft design system in `/Users/bmg/Documents/ui`:
1. **Laravel API Backend (`/Users/bmg/Documents/ui/backend`):** Clean Sanctum-authenticated SQLite REST API (`/api/v1`) built from scratch to power every parent flow—onboarding/OTP auth, live bus telemetry, stop timelines, trip history replay, attendance analytics, trilingual school bulletins, child dossiers (personal QR, educative, medical, weekly Sun–Thu schedule), absence reporting, emergency dispatch contacts, support messaging, UI preferences sync, and account deletion.
2. **Flutter Parent Mobile App (`/Users/bmg/Documents/ui/hanna_bus_parent`):** All 34 unified screens across 6 modules in English (LTR), Arabic (RTL with `IBM Plex Sans Arabic`), and French (LTR), featuring Mustard Gold / Teal-Gray / Ocean Blue × Light & Dark modes, abstract background & clipped hero geometry, floating dark capsule navbar, Emil Kowalski motion engineering, and automatic offline demo fallback when the local backend is unreachable.

---

## 2. Goals, Non-Goals & Anti-Goals

### Goals
- **Complete 34-Screen Reachability:** Preserve every layout, field, and graphic from all 36 FigCraft frames across 6 modules, consolidating overlapping Profile/Children child views into `ChildDossierScreen` and `AddEditChildScreen` and adding header/card entry triggers (`gear` on Profile, `History` on Live Tracking, `Manage` on Child Dossier).
- **Trilingual Domain Support (`en`, `ar`, `fr`):** Backend honors `Accept-Language: en|ar|fr` for bulletins, status labels, and error messages; Flutter `AppStrings` provides complete `en`, `ar`, and `fr` localization.
- **Emil Kowalski (`emilkowal.ski/skill`) Motion Engineering:** GPU-cheap `Transform` + `Opacity` transitions (`110–250 ms`), `easeOut` curves, origin-aware bottom sheets, RTL-aware `HannaPageRoute`, never scaling from `0`, and `MediaQuery.disableAnimationsOf(context)` support.
- **Strict Design System Compliance:** All 84 WCAG AA contrast pairs verified across 3 palettes × Light/Dark modes; all 8 interactive widget states implemented.

### Non-Goals & Self-Contained Device Actions
- **No Third-Party Map SDKs or OAuth Secrets:** Use native `StylizedRouteMap` (`CustomPainter`) matching FigCraft rather than `google_maps_flutter`. Apple/Google buttons on Sign In run a clean in-app Social Demo Sign-In against the backend/demo user without external SDK keys.
- **Self-Contained Device Actions (Zero OS Permission Dependencies):** Phone calls (`Call Driver`, `SOS / 14`, `Pediatrician`) open a styled in-app Call Confirmation Sheet; `Download PDF` / `Export Report` opens an in-app Receipt/Report Preview Sheet; `Share` copies a formatted summary/link to the clipboard with feedback snackbar; `Change Photo` opens a curated avatar preset picker.

### Anti-Goals (Hard Rules)
- **Zero Emoji & Zero Em-Dashes (`—`, `–`):** Use `phosphor_flutter` icons and `:`, `,`, `·`, or parentheses in UI copy.
- **No Native `<select>` Lookalikes:** Use `HannaPickerSheet`.
- **No One-Sided Colored Borders:** Full hairline borders only.
- **Never Blue Destructive Actions:** SOS, Delete Child, and Delete Account always use `actionDestructive`.

---

## 3. Tech Stack & Packages

### Backend (`/Users/bmg/Documents/ui/backend`)
- PHP `8.5.4`, Composer `2.9.5`, Laravel + Sanctum (`laravel/sanctum`), SQLite (`database/database.sqlite`), PHPUnit feature & unit test suite.
- Mounted cleanly under `apiPrefix: 'api/v1'` in `bootstrap/app.php`.

### Frontend (`/Users/bmg/Documents/ui/hanna_bus_parent`)
- Flutter (`stable`, Dart `^3.12.2`), `flutter_localizations`, `http`, `phosphor_flutter`, `google_fonts`, `qr_flutter`, `shared_preferences`.
- Asset: `assets/images/hanna-bus-logo.png` copied from `/Users/bmg/Documents/ui/design/assets/brand/hanna-bus-logo.png`.

---

## 4. Backend Schema & API Contract (`/Users/bmg/Documents/ui/backend`)

### 4.1 Database Tables
- `users`: `id`, `name`, `email` (unique), `phone` (nullable), `backup_phone` (nullable), `password`, `role` (default `'parent'`), `is_verified` (default `true`), `primary_bus_stop`, `theme_palette` (`mustard`), `brightness_mode` (`light`), `locale` (`en`).
- `parent_otp_codes`: `id`, `email` (indexed), `code` (`6` chars), `reset_token` (nullable), `verified_at` (nullable), `expires_at`.
- `children`: `id` (string PK e.g. `child-youssef`), `parent_id` (nullable fk `users`), `student_code` (unique e.g. `HB-304`), `full_name`, `birth_date`, `national_id`, `stage` (`preschool|primary|middle|secondary`), `school_name`, `grade`, `class_room`, `homeroom_teacher`, `transport_coordinator`, `dismissal_rule`, `bus_number`, `seat_number`, `stop_name`, `stop_time`, `transit_status` (`on_bus|at_school|at_home|absent`), `avatar_preset`, `blood_type`, `insurance_number`, `allergies`, `chronic_conditions`, `first_aid_protocol`, `pediatrician_name`, `pediatrician_phone`, `schedule_json` (Sun–Thu AM/School/PM slots).
- `active_trips` & `trip_stations`: Live route telemetry (`bus_number`, `driver_name`, `driver_phone`, `vehicle_model`, `plate_number`, `eta_minutes`, `distance_km`, `speed_kmh`, `progress`, `onboard_count`, `capacity`, `status`, ordered stations with `status`: `completed|current|upcoming`).
- `trip_histories`: Completed trips per child (`child_id`, `bus_number`, `period`: `morning|return`, `trip_date`, `departure_time`, `arrival_time`, `duration_minutes`, `distance_km`, `avg_speed_kmh`, `status_badge`, `driver_name`, `driver_rating`, `vehicle_model`, `waypoints_json`, `qr_audit_json`).
- `absence_reports`: `id`, `parent_id`, `child_id`, `absence_date`, `reason`, `status`.
- `safety_notifications`: `id`, `parent_id`, `child_id` (nullable), `category` (`bus|school`), `title_en`, `title_ar`, `title_fr`, `body_en`, `body_ar`, `body_fr`, `time_label`, `is_read`.
- `school_bulletins`: `id`, `tag` (`SCHEDULE|STOP UPDATE|TERM NOTICE`), `title_en`, `title_ar`, `title_fr`, `body_en`, `body_ar`, `body_fr`, `published_at`.
- `support_messages`: `id`, `parent_id`, `recipient_type` (`driver|coordinator`), `child_id` (nullable), `message`, `status`.
- `transit_alert_settings`: `parent_id` (unique), `global_radius_meters` (`400`), `bus_approaching`, `child_boarded`, `arrived_safely`, `route_delays`, `critical_sos_sound`, `sms_backup`.

### 4.2 REST Endpoints (`/api/v1`)
- **Public Auth:**
  - `GET /health` -> `{status: "operational", service: "Hanna Bus Parent API"}`
  - `POST /auth/register` (`name, email, password, phone?`) -> `201 {token, user}` (creates initial alert settings)
  - `POST /auth/login` (`email, password`) -> `200 {token, user}` | `401`
  - `POST /auth/forgot-password` (`email`) -> validates user exists (`422` if unknown), issues OTP in `parent_otp_codes`, returns `{message, demo_otp}` in local/testing
  - `POST /auth/verify-otp` (`email, code`) -> verifies 6-digit OTP (`482910` also valid in local/testing), returns `{verified: true, reset_token}`
  - `POST /auth/reset-password` (`email, reset_token, password, password_confirmation`) -> updates password, deletes OTP, returns `{token, user}` so user proceeds directly to `HomeShell`
- **Authenticated Parent Suite (`auth:sanctum`, prefix `/parent`):**
  - `POST /auth/logout` -> revokes current token
  - `GET /auth/me` -> current user
  - `DELETE /parent/account` (`{confirmation}` must equal `DELETE` or `حذف`) -> deletes user + cascades
  - `GET /parent/profile` & `PUT /parent/profile` (syncs `name`, `email`, `phone`, `backup_phone`, `primary_bus_stop`)
  - `PUT /parent/settings/preferences` (`theme_palette, brightness_mode, locale`)
  - `GET /parent/settings/alerts` & `PUT /parent/settings/alerts`
  - `GET /parent/children`, `POST /parent/children`, `PUT /parent/children/{id}`, `DELETE /parent/children/{id}`
  - `POST /parent/children/link` (`{student_code}`) -> links unassigned child or returns `409` if already owned by another parent
  - `POST /parent/attendance/absences` (`{child_id, absence_date?, reason?}`) -> records absence and sets child `transit_status = absent` (with `DELETE /parent/attendance/absences/{child_id}/today` or toggle to resume)
  - `GET /parent/tracking/active-trip?child_id=...` -> live bus telemetry + ordered stops
  - `GET /parent/tracking/history?child_id=...&period=all|morning|return` -> KPIs + date-grouped historical rides
  - `GET /parent/tracking/trips/{id}` -> full trip replay waypoints + QR audit log + vehicle/driver card
  - `GET /parent/attendance/analytics?child_id=...` -> monthly KPIs (`completed, absences, missed_qr, on_time_rate`) + Sun–Thu AM/PM counts
  - `GET /parent/notifications`, `PUT /parent/notifications/{id}/read`, `PUT /parent/notifications/read-all`
  - `GET /parent/bulletins`, `POST /parent/support/messages`, `GET /parent/emergency-contacts`

---

## 5. Frontend Architecture & Verification (`/Users/bmg/Documents/ui/hanna_bus_parent`)

### 5.1 Tokens, Motion, Offline Fallback & Persistence
- **`HannaTokens` (`ThemeExtension`):** Exact 84-pair WCAG AA verified hex matrix across `Mustard` (default), `Teal-Gray`, and `Ocean Blue` × `Light` and `Dark`, including `onHero`, `onHeroMuted`, `heroAccent`, `onAccent`, destructive tokens, and map surface tokens (`mapLand`, `mapPark`, `mapBlock`, `mapRoad`).
- **Emil Kowalski Motion (`core/motion/hanna_motion.dart`):** `HannaCurves.easeOutExpo`, `HannaCurves.easeOutQuint`, `HannaTactilePress` (`1.0 -> 0.965`, `110ms`), directional RTL-aware `HannaPageRoute` (`250ms`), origin-aware `HannaPickerSheet`, smooth `HannaFloatingNavBar` active pill glide (`180ms`), pulsing live GPS beacon, and full `MediaQuery.disableAnimationsOf(context)` support.
- **API Client + Offline Demo Fallback:** `HannaApiClient` targets `--dart-define=HANNA_API_URL=http://127.0.0.1:8000/api/v1`. When reachable, all screens mutate/read real SQLite records; when unreachable, stores fall back cleanly to `demo_seed.dart` with an `"Offline Demo Mode"` chip.
- **Persistence:** `shared_preferences` stores `palette`, `brightness`, `locale`, notification switches, `onboardingComplete`, and cached offline QR pass snapshot (`Save pass for offline use`). Auth token stays in memory.

### 5.2 Verification Criteria
1. **Backend:** `php artisan test` passes 100% across all feature tests (Auth/OTP/Reset, Children CRUD + Link, Tracking Active/History/Replay, Attendance Analytics, Notifications, Bulletins/Support, Profile/Settings/Delete Account). Live `php artisan serve` + `curl` smoke checks succeed.
2. **Frontend:** `flutter analyze` outputs 0 errors/warnings; `flutter test` passes 100% across contrast token tests, HTTP client mock tests, controller tests, and widget tests covering all 6 modules, EN/AR/FR RTL/LTR, 3 palettes × Light/Dark, child CRUD, reduced motion, and zero overflow (`360px` width & `1.25x` text scale).

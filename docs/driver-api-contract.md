# Hanna Bus: Driver API contract (v1)

Single source of truth for three parallel workstreams:
- **B** backend (`backend/`) implements it.
- **A** parent map (`hanna_bus_parent/`) consumes the parent-side tracking additions (section 6).
- **C** driver app (`hanna_bus_driver/`, later) consumes everything under `/driver`.

Base URL: `/api/v1`. JSON only. Bearer token (Sanctum). Existing conventions stay: errors are `{"message": "..."}`, validation errors use Laravel's 422 shape, user-facing strings are picked with `Trilingual` (en, ar, fr) from the `Accept-Language` / `lang` the parent API already uses. Timestamps are ISO 8601 UTC. IDs are strings, like the existing `children` and `active_trips` tables.

## 1. Roles

- `users.role` is already `parent` by default. Add the value `driver`.
- New middleware `role:<name>` returns `403 {"message": "..."}` when `role` does not match.
- Every existing `/parent/*` route must require `role:parent`. Every `/driver/*` route requires `auth:sanctum` and `role:driver`.
- Token name for drivers: `hanna-driver`.

## 2. New data (migrations, SQLite friendly)

| Table | Columns |
|---|---|
| `driver_profiles` | `user_id` (unique, fk), `license_number`, `rating` (float, default 4.9), `trips_count` (int) |
| `buses` | `id` (string pk), `number` (unique, e.g. `04`), `line_name`, `plate_number`, `vehicle_model`, `capacity`, `status` (`available`, `in_service`, `workshop`) |
| `bus_assignments` | `id`, `driver_id` (fk users), `bus_id` (fk buses), `date` (date), unique(`driver_id`, `date`). This is the rotation: one bus per driver per day |
| `bus_inspections` | `id`, `driver_id`, `bus_id`, `date`, `items_json`, `passed` (bool) |
| `boarding_events` | `id`, `trip_id`, `child_id`, `station_id` (nullable), `type` (`boarded`, `alighted`), `method` (`qr`, `manual`), `driver_id`, `recorded_at` |
| `trip_location_points` | `id`, `trip_id`, `lat`, `lng`, `speed_kmh`, `heading`, `recorded_at` |
| `sos_alerts` | `id`, `driver_id`, `trip_id` (nullable), `type` (`accident`, `breakdown`, `medical`, `security`), `lat`, `lng`, `status` (`open`, `closed`), timestamps |

Changes to existing tables:
- `active_trips`: add nullable `driver_id`, `bus_id`, `lat`, `lng`, `heading`, `last_location_at`, `started_at`, `ended_at`, and `route_points_json` (list of `[lat, lng]`). Status values: `scheduled`, `en_route`, `completed`.
- `trip_stations`: add nullable `lat`, `lng`.
- `support_messages`: add nullable `driver_id`, `direction` (`parent_to_driver`, `driver_to_parent`, default `parent_to_driver`), nullable `read_at`.

Demo seed (same place the current demo data is seeded): driver `ahmed.benali@mail.dz` / `Password123!`, role `driver`, license `DZ-D-2024-0457`, assigned to bus `04` today; buses `04` (in_service), `07` (available), `11` (in_service by another driver, create a second driver for it), `02` (workshop). Give trip stations real coordinates around Algiers (center 36.7538, 3.0588) and a `route_points_json` of 8 to 12 points following them. Existing parent demo data must keep working.

## 3. Driver endpoints

All under `/api/v1/driver`, role `driver`, except login.

### Auth
- `POST /driver/auth/login` `{email, password}` -> `200 {token, user}`. `401` bad credentials. `403` if the user is not a driver.
- `GET /auth/me` and `POST /auth/logout` already exist and keep working for drivers.

### Profile, buses, rotation
- `GET /driver/profile` -> `{user, license_number, rating, trips_count, current_bus}`.
- `GET /driver/buses` -> `[{id, number, line_name, plate_number, vehicle_model, capacity, status, is_current}]`.
- `GET /driver/rotation?week_of=YYYY-MM-DD` -> `{days: [{date, weekday, bus_number|null, is_today}]}` for Sunday to Thursday of that week (default current week).
- `PUT /driver/bus` `{bus_id}` -> `200 {bus, inspection_required: true}`. Sets today's `bus_assignments`. `409` if the bus is `workshop`, or `in_service` for another driver, or the driver has a trip `en_route`.
- `POST /driver/inspections` `{bus_id, items: {tires, brakes, lights, fuel, ...: bool}, passed}` -> `201`. A starting trip requires a passed inspection for the current bus today.

### Trips
- `GET /driver/trips/today` -> `[{id, period (morning|return), route_name, bus_number, status, scheduled_start, stations: [{id, sort_order, name, scheduled_time, status, lat, lng, students: [{child_id, name, student_code, absent}]}]}]`.
- `POST /driver/trips/{trip}/start` -> `200` trip. `422` without a passed inspection today. `409` if the driver already has an `en_route` trip. Sets `en_route`, `started_at`.
- `POST /driver/trips/{trip}/location` `{lat, lng, speed_kmh?, heading?}` -> `200 {ok: true}`. Updates the trip's `lat`, `lng`, `heading`, `speed_kmh`, `last_location_at`, recomputes `progress` (0 to 1, nearest point along `route_points_json`) and appends a `trip_location_points` row. Only the trip's own driver, only while `en_route` (`409` otherwise). Throttle to 30 per minute per driver.
- `POST /driver/trips/{trip}/stations/{station}/arrive` -> `200`. Marks earlier stations `completed`, this one `current`. Creates a `SafetyNotification` (category `bus`, trilingual) for each parent with a child at that stop.
- `POST /driver/trips/{trip}/delay` `{minutes: 1..120, reason: traffic|breakdown|weather|other}` -> `200 {notified: n}`. Notifies all parents of the trip's children and updates `eta_minutes`.
- `POST /driver/trips/{trip}/end` `{safety_walk_confirmed: true}` -> `200`. `422` unless confirmed. Sets `completed`, `ended_at`, creates one `trip_histories` row per child who boarded, increments `driver_profiles.trips_count`.

### Boarding
- `GET /driver/trips/{trip}/students` -> `[{child_id, name, student_code, stop_name, transit_status, absent, boarded_at|null}]`.
- `POST /driver/trips/{trip}/boarding` `{student_code, type: boarded|alighted, method: qr|manual}` -> `201 {event, child, onboard_count}`. `404` unknown code. `422` child not on this trip's bus, or absent today. Repeating the same event for the same child and trip returns `200` with the existing event (idempotent). Updates `children.transit_status` (`on_bus` on boarded, `at_school` on alighted in a morning trip, `at_home` on alighted in a return trip), `active_trips.onboard_count`, and notifies the parent.

### Messages
- `GET /driver/messages` -> `[{parent: {id, name}, child: {id, name, stop_name}, last_message, last_at, unread_count, is_urgent}]`, newest first. A message is urgent when it contains the child's allergy or medical keywords or was sent with `urgent: true`.
- `GET /driver/messages/{parent}?child_id=` -> `{parent, child, messages: [{id, direction, message, created_at, read_at}]}`. Marks the parent's messages as read.
- `POST /driver/messages/{parent}` `{child_id, message}` -> `201`. The parent must have that child on a bus the driver drives. Creates a `driver_to_parent` row and a parent notification.

### History and stats
- `GET /driver/history?period=week|month|all` -> `{totals: {trips, km, on_time_rate}, trips: [{id, date, period, route_name, departure_time, arrival_time, students, status_code (completed|delayed), delay_minutes}]}`.
- `GET /driver/stats` -> `{rating, trips_count, on_time_rate, trips_this_month, km_this_month, safe_scans, per_weekday: [{weekday, trips}]}`.

### SOS
- `POST /driver/sos` `{type: accident|breakdown|medical|security, lat?, lng?, trip_id?}` -> `201`. Creates the `sos_alerts` row and one `SafetyNotification` per affected parent when `trip_id` is given.

## 4. Parent endpoint additions

- `GET /parent/support/messages` -> list of the parent's thread with drivers, same item shape as `messages` above, so parents can read driver replies. The existing `POST /parent/support/messages` keeps working.

## 5. Behaviour rules

- Everything a driver touches is scoped to their own trips and their bus's children. Another driver's trip is `404`.
- A parent only ever sees children linked to them (unchanged).
- No endpoint trusts a client-provided `driver_id`.

## 6. Parent tracking additions (what the map needs)

`GET /parent/tracking/active-trip` keeps every current field and adds:

```json
{
  "location": {"lat": 36.7552, "lng": 3.0601, "heading": 82, "updated_at": "2026-11-21T07:14:03Z"},
  "route_points": [[36.7538, 3.0588], [36.7545, 3.0597]],
  "stations": [{"id": 1, "name": "...", "lat": 36.7538, "lng": 3.0588, "status": "completed"}]
}
```

- `location` is `null` until the driver sends the first point. Clients must then fall back to placing the bus along `route_points` using `progress`.
- `route_points` is `[]` when unknown. Stations' `lat` and `lng` are `null` when unknown.
- `GET /parent/tracking/trips/{id}` (history replay) keeps `waypoints` (normalized 0 to 1 pairs) and adds `route_points` as real coordinates when available.

## 7. Done means

- `php artisan test` is green, the 14 existing tests untouched, new feature tests for every endpoint above (happy path, 401, 403 wrong role, the 409 and 422 rules).
- Parent demo flows keep working. A driver token gets `403` on `/parent/*` and a parent token gets `403` on `/driver/*`.

## 8. Round 2 additions (hardening and phase 2 of the driver app)

Everything above is implemented. This section adds the remaining pieces. Existing endpoints keep their shape unless stated.

### 8.1 Hardening
- Trip state guards. `arrive`, `delay`, `boarding` and `end` require the trip to be `en_route`: otherwise `409 {"message": ...}`. Exception: `end` on an already `completed` trip stays an idempotent `200`. `students` and `today` have no state guard.
- Data minimisation. No driver endpoint returns a full `Child` model. A driver-facing child object contains only: `id`, `name`, `student_code`, `grade`, `stop_name`, `stop_time`, `bus_number`, `seat_number`, `transit_status`, `avatar_preset`, `dismissal_rule`, `absent`. Never `national_id`, `insurance_number`, `birth_date` or the pediatrician fields. `POST /driver/trips/{trip}/boarding` returns that object too.
- Login throttle: `POST /driver/auth/login` and the parent login are limited to 5 attempts per minute per email and IP (`429`).
- The existing `POST /auth/forgot-password`, `/auth/verify-otp` and `/auth/reset-password` must work for driver accounts as well as parents. Add tests for a driver.

### 8.2 New driver endpoints (role `driver`)
- `GET /driver/students/{child}` -> dossier for a child on one of the driver's buses (404 otherwise): `{student: <driver-facing child object>, transit: {bus_number, seat_number, stop_name, stop_time, return_time, dismissal_rule}, medical: {blood_type, allergies, chronic_conditions, first_aid_protocol}, guardian: {name, phone, backup_phone}}`.
- `PUT /driver/profile` `{name?, phone?, locale?: en|ar}` -> updated profile.
- `GET /driver/settings` and `PUT /driver/settings`. Stored as JSON on `driver_profiles.settings_json`. Known keys, all optional on PUT, unknown keys rejected with 422: `voice_guidance` (bool), `speed_chime` (bool), `glare_mode` (`auto|day|night`), `radar_radius_m` (int 100 to 1000), `scan_mode` (`camera|bluetooth`), `scan_chime` (bool), `biometric_unlock` (bool), `quick_pin_enabled` (bool), `privacy_lock_minutes` (int 1 to 30), `theme_palette` (`mustard|teal-gray|ocean-blue`), `brightness_mode` (`light|dark|auto`). GET returns all keys with defaults filled in.
- `GET /driver/contacts` -> `{emergency: [{key: civil_protection, label, phone: "14"}, {key: police, label, phone: "17"}], school: {name, phone}, coordinator: {name, phone}}`. Values from a new `config/hanna.php` (env `HANNA_SCHOOL_NAME`, `HANNA_SCHOOL_PHONE`, `HANNA_COORDINATOR_NAME`, `HANNA_COORDINATOR_PHONE`, with demo defaults). `GET /driver/profile` also returns `school` and `coordinator` with the same shape.
- `GET /driver/telemetry/today` -> `{max_speed_kmh, avg_speed_kmh, speeding_events, distance_km, driving_minutes, trips}` computed from today's `trip_location_points` and trips. A speeding event is a point above 60 km/h. Zeroes when there is no data.
- `GET /driver/buses/{bus}` -> vehicle passport: `{id, number, line_name, plate_number, vehicle_model, capacity, status, insurance_expires_on, technical_control_expires_on, last_service_on, last_inspection: {date, passed}|null}`. Add the three nullable date columns to `buses` and seed them.

### 8.3 Parent side
- `GET /parent/support/messages` already exists. Add `PUT /parent/support/messages/{id}/read` (only the parent's own, marks `read_at`).
- A parent with no children gets `404 {"message": ...}` from `/parent/tracking/active-trip`. The parent app must show an empty state, not an error.

### 8.4 Done means (round 2)
- `php artisan test` green, all earlier tests still passing, new tests for every item in 8.1 to 8.3.
- The Flutter driver app (`hanna_bus_driver/`) calls every endpoint in 8.2.

### 8.5 Driver map data (added after emulator testing)
- `GET /driver/trips/today` items also return `route_points` (list of `[lat, lng]`, `[]` when unknown), the same value the parent endpoint returns, so the driver app can draw the route on a real map. Station `lat` and `lng` stay as they are.

### 8.6 Daily trip generation (added after emulator testing)
Today's trips used to exist only as seeded rows. Add the artisan command `php artisan hanna:generate-trips {--date=}` (default today, `YYYY-MM-DD`):
- For every bus that has a `bus_assignments` row for that date, and for every bus with a driver on the previous service date, clone the most recent morning trip and the most recent return trip of that bus, with their stations and route points, into new `active_trips` rows for the date: id `trip-{bus_number}-{am|return}-{YYYYMMDD}`, `status = scheduled`, `service_date` set, `driver_id` from that day's assignment, and progress, location, speed, `started_at`, `ended_at`, `delay_minutes` and `onboard_count` reset; stations reset to `upcoming`.
- Idempotent: running it twice creates nothing new. It never touches an existing row for that date.
- Registered in the scheduler to run daily at 00:05. The seeder may keep its demo trips.
- Feature tests cover: creating trips, idempotence, no assignment means no trip, driver and bus from the assignment, and `/driver/trips/today` returning the generated trips.

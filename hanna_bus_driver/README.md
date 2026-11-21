# Hanna Bus Driver

Driver daily route companion with the full phase 2 screen set. English and Arabic with live RTL, three project palettes, light, dark and system appearance, bundled fonts and Phosphor icons, shared motion tokens and the floating home navigation. Android application ID: `com.hannabus.hanna_bus_driver`.

## Run

```sh
flutter pub get
flutter run --dart-define=HANNA_API_URL=http://10.0.2.2:8000/api/v1
```

Use a reachable server address on a phone. `10.0.2.2` is for Android emulators. The default is `http://127.0.0.1:8000/api/v1`. HTTP is enabled only in the Android debug manifest; use HTTPS for deployment.

Demo credentials: `ahmed.benali@mail.dz` / `Password123!`. A transport failure during login permits this seeded session. The credentials hint appears only in debug builds (`kDebugMode`) after a login transport failure; the next HTTP response clears this condition. A visible banner labels all simulated actions. All phase 2 modules have separate in-memory demo responses, including messages, settings and profile edits. Live sessions never switch into simulation after login. Authentication, authorization, validation and conflict failures stay errors. Undeployed round 2 endpoints do not block daily trip initialization; their screens expose localized error and retry states. There is no offline mode, student cache, queued boarding or French option. Tokens remain in memory. Appearance, language and operational preferences are saved locally.

## Screens and behavior

* Auth: welcome, driver sign in, recovery email, OTP verification and new password. Recovery calls the existing auth API, carries the returned reset token and returns to sign in after success. It never invents a verification code. A development OTP is displayed only if the server explicitly returns `demo_otp`.
* Home: mission control, trip selection, inspection, station manifest, Messages shortcut and unread header badge, roster, navigation and profile entry points.
* Boarding: QR camera, manual student code fallback and Bluetooth keyboard scanner input. Parent payloads (`HANNA-BUS|student_code|BUS-number|name`), plain student codes and JSON with `student_code` are accepted. Bluetooth devices must already be paired as keyboards in device settings. Successful scans give haptic feedback and the configured system chime. Backend eligibility and boarding idempotency remain authoritative.
* Trips: twelve physical inspection checks, start, foreground GPS, arrival, delay broadcast, boarding and alighting, mandatory safety walk and finish. Inspection is also accessible from profile and vehicle passport. The API's four required fields remain present alongside the additional inspection items.
* Students: searchable roster, status filters, grouping by stops, absence view and a student dossier with Transit, Medical and Guardian tabs. The dossier shows actual schedules, seat, handover protocol, permitted health fields, first aid protocol and primary/backup guardian calls through the injectable dialer. No pediatrician or private identity fields are requested.
* Messages: All, Unread and Urgent filters with counts, unread badges and urgent tags; parent and child context; incoming/outgoing bubbles, quick replies and composer. Opening a thread marks its messages read through GET and updates the home badge. The open foreground thread polls about every ten seconds without overlapping requests. Polls skip covered routes and stop on disposal or app pause. Sending requires a confirmed POST; an inbox refresh failure after a successful POST does not invite a duplicate send.
* History: week, month and all periods; totals, route names, dates, times, passenger counts and delayed/completed status. Performance: rating hero, four KPI cards and weekday bar chart. The API provides no parent quote, so none is fabricated.
* Profile: driver identity, rating, license and contact editing; vehicle passport with bus identity, capacity, insurance/technical control/service dates and last inspection; today's six telemetry metrics; dispatch contacts for school, coordinator and emergency services; links to history, performance, messages and settings.
* SOS: three second hold, incident type, latest available coordinates, API submission and dialer shortcuts. School/coordinator numbers come from `/driver/contacts`, then profile contact data; `HANNA_SCHOOL_PHONE` remains a final optional build-time fallback. SOS does not automatically call rescue services.
* Settings: hub; navigation and audio; scanner and hardware; shift security; localization and night mode; expandable SOP handbook with actual session/location diagnostics. All eleven contract settings are loaded and saved through GET/PUT and locally. EN/AR locale is saved with PUT profile. Palette and light/dark/system brightness apply throughout the app; system mode responds to platform brightness changes. Map glare mode applies to the map tiles and overlays, speed chime uses the contract's 60 km/h threshold, scan chime controls scan feedback, and Bluetooth mode avoids opening the camera.
* Privacy: the configured idle timer covers student information with a privacy curtain; real backgrounding (paused or hidden) leaves it covered until Resume shift. Inactive system dialogs do not cover information or run the timer. Location permission and accuracy acquisition suspend the curtain and idle timer; routine GPS samples preserve the idle deadline. The curtain is not authentication. Biometric and Quick PIN toggles store preferences only; no native authentication plugin, PIN enrollment or protected unlock is claimed.

## Architecture and changed modules

* `lib/core/state/app_state.dart` remains the ChangeNotifier controller. `phase2_state.dart` is its library part for settings, profile, messages, dossiers, history, stats, contacts, telemetry, passport and recovery calls.
* `lib/core/network` retains the API transport and session-pinned repository. `phase2_demo.dart` extends the existing separate `DemoSeed` simulator.
* `lib/core/widgets/remote_page.dart` centralizes asynchronous reads, localized errors, retry, display timestamps and data cards. `privacy_guard.dart` handles the privacy curtain. Existing tokens, typography, backgrounds and cards remain shared.
* `lib/features/messages/messages_screen.dart`: inbox and thread.
* `lib/features/history/history_screens.dart`: history, performance, metric grid and weekday chart.
* `lib/features/students/dossier_screen.dart`: three dossier tabs and injectable dialing; roster and home student cards open it.
* `lib/features/profile/profile_screens.dart`: hub, edit contacts, passport, telemetry and dispatch contacts.
* `lib/features/settings/settings_screens.dart`: hub and five sub screens.
* `lib/features/auth/recovery_screen.dart`: three recovery steps, replacing the coordinator workaround.
* `assets/l10n/design_strings.json` includes the EN/AR design builder strings; `phase2_strings.json` supplies operational labels and honest capability descriptions. English uses Inter; Arabic uses IBM Plex Sans Arabic with the existing extra pixel for small text.
* `test/phase2_modules_test.dart`, API fallback, auth, inspection, RTL/overflow and preview tests cover the new modules. Services remain injectable and tests use only fakes and HTTP mocks.

## API calls

All paths are relative to `/api/v1`. The app sends `Accept-Language` and bearer authentication for live driver sessions.

| Method | Path | Use |
| --- | --- | --- |
| POST | `/driver/auth/login` | Driver role login |
| POST | `/auth/logout` | Sign out |
| POST | `/auth/forgot-password` | Recovery email |
| POST | `/auth/verify-otp` | Verify code and obtain reset token |
| POST | `/auth/reset-password` | Reset password and confirmation |
| GET, PUT | `/driver/profile` | Driver context and contact/locale editing |
| GET | `/driver/buses` | Assigned and switchable vehicles |
| GET | `/driver/buses/{bus}` | Vehicle passport |
| GET | `/driver/rotation` | Sunday to Thursday rotation |
| PUT | `/driver/bus` | Switch assignment |
| POST | `/driver/inspections` | Physical vehicle checks |
| GET | `/driver/trips/today` | Mission control and stations |
| GET | `/driver/trips/{trip}/students` | Roster and boarding status |
| POST | `/driver/trips/{trip}/start` | Start after inspection |
| POST | `/driver/trips/{trip}/location` | Foreground GPS |
| POST | `/driver/trips/{trip}/stations/{station}/arrive` | Confirm arrival |
| POST | `/driver/trips/{trip}/boarding` | QR/manual boarding or alighting |
| POST | `/driver/trips/{trip}/delay` | Delay duration and reason |
| POST | `/driver/trips/{trip}/end` | Confirm safety walk and finish |
| GET | `/driver/students/{child}` | Transit, medical and guardian dossier |
| GET | `/driver/messages` | Inbox and unread counts |
| GET | `/driver/messages/{parent}?child_id={child}` | Thread and mark read |
| POST | `/driver/messages/{parent}` | Reply with `child_id` and `message` |
| GET | `/driver/history?period=week\|month\|all` | History and totals |
| GET | `/driver/stats` | Rating, KPIs and weekday chart |
| GET, PUT | `/driver/settings` | All contract preference keys |
| GET | `/driver/contacts` | School, coordinator and emergency contacts |
| GET | `/driver/telemetry/today` | Today's measured driving metrics |
| POST | `/driver/sos` | Incident and optional trip/location |

All seven method/path combinations from contract section 8.2 are called, alongside the three recovery endpoints and the previously implemented API.

## Capability limits and design adaptations

The contract does not supply engine health, brake/tire measurements, fuel diagnostics, certification expiry, a derived safety score, parent commendations, towing contacts, maintenance requests or diagnostic export endpoints. These mock values and unsupported success actions are not fabricated. The implemented passport, telemetry and contacts screens present actual contract data and retain the shared design language. Parent quotes are omitted as permitted by scope.

Voice guidance and proximity radius persist as terminal preferences. Actual spoken turn instructions and automatic proximity notifications need a routing provider and appropriate API behavior; the existing contract supplies station coordinates rather than routing instructions. Navigation uses flutter_map and free OpenStreetMap tiles with attribution, a route polyline, completed/current/upcoming station markers, the driver's last successfully sent position and a recenter control. It prefers optional `route_points` from GET `/driver/trips/today`, then valid station coordinates in order. When neither is available it shows an ordered schematic and a localized note. Geographic points remain unmirrored in RTL; controls and tooltips follow EN/AR direction. Straight segments between stations do not claim road routing. Glare mode adjusts the map tiles and overlays. Tiles need network access; tests inject `NonNetworkTileProvider` through `LiveRouteMap.defaultTileProvider` or the widget constructor. The handbook uses supplied operating guidance without claiming a live WebSocket, GPS accuracy reading or regulatory certification.

GPS is sampled approximately every five seconds while an active trip is foregrounded, with no overlapping requests. Permission denial gives immediate localized retry feedback. Other acquisition or send failures show the retry banner only after two consecutive failures. A successful POST clears the banner and failure streak immediately and notifies listeners to update Home and the map. One transient failure stays silent; a later failure after success starts a new streak. Background/locked-device tracking is not implemented. Privacy curtains do not stop an active trip's foreground GPS. Recovery requires the real auth server, including when the separate driver demo simulator is available.

## Validation and previews

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Run the four gates above after changes. The optional live backend suite stays skipped unless `HANNA_LIVE_API_URL` is supplied.

Tests are fully offline: HTTP mocks, fake camera, location and dialer, and non-network map tiles. They cover daily trip operations, every new module, recovery payloads and reset tokens, demo endpoint coverage, live errors without fallback, message polling lifecycle, settings persistence, live RTL/appearance, Bluetooth QR input, privacy lifecycle and permission suppression, location banner recovery, conditional login hints, route fallback, map markers and controls, selected chip contrast across every palette and brightness, and screens at 360px with 1.25 text scale in EN/AR and light/dark themes.

Generate 44 current EN/AR screen previews in PowerShell:

```powershell
$env:HANNA_CAPTURE='1'
flutter test test/visual_render_capture_test.dart
Remove-Item Env:HANNA_CAPTURE
```

Previews are written to `output/previews/`. Android debug APK: `build/app/outputs/flutter-apk/app-debug.apk`. Real Laravel integration, device camera, GPS, Bluetooth pairing, system audio, dialer behavior and iOS compilation require separate verification. No changes outside `hanna_bus_driver/` are needed for this app.

## Live backend e2e and emulator

Start the existing Laravel server on the host at port 8000 using the backend's documented setup. Use a dedicated freshly seeded test backend: the live suite changes trip state through boarding, arrival, delay, SOS and completion. It stays skipped during the default offline test suite.

From `hanna_bus_driver/`, run the host-based live test:

```sh
flutter test test/live_backend_e2e_test.dart --dart-define=HANNA_LIVE_API_URL=http://127.0.0.1:8000/api/v1
```

Launch an Android emulator, then connect the driver to the host server:

```sh
flutter devices
flutter run --dart-define=HANNA_API_URL=http://10.0.2.2:8000/api/v1
```

Use `-d <emulator-device-id>` if multiple devices are connected. Sign in with the seeded driver, select today's trip, complete inspection if needed, start and grant foreground location permission. Open Navigation to check tiles, stop statuses, driver position and recenter. Interrupt connectivity briefly to verify that one failed send stays silent and successful sends clear a repeated-failure banner. Permission and accuracy dialogs should leave student information visible; returning from the launcher should require Resume shift. Check Arabic labels and controls with larger system text. Map tiles contact OpenStreetMap; no API key or paid map service is used.

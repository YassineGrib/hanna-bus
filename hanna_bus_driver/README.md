# Hanna Bus Driver

Separate Flutter app for the phase 1 driver daily flow. English and Arabic, RTL, three palettes, light and dark themes. Android application ID: `com.hannabus.hanna_bus_driver`.

## Run

```sh
flutter pub get
flutter run --dart-define=HANNA_API_URL=http://10.0.2.2:8000/api/v1
```

Use a reachable server address on a phone. `10.0.2.2` is for the Android emulator; the default is `http://127.0.0.1:8000/api/v1`. Development HTTP is enabled in the Android debug manifest. Use HTTPS for deployment.

Demo credentials: `ahmed.benali@mail.dz` / `Password123!`. Only a transport failure during login permits this seeded demo session. A visible demo banner identifies simulated actions. Server authentication, authorization, validation and conflict failures stay errors. Live sessions never silently switch into simulation. No boarding queue or offline mode is implemented. Tokens stay in memory; appearance and language preferences are saved locally.

The parent QR payload `HANNA-BUS|student_code|BUS-number|name`, a plain student code and JSON with `student_code` are accepted. Backend responses remain the authority for student eligibility and boarding idempotency.

To enable the school coordinator dial shortcut, also pass `--dart-define=HANNA_SCHOOL_PHONE=<school phone number>`. The API contract does not provide this number. Civil Protection and Police shortcuts open the device dialer. SOS submits the incident to the backend; it does not place an emergency call automatically.

## Architecture

* `lib/core/theme`, `motion`, `widgets`: copied parent visual foundation, adapted locally; bundled fonts and Phosphor SVGs.
* `lib/core/l10n`: EN/AR design strings plus operational feedback. `assets/l10n/design_strings.json` contains the phase 1 STR entries extracted from the FigCraft builders, with example counts replaced by API data in widgets.
* `lib/core/network`: HTTP transport and repository. The repository pins each session to the live API or a separate in-memory simulator.
* `lib/core/state`: immutable parsed models, demo seed and provider-free ChangeNotifier controller.
* `lib/core/services`: injectable scanner, location and phone dialer interfaces.
* `lib/features`: auth, home shell, inspection and safety walk, boarding, students, fleet, navigation and SOS.

## API calls

Paths are relative to `/api/v1`.

| Method | Path | Use |
| --- | --- | --- |
| POST | `/driver/auth/login` | Driver role login |
| POST | `/auth/logout` | Sign out |
| GET | `/driver/profile` | Driver name and assignment context |
| GET | `/driver/buses` | Current and switchable buses |
| GET | `/driver/rotation` | Current Sunday to Thursday rotation |
| PUT | `/driver/bus` | Switch today's assignment |
| POST | `/driver/inspections` | Four required inspection items |
| GET | `/driver/trips/today` | Mission control and station manifest |
| GET | `/driver/trips/{trip}/students` | Roster and boarding status |
| POST | `/driver/trips/{trip}/start` | Start after inspection |
| POST | `/driver/trips/{trip}/location` | Active trip GPS update |
| POST | `/driver/trips/{trip}/stations/{station}/arrive` | Confirm arrival |
| POST | `/driver/trips/{trip}/boarding` | QR or manual boarding and alighting |
| POST | `/driver/trips/{trip}/delay` | Delay duration and reason |
| POST | `/driver/trips/{trip}/end` | Mandatory safety walk confirmation |
| POST | `/driver/sos` | Incident and optional latest coordinates |

No in-scope operational screen is restricted to demo data. Recovery is a coordinator contact UI because no driver password recovery endpoint exists. Messages, history, stats, profile hub and settings screens are deferred. The Profile tab gives a localized phase notice; appearance controls are a small sheet accessible from the header.

## Location and navigation limits

Location is sampled and posted approximately every five seconds while an active trip is foregrounded. Requests never overlap, and stop on app pause, trip end, logout and disposal. Permission denial and unavailable location services leave the trip usable with a localized retry notice. Background or locked-screen tracking is not implemented in phase 1.

The navigation view plots actual station coordinates and allows arrival confirmation. The contract provides no turn instruction or routing provider, so this is a route overview rather than a road map with turn by turn directions. Its geometry is not mirrored in RTL.

## Validation

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
dart run flutter_launcher_icons
```

Tests use an HTTP mock or fake repository, fake camera, fake location and fake dialer. No network, camera or GPS is used. Tests load shipped fonts and cover all modules, a full trip flow, demo fallback, role rejection, absent students, duplicate scans, location cadence and lifecycle, three-second SOS hold, semantic contrast across all themes, and 360px layouts at 1.25 text scale in EN/AR.

To regenerate preview PNGs in PowerShell:

```powershell
$env:HANNA_CAPTURE='1'
flutter test test/visual_render_capture_test.dart
```

Previews are written to `output/previews/`. Device camera, real GPS, dialer behavior, live Laravel integration and iOS compilation require separate verification. iOS camera and location usage descriptions are provided in English and Arabic.

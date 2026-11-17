# Hanna Bus Parent Full-Stack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (or superpowers:subagent-driven-development) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the fresh Laravel 13 + Sanctum SQLite API (`/Users/bmg/Documents/ui/backend`) and the 34-screen bilingual RTL/LTR Flutter parent app (`/Users/bmg/Documents/ui/hanna_bus_parent`) matching the FigCraft designs, Emil Kowalski motion spec, and offline fallback architecture.

**Architecture:** Clean two-subsystem architecture inside `/Users/bmg/Documents/ui`: a REST API mounted at `/api/v1` backed by SQLite and Sanctum tokens, paired with a feature-first Flutter app using `HannaTokens` (`ThemeExtension`, 3 palettes × Light/Dark), `HannaMotion` (GPU-cheap `Transform`/`Opacity` curves), `ChangeNotifier` stores via `InheritedNotifier`, `CustomPainter` maps/charts/abstract shapes, and graceful `demo_seed` offline fallback.

**Tech Stack:** PHP `8.5.4`, Composer `2.9.5`, Laravel + Sanctum, SQLite, PHPUnit; Flutter `3.44.6`, Dart `^3.12.2`, `http`, `phosphor_flutter`, `google_fonts`, `qr_flutter`, `shared_preferences`, `flutter_localizations`.

**Spec:** `/Users/bmg/Documents/ui/docs/superpowers/specs/2026-11-10-hanna-bus-parent-design.md`

---

## Global Constraints

- Zero emoji and zero em/en dashes (`—`, `–`) in any UI copy; use `phosphor_flutter` icons and `:`, `,`, `·`, or parentheses.
- Never use native `<select>` / unstyled dropdown lookalikes; always use custom trigger fields opening `HannaPickerSheet`.
- Never use one-sided colored borders on cards, alerts, or callouts; always use full hairline borders.
- Destructive actions (`SOS`, `Delete child`, `Delete account`) always use `actionDestructive` on both triggers and confirm dialogs.
- Backend API mounts under `apiPrefix: 'api/v1'`; supports `Accept-Language: en|ar|fr`.
- Flutter UI motion stays `< 300ms`, animates only `Transform`/`Opacity`, never scales from `0`, never uses `easeIn` on entrances, and resolves to `Duration.zero` when `MediaQuery.disableAnimationsOf(context)` is true.
- Only preferences (`palette`, `brightness`, `locale`, notification flags, `onboardingComplete`, cached QR snapshot) persist in `shared_preferences`; Sanctum token stays in-memory.

## Review Focus

1. **84-pair WCAG AA contrast compliance:** All 6 theme combinations (`Mustard`, `Teal-Gray`, `Ocean Blue` × `Light`, `Dark`) must pass `>= 4.5:1` on text/muted/hero/accent/destructive surfaces and `>= 3.0:1` on large titles/icons (`test/theme_contrast_test.dart` in Task 6).
2. **Offline cold start fallback:** When `http://127.0.0.1:8000/api/v1` is unreachable (`SocketException` / timeout), signing in or launching in demo mode enters `HomeShell` with `demo_seed.dart` and marks `isOfflineDemo = true` rather than hanging (`test/api_client_fallback_test.dart` in Task 7).
3. **Destructive ID / Keyword confirmation guards:** `ManageChildScreen` refuses deletion until the exact `studentCode` (`HB-304`) is typed; `AccountActionsScreen` and `DELETE /api/v1/parent/account` refuse deletion unless `DELETE` or `حذف` is provided (`AccountManagementTest` in Task 2 & `test/settings_flow_test.dart` in Task 13).
4. **RTL mirroring & text overflow at 360px / 1.25x scale:** Switching locale to `ar` switches `Directionality` to `TextDirection.rtl`, flips directional icons/slides (`HannaPageRoute`), and passes zero `RenderFlex` overflow checks at `360px` width and `1.25x` text scaling (`test/rtl_and_overflow_test.dart` in Task 13).
5. **Cross-parent authorization isolation:** A parent cannot read, edit, link-hijack (`409`), or delete another parent's child or mark another parent's notification read (`ChildManagementTest` in Task 3).

---

## Phase A — Laravel Backend (`/Users/bmg/Documents/ui/backend`)

### Task 1: Scaffold Laravel + Sanctum + Core Migrations + Health Endpoint

**Files:**
- Create: `/Users/bmg/Documents/ui/backend/` (via `composer create-project laravel/laravel`)
- Modify: `bootstrap/app.php`, `routes/api.php`, `.env`, `database/migrations/*`
- Test: `tests/Feature/HealthAndSchemaTest.php`

**Interfaces:**
- Produces: Running Laravel SQLite test setup, `/api/v1/health` JSON endpoint, core migrations (`users`, `parent_otp_codes`, `children`, `active_trips`, `trip_stations`, `trip_histories`, `absence_reports`, `safety_notifications`, `school_bulletins`, `support_messages`, `transit_alert_settings`).

- [ ] **Step 1:** Run `composer create-project laravel/laravel /Users/bmg/Documents/ui/backend --no-interaction` and `composer require laravel/sanctum` inside `backend`, configure SQLite in `.env` and `phpunit.xml` (`:memory:` for fast test runs), and set `apiPrefix: 'api/v1'` in `bootstrap/app.php` plus `Route::get('/health', ...)` in `routes/api.php`.
- [ ] **Step 2:** Write `tests/Feature/HealthAndSchemaTest.php` asserting `GET /api/v1/health` returns `200` with `status: operational` and all required tables exist after migration.
- [ ] **Step 3:** Run `php artisan test tests/Feature/HealthAndSchemaTest.php` -> confirm FAIL (missing tables/migrations).
- [ ] **Step 4:** Write all database migrations matching Section 4.1 of the spec and Eloquent models (`User`, `ParentOtpCode`, `Child`, `ActiveTrip`, `TripStation`, `TripHistory`, `AbsenceReport`, `SafetyNotification`, `SchoolBulletin`, `SupportMessage`, `TransitAlertSetting`) with `HasApiTokens` on `User` and proper relationships/casts (`schedule_json`, `waypoints_json`, `qr_audit_json`).
- [ ] **Step 5:** Run `php artisan migrate --force` and `php artisan test tests/Feature/HealthAndSchemaTest.php` -> Expected: PASS.

---

### Task 2: Auth Suite (Register, Login, OTP Forgot/Verify/Reset, Me, Logout, Delete Account)

**Files:**
- Create: `app/Http/Controllers/Api/V1/AuthController.php`
- Modify: `routes/api.php`
- Test: `tests/Feature/AuthSuiteTest.php`

**Interfaces:**
- Consumes: `User`, `ParentOtpCode`, `TransitAlertSetting`.
- Produces: `/api/v1/auth/register` (`phone` optional), `/login`, `/forgot-password`, `/verify-otp`, `/reset-password` (returns `{token, user}`), `/logout`, `/me`, and `DELETE /api/v1/parent/account`.

- [ ] **Step 1:** Write failing `tests/Feature/AuthSuiteTest.php` covering:
  - `register` without `phone` creates user + alert settings and returns `201 {token, user}`.
  - `login` valid -> `200 {token, user}`; invalid -> `401`.
  - `forgot-password` unknown email -> `422`; valid email -> `200 {message, demo_otp}`.
  - `verify-otp` invalid code -> `422`; valid OTP (or `482910` in testing/local) -> `200 {verified: true, reset_token}`.
  - `reset-password` updates password hash, invalidates OTP, and returns `{token, user}` allowing authenticated `/auth/me`.
  - `DELETE /api/v1/parent/account` with wrong confirmation -> `422`; with `DELETE` or `حذف` -> deletes user, revokes token (`200`).
- [ ] **Step 2:** Run `php artisan test tests/Feature/AuthSuiteTest.php` -> confirm FAIL.
- [ ] **Step 3:** Implement `AuthController` + routes in `routes/api.php`.
- [ ] **Step 4:** Run `php artisan test tests/Feature/AuthSuiteTest.php` -> Expected: PASS.

---

### Task 3: Children Dossier CRUD, Linking & Absence Reports

**Files:**
- Create: `app/Http/Controllers/Api/V1/ChildController.php`, `app/Http/Controllers/Api/V1/AttendanceController.php`, `app/Http/Resources/ChildResource.php`
- Modify: `routes/api.php`
- Test: `tests/Feature/ChildManagementTest.php`

**Interfaces:**
- Consumes: `Child`, `AbsenceReport`.
- Produces: `/api/v1/parent/children` (`index`, `store`, `show`, `update`, `destroy`), `/api/v1/parent/children/link` (`student_code`), `/api/v1/parent/attendance/absences` (`index`, `store`, `destroyToday`).

- [ ] **Step 1:** Write failing `tests/Feature/ChildManagementTest.php` covering:
  - Creating a preschool/primary/middle/secondary child with extended fields (`birth_date`, `national_id`, `seat_number`, `homeroom_teacher`, `transport_coordinator`, `dismissal_rule`, `insurance_number`, `pediatrician_name`, `pediatrician_phone`, `schedule`).
  - Linking an unassigned child by `student_code`, returning `409` if owned by another parent (Review Focus #5), and `403` when accessing/editing/deleting another parent's child.
  - Reporting today's absence updates `transit_status = absent`, and resuming clears it.
- [ ] **Step 2:** Run `php artisan test tests/Feature/ChildManagementTest.php` -> confirm FAIL.
- [ ] **Step 3:** Implement `ChildResource`, `ChildController`, and `AttendanceController`.
- [ ] **Step 4:** Run `php artisan test tests/Feature/ChildManagementTest.php` -> Expected: PASS.

---

### Task 4: Live Tracking, Trip History, Trip Replay & Attendance Analytics

**Files:**
- Create: `app/Http/Controllers/Api/V1/TrackingController.php`
- Modify: `app/Http/Controllers/Api/V1/AttendanceController.php`, `routes/api.php`
- Test: `tests/Feature/TrackingAndAnalyticsTest.php`

**Interfaces:**
- Consumes: `ActiveTrip`, `TripStation`, `TripHistory`, `Child`, `AbsenceReport`.
- Produces: `/api/v1/parent/tracking/active-trip`, `/api/v1/parent/tracking/history`, `/api/v1/parent/tracking/trips/{id}`, `/api/v1/parent/attendance/analytics`.

- [ ] **Step 1:** Write failing `tests/Feature/TrackingAndAnalyticsTest.php` testing active trip stations, history period filtering (`all|morning|return`), trip `#9042` replay waypoints & QR audit logs, and monthly attendance analytics (`completed, absences, missed_qr, on_time_rate, weekly_regularity`).
- [ ] **Step 2:** Run `php artisan test tests/Feature/TrackingAndAnalyticsTest.php` -> confirm FAIL.
- [ ] **Step 3:** Implement `TrackingController` and `AttendanceController::analytics`.
- [ ] **Step 4:** Run `php artisan test tests/Feature/TrackingAndAnalyticsTest.php` -> Expected: PASS.

---

### Task 5: Profile, Preferences, Alerts, Notifications, Bulletins, Support & Demo Seeder

**Files:**
- Create: `app/Http/Controllers/Api/V1/SettingsController.php`, `app/Http/Controllers/Api/V1/NotificationController.php`, `app/Http/Controllers/Api/V1/BulletinSupportController.php`, `database/seeders/ParentPortalDemoSeeder.php`
- Modify: `database/seeders/DatabaseSeeder.php`, `routes/api.php`
- Test: `tests/Feature/ParentPortalExtrasTest.php`

**Interfaces:**
- Consumes: `User`, `SafetyNotification`, `SchoolBulletin`, `SupportMessage`, `TransitAlertSetting`.
- Produces: Complete seeded database + `/parent/profile`, `/parent/settings/preferences`, `/parent/settings/alerts`, `/parent/notifications/*`, `/parent/bulletins`, `/parent/support/messages`, `/parent/emergency-contacts`.

- [ ] **Step 1:** Write failing `tests/Feature/ParentPortalExtrasTest.php` testing profile update + `users.email` sync, preference sync (`theme_palette`, `brightness_mode`, `locale`), alert settings update, notification read/read-all, trilingual bulletins (`Accept-Language: ar|en|fr`), support message creation (`201`), and `ParentPortalDemoSeeder` seeding `k.mansouri@mail.dz` with 3 children (`HB-304`, `HB-208`, `HB-105`), active trips, history trips, bulletins, and notifications.
- [ ] **Step 2:** Run `php artisan test tests/Feature/ParentPortalExtrasTest.php` -> confirm FAIL.
- [ ] **Step 3:** Implement `SettingsController`, `NotificationController`, `BulletinSupportController`, and `ParentPortalDemoSeeder`.
- [ ] **Step 4:** Run `php artisan db:seed --force` and full `php artisan test` -> Expected: ALL PHPUnit tests PASS.

---

## Phase B — Flutter Parent App (`/Users/bmg/Documents/ui/hanna_bus_parent`)

### Task 6: Scaffold Flutter App + `HannaTokens` (84 Contrast Checks) + `HannaTypography` + `HannaMotion`

**Files:**
- Create: `/Users/bmg/Documents/ui/hanna_bus_parent/` (`flutter create`), `pubspec.yaml`, `assets/images/hanna-bus-logo.png`
- Create: `lib/core/theme/hanna_tokens.dart`, `lib/core/theme/hanna_typography.dart`, `lib/core/motion/hanna_motion.dart`
- Test: `test/theme_contrast_test.dart`, `test/motion_test.dart`

**Interfaces:**
- Produces: `HannaPaletteKind`, `HannaTokens.resolve(HannaPaletteKind, Brightness)`, `HannaTypography.textTheme(...)`, `HannaCurves`, `HannaMotion`, `HannaTactilePress`, `HannaPageRoute`.

- [ ] **Step 1:** Create Flutter project with `flutter create --org com.hannabus --project-name hanna_bus_parent /Users/bmg/Documents/ui/hanna_bus_parent`, copy `hanna-bus-logo.png`, add `http`, `phosphor_flutter`, `google_fonts`, `qr_flutter`, `shared_preferences`, `flutter_localizations` to `pubspec.yaml`, and run `flutter pub get`.
- [ ] **Step 2:** Write `test/theme_contrast_test.dart` checking all **84** semantic contrast pairs across the 6 palette-mode combinations (Review Focus #1) and `test/motion_test.dart` checking `HannaCurves`, `HannaMotion.resolve` returning `Duration.zero` under `MediaQuery(disableAnimations: true)`, and `HannaTactilePress` scale behavior.
- [ ] **Step 3:** Run `flutter test test/theme_contrast_test.dart test/motion_test.dart` -> confirm FAIL.
- [ ] **Step 4:** Implement `hanna_tokens.dart`, `hanna_typography.dart`, and `hanna_motion.dart`.
- [ ] **Step 5:** Run `flutter test test/theme_contrast_test.dart test/motion_test.dart` -> Expected: PASS.

---

### Task 7: Localization (`AppStrings`), Data Models, `HannaApiClient` + Offline Fallback & `AppStateScope`

**Files:**
- Create: `lib/core/l10n/app_strings.dart`, `lib/core/network/hanna_api_client.dart`, `lib/core/state/models.dart`, `lib/core/state/demo_seed.dart`, `lib/core/state/app_state.dart`
- Test: `test/api_client_fallback_test.dart`, `test/app_state_test.dart`

**Interfaces:**
- Produces: `AppStrings.of(AppLanguage)`, `HannaApiClient` (using `http.Client` injection for deterministic unit testing), `AppStateScope` (`SettingsController`, `AuthController`, `ChildrenController`, `TelemetryController`).

- [ ] **Step 1:** Write `test/api_client_fallback_test.dart` using `http.testing.MockClient` + throwing `SocketException` to verify live API login/child parsing AND automatic offline demo fallback (`isOfflineDemo == true`, Review Focus #2), plus `test/app_state_test.dart` verifying preference persistence in `SharedPreferences.setMockInitialValues({})` and in-memory auth token reset.
- [ ] **Step 2:** Run `flutter test test/api_client_fallback_test.dart test/app_state_test.dart` -> confirm FAIL.
- [ ] **Step 3:** Implement `app_strings.dart` (full EN/AR/FR strings, zero emoji/em-dash), `models.dart`, `demo_seed.dart`, `hanna_api_client.dart`, and `app_state.dart`.
- [ ] **Step 4:** Run `flutter test test/api_client_fallback_test.dart test/app_state_test.dart` -> Expected: PASS.

---

### Task 8: Core Shared UI System (`HannaBackground`, `HannaHeroCard`, `HannaFloatingNavBar`, Inputs & Pickers)

**Files:**
- Create: `lib/core/widgets/hanna_background.dart`, `lib/core/widgets/hanna_hero_card.dart`, `lib/core/widgets/hanna_floating_nav_bar.dart`, `lib/core/widgets/hanna_header.dart`, `lib/core/widgets/hanna_button.dart`, `lib/core/widgets/hanna_text_field.dart`, `lib/core/widgets/hanna_picker_sheet.dart`, `lib/core/widgets/hanna_badge.dart`
- Test: `test/core_widgets_test.dart`

**Interfaces:**
- Produces: All reusable design system widgets supporting all 8 states, RTL mirroring, and `CustomPainter` abstract shapes.

- [ ] **Step 1:** Write `test/core_widgets_test.dart` testing `HannaButton` (enabled/disabled/loading/destructive), `HannaTextField` (focus/error/password toggle), `HannaPickerSheet` opening & selecting without native dropdown, and `HannaFloatingNavBar` LTR vs RTL order & active tab tap.
- [ ] **Step 2:** Run `flutter test test/core_widgets_test.dart` -> confirm FAIL.
- [ ] **Step 3:** Implement all shared widgets faithfully matching the FigCraft proportions and Emil Kowalski transitions.
- [ ] **Step 4:** Run `flutter test test/core_widgets_test.dart` -> Expected: PASS.

---

### Task 9: Module 01 — Auth & Onboarding (All 7 Screens)

**Files:**
- Create: `lib/features/auth/screens/welcome_screen.dart`, `sign_in_screen.dart`, `sign_up_screen.dart`, `forgot_password_screen.dart`, `otp_verification_screen.dart`, `reset_password_screen.dart`, `auth_success_screen.dart`
- Test: `test/auth_flow_test.dart`

- [ ] **Step 1:** Write `test/auth_flow_test.dart` covering Welcome tilted card stack + skip/continue, Sign In validation + quick demo fill / Social Demo Sign-In, Sign Up flow, and Forgot Password -> 6-digit OTP (`482910`) -> Reset Password live strength checks -> Auth Success -> `HomeShell`.
- [ ] **Step 2:** Run `flutter test test/auth_flow_test.dart` -> confirm FAIL.
- [ ] **Step 3:** Implement all 7 auth screens with orbital halos, tilted photo/logo frames, and smooth `HannaPageRoute` transitions.
- [ ] **Step 4:** Run `flutter test test/auth_flow_test.dart` -> Expected: PASS.

---

### Task 10: Module 06 — HomeShell & Home Dashboard Screens (5 Screens)

**Files:**
- Create: `lib/features/home/screens/home_shell.dart`, `home_dashboard_screen.dart`, `notifications_screen.dart`, `quick_qr_pass_screen.dart`, `updates_support_screen.dart`
- Test: `test/home_module_test.dart`

- [ ] **Step 1:** Write `test/home_module_test.dart` covering Morning Live Hero vs Afternoon All-Safe Hero toggle, Quick Actions navigation (`QR Pass`, `Absence`, `Schedule`, `SOS`), `NotificationsScreen` mark-all-read & filter chips, `QuickQrPassScreen` `QrImageView` rendering + offline pass save, and `UpdatesSupportScreen` sending a support message.
- [ ] **Step 2:** Run `flutter test test/home_module_test.dart` -> confirm FAIL.
- [ ] **Step 3:** Implement `home_shell.dart` (hosting `HomeFloatingNavBar` across the 4 primary tabs) and the 4 Home screens.
- [ ] **Step 4:** Run `flutter test test/home_module_test.dart` -> Expected: PASS.

---

### Task 11: Module 05 — Live & History Tracking (6 Screens + CustomPainters)

**Files:**
- Create: `lib/features/tracking/widgets/stylized_route_map.dart`, `attendance_bar_chart.dart`
- Create: `lib/features/tracking/screens/live_bus_map_screen.dart`, `live_route_timeline_screen.dart`, `live_boarding_alerts_screen.dart`, `trip_history_screen.dart`, `trip_history_detail_screen.dart`, `attendance_analytics_screen.dart`
- Test: `test/tracking_module_test.dart`

- [ ] **Step 1:** Write `test/tracking_module_test.dart` covering `LiveBusMapScreen` child switch, `LiveRouteTimelineScreen` 5-stop progress, `LiveBoardingAlertsScreen`, `TripHistoryScreen` period filter -> `TripHistoryDetailScreen` replay scrubber (`00:00..24:10`), and `AttendanceAnalyticsScreen` weekly bar chart.
- [ ] **Step 2:** Run `flutter test test/tracking_module_test.dart` -> confirm FAIL.
- [ ] **Step 3:** Implement `StylizedRouteMap`, `AttendanceBarChart`, and all 6 tracking screens.
- [ ] **Step 4:** Run `flutter test test/tracking_module_test.dart` -> Expected: PASS.

---

### Task 12: Module 04 — My Children (List/Filter, Add/Edit + School Code, Manage/Delete, 4-Tab Dossier)

**Files:**
- Create: `lib/features/children/screens/children_list_screen.dart`, `add_edit_child_screen.dart`, `manage_child_screen.dart`, `child_dossier_screen.dart`
- Test: `test/children_module_test.dart`

- [ ] **Step 1:** Write `test/children_module_test.dart` covering search & status filter chips (`All`, `On Bus`, `At School`, `At Home`), adding a child + linking via `student_code`, editing a child, pausing today's ride, ID-guarded child deletion (`HB-304`, Review Focus #3), and navigating all 4 Dossier tabs (`Personal QR`, `Educative`, `Medical`, `Schedule` Sun–Thu).
- [ ] **Step 2:** Run `flutter test test/children_module_test.dart` -> confirm FAIL.
- [ ] **Step 3:** Implement all 4 children screens.
- [ ] **Step 4:** Run `flutter test test/children_module_test.dart` -> Expected: PASS.

---

### Task 13: Modules 02 & 03 — Profile, Emergency Dispatch, All 6 Settings Screens & `app.dart` + RTL/Overflow Tests

**Files:**
- Create: `lib/features/profile/screens/profile_hub_screen.dart`, `edit_profile_screen.dart`, `emergency_dispatch_screen.dart`
- Create: `lib/features/settings/screens/settings_hub_screen.dart`, `theme_appearance_screen.dart`, `notifications_settings_screen.dart`, `language_screen.dart`, `terms_privacy_screen.dart`, `account_actions_screen.dart`
- Create: `lib/app.dart`, `lib/main.dart`
- Test: `test/profile_settings_test.dart`, `test/rtl_and_overflow_test.dart`

- [ ] **Step 1:** Write `test/profile_settings_test.dart` (Profile -> Edit Info, Emergency SOS sheet, Settings -> Theme/Dark Mode live switch, Language AR/EN/FR switch, Notifications toggles, Terms/Privacy tabs, Logout & typed `DELETE`/`حذف` confirmation guard — Review Focus #3) and `test/rtl_and_overflow_test.dart` (renders key screens across EN & AR at `360x780` and `1.25x` text scale with zero overflow — Review Focus #4).
- [ ] **Step 2:** Run `flutter test test/profile_settings_test.dart test/rtl_and_overflow_test.dart` -> confirm FAIL.
- [ ] **Step 3:** Implement all Profile, Settings, `app.dart`, and `main.dart`.
- [ ] **Step 4:** Run `flutter test test/profile_settings_test.dart test/rtl_and_overflow_test.dart` -> Expected: PASS.

---

### Task 14: End-to-End Full-Stack Verification (`php artisan test`, `flutter analyze`, `flutter test`, Live API Smoke)

**Files:**
- Verify: `/Users/bmg/Documents/ui/backend` and `/Users/bmg/Documents/ui/hanna_bus_parent`

- [ ] **Step 1:** Run `cd /Users/bmg/Documents/ui/backend && php artisan test` -> Expected: 100% PASS.
- [ ] **Step 2:** Start temporary `php artisan serve --port=8099`, run `curl` smoke checks (`GET /api/v1/health`, `POST /api/v1/auth/login` with `k.mansouri@mail.dz`, `GET /api/v1/parent/children`, `GET /api/v1/parent/tracking/active-trip`, `GET /api/v1/parent/tracking/history`, `GET /api/v1/parent/bulletins`), then kill the temporary server.
- [ ] **Step 3:** Run `cd /Users/bmg/Documents/ui/hanna_bus_parent && flutter analyze && flutter test` -> Expected: 0 analyzer issues, 100% tests PASS.
- [ ] **Step 4:** Update `AGENTS.md` cleanly with backend/frontend paths and exact run/test commands.

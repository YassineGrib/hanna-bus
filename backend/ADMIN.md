# Hanna Bus Admin

Back office for the Hanna Bus school transport system, built with Filament v5.

- URL: `/admin` (for example http://127.0.0.1:8000/admin after `php artisan serve`)
- Local demo login: `admin@hanna.dz` / `Password123!` (seeded by `AdminDemoSeeder` only when the app environment is `local` or `testing`; never seeded in production)
- Access: only users with `users.role = admin`. Parents and drivers get 403.
- Languages: English and Arabic (RTL). Use the user menu to switch; the choice is saved on the admin user.

## What it manages

| Section | Purpose |
|---|---|
| Dashboard | buses in service, trips en route, students on a bus, open SOS alerts, parents and drivers, today's trips |
| Daily planning | pick a date, carry over the previous day's assignments, generate that date's trips |
| Daily assignments | which driver drives which bus on a date (one bus per driver per day) |
| Buses | fleet, status, inspections and assignments |
| Drivers | driver accounts and profiles |
| Parents | parent accounts and their children |
| Students | children, parent link, bus, stop, medical data, QR code |
| Trips | trips of a date, stations, boarding events, cancel a scheduled trip |
| Safety alerts | SOS alerts from drivers, map link, close action |
| School bulletins | announcements in English, Arabic and French |
| Support messages | read-only threads between parents and drivers |

## Daily routine

1. Open Daily planning and choose tomorrow.
2. Press "Carry over yesterday's assignments" (or add assignments by hand in Daily assignments).
3. Press "Generate trips". The same can run from the command line:
   `php artisan hanna:generate-trips --date=YYYY-MM-DD --carry-assignments`
   (the scheduler runs `hanna:generate-trips` every day at 00:05).

## Tests

`php artisan test --filter=Admin` runs the admin feature tests (Livewire). The whole suite is `php artisan test`.

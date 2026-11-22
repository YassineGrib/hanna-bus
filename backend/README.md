# Hanna Bus backend

Laravel 13 API (`/api/v1`, Sanctum) and the Filament 5 admin dashboard (`/admin`) for the Hanna Bus school transport system. See the [root README](../README.md) for the whole project.

## Quick start

```bash
composer install
cp .env.example .env && php artisan key:generate
php artisan migrate --seed      # demo data, local and testing environments only
php artisan serve
php artisan test
```

## Where things are

| Path | What |
|---|---|
| `routes/api.php` | Parent, driver and admin API routes (`role:` middleware, login throttling) |
| `app/Http/Controllers/Api/V1` | API controllers |
| `app/Support` | Domain services: trip generation, assignment carry over, driver data minimisation |
| `app/Filament` | Admin resources, pages and widgets |
| `resources/views/filament` | Admin views: background, daily planning, station map picker |
| `lang/{en,ar}` | Admin translations |
| `tests` | PHPUnit feature and unit tests |

## Related docs

- [`ADMIN.md`](ADMIN.md): what the dashboard manages and how to sign in locally.
- [`../docs/driver-api-contract.md`](../docs/driver-api-contract.md): the API contract between the apps and the server.

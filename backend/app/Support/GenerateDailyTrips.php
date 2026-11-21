<?php

namespace App\Support;

use App\Models\ActiveTrip;
use App\Models\Bus;
use App\Models\BusAssignment;
use App\Models\Route;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

class GenerateDailyTrips
{
    /** @return list<array{bus_number: string, period: string}> */
    public function missingRoutes(CarbonImmutable $date): array
    {
        $missing = [];
        foreach (['morning' => true, 'return' => false] as $period => $morning) {
            $buses = Bus::query()
                ->whereHas('assignments', fn (Builder $query): Builder => $query->whereDate('date', $date))
                ->whereDoesntHave('routes', fn (Builder $query): Builder => $query->where('period', $period)->where('is_active', true))
                ->whereDoesntHave('trips', fn (Builder $query): Builder => $query->where('is_morning', $morning)->whereDate('service_date', '<=', $date))
                ->orderBy('number')->get();
            foreach ($buses as $bus) {
                $missing[] = ['bus_number' => $bus->number, 'period' => $period];
            }
        }

        return array_values($missing);
    }

    /** @return list<string> */
    public function warnings(CarbonImmutable $date): array
    {
        return array_map(fn (array $missing): string => __('admin.missing_route', [
            'bus' => $missing['bus_number'], 'period' => __('admin.'.$missing['period']),
        ]), $this->missingRoutes($date));
    }

    /** @return array{created: int, skipped: int} */
    public function handle(CarbonImmutable $date): array
    {
        return DB::transaction(function () use ($date) {
            $counts = ['created' => 0, 'skipped' => 0];
            $assignments = BusAssignment::with(['bus.routes.stations', 'driver'])
                ->whereDate('date', $date)->orderBy('id')->get();

            foreach ($assignments as $assignment) {
                foreach (['am' => true, 'return' => false] as $period => $morning) {
                    $existing = ActiveTrip::where('bus_id', $assignment->bus_id)
                        ->whereDate('service_date', $date)->where('is_morning', $morning)->exists();
                    if ($existing) {
                        $counts['skipped']++;

                        continue;
                    }

                    $route = $assignment->bus->routes->first(fn (Route $route): bool => $route->is_active
                        && $route->period === ($morning ? 'morning' : 'return'));
                    $template = $route ?? ActiveTrip::with('stations')->where('bus_id', $assignment->bus_id)
                        ->where('is_morning', $morning)->whereDate('service_date', '<', $date)
                        ->orderByDesc('service_date')->orderByDesc('scheduled_start')->orderByDesc('id')->first();
                    if (! $template) {
                        $counts['skipped']++;

                        continue;
                    }

                    $trip = $route ? new ActiveTrip : $template->replicate();
                    if ($route) {
                        $trip->fill([
                            'route_name' => $route->name,
                            'is_morning' => $morning,
                            'route_points_json' => $route->route_points_json,
                            'distance_km' => 0,
                        ]);
                    }
                    $trip->fill([
                        'id' => 'trip-'.$assignment->bus->number.'-'.$period.'-'.$date->format('Ymd'),
                        'service_date' => $date->toDateString(),
                        'scheduled_start' => $template->scheduled_start
                            ? $date->setTimeFromTimeString($route ? $route->scheduled_start : $template->scheduled_start->format('H:i:s')) : null,
                        'driver_id' => $assignment->driver_id,
                        'driver_name' => $assignment->driver->name,
                        'driver_phone' => $assignment->driver->phone ?? '',
                        'bus_id' => $assignment->bus_id,
                        'bus_number' => $assignment->bus->number,
                        'vehicle_model' => $assignment->bus->vehicle_model,
                        'plate_number' => $assignment->bus->plate_number,
                        'capacity' => $assignment->bus->capacity,
                        'status' => 'scheduled',
                        'progress' => 0,
                        'lat' => null,
                        'lng' => null,
                        'heading' => null,
                        'last_location_at' => null,
                        'speed_kmh' => 0,
                        'started_at' => null,
                        'ended_at' => null,
                        'delay_minutes' => 0,
                        'onboard_count' => 0,
                        'eta_minutes' => 0,
                        'current_street' => '',
                    ])->save();

                    foreach ($template->stations as $station) {
                        $trip->stations()->create([
                            ...$station->only(['sort_order', 'name_en', 'name_ar', 'name_fr', 'subtitle_en',
                                'subtitle_ar', 'subtitle_fr', 'scheduled_time', 'lat', 'lng']),
                            'status' => 'upcoming',
                        ]);
                    }

                    $counts['created']++;
                }
            }

            return $counts;
        });
    }
}

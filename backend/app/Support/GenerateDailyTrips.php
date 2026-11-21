<?php

namespace App\Support;

use App\Models\ActiveTrip;
use App\Models\BusAssignment;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;

class GenerateDailyTrips
{
    /** @return array{created: int, skipped: int} */
    public function handle(CarbonImmutable $date): array
    {
        return DB::transaction(function () use ($date) {
            $counts = ['created' => 0, 'skipped' => 0];
            $assignments = BusAssignment::with(['bus', 'driver'])
                ->whereDate('date', $date)->orderBy('id')->get();

            foreach ($assignments as $assignment) {
                foreach (['am' => true, 'return' => false] as $period => $morning) {
                    $existing = ActiveTrip::where('bus_id', $assignment->bus_id)
                        ->whereDate('service_date', $date)->where('is_morning', $morning)->exists();
                    if ($existing) {
                        $counts['skipped']++;

                        continue;
                    }

                    $template = ActiveTrip::with('stations')->where('bus_id', $assignment->bus_id)
                        ->where('is_morning', $morning)->whereDate('service_date', '<', $date)
                        ->orderByDesc('service_date')->orderByDesc('scheduled_start')->orderByDesc('id')->first();
                    if (! $template) {
                        $counts['skipped']++;

                        continue;
                    }

                    $trip = $template->replicate();
                    $trip->fill([
                        'id' => 'trip-'.$assignment->bus->number.'-'.$period.'-'.$date->format('Ymd'),
                        'service_date' => $date->toDateString(),
                        'scheduled_start' => $template->scheduled_start
                            ? $date->setTimeFromTimeString($template->scheduled_start->format('H:i:s')) : null,
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
                        $copy = $station->replicate();
                        $copy->fill(['trip_id' => $trip->id, 'status' => 'upcoming'])->save();
                    }

                    $counts['created']++;
                }
            }

            return $counts;
        });
    }
}

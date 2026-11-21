<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ActiveTrip;
use App\Models\BusAssignment;
use App\Models\BusInspection;
use App\Models\TripHistory;
use App\Support\DriverPortal;
use App\Support\Trilingual;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class DriverTripController extends Controller
{
    public function today(Request $request): JsonResponse
    {
        $lang = Trilingual::lang($request);
        $trips = $request->user()->driverTrips()->with('stations')
            ->whereDate('service_date', today())->get();

        return response()->json($trips->map(function ($trip) use ($lang) {
            $children = DriverPortal::children($trip);

            return ['id' => $trip->id, 'period' => $trip->is_morning ? 'morning' : 'return',
                'route_name' => $trip->route_name, 'bus_number' => $trip->bus_number,
                'status' => $trip->status, 'scheduled_start' => $trip->scheduled_start?->toISOString(),
                'stations' => $trip->stations->map(fn ($s) => [
                    'id' => $s->id, 'sort_order' => $s->sort_order,
                    'name' => Trilingual::pick($lang, $s->name_en, $s->name_ar, $s->name_fr),
                    'scheduled_time' => $s->scheduled_time, 'status' => $s->status,
                    'lat' => $s->lat, 'lng' => $s->lng,
                    'students' => $children->filter(fn ($c) => DriverPortal::station($trip, $c)?->id === $s->id)
                        ->map(fn ($c) => ['child_id' => $c->id,
                            ...Arr::only(DriverPortal::childObject($c), ['name', 'student_code', 'absent'])])->values(),
                ])->values()];
        }));
    }

    public function start(Request $request, string $trip): JsonResponse
    {
        $owned = DriverPortal::trip($request, $trip);

        return DB::transaction(function () use ($request, $owned) {
            // Serialize trip starts for this driver as well as locking this trip.
            $request->user()->newQuery()->whereKey($request->user()->id)->lockForUpdate()->first();
            $owned->refresh();
            abort_if($request->user()->driverTrips()->where('status', 'en_route')->exists() || $owned->status !== 'scheduled', 409,
                Trilingual::pick(Trilingual::lang($request), 'A trip is already active or cannot be started.', 'الرحلة نشطة أو لا يمكن بدؤها.', 'Un trajet est actif ou ne peut pas démarrer.'));
            $assignment = BusAssignment::where('driver_id', $request->user()->id)->whereDate('date', today())->first();
            $passed = $assignment && $assignment->bus_id === $owned->bus_id && BusInspection::where('driver_id', $request->user()->id)
                ->where('bus_id', $assignment->bus_id)->whereDate('date', today())->where('passed', true)->exists();
            if (! $passed) {
                throw ValidationException::withMessages(['inspection' => Trilingual::pick(Trilingual::lang($request),
                    'A passed inspection for the current bus today is required.', 'يلزم فحص ناجح لحافلة اليوم.', 'Une inspection réussie du bus actuel est requise aujourd’hui.')]);
            }
            $owned->update(['status' => 'en_route', 'started_at' => now()]);

            return response()->json($owned);
        });
    }

    public function location(Request $request, string $trip): JsonResponse
    {
        $owned = DriverPortal::trip($request, $trip);
        $v = $request->validate(['lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
            'speed_kmh' => ['nullable', 'numeric', 'min:0'], 'heading' => ['nullable', 'numeric', 'between:0,360']]);

        return DB::transaction(function () use ($request, $owned, $v) {
            $owned = ActiveTrip::where('driver_id', $request->user()->id)->whereKey($owned->id)->lockForUpdate()->firstOrFail();
            abort_unless($owned->status === 'en_route', 409,
                Trilingual::pick(Trilingual::lang($request), 'Trip is not en route.', 'الرحلة ليست جارية.', 'Le trajet n’est pas en cours.'));
            $points = $owned->route_points_json ?? [];
            $progress = $owned->progress;
            if (count($points) > 0) {
                $nearest = 0;
                $distance = INF;
                foreach ($points as $i => [$lat, $lng]) {
                    $d = ($lat - $v['lat']) ** 2 + (($lng - $v['lng']) * cos(deg2rad($v['lat']))) ** 2;
                    if ($d < $distance) {
                        $distance = $d;
                        $nearest = $i;
                    }
                }
                $progress = count($points) > 1 ? $nearest / (count($points) - 1) : 0;
            }
            $owned->update(['lat' => $v['lat'], 'lng' => $v['lng'], 'heading' => $v['heading'] ?? null,
                'speed_kmh' => $v['speed_kmh'] ?? $owned->speed_kmh, 'last_location_at' => now(), 'progress' => $progress]);
            $owned->locationPoints()->create([...$v, 'recorded_at' => now()]);

            return response()->json(['ok' => true]);
        });
    }

    public function arrive(Request $request, string $trip, string $station): JsonResponse
    {
        $owned = DriverPortal::trip($request, $trip);
        $stop = $owned->stations()->findOrFail($station);

        return DB::transaction(function () use ($request, $owned, $stop) {
            $owned = ActiveTrip::where('driver_id', $request->user()->id)->whereKey($owned->id)->lockForUpdate()->firstOrFail();
            DriverPortal::requireEnRoute($request, $owned);
            $owned->stations()->where('sort_order', '<', $stop->sort_order)->update(['status' => 'completed']);
            $owned->stations()->where('sort_order', '>', $stop->sort_order)->update(['status' => 'upcoming']);
            $stop->update(['status' => 'current']);
            DriverPortal::notify(DriverPortal::children($owned)->filter(fn ($c) => DriverPortal::station($owned, $c)?->id === $stop->id),
                ['The bus has arrived at your child’s stop.', 'وصلت الحافلة إلى محطة طفلك.', 'Le bus est arrivé à l’arrêt de votre enfant.']);

            return response()->json($stop);
        });
    }

    public function delay(Request $request, string $trip): JsonResponse
    {
        $owned = DriverPortal::trip($request, $trip);
        DriverPortal::requireEnRoute($request, $owned);
        $v = $request->validate(['minutes' => ['required', 'integer', 'between:1,120'],
            'reason' => ['required', 'in:traffic,breakdown,weather,other']]);

        return DB::transaction(function () use ($request, $owned, $v) {
            $owned = ActiveTrip::where('driver_id', $request->user()->id)->whereKey($owned->id)->lockForUpdate()->firstOrFail();
            DriverPortal::requireEnRoute($request, $owned);
            $owned->increment('eta_minutes', $v['minutes']);
            $owned->increment('delay_minutes', $v['minutes']);
            $n = DriverPortal::notify(DriverPortal::children($owned), [
                "The bus is delayed by {$v['minutes']} minutes.", "تأخرت الحافلة {$v['minutes']} دقيقة.", "Le bus a {$v['minutes']} minutes de retard."]);

            return response()->json(['notified' => $n]);
        });
    }

    public function end(Request $request, string $trip): JsonResponse
    {
        $owned = DriverPortal::trip($request, $trip);

        return DB::transaction(function () use ($owned, $request) {
            $owned = ActiveTrip::where('driver_id', $request->user()->id)->whereKey($owned->id)->lockForUpdate()->firstOrFail();
            if ($owned->status === 'completed') {
                return response()->json($owned);
            }
            DriverPortal::requireEnRoute($request, $owned);
            $request->validate(['safety_walk_confirmed' => ['required', 'boolean', 'accepted']]);
            $end = now();
            $start = $owned->started_at ?? $end;
            $events = $owned->boardingEvents()->with('child')->get();
            foreach ($events->where('type', 'boarded')->unique('child_id') as $event) {
                $history = TripHistory::firstOrNew(['trip_id' => $owned->id, 'child_id' => $event->child_id]);
                if (! $history->exists) {
                    $history->id = (string) Str::uuid();
                }
                $history->fill([
                    'bus_number' => $owned->bus_number, 'period' => $owned->is_morning ? 'morning' : 'return',
                    'trip_date' => $start->toDateString(), 'date_group_en' => $start->toDateString(),
                    'date_group_ar' => $start->toDateString(), 'date_group_fr' => $start->toDateString(),
                    'departure_time' => $start->format('H:i'), 'arrival_time' => $end->format('H:i'),
                    'duration_minutes' => (int) $start->diffInMinutes($end), 'distance_km' => $owned->distance_km,
                    'avg_speed_kmh' => (int) ($owned->locationPoints()->avg('speed_kmh') ?? $owned->speed_kmh),
                    'status_code' => $owned->delay_minutes > 0 ? 'delayed' : 'completed', 'delay_minutes' => $owned->delay_minutes,
                    'driver_name' => $request->user()->name, 'driver_rating' => $request->user()->driverProfile?->rating ?? 4.9,
                    'vehicle_model' => $owned->vehicle_model, 'route_points_json' => $owned->route_points_json,
                    'qr_audit_json' => $events->where('child_id', $event->child_id)->map(fn ($e) => [
                        'time' => $e->recorded_at->toISOString(), 'event' => $e->type, 'verifier' => $request->user()->name])->values()->all(),
                ])->save();
            }
            $owned->update(['status' => 'completed', 'ended_at' => $end]);
            $request->user()->driverProfile()->increment('trips_count');

            return response()->json($owned);
        });
    }
}

<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\TripLocationPoint;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DriverTelemetryController extends Controller
{
    public function today(Request $request): JsonResponse
    {
        $start = today();
        $end = now();
        $points = TripLocationPoint::whereHas('trip', fn ($q) => $q->where('driver_id', $request->user()->id))
            ->whereBetween('recorded_at', [$start, $end])->orderBy('recorded_at')->orderBy('id')->get();
        $trips = $request->user()->driverTrips()->whereNotNull('started_at')->where('started_at', '<=', $end)
            ->where(fn ($q) => $q->where('ended_at', '>=', $start)
                ->orWhere(fn ($q) => $q->whereNull('ended_at')->where('status', 'en_route')))->get();
        $distance = 0;
        // Never connect samples belonging to different trips or different days.
        foreach ($points->groupBy('trip_id') as $samples) {
            $previous = null;
            foreach ($samples as $point) {
                if ($previous) {
                    $lat = deg2rad($point->lat - $previous->lat);
                    $lng = deg2rad($point->lng - $previous->lng);
                    $a = sin($lat / 2) ** 2 + cos(deg2rad($previous->lat)) * cos(deg2rad($point->lat)) * sin($lng / 2) ** 2;
                    $distance += 6371 * 2 * asin(sqrt(min(1, $a)));
                }
                $previous = $point;
            }
        }
        $minutes = $trips->sum(fn ($trip) => max(0,
            $trip->started_at->max($start)->diffInMinutes(($trip->ended_at ?? $end)->min($end), false)));

        return response()->json([
            'max_speed_kmh' => (float) ($points->max('speed_kmh') ?? 0),
            'avg_speed_kmh' => round((float) ($points->whereNotNull('speed_kmh')->avg('speed_kmh') ?? 0), 2),
            'speeding_events' => $points->where('speed_kmh', '>', 60)->count(),
            'distance_km' => round($distance, 2), 'driving_minutes' => (int) floor($minutes),
            'trips' => $trips->pluck('id')->merge($points->pluck('trip_id'))->unique()->count(),
        ]);
    }
}

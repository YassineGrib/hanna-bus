<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\BoardingEvent;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;

class DriverHistoryController extends Controller
{
    private function trips(Request $request): \Illuminate\Database\Eloquent\Collection
    {
        return $request->user()->driverTrips()->withCount(['boardingEvents as students' => fn ($q) => $q->where('type', 'boarded')])
            ->where('status', 'completed')->orderByDesc('ended_at')->get();
    }

    private function rate(Collection $trips): float
    {
        return $trips->isEmpty() ? 100 : round(100 * $trips->where('delay_minutes', 0)->count() / $trips->count(), 1);
    }

    public function history(Request $request): JsonResponse
    {
        $v = $request->validate(['period' => ['sometimes', 'in:week,month,all']]);
        $period = $v['period'] ?? 'all';
        $trips = $this->trips($request);
        if ($period !== 'all') {
            $start = $period === 'week' ? now()->startOfWeek(Carbon::SUNDAY) : now()->startOfMonth();
            $trips = $trips->filter(fn ($t) => $t->ended_at && $t->ended_at->gte($start));
        }

        return response()->json(['totals' => ['trips' => $trips->count(), 'km' => $trips->sum('distance_km'), 'on_time_rate' => $this->rate($trips)],
            'trips' => $trips->map(fn ($t) => ['id' => $t->id, 'date' => ($t->service_date ?? $t->ended_at)?->toDateString(),
                'period' => $t->is_morning ? 'morning' : 'return', 'route_name' => $t->route_name,
                'departure_time' => $t->started_at?->toISOString(), 'arrival_time' => $t->ended_at?->toISOString(),
                'students' => $t->students, 'status_code' => $t->delay_minutes > 0 ? 'delayed' : 'completed',
                'delay_minutes' => $t->delay_minutes])->values()]);
    }

    public function stats(Request $request): JsonResponse
    {
        $trips = $this->trips($request);
        $month = $trips->filter(fn ($t) => $t->ended_at?->isCurrentMonth() && $t->ended_at->year === now()->year);
        $profile = $request->user()->driverProfile;
        $weekdays = collect(range(0, 4))->map(function ($day) use ($trips) {
            return ['weekday' => now()->startOfWeek(Carbon::SUNDAY)->addDays($day)->format('l'),
                'trips' => $trips->filter(fn ($t) => ($t->service_date ?? $t->ended_at)?->dayOfWeek === $day)->count()];
        });

        return response()->json(['rating' => $profile?->rating ?? 4.9, 'trips_count' => $profile?->trips_count ?? 0,
            'on_time_rate' => $this->rate($trips), 'trips_this_month' => $month->count(), 'km_this_month' => $month->sum('distance_km'),
            'safe_scans' => BoardingEvent::where('driver_id', $request->user()->id)->where('method', 'qr')->count(),
            'per_weekday' => $weekdays]);
    }
}

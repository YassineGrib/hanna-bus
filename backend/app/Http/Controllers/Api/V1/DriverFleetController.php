<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ActiveTrip;
use App\Models\Bus;
use App\Models\BusAssignment;
use App\Models\BusInspection;
use App\Support\Trilingual;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DriverFleetController extends Controller
{
    private function currentBus(Request $request): ?Bus
    {
        return BusAssignment::with('bus')->where('driver_id', $request->user()->id)
            ->whereDate('date', today())->first()?->bus;
    }

    public function profile(Request $request): JsonResponse
    {
        $profile = $request->user()->driverProfile;

        return response()->json(['user' => $request->user(), 'license_number' => $profile?->license_number,
            'rating' => $profile?->rating ?? 4.9, 'trips_count' => $profile?->trips_count ?? 0,
            'current_bus' => $this->currentBus($request)]);
    }

    public function buses(Request $request): JsonResponse
    {
        $current = $this->currentBus($request)?->id;

        return response()->json(Bus::orderBy('number')->get()->map(fn ($bus) => [
            ...$bus->only(['id', 'number', 'line_name', 'plate_number', 'vehicle_model', 'capacity', 'status']),
            'is_current' => $bus->id === $current,
        ]));
    }

    public function rotation(Request $request): JsonResponse
    {
        $v = $request->validate(['week_of' => ['sometimes', 'date_format:Y-m-d']]);
        $start = Carbon::parse($v['week_of'] ?? today())->startOfWeek(Carbon::SUNDAY);
        $assignments = BusAssignment::with('bus')->where('driver_id', $request->user()->id)
            ->whereBetween('date', [$start->toDateString(), $start->copy()->addDays(4)->toDateString()])->get();
        $days = [];
        for ($i = 0; $i < 5; $i++) {
            $date = $start->copy()->addDays($i);
            $assignment = $assignments->first(fn ($a) => $a->date->isSameDay($date));
            $days[] = ['date' => $date->toDateString(), 'weekday' => $date->format('l'),
                'bus_number' => $assignment?->bus?->number, 'is_today' => $date->isToday()];
        }

        return response()->json(['days' => $days]);
    }

    public function updateBus(Request $request): JsonResponse
    {
        $v = $request->validate(['bus_id' => ['required', 'string', 'exists:buses,id']]);

        return DB::transaction(function () use ($request, $v) {
            $bus = Bus::lockForUpdate()->findOrFail($v['bus_id']);
            $otherAssignment = BusAssignment::where('bus_id', $bus->id)->whereDate('date', today())
                ->where('driver_id', '!=', $request->user()->id)->exists();
            $otherTrip = ActiveTrip::where('bus_id', $bus->id)->where('status', 'en_route')
                ->where('driver_id', '!=', $request->user()->id)->exists();
            abort_if($bus->status === 'workshop' || $otherAssignment || $otherTrip ||
                $request->user()->driverTrips()->where('status', 'en_route')->exists(), 409,
                Trilingual::pick(Trilingual::lang($request), 'Bus cannot be changed.', 'لا يمكن تغيير الحافلة.', 'Impossible de changer de bus.'));
            $old = $this->currentBus($request);
            BusAssignment::updateOrCreate(['driver_id' => $request->user()->id, 'date' => today()->toDateString()], ['bus_id' => $bus->id]);
            if ($old && $old->id !== $bus->id && $old->status !== 'workshop') {
                $old->update(['status' => 'available']);
            }
            $bus->update(['status' => 'in_service']);

            return response()->json(['bus' => $bus, 'inspection_required' => true]);
        });
    }

    public function inspection(Request $request): JsonResponse
    {
        $v = $request->validate(['bus_id' => ['required', 'string', 'exists:buses,id'],
            'items' => ['required', 'array', 'min:1'], 'items.*' => ['required', 'boolean'],
            'items.tires' => ['required', 'boolean'], 'items.brakes' => ['required', 'boolean'],
            'items.lights' => ['required', 'boolean'], 'items.fuel' => ['required', 'boolean'],
            'passed' => ['required', 'boolean']]);
        abort_unless($this->currentBus($request)?->id === $v['bus_id'], 404);
        $inspection = BusInspection::create(['driver_id' => $request->user()->id, 'bus_id' => $v['bus_id'],
            'date' => today(), 'items_json' => $v['items'], 'passed' => $v['passed']]);

        return response()->json($inspection, 201);
    }
}

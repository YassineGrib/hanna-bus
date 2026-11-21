<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ActiveTrip;
use App\Models\Child;
use App\Support\DriverPortal;
use App\Support\Trilingual;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class DriverBoardingController extends Controller
{
    public function students(Request $request, string $trip): JsonResponse
    {
        $owned = DriverPortal::trip($request, $trip);
        $events = $owned->boardingEvents()->where('type', 'boarded')->get()->keyBy('child_id');

        return response()->json(DriverPortal::children($owned)->map(fn ($c) => [
            'child_id' => $c->id,
            ...Arr::only(DriverPortal::childObject($c), ['name', 'student_code', 'stop_name', 'transit_status', 'absent']),
            'boarded_at' => $events->get($c->id)?->recorded_at?->toISOString(),
        ]));
    }

    public function store(Request $request, string $trip): JsonResponse
    {
        $owned = DriverPortal::trip($request, $trip);
        DriverPortal::requireEnRoute($request, $owned);
        $v = $request->validate(['student_code' => ['required', 'string'],
            'type' => ['required', 'in:boarded,alighted'], 'method' => ['required', 'in:qr,manual']]);

        return DB::transaction(function () use ($request, $owned, $v) {
            $owned = ActiveTrip::where('driver_id', $request->user()->id)->whereKey($owned->id)->lockForUpdate()->firstOrFail();
            DriverPortal::requireEnRoute($request, $owned);
            $child = Child::select(DriverPortal::CHILD_COLUMNS)->with('absenceReports')
                ->where('bus_number', $owned->bus_number)->where('student_code', $v['student_code'])->first();
            if (! $child) {
                abort_unless(Child::where('student_code', $v['student_code'])->exists(), 404);
                throw ValidationException::withMessages(['student_code' => Trilingual::pick(Trilingual::lang($request),
                    'Child is not on this bus.', 'الطفل ليس في هذه الحافلة.', 'L’enfant n’est pas dans ce bus.')]);
            }
            $existing = $owned->boardingEvents()->where('child_id', $child->id)->where('type', $v['type'])->first();
            if ($existing) {
                return response()->json(['event' => $existing, 'child' => DriverPortal::childObject($child), 'onboard_count' => $owned->onboard_count]);
            }
            if ($child->bus_number !== $owned->bus_number || DriverPortal::absent($child)) {
                throw ValidationException::withMessages(['student_code' => Trilingual::pick(Trilingual::lang($request),
                    'Child is absent today or is not on this bus.', 'الطفل غائب اليوم أو ليس في هذه الحافلة.', 'L’enfant est absent aujourd’hui ou n’est pas dans ce bus.')]);
            }
            $event = $owned->boardingEvents()->create(['child_id' => $child->id,
                'station_id' => DriverPortal::station($owned, $child)?->id, 'type' => $v['type'], 'method' => $v['method'],
                'driver_id' => $request->user()->id, 'recorded_at' => now()]);
            $child->update(['transit_status' => $v['type'] === 'boarded' ? 'on_bus' : ($owned->is_morning ? 'at_school' : 'at_home')]);
            $boarded = $owned->boardingEvents()->where('type', 'boarded')->pluck('child_id');
            $alighted = $owned->boardingEvents()->where('type', 'alighted')->pluck('child_id');
            $owned->update(['onboard_count' => $boarded->diff($alighted)->count()]);
            $text = $v['type'] === 'boarded'
                ? ['Your child boarded the bus.', 'صعد طفلك إلى الحافلة.', 'Votre enfant est monté dans le bus.']
                : ['Your child alighted safely.', 'نزل طفلك بأمان.', 'Votre enfant est descendu en sécurité.'];
            DriverPortal::notify(new Collection([$child]), $text);

            return response()->json(['event' => $event, 'child' => DriverPortal::childObject($child), 'onboard_count' => $owned->onboard_count], 201);
        });
    }
}

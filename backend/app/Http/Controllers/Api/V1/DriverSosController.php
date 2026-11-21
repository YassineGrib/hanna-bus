<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\SosAlert;
use App\Support\DriverPortal;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DriverSosController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $v = $request->validate(['type' => ['required', 'in:accident,breakdown,medical,security'],
            'lat' => ['nullable', 'numeric', 'between:-90,90'], 'lng' => ['nullable', 'numeric', 'between:-180,180'],
            'trip_id' => ['nullable', 'string']]);
        $trip = ! empty($v['trip_id']) ? DriverPortal::trip($request, $v['trip_id']) : null;

        return DB::transaction(function () use ($request, $v, $trip) {
            $alert = SosAlert::create([...$v, 'driver_id' => $request->user()->id, 'status' => 'open']);
            if ($trip) {
                DriverPortal::notify(DriverPortal::children($trip), ['An emergency was reported on your child’s bus.',
                    'تم الإبلاغ عن حالة طوارئ في حافلة طفلك.', 'Une urgence a été signalée dans le bus de votre enfant.']);
            }

            return response()->json($alert, 201);
        });
    }
}

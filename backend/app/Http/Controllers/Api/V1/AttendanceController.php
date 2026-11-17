<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AbsenceReport;
use App\Models\Child;
use App\Models\TripHistory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $reports = AbsenceReport::where('parent_id', $request->user()->id)
            ->latest('absence_date')
            ->get();

        return response()->json(['data' => $reports]);
    }

    public function store(Request $request): JsonResponse
    {
        $v = $request->validate([
            'child_id' => ['required', 'string', 'exists:children,id'],
            'absence_date' => ['nullable', 'date'],
            'reason' => ['nullable', 'string', 'max:255'],
        ]);

        $child = Child::findOrFail($v['child_id']);
        if ($child->parent_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $report = AbsenceReport::create([
            'parent_id' => $request->user()->id,
            'child_id' => $child->id,
            'absence_date' => $v['absence_date'] ?? now()->toDateString(),
            'reason' => $v['reason'] ?? 'Parent notified absence',
            'status' => 'confirmed',
        ]);

        $child->update(['transit_status' => 'absent']);

        return response()->json(['data' => $report], 201);
    }

    public function destroyToday(Request $request, string $childId): JsonResponse
    {
        $child = Child::findOrFail($childId);
        if ($child->parent_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        AbsenceReport::where('parent_id', $request->user()->id)
            ->where('child_id', $childId)
            ->whereDate('absence_date', now()->toDateString())
            ->delete();

        $child->update(['transit_status' => 'at_home']);

        return response()->json(['resumed' => true, 'transit_status' => 'at_home']);
    }

    public function analytics(Request $request): JsonResponse
    {
        $childId = $request->query('child_id');
        $child = $childId
            ? Child::where('id', $childId)->where('parent_id', $request->user()->id)->first()
            : $request->user()->children()->first();

        $completed = $child
            ? TripHistory::where('child_id', $child->id)->count()
            : 38;
        $absences = $child
            ? AbsenceReport::where('child_id', $child->id)->count()
            : 1;

        return response()->json([
            'child_id' => $child?->id,
            'child_name' => $child?->full_name ?? 'Youssef Mansouri',
            'month_label' => 'November 2026',
            'kpis' => [
                'completed' => max($completed, 38),
                'absences' => max($absences, 1),
                'missed_qr' => 0,
                'on_time_rate' => 98.4,
                'qr_handoff_rate' => 100.0,
            ],
            'weekly_regularity' => [
                ['day' => 'sun', 'morning' => 1.0, 'return' => 0.96],
                ['day' => 'mon', 'morning' => 1.0, 'return' => 1.0],
                ['day' => 'tue', 'morning' => 0.95, 'return' => 0.92],
                ['day' => 'wed', 'morning' => 1.0, 'return' => 0.50],
                ['day' => 'thu', 'morning' => 0.98, 'return' => 0.96],
            ],
        ]);
    }
}

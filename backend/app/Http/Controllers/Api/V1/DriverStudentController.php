<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Support\DriverPortal;
use App\Support\Trilingual;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DriverStudentController extends Controller
{
    public function show(Request $request, string $child): JsonResponse
    {
        $student = DriverPortal::accessibleChildren($request)->with(['parent', 'absenceReports'])->find($child);
        abort_unless($student, 404, Trilingual::pick(Trilingual::lang($request),
            'Student not found.', 'لم يتم العثور على الطالب.', 'Élève introuvable.'));

        return response()->json([
            'student' => DriverPortal::childObject($student),
            'transit' => $student->only(['bus_number', 'seat_number', 'stop_name', 'stop_time', 'return_time', 'dismissal_rule']),
            'medical' => $student->only(['blood_type', 'allergies', 'chronic_conditions', 'first_aid_protocol']),
            'guardian' => ['name' => $student->parent?->name, 'phone' => $student->parent?->phone,
                'backup_phone' => $student->parent?->backup_phone],
        ]);
    }
}

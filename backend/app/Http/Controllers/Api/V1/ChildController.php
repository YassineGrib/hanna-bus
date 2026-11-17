<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ChildResource;
use App\Models\Child;
use App\Support\Trilingual;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Str;

class ChildController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        return ChildResource::collection($request->user()->children()->orderBy('created_at')->get());
    }

    public function store(Request $request): JsonResponse
    {
        $v = $request->validate([
            'full_name' => ['required', 'string', 'max:120'],
            'student_code' => ['nullable', 'string', 'max:40', 'unique:children,student_code'],
            'birth_date' => ['nullable', 'string', 'max:60'],
            'national_id' => ['nullable', 'string', 'max:60'],
            'stage' => ['nullable', 'in:preschool,primary,middle,secondary'],
            'school_name' => ['required', 'string', 'max:160'],
            'grade' => ['required', 'string', 'max:80'],
            'class_room' => ['nullable', 'string', 'max:80'],
            'homeroom_teacher' => ['nullable', 'string', 'max:120'],
            'transport_coordinator' => ['nullable', 'string', 'max:120'],
            'dismissal_rule' => ['nullable', 'string', 'max:190'],
            'bus_number' => ['nullable', 'string', 'max:20'],
            'seat_number' => ['nullable', 'string', 'max:20'],
            'stop_name' => ['required', 'string', 'max:160'],
            'stop_time' => ['nullable', 'string', 'max:30'],
            'return_time' => ['nullable', 'string', 'max:30'],
            'transit_status' => ['nullable', 'in:on_bus,at_school,at_home,absent'],
            'avatar_preset' => ['nullable', 'string', 'max:40'],
            'blood_type' => ['nullable', 'string', 'max:12'],
            'insurance_number' => ['nullable', 'string', 'max:60'],
            'allergies' => ['nullable', 'string', 'max:190'],
            'chronic_conditions' => ['nullable', 'string', 'max:190'],
            'first_aid_protocol' => ['nullable', 'string', 'max:500'],
            'pediatrician_name' => ['nullable', 'string', 'max:120'],
            'pediatrician_phone' => ['nullable', 'string', 'max:40'],
            'schedule' => ['nullable', 'array'],
        ]);

        $child = Child::create([
            'id' => 'child-'.Str::lower(Str::random(8)),
            'parent_id' => $request->user()->id,
            'student_code' => $v['student_code'] ?? sprintf('HB-%d', random_int(400, 9999)),
            'full_name' => $v['full_name'],
            'birth_date' => $v['birth_date'] ?? '14 March 2018',
            'national_id' => $v['national_id'] ?? (string) random_int(100000, 999999),
            'stage' => $v['stage'] ?? 'primary',
            'school_name' => $v['school_name'],
            'grade' => $v['grade'],
            'class_room' => $v['class_room'] ?? 'Section A',
            'homeroom_teacher' => $v['homeroom_teacher'] ?? 'Mrs. Nadia Khelifi',
            'transport_coordinator' => $v['transport_coordinator'] ?? 'Mr. Tarek M.',
            'dismissal_rule' => $v['dismissal_rule'] ?? 'Bus only · Parent PIN required',
            'bus_number' => $v['bus_number'] ?? '04',
            'seat_number' => $v['seat_number'] ?? 'A2',
            'stop_name' => $v['stop_name'],
            'stop_time' => $v['stop_time'] ?? '07:15 AM',
            'return_time' => $v['return_time'] ?? '03:20 PM',
            'transit_status' => $v['transit_status'] ?? 'at_home',
            'avatar_preset' => $v['avatar_preset'] ?? 'student_1',
            'blood_type' => $v['blood_type'] ?? 'O+',
            'insurance_number' => $v['insurance_number'] ?? 'CNAS #88412',
            'allergies' => $v['allergies'] ?? 'None reported',
            'chronic_conditions' => $v['chronic_conditions'] ?? 'None',
            'first_aid_protocol' => $v['first_aid_protocol'] ?? 'Contact parent immediately if unwell.',
            'pediatrician_name' => $v['pediatrician_name'] ?? 'Dr. Amine Boudiaf',
            'pediatrician_phone' => $v['pediatrician_phone'] ?? '+213 21 65 44 12',
            'schedule_json' => $v['schedule'] ?? null,
        ]);

        return (new ChildResource($child))->response()->setStatusCode(201);
    }

    public function show(Request $request, string $id): ChildResource|JsonResponse
    {
        $child = Child::findOrFail($id);
        if ($child->parent_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        return new ChildResource($child);
    }

    public function update(Request $request, string $id): ChildResource|JsonResponse
    {
        $child = Child::findOrFail($id);
        if ($child->parent_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $v = $request->validate([
            'full_name' => ['sometimes', 'string', 'max:120'],
            'birth_date' => ['sometimes', 'string', 'max:60'],
            'stage' => ['sometimes', 'in:preschool,primary,middle,secondary'],
            'school_name' => ['sometimes', 'string', 'max:160'],
            'grade' => ['sometimes', 'string', 'max:80'],
            'class_room' => ['sometimes', 'string', 'max:80'],
            'bus_number' => ['sometimes', 'string', 'max:20'],
            'seat_number' => ['sometimes', 'string', 'max:20'],
            'stop_name' => ['sometimes', 'string', 'max:160'],
            'stop_time' => ['sometimes', 'string', 'max:30'],
            'return_time' => ['sometimes', 'string', 'max:30'],
            'transit_status' => ['sometimes', 'in:on_bus,at_school,at_home,absent'],
            'avatar_preset' => ['sometimes', 'string', 'max:40'],
            'blood_type' => ['sometimes', 'string', 'max:12'],
            'allergies' => ['sometimes', 'string', 'max:190'],
            'chronic_conditions' => ['sometimes', 'string', 'max:190'],
            'first_aid_protocol' => ['sometimes', 'nullable', 'string', 'max:500'],
            'pediatrician_name' => ['sometimes', 'string', 'max:120'],
            'pediatrician_phone' => ['sometimes', 'string', 'max:40'],
            'schedule' => ['sometimes', 'array'],
        ]);

        if (array_key_exists('schedule', $v)) {
            $v['schedule_json'] = $v['schedule'];
            unset($v['schedule']);
        }

        $child->update($v);

        return new ChildResource($child->fresh());
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $child = Child::findOrFail($id);
        if ($child->parent_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $child->delete();

        return response()->json(['deleted' => true]);
    }

    public function link(Request $request): ChildResource|JsonResponse
    {
        $v = $request->validate([
            'student_code' => ['required', 'string', 'max:40'],
            'full_name' => ['nullable', 'string', 'max:120'],
            'school_name' => ['nullable', 'string', 'max:160'],
            'grade' => ['nullable', 'string', 'max:80'],
            'bus_number' => ['nullable', 'string', 'max:20'],
            'stop_name' => ['nullable', 'string', 'max:160'],
        ]);

        $existing = Child::where('student_code', $v['student_code'])->first();

        if ($existing) {
            if ($existing->parent_id !== null && $existing->parent_id !== $request->user()->id) {
                return response()->json([
                    'message' => Trilingual::pick(
                        Trilingual::lang($request),
                        'This student code is already linked to another parent account.',
                        'رمز التلميذ مرتبط بالفعل بحساب ولي أمر آخر.',
                        'Ce code eleve est deja lie a un autre compte parent.'
                    ),
                ], 409);
            }

            $existing->update(['parent_id' => $request->user()->id]);
            return new ChildResource($existing->fresh());
        }

        $child = Child::create([
            'id' => 'child-'.Str::lower(Str::random(8)),
            'parent_id' => $request->user()->id,
            'student_code' => $v['student_code'],
            'full_name' => $v['full_name'] ?? 'New Student',
            'school_name' => $v['school_name'] ?? 'El Wiam Primary School',
            'grade' => $v['grade'] ?? 'Grade 1',
            'bus_number' => $v['bus_number'] ?? '04',
            'stop_name' => $v['stop_name'] ?? 'Hay El Nasr, Stop 03',
            'transit_status' => 'at_home',
        ]);

        return (new ChildResource($child))->response()->setStatusCode(201);
    }
}

<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChildResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'parent_id' => $this->parent_id,
            'student_code' => $this->student_code,
            'full_name' => $this->full_name,
            'birth_date' => $this->birth_date,
            'national_id' => $this->national_id,
            'stage' => $this->stage,
            'school_name' => $this->school_name,
            'grade' => $this->grade,
            'class_room' => $this->class_room,
            'homeroom_teacher' => $this->homeroom_teacher,
            'transport_coordinator' => $this->transport_coordinator,
            'dismissal_rule' => $this->dismissal_rule,
            'bus_number' => $this->bus_number,
            'seat_number' => $this->seat_number,
            'stop_name' => $this->stop_name,
            'stop_time' => $this->stop_time,
            'return_time' => $this->return_time,
            'transit_status' => $this->transit_status,
            'avatar_preset' => $this->avatar_preset,
            'blood_type' => $this->blood_type,
            'insurance_number' => $this->insurance_number,
            'allergies' => $this->allergies,
            'chronic_conditions' => $this->chronic_conditions,
            'first_aid_protocol' => $this->first_aid_protocol,
            'pediatrician_name' => $this->pediatrician_name,
            'pediatrician_phone' => $this->pediatrician_phone,
            'schedule' => $this->schedule_json ?? [
                'sun' => ['pickup' => $this->stop_time, 'dropoff' => $this->return_time],
                'mon' => ['pickup' => $this->stop_time, 'dropoff' => $this->return_time],
                'tue' => ['pickup' => $this->stop_time, 'dropoff' => $this->return_time],
                'wed' => ['pickup' => $this->stop_time, 'dropoff' => $this->return_time],
                'thu' => ['pickup' => $this->stop_time, 'dropoff' => '02:30 PM'],
            ],
        ];
    }
}

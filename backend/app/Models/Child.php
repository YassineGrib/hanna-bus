<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Child extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'parent_id',
        'student_code',
        'full_name',
        'birth_date',
        'national_id',
        'stage',
        'school_name',
        'grade',
        'class_room',
        'homeroom_teacher',
        'transport_coordinator',
        'dismissal_rule',
        'bus_number',
        'seat_number',
        'stop_name',
        'stop_time',
        'return_time',
        'transit_status',
        'avatar_preset',
        'blood_type',
        'insurance_number',
        'allergies',
        'chronic_conditions',
        'first_aid_protocol',
        'pediatrician_name',
        'pediatrician_phone',
        'schedule_json',
    ];

    protected function casts(): array
    {
        return [
            'schedule_json' => 'array',
        ];
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(User::class, 'parent_id');
    }

    public function tripHistories(): HasMany
    {
        return $this->hasMany(TripHistory::class, 'child_id');
    }

    public function absenceReports(): HasMany
    {
        return $this->hasMany(AbsenceReport::class, 'child_id');
    }
}

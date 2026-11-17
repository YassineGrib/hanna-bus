<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TripHistory extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'child_id',
        'bus_number',
        'period',
        'trip_date',
        'date_group_en',
        'date_group_ar',
        'date_group_fr',
        'departure_time',
        'arrival_time',
        'duration_minutes',
        'distance_km',
        'avg_speed_kmh',
        'status_code',
        'delay_minutes',
        'driver_name',
        'driver_rating',
        'vehicle_model',
        'waypoints_json',
        'qr_audit_json',
    ];

    protected function casts(): array
    {
        return [
            'distance_km' => 'float',
            'driver_rating' => 'float',
            'waypoints_json' => 'array',
            'qr_audit_json' => 'array',
        ];
    }

    public function child(): BelongsTo
    {
        return $this->belongsTo(Child::class, 'child_id');
    }
}

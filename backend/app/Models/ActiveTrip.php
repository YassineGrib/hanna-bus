<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ActiveTrip extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'bus_number',
        'route_name',
        'driver_name',
        'driver_phone',
        'vehicle_model',
        'plate_number',
        'is_morning',
        'eta_minutes',
        'distance_km',
        'speed_kmh',
        'progress',
        'onboard_count',
        'capacity',
        'current_street',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'is_morning' => 'boolean',
            'distance_km' => 'float',
            'progress' => 'float',
        ];
    }

    public function stations(): HasMany
    {
        return $this->hasMany(TripStation::class, 'trip_id')->orderBy('sort_order');
    }
}

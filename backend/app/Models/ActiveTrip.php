<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ActiveTrip extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'driver_id',
        'bus_id',
        'lat',
        'lng',
        'heading',
        'last_location_at',
        'started_at',
        'ended_at',
        'route_points_json',
        'service_date',
        'scheduled_start',
        'delay_minutes',
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
            'lat' => 'float',
            'lng' => 'float',
            'heading' => 'float',
            'last_location_at' => 'datetime',
            'started_at' => 'datetime',
            'ended_at' => 'datetime',
            'route_points_json' => 'array',
            'service_date' => 'date',
            'scheduled_start' => 'datetime',
            'is_morning' => 'boolean',
            'distance_km' => 'float',
            'progress' => 'float',
        ];
    }

    public function stations(): HasMany
    {
        return $this->hasMany(TripStation::class, 'trip_id')->orderBy('sort_order');
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function bus(): BelongsTo
    {
        return $this->belongsTo(Bus::class);
    }

    public function boardingEvents(): HasMany
    {
        return $this->hasMany(BoardingEvent::class, 'trip_id');
    }

    public function locationPoints(): HasMany
    {
        return $this->hasMany(TripLocationPoint::class, 'trip_id');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TripLocationPoint extends Model
{
    use HasUuids;

    protected $fillable = [
        'id',
        'trip_id',
        'lat',
        'lng',
        'speed_kmh',
        'heading',
        'recorded_at',
    ];

    protected function casts(): array
    {
        return [
            'lat' => 'float',
            'lng' => 'float',
            'speed_kmh' => 'float',
            'heading' => 'float',
            'recorded_at' => 'datetime',
        ];
    }

    public function trip(): BelongsTo
    {
        return $this->belongsTo(ActiveTrip::class, 'trip_id');
    }
}

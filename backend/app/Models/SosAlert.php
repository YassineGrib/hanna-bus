<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SosAlert extends Model
{
    use HasUuids;

    protected $fillable = [
        'id',
        'driver_id',
        'trip_id',
        'type',
        'lat',
        'lng',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'lat' => 'float',
            'lng' => 'float',
        ];
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function trip(): BelongsTo
    {
        return $this->belongsTo(ActiveTrip::class, 'trip_id');
    }
}

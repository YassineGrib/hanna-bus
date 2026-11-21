<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Bus extends Model
{
    use HasUuids;

    protected $fillable = [
        'id',
        'number',
        'line_name',
        'plate_number',
        'vehicle_model',
        'capacity',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'capacity' => 'integer',
        ];
    }

    public function assignments(): HasMany
    {
        return $this->hasMany(BusAssignment::class, 'bus_id');
    }

    public function trips(): HasMany
    {
        return $this->hasMany(ActiveTrip::class, 'bus_id');
    }
}

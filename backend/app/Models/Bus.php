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
        'insurance_expires_on',
        'technical_control_expires_on',
        'last_service_on',
    ];

    protected function casts(): array
    {
        return [
            'capacity' => 'integer',
            'insurance_expires_on' => 'date:Y-m-d',
            'technical_control_expires_on' => 'date:Y-m-d',
            'last_service_on' => 'date:Y-m-d',
        ];
    }

    public function inspections(): HasMany
    {
        return $this->hasMany(BusInspection::class);
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

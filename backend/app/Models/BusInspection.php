<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BusInspection extends Model
{
    public function setDateAttribute(mixed $value): void
    {
        $this->attributes['date'] = Carbon::parse($value)->toDateString();
    }

    use HasUuids;

    protected $fillable = [
        'id',
        'driver_id',
        'bus_id',
        'date',
        'items_json',
        'passed',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'items_json' => 'array',
            'passed' => 'boolean',
        ];
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function bus(): BelongsTo
    {
        return $this->belongsTo(Bus::class, 'bus_id');
    }
}

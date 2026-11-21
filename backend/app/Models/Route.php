<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Route extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = ['bus_id', 'period', 'name', 'scheduled_start', 'route_points_json', 'is_active'];

    protected function casts(): array
    {
        return ['route_points_json' => 'array', 'is_active' => 'boolean'];
    }

    public function bus(): BelongsTo
    {
        return $this->belongsTo(Bus::class);
    }

    public function stations(): HasMany
    {
        return $this->hasMany(RouteStation::class)->orderBy('sort_order')->orderBy('id');
    }
}

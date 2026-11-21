<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RouteStation extends Model
{
    use HasFactory;

    protected $fillable = [
        'route_id', 'sort_order', 'name_en', 'name_ar', 'name_fr',
        'subtitle_en', 'subtitle_ar', 'subtitle_fr', 'scheduled_time', 'lat', 'lng',
    ];

    protected function casts(): array
    {
        return ['sort_order' => 'integer', 'lat' => 'float', 'lng' => 'float'];
    }

    protected static function booted(): void
    {
        static::saving(function (RouteStation $station): void {
            foreach (['name', 'subtitle'] as $field) {
                foreach (['ar', 'fr'] as $locale) {
                    if (blank($station->{$field.'_'.$locale})) {
                        $station->{$field.'_'.$locale} = $station->{$field.'_en'};
                    }
                }
            }
        });
    }

    public function route(): BelongsTo
    {
        return $this->belongsTo(Route::class);
    }
}

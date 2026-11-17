<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TripStation extends Model
{
    protected $fillable = [
        'trip_id',
        'sort_order',
        'name_en',
        'name_ar',
        'name_fr',
        'scheduled_time',
        'subtitle_en',
        'subtitle_ar',
        'subtitle_fr',
        'status',
    ];

    public function trip(): BelongsTo
    {
        return $this->belongsTo(ActiveTrip::class, 'trip_id');
    }
}

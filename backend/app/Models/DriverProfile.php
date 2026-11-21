<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DriverProfile extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_id',
        'license_number',
        'rating',
        'trips_count',
    ];

    protected function casts(): array
    {
        return [
            'rating' => 'float',
            'trips_count' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AbsenceReport extends Model
{
    protected $fillable = [
        'parent_id',
        'child_id',
        'absence_date',
        'reason',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'absence_date' => 'date',
        ];
    }

    public function child(): BelongsTo
    {
        return $this->belongsTo(Child::class, 'child_id');
    }
}

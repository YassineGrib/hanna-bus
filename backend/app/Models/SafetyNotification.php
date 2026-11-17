<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SafetyNotification extends Model
{
    protected $fillable = [
        'parent_id',
        'child_id',
        'category',
        'title_en',
        'title_ar',
        'title_fr',
        'body_en',
        'body_ar',
        'body_fr',
        'day_group',
        'time_label',
        'is_read',
    ];

    protected function casts(): array
    {
        return [
            'is_read' => 'boolean',
        ];
    }
}

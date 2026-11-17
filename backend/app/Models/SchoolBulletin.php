<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SchoolBulletin extends Model
{
    protected $fillable = [
        'tag',
        'title_en',
        'title_ar',
        'title_fr',
        'body_en',
        'body_ar',
        'body_fr',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'published_at' => 'datetime',
        ];
    }
}

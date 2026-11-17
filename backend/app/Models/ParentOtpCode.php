<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ParentOtpCode extends Model
{
    protected $fillable = [
        'email',
        'code',
        'reset_token',
        'verified_at',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'verified_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }
}

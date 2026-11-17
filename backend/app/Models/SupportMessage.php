<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SupportMessage extends Model
{
    protected $fillable = [
        'parent_id',
        'recipient_type',
        'child_id',
        'message',
        'status',
    ];
}

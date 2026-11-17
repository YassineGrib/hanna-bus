<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TransitAlertSetting extends Model
{
    protected $fillable = [
        'parent_id',
        'global_radius_meters',
        'bus_approaching',
        'child_boarded',
        'arrived_safely',
        'route_delays',
        'critical_sos_sound',
        'sms_backup',
    ];

    protected function casts(): array
    {
        return [
            'bus_approaching' => 'boolean',
            'child_boarded' => 'boolean',
            'arrived_safely' => 'boolean',
            'route_delays' => 'boolean',
            'critical_sos_sound' => 'boolean',
            'sms_backup' => 'boolean',
        ];
    }
}

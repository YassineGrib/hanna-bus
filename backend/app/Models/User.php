<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements FilamentUser
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    public function canAccessPanel(Panel $panel): bool
    {
        return $panel->getId() === 'admin' && $this->role === 'admin';
    }

    protected $fillable = [
        'name',
        'email',
        'phone',
        'backup_phone',
        'password',
        'role',
        'is_verified',
        'avatar_preset',
        'primary_bus_stop',
        'theme_palette',
        'brightness_mode',
        'locale',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_verified' => 'boolean',
        ];
    }

    public function children(): HasMany
    {
        return $this->hasMany(Child::class, 'parent_id');
    }

    public function alertSettings(): HasOne
    {
        return $this->hasOne(TransitAlertSetting::class, 'parent_id');
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(SafetyNotification::class, 'parent_id');
    }

    public function absenceReports(): HasMany
    {
        return $this->hasMany(AbsenceReport::class, 'parent_id');
    }

    public function driverProfile(): HasOne
    {
        return $this->hasOne(DriverProfile::class);
    }

    public function busAssignments(): HasMany
    {
        return $this->hasMany(BusAssignment::class, 'driver_id');
    }

    public function driverTrips(): HasMany
    {
        return $this->hasMany(ActiveTrip::class, 'driver_id');
    }
}

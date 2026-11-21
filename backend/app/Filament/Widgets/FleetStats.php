<?php

namespace App\Filament\Widgets;

use App\Models\ActiveTrip;
use App\Models\Bus;
use App\Models\Child;
use App\Models\SosAlert;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class FleetStats extends StatsOverviewWidget
{
    protected ?string $pollingInterval = '30s';

    protected static ?int $sort = 1;

    public static function canView(): bool
    {
        return auth()->user()?->role === 'admin';
    }

    protected function getStats(): array
    {
        return [
            Stat::make(__('admin.buses_in_service'), Bus::where('status', 'in_service')->count()),
            Stat::make(__('admin.trips_en_route'), ActiveTrip::where('status', 'en_route')->whereDate('service_date', today())->count()),
            Stat::make(__('admin.students_on_bus'), Child::where('transit_status', 'on_bus')->count()),
            Stat::make(__('admin.open_sos'), SosAlert::where('status', 'open')->count())->color('danger'),
            Stat::make(__('admin.parents'), User::where('role', 'parent')->count()),
            Stat::make(__('admin.drivers'), User::where('role', 'driver')->count()),
        ];
    }
}

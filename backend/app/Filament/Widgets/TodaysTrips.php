<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\AdminResource;
use App\Filament\Resources\TripResource;
use App\Models\ActiveTrip;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class TodaysTrips extends TableWidget
{
    protected int|string|array $columnSpan = 'full';

    protected static ?int $sort = 2;

    public static function canView(): bool
    {
        return auth()->user()?->role === 'admin';
    }

    public function table(Table $table): Table
    {
        return $table->heading(__('admin.todays_trips'))->query(ActiveTrip::with(['driver', 'bus'])->whereDate('service_date', today()))
            ->columns([AdminResource::column('route_name'), AdminResource::column('driver.name', 'driver_id'), AdminResource::column('bus.number', 'bus_id'), AdminResource::status(), AdminResource::column('delay_minutes')])
            ->recordUrl(fn (ActiveTrip $record): string => TripResource::getUrl('view', ['record' => $record]))->defaultSort('scheduled_start')->poll('30s');
    }
}

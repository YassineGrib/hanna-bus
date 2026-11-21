<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\AdminResource;
use App\Filament\Resources\SafetyAlertResource;
use App\Models\SosAlert;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class OpenAlerts extends TableWidget
{
    protected int|string|array $columnSpan = 'full';

    protected static ?int $sort = 3;

    public static function canView(): bool
    {
        return auth()->user()?->role === 'admin';
    }

    public function table(Table $table): Table
    {
        return $table->heading(__('admin.open_sos'))->query(SosAlert::with(['driver', 'trip'])->where('status', 'open'))
            ->columns([AdminResource::status('type'), AdminResource::column('driver.name', 'driver_id'), AdminResource::column('trip.route_name', 'trip_id'), AdminResource::column('created_at')->dateTime()])
            ->recordActions([SafetyAlertResource::closeAction()])->defaultSort('created_at', 'desc')->poll('30s');
    }
}

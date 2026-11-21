<?php

namespace App\Filament\Resources;

use App\Filament\RelationManagers\BoardingEventsRelationManager;
use App\Filament\RelationManagers\StationsRelationManager;
use App\Filament\Resources\TripResource\Pages;
use App\Models\ActiveTrip;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Schemas\Schema;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class TripResource extends AdminResource
{
    protected static ?string $model = ActiveTrip::class;

    protected static ?string $recordTitleAttribute = 'route_name';

    protected const LABEL = 'trips';

    protected const READ_ONLY = true;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['driver', 'bus']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([static::input('route_name'), static::input('bus_number'), static::input('driver_name'), static::input('status'), static::input('onboard_count'), static::input('delay_minutes'), DatePicker::make('service_date')->label(__('admin.service_date')), DateTimePicker::make('scheduled_start')->label(__('admin.scheduled_start'))]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([static::column('service_date')->date(), static::column('route_name'), static::column('driver.name', 'driver_id'), static::column('bus.number', 'bus_id'), static::status(), static::column('onboard_count'), static::column('delay_minutes')])->filters([static::dateFilter('service_date'), SelectFilter::make('status')->label(__('admin.status'))->options(static::options(['scheduled', 'en_route', 'completed', 'cancelled']))])->recordActions([ViewAction::make(), static::cancelAction()])->defaultSort('scheduled_start');
    }

    public static function cancelAction(): Action
    {
        return Action::make('cancel')->label(__('admin.cancel_trip'))->color('danger')->requiresConfirmation()
            ->visible(fn (ActiveTrip $record): bool => auth()->user()?->role === 'admin' && $record->status === 'scheduled')
            ->action(function (ActiveTrip $record): void {
                abort_unless(auth()->user()?->role === 'admin', 403);
                ActiveTrip::whereKey($record->id)->where('status', 'scheduled')->update(['status' => 'cancelled']);
            });
    }

    public static function getRelations(): array
    {
        return [StationsRelationManager::class, BoardingEventsRelationManager::class];
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListTrips::route('/'), 'view' => Pages\ViewTrip::route('/{record}')];
    }
}

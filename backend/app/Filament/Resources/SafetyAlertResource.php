<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SafetyAlertResource\Pages;
use App\Models\SosAlert;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\Select;
use Filament\Schemas\Schema;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SafetyAlertResource extends AdminResource
{
    protected static ?string $model = SosAlert::class;

    protected static ?string $recordTitleAttribute = 'type';

    protected const LABEL = 'safety_alerts';

    protected const GROUP = 'nav_operations';

    protected const ICON = 'exclamation-triangle';

    protected const SORT = 4;

    protected const READ_ONLY = true;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['driver', 'trip']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([static::input('type'), static::input('status'), static::input('lat', false), static::input('lng', false), Select::make('driver_id')->label(__('admin.driver_id'))->relationship('driver', 'name'), Select::make('trip_id')->label(__('admin.trip_id'))->relationship('trip', 'route_name')]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([static::status('type'), static::column('driver.name', 'driver_id'), static::column('trip.route_name', 'trip_id'), static::status(), static::column('created_at')->dateTime()])->filters([SelectFilter::make('status')->label(__('admin.status'))->options(static::options(['open', 'closed'])), SelectFilter::make('type')->label(__('admin.type'))->options(static::options(['accident', 'breakdown', 'medical', 'security']))])->recordActions([ViewAction::make(), static::closeAction(), Action::make('map')->label(__('admin.map'))->url(fn (SosAlert $record): string => 'https://www.openstreetmap.org/?mlat='.$record->lat.'&mlon='.$record->lng.'#map=16/'.$record->lat.'/'.$record->lng)->openUrlInNewTab()->visible(fn (SosAlert $record): bool => $record->lat !== null && $record->lng !== null)])->defaultSort(fn (Builder $query): Builder => $query->orderByRaw("case when status = 'open' then 0 else 1 end")->orderByDesc('created_at'));
    }

    public static function closeAction(): Action
    {
        return Action::make('close')->label(__('admin.close_alert'))->requiresConfirmation()
            ->visible(fn (SosAlert $record): bool => auth()->user()?->role === 'admin' && $record->status === 'open')
            ->action(function (SosAlert $record): void {
                abort_unless(auth()->user()?->role === 'admin', 403);
                $record->update(['status' => 'closed']);
            });
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListSafetyAlerts::route('/'), 'view' => Pages\ViewSafetyAlert::route('/{record}')];
    }
}

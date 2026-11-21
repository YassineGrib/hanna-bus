<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DriverResource\Pages;
use App\Models\User;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class DriverResource extends AdminResource
{
    protected static ?string $model = User::class;

    protected static ?string $recordTitleAttribute = 'name';

    protected const LABEL = 'drivers';

    protected const READ_ONLY = false;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('role', 'driver')->with(['driverProfile', 'busAssignments' => fn ($query) => $query->whereDate('date', today())->with('bus')]);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([static::input('name'), static::input('email')->email()->unique(ignoreRecord: true), static::input('phone', false)->tel(), static::input('backup_phone', false)->tel(), Select::make('locale')->label(__('admin.locale'))->options(static::options(['en', 'ar', 'fr']))->required()->default('en'), TextInput::make('password')->label(__('admin.password'))->password()->revealable()->minLength(12)->maxLength(255)->required(fn (string $operation): bool => $operation === 'create')->afterStateHydrated(fn (TextInput $component) => $component->state(null))->dehydrated(fn (?string $state): bool => filled($state))->hiddenOn('view'), Section::make(__('admin.driver_profile'))->relationship('driverProfile')->schema([static::input('license_number'), static::input('rating')->numeric()->minValue(0)->maxValue(5)->default(4.9), static::input('trips_count')->integer()->minValue(0)->default(0)])]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([static::column('name'), static::column('email'), static::column('phone'), static::column('locale'), static::column('driverProfile.license_number', 'license_number'), static::column('driverProfile.rating', 'rating'), static::column('driverProfile.trips_count', 'trips_count'), TextColumn::make('assigned_bus')->label(__('admin.assigned_bus'))->state(fn (User $record): ?string => $record->busAssignments->first()?->bus?->number)])->filters([SelectFilter::make('locale')->label(__('admin.locale'))->options(static::options(['en', 'ar', 'fr']))])->recordActions([ViewAction::make(), EditAction::make(), DeleteAction::make()]);
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListDrivers::route('/'), 'create' => Pages\CreateDriver::route('/create'), 'edit' => Pages\EditDriver::route('/{record}/edit'), 'view' => Pages\ViewDriver::route('/{record}')];
    }
}

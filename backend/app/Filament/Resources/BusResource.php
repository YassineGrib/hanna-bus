<?php

namespace App\Filament\Resources;

use App\Filament\RelationManagers\AssignmentsRelationManager;
use App\Filament\RelationManagers\InspectionsRelationManager;
use App\Filament\Resources\BusResource\Pages;
use App\Models\Bus;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Schemas\Schema;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class BusResource extends AdminResource
{
    protected static ?string $model = Bus::class;

    protected static ?string $recordTitleAttribute = 'number';

    protected const LABEL = 'buses';

    protected const READ_ONLY = false;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery();
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([static::input('number')->unique(ignoreRecord: true), static::input('line_name'), static::input('plate_number'), static::input('vehicle_model'), static::input('capacity')->integer()->minValue(1)->maxValue(200), Select::make('status')->label(__('admin.status'))->options(static::options(['available', 'in_service', 'workshop']))->required(), DatePicker::make('insurance_expires_on')->label(__('admin.insurance_expires_on')), DatePicker::make('technical_control_expires_on')->label(__('admin.technical_control_expires_on')), DatePicker::make('last_service_on')->label(__('admin.last_service_on'))]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([static::column('number'), static::column('line_name'), static::column('plate_number'), static::column('vehicle_model'), static::column('capacity'), static::status()])->filters([SelectFilter::make('status')->label(__('admin.status'))->options(static::options(['available', 'in_service', 'workshop']))])->recordActions([ViewAction::make(), EditAction::make(), DeleteAction::make()]);
    }

    public static function getRelations(): array
    {
        return [InspectionsRelationManager::class, AssignmentsRelationManager::class];
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListBuses::route('/'), 'create' => Pages\CreateBus::route('/create'), 'edit' => Pages\EditBus::route('/{record}/edit'), 'view' => Pages\ViewBus::route('/{record}')];
    }
}

<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AssignmentResource\Pages;
use App\Models\BusAssignment;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Validation\Rules\Unique;

class AssignmentResource extends AdminResource
{
    protected static ?string $model = BusAssignment::class;

    protected static ?string $recordTitleAttribute = 'date';

    protected const LABEL = 'assignments';

    protected const READ_ONLY = false;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['driver', 'bus']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([static::userSelect('driver_id', 'driver', 'driver')->unique(ignoreRecord: true, modifyRuleUsing: fn (Unique $rule, Get $get): Unique => $rule->where('date', $get('date')))->validationMessages(['unique' => __('admin.assignment_unique')]), Select::make('bus_id')->label(__('admin.bus_id'))->relationship('bus', 'number')->searchable()->preload()->required(), DatePicker::make('date')->label(__('admin.date'))->default(today())->live()->required()]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([static::column('date')->date(), static::column('driver.name', 'driver_id'), static::column('bus.number', 'bus_id')])->filters([static::dateFilter('date'), SelectFilter::make('bus_id')->label(__('admin.bus_id'))->relationship('bus', 'number')])->recordActions([ViewAction::make(), EditAction::make(), DeleteAction::make()])->defaultSort('date', 'desc');
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListAssignments::route('/'), 'create' => Pages\CreateAssignment::route('/create'), 'edit' => Pages\EditAssignment::route('/{record}/edit'), 'view' => Pages\ViewAssignment::route('/{record}')];
    }
}

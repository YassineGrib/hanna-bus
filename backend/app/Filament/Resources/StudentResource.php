<?php

namespace App\Filament\Resources;

use App\Filament\Resources\StudentResource\Pages;
use App\Models\Bus;
use App\Models\Child;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\KeyValue;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Components\View;
use Filament\Schemas\Schema;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class StudentResource extends AdminResource
{
    protected static ?string $model = Child::class;

    protected static ?string $recordTitleAttribute = 'full_name';

    protected const LABEL = 'students';

    protected const READ_ONLY = false;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with('parent');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([static::input('full_name'), static::input('student_code')->unique(ignoreRecord: true), static::userSelect('parent_id', 'parent', 'parent'), Select::make('bus_number')->label(__('admin.bus_number'))->options(fn (): array => Bus::orderBy('number')->pluck('number', 'number')->all())->searchable()->required(), Select::make('transit_status')->label(__('admin.transit_status'))->options(static::options(['on_bus', 'at_school', 'at_home', 'absent']))->default('at_home')->required(), Select::make('stage')->label(__('admin.stage'))->options(static::options(['preschool', 'primary', 'middle', 'secondary']))->required(), static::input('birth_date'), static::input('national_id'), static::input('school_name'), static::input('grade'), static::input('class_room'), static::input('homeroom_teacher'), static::input('transport_coordinator'), static::input('dismissal_rule'), static::input('seat_number'), static::input('stop_name'), static::input('stop_time'), static::input('return_time'), static::input('blood_type'), static::input('insurance_number'), static::input('allergies'), static::input('chronic_conditions'), static::input('pediatrician_name'), static::input('pediatrician_phone'), static::input('avatar_preset'), Textarea::make('first_aid_protocol')->label(__('admin.first_aid_protocol'))->maxLength(10000), KeyValue::make('schedule_json')->label(__('admin.schedule_json')), View::make('filament.student-qr')->visibleOn('view')]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([static::column('full_name'), static::column('student_code'), static::column('grade'), static::column('school_name'), static::column('parent.name', 'parent_id'), static::column('bus_number'), static::status('transit_status')])->filters([SelectFilter::make('bus_number')->label(__('admin.bus_number'))->options(fn (): array => Bus::pluck('number', 'number')->all()), SelectFilter::make('transit_status')->label(__('admin.transit_status'))->options(static::options(['on_bus', 'at_school', 'at_home', 'absent']))])->recordActions([ViewAction::make(), EditAction::make(), DeleteAction::make()]);
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListStudents::route('/'), 'create' => Pages\CreateStudent::route('/create'), 'edit' => Pages\EditStudent::route('/{record}/edit'), 'view' => Pages\ViewStudent::route('/{record}')];
    }
}

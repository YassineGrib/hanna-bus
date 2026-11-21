<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BulletinResource\Pages;
use App\Models\SchoolBulletin;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class BulletinResource extends AdminResource
{
    protected static ?string $model = SchoolBulletin::class;

    protected static ?string $recordTitleAttribute = 'title_en';

    protected const LABEL = 'bulletins';

    protected const GROUP = 'nav_communication';

    protected const ICON = 'megaphone';

    protected const SORT = 1;

    protected const READ_ONLY = false;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery();
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([static::input('tag'), static::input('title_en'), static::input('title_ar'), static::input('title_fr'), Textarea::make('body_en')->label(__('admin.body_en'))->required()->maxLength(20000), Textarea::make('body_ar')->label(__('admin.body_ar'))->required()->maxLength(20000), Textarea::make('body_fr')->label(__('admin.body_fr'))->required()->maxLength(20000), DateTimePicker::make('published_at')->label(__('admin.published_at'))]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([static::column('title_'.app()->getLocale(), 'title'), static::column('tag'), static::column('published_at')->dateTime()])->filters([TernaryFilter::make('published_at')->label(__('admin.published_at'))->nullable()])->recordActions([ViewAction::make(), EditAction::make(), DeleteAction::make()])->defaultSort('published_at', 'desc');
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListBulletins::route('/'), 'create' => Pages\CreateBulletin::route('/create'), 'edit' => Pages\EditBulletin::route('/{record}/edit'), 'view' => Pages\ViewBulletin::route('/{record}')];
    }
}

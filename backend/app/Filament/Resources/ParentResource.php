<?php

namespace App\Filament\Resources;

use App\Filament\RelationManagers\ChildrenRelationManager;
use App\Filament\Resources\ParentResource\Pages;
use App\Models\User;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ParentResource extends AdminResource
{
    protected static ?string $model = User::class;

    protected static ?string $recordTitleAttribute = 'name';

    protected const LABEL = 'parents';

    protected const GROUP = 'nav_people';

    protected const ICON = 'users';

    protected const SORT = 2;

    protected const READ_ONLY = false;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('role', 'parent');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([static::input('name'), static::input('email')->email()->unique(ignoreRecord: true), static::input('phone', false)->tel(), static::input('backup_phone', false)->tel(), Select::make('locale')->label(__('admin.locale'))->options(static::options(['en', 'ar', 'fr']))->required()->default('en'), TextInput::make('password')->label(__('admin.password'))->password()->revealable()->minLength(12)->maxLength(255)->required(fn (string $operation): bool => $operation === 'create')->afterStateHydrated(fn (TextInput $component) => $component->state(null))->dehydrated(fn (?string $state): bool => filled($state))->hiddenOn('view')]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([static::column('name'), static::column('email'), static::column('phone'), static::column('locale')])->filters([SelectFilter::make('locale')->label(__('admin.locale'))->options(static::options(['en', 'ar', 'fr']))])->recordActions([ViewAction::make(), EditAction::make(), DeleteAction::make()]);
    }

    public static function getRelations(): array
    {
        return [ChildrenRelationManager::class];
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListParents::route('/'), 'create' => Pages\CreateParent::route('/create'), 'edit' => Pages\EditParent::route('/{record}/edit'), 'view' => Pages\ViewParent::route('/{record}')];
    }
}

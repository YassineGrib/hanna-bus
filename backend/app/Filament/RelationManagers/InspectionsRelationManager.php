<?php

namespace App\Filament\RelationManagers;

use App\Filament\Resources\AdminResource;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class InspectionsRelationManager extends RelationManager
{
    protected static string $relationship = 'inspections';

    public static function getTitle(Model $ownerRecord, string $pageClass): string
    {
        return __('admin.inspections');
    }

    public static function canViewForRecord(Model $ownerRecord, string $pageClass): bool
    {
        return auth()->user()?->role === 'admin';
    }

    public function isReadOnly(): bool
    {
        return true;
    }

    public function table(Table $table): Table
    {
        return $table->modifyQueryUsing(fn (Builder $query): Builder => $query->with('driver'))->columns([AdminResource::column('date')->date(), AdminResource::column('driver.name', 'driver_id'), IconColumn::make('passed')->label(__('admin.passed'))->boolean(), AdminResource::column('items_json')->formatStateUsing(fn ($state): string => is_bool($state) ? ($state ? __('admin.yes') : __('admin.no')) : (string) $state)])->recordActions([])->headerActions([]);
    }
}

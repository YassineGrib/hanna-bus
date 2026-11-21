<?php

namespace App\Filament\RelationManagers;

use App\Filament\Resources\AdminResource;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class StationsRelationManager extends RelationManager
{
    protected static string $relationship = 'stations';

    public static function getTitle(Model $ownerRecord, string $pageClass): string
    {
        return __('admin.stations');
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
        return $table->modifyQueryUsing(fn (Builder $query): Builder => $query)->columns([AdminResource::column('sort_order'), AdminResource::column('name_'.app()->getLocale(), 'stop_name'), AdminResource::column('scheduled_time'), AdminResource::status()])->recordActions([])->headerActions([]);
    }
}

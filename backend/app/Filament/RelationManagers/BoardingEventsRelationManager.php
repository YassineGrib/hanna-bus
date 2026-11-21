<?php

namespace App\Filament\RelationManagers;

use App\Filament\Resources\AdminResource;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class BoardingEventsRelationManager extends RelationManager
{
    protected static string $relationship = 'boardingEvents';

    public static function getTitle(Model $ownerRecord, string $pageClass): string
    {
        return __('admin.boarding_events');
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
        return $table->modifyQueryUsing(fn (Builder $query): Builder => $query->with('child'))->columns([AdminResource::column('child.full_name', 'students'), AdminResource::status('type'), AdminResource::column('method')->formatStateUsing(fn (string $state): string => __('admin.'.$state)), AdminResource::column('recorded_at')->dateTime()])->recordActions([])->headerActions([]);
    }
}

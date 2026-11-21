<?php

namespace App\Filament\RelationManagers;

use App\Filament\Resources\AdminResource;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class AssignmentsRelationManager extends RelationManager
{
    protected static string $relationship = 'assignments';

    public static function getTitle(Model $ownerRecord, string $pageClass): string
    {
        return __('admin.assignments');
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
        return $table->modifyQueryUsing(fn (Builder $query): Builder => $query->with(['driver', 'bus']))->columns([AdminResource::column('date')->date(), AdminResource::column('driver.name', 'driver_id'), AdminResource::column('bus.number', 'bus_id')])->recordActions([])->headerActions([]);
    }
}

<?php

namespace App\Filament\RelationManagers;

use App\Filament\Resources\AdminResource;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class ChildrenRelationManager extends RelationManager
{
    protected static string $relationship = 'children';

    public static function getTitle(Model $ownerRecord, string $pageClass): string
    {
        return __('admin.students');
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
        return $table->modifyQueryUsing(fn (Builder $query): Builder => $query)->columns([AdminResource::column('full_name'), AdminResource::column('student_code'), AdminResource::column('school_name'), AdminResource::column('bus_number'), AdminResource::status('transit_status')])->recordActions([])->headerActions([]);
    }
}

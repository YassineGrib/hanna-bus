<?php

namespace App\Filament\RelationManagers;

use App\Filament\Resources\RouteResource;
use App\Models\Route;
use Filament\Actions\Action;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

class RoutesRelationManager extends RelationManager
{
    protected static string $relationship = 'routes';

    public static function getTitle(Model $ownerRecord, string $pageClass): string
    {
        return __('admin.routes');
    }

    public static function canViewForRecord(Model $ownerRecord, string $pageClass): bool
    {
        return auth()->user()?->role === 'admin';
    }

    public function table(Table $table): Table
    {
        return RouteResource::table($table)->recordActions([
            Action::make('edit')->label(__('admin.edit_route'))
                ->url(fn (Route $record): string => RouteResource::getUrl('edit', ['record' => $record])),
        ])->headerActions([
            Action::make('create')->label(__('admin.create_route'))
                ->url(fn (): string => RouteResource::getUrl('create', ['bus_id' => $this->getOwnerRecord()->getKey()])),
        ]);
    }
}

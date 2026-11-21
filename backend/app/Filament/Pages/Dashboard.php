<?php

namespace App\Filament\Pages;

use Filament\Support\Icons\Heroicon;

class Dashboard extends \Filament\Pages\Dashboard
{
    public static function canAccess(): bool
    {
        return auth()->user()?->role === 'admin';
    }

    public static function getNavigationLabel(): string
    {
        return __('admin.dashboard');
    }

    public static function getNavigationIcon(): Heroicon
    {
        return Heroicon::OutlinedSquares2x2;
    }

    public static function getNavigationSort(): ?int
    {
        return -1;
    }

    public function getTitle(): string
    {
        return __('admin.dashboard');
    }
}

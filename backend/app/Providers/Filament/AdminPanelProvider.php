<?php

namespace App\Providers\Filament;

use App\Filament\Pages\DailyPlanning;
use App\Filament\Pages\Dashboard;
use App\Filament\Widgets\FleetStats;
use App\Filament\Widgets\OpenAlerts;
use App\Filament\Widgets\TodaysTrips;
use App\Http\Middleware\AdminLocale;
use Filament\Actions\Action;
use Filament\Enums\ThemeMode;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Navigation\NavigationGroup;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\View\PanelsRenderHook;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel->default()->id('admin')->path('admin')->login()->brandName('Hanna Bus Admin')
            ->brandLogo(asset('images/hanna-bus-logo.png'))->brandLogoHeight('3rem')->colors(['primary' => Color::hex('#D4A017')])->darkMode()->defaultThemeMode(ThemeMode::Light)
            ->sidebarCollapsibleOnDesktop()
            ->navigationGroups([
                NavigationGroup::make()->label(fn (): string => __('admin.nav_operations')),
                NavigationGroup::make()->label(fn (): string => __('admin.nav_fleet')),
                NavigationGroup::make()->label(fn (): string => __('admin.nav_people')),
                NavigationGroup::make()->label(fn (): string => __('admin.nav_communication')),
            ])
            ->renderHook(PanelsRenderHook::HEAD_END, fn (): string => view('filament.background')->render())
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->pages([Dashboard::class, DailyPlanning::class])
            ->widgets([FleetStats::class, TodaysTrips::class, OpenAlerts::class])
            ->middleware([
                EncryptCookies::class, AddQueuedCookiesToResponse::class,
                StartSession::class, AuthenticateSession::class,
                ShareErrorsFromSession::class, VerifyCsrfToken::class,
                SubstituteBindings::class, DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])->authMiddleware([Authenticate::class, AdminLocale::class], isPersistent: true)
            ->userMenuItems([
                Action::make('language')->label(fn (): string => __('admin.switch_language'))
                    ->url(fn (): string => route('admin.locale', ['locale' => app()->getLocale() === 'ar' ? 'en' : 'ar']))->postToUrl(),
            ]);
    }
}

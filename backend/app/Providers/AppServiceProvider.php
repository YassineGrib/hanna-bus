<?php

namespace App\Providers;

use App\Support\Trilingual;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('driver-location', fn (Request $request) => Limit::perMinute(30)->by($request->user()->id));
        RateLimiter::for('login', function (Request $request) {
            $email = $request->input('email');

            return Limit::perMinute(5)
                ->by(hash('sha256', (is_string($email) ? mb_strtolower(trim($email)) : '').'|'.$request->ip()))
                ->response(fn (Request $request, array $headers) => response()->json([
                    'message' => Trilingual::pick(Trilingual::lang($request),
                        'Too many login attempts. Try again in one minute.',
                        'محاولات تسجيل الدخول كثيرة. حاول مجدداً بعد دقيقة.',
                        'Trop de tentatives de connexion. Réessayez dans une minute.'),
                ], 429, $headers));
        });
    }
}

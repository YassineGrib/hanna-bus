<?php

namespace App\Support;

use Illuminate\Http\Request;

class Trilingual
{
    public static function lang(Request $request): string
    {
        $raw = strtolower((string) ($request->query('lang') ?? $request->header('Accept-Language') ?? 'en'));
        if (str_starts_with($raw, 'ar')) {
            return 'ar';
        }
        if (str_starts_with($raw, 'fr')) {
            return 'fr';
        }

        return 'en';
    }

    public static function pick(string $lang, string $en, string $ar, string $fr): string
    {
        return match ($lang) {
            'ar' => $ar,
            'fr' => $fr,
            default => $en,
        };
    }
}

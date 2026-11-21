<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Support\Trilingual;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class DriverSettingsController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $defaults = config('hanna.driver_settings');

        return response()->json(array_replace($defaults,
            array_intersect_key($request->user()->driverProfile?->settings_json ?? [], $defaults)));
    }

    public function update(Request $request): JsonResponse
    {
        $rules = [
            'voice_guidance' => ['sometimes', 'boolean'],
            'speed_chime' => ['sometimes', 'boolean'],
            'glare_mode' => ['sometimes', 'in:auto,day,night'],
            'radar_radius_m' => ['sometimes', 'integer', 'between:100,1000'],
            'scan_mode' => ['sometimes', 'in:camera,bluetooth'],
            'scan_chime' => ['sometimes', 'boolean'],
            'biometric_unlock' => ['sometimes', 'boolean'],
            'quick_pin_enabled' => ['sometimes', 'boolean'],
            'privacy_lock_minutes' => ['sometimes', 'integer', 'between:1,30'],
            'theme_palette' => ['sometimes', 'in:mustard,teal-gray,ocean-blue'],
            'brightness_mode' => ['sometimes', 'in:light,dark,auto'],
        ];
        $unknown = array_diff(array_keys($request->json()->all()), array_keys($rules));
        if ($unknown) {
            $message = Trilingual::pick(Trilingual::lang($request), 'Unknown setting.', 'إعداد غير معروف.', 'Paramètre inconnu.');
            throw ValidationException::withMessages(array_fill_keys($unknown, $message));
        }
        $v = $request->validate($rules);
        foreach (['voice_guidance', 'speed_chime', 'scan_chime', 'biometric_unlock', 'quick_pin_enabled'] as $key) {
            if (array_key_exists($key, $v)) {
                $v[$key] = (bool) $v[$key];
            }
        }
        foreach (['radar_radius_m', 'privacy_lock_minutes'] as $key) {
            if (array_key_exists($key, $v)) {
                $v[$key] = (int) $v[$key];
            }
        }

        return DB::transaction(function () use ($request, $v) {
            $request->user()->newQuery()->whereKey($request->user()->id)->lockForUpdate()->firstOrFail();
            $profile = $request->user()->driverProfile()->firstOrCreate([], ['license_number' => '']);
            $settings = array_replace(config('hanna.driver_settings'),
                array_intersect_key($profile->settings_json ?? [], config('hanna.driver_settings')), $v);
            $profile->update(['settings_json' => $settings]);

            return response()->json($settings);
        });
    }

    public function contacts(Request $request): JsonResponse
    {
        $lang = Trilingual::lang($request);

        return response()->json([
            'emergency' => collect(config('hanna.emergency'))->map(fn ($contact) => [
                'key' => $contact['key'], 'phone' => $contact['phone'],
                'label' => Trilingual::pick($lang, $contact['label_en'], $contact['label_ar'], $contact['label_fr']),
            ]),
            'school' => config('hanna.school'), 'coordinator' => config('hanna.coordinator'),
        ]);
    }
}

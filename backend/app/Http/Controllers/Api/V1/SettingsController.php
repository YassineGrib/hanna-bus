<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\TransitAlertSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    public function getProfile(Request $request): JsonResponse
    {
        return response()->json($request->user());
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();
        $v = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'email' => ['sometimes', 'email', 'max:190', 'unique:users,email,'.$user->id],
            'phone' => ['sometimes', 'nullable', 'string', 'max:40'],
            'backup_phone' => ['sometimes', 'nullable', 'string', 'max:40'],
            'primary_bus_stop' => ['sometimes', 'string', 'max:160'],
            'avatar_preset' => ['sometimes', 'string', 'max:40'],
        ]);

        $user->update($v);

        return response()->json($user->fresh());
    }

    public function updatePreferences(Request $request): JsonResponse
    {
        $v = $request->validate([
            'theme_palette' => ['sometimes', 'in:mustard,tealGray,ocean'],
            'brightness_mode' => ['sometimes', 'in:light,dark'],
            'locale' => ['sometimes', 'in:en,ar,fr'],
        ]);

        $user = $request->user();
        $user->update($v);

        return response()->json([
            'theme_palette' => $user->theme_palette,
            'brightness_mode' => $user->brightness_mode,
            'locale' => $user->locale,
        ]);
    }

    public function getAlerts(Request $request): JsonResponse
    {
        $settings = TransitAlertSetting::firstOrCreate(['parent_id' => $request->user()->id]);

        return response()->json($settings);
    }

    public function updateAlerts(Request $request): JsonResponse
    {
        $v = $request->validate([
            'global_radius_meters' => ['sometimes', 'integer', 'min:100', 'max:2000'],
            'bus_approaching' => ['sometimes', 'boolean'],
            'child_boarded' => ['sometimes', 'boolean'],
            'arrived_safely' => ['sometimes', 'boolean'],
            'route_delays' => ['sometimes', 'boolean'],
            'critical_sos_sound' => ['sometimes', 'boolean'],
            'sms_backup' => ['sometimes', 'boolean'],
        ]);

        $settings = TransitAlertSetting::firstOrCreate(['parent_id' => $request->user()->id]);
        $settings->update($v);

        return response()->json($settings->fresh());
    }

    public function emergencyContacts(Request $request): JsonResponse
    {
        return response()->json([
            'data' => [
                [
                    'id' => 'sos-driver-04',
                    'type' => 'driver',
                    'title_en' => 'Call Bus 04 Driver',
                    'title_ar' => 'اتصال بسائق الحافلة 04',
                    'title_fr' => 'Appeler chauffeur Bus 04',
                    'subtitle_en' => 'Ahmed Benali · Direct cab phone',
                    'subtitle_ar' => 'أحمد بن علي · هاتف المقصورة المباشر',
                    'subtitle_fr' => 'Ahmed Benali · Ligne directe',
                    'phone' => '+213 550 77 88 99',
                    'is_urgent' => false,
                ],
                [
                    'id' => 'sos-supervisor',
                    'type' => 'supervisor',
                    'title_en' => 'Transport Supervisor',
                    'title_ar' => 'مشرف النقل المدرسي',
                    'title_fr' => 'Superviseur transport',
                    'subtitle_en' => 'Central safety desk · Priority line',
                    'subtitle_ar' => 'مكتب الأمان المركزي · خط أولوية',
                    'subtitle_fr' => 'Bureau securite · Ligne prioritaire',
                    'phone' => '+213 21 55 44 33',
                    'is_urgent' => false,
                ],
                [
                    'id' => 'sos-civil',
                    'type' => 'emergency',
                    'title_en' => 'Civil Protection · SOS',
                    'title_ar' => 'الحماية المدنية / الطوارئ',
                    'title_fr' => 'Protection civile · SOS',
                    'subtitle_en' => 'National emergency response · 14',
                    'subtitle_ar' => 'الخط الوطني للطوارئ · 14',
                    'subtitle_fr' => 'Urgences nationales · 14',
                    'phone' => '14',
                    'is_urgent' => true,
                ],
            ],
        ]);
    }
}

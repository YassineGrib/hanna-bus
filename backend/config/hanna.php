<?php

return [
    'school' => [
        'name' => env('HANNA_SCHOOL_NAME', 'Hanna School'),
        'phone' => env('HANNA_SCHOOL_PHONE', '+213 21 74 30 30'),
    ],
    'coordinator' => [
        'name' => env('HANNA_COORDINATOR_NAME', 'Tarek Mansouri'),
        'phone' => env('HANNA_COORDINATOR_PHONE', '+213 550 00 11 22'),
    ],
    'emergency' => [
        ['key' => 'civil_protection', 'phone' => '14', 'label_en' => 'Civil Protection',
            'label_ar' => 'الحماية المدنية', 'label_fr' => 'Protection civile'],
        ['key' => 'police', 'phone' => '17', 'label_en' => 'Police',
            'label_ar' => 'الشرطة', 'label_fr' => 'Police'],
    ],
    'driver_settings' => [
        'voice_guidance' => true,
        'speed_chime' => true,
        'glare_mode' => 'auto',
        'radar_radius_m' => 300,
        'scan_mode' => 'camera',
        'scan_chime' => true,
        'biometric_unlock' => false,
        'quick_pin_enabled' => false,
        'privacy_lock_minutes' => 5,
        'theme_palette' => 'mustard',
        'brightness_mode' => 'auto',
    ],
];

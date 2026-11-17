<?php

namespace Database\Seeders;

use App\Models\ActiveTrip;
use App\Models\Child;
use App\Models\SafetyNotification;
use App\Models\SchoolBulletin;
use App\Models\TransitAlertSetting;
use App\Models\TripHistory;
use App\Models\TripStation;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class ParentPortalDemoSeeder extends Seeder
{
    public function run(): void
    {
        $parent = User::updateOrCreate(
            ['email' => 'k.mansouri@mail.dz'],
            [
                'name' => 'Karim Mansouri',
                'phone' => '+213 550 12 34 56',
                'backup_phone' => '+213 551 98 76 54',
                'password' => Hash::make('Password123!'),
                'role' => 'parent',
                'is_verified' => true,
                'primary_bus_stop' => 'Hay El Nasr, Algiers',
                'theme_palette' => 'mustard',
                'brightness_mode' => 'light',
                'locale' => 'en',
            ]
        );

        TransitAlertSetting::updateOrCreate(
            ['parent_id' => $parent->id],
            [
                'global_radius_meters' => 400,
                'bus_approaching' => true,
                'child_boarded' => true,
                'arrived_safely' => true,
                'route_delays' => false,
                'critical_sos_sound' => true,
                'sms_backup' => true,
            ]
        );

        Child::updateOrCreate(
            ['id' => 'child-youssef'],
            [
                'parent_id' => $parent->id,
                'student_code' => 'HB-304',
                'full_name' => 'Youssef Mansouri',
                'birth_date' => '14 March 2018 (8 yrs)',
                'national_id' => '180349',
                'stage' => 'primary',
                'school_name' => 'El Wiam Primary School',
                'grade' => 'Grade 3',
                'class_room' => 'Section B (Rm 14)',
                'homeroom_teacher' => 'Mrs. Nadia Khelifi',
                'transport_coordinator' => 'Mr. Tarek M.',
                'dismissal_rule' => 'Bus only · Parent PIN required for walk-out',
                'bus_number' => '04',
                'seat_number' => 'A2',
                'stop_name' => 'Hay El Nasr, Stop 03',
                'stop_time' => '07:15 AM',
                'return_time' => '03:20 PM',
                'transit_status' => 'on_bus',
                'blood_type' => 'O+',
                'insurance_number' => 'CNAS #88412',
                'allergies' => 'None reported · Verified Oct 2026',
                'chronic_conditions' => 'Mild Exercise Asthma',
                'first_aid_protocol' => 'Seat in front row near fresh air. Assist with 2 puffs of blue Ventolin inhaler in front pocket and call parent immediately.',
                'pediatrician_name' => 'Dr. Amine Boudiaf',
                'pediatrician_phone' => '+213 21 65 44 12',
            ]
        );

        Child::updateOrCreate(
            ['id' => 'child-amina'],
            [
                'parent_id' => $parent->id,
                'student_code' => 'HB-208',
                'full_name' => 'Amina Mansouri',
                'birth_date' => '22 September 2014 (12 yrs)',
                'national_id' => '140922',
                'stage' => 'middle',
                'school_name' => 'Ibn Khaldoun Middle',
                'grade' => 'Grade 6',
                'class_room' => 'Section A (Rm 08)',
                'homeroom_teacher' => 'Mr. Samir Rahmani',
                'transport_coordinator' => 'Mr. Tarek M.',
                'dismissal_rule' => 'Gate B checked departure',
                'bus_number' => '02',
                'seat_number' => 'B4',
                'stop_name' => 'Hay El Nasr, Stop 03',
                'stop_time' => '07:10 AM',
                'return_time' => '04:00 PM',
                'transit_status' => 'at_school',
                'blood_type' => 'A+',
                'insurance_number' => 'CNAS #88413',
                'allergies' => 'No Medical Alerts',
                'chronic_conditions' => 'None',
                'first_aid_protocol' => 'Standard school nurse protocol.',
                'pediatrician_name' => 'Dr. Amine Boudiaf',
                'pediatrician_phone' => '+213 21 65 44 12',
            ]
        );

        Child::updateOrCreate(
            ['id' => 'child-rayan'],
            [
                'parent_id' => $parent->id,
                'student_code' => 'HB-105',
                'full_name' => 'Rayan Mansouri',
                'birth_date' => '05 January 2021 (5 yrs)',
                'national_id' => '210105',
                'stage' => 'preschool',
                'school_name' => 'Al Manar Preschool',
                'grade' => 'KG 2',
                'class_room' => 'Sunflower Room',
                'homeroom_teacher' => 'Ms. Meriem Haddad',
                'transport_coordinator' => 'Mr. Tarek M.',
                'dismissal_rule' => 'Direct guardian handoff at stop',
                'bus_number' => '04',
                'seat_number' => 'A1',
                'stop_name' => 'Hay El Nasr, Stop 03',
                'stop_time' => '08:15 AM',
                'return_time' => '03:00 PM',
                'transit_status' => 'at_home',
                'blood_type' => 'O+',
                'insurance_number' => 'CNAS #88414',
                'allergies' => 'Peanut Allergy',
                'chronic_conditions' => 'Peanut Allergy (EpiPen in kit)',
                'first_aid_protocol' => 'Strictly avoid nut products. Carry emergency contact card at all times.',
                'pediatrician_name' => 'Dr. Amine Boudiaf',
                'pediatrician_phone' => '+213 21 65 44 12',
            ]
        );

        // Unassigned child available for school-code linking demo
        Child::updateOrCreate(
            ['id' => 'child-linkable'],
            [
                'parent_id' => null,
                'student_code' => 'HB-2026-9911',
                'full_name' => 'Lina Mansouri',
                'stage' => 'primary',
                'school_name' => 'El Wiam Primary School',
                'grade' => 'Grade 1',
                'bus_number' => '04',
                'seat_number' => 'A4',
                'stop_name' => 'Hay El Nasr, Stop 03',
                'transit_status' => 'at_home',
            ]
        );

        $trip04 = ActiveTrip::updateOrCreate(
            ['id' => 'trip-04-am'],
            [
                'bus_number' => '04',
                'route_name' => 'Morning Route 04',
                'driver_name' => 'Ahmed Benali',
                'driver_phone' => '+213 550 77 88 99',
                'vehicle_model' => 'Mercedes Sprinter',
                'plate_number' => '04821-116',
                'is_morning' => true,
                'eta_minutes' => 4,
                'distance_km' => 1.2,
                'speed_kmh' => 38,
                'progress' => 0.68,
                'onboard_count' => 19,
                'capacity' => 24,
                'current_street' => 'Blvd des Martyrs',
                'status' => 'en_route',
            ]
        );

        TripStation::where('trip_id', $trip04->id)->delete();
        $stations = [
            [1, 'Central Depot', 'المستودع المركزي', 'Depot Central', '07:05 AM', 'Departed on schedule', 'انطلقت في الموعد المحدّد', 'Depart a l heure', 'completed'],
            [2, 'Hay El Nasr (Stop 03)', 'حي النصر (محطة 03)', 'Hay El Nasr (Arret 03)', '07:16 AM', 'Youssef boarded · QR #HB-304', 'صعد يوسف · مسح البطاقة #HB-304', 'Youssef monte · QR #HB-304', 'completed'],
            [3, 'Algiers Square', 'ساحة الجزائر', 'Place d Alger', '07:28 AM', '3 students boarded', 'صعود 3 تلاميذ', '3 eleves montes', 'completed'],
            [4, 'Blvd des Martyrs', 'شارع الشهداء', 'Bd des Martyrs', '07:34 AM', 'LIVE NOW · Bus 04 is passing here', 'الآن مباشر · الحافلة 04 تمرّ من هنا', 'EN DIRECT · Bus 04 ici', 'current'],
            [5, 'El Wiam Primary Gate', 'بوابة مدرسة الوئام', 'Portail El Wiam', '07:40 AM', 'Destination · East Student Gate', 'الوجهة النهائية · البوابة الشرقية', 'Destination · Portail Est', 'upcoming'],
        ];
        foreach ($stations as [$ord, $nen, $nar, $nfr, $tm, $sen, $sar, $sfr, $st]) {
            TripStation::create([
                'trip_id' => $trip04->id,
                'sort_order' => $ord,
                'name_en' => $nen,
                'name_ar' => $nar,
                'name_fr' => $nfr,
                'scheduled_time' => $tm,
                'subtitle_en' => $sen,
                'subtitle_ar' => $sar,
                'subtitle_fr' => $sfr,
                'status' => $st,
            ]);
        }

        TripHistory::updateOrCreate(
            ['id' => '9042'],
            [
                'child_id' => 'child-youssef',
                'bus_number' => '04',
                'period' => 'morning',
                'trip_date' => '2026-11-09',
                'date_group_en' => 'Yesterday · Mon 09 Nov',
                'date_group_ar' => 'أمس · الإثنين 09 نوفمبر',
                'date_group_fr' => 'Hier · Lun 09 Nov',
                'departure_time' => '07:15 AM',
                'arrival_time' => '07:39 AM',
                'duration_minutes' => 24,
                'distance_km' => 6.8,
                'avg_speed_kmh' => 32,
                'status_code' => 'completed',
                'delay_minutes' => 0,
                'driver_name' => 'Ahmed Benali',
                'driver_rating' => 4.9,
                'vehicle_model' => 'Mercedes Sprinter',
                'waypoints_json' => [[0.15, 0.78], [0.35, 0.64], [0.55, 0.45], [0.72, 0.32], [0.85, 0.22]],
                'qr_audit_json' => [
                    ['time' => '07:15:22 AM', 'event' => 'pickup', 'verifier' => 'Driver Ahmed B.'],
                    ['time' => '07:39:10 AM', 'event' => 'school_checkin', 'verifier' => 'Supervisor Tarek M.'],
                ],
            ]
        );

        TripHistory::updateOrCreate(
            ['id' => '9041'],
            [
                'child_id' => 'child-youssef',
                'bus_number' => '04',
                'period' => 'return',
                'trip_date' => '2026-11-09',
                'date_group_en' => 'Yesterday · Mon 09 Nov',
                'date_group_ar' => 'أمس · الإثنين 09 نوفمبر',
                'date_group_fr' => 'Hier · Lun 09 Nov',
                'departure_time' => '03:22 PM',
                'arrival_time' => '03:46 PM',
                'duration_minutes' => 24,
                'distance_km' => 6.9,
                'avg_speed_kmh' => 31,
                'status_code' => 'completed',
                'delay_minutes' => 0,
                'driver_name' => 'Ahmed Benali',
                'driver_rating' => 4.9,
                'vehicle_model' => 'Mercedes Sprinter',
                'waypoints_json' => [[0.85, 0.22], [0.60, 0.42], [0.35, 0.64], [0.15, 0.78]],
                'qr_audit_json' => [
                    ['time' => '03:22:05 PM', 'event' => 'pickup', 'verifier' => 'Driver Ahmed B.'],
                    ['time' => '03:46:18 PM', 'event' => 'home_handoff', 'verifier' => 'Parent Karim M.'],
                ],
            ]
        );

        TripHistory::updateOrCreate(
            ['id' => '9039'],
            [
                'child_id' => 'child-youssef',
                'bus_number' => '04',
                'period' => 'return',
                'trip_date' => '2026-11-08',
                'date_group_en' => 'Sun 08 Nov',
                'date_group_ar' => 'الأحد 08 نوفمبر',
                'date_group_fr' => 'Dim 08 Nov',
                'departure_time' => '03:20 PM',
                'arrival_time' => '03:48 PM',
                'duration_minutes' => 28,
                'distance_km' => 6.9,
                'avg_speed_kmh' => 28,
                'status_code' => 'delayed',
                'delay_minutes' => 4,
                'driver_name' => 'Ahmed Benali',
                'driver_rating' => 4.9,
                'vehicle_model' => 'Mercedes Sprinter',
            ]
        );

        SafetyNotification::where('parent_id', $parent->id)->delete();
        $notifs = [
            ['bus', 'Approaching El Wiam Gate', 'الحافلة تقترب من المدرسة', 'Approche du portail El Wiam', 'Bus 04 is 4 min from school entrance.', 'الحافلة 04 على بُعد 4 دقائق من بوابة الوئام.', 'Le bus 04 est a 4 min de l entree.', 'today', '2m ago', false],
            ['bus', 'Youssef Boarded Bus 04', 'صعود يوسف للحافلة 04', 'Youssef est monte dans le Bus 04', 'QR #HB-304 scanned at Hay El Nasr Stop 03.', 'تم مسح البطاقة #HB-304 في محطة حي النصر 03.', 'QR #HB-304 scanne a Hay El Nasr.', 'today', '07:16 AM', false],
            ['school', 'Amina Arrived at School', 'وصول أمينة للمدرسة', 'Amina est arrivee a l ecole', 'Checked in safely at Ibn Khaldoun Middle.', 'تم تأكيد الدخول بأمان في متوسطة ابن خلدون.', 'Arrivee confirmee au CEM Ibn Khaldoun.', 'today', '07:42 AM', true],
            ['school', 'Thursday Early Dismissal', 'انصراف مبكّر يوم الخميس', 'Sortie anticipee jeudi', 'Afternoon buses depart at 02:30 PM this Thursday.', 'تنطلق حافلات العودة الساعة 02:30 م هذا الخميس.', 'Les bus partent a 14h30 ce jeudi.', 'yesterday', 'Mon 04:10 PM', true],
        ];
        foreach ($notifs as [$cat, $ten, $tar, $tfr, $ben, $bar, $bfr, $dg, $tm, $rd]) {
            SafetyNotification::create([
                'parent_id' => $parent->id,
                'category' => $cat,
                'title_en' => $ten,
                'title_ar' => $tar,
                'title_fr' => $tfr,
                'body_en' => $ben,
                'body_ar' => $bar,
                'body_fr' => $bfr,
                'day_group' => $dg,
                'time_label' => $tm,
                'is_read' => $rd,
            ]);
        }

        SchoolBulletin::query()->delete();
        $bulletins = [
            ['SCHEDULE', 'Early Dismissal This Thursday', 'انصراف مبكّر يوم الخميس القادم', 'Sortie anticipee ce jeudi', 'School closes at 02:15 PM. Bus 04 & Bus 02 depart at 02:30 PM.', 'ينتهي الدوام 02:15 م وتنطلق الحافلات الساعة 02:30 م.', 'Sortie a 14h15. Depart des bus a 14h30.'],
            ['STOP UPDATE', 'New Lighting at Hay El Nasr Stop 03', 'إنارة ومظلة جديدة لمحطة حي النصر 03', 'Nouvel eclairage a Hay El Nasr', 'Solar street lamps and shaded shelter installed for morning pickups.', 'تم تزويد المحطة بإنارة شمسية ومظلة انتظار لرحلات الصباح.', 'Lampadaires solaires et abri installes.'],
            ['TERM NOTICE', 'Winter Term Route Verification', 'تأكيد محطات الفصل الشتوي', 'Verification des arrets d hiver', 'Confirm home drop-off stops before 20 Nov in Profile.', 'يرجى مراجعة محطة النزول المعتمدة قبل 20 نوفمبر في ملفك.', 'Confirmez votre arret avant le 20 nov.'],
        ];
        foreach ($bulletins as $idx => [$tag, $ten, $tar, $tfr, $ben, $bar, $bfr]) {
            SchoolBulletin::create([
                'tag' => $tag,
                'title_en' => $ten,
                'title_ar' => $tar,
                'title_fr' => $tfr,
                'body_en' => $ben,
                'body_ar' => $bar,
                'body_fr' => $bfr,
                'published_at' => now()->subHours($idx * 6),
            ]);
        }
    }
}

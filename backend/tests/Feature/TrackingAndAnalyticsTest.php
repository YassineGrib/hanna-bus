<?php

namespace Tests\Feature;

use App\Models\ActiveTrip;
use App\Models\Child;
use App\Models\TripHistory;
use App\Models\TripStation;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TrackingAndAnalyticsTest extends TestCase
{
    use RefreshDatabase;

    public function test_active_trip_history_replay_and_analytics_endpoints(): void
    {
        $parent = User::create([
            'name' => 'Karim',
            'email' => 'karim@mail.dz',
            'password' => 'Password123!',
        ]);
        $child = Child::create([
            'id' => 'child-y',
            'parent_id' => $parent->id,
            'student_code' => 'HB-304',
            'full_name' => 'Youssef Mansouri',
            'school_name' => 'El Wiam Primary',
            'grade' => 'Grade 3',
            'bus_number' => '04',
            'stop_name' => 'Hay El Nasr',
        ]);

        $trip = ActiveTrip::create([
            'id' => 'trip-04-am',
            'bus_number' => '04',
            'route_name' => 'Morning Route 04',
            'driver_name' => 'Ahmed Benali',
            'driver_phone' => '+213 550 77 88 99',
            'eta_minutes' => 4,
            'distance_km' => 1.2,
            'speed_kmh' => 38,
            'progress' => 0.68,
        ]);

        TripStation::create([
            'trip_id' => $trip->id,
            'sort_order' => 1,
            'name_en' => 'Hay El Nasr (Stop 03)',
            'name_ar' => 'حي النصر (محطة 03)',
            'name_fr' => 'Hay El Nasr (Arret 03)',
            'scheduled_time' => '07:16 AM',
            'subtitle_en' => 'Youssef boarded · QR #HB-304',
            'subtitle_ar' => 'صعد يوسف · مسح البطاقة #HB-304',
            'subtitle_fr' => 'Youssef est monte · QR #HB-304',
            'status' => 'completed',
        ]);

        TripHistory::create([
            'id' => '9042',
            'child_id' => $child->id,
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
            'waypoints_json' => [[0.15, 0.78], [0.48, 0.50], [0.82, 0.22]],
            'qr_audit_json' => [
                ['time' => '07:15:22 AM', 'event' => 'pickup', 'verifier' => 'Driver Ahmed B.'],
                ['time' => '07:39:10 AM', 'event' => 'school_checkin', 'verifier' => 'Supervisor Tarek M.'],
            ],
        ]);

        TripHistory::create([
            'id' => '9041',
            'child_id' => $child->id,
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
        ]);

        $token = $parent->createToken('test')->plainTextToken;

        $this->withToken($token)
            ->withHeaders(['Accept-Language' => 'ar'])
            ->getJson("/api/v1/parent/tracking/active-trip?child_id={$child->id}")
            ->assertStatus(200)
            ->assertJsonPath('bus_number', '04')
            ->assertJsonPath('stations.0.name', 'حي النصر (محطة 03)');

        $this->withToken($token)
            ->getJson("/api/v1/parent/tracking/history?child_id={$child->id}&period=morning")
            ->assertStatus(200)
            ->assertJsonCount(1, 'trips')
            ->assertJsonPath('trips.0.id', '9042');

        $this->withToken($token)
            ->getJson('/api/v1/parent/tracking/trips/9042')
            ->assertStatus(200)
            ->assertJsonPath('id', '9042')
            ->assertJsonCount(3, 'waypoints')
            ->assertJsonCount(2, 'qr_audit');

        $this->withToken($token)
            ->getJson("/api/v1/parent/attendance/analytics?child_id={$child->id}")
            ->assertStatus(200)
            ->assertJsonStructure(['kpis' => ['completed', 'absences', 'missed_qr', 'on_time_rate'], 'weekly_regularity']);
    }
}

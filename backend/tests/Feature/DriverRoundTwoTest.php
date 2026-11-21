<?php

namespace Tests\Feature;

use App\Models\AbsenceReport;
use App\Models\ActiveTrip;
use App\Models\Bus;
use App\Models\BusAssignment;
use App\Models\BusInspection;
use App\Models\Child;
use App\Models\DriverProfile;
use App\Models\ParentOtpCode;
use App\Models\SupportMessage;
use App\Models\TripStation;
use App\Models\User;
use App\Support\DriverPortal;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Route;
use Laravel\Sanctum\Sanctum;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class DriverRoundTwoTest extends TestCase
{
    use RefreshDatabase;

    private User $driver;

    private User $parent;

    private Child $child;

    private ActiveTrip $trip;

    private TripStation $station;

    private const CHILD_KEYS = ['id', 'name', 'student_code', 'grade', 'stop_name', 'stop_time',
        'bus_number', 'seat_number', 'transit_status', 'avatar_preset', 'dismissal_rule', 'absent'];

    protected function setUp(): void
    {
        parent::setUp();
        Cache::flush(); // Isolate named limiter buckets, including repeated logins in data providers.
        $this->travelTo(now()->setDate(2026, 11, 23)->setTime(10, 0));
        $this->driver = User::factory()->create(['role' => 'driver', 'password' => 'Password123!']);
        $this->parent = User::factory()->create(['role' => 'parent', 'phone' => '0550000001', 'backup_phone' => '0550000002']);
        DriverProfile::create(['user_id' => $this->driver->id, 'license_number' => 'DZ-0457']);
        Bus::create(['id' => 'bus-04', 'number' => '04', 'line_name' => 'Line 04', 'plate_number' => '123',
            'vehicle_model' => 'Sprinter', 'capacity' => 24, 'status' => 'in_service']);
        BusAssignment::create(['driver_id' => $this->driver->id, 'bus_id' => 'bus-04', 'date' => today()]);
        $this->trip = ActiveTrip::create(['id' => 'trip-04', 'driver_id' => $this->driver->id,
            'bus_id' => 'bus-04', 'bus_number' => '04', 'route_name' => 'Line 04', 'status' => 'scheduled',
            'driver_name' => $this->driver->name, 'driver_phone' => '0550000000',
            'service_date' => today(), 'onboard_count' => 0]);
        $this->station = TripStation::create(['trip_id' => $this->trip->id, 'sort_order' => 1,
            'name_en' => 'Stop', 'name_ar' => 'المحطة', 'name_fr' => 'Arrêt', 'scheduled_time' => '07:15',
            'subtitle_en' => '', 'subtitle_ar' => '', 'subtitle_fr' => '']);
        $this->child = Child::create(['id' => 'child-1', 'parent_id' => $this->parent->id, 'student_code' => 'HB-304',
            'full_name' => 'Youssef', 'school_name' => 'School', 'grade' => '3', 'bus_number' => '04', 'stop_name' => 'Stop',
            'national_id' => 'SECRET-NATIONAL', 'insurance_number' => 'SECRET-INSURANCE', 'birth_date' => 'SECRET-BIRTH',
            'pediatrician_name' => 'SECRET-DOCTOR', 'pediatrician_phone' => 'SECRET-DOCTOR-PHONE',
            'blood_type' => 'A+', 'allergies' => 'Peanuts', 'chronic_conditions' => 'Asthma', 'first_aid_protocol' => 'Call guardian']);
    }

    private function asDriver(): static
    {
        Sanctum::actingAs($this->driver);

        return $this;
    }

    private function boarding(): array
    {
        return ['student_code' => $this->child->student_code, 'type' => 'boarded', 'method' => 'qr'];
    }

    public static function inactiveActions(): array
    {
        $cases = [];
        foreach (['scheduled', 'completed'] as $status) {
            foreach (['stations/1/arrive', 'delay', 'boarding', 'end'] as $action) {
                if ($status === 'completed' && $action === 'end') {
                    continue;
                }
                $cases[$status.' '.$action] = [$status, $action];
            }
        }

        return $cases;
    }

    #[DataProvider('inactiveActions')]
    public function test_inactive_trip_actions_are_conflicts_without_side_effects(string $status, string $action): void
    {
        $this->trip->update(['status' => $status]);
        $original = $this->trip->fresh()->attributesToArray();
        $action = str_replace('stations/1/', 'stations/'.$this->station->id.'/', $action);
        $this->asDriver()->postJson('/api/v1/driver/trips/trip-04/'.$action, [
            ...$this->boarding(), 'minutes' => 5, 'reason' => 'traffic', 'safety_walk_confirmed' => true,
        ])->assertConflict()->assertJsonStructure(['message']);
        $this->assertSame($original, $this->trip->fresh()->attributesToArray());
        $this->assertDatabaseCount('boarding_events', 0);
        $this->assertDatabaseCount('safety_notifications', 0);
        $this->assertDatabaseCount('trip_histories', 0);
        $this->assertSame(0, $this->driver->driverProfile->trips_count);
        $this->assertSame('upcoming', $this->station->fresh()->status);
        $this->getJson('/api/v1/driver/trips/trip-04/students')->assertOk();
        $this->getJson('/api/v1/driver/trips/today')->assertOk();
    }

    public function test_completed_end_is_idempotent_even_without_confirmation(): void
    {
        $this->trip->update(['status' => 'completed', 'ended_at' => now()->subHour()]);
        $endedAt = $this->trip->ended_at;
        $this->asDriver()->postJson('/api/v1/driver/trips/trip-04/end')->assertOk()->assertJsonPath('status', 'completed');
        $this->assertTrue($endedAt->equalTo($this->trip->fresh()->ended_at));
        $this->assertSame(0, $this->driver->driverProfile->trips_count);
        $this->assertDatabaseCount('trip_histories', 0);
    }

    public function test_dossier_is_minimised_and_includes_only_required_medical_and_guardian_details(): void
    {
        AbsenceReport::create(['parent_id' => $this->parent->id, 'child_id' => $this->child->id, 'absence_date' => today()]);
        $response = $this->asDriver()->getJson('/api/v1/driver/students/child-1')->assertOk()
            ->assertJsonPath('student.name', 'Youssef')->assertJsonPath('student.absent', true)
            ->assertJsonPath('transit.return_time', $this->child->fresh()->return_time)
            ->assertJsonPath('medical', ['blood_type' => 'A+', 'allergies' => 'Peanuts',
                'chronic_conditions' => 'Asthma', 'first_aid_protocol' => 'Call guardian'])
            ->assertJsonPath('guardian', ['name' => $this->parent->name, 'phone' => '0550000001', 'backup_phone' => '0550000002']);
        $this->assertEqualsCanonicalizing(self::CHILD_KEYS, array_keys($response->json('student')));
        $this->getJson('/api/v1/driver/students/missing')->assertNotFound();
        $this->child->update(['bus_number' => '11']);
        $this->getJson('/api/v1/driver/students/child-1')->assertNotFound();
    }

    public function test_dossier_scope_includes_assigned_bus_without_trip_but_not_another_driver(): void
    {
        $this->trip->delete();
        $this->asDriver()->getJson('/api/v1/driver/students/child-1')->assertOk();
        BusAssignment::where('driver_id', $this->driver->id)->update(['date' => today()->subDay()->toDateString()]);
        $this->getJson('/api/v1/driver/students/child-1')->assertNotFound();
        $this->child->update(['parent_id' => null]);
        BusAssignment::where('driver_id', $this->driver->id)->update(['date' => today()->toDateString()]);
        $this->getJson('/api/v1/driver/students/child-1')->assertOk()
            ->assertJsonPath('guardian', ['name' => null, 'phone' => null, 'backup_phone' => null]);
    }

    public function test_profile_update_is_partial_validated_and_cannot_change_privileged_fields(): void
    {
        $this->asDriver()->putJson('/api/v1/driver/profile', ['name' => 'Ahmed', 'phone' => '0551234567', 'locale' => 'ar',
            'role' => 'parent', 'license_number' => 'forged', 'rating' => 1, 'email' => 'forged@example.com'])
            ->assertOk()->assertJsonPath('user.name', 'Ahmed')->assertJsonPath('user.phone', '0551234567')
            ->assertJsonPath('user.locale', 'ar')->assertJsonPath('user.role', 'driver')->assertJsonPath('license_number', 'DZ-0457');
        $this->putJson('/api/v1/driver/profile', ['phone' => '0559999999'])->assertOk()->assertJsonPath('user.name', 'Ahmed');
        $this->putJson('/api/v1/driver/profile', [])->assertOk();
        $this->assertSame($this->driver->email, $this->driver->fresh()->email);
        $this->assertNotSame('Ahmed', $this->parent->fresh()->name);
        $this->putJson('/api/v1/driver/profile', ['name' => '', 'phone' => [], 'locale' => 'fr'])
            ->assertUnprocessable()->assertJsonValidationErrors(['name', 'phone', 'locale']);
        $this->putJson('/api/v1/driver/profile', ['name' => str_repeat('a', 121), 'phone' => str_repeat('1', 41)])
            ->assertUnprocessable()->assertJsonValidationErrors(['name', 'phone']);
    }

    public function test_settings_defaults_partial_merge_all_keys_and_driver_isolation(): void
    {
        $defaults = config('hanna.driver_settings');
        $this->asDriver()->getJson('/api/v1/driver/settings')->assertOk()->assertExactJson($defaults);
        $settings = ['voice_guidance' => false, 'speed_chime' => false, 'glare_mode' => 'night', 'radar_radius_m' => 1000,
            'scan_mode' => 'bluetooth', 'scan_chime' => false, 'biometric_unlock' => true, 'quick_pin_enabled' => true,
            'privacy_lock_minutes' => 30, 'theme_palette' => 'ocean-blue', 'brightness_mode' => 'dark'];
        $this->putJson('/api/v1/driver/settings', $settings)->assertOk()->assertExactJson($settings);
        $this->putJson('/api/v1/driver/settings', ['radar_radius_m' => 100, 'privacy_lock_minutes' => 1])
            ->assertOk()->assertExactJson(array_replace($settings, ['radar_radius_m' => 100, 'privacy_lock_minutes' => 1]));
        $this->putJson('/api/v1/driver/settings', [])->assertOk()->assertJsonPath('scan_mode', 'bluetooth');
        $this->assertFalse($this->driver->driverProfile()->first()->settings_json['scan_chime']);
        $other = User::factory()->create(['role' => 'driver']);
        DriverProfile::create(['user_id' => $other->id, 'license_number' => 'OTHER', 'settings_json' => ['glare_mode' => 'day']]);
        Sanctum::actingAs($other);
        $this->getJson('/api/v1/driver/settings')->assertOk()->assertExactJson(array_replace($defaults, ['glare_mode' => 'day']));
        $this->putJson('/api/v1/driver/settings', ['scan_mode' => 'camera'])->assertOk();
        $this->assertSame('bluetooth', $this->driver->driverProfile()->first()->settings_json['scan_mode']);
    }

    public static function invalidSettings(): array
    {
        return [
            ['voice_guidance', 'yes'], ['speed_chime', null], ['scan_chime', []], ['biometric_unlock', 'enabled'],
            ['quick_pin_enabled', 2], ['glare_mode', 'dark'], ['radar_radius_m', 99], ['radar_radius_m', 1001],
            ['radar_radius_m', 100.5], ['privacy_lock_minutes', 0], ['privacy_lock_minutes', 31],
            ['scan_mode', 'qr'], ['theme_palette', 'blue'], ['brightness_mode', 'night'], ['unknown', true],
        ];
    }

    #[DataProvider('invalidSettings')]
    public function test_invalid_and_unknown_settings_are_rejected_atomically(string $key, mixed $value): void
    {
        $this->asDriver()->putJson('/api/v1/driver/settings?lang=fr', ['voice_guidance' => false, $key => $value])
            ->assertUnprocessable()->assertJsonValidationErrors([$key]);
        $this->assertNull($this->driver->driverProfile()->first()->settings_json);
    }

    public function test_contacts_and_profile_share_config_and_translate_emergency_labels(): void
    {
        config(['hanna.school' => ['name' => 'Custom School', 'phone' => '021123456'],
            'hanna.coordinator' => ['name' => 'Coordinator', 'phone' => '0551234567']]);
        foreach (['en' => 'Civil Protection', 'ar' => 'الحماية المدنية', 'fr' => 'Protection civile'] as $lang => $label) {
            $contacts = $this->asDriver()->withHeader('Accept-Language', $lang)->getJson('/api/v1/driver/contacts')
                ->assertOk()->assertJsonCount(2, 'emergency')->assertJsonPath('emergency.0.key', 'civil_protection')
                ->assertJsonPath('emergency.0.label', $label)->assertJsonPath('emergency.0.phone', '14')
                ->assertJsonPath('emergency.1.phone', '17')->json();
            $this->getJson('/api/v1/driver/profile')->assertOk()->assertJsonPath('school', $contacts['school'])
                ->assertJsonPath('coordinator', $contacts['coordinator']);
        }
    }

    public function test_vehicle_passport_dates_nullable_inspection_latest_and_driver_scope(): void
    {
        $this->asDriver()->getJson('/api/v1/driver/buses/bus-04')->assertOk()->assertJsonPath('last_inspection', null)
            ->assertJsonPath('insurance_expires_on', null)->assertJsonPath('technical_control_expires_on', null)
            ->assertJsonPath('last_service_on', null);
        Bus::findOrFail('bus-04')->update(['insurance_expires_on' => '2027-11-23',
            'technical_control_expires_on' => '2027-05-23', 'last_service_on' => '2026-10-23']);
        foreach ([2 => true, 1 => false] as $daysAgo => $passed) {
            BusInspection::create(['driver_id' => $this->driver->id, 'bus_id' => 'bus-04',
                'date' => today()->subDays($daysAgo), 'passed' => $passed, 'items_json' => ['brakes' => $passed]]);
        }
        $other = User::factory()->create(['role' => 'driver']);
        BusInspection::create(['driver_id' => $other->id, 'bus_id' => 'bus-04', 'date' => today(),
            'passed' => true, 'items_json' => ['brakes' => true]]);
        $this->getJson('/api/v1/driver/buses/bus-04')->assertOk()->assertJsonPath('insurance_expires_on', '2027-11-23')
            ->assertJsonPath('technical_control_expires_on', '2027-05-23')->assertJsonPath('last_service_on', '2026-10-23')
            ->assertJsonPath('last_inspection', ['date' => '2026-11-22', 'passed' => false]);
        $this->getJson('/api/v1/driver/buses/missing')->assertNotFound();
        Sanctum::actingAs($other);
        $this->getJson('/api/v1/driver/buses/bus-04')->assertNotFound();
    }

    public function test_telemetry_uses_only_todays_own_points_and_separates_trips(): void
    {
        $this->asDriver()->getJson('/api/v1/driver/telemetry/today')->assertOk()->assertExactJson([
            'max_speed_kmh' => 0, 'avg_speed_kmh' => 0, 'speeding_events' => 0,
            'distance_km' => 0, 'driving_minutes' => 0, 'trips' => 0,
        ]);
        $this->trip->update(['started_at' => today()->setTime(7, 0), 'ended_at' => today()->setTime(7, 30), 'status' => 'completed']);
        foreach ([[7, 0, 0, 40], [7, 10, 0.01, 60], [7, 20, 0.02, 80], [7, 25, 0.03, null]] as [$hour, $minute, $lat, $speed]) {
            $this->trip->locationPoints()->create(['lat' => $lat, 'lng' => 0, 'speed_kmh' => $speed,
                'recorded_at' => today()->setTime($hour, $minute)]);
        }
        $this->trip->locationPoints()->create(['lat' => 80, 'lng' => 80, 'speed_kmh' => 200, 'recorded_at' => today()->subSecond()]);
        $other = $this->trip->replicate();
        $other->id = 'other-trip';
        $other->driver_id = User::factory()->create(['role' => 'driver'])->id;
        $other->save();
        $other->locationPoints()->create(['lat' => 80, 'lng' => 80, 'speed_kmh' => 200, 'recorded_at' => now()]);
        $second = $this->trip->replicate();
        $second->id = 'second';
        $second->started_at = now()->subMinutes(15);
        $second->ended_at = null;
        $second->status = 'en_route';
        $second->save();
        $second->locationPoints()->create(['lat' => 80, 'lng' => 80, 'speed_kmh' => 0, 'recorded_at' => now()]);
        $this->getJson('/api/v1/driver/telemetry/today')->assertOk()->assertExactJson([
            'max_speed_kmh' => 80, 'avg_speed_kmh' => 45, 'speeding_events' => 1,
            'distance_km' => 3.34, 'driving_minutes' => 45, 'trips' => 2,
        ]);
    }

    public function test_telemetry_clips_overnight_driving_at_midnight_and_handles_null_speed(): void
    {
        $this->trip->update(['started_at' => today()->subMinutes(15), 'ended_at' => today()->addMinutes(20), 'status' => 'completed']);
        $this->trip->locationPoints()->create(['lat' => 0, 'lng' => 0, 'recorded_at' => today()->addMinute()]);
        $this->asDriver()->getJson('/api/v1/driver/telemetry/today')->assertOk()->assertJsonPath('driving_minutes', 20)
            ->assertJsonPath('max_speed_kmh', 0)->assertJsonPath('avg_speed_kmh', 0)->assertJsonPath('distance_km', 0);
    }

    public static function loginRoutes(): array
    {
        return [['/api/v1/driver/auth/login'], ['/api/v1/auth/login']];
    }

    #[DataProvider('loginRoutes')]
    public function test_login_throttle_handles_malformed_email_and_counts_successful_attempts(string $path): void
    {
        $this->postJson($path, ['email' => ['invalid'], 'password' => 'bad'])
            ->assertUnprocessable()->assertJsonValidationErrors('email');
        $user = $path === '/api/v1/auth/login' ? $this->parent : $this->driver;
        $user->update(['password' => 'Password123!']);
        for ($i = 0; $i < 5; $i++) {
            $this->postJson($path, ['email' => $user->email, 'password' => 'Password123!'])->assertOk();
        }
        $this->postJson($path, ['email' => $user->email, 'password' => 'Password123!'])->assertStatus(429);
    }

    #[DataProvider('loginRoutes')]
    public function test_login_throttle_is_per_email_and_ip_and_resets_after_a_minute(string $path): void
    {
        $credentials = ['email' => $this->driver->email, 'password' => 'bad'];
        for ($i = 0; $i < 5; $i++) {
            $this->postJson($path, $credentials)->assertUnauthorized();
        }
        $this->postJson($path.'?lang=fr', $credentials)->assertStatus(429)->assertJsonStructure(['message'])
            ->assertHeader('Retry-After')->assertJsonPath('message', 'Trop de tentatives de connexion. Réessayez dans une minute.');
        $this->postJson($path, ['email' => 'another@example.com', 'password' => 'bad'])->assertUnauthorized();
        $this->withServerVariables(['REMOTE_ADDR' => '192.0.2.2'])->postJson($path, $credentials)->assertUnauthorized();
        $this->withServerVariables(['REMOTE_ADDR' => '127.0.0.1']);
        $this->travel(61)->seconds();
        $this->postJson($path, ['email' => $this->driver->email, 'password' => 'Password123!'])->assertOk();
    }

    public function test_login_throttle_normalises_email_case_and_is_shared_between_login_routes(): void
    {
        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/v1/driver/auth/login', ['email' => $this->driver->email, 'password' => 'bad'])->assertUnauthorized();
        }
        $this->postJson('/api/v1/auth/login', ['email' => strtoupper($this->driver->email), 'password' => 'bad'])->assertStatus(429);
    }

    public function test_driver_password_recovery_rejects_invalid_otp_and_resets_password_with_a_driver_token(): void
    {
        $oldToken = $this->driver->createToken('hanna-driver');
        $email = $this->driver->email;
        $otp = $this->postJson('/api/v1/auth/forgot-password', ['email' => $email])->assertOk()->json('demo_otp');
        $this->postJson('/api/v1/auth/verify-otp', ['email' => $email, 'code' => '000000'])->assertUnprocessable();
        $this->postJson('/api/v1/auth/reset-password', ['email' => $email, 'reset_token' => 'invalid',
            'password' => 'NewPassword1!', 'password_confirmation' => 'NewPassword1!'])->assertUnprocessable();
        $resetToken = $this->postJson('/api/v1/auth/verify-otp', ['email' => $email, 'code' => $otp])
            ->assertOk()->assertJsonPath('verified', true)->json('reset_token');
        $body = ['email' => $email, 'reset_token' => $resetToken, 'password' => 'NewPassword1!', 'password_confirmation' => 'NewPassword1!'];
        $this->postJson('/api/v1/auth/reset-password', [...$body, 'password_confirmation' => 'mismatch'])->assertUnprocessable();
        $token = $this->postJson('/api/v1/auth/reset-password', $body)->assertOk()->assertJsonPath('user.role', 'driver')->json('token');
        $this->assertTrue(Hash::check('NewPassword1!', $this->driver->fresh()->password));
        $this->assertDatabaseMissing('personal_access_tokens', ['id' => $oldToken->accessToken->id]);
        $this->assertDatabaseHas('personal_access_tokens', ['tokenable_id' => $this->driver->id, 'name' => 'hanna-driver']);
        $this->assertDatabaseMissing('parent_otp_codes', ['email' => $email]);
        $this->postJson('/api/v1/auth/reset-password', $body)->assertUnprocessable();
        $this->postJson('/api/v1/driver/auth/login', ['email' => $email, 'password' => 'Password123!'])->assertUnauthorized();
        $this->postJson('/api/v1/driver/auth/login', ['email' => $email, 'password' => 'NewPassword1!'])->assertOk();
        $this->withToken($token)->getJson('/api/v1/driver/profile')->assertOk();
        $this->getJson('/api/v1/auth/me')->assertOk()->assertJsonPath('role', 'driver');
    }

    public function test_expired_driver_otp_and_reset_session_are_rejected(): void
    {
        $email = $this->driver->email;
        $otp = $this->postJson('/api/v1/auth/forgot-password', ['email' => $email])->assertOk()->json('demo_otp');
        $token = $this->postJson('/api/v1/auth/verify-otp', ['email' => $email, 'code' => $otp])->assertOk()->json('reset_token');
        ParentOtpCode::where('email', $email)->update(['expires_at' => now()->subSecond()]);
        $this->postJson('/api/v1/auth/verify-otp', ['email' => $email, 'code' => $otp])->assertUnprocessable();
        $this->postJson('/api/v1/auth/reset-password', ['email' => $email, 'reset_token' => $token,
            'password' => 'NewPassword1!', 'password_confirmation' => 'NewPassword1!'])->assertUnprocessable();
        $this->assertTrue(Hash::check('Password123!', $this->driver->fresh()->password));
    }

    public function test_parent_read_receipt_requires_auth_parent_role_and_ownership_and_is_idempotent(): void
    {
        $message = SupportMessage::create(['parent_id' => $this->parent->id, 'driver_id' => $this->driver->id,
            'child_id' => $this->child->id, 'recipient_type' => 'driver', 'direction' => 'driver_to_parent',
            'message' => 'Hello', 'status' => 'sent']);
        $url = '/api/v1/parent/support/messages/'.$message->id.'/read';
        $this->putJson($url)->assertUnauthorized();
        $this->asDriver()->putJson($url)->assertForbidden();
        Sanctum::actingAs(User::factory()->create(['role' => 'parent']));
        $this->putJson($url)->assertNotFound();
        $this->assertNull($message->fresh()->read_at);
        Sanctum::actingAs($this->parent);
        $this->putJson($url)->assertOk()->assertJsonPath('id', $message->id)->assertJsonPath('read_at', now()->toISOString());
        $this->travel(1)->minutes();
        $this->putJson($url)->assertOk()->assertJsonPath('read_at', $message->fresh()->read_at->toISOString());
        $this->putJson('/api/v1/parent/support/messages/9999/read')->assertNotFound();
    }

    public function test_parent_without_children_gets_a_translated_tracking_404_even_if_a_trip_exists(): void
    {
        Sanctum::actingAs(User::factory()->create(['role' => 'parent']));
        foreach (['en' => 'No children linked to this account.', 'ar' => 'لا يوجد أطفال مرتبطون بهذا الحساب.',
            'fr' => 'Aucun enfant lié à ce compte.'] as $lang => $message) {
            $this->withHeader('Accept-Language', $lang)->getJson('/api/v1/parent/tracking/active-trip?bus_number=04')
                ->assertNotFound()->assertJsonPath('message', $message);
        }
    }

    public function test_no_driver_response_exposes_private_child_fields(): void
    {
        $this->trip->update(['status' => 'en_route', 'started_at' => now()]);
        $this->asDriver();
        $boarding = $this->postJson('/api/v1/driver/trips/trip-04/boarding', $this->boarding())->assertCreated();
        $this->assertEqualsCanonicalizing(self::CHILD_KEYS, array_keys($boarding->json('child')));
        $repeat = $this->postJson('/api/v1/driver/trips/trip-04/boarding', $this->boarding())->assertOk();
        $this->assertEqualsCanonicalizing(self::CHILD_KEYS, array_keys($repeat->json('child')));
        $loaded = DriverPortal::children($this->trip)->first();
        $this->assertArrayNotHasKey('national_id', $loaded->getAttributes());
        $this->assertArrayNotHasKey('pediatrician_phone', $loaded->getAttributes());
        $this->postJson('/api/v1/driver/messages/'.$this->parent->id, ['child_id' => $this->child->id, 'message' => 'Hello'])->assertCreated();
        foreach (Route::getRoutes() as $route) {
            if (! str_starts_with($route->uri(), 'api/v1/driver/')) {
                continue;
            }
            $uri = str_replace(['{trip}', '{station}', '{child}', '{bus}', '{parent}'],
                [$this->trip->id, $this->station->id, $this->child->id, 'bus-04', $this->parent->id], $route->uri());
            $body = [...$this->boarding(), 'child_id' => $this->child->id, 'message' => 'Hello', 'type' => 'boarded',
                'minutes' => 5, 'reason' => 'traffic', 'safety_walk_confirmed' => true, 'lat' => 36.75, 'lng' => 3.05];
            if ($uri === 'api/v1/driver/settings') {
                $body = [];
            }
            if (in_array('GET', $route->methods(), true)) {
                $uri .= '?child_id='.$this->child->id;
            }
            $response = $this->json($route->methods()[0], '/'.$uri, $body);
            $this->assertLessThan(500, $response->status(), $uri);
            foreach (['national_id', 'insurance_number', 'birth_date', 'pediatrician_name', 'pediatrician_phone',
                'SECRET-NATIONAL', 'SECRET-INSURANCE', 'SECRET-BIRTH', 'SECRET-DOCTOR'] as $private) {
                $this->assertStringNotContainsString($private, $response->getContent(), $uri);
            }
        }
    }

    public function test_demo_seed_populates_vehicle_dates_and_settings_repeatably(): void
    {
        $this->child->delete();
        $this->seed();
        $this->seed();
        $driver = User::where('email', 'ahmed.benali@mail.dz')->firstOrFail();
        $this->assertSame(config('hanna.driver_settings'), $driver->driverProfile->settings_json);
        foreach (Bus::all() as $bus) {
            $this->assertNotNull($bus->insurance_expires_on);
            $this->assertNotNull($bus->technical_control_expires_on);
            $this->assertNotNull($bus->last_service_on);
        }
    }
}

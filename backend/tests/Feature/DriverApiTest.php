<?php

namespace Tests\Feature;

use App\Models\AbsenceReport;
use App\Models\ActiveTrip;
use App\Models\BoardingEvent;
use App\Models\Bus;
use App\Models\BusAssignment;
use App\Models\BusInspection;
use App\Models\Child;
use App\Models\DriverProfile;
use App\Models\SafetyNotification;
use App\Models\SupportMessage;
use App\Models\TripHistory;
use App\Models\TripStation;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Route;
use Laravel\Sanctum\Sanctum;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class DriverApiTest extends TestCase
{
    use RefreshDatabase;

    private User $driver;

    private User $parent;

    private Child $child;

    private ActiveTrip $trip;

    private TripStation $station;

    protected function setUp(): void
    {
        parent::setUp();
        $this->travelTo(now()->setDate(2026, 11, 23)->setTime(7, 0));
        $this->driver = User::factory()->create(['role' => 'driver', 'password' => 'Password123!']);
        $this->parent = User::factory()->create(['role' => 'parent']);
        DriverProfile::create(['user_id' => $this->driver->id, 'license_number' => 'DZ-D-2024-0457']);
        foreach (['04' => 'in_service', '07' => 'available', '11' => 'in_service', '02' => 'workshop'] as $number => $status) {
            $number = str_pad((string) $number, 2, '0', STR_PAD_LEFT);
            Bus::create(['id' => 'bus-'.$number, 'number' => $number, 'line_name' => 'Line '.$number,
                'plate_number' => 'plate-'.$number, 'vehicle_model' => 'Sprinter', 'capacity' => 24, 'status' => $status]);
        }
        BusAssignment::create(['driver_id' => $this->driver->id, 'bus_id' => 'bus-04', 'date' => today()]);
        $other = User::factory()->create(['role' => 'driver']);
        BusAssignment::create(['driver_id' => $other->id, 'bus_id' => 'bus-11', 'date' => today()]);
        $this->trip = ActiveTrip::create(['id' => 'trip-04', 'bus_id' => 'bus-04', 'bus_number' => '04',
            'driver_id' => $this->driver->id, 'route_name' => 'Morning 04', 'driver_name' => $this->driver->name,
            'driver_phone' => '0550000000', 'status' => 'scheduled', 'service_date' => today(),
            'scheduled_start' => today()->setTime(7, 5), 'onboard_count' => 0, 'progress' => 0,
            'route_points_json' => [[36.7538, 3.0588], [36.7545, 3.0597], [36.7552, 3.0601]]]);
        $foreign = $this->trip->replicate();
        $foreign->id = 'foreign';
        $foreign->driver_id = $other->id;
        $foreign->bus_id = 'bus-11';
        $foreign->bus_number = '11';
        $foreign->save();
        $this->station = TripStation::create(['trip_id' => $this->trip->id, 'sort_order' => 1,
            'name_en' => 'Hay El Nasr (Stop 03)', 'name_ar' => 'حي النصر', 'name_fr' => 'Hay El Nasr',
            'scheduled_time' => '07:15', 'subtitle_en' => '', 'subtitle_ar' => '', 'subtitle_fr' => '',
            'lat' => 36.7538, 'lng' => 3.0588]);
        $this->child = Child::create(['id' => 'child-1', 'parent_id' => $this->parent->id, 'student_code' => 'HB-304',
            'full_name' => 'Youssef', 'school_name' => 'School', 'grade' => '3', 'bus_number' => '04',
            'stop_name' => 'Hay El Nasr, Stop 03', 'transit_status' => 'at_home', 'allergies' => 'Peanut allergy']);
    }

    private function asDriver(): static
    {
        Sanctum::actingAs($this->driver);

        return $this;
    }

    private function inspection(): void
    {
        BusInspection::create(['driver_id' => $this->driver->id, 'bus_id' => 'bus-04', 'date' => today(),
            'items_json' => ['brakes' => true], 'passed' => true]);
    }

    public static function driverEndpoints(): array
    {
        return [
            ['GET', 'profile'], ['GET', 'buses'], ['GET', 'rotation'], ['PUT', 'bus'], ['POST', 'inspections'],
            ['GET', 'trips/today'], ['POST', 'trips/trip-04/start'], ['POST', 'trips/trip-04/location'],
            ['POST', 'trips/trip-04/stations/1/arrive'], ['POST', 'trips/trip-04/delay'], ['POST', 'trips/trip-04/end'],
            ['GET', 'trips/trip-04/students'], ['POST', 'trips/trip-04/boarding'], ['GET', 'messages'],
            ['GET', 'messages/1?child_id=child-1'], ['POST', 'messages/1'], ['GET', 'history'], ['GET', 'stats'], ['POST', 'sos'],
            ['GET', 'students/child-1'], ['PUT', 'profile'], ['GET', 'settings'], ['PUT', 'settings'],
            ['GET', 'contacts'], ['GET', 'telemetry/today'], ['GET', 'buses/bus-04'],
        ];
    }

    #[DataProvider('driverEndpoints')]
    public function test_every_driver_endpoint_requires_authentication(string $method, string $path): void
    {
        $this->json($method, '/api/v1/driver/'.$path)->assertUnauthorized();
    }

    #[DataProvider('driverEndpoints')]
    public function test_every_driver_endpoint_rejects_parent_role(string $method, string $path): void
    {
        Sanctum::actingAs($this->parent);
        $this->json($method, '/api/v1/driver/'.$path)->assertForbidden()->assertJsonStructure(['message']);
    }

    public function test_driver_login_and_shared_auth_endpoints(): void
    {
        $this->postJson('/api/v1/driver/auth/login', ['email' => $this->driver->email, 'password' => 'wrong'])->assertUnauthorized();
        $this->postJson('/api/v1/driver/auth/login', ['email' => $this->parent->email, 'password' => 'password'])->assertForbidden();
        $this->postJson('/api/v1/driver/auth/login', [])->assertUnprocessable()->assertJsonValidationErrors(['email', 'password']);
        $token = $this->postJson('/api/v1/driver/auth/login', ['email' => $this->driver->email, 'password' => 'Password123!'])
            ->assertOk()->assertJsonPath('user.role', 'driver')->json('token');
        $this->assertDatabaseHas('personal_access_tokens', ['tokenable_id' => $this->driver->id, 'name' => 'hanna-driver']);
        $this->withToken($token)->getJson('/api/v1/auth/me')->assertOk()->assertJsonPath('id', $this->driver->id);
        $this->withToken($token)->postJson('/api/v1/auth/logout')->assertOk();
        $this->assertDatabaseMissing('personal_access_tokens', ['tokenable_id' => $this->driver->id]);
    }

    public function test_profile_buses_and_rotation(): void
    {
        $this->asDriver()->getJson('/api/v1/driver/profile')->assertOk()
            ->assertJsonPath('license_number', 'DZ-D-2024-0457')->assertJsonPath('current_bus.number', '04');
        $buses = $this->getJson('/api/v1/driver/buses')->assertOk()->assertJsonCount(4)->json();
        $this->assertTrue(collect($buses)->firstWhere('number', '04')['is_current']);
        $this->assertFalse(collect($buses)->firstWhere('number', '07')['is_current']);
        $this->getJson('/api/v1/driver/rotation?week_of=2026-11-23')->assertOk()->assertJsonCount(5, 'days')
            ->assertJsonPath('days.0.date', '2026-11-22')->assertJsonPath('days.0.weekday', 'Sunday')
            ->assertJsonPath('days.0.bus_number', null)->assertJsonPath('days.1.bus_number', '04')->assertJsonPath('days.1.is_today', true);
        $this->getJson('/api/v1/driver/rotation')->assertOk()->assertJsonCount(5, 'days');
        $this->getJson('/api/v1/driver/rotation?week_of=no')->assertUnprocessable();
    }

    public function test_bus_rotation_conflicts_and_inspection_validation(): void
    {
        $this->asDriver()->putJson('/api/v1/driver/bus', ['bus_id' => 'bus-02'])->assertConflict();
        $this->putJson('/api/v1/driver/bus', ['bus_id' => 'bus-11'])->assertConflict();
        $this->trip->update(['status' => 'en_route']);
        $this->putJson('/api/v1/driver/bus', ['bus_id' => 'bus-07'])->assertConflict();
        $this->trip->update(['status' => 'scheduled']);
        $this->putJson('/api/v1/driver/bus', ['bus_id' => 'missing'])->assertUnprocessable();
        $this->putJson('/api/v1/driver/bus', ['bus_id' => 'bus-07', 'driver_id' => 999])->assertOk()
            ->assertJsonPath('bus.number', '07')->assertJsonPath('inspection_required', true);
        $this->assertDatabaseHas('bus_assignments', ['driver_id' => $this->driver->id, 'bus_id' => 'bus-07']);
        $this->assertSame(1, BusAssignment::where('driver_id', $this->driver->id)->count());
        $this->postJson('/api/v1/driver/inspections', ['bus_id' => 'bus-07', 'items' => ['tires' => 'bad'], 'passed' => true])->assertUnprocessable();
        $this->postJson('/api/v1/driver/inspections', ['bus_id' => 'bus-07', 'items' => ['tires' => true], 'passed' => true])
            ->assertUnprocessable()->assertJsonValidationErrors(['items.brakes', 'items.lights', 'items.fuel']);
        $this->postJson('/api/v1/driver/inspections', ['bus_id' => 'bus-11', 'items' => ['tires' => true, 'brakes' => true,
            'lights' => true, 'fuel' => true], 'passed' => true])->assertNotFound();
        $this->postJson('/api/v1/driver/inspections', ['bus_id' => 'bus-07', 'items' => ['tires' => true, 'brakes' => true,
            'lights' => true, 'fuel' => true], 'passed' => true, 'driver_id' => 999])->assertCreated();
        $this->assertDatabaseHas('bus_inspections', ['driver_id' => $this->driver->id, 'bus_id' => 'bus-07', 'passed' => true]);
    }

    public function test_today_trips_students_absences_and_start_rules(): void
    {
        AbsenceReport::create(['parent_id' => $this->parent->id, 'child_id' => $this->child->id, 'absence_date' => today()]);
        $this->asDriver()->getJson('/api/v1/driver/trips/today')->assertOk()->assertJsonCount(1)
            ->assertJsonPath('0.period', 'morning')->assertJsonPath('0.scheduled_start', today()->setTime(7, 5)->toISOString())
            ->assertJsonPath('0.stations.0.students.0.absent', true);
        $this->getJson('/api/v1/driver/trips/trip-04/students')->assertOk()->assertJsonCount(1)
            ->assertJsonPath('0.boarded_at', null)->assertJsonPath('0.absent', true);
        $this->postJson('/api/v1/driver/trips/trip-04/start')->assertUnprocessable();
        $this->inspection();
        BusInspection::query()->update(['date' => today()->subDay()]);
        $this->postJson('/api/v1/driver/trips/trip-04/start')->assertUnprocessable();
        BusInspection::query()->update(['date' => today(), 'passed' => false]);
        $this->postJson('/api/v1/driver/trips/trip-04/start')->assertUnprocessable();
        BusInspection::query()->update(['passed' => true]);
        $this->postJson('/api/v1/driver/trips/trip-04/start')->assertOk()->assertJsonPath('status', 'en_route');
        $this->assertNotNull($this->trip->fresh()->started_at);
        $this->postJson('/api/v1/driver/trips/trip-04/start')->assertConflict();
        $second = $this->trip->replicate();
        $second->id = 'second';
        $second->status = 'scheduled';
        $second->save();
        $this->postJson('/api/v1/driver/trips/second/start')->assertConflict();
    }

    public static function ownedTripEndpoints(): array
    {
        return [['GET', 'students', []], ['POST', 'start', []], ['POST', 'end', ['safety_walk_confirmed' => true]],
            ['POST', 'location', ['lat' => 36, 'lng' => 3]], ['POST', 'stations/1/arrive', []],
            ['POST', 'delay', ['minutes' => 5, 'reason' => 'traffic']],
            ['POST', 'boarding', ['student_code' => 'HB-304', 'type' => 'boarded', 'method' => 'qr']]];
    }

    #[DataProvider('ownedTripEndpoints')]
    public function test_another_drivers_trip_is_always_404(string $method, string $action, array $body): void
    {
        $this->asDriver()->json($method, '/api/v1/driver/trips/foreign/'.$action, $body)->assertNotFound();
    }

    public function test_location_updates_progress_parent_map_and_throttle(): void
    {
        $this->asDriver()->postJson('/api/v1/driver/trips/trip-04/location', ['lat' => 36, 'lng' => 3])->assertConflict();
        $this->trip->update(['status' => 'en_route']);
        $this->postJson('/api/v1/driver/trips/trip-04/location', ['lat' => 91, 'lng' => 181, 'speed_kmh' => -1, 'heading' => 361])
            ->assertUnprocessable()->assertJsonValidationErrors(['lat', 'lng', 'speed_kmh', 'heading']);
        $this->postJson('/api/v1/driver/trips/trip-04/location', ['lat' => 36.7545, 'lng' => 3.0597, 'speed_kmh' => 25, 'heading' => 82,
            'driver_id' => 999])->assertOk()->assertExactJson(['ok' => true]);
        $this->assertEquals(0.5, $this->trip->fresh()->progress);
        $this->assertDatabaseCount('trip_location_points', 1);
        $this->assertEquals(25, $this->trip->fresh()->speed_kmh);
        Sanctum::actingAs($this->parent);
        $this->getJson('/api/v1/parent/tracking/active-trip')->assertOk()->assertJsonPath('location.lat', 36.7545)
            ->assertJsonPath('location.heading', 82)->assertJsonCount(3, 'route_points')->assertJsonPath('stations.0.lat', 36.7538);
        $this->asDriver();
        // Three requests above already used this driver's minute bucket.
        for ($i = 0; $i < 27; $i++) {
            $this->postJson('/api/v1/driver/trips/trip-04/location', ['lat' => 36.7552, 'lng' => 3.0601])->assertOk();
        }
        $this->postJson('/api/v1/driver/trips/trip-04/location', ['lat' => 36, 'lng' => 3])->assertStatus(429);
    }

    public function test_arrival_delay_notifications_and_validation(): void
    {
        $this->trip->update(['status' => 'en_route']);
        $next = $this->station->replicate();
        $next->sort_order = 2;
        $next->name_en = 'School';
        $next->save();
        $this->asDriver()->postJson('/api/v1/driver/trips/trip-04/stations/'.$this->station->id.'/arrive')->assertOk();
        $this->assertDatabaseHas('trip_stations', ['id' => $this->station->id, 'status' => 'current']);
        $this->assertDatabaseCount('safety_notifications', 1);
        $notification = SafetyNotification::first();
        $this->assertSame('bus', $notification->category);
        $this->assertNotSame($notification->title_en, $notification->title_ar);
        $this->assertNotSame($notification->title_en, $notification->title_fr);
        $this->postJson('/api/v1/driver/trips/trip-04/stations/'.$next->id.'/arrive')->assertOk();
        $this->assertSame('completed', $this->station->fresh()->status);
        $this->postJson('/api/v1/driver/trips/trip-04/delay', ['minutes' => 0, 'reason' => 'invalid'])->assertUnprocessable();
        $this->postJson('/api/v1/driver/trips/trip-04/delay', ['minutes' => 121, 'reason' => 'weather'])->assertUnprocessable();
        $oldEta = $this->trip->fresh()->eta_minutes;
        $this->postJson('/api/v1/driver/trips/trip-04/delay', ['minutes' => 5, 'reason' => 'traffic'])->assertOk()->assertJsonPath('notified', 1);
        $this->assertEquals($oldEta + 5, $this->trip->fresh()->eta_minutes);
    }

    public function test_boarding_idempotency_absence_bus_membership_and_alighting(): void
    {
        $this->trip->update(['status' => 'en_route']);
        $body = ['student_code' => 'HB-304', 'type' => 'boarded', 'method' => 'qr', 'driver_id' => 999];
        $this->asDriver()->postJson('/api/v1/driver/trips/trip-04/boarding', [...$body, 'student_code' => 'unknown'])->assertNotFound();
        $this->child->update(['bus_number' => '11']);
        $this->postJson('/api/v1/driver/trips/trip-04/boarding', $body)->assertUnprocessable();
        $this->child->update(['bus_number' => '04']);
        AbsenceReport::create(['parent_id' => $this->parent->id, 'child_id' => $this->child->id, 'absence_date' => today()]);
        $this->postJson('/api/v1/driver/trips/trip-04/boarding', $body)->assertUnprocessable();
        AbsenceReport::query()->delete();
        $this->postJson('/api/v1/driver/trips/trip-04/boarding', [...$body, 'type' => 'invalid', 'method' => 'invalid'])->assertUnprocessable();
        $event = $this->postJson('/api/v1/driver/trips/trip-04/boarding', $body)->assertCreated()
            ->assertJsonPath('child.transit_status', 'on_bus')->assertJsonPath('onboard_count', 1)->json('event.id');
        $this->postJson('/api/v1/driver/trips/trip-04/boarding', $body)->assertOk()->assertJsonPath('event.id', $event);
        AbsenceReport::create(['parent_id' => $this->parent->id, 'child_id' => $this->child->id, 'absence_date' => today()]);
        $this->postJson('/api/v1/driver/trips/trip-04/boarding', $body)->assertOk()->assertJsonPath('event.id', $event);
        AbsenceReport::query()->delete();
        $this->assertDatabaseCount('boarding_events', 1);
        $this->assertDatabaseCount('safety_notifications', 1);
        $this->assertDatabaseHas('boarding_events', ['driver_id' => $this->driver->id, 'station_id' => $this->station->id]);
        $this->getJson('/api/v1/driver/trips/trip-04/students')->assertOk()->assertJsonPath('0.boarded_at', BoardingEvent::first()->recorded_at->toISOString());
        $this->postJson('/api/v1/driver/trips/trip-04/boarding', [...$body, 'type' => 'alighted', 'method' => 'manual'])
            ->assertCreated()->assertJsonPath('child.transit_status', 'at_school')->assertJsonPath('onboard_count', 0);
        $return = $this->trip->replicate();
        $return->id = 'return';
        $return->is_morning = false;
        $return->save();
        $this->postJson('/api/v1/driver/trips/return/boarding', $body)->assertCreated();
        $this->postJson('/api/v1/driver/trips/return/boarding', [...$body, 'type' => 'alighted'])->assertCreated()->assertJsonPath('child.transit_status', 'at_home');
    }

    public function test_end_reuses_an_existing_history_row_instead_of_failing(): void
    {
        $this->inspection();
        $this->asDriver()->postJson('/api/v1/driver/trips/trip-04/start')->assertOk();
        $this->postJson('/api/v1/driver/trips/trip-04/boarding', ['student_code' => 'HB-304', 'type' => 'boarded', 'method' => 'qr'])->assertCreated();
        $this->postJson('/api/v1/driver/trips/trip-04/end', ['safety_walk_confirmed' => true])->assertOk();
        $firstId = TripHistory::first()->id;
        // A trip that is restarted and ended again must update its history row, not violate the unique key.
        $this->trip->fresh()->update(['status' => 'en_route', 'ended_at' => null]);
        $this->postJson('/api/v1/driver/trips/trip-04/end', ['safety_walk_confirmed' => true])->assertOk();
        $this->assertDatabaseCount('trip_histories', 1);
        $this->assertSame($firstId, TripHistory::first()->id);
    }

    public function test_end_creates_histories_once_and_history_stats_are_driver_scoped(): void
    {
        $this->inspection();
        $this->asDriver()->postJson('/api/v1/driver/trips/trip-04/start')->assertOk();
        $this->postJson('/api/v1/driver/trips/trip-04/boarding', ['student_code' => 'HB-304', 'type' => 'boarded', 'method' => 'qr'])->assertCreated();
        $this->postJson('/api/v1/driver/trips/trip-04/end')->assertUnprocessable();
        $this->postJson('/api/v1/driver/trips/trip-04/end', ['safety_walk_confirmed' => false])->assertUnprocessable();
        $this->postJson('/api/v1/driver/trips/trip-04/delay', ['minutes' => 5, 'reason' => 'breakdown'])->assertOk();
        $this->travel(20)->minutes();
        $this->postJson('/api/v1/driver/trips/trip-04/end', ['safety_walk_confirmed' => true])->assertOk()->assertJsonPath('status', 'completed');
        $this->postJson('/api/v1/driver/trips/trip-04/end', ['safety_walk_confirmed' => true])->assertOk();
        $this->assertDatabaseCount('trip_histories', 1);
        $this->assertEquals(1, $this->driver->fresh()->driverProfile->trips_count);
        $this->assertNotNull($this->trip->fresh()->ended_at);
        $this->getJson('/api/v1/driver/history?period=week')->assertOk()->assertJsonPath('totals.trips', 1)
            ->assertJsonPath('totals.on_time_rate', 0)->assertJsonPath('trips.0.students', 1)
            ->assertJsonPath('trips.0.delay_minutes', 5)->assertJsonPath('trips.0.status_code', 'delayed');
        $this->getJson('/api/v1/driver/history?period=month')->assertOk()->assertJsonCount(1, 'trips');
        $this->getJson('/api/v1/driver/history?period=all')->assertOk()->assertJsonCount(1, 'trips');
        $this->getJson('/api/v1/driver/history?period=bad')->assertUnprocessable();
        $this->getJson('/api/v1/driver/stats')->assertOk()->assertJsonPath('trips_this_month', 1)
            ->assertJsonPath('safe_scans', 1)->assertJsonPath('per_weekday.1.trips', 1);
        Sanctum::actingAs($this->parent);
        $this->getJson('/api/v1/parent/tracking/trips/'.TripHistory::first()->id)->assertOk()->assertJsonCount(3, 'route_points')
            ->assertJsonStructure(['waypoints', 'qr_audit']);
    }

    public function test_driver_parent_messages_read_receipts_urgency_and_scoping(): void
    {
        Sanctum::actingAs($this->parent);
        $this->postJson('/api/v1/parent/support/messages', ['recipient_type' => 'driver', 'child_id' => $this->child->id,
            'message' => 'Remember the peanut medication', 'driver_id' => 999])->assertCreated();
        $this->assertDatabaseHas('support_messages', ['driver_id' => $this->driver->id, 'direction' => 'parent_to_driver']);
        $this->asDriver()->getJson('/api/v1/driver/messages')->assertOk()->assertJsonCount(1)
            ->assertJsonPath('0.unread_count', 1)->assertJsonPath('0.is_urgent', true)->assertJsonPath('0.child.name', 'Youssef');
        $this->getJson('/api/v1/driver/messages/'.$this->parent->id.'?child_id='.$this->child->id)->assertOk()
            ->assertJsonCount(1, 'messages')->assertJsonPath('messages.0.direction', 'parent_to_driver');
        $this->assertNotNull(SupportMessage::first()->read_at);
        $this->getJson('/api/v1/driver/messages')->assertOk()->assertJsonPath('0.unread_count', 0);
        $url = '/api/v1/driver/messages/'.$this->parent->id;
        $this->postJson($url, ['child_id' => $this->child->id, 'message' => 'Will do', 'driver_id' => 999])->assertCreated()->assertJsonPath('direction', 'driver_to_parent');
        $this->assertDatabaseCount('safety_notifications', 1);
        $this->postJson($url, ['child_id' => $this->child->id, 'message' => ''])->assertUnprocessable();
        $this->getJson($url.'?child_id=unknown')->assertNotFound();
        $otherParent = User::factory()->create(['role' => 'parent']);
        $this->postJson('/api/v1/driver/messages/'.$otherParent->id, ['child_id' => $this->child->id, 'message' => 'Hello'])->assertNotFound();
        $otherChild = $this->child->replicate();
        $otherChild->id = 'foreign-child';
        $otherChild->student_code = 'foreign-code';
        $otherChild->bus_number = '11';
        $otherChild->save();
        $this->postJson($url, ['child_id' => $otherChild->id, 'message' => 'Hello'])->assertNotFound();
        Sanctum::actingAs($this->parent);
        $this->getJson('/api/v1/parent/support/messages')->assertOk()->assertJsonCount(2)->assertJsonPath('1.direction', 'driver_to_parent');
        $this->assertNotNull(SupportMessage::where('direction', 'driver_to_parent')->first()->read_at);
        $this->postJson('/api/v1/parent/support/messages', ['recipient_type' => 'driver', 'child_id' => $this->child->id,
            'message' => 'Please call', 'urgent' => true])->assertCreated();
        $this->asDriver()->getJson('/api/v1/driver/messages')->assertOk()->assertJsonPath('0.is_urgent', true);
        Sanctum::actingAs($otherParent);
        $this->getJson('/api/v1/parent/support/messages')->assertOk()->assertJsonCount(0);
        $this->postJson('/api/v1/parent/support/messages', ['recipient_type' => 'driver', 'child_id' => $this->child->id, 'message' => 'Hello'])->assertNotFound();
    }

    public function test_sos_validation_trip_scoping_and_parent_notifications(): void
    {
        $this->asDriver()->postJson('/api/v1/driver/sos', ['type' => 'bad', 'lat' => -91, 'lng' => -181])->assertUnprocessable();
        $this->postJson('/api/v1/driver/sos', ['type' => 'accident', 'trip_id' => 'foreign'])->assertNotFound();
        $this->postJson('/api/v1/driver/sos', ['type' => 'security', 'driver_id' => 999])->assertCreated()->assertJsonPath('status', 'open');
        $this->assertDatabaseCount('safety_notifications', 0);
        $this->postJson('/api/v1/driver/sos', ['type' => 'medical', 'trip_id' => $this->trip->id, 'lat' => 36.75, 'lng' => 3.05])->assertCreated();
        $this->assertDatabaseCount('safety_notifications', 1);
        $this->assertDatabaseHas('sos_alerts', ['driver_id' => $this->driver->id, 'trip_id' => $this->trip->id, 'lat' => 36.75]);
    }

    public function test_parent_additions_require_auth_and_role_and_have_null_fallbacks(): void
    {
        foreach (['support/messages', 'tracking/active-trip', 'tracking/trips/unknown'] as $path) {
            $this->getJson('/api/v1/parent/'.$path)->assertUnauthorized();
        }
        $this->asDriver();
        foreach (['support/messages', 'tracking/active-trip', 'tracking/trips/unknown'] as $path) {
            $this->getJson('/api/v1/parent/'.$path)->assertForbidden();
        }
        // Every parent route, including mutation routes, has the role middleware.
        foreach (Route::getRoutes() as $route) {
            if (str_starts_with($route->uri(), 'api/v1/parent/')) {
                $this->assertContains('role:parent', $route->gatherMiddleware());
            }
        }
        Sanctum::actingAs($this->parent);
        $this->trip->update(['route_points_json' => null]);
        $this->station->update(['lat' => null, 'lng' => null]);
        $this->getJson('/api/v1/parent/tracking/active-trip')->assertOk()->assertJsonPath('location', null)
            ->assertJsonPath('route_points', [])->assertJsonPath('stations.0.lat', null)->assertJsonPath('stations.0.lng', null);
        $this->getJson('/api/v1/parent/tracking/active-trip?bus_number=11')->assertNotFound();
        $this->getJson('/api/v1/parent/tracking/active-trip?child_id=unknown')->assertNotFound();
    }

    public function test_demo_seed_extends_existing_parent_data_and_is_repeatable(): void
    {
        $this->child->delete();
        $this->seed();
        $this->seed();
        $driver = User::where('email', 'ahmed.benali@mail.dz')->firstOrFail();
        $this->assertSame('driver', $driver->role);
        $this->assertSame('DZ-D-2024-0457', $driver->driverProfile->license_number);
        $this->assertDatabaseHas('users', ['email' => 'k.mansouri@mail.dz', 'role' => 'parent']);
        $this->assertDatabaseHas('children', ['student_code' => 'HB-2026-9911']);
        $trip = ActiveTrip::findOrFail('trip-04-am');
        $this->assertCount(10, $trip->route_points_json);
        $this->assertCount(10, ActiveTrip::findOrFail('trip-04-return')->route_points_json);
        $this->assertNotNull($trip->stations->first()->lat);
        Sanctum::actingAs($driver);
        $this->getJson('/api/v1/driver/trips/today')->assertOk()->assertJsonCount(2);
    }

    public function test_history_periods_totals_empty_stats_and_trip_date_filter(): void
    {
        $this->asDriver()->getJson('/api/v1/driver/stats')->assertOk()->assertJsonPath('trips_this_month', 0)
            ->assertJsonPath('on_time_rate', 100)->assertJsonPath('safe_scans', 0);
        $old = $this->trip->replicate();
        $old->id = 'old-trip';
        $old->service_date = today()->subMonths(2);
        $old->started_at = today()->subMonths(2)->setTime(7, 0);
        $old->ended_at = today()->subMonths(2)->setTime(8, 0);
        $old->status = 'completed';
        $old->distance_km = 12.5;
        $old->save();
        $this->getJson('/api/v1/driver/trips/today')->assertOk()->assertJsonCount(1);
        ActiveTrip::whereKey('foreign')->update(['status' => 'completed', 'ended_at' => now(), 'distance_km' => 99]);
        $this->getJson('/api/v1/driver/history?period=all')->assertOk()->assertJsonPath('totals.trips', 1)
            ->assertJsonPath('totals.km', 12.5)->assertJsonPath('totals.on_time_rate', 100);
        $this->getJson('/api/v1/driver/history?period=week')->assertOk()->assertJsonCount(0, 'trips');
        $this->getJson('/api/v1/driver/history?period=month')->assertOk()->assertJsonCount(0, 'trips');
        $this->getJson('/api/v1/driver/stats')->assertOk()->assertJsonPath('trips_this_month', 0)->assertJsonPath('km_this_month', 0);
    }

    public function test_parent_map_chooses_the_current_trip_and_never_exposes_another_childs_replay(): void
    {
        $this->trip->update(['status' => 'completed']);
        $return = $this->trip->replicate();
        $return->id = 'return';
        $return->is_morning = false;
        $return->status = 'en_route';
        $return->save();
        Sanctum::actingAs($this->parent);
        $this->getJson('/api/v1/parent/tracking/active-trip')->assertOk()->assertJsonPath('id', 'return');
        $this->getJson('/api/v1/parent/tracking/trips/unknown')->assertNotFound();
    }

    public function test_language_selection_and_trip_station_ownership(): void
    {
        $this->postJson('/api/v1/driver/auth/login?lang=ar', ['email' => $this->driver->email, 'password' => 'bad'])
            ->assertUnauthorized()->assertJsonPath('message', 'البريد الإلكتروني أو كلمة المرور غير صحيحة.');
        Sanctum::actingAs($this->parent);
        $this->getJson('/api/v1/driver/profile?lang=fr')->assertForbidden()->assertJsonPath('message', 'Accès refusé.');
        $foreignStation = $this->station->replicate();
        $foreignStation->trip_id = 'foreign';
        $foreignStation->save();
        $this->asDriver()->postJson('/api/v1/driver/trips/trip-04/stations/'.$foreignStation->id.'/arrive')->assertNotFound();
        $this->getJson('/api/v1/driver/trips/today?lang=ar')->assertOk()->assertJsonPath('0.stations.0.name', 'حي النصر');
    }
}

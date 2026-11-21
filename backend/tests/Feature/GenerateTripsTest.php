<?php

namespace Tests\Feature;

use App\Models\ActiveTrip;
use App\Models\Bus;
use App\Models\BusAssignment;
use App\Models\TripStation;
use App\Models\User;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class GenerateTripsTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->travelTo(now()->setDate(2026, 11, 24)->setTime(8, 0));
    }

    public function test_creates_both_periods_with_stations_route_points_and_reset_runtime(): void
    {
        ['morning' => $morning, 'return' => $return] = $this->templates();
        $original = $morning->refresh()->getRawOriginal();

        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-24'])
            ->expectsOutput('Created 2 trips; skipped 0 trips for 2026-11-24.')->assertSuccessful();

        $this->assertDatabaseCount('active_trips', 4);
        $this->assertDatabaseCount('trip_stations', 8);
        foreach (['trip-04-am-20261124' => $morning, 'trip-04-return-20261124' => $return] as $id => $source) {
            $trip = ActiveTrip::with('stations')->findOrFail($id);
            $this->assertSame('2026-11-24', $trip->service_date->toDateString());
            $this->assertSame($source->route_name, $trip->route_name);
            $this->assertSame($source->route_points_json, $trip->route_points_json);
            $this->assertSame($source->is_morning, $trip->is_morning);
            $this->assertSame('2026-11-24 '.$source->scheduled_start->format('H:i:s'), $trip->scheduled_start->toDateTimeString());
            $this->assertDatabaseHas('active_trips', [
                'id' => $id, 'status' => 'scheduled', 'progress' => 0, 'speed_kmh' => 0,
                'onboard_count' => 0, 'delay_minutes' => 0, 'eta_minutes' => 0, 'current_street' => '',
                'lat' => null, 'lng' => null, 'heading' => null, 'last_location_at' => null,
                'started_at' => null, 'ended_at' => null,
            ]);
            foreach ($source->stations as $index => $station) {
                $copy = $trip->stations[$index];
                $this->assertNotSame($station->id, $copy->id);
                $this->assertSame('upcoming', $copy->status);
                $this->assertSame($station->only(['sort_order', 'name_en', 'name_ar', 'name_fr', 'scheduled_time',
                    'subtitle_en', 'subtitle_ar', 'subtitle_fr', 'lat', 'lng']),
                    $copy->only(['sort_order', 'name_en', 'name_ar', 'name_fr', 'scheduled_time',
                        'subtitle_en', 'subtitle_ar', 'subtitle_fr', 'lat', 'lng']));
            }
        }
        $this->assertSame($original, $morning->fresh()->getRawOriginal());
    }

    public function test_uses_the_target_dates_driver_and_bus_details(): void
    {
        ['driver' => $driver, 'bus' => $bus] = $this->templates();

        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-24'])->assertSuccessful();

        foreach (['trip-04-am-20261124', 'trip-04-return-20261124'] as $id) {
            $this->assertDatabaseHas('active_trips', [
                'id' => $id, 'driver_id' => $driver->id, 'driver_name' => $driver->name,
                'driver_phone' => $driver->phone, 'bus_id' => $bus->id, 'bus_number' => '04',
                'vehicle_model' => $bus->vehicle_model, 'plate_number' => $bus->plate_number, 'capacity' => 30,
            ]);
        }
    }

    public function test_rerunning_preserves_generated_trips_and_stations_even_after_they_start(): void
    {
        $this->templates();
        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-24'])->assertSuccessful();
        $trip = ActiveTrip::findOrFail('trip-04-am-20261124');
        $trip->update(['status' => 'en_route', 'progress' => 0.4, 'started_at' => now()]);
        $trip->stations()->first()->update(['status' => 'current']);
        $trips = ActiveTrip::orderBy('id')->get()->toArray();
        $stations = TripStation::orderBy('id')->get()->toArray();

        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-24'])
            ->expectsOutput('Created 0 trips; skipped 2 trips for 2026-11-24.')->assertSuccessful();

        $this->assertSame($trips, ActiveTrip::orderBy('id')->get()->toArray());
        $this->assertSame($stations, TripStation::orderBy('id')->get()->toArray());
    }

    public function test_preserves_existing_trips_with_legacy_ids_and_only_fills_the_missing_period(): void
    {
        ['morning' => $morning] = $this->templates();
        $morning->update(['service_date' => '2026-11-24']);
        $before = $morning->refresh()->getRawOriginal();

        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-24'])
            ->expectsOutput('Created 1 trips; skipped 1 trips for 2026-11-24.')->assertSuccessful();

        $this->assertSame($before, $morning->fresh()->getRawOriginal());
        $this->assertDatabaseMissing('active_trips', ['id' => 'trip-04-am-20261124']);
        $this->assertDatabaseHas('active_trips', ['id' => 'trip-04-return-20261124']);
    }

    public function test_no_target_date_assignment_means_no_trip_even_with_a_previous_driver(): void
    {
        $this->templates();
        BusAssignment::whereDate('date', '2026-11-24')->delete();

        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-24'])
            ->expectsOutput('Created 0 trips; skipped 0 trips for 2026-11-24.')->assertSuccessful();

        $this->assertDatabaseCount('active_trips', 2);
        $this->assertDatabaseCount('trip_stations', 4);
    }

    public function test_selects_the_latest_prior_template_independently_for_each_period(): void
    {
        ['morning' => $morning, 'return' => $return] = $this->templates();
        $older = $morning->replicate();
        $older->fill(['id' => 'older-morning', 'service_date' => '2026-11-20', 'route_name' => 'Old route'])->save();
        $future = $return->replicate();
        $future->fill(['id' => 'future-return', 'service_date' => '2026-11-25', 'route_name' => 'Future route'])->save();

        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-24'])->assertSuccessful();

        $this->assertDatabaseHas('active_trips', ['id' => 'trip-04-am-20261124', 'route_name' => $morning->route_name]);
        $this->assertDatabaseHas('active_trips', ['id' => 'trip-04-return-20261124', 'route_name' => $return->route_name]);
    }

    public function test_skips_a_missing_template_without_inventing_a_route(): void
    {
        ['return' => $return, 'morning' => $morning] = $this->templates();
        $return->delete();
        $morning->update(['scheduled_start' => null]);

        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-24'])
            ->expectsOutput('Created 1 trips; skipped 1 trips for 2026-11-24.')->assertSuccessful();

        $this->assertDatabaseMissing('active_trips', ['id' => 'trip-04-return-20261124']);
        $this->assertDatabaseHas('active_trips', ['id' => 'trip-04-am-20261124', 'scheduled_start' => null]);
    }

    public function test_explicit_future_date_generates_for_each_assigned_bus(): void
    {
        ['morning' => $morning] = $this->templates();
        BusAssignment::whereDate('date', '2026-11-24')->first()->update(['date' => '2026-11-25']);
        $driver = User::factory()->create(['role' => 'driver']);
        $bus = Bus::create(['id' => 'bus-11', 'number' => '11', 'line_name' => 'Route 11',
            'plate_number' => 'plate-11', 'vehicle_model' => 'Sprinter 11', 'capacity' => 24, 'status' => 'available']);
        BusAssignment::create(['driver_id' => $driver->id, 'bus_id' => $bus->id, 'date' => '2026-11-25']);
        $template = $morning->replicate();
        $template->fill(['id' => 'template-11-am', 'bus_id' => $bus->id, 'bus_number' => '11', 'route_name' => 'Route 11'])->save();

        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-25'])
            ->expectsOutput('Created 3 trips; skipped 1 trips for 2026-11-25.')->assertSuccessful();

        $this->assertDatabaseHas('active_trips', ['id' => 'trip-04-am-20261125', 'scheduled_start' => '2026-11-25 07:05:00']);
        $this->assertDatabaseHas('active_trips', ['id' => 'trip-04-return-20261125']);
        $this->assertDatabaseHas('active_trips', ['id' => 'trip-11-am-20261125', 'bus_id' => $bus->id,
            'bus_number' => '11', 'driver_id' => $driver->id, 'route_name' => 'Route 11']);
        $this->assertDatabaseMissing('active_trips', ['id' => 'trip-11-return-20261125']);
        $this->assertSame(0, ActiveTrip::whereDate('service_date', '2026-11-24')->count());
    }

    public function test_defaults_to_today_and_driver_endpoint_returns_generated_trips_and_route_points(): void
    {
        ['driver' => $driver, 'morning' => $morning, 'return' => $return] = $this->templates();
        $return->update(['route_points_json' => null]);

        $this->artisan('hanna:generate-trips')
            ->expectsOutput('Created 2 trips; skipped 0 trips for 2026-11-24.')->assertSuccessful();

        Sanctum::actingAs($driver);
        $trips = $this->getJson('/api/v1/driver/trips/today')->assertOk()->assertJsonCount(2)->json();
        $trips = collect($trips)->keyBy('period');
        $this->assertSame('trip-04-am-20261124', $trips['morning']['id']);
        $this->assertSame('trip-04-return-20261124', $trips['return']['id']);
        $this->assertSame($morning->route_points_json, $trips['morning']['route_points']);
        $this->assertSame([], $trips['return']['route_points']);
        $this->assertSame('2026-11-24T07:05:00.000000Z', $trips['morning']['scheduled_start']);
        $this->assertSame('scheduled', $trips['morning']['status']);
        $this->assertSame(36.7538, $trips['morning']['stations'][0]['lat']);
        $this->assertSame(3.0588, $trips['morning']['stations'][0]['lng']);
        $this->assertSame('upcoming', $trips['morning']['stations'][0]['status']);
    }

    #[DataProvider('invalidDates')]
    public function test_rejects_invalid_dates_without_writes(string $date): void
    {
        $this->templates();

        $this->artisan('hanna:generate-trips', ['--date' => $date])
            ->expectsOutput('Invalid date. Use --date=YYYY-MM-DD with a valid calendar date.')->assertFailed();

        $this->assertDatabaseCount('active_trips', 2);
        $this->assertDatabaseCount('trip_stations', 4);
    }

    public static function invalidDates(): array
    {
        return [
            'text' => ['tomorrow'], 'impossible day' => ['2026-02-30'],
            'non leap year' => ['2026-02-29'], 'wrong format' => ['24-11-2026'],
            'unpadded' => ['2026-1-4'], 'timestamp' => ['2026-11-24T00:00:00Z'], 'empty' => [''],
        ];
    }

    public function test_scheduler_runs_the_generator_at_five_minutes_after_midnight(): void
    {
        $event = collect(app(Schedule::class)->events())
            ->first(fn ($event) => str_contains($event->command ?? '', 'hanna:generate-trips'));

        $this->assertNotNull($event);
        $this->travelTo(today()->setTime(0, 5));
        $this->assertTrue($event->isDue($this->app));
        $this->travelTo(today()->setTime(0, 4));
        $this->assertFalse($event->isDue($this->app));
        $this->travelTo(today()->setTime(1, 5));
        $this->assertFalse($event->isDue($this->app));
    }

    /** @return array{driver: User, bus: Bus, morning: ActiveTrip, return: ActiveTrip} */
    private function templates(): array
    {
        $oldDriver = User::factory()->create(['role' => 'driver']);
        $driver = User::factory()->create(['role' => 'driver', 'phone' => '0550000004']);
        $bus = Bus::create(['id' => 'bus-04', 'number' => '04', 'line_name' => 'Route 04',
            'plate_number' => 'new-plate', 'vehicle_model' => 'New Sprinter', 'capacity' => 30, 'status' => 'available']);
        BusAssignment::create(['driver_id' => $oldDriver->id, 'bus_id' => $bus->id, 'date' => '2026-11-23']);
        BusAssignment::create(['driver_id' => $driver->id, 'bus_id' => $bus->id, 'date' => '2026-11-24']);
        $morning = ActiveTrip::create([
            'id' => 'template-am', 'bus_id' => $bus->id, 'bus_number' => '04',
            'driver_id' => $oldDriver->id, 'driver_name' => $oldDriver->name, 'driver_phone' => 'old-phone',
            'vehicle_model' => 'Old Sprinter', 'plate_number' => 'old-plate', 'capacity' => 24,
            'route_name' => 'Morning route', 'is_morning' => true, 'status' => 'completed',
            'service_date' => '2026-11-23', 'scheduled_start' => '2026-11-23 07:05:00',
            'lat' => 36.7552, 'lng' => 3.0601, 'heading' => 82, 'progress' => 1,
            'speed_kmh' => 45, 'onboard_count' => 12, 'delay_minutes' => 15, 'eta_minutes' => 15,
            'current_street' => 'Old street', 'started_at' => '2026-11-23 07:05:00',
            'ended_at' => '2026-11-23 08:00:00', 'last_location_at' => '2026-11-23 08:00:00',
            'route_points_json' => [[36.7538, 3.0588], [36.7552, 3.0601]],
        ]);
        $return = $morning->replicate();
        $return->fill(['id' => 'template-return', 'is_morning' => false, 'route_name' => 'Return route',
            'service_date' => '2026-11-22', 'scheduled_start' => '2026-11-22 15:20:00',
            'route_points_json' => [[36.7552, 3.0601], [36.7538, 3.0588]]])->save();
        foreach ([$morning, $return] as $trip) {
            foreach ([1, 2] as $order) {
                $trip->stations()->create(['sort_order' => $order, 'name_en' => 'Stop '.$order,
                    'name_ar' => 'AR '.$order, 'name_fr' => 'FR '.$order, 'scheduled_time' => '07:15',
                    'subtitle_en' => 'EN', 'subtitle_ar' => 'AR', 'subtitle_fr' => 'FR',
                    'status' => 'completed', 'lat' => 36.7538, 'lng' => 3.0588]);
            }
        }

        return compact('driver', 'bus', 'morning', 'return');
    }
}

<?php

namespace Tests\Feature\Admin;

use App\Filament\Pages\DailyPlanning;
use App\Filament\RelationManagers\RoutesRelationManager;
use App\Filament\Resources\BusResource;
use App\Filament\Resources\BusResource\Pages\ViewBus;
use App\Filament\Resources\RouteResource;
use App\Filament\Resources\RouteResource\Pages\CreateRoute;
use App\Filament\Resources\RouteResource\Pages\EditRoute;
use App\Filament\Resources\RouteResource\Pages\ListRoutes;
use App\Models\ActiveTrip;
use App\Models\BusAssignment;
use App\Models\Child;
use App\Models\Route;
use App\Models\RouteStation;
use App\Models\User;
use App\Support\GenerateDailyTrips;
use Carbon\CarbonImmutable;
use Database\Seeders\ParentPortalDemoSeeder;
use Filament\Facades\Filament;
use Filament\Notifications\Notification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Livewire\Livewire;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class RouteManagementTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Filament::setCurrentPanel(Filament::getPanel('admin'));
        $this->travelTo(CarbonImmutable::parse('2026-11-24 08:00:00'));
    }

    private function admin(): void
    {
        $this->actingAs(User::factory()->create(['role' => 'admin']));
    }

    private function stations(): array
    {
        return [
            ['name_en' => 'First stop', 'name_ar' => '', 'name_fr' => '', 'subtitle_en' => 'North',
                'subtitle_ar' => '', 'subtitle_fr' => '', 'scheduled_time' => '07:05', 'lat' => 36.75, 'lng' => 3.05],
            ['name_en' => 'School', 'subtitle_en' => 'School gate', 'scheduled_time' => '07:30', 'lat' => 36.76, 'lng' => 3.06],
        ];
    }

    private function route(bool $active = true): Route
    {
        $route = Route::factory()->create(['is_active' => false, 'name' => 'North morning',
            'route_points_json' => [[36.75, 3.05], [36.76, 3.06]]]);
        foreach ($this->stations() as $index => $station) {
            $route->stations()->create([...$station, 'sort_order' => $index + 1]);
        }
        $route->update(['is_active' => $active]);

        return $route;
    }

    public function test_admin_creates_route_with_ordered_stations_and_translation_fallback(): void
    {
        $this->admin();
        $bus = Route::factory()->create()->bus;
        $bus->routes()->delete();
        Livewire::test(CreateRoute::class)->fillForm([
            'bus_id' => $bus->id, 'period' => 'morning', 'name' => 'New route',
            'scheduled_start' => '07:00', 'is_active' => true, 'stations' => $this->stations(),
            'route_points_json' => [['lat' => 36.75, 'lng' => 3.05], ['lat' => 36.76, 'lng' => 3.06]],
        ])->call('create')->assertHasNoFormErrors();

        $route = Route::with('stations')->where('bus_id', $bus->id)->firstOrFail();
        $this->assertSame([[36.75, 3.05], [36.76, 3.06]], $route->route_points_json);
        $this->assertSame(['First stop', 'School'], $route->stations->pluck('name_en')->all());
        $this->assertSame([1, 2], $route->stations->pluck('sort_order')->all());
        $this->assertSame('First stop', $route->stations[0]->name_ar);
        $this->assertSame('First stop', $route->stations[0]->name_fr);
        $this->assertSame('North', $route->stations[0]->subtitle_ar);
        $this->assertSame('North', $route->stations[0]->subtitle_fr);
        Livewire::test(EditRoute::class, ['record' => $route->id])->call('save')->assertHasNoFormErrors();
        $this->assertSame([[36.75, 3.05], [36.76, 3.06]], $route->fresh()->route_points_json);
        $this->get(RouteResource::getUrl())->assertOk();
        $this->get(BusResource::getUrl('view', ['record' => $bus]))->assertOk();
        Livewire::test(RoutesRelationManager::class, ['ownerRecord' => $bus, 'pageClass' => ViewBus::class])
            ->assertCanSeeTableRecords([$route]);
    }

    public function test_minimum_stations_blocks_activation_and_edit_but_allows_drafts(): void
    {
        $this->admin();
        $route = $this->route(false);
        Livewire::test(EditRoute::class, ['record' => $route->id])
            ->fillForm(['is_active' => true, 'stations' => [$this->stations()[0]]])
            ->call('save')->assertHasFormErrors(['stations' => 'min'])
            ->assertSee(__('admin.route_min_stations'));
        $this->assertFalse($route->fresh()->is_active);
        Livewire::test(EditRoute::class, ['record' => $route->id])
            ->fillForm(['is_active' => false, 'stations' => []])->call('save')->assertHasNoFormErrors();
        Livewire::test(ListRoutes::class)->call('updateTableColumnState', 'is_active', $route->id, true)
            ->assertNotified(__('admin.route_min_stations'));
        $this->assertFalse($route->fresh()->is_active);
    }

    public function test_create_requires_two_stations_when_active_and_allows_empty_draft(): void
    {
        $this->admin();
        $bus = Route::factory()->create()->bus;
        $bus->routes()->delete();
        $data = ['bus_id' => $bus->id, 'period' => 'morning', 'name' => 'Draft', 'is_active' => true, 'stations' => []];
        Livewire::test(CreateRoute::class)->fillForm($data)->call('create')->assertHasFormErrors(['stations' => 'min']);
        $data['stations'] = [$this->stations()[0]];
        Livewire::test(CreateRoute::class)->fillForm($data)->call('create')->assertHasFormErrors(['stations' => 'min']);
        $data['is_active'] = false;
        $data['stations'] = [];
        Livewire::test(CreateRoute::class)->fillForm($data)->call('create')->assertHasNoFormErrors();
        $this->assertDatabaseHas('routes', ['name' => 'Draft', 'is_active' => false]);
    }

    public function test_edit_reorders_stations_and_accepts_coordinate_boundaries_and_nulls(): void
    {
        $this->admin();
        $route = $this->route();
        $component = Livewire::test(EditRoute::class, ['record' => $route->id]);
        $state = array_reverse($component->get('data.stations'), true);
        $keys = array_keys($state);
        $state[$keys[0]]['lat'] = -90;
        $state[$keys[0]]['lng'] = 180;
        $state[$keys[1]]['lat'] = null;
        $state[$keys[1]]['lng'] = null;
        $component->fillForm(['stations' => $state, 'route_points_json' => []])
            ->callFormComponentAction('stations', 'reorder', arguments: ['items' => $keys])
            ->call('save')->assertHasNoFormErrors();
        $stations = $route->stations()->get();
        $this->assertSame(['School', 'First stop'], $stations->pluck('name_en')->all());
        $this->assertSame([1, 2], $stations->pluck('sort_order')->all());
        $this->assertSame(-90.0, $stations[0]->lat);
        $this->assertSame(180.0, $stations[0]->lng);
        $this->assertNull($stations[1]->lat);
        $this->assertSame([], $route->fresh()->route_points_json);
    }

    public static function invalidCoordinates(): array
    {
        return [
            'latitude low' => ['lat', -90.01], 'latitude high' => ['lat', 90.01],
            'longitude low' => ['lng', -180.01], 'longitude high' => ['lng', 180.01],
        ];
    }

    #[DataProvider('invalidCoordinates')]
    public function test_rejects_invalid_station_and_route_point_coordinates(string $field, float $value): void
    {
        $this->admin();
        $route = $this->route();
        $stations = $this->stations();
        $stations[0][$field] = $value;
        $component = Livewire::test(EditRoute::class, ['record' => $route->id])->fillForm([
            'stations' => $stations, 'route_points_json' => [['lat' => 36.75, 'lng' => 3.05, $field => $value]],
        ])->call('save');
        $errors = $component->instance()->getErrorBag()->keys();
        $this->assertTrue(collect($errors)->contains(fn (string $key): bool => str_starts_with($key, 'data.stations.') && str_ends_with($key, '.'.$field)));
        $this->assertTrue(collect($errors)->contains(fn (string $key): bool => str_starts_with($key, 'data.route_points_json.') && str_ends_with($key, '.'.$field)));
        $this->assertSame(36.75, $route->stations()->first()->lat);
    }

    public function test_duplicate_return_reverses_stations_and_points_and_skips_existing_return(): void
    {
        $this->admin();
        $route = $this->route();
        Livewire::test(ListRoutes::class)->callTableAction('duplicateReturn', $route)
            ->assertNotified(__('admin.return_route_created'));
        $return = Route::with('stations')->where('bus_id', $route->bus_id)->where('period', 'return')->firstOrFail();
        $this->assertSame(['School', 'First stop'], $return->stations->pluck('name_en')->all());
        $this->assertSame([1, 2], $return->stations->pluck('sort_order')->all());
        $this->assertSame([[36.76, 3.06], [36.75, 3.05]], $return->route_points_json);
        $this->assertNull($return->scheduled_start);
        $before = $return->toArray();
        Livewire::test(ListRoutes::class)->callTableAction('duplicateReturn', $route)
            ->assertNotified(__('admin.return_route_exists'));
        $this->assertSame($before, $return->fresh('stations')->toArray());
        $this->assertDatabaseCount('routes', 2);
    }

    public function test_form_rejects_duplicate_bus_period(): void
    {
        $this->admin();
        $route = $this->route();
        Livewire::test(CreateRoute::class)->fillForm([
            'bus_id' => $route->bus_id, 'period' => 'morning', 'name' => 'Duplicate',
            'is_active' => true, 'stations' => $this->stations(),
        ])->call('create')->assertHasFormErrors(['period' => 'unique']);
        $this->assertDatabaseCount('routes', 1);
    }

    public function test_planning_generates_trips_for_new_bus_and_preserves_mobile_response_shapes(): void
    {
        $this->admin();
        $route = $this->route();
        $driver = User::factory()->create(['role' => 'driver', 'phone' => '0550000011']);
        BusAssignment::create(['bus_id' => $route->bus_id, 'driver_id' => $driver->id, 'date' => today()]);
        Livewire::test(DailyPlanning::class)->callAction('generateTrips')
            ->assertNotified(__('admin.operation_result', ['created' => 1, 'skipped' => 1]));
        $trip = ActiveTrip::with('stations')->firstOrFail();
        $this->assertSame('trip-'.$route->bus->number.'-am-20261124', $trip->id);
        $this->assertSame($route->route_points_json, $trip->route_points_json);
        $this->assertSame($route->name, $trip->route_name);
        $this->assertSame('2026-11-24 07:00:00', $trip->scheduled_start->toDateTimeString());
        $this->assertSame($driver->id, $trip->driver_id);
        $this->assertSame($driver->name, $trip->driver_name);
        $this->assertSame($driver->phone, $trip->driver_phone);
        $this->assertSame($route->bus_id, $trip->bus_id);
        $this->assertSame($route->bus->plate_number, $trip->plate_number);
        $this->assertSame($route->bus->vehicle_model, $trip->vehicle_model);
        $this->assertSame($route->bus->capacity, $trip->capacity);
        $this->assertSame('scheduled', $trip->status);
        $this->assertSame(['upcoming', 'upcoming'], $trip->stations->pluck('status')->all());
        $this->assertSame('07:05', $trip->stations[0]->scheduled_time);
        $this->assertNull($trip->lat);
        $this->assertNull($trip->started_at);
        $this->assertSame(0.0, $trip->progress);
        $before = $trip->toArray();
        app(GenerateDailyTrips::class)->handle(CarbonImmutable::today());
        $this->assertSame($before, $trip->fresh('stations')->toArray());

        Sanctum::actingAs($driver);
        $response = $this->getJson('/api/v1/driver/trips/today')->assertOk()
            ->assertJsonPath('0.route_points', $route->route_points_json)
            ->assertJsonPath('0.stations.0.lat', 36.75)->assertJsonPath('0.stations.0.lng', 3.05);
        $this->assertEqualsCanonicalizing(['id', 'period', 'route_name', 'bus_number', 'status', 'scheduled_start', 'route_points', 'stations'], array_keys($response->json('0')));
        $this->assertEqualsCanonicalizing(['id', 'sort_order', 'name', 'scheduled_time', 'status', 'lat', 'lng', 'students'], array_keys($response->json('0.stations.0')));
        $parent = User::factory()->create(['role' => 'parent']);
        Child::create(['id' => 'new-child', 'parent_id' => $parent->id, 'student_code' => 'NEW-11',
            'full_name' => 'New student', 'school_name' => 'School', 'grade' => 'Grade 1', 'bus_number' => $route->bus->number]);
        Sanctum::actingAs($parent);
        $response = $this->getJson('/api/v1/parent/tracking/active-trip')->assertOk()
            ->assertJsonPath('route_points', $route->route_points_json)
            ->assertJsonPath('stations.0.lat', 36.75)->assertJsonPath('stations.0.lng', 3.05);
        $this->assertEqualsCanonicalizing(['id', 'bus_number', 'route_name', 'driver_name', 'driver_phone', 'vehicle_model',
            'plate_number', 'is_morning', 'eta_minutes', 'distance_km', 'speed_kmh', 'progress', 'onboard_count',
            'capacity', 'current_street', 'status', 'location', 'route_points', 'stations'], array_keys($response->json()));
        $this->assertEqualsCanonicalizing(['id', 'sort_order', 'name', 'scheduled_time', 'subtitle', 'status', 'lat', 'lng'], array_keys($response->json('stations.0')));
    }

    public function test_missing_route_warning_is_shown_in_preview_notification_and_command(): void
    {
        $this->admin();
        $route = $this->route(false);
        BusAssignment::create(['bus_id' => $route->bus_id, 'driver_id' => User::factory()->create(['role' => 'driver'])->id, 'date' => today()]);
        $warning = __('admin.missing_route', ['bus' => $route->bus->number, 'period' => __('admin.morning')]);
        Livewire::test(DailyPlanning::class)->assertSee($warning)->callAction('generateTrips')
            ->assertSee($warning)->assertNotified(Notification::make()
            ->title(__('admin.operation_result', ['created' => 0, 'skipped' => 2]))
            ->body(implode("\n", app(GenerateDailyTrips::class)->warnings(CarbonImmutable::today())))->warning());
        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-24'])->expectsOutput($warning)->assertSuccessful();
        $this->assertDatabaseCount('active_trips', 0);
    }

    public function test_demo_route_seeding_is_idempotent(): void
    {
        $this->seed(ParentPortalDemoSeeder::class);
        $ids = Route::orderBy('period')->pluck('id')->all();
        $stations = RouteStation::orderBy('id')->pluck('id')->all();
        $this->seed(ParentPortalDemoSeeder::class);
        $this->assertSame($ids, Route::orderBy('period')->pluck('id')->all());
        $this->assertSame($stations, RouteStation::orderBy('id')->pluck('id')->all());
        $this->assertDatabaseCount('routes', 2);
        $this->assertDatabaseCount('route_stations', 10);
        foreach (Route::with('stations')->get() as $route) {
            $this->assertCount(10, $route->route_points_json);
            $this->assertCount(5, $route->stations);
        }
    }

    public function test_non_admins_receive_403_for_route_resource(): void
    {
        foreach (['parent', 'driver'] as $role) {
            $this->actingAs(User::factory()->create(['role' => $role]));
            $this->get('/admin/routes')->assertForbidden();
            $this->get('/admin/routes/create')->assertForbidden();
        }
    }
}

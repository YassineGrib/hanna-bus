<?php

namespace Tests\Feature\Admin;

use App\Filament\Pages\DailyPlanning;
use App\Filament\Resources\AssignmentResource\Pages\CreateAssignment;
use App\Filament\Resources\AssignmentResource\Pages\EditAssignment;
use App\Filament\Resources\BusResource\Pages\CreateBus;
use App\Filament\Resources\SafetyAlertResource\Pages\ListSafetyAlerts;
use App\Filament\Resources\StudentResource;
use App\Filament\Resources\StudentResource\Pages\CreateStudent;
use App\Models\ActiveTrip;
use App\Models\Bus;
use App\Models\BusAssignment;
use App\Models\Child;
use App\Models\SosAlert;
use App\Models\User;
use App\Support\CarryOverAssignments;
use Carbon\CarbonImmutable;
use Database\Seeders\AdminDemoSeeder;
use Database\Seeders\ParentPortalDemoSeeder;
use Filament\Auth\Pages\Login;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Livewire\Livewire;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class AdminPanelTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Filament::setCurrentPanel(Filament::getPanel('admin'));
        $this->travelTo(CarbonImmutable::parse('2026-11-24 08:00:00'));
    }

    private function admin(): User
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $this->actingAs($admin);

        return $admin;
    }

    private function bus(): Bus
    {
        return Bus::create(['number' => '30', 'line_name' => 'North', 'plate_number' => '123',
            'vehicle_model' => 'Sprinter', 'capacity' => 24, 'status' => 'available']);
    }

    public function test_admin_can_open_dashboard_and_guests_are_sent_to_login(): void
    {
        $this->get('/admin')->assertRedirect('/admin/login');
        $this->admin();

        $this->get('/admin')->assertOk();
    }

    public static function deniedRoles(): array
    {
        return ['parent' => ['parent'], 'driver' => ['driver']];
    }

    #[DataProvider('deniedRoles')]
    public function test_non_admins_get_403_for_every_panel_area(string $role): void
    {
        $this->actingAs(User::factory()->create(['role' => $role]));

        foreach (['', '/buses', '/drivers', '/parents', '/students', '/assignments', '/trips', '/safety-alerts', '/bulletins', '/support-messages', '/daily-planning'] as $path) {
            $this->get('/admin'.$path)->assertForbidden();
        }
        $this->post(route('admin.locale'), ['locale' => 'ar'])->assertForbidden();
    }

    public static function resources(): array
    {
        return array_map(fn (string $name): array => [$name], ['Bus', 'Driver', 'Parent', 'Student', 'Assignment', 'Trip', 'SafetyAlert', 'Bulletin', 'SupportMessage']);
    }

    #[DataProvider('resources')]
    public function test_every_resource_list_renders_for_admin(string $name): void
    {
        $this->seed(ParentPortalDemoSeeder::class);
        $this->admin();
        $resource = 'App\\Filament\\Resources\\'.$name.'Resource';

        $this->get($resource::getUrl('index'))->assertOk();
    }

    public function test_admin_creates_bus_through_form(): void
    {
        $this->admin();

        Livewire::test(CreateBus::class)->fillForm(['number' => '90', 'line_name' => 'West', 'plate_number' => '900',
            'vehicle_model' => 'Sprinter', 'capacity' => 32, 'status' => 'available'])->call('create')->assertHasNoFormErrors();

        $this->assertDatabaseHas('buses', ['number' => '90', 'capacity' => 32]);
    }

    public function test_admin_creates_student_with_medical_and_parent_data_and_sees_qr(): void
    {
        $this->admin();
        $bus = $this->bus();
        $parent = User::factory()->create(['role' => 'parent']);
        $data = ['full_name' => 'Amina Test', 'student_code' => 'HB-TEST', 'parent_id' => $parent->id,
            'bus_number' => $bus->number, 'transit_status' => 'at_home', 'stage' => 'primary'];
        foreach (['birth_date', 'national_id', 'school_name', 'grade', 'class_room', 'homeroom_teacher',
            'transport_coordinator', 'dismissal_rule', 'seat_number', 'stop_name', 'stop_time', 'return_time',
            'blood_type', 'insurance_number', 'allergies', 'chronic_conditions', 'pediatrician_name',
            'pediatrician_phone', 'avatar_preset'] as $field) {
            $data[$field] = 'Test value';
        }

        Livewire::test(CreateStudent::class)->fillForm($data)->call('create')->assertHasNoFormErrors();

        $student = Child::where('student_code', 'HB-TEST')->firstOrFail();
        $this->assertDatabaseHas('children', ['id' => $student->id, 'parent_id' => $parent->id, 'national_id' => 'Test value']);
        $this->get(StudentResource::getUrl('view', ['record' => $student]))
            ->assertOk()->assertSee('data:image/svg+xml', false)->assertSee('HB-TEST');
    }

    public function test_assignment_form_rejects_duplicate_driver_date_with_friendly_message(): void
    {
        $this->admin();
        $bus = $this->bus();
        $driver = User::factory()->create(['role' => 'driver']);
        BusAssignment::create(['bus_id' => $bus->id, 'driver_id' => $driver->id, 'date' => '2026-11-24']);

        Livewire::test(CreateAssignment::class)->fillForm(['bus_id' => $bus->id, 'driver_id' => $driver->id, 'date' => '2026-11-24'])
            ->call('create')->assertHasFormErrors(['driver_id' => 'unique'])->assertSee(__('admin.assignment_unique'));

        $this->assertDatabaseCount('bus_assignments', 1);
    }

    public function test_assignment_form_accepts_another_date_and_edit_can_keep_its_own_date(): void
    {
        $this->admin();
        $bus = $this->bus();
        $driver = User::factory()->create(['role' => 'driver']);
        $assignment = BusAssignment::create(['bus_id' => $bus->id, 'driver_id' => $driver->id, 'date' => '2026-11-24']);

        Livewire::test(CreateAssignment::class)->fillForm(['bus_id' => $bus->id, 'driver_id' => $driver->id, 'date' => '2026-11-25'])
            ->call('create')->assertHasNoFormErrors();
        Livewire::test(EditAssignment::class, ['record' => $assignment->id])
            ->call('save')->assertHasNoFormErrors();

        $this->assertDatabaseCount('bus_assignments', 2);
    }

    public function test_carry_over_preserves_existing_assignments_and_is_idempotent(): void
    {
        $bus = $this->bus();
        $otherBus = $bus->replicate();
        $otherBus->number = '31';
        $otherBus->save();
        $drivers = User::factory()->count(2)->create(['role' => 'driver']);
        foreach ($drivers as $driver) {
            BusAssignment::create(['bus_id' => $bus->id, 'driver_id' => $driver->id, 'date' => '2026-11-23']);
        }
        BusAssignment::create(['bus_id' => $otherBus->id, 'driver_id' => $drivers[0]->id, 'date' => '2026-11-24']);

        $carry = app(CarryOverAssignments::class);
        $this->assertSame(['created' => 1, 'skipped' => 1], $carry->handle(CarbonImmutable::parse('2026-11-24')));
        $this->assertSame(['created' => 0, 'skipped' => 2], $carry->handle(CarbonImmutable::parse('2026-11-24')));
        $this->assertDatabaseHas('bus_assignments', ['driver_id' => $drivers[0]->id, 'date' => '2026-11-24', 'bus_id' => $otherBus->id]);
    }

    public function test_carry_over_uses_thursday_for_sunday_and_empty_source_creates_nothing(): void
    {
        $driver = User::factory()->create(['role' => 'driver']);
        BusAssignment::create(['bus_id' => $this->bus()->id, 'driver_id' => $driver->id, 'date' => '2026-11-19']);

        $this->assertSame(['created' => 1, 'skipped' => 0], app(CarryOverAssignments::class)->handle(CarbonImmutable::parse('2026-11-22')));
        $this->assertSame(['created' => 0, 'skipped' => 0], app(CarryOverAssignments::class)->handle(CarbonImmutable::parse('2026-11-18')));
    }

    public function test_carry_over_copies_from_the_latest_earlier_day_with_assignments(): void
    {
        $this->admin();
        $driver = User::factory()->create(['role' => 'driver']);
        BusAssignment::create(['bus_id' => $this->bus()->id, 'driver_id' => $driver->id, 'date' => '2026-11-19']);

        // Monday: the previous day (Sunday) and the weekend have nothing, Thursday does.
        $carry = app(CarryOverAssignments::class);
        $this->assertSame('2026-11-19', $carry->sourceDate(CarbonImmutable::parse('2026-11-23'))?->toDateString());
        $this->assertNull($carry->sourceDate(CarbonImmutable::parse('2026-11-19')));

        Livewire::test(DailyPlanning::class)->set('date', '2026-11-23')->callAction('carryOver')
            ->assertNotified(__('admin.operation_result', ['created' => 1, 'skipped' => 0]));
        $this->assertDatabaseHas('bus_assignments', ['driver_id' => $driver->id, 'date' => '2026-11-23']);

        // With nothing earlier the admin is told why instead of seeing "Created 0".
        Livewire::test(DailyPlanning::class)->set('date', '2026-11-18')->callAction('carryOver')
            ->assertNotified(__('admin.carry_over_none'));
    }

    public function test_generate_trips_action_uses_selected_date_and_reports_counts(): void
    {
        $this->seed(ParentPortalDemoSeeder::class);
        $this->admin();
        $source = BusAssignment::firstOrFail();
        BusAssignment::create(['driver_id' => $source->driver_id, 'bus_id' => $source->bus_id, 'date' => '2026-11-25']);

        Livewire::test(DailyPlanning::class)->set('date', '2026-11-25')->callAction('generateTrips')->assertNotified(__('admin.operation_result', ['created' => 2, 'skipped' => 0]));

        $this->assertSame(2, ActiveTrip::whereDate('service_date', '2026-11-25')->count());
        $this->assertTrue(ActiveTrip::whereDate('service_date', '2026-11-25')->where('status', 'scheduled')->where('driver_id', $source->driver_id)->exists());
    }

    public function test_carry_over_action_and_artisan_option_copy_assignments(): void
    {
        $this->admin();
        $driver = User::factory()->create(['role' => 'driver']);
        BusAssignment::create(['bus_id' => $this->bus()->id, 'driver_id' => $driver->id, 'date' => '2026-11-23']);

        Livewire::test(DailyPlanning::class)->set('date', '2026-11-24')->callAction('carryOver')
            ->assertNotified(__('admin.operation_result', ['created' => 1, 'skipped' => 0]));
        $this->artisan('hanna:generate-trips', ['--date' => '2026-11-25', '--carry-assignments' => true])->assertSuccessful();

        $this->assertDatabaseHas('bus_assignments', ['driver_id' => $driver->id, 'date' => '2026-11-25']);
    }

    public function test_close_sos_action_closes_alert(): void
    {
        $this->admin();
        $driver = User::factory()->create(['role' => 'driver']);
        $alert = SosAlert::create(['driver_id' => $driver->id, 'type' => 'medical', 'status' => 'open', 'lat' => 36.75, 'lng' => 3.05]);

        Livewire::test(ListSafetyAlerts::class)->callTableAction('close', $alert);

        $this->assertDatabaseHas('sos_alerts', ['id' => $alert->id, 'status' => 'closed']);
    }

    public function test_locale_switch_persists_and_dashboard_is_rtl(): void
    {
        $admin = $this->admin();

        $this->post(route('admin.locale'), ['locale' => 'ar'])->assertRedirect('/admin');

        $this->assertSame('ar', $admin->fresh()->locale);
        $this->get('/admin')->assertOk()->assertSee('dir="rtl"', false)->assertSee(__('admin.dashboard', [], 'ar'));
        $this->post(route('admin.locale'), ['locale' => 'fr'])->assertSessionHasErrors('locale');
        $this->assertSame('ar', $admin->fresh()->locale);
    }

    public function test_admin_bearer_token_cannot_call_mobile_apis(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('admin-test')->plainTextToken;

        $this->withToken($token)->getJson('/api/v1/parent/children')->assertForbidden();
        $this->withToken($token)->getJson('/api/v1/driver/profile')->assertForbidden();
    }

    public function test_demo_admin_is_seeded_only_locally_or_in_testing(): void
    {
        $this->seed(AdminDemoSeeder::class);

        $admin = User::where('email', 'admin@hanna.dz')->firstOrFail();
        $this->assertSame('admin', $admin->role);
        $this->assertTrue(Hash::check('Password123!', $admin->password));
        $admin->delete();
        app()->detectEnvironment(fn (): string => 'production');
        $this->artisan('db:seed', ['--class' => AdminDemoSeeder::class, '--force' => true])->assertSuccessful();
        $this->assertDatabaseMissing('users', ['email' => 'admin@hanna.dz']);
    }

    public function test_seeded_admin_can_authenticate_using_standard_filament_login(): void
    {
        $this->seed(AdminDemoSeeder::class);
        $this->get('/admin/login')->assertOk();

        Livewire::test(Login::class)->fillForm(['email' => 'admin@hanna.dz', 'password' => 'Password123!'])
            ->call('authenticate')->assertHasNoFormErrors()->assertRedirect('/admin');

        $this->assertAuthenticatedAs(User::where('email', 'admin@hanna.dz')->firstOrFail());
        $this->get('/admin')->assertOk();
    }
}

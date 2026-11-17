<?php

namespace Tests\Feature;

use App\Models\SafetyNotification;
use App\Models\SchoolBulletin;
use App\Models\User;
use Database\Seeders\ParentPortalDemoSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ParentPortalExtrasTest extends TestCase
{
    use RefreshDatabase;

    public function test_profile_preferences_alerts_notifications_bulletins_and_support(): void
    {
        $user = User::create([
            'name' => 'Karim Mansouri',
            'email' => 'k.mansouri@mail.dz',
            'phone' => '+213 550 12 34 56',
            'password' => 'Password123!',
        ]);
        $token = $user->createToken('test')->plainTextToken;

        $this->withToken($token)->putJson('/api/v1/parent/profile', [
            'name' => 'Karim M.',
            'email' => 'karim.new@mail.dz',
            'phone' => '+213 550 11 22 33',
            'backup_phone' => '+213 551 98 76 54',
            'primary_bus_stop' => 'Hay El Nasr Stop 03',
        ])->assertStatus(200)
            ->assertJsonPath('email', 'karim.new@mail.dz')
            ->assertJsonPath('backup_phone', '+213 551 98 76 54');

        $this->assertDatabaseHas('users', ['id' => $user->id, 'email' => 'karim.new@mail.dz']);

        $this->withToken($token)->putJson('/api/v1/parent/settings/preferences', [
            'theme_palette' => 'tealGray',
            'brightness_mode' => 'dark',
            'locale' => 'ar',
        ])->assertStatus(200)
            ->assertJsonPath('theme_palette', 'tealGray')
            ->assertJsonPath('locale', 'ar');

        $this->withToken($token)->putJson('/api/v1/parent/settings/alerts', [
            'global_radius_meters' => 500,
            'route_delays' => true,
        ])->assertStatus(200)
            ->assertJsonPath('global_radius_meters', 500)
            ->assertJsonPath('route_delays', true);

        $n = SafetyNotification::create([
            'parent_id' => $user->id,
            'category' => 'bus',
            'title_en' => 'Approaching Gate',
            'title_ar' => 'اقتراب الحافلة',
            'title_fr' => 'Arrivee proche',
            'body_en' => '4 min away',
            'body_ar' => 'على بعد 4 دقائق',
            'body_fr' => 'Dans 4 min',
            'day_group' => 'today',
            'time_label' => '2m ago',
            'is_read' => false,
        ]);

        $this->withToken($token)
            ->withHeaders(['Accept-Language' => 'fr'])
            ->getJson('/api/v1/parent/notifications')
            ->assertStatus(200)
            ->assertJsonPath('data.0.title', 'Arrivee proche')
            ->assertJsonPath('data.0.is_read', false);

        $this->withToken($token)->putJson("/api/v1/parent/notifications/{$n->id}/read")
            ->assertStatus(200)
            ->assertJsonPath('is_read', true);

        $this->withToken($token)->putJson('/api/v1/parent/notifications/read-all')
            ->assertStatus(200);

        SchoolBulletin::create([
            'tag' => 'SCHEDULE',
            'title_en' => 'Early Dismissal',
            'title_ar' => 'انصراف مبكّر',
            'title_fr' => 'Sortie anticipee',
            'body_en' => 'Thursday 02:30 PM',
            'body_ar' => 'الخميس 02:30 م',
            'body_fr' => 'Jeudi 14h30',
            'published_at' => now(),
        ]);

        $this->withToken($token)
            ->withHeaders(['Accept-Language' => 'ar'])
            ->getJson('/api/v1/parent/bulletins')
            ->assertStatus(200)
            ->assertJsonPath('data.0.title', 'انصراف مبكّر');

        $this->withToken($token)->postJson('/api/v1/parent/support/messages', [
            'recipient_type' => 'driver',
            'message' => 'Please wait 2 minutes at Stop 03.',
        ])->assertStatus(201)
            ->assertJsonPath('status', 'sent');

        $this->withToken($token)->getJson('/api/v1/parent/emergency-contacts')
            ->assertStatus(200)
            ->assertJsonStructure(['data']);
    }

    public function test_demo_seeder_is_idempotent_and_populates_complete_family_portal(): void
    {
        $this->seed(ParentPortalDemoSeeder::class);
        $this->seed(ParentPortalDemoSeeder::class);

        $this->assertDatabaseHas('users', ['email' => 'k.mansouri@mail.dz']);
        $this->assertDatabaseHas('children', ['student_code' => 'HB-304']);
        $this->assertDatabaseHas('children', ['student_code' => 'HB-208']);
        $this->assertDatabaseHas('children', ['student_code' => 'HB-105']);
        $this->assertDatabaseHas('active_trips', ['bus_number' => '04']);
        $this->assertDatabaseHas('trip_histories', ['id' => '9042']);
    }
}

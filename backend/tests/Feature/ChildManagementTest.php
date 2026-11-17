<?php

namespace Tests\Feature;

use App\Models\Child;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ChildManagementTest extends TestCase
{
    use RefreshDatabase;

    public function test_parent_can_create_update_list_and_delete_child_with_extended_dossier(): void
    {
        $parent = User::create([
            'name' => 'Karim',
            'email' => 'karim@mail.dz',
            'password' => Hash::make('Password123!'),
        ]);
        $token = $parent->createToken('test')->plainTextToken;

        $create = $this->withToken($token)->postJson('/api/v1/parent/children', [
            'full_name' => 'Rayan Mansouri',
            'stage' => 'preschool',
            'school_name' => 'Al Manar Preschool',
            'grade' => 'KG 2',
            'bus_number' => '04',
            'seat_number' => 'A1',
            'stop_name' => 'Hay El Nasr, Stop 03',
            'blood_type' => 'A+',
            'allergies' => 'Peanut Allergy',
            'pediatrician_name' => 'Dr. Amine Boudiaf',
            'schedule' => [
                'sun' => ['pickup' => '08:15 AM', 'dropoff' => '03:45 PM'],
            ],
        ]);

        $create->assertStatus(201)
            ->assertJsonPath('data.full_name', 'Rayan Mansouri')
            ->assertJsonPath('data.stage', 'preschool')
            ->assertJsonPath('data.pediatrician_name', 'Dr. Amine Boudiaf');

        $childId = $create->json('data.id');

        $this->withToken($token)->getJson('/api/v1/parent/children')
            ->assertStatus(200)
            ->assertJsonCount(1, 'data');

        $this->withToken($token)->putJson("/api/v1/parent/children/{$childId}", [
            'seat_number' => 'A3',
            'transit_status' => 'at_school',
        ])->assertStatus(200)
            ->assertJsonPath('data.seat_number', 'A3')
            ->assertJsonPath('data.transit_status', 'at_school');

        $this->withToken($token)->deleteJson("/api/v1/parent/children/{$childId}")
            ->assertStatus(200);

        $this->assertDatabaseMissing('children', ['id' => $childId]);
    }

    public function test_cross_parent_isolation_and_school_code_linking(): void
    {
        $parentA = User::create(['name' => 'A', 'email' => 'a@mail.dz', 'password' => Hash::make('Password123!')]);
        $parentB = User::create(['name' => 'B', 'email' => 'b@mail.dz', 'password' => Hash::make('Password123!')]);

        $ownedByA = Child::create([
            'id' => 'child-a',
            'parent_id' => $parentA->id,
            'student_code' => 'HB-304',
            'full_name' => 'Youssef',
            'school_name' => 'El Wiam',
            'grade' => 'Grade 3',
        ]);

        Child::create([
            'id' => 'child-unassigned',
            'parent_id' => null,
            'student_code' => 'HB-2026-9911',
            'full_name' => 'Salma',
            'school_name' => 'El Wiam',
            'grade' => 'Grade 2',
        ]);

        $tokenB = $parentB->createToken('test')->plainTextToken;

        $this->withToken($tokenB)->getJson("/api/v1/parent/children/{$ownedByA->id}")->assertStatus(403);
        $this->withToken($tokenB)->putJson("/api/v1/parent/children/{$ownedByA->id}", ['grade' => 'Grade 4'])->assertStatus(403);
        $this->withToken($tokenB)->deleteJson("/api/v1/parent/children/{$ownedByA->id}")->assertStatus(403);

        // Linking a child already owned by parent A returns 409 Conflict
        $this->withToken($tokenB)->postJson('/api/v1/parent/children/link', [
            'student_code' => 'HB-304',
        ])->assertStatus(409);

        // Linking an unassigned student succeeds
        $this->withToken($tokenB)->postJson('/api/v1/parent/children/link', [
            'student_code' => 'HB-2026-9911',
        ])->assertStatus(200)
            ->assertJsonPath('data.student_code', 'HB-2026-9911');
    }

    public function test_parent_can_report_and_resume_absence_today(): void
    {
        $parent = User::create(['name' => 'Karim', 'email' => 'k@mail.dz', 'password' => Hash::make('Password123!')]);
        Child::create([
            'id' => 'child-y',
            'parent_id' => $parent->id,
            'student_code' => 'HB-304',
            'full_name' => 'Youssef',
            'school_name' => 'El Wiam',
            'grade' => 'Grade 3',
            'transit_status' => 'on_bus',
        ]);
        $token = $parent->createToken('test')->plainTextToken;

        $this->withToken($token)->postJson('/api/v1/parent/attendance/absences', [
            'child_id' => 'child-y',
            'reason' => 'Family appointment',
        ])->assertStatus(201);

        $this->assertDatabaseHas('children', ['id' => 'child-y', 'transit_status' => 'absent']);

        $this->withToken($token)->deleteJson('/api/v1/parent/attendance/absences/child-y/today')
            ->assertStatus(200);

        $this->assertDatabaseHas('children', ['id' => 'child-y', 'transit_status' => 'at_home']);
    }
}

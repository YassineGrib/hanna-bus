<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class HealthAndSchemaTest extends TestCase
{
    use RefreshDatabase;

    public function test_health_endpoint_returns_operational_json(): void
    {
        $response = $this->getJson('/api/v1/health');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'operational',
                'service' => 'Hanna Bus Parent API',
                'version' => '1.0.0',
            ]);
    }

    public function test_all_hanna_bus_tables_exist(): void
    {
        $tables = [
            'users',
            'personal_access_tokens',
            'parent_otp_codes',
            'children',
            'active_trips',
            'trip_stations',
            'trip_histories',
            'absence_reports',
            'safety_notifications',
            'school_bulletins',
            'support_messages',
            'transit_alert_settings',
        ];

        foreach ($tables as $table) {
            $this->assertTrue(Schema::hasTable($table), "Missing expected table: {$table}");
        }
    }
}

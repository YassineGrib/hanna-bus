<?php

namespace Database\Factories;

use App\Models\Bus;
use Illuminate\Database\Eloquent\Factories\Factory;

class RouteFactory extends Factory
{
    public function definition(): array
    {
        return [
            'bus_id' => fn () => Bus::create([
                'number' => fake()->unique()->numerify('#####'), 'line_name' => 'School',
                'plate_number' => fake()->numerify('#####'), 'vehicle_model' => 'Sprinter',
                'capacity' => 24, 'status' => 'available',
            ])->id,
            'period' => 'morning', 'name' => fake()->streetName(),
            'scheduled_start' => '07:00:00', 'is_active' => false,
        ];
    }
}

<?php

namespace Database\Factories;

use App\Models\Route;
use Illuminate\Database\Eloquent\Factories\Factory;

class RouteStationFactory extends Factory
{
    public function definition(): array
    {
        return [
            'route_id' => Route::factory(), 'sort_order' => 1,
            'name_en' => fake()->streetName(), 'subtitle_en' => fake()->city(),
            'scheduled_time' => '07:05', 'lat' => 36.75, 'lng' => 3.05,
        ];
    }
}

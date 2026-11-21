<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('driver_profiles', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('license_number');
            $table->float('rating')->default(4.9);
            $table->unsignedInteger('trips_count')->default(0);
            $table->timestamps();
        });
        Schema::create('buses', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('number')->unique();
            $table->string('line_name');
            $table->string('plate_number');
            $table->string('vehicle_model');
            $table->unsignedInteger('capacity');
            $table->string('status')->default('available');
            $table->timestamps();
        });
        foreach (['bus_assignments', 'bus_inspections'] as $name) {
            Schema::create($name, function (Blueprint $table) use ($name) {
                $table->string('id')->primary();
                $table->foreignId('driver_id')->constrained('users')->cascadeOnDelete();
                $table->string('bus_id');
                $table->foreign('bus_id')->references('id')->on('buses')->cascadeOnDelete();
                $table->date('date');
                if ($name === 'bus_assignments') {
                    $table->unique(['driver_id', 'date']);
                } else {
                    $table->json('items_json');
                    $table->boolean('passed');
                }
                $table->timestamps();
            });
        }
        Schema::table('active_trips', function (Blueprint $table) {
            $table->foreignId('driver_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('bus_id')->nullable();
            $table->foreign('bus_id')->references('id')->on('buses')->nullOnDelete();
            $table->double('lat')->nullable();
            $table->double('lng')->nullable();
            $table->float('heading')->nullable();
            $table->timestamp('last_location_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('ended_at')->nullable();
            $table->json('route_points_json')->nullable();
            // Trips need a service date and scheduled departure independent of creation time.
            $table->date('service_date')->nullable()->index();
            $table->timestamp('scheduled_start')->nullable();
            $table->unsignedInteger('delay_minutes')->default(0);
        });
        Schema::table('trip_stations', function (Blueprint $table) {
            $table->double('lat')->nullable();
            $table->double('lng')->nullable();
        });
        Schema::table('support_messages', function (Blueprint $table) {
            $table->foreignId('driver_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('direction')->default('parent_to_driver');
            $table->timestamp('read_at')->nullable();
            $table->boolean('urgent')->default(false);
        });
        Schema::table('trip_histories', function (Blueprint $table) {
            $table->string('trip_id')->nullable();
            $table->foreign('trip_id')->references('id')->on('active_trips')->nullOnDelete();
            $table->json('route_points_json')->nullable();
            $table->unique(['trip_id', 'child_id']);
        });
        Schema::create('boarding_events', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('trip_id');
            $table->foreign('trip_id')->references('id')->on('active_trips')->cascadeOnDelete();
            $table->string('child_id');
            $table->foreign('child_id')->references('id')->on('children')->cascadeOnDelete();
            $table->foreignId('station_id')->nullable()->constrained('trip_stations')->nullOnDelete();
            $table->string('type');
            $table->string('method');
            $table->foreignId('driver_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('recorded_at');
            $table->unique(['trip_id', 'child_id', 'type']);
            $table->timestamps();
        });
        Schema::create('trip_location_points', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('trip_id');
            $table->foreign('trip_id')->references('id')->on('active_trips')->cascadeOnDelete();
            $table->double('lat');
            $table->double('lng');
            $table->float('speed_kmh')->nullable();
            $table->float('heading')->nullable();
            $table->timestamp('recorded_at');
            $table->timestamps();
        });
        Schema::create('sos_alerts', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('driver_id')->constrained('users')->cascadeOnDelete();
            $table->string('trip_id')->nullable();
            $table->foreign('trip_id')->references('id')->on('active_trips')->nullOnDelete();
            $table->string('type');
            $table->double('lat')->nullable();
            $table->double('lng')->nullable();
            $table->string('status')->default('open');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sos_alerts');
        Schema::dropIfExists('trip_location_points');
        Schema::dropIfExists('boarding_events');
        Schema::table('trip_histories', function (Blueprint $table) {
            $table->dropUnique(['trip_id', 'child_id']);
            $table->dropForeign(['trip_id']);
            $table->dropColumn(['trip_id', 'route_points_json']);
        });
        Schema::table('support_messages', function (Blueprint $table) {
            $table->dropForeign(['driver_id']);
            $table->dropColumn(['driver_id', 'direction', 'read_at', 'urgent']);
        });
        Schema::table('trip_stations', fn (Blueprint $table) => $table->dropColumn(['lat', 'lng']));
        Schema::table('active_trips', function (Blueprint $table) {
            $table->dropForeign(['driver_id']);
            $table->dropForeign(['bus_id']);
            $table->dropIndex(['service_date']);
            $table->dropColumn(['driver_id', 'bus_id', 'lat', 'lng', 'heading', 'last_location_at', 'started_at', 'ended_at', 'route_points_json', 'service_date', 'scheduled_start', 'delay_minutes']);
        });
        Schema::dropIfExists('bus_inspections');
        Schema::dropIfExists('bus_assignments');
        Schema::dropIfExists('buses');
        Schema::dropIfExists('driver_profiles');
    }
};

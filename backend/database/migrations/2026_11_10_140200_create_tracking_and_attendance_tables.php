<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('active_trips', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('bus_number')->index();
            $table->string('route_name');
            $table->string('driver_name');
            $table->string('driver_phone');
            $table->string('vehicle_model')->default('Mercedes Sprinter');
            $table->string('plate_number')->default('04821-116');
            $table->boolean('is_morning')->default(true);
            $table->integer('eta_minutes')->default(4);
            $table->float('distance_km')->default(1.2);
            $table->integer('speed_kmh')->default(38);
            $table->float('progress')->default(0.68);
            $table->integer('onboard_count')->default(19);
            $table->integer('capacity')->default(24);
            $table->string('current_street')->default('Blvd des Martyrs');
            $table->string('status')->default('en_route');
            $table->timestamps();
        });

        Schema::create('trip_stations', function (Blueprint $table) {
            $table->id();
            $table->string('trip_id');
            $table->foreign('trip_id')->references('id')->on('active_trips')->cascadeOnDelete();
            $table->integer('sort_order');
            $table->string('name_en');
            $table->string('name_ar');
            $table->string('name_fr');
            $table->string('scheduled_time');
            $table->string('subtitle_en');
            $table->string('subtitle_ar');
            $table->string('subtitle_fr');
            $table->string('status')->default('upcoming'); // completed|current|upcoming
            $table->timestamps();
        });

        Schema::create('trip_histories', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('child_id')->index();
            $table->foreign('child_id')->references('id')->on('children')->cascadeOnDelete();
            $table->string('bus_number');
            $table->string('period'); // morning|return
            $table->string('trip_date'); // e.g. 2026-11-09
            $table->string('date_group_en');
            $table->string('date_group_ar');
            $table->string('date_group_fr');
            $table->string('departure_time');
            $table->string('arrival_time');
            $table->integer('duration_minutes');
            $table->float('distance_km');
            $table->integer('avg_speed_kmh');
            $table->string('status_code')->default('completed'); // completed|delayed
            $table->integer('delay_minutes')->default(0);
            $table->string('driver_name');
            $table->float('driver_rating')->default(4.9);
            $table->string('vehicle_model')->default('Mercedes Sprinter');
            $table->json('waypoints_json')->nullable();
            $table->json('qr_audit_json')->nullable();
            $table->timestamps();
        });

        Schema::create('absence_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_id')->constrained('users')->cascadeOnDelete();
            $table->string('child_id');
            $table->foreign('child_id')->references('id')->on('children')->cascadeOnDelete();
            $table->date('absence_date');
            $table->string('reason')->nullable();
            $table->string('status')->default('confirmed');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('absence_reports');
        Schema::dropIfExists('trip_histories');
        Schema::dropIfExists('trip_stations');
        Schema::dropIfExists('active_trips');
    }
};

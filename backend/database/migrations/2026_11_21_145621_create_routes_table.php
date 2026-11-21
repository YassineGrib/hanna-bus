<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('routes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('bus_id');
            $table->foreign('bus_id')->references('id')->on('buses')->cascadeOnDelete();
            $table->enum('period', ['morning', 'return']);
            $table->string('name');
            $table->time('scheduled_start')->nullable();
            $table->json('route_points_json')->nullable();
            $table->boolean('is_active')->default(true);
            $table->unique(['bus_id', 'period']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('routes');
    }
};

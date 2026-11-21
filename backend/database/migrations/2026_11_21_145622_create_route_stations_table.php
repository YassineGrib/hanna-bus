<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('route_stations', function (Blueprint $table) {
            $table->id();
            $table->foreignUuid('route_id')->constrained()->cascadeOnDelete();
            $table->unsignedInteger('sort_order');
            $table->string('name_en');
            $table->string('name_ar')->nullable();
            $table->string('name_fr')->nullable();
            $table->string('subtitle_en');
            $table->string('subtitle_ar')->nullable();
            $table->string('subtitle_fr')->nullable();
            $table->string('scheduled_time');
            $table->double('lat')->nullable();
            $table->double('lng')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('route_stations');
    }
};

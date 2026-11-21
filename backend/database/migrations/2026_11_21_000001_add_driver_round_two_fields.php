<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('buses', function (Blueprint $table) {
            $table->date('insurance_expires_on')->nullable();
            $table->date('technical_control_expires_on')->nullable();
            $table->date('last_service_on')->nullable();
        });
        Schema::table('driver_profiles', fn (Blueprint $table) => $table->json('settings_json')->nullable());
    }

    public function down(): void
    {
        Schema::table('driver_profiles', fn (Blueprint $table) => $table->dropColumn('settings_json'));
        Schema::table('buses', fn (Blueprint $table) => $table->dropColumn([
            'insurance_expires_on', 'technical_control_expires_on', 'last_service_on',
        ]));
    }
};

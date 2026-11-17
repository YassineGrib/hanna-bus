<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone')->nullable()->after('email');
            $table->string('backup_phone')->nullable()->after('phone');
            $table->string('role')->default('parent')->after('password');
            $table->boolean('is_verified')->default(true)->after('role');
            $table->string('avatar_preset')->default('avatar_1')->after('is_verified');
            $table->string('primary_bus_stop')->default('Hay El Nasr, Algiers')->after('avatar_preset');
            $table->string('theme_palette')->default('mustard')->after('primary_bus_stop');
            $table->string('brightness_mode')->default('light')->after('theme_palette');
            $table->string('locale')->default('en')->after('brightness_mode');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'phone', 'backup_phone', 'role', 'is_verified', 'avatar_preset',
                'primary_bus_stop', 'theme_palette', 'brightness_mode', 'locale',
            ]);
        });
    }
};

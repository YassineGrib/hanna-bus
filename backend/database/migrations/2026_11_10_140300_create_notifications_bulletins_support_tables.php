<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('safety_notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_id')->constrained('users')->cascadeOnDelete();
            $table->string('child_id')->nullable();
            $table->string('category')->default('bus'); // bus|school
            $table->string('title_en');
            $table->string('title_ar');
            $table->string('title_fr');
            $table->text('body_en');
            $table->text('body_ar');
            $table->text('body_fr');
            $table->string('day_group')->default('today'); // today|yesterday
            $table->string('time_label');
            $table->boolean('is_read')->default(false);
            $table->timestamps();
        });

        Schema::create('school_bulletins', function (Blueprint $table) {
            $table->id();
            $table->string('tag'); // SCHEDULE|STOP UPDATE|TERM NOTICE
            $table->string('title_en');
            $table->string('title_ar');
            $table->string('title_fr');
            $table->text('body_en');
            $table->text('body_ar');
            $table->text('body_fr');
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
        });

        Schema::create('support_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_id')->constrained('users')->cascadeOnDelete();
            $table->string('recipient_type')->default('coordinator'); // driver|coordinator
            $table->string('child_id')->nullable();
            $table->text('message');
            $table->string('status')->default('sent');
            $table->timestamps();
        });

        Schema::create('transit_alert_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->integer('global_radius_meters')->default(400);
            $table->boolean('bus_approaching')->default(true);
            $table->boolean('child_boarded')->default(true);
            $table->boolean('arrived_safely')->default(true);
            $table->boolean('route_delays')->default(false);
            $table->boolean('critical_sos_sound')->default(true);
            $table->boolean('sms_backup')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transit_alert_settings');
        Schema::dropIfExists('support_messages');
        Schema::dropIfExists('school_bulletins');
        Schema::dropIfExists('safety_notifications');
    }
};

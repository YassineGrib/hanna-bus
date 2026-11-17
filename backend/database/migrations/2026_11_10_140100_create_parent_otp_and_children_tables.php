<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('parent_otp_codes', function (Blueprint $table) {
            $table->id();
            $table->string('email')->index();
            $table->string('code', 6);
            $table->string('reset_token')->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->timestamp('expires_at');
            $table->timestamps();
        });

        Schema::create('children', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('parent_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('student_code')->unique();
            $table->string('full_name');
            $table->string('birth_date')->default('14 March 2018');
            $table->string('national_id')->default('180349');
            $table->string('stage')->default('primary'); // preschool|primary|middle|secondary
            $table->string('school_name');
            $table->string('grade');
            $table->string('class_room')->default('Section B (Rm 14)');
            $table->string('homeroom_teacher')->default('Mrs. Nadia Khelifi');
            $table->string('transport_coordinator')->default('Mr. Tarek M.');
            $table->string('dismissal_rule')->default('Bus only · Parent PIN required');
            $table->string('bus_number')->default('04');
            $table->string('seat_number')->default('A2');
            $table->string('stop_name')->default('Hay El Nasr, Stop 03');
            $table->string('stop_time')->default('07:15 AM');
            $table->string('return_time')->default('03:20 PM');
            $table->string('transit_status')->default('on_bus'); // on_bus|at_school|at_home|absent
            $table->string('avatar_preset')->default('student_1');
            $table->string('blood_type')->default('O+');
            $table->string('insurance_number')->default('CNAS #88412');
            $table->string('allergies')->default('None reported');
            $table->string('chronic_conditions')->default('None');
            $table->text('first_aid_protocol')->nullable();
            $table->string('pediatrician_name')->default('Dr. Amine Boudiaf');
            $table->string('pediatrician_phone')->default('+213 21 65 44 12');
            $table->json('schedule_json')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('children');
        Schema::dropIfExists('parent_otp_codes');
    }
};

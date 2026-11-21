<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class AdminDemoSeeder extends Seeder
{
    public function run(): void
    {
        if (! app()->environment(['local', 'testing'])) {
            return;
        }
        User::firstOrCreate(['email' => 'admin@hanna.dz'], [
            'name' => 'Hanna Bus Admin', 'password' => 'Password123!', 'role' => 'admin', 'locale' => 'en',
        ]);
    }
}

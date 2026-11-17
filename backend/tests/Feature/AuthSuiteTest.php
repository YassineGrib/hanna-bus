<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthSuiteTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_without_phone_returns_sanctum_token_and_creates_alert_settings(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Karim Mansouri',
            'email' => 'karim@mail.dz',
            'password' => 'SecretPass1!',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email']]);

        $user = User::where('email', 'karim@mail.dz')->first();
        $this->assertNotNull($user);
        $this->assertNotNull($user->alertSettings);
    }

    public function test_login_validates_credentials_and_fetches_me(): void
    {
        User::create([
            'name' => 'Karim',
            'email' => 'k.mansouri@mail.dz',
            'password' => Hash::make('Password123!'),
        ]);

        $this->postJson('/api/v1/auth/login', [
            'email' => 'k.mansouri@mail.dz',
            'password' => 'wrong-pass',
        ])->assertStatus(401);

        $login = $this->postJson('/api/v1/auth/login', [
            'email' => 'k.mansouri@mail.dz',
            'password' => 'Password123!',
        ])->assertStatus(200);

        $token = $login->json('token');
        $this->withToken($token)->getJson('/api/v1/auth/me')
            ->assertStatus(200)
            ->assertJsonPath('email', 'k.mansouri@mail.dz');

        $this->withToken($token)->postJson('/api/v1/auth/logout')
            ->assertStatus(200);
    }

    public function test_otp_password_recovery_and_reset_authenticates_user(): void
    {
        User::create([
            'name' => 'Karim',
            'email' => 'k.mansouri@mail.dz',
            'password' => Hash::make('OldPassword1!'),
        ]);

        $this->postJson('/api/v1/auth/forgot-password', ['email' => 'nobody@mail.dz'])
            ->assertStatus(422);

        $forgot = $this->postJson('/api/v1/auth/forgot-password', ['email' => 'k.mansouri@mail.dz'])
            ->assertStatus(200)
            ->assertJsonStructure(['message', 'demo_otp']);

        $otp = $forgot->json('demo_otp');

        $this->postJson('/api/v1/auth/verify-otp', [
            'email' => 'k.mansouri@mail.dz',
            'code' => '000000',
        ])->assertStatus(422);

        $verify = $this->postJson('/api/v1/auth/verify-otp', [
            'email' => 'k.mansouri@mail.dz',
            'code' => $otp,
        ])->assertStatus(200)
            ->assertJson(['verified' => true]);

        $resetToken = $verify->json('reset_token');

        $reset = $this->postJson('/api/v1/auth/reset-password', [
            'email' => 'k.mansouri@mail.dz',
            'reset_token' => $resetToken,
            'password' => 'NewPass123!',
            'password_confirmation' => 'NewPass123!',
        ])->assertStatus(200)
            ->assertJsonStructure(['token', 'user']);

        $this->withToken($reset->json('token'))
            ->getJson('/api/v1/auth/me')
            ->assertStatus(200);
    }

    public function test_delete_account_requires_confirmation_keyword(): void
    {
        $user = User::create([
            'name' => 'Karim',
            'email' => 'delete@mail.dz',
            'password' => Hash::make('Password123!'),
        ]);
        $token = $user->createToken('test')->plainTextToken;

        $this->withToken($token)->deleteJson('/api/v1/parent/account', [
            'confirmation' => 'WRONG',
        ])->assertStatus(422);

        $this->withToken($token)->deleteJson('/api/v1/parent/account', [
            'confirmation' => 'DELETE',
        ])->assertStatus(200);

        $this->assertDatabaseMissing('users', ['email' => 'delete@mail.dz']);
    }
}

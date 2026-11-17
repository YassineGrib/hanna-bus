<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ParentOtpCode;
use App\Models\TransitAlertSetting;
use App\Models\User;
use App\Support\Trilingual;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'phone' => ['nullable', 'string', 'max:40'],
            'locale' => ['nullable', 'in:en,ar,fr'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'] ?? '+213 550 00 00 00',
            'password' => $validated['password'],
            'role' => 'parent',
            'locale' => $validated['locale'] ?? Trilingual::lang($request),
        ]);

        TransitAlertSetting::create(['parent_id' => $user->id]);

        $token = $user->createToken('hanna-parent')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            $lang = Trilingual::lang($request);
            return response()->json([
                'message' => Trilingual::pick(
                    $lang,
                    'Invalid email or password.',
                    'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
                    'E-mail ou mot de passe invalide.'
                ),
            ], 401);
        }

        $token = $user->createToken('hanna-parent')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
        ]);
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email', 'exists:users,email'],
        ]);

        $code = app()->environment(['local', 'testing'])
            ? '482910'
            : (string) random_int(100000, 999999);

        ParentOtpCode::where('email', $validated['email'])->delete();

        ParentOtpCode::create([
            'email' => $validated['email'],
            'code' => $code,
            'expires_at' => now()->addMinutes(15),
        ]);

        $lang = Trilingual::lang($request);
        $payload = [
            'message' => Trilingual::pick(
                $lang,
                'A 6-digit verification code has been sent.',
                'تم إرسال رمز التحقق المكوّن من 6 أرقام.',
                'Un code de verification a 6 chiffres a ete envoye.'
            ),
        ];

        if (app()->environment(['local', 'testing'])) {
            $payload['demo_otp'] = $code;
        }

        return response()->json($payload);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'code' => ['required', 'string', 'size:6'],
        ]);

        $record = ParentOtpCode::where('email', $validated['email'])
            ->where('expires_at', '>', now())
            ->latest('id')
            ->first();

        $isLocalMagic = app()->environment(['local', 'testing']) && $validated['code'] === '482910';

        if (! $record || ($record->code !== $validated['code'] && ! $isLocalMagic)) {
            $lang = Trilingual::lang($request);
            return response()->json([
                'message' => Trilingual::pick(
                    $lang,
                    'Invalid or expired verification code.',
                    'رمز التحقق غير صحيح أو منتهي الصلاحية.',
                    'Code de verification invalide ou expire.'
                ),
            ], 422);
        }

        $resetToken = Str::random(48);
        $record->update([
            'reset_token' => $resetToken,
            'verified_at' => now(),
        ]);

        return response()->json([
            'verified' => true,
            'reset_token' => $resetToken,
        ]);
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email', 'exists:users,email'],
            'reset_token' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $record = ParentOtpCode::where('email', $validated['email'])
            ->where('reset_token', $validated['reset_token'])
            ->whereNotNull('verified_at')
            ->first();

        if (! $record) {
            return response()->json(['message' => 'Invalid reset session.'], 422);
        }

        $user = User::where('email', $validated['email'])->firstOrFail();
        $user->update(['password' => $validated['password']]);
        $user->tokens()->delete();
        $record->delete();

        $token = $user->createToken('hanna-parent')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json($request->user());
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['message' => 'Logged out.']);
    }

    public function deleteAccount(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'confirmation' => ['required', 'string'],
        ]);

        if (! in_array(trim($validated['confirmation']), ['DELETE', 'حذف', 'SUPPRIMER'], true)) {
            return response()->json([
                'message' => Trilingual::pick(
                    Trilingual::lang($request),
                    'Please type DELETE to confirm.',
                    'يرجى كتابة كلمة حذف للتأكيد.',
                    'Veuillez saisir SUPPRIMER ou DELETE pour confirmer.'
                ),
            ], 422);
        }

        $user = $request->user();
        $user->tokens()->delete();
        $user->delete();

        return response()->json(['deleted' => true]);
    }
}

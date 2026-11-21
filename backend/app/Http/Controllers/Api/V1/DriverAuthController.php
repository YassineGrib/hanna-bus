<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\Trilingual;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class DriverAuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $v = $request->validate(['email' => ['required', 'email'], 'password' => ['required', 'string']]);
        $user = User::where('email', $v['email'])->first();
        if (! $user || ! Hash::check($v['password'], $user->password)) {
            return response()->json(['message' => Trilingual::pick(Trilingual::lang($request), 'Invalid email or password.', 'البريد الإلكتروني أو كلمة المرور غير صحيحة.', 'E-mail ou mot de passe invalide.')], 401);
        }
        if ($user->role !== 'driver') {
            return response()->json(['message' => Trilingual::pick(Trilingual::lang($request), 'Access denied.', 'الوصول مرفوض.', 'Accès refusé.')], 403);
        }

        return response()->json(['token' => $user->createToken('hanna-driver')->plainTextToken, 'user' => $user]);
    }
}

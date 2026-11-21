<?php

use App\Http\Controllers\Api\V1\AttendanceController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BulletinSupportController;
use App\Http\Controllers\Api\V1\ChildController;
use App\Http\Controllers\Api\V1\DriverAuthController;
use App\Http\Controllers\Api\V1\DriverBoardingController;
use App\Http\Controllers\Api\V1\DriverFleetController;
use App\Http\Controllers\Api\V1\DriverHistoryController;
use App\Http\Controllers\Api\V1\DriverMessageController;
use App\Http\Controllers\Api\V1\DriverSosController;
use App\Http\Controllers\Api\V1\DriverTripController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\SettingsController;
use App\Http\Controllers\Api\V1\TrackingController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'status' => 'operational',
        'service' => 'Hanna Bus Parent API',
        'version' => '1.0.0',
    ]);
});

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

Route::middleware(['auth:sanctum', 'role:parent'])->prefix('parent')->group(function () {
    Route::delete('/account', [AuthController::class, 'deleteAccount']);

    Route::get('/profile', [SettingsController::class, 'getProfile']);
    Route::put('/profile', [SettingsController::class, 'updateProfile']);
    Route::put('/settings/preferences', [SettingsController::class, 'updatePreferences']);
    Route::get('/settings/alerts', [SettingsController::class, 'getAlerts']);
    Route::put('/settings/alerts', [SettingsController::class, 'updateAlerts']);
    Route::get('/emergency-contacts', [SettingsController::class, 'emergencyContacts']);

    Route::post('/children/link', [ChildController::class, 'link']);
    Route::apiResource('children', ChildController::class);

    Route::get('/attendance/absences', [AttendanceController::class, 'index']);
    Route::post('/attendance/absences', [AttendanceController::class, 'store']);
    Route::delete('/attendance/absences/{childId}/today', [AttendanceController::class, 'destroyToday']);
    Route::get('/attendance/analytics', [AttendanceController::class, 'analytics']);

    Route::get('/tracking/active-trip', [TrackingController::class, 'getActiveTrip']);
    Route::get('/tracking/history', [TrackingController::class, 'history']);
    Route::get('/tracking/trips/{id}', [TrackingController::class, 'showTrip']);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);

    Route::get('/bulletins', [BulletinSupportController::class, 'bulletins']);
    Route::post('/support/messages', [BulletinSupportController::class, 'storeMessage']);
    Route::get('/support/messages', [BulletinSupportController::class, 'messages']);
});

Route::post('/driver/auth/login', [DriverAuthController::class, 'login']);
Route::middleware(['auth:sanctum', 'role:driver'])->prefix('driver')->group(function () {
    Route::get('/profile', [DriverFleetController::class, 'profile']);
    Route::get('/buses', [DriverFleetController::class, 'buses']);
    Route::get('/rotation', [DriverFleetController::class, 'rotation']);
    Route::put('/bus', [DriverFleetController::class, 'updateBus']);
    Route::post('/inspections', [DriverFleetController::class, 'inspection']);
    Route::get('/trips/today', [DriverTripController::class, 'today']);
    Route::post('/trips/{trip}/start', [DriverTripController::class, 'start']);
    Route::post('/trips/{trip}/location', [DriverTripController::class, 'location'])->middleware('throttle:driver-location');
    Route::post('/trips/{trip}/stations/{station}/arrive', [DriverTripController::class, 'arrive']);
    Route::post('/trips/{trip}/delay', [DriverTripController::class, 'delay']);
    Route::post('/trips/{trip}/end', [DriverTripController::class, 'end']);
    Route::get('/trips/{trip}/students', [DriverBoardingController::class, 'students']);
    Route::post('/trips/{trip}/boarding', [DriverBoardingController::class, 'store']);
    Route::get('/messages', [DriverMessageController::class, 'index']);
    Route::get('/messages/{parent}', [DriverMessageController::class, 'show']);
    Route::post('/messages/{parent}', [DriverMessageController::class, 'store']);
    Route::get('/history', [DriverHistoryController::class, 'history']);
    Route::get('/stats', [DriverHistoryController::class, 'stats']);
    Route::post('/sos', [DriverSosController::class, 'store']);
});

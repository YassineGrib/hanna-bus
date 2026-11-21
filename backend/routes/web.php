<?php

use App\Http\Controllers\AdminLocaleController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::post('/admin/locale', AdminLocaleController::class)
    ->middleware('auth')->name('admin.locale');

<?php

use App\Http\Controllers\Api\LapanganController;
use App\Http\Controllers\Api\PemesananController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::apiResource('users', UserController::class);
Route::apiResource('lapangans', LapanganController::class);
Route::apiResource('pemesanans', PemesananController::class);

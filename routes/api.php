<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BarangController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\PenjualanController;
use App\Http\Controllers\Api\DashboardController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::post('/auth/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Dashboard & Alerts
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/dashboard/alerts', [DashboardController::class, 'alerts']);

    // Categories
    Route::get('/categories', [CategoryController::class, 'index']);

    // Barang (Products)
    Route::get('/barangs/search/{kode}', [BarangController::class, 'searchByBarcode']);
    Route::apiResource('barangs', BarangController::class);

    // Penjualan (Sales)
    Route::get('/penjualans', [PenjualanController::class, 'index']);
    Route::post('/penjualans', [PenjualanController::class, 'store']);
    Route::get('/penjualans/{id}', [PenjualanController::class, 'show']);
});

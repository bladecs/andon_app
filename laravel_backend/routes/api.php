<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\FirebaseController; // Pastikan ini di-import

// Route untuk menambah Andon Event baru
Route::post('/andon-events', [FirebaseController::class, 'addAndonEvent']);

// Route untuk mengatur status aplikasi
Route::post('/app-status', [FirebaseController::class, 'setAppStatus']);

// Route untuk update Andon Event tertentu
Route::patch('/andon-events/{key}', [FirebaseController::class, 'updateAndonStatus']);

// Route untuk menghapus Andon Event
Route::delete('/andon-events/{key}', [FirebaseController::class, 'deleteAndonEvent']);


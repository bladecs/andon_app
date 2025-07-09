<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Auth;
use Kreait\Firebase\Firestore;
use Kreait\Firebase\Storage;
use Kreait\Firebase\Database; // Untuk Realtime Database

class FirebaseServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(Factory::class, function ($app) {
            $credentialsPath = config('firebase.projects.app.credentials.file');
            $databaseUrl = config('firebase.projects.app.database.url');

            return (new Factory)
                ->withServiceAccount($credentialsPath)
                ->withDatabaseUri($databaseUrl); // Jika menggunakan Realtime Database
        });

        $this->app->singleton(Auth::class, function ($app) {
            return $app->make(Factory::class)->createAuth();
        });

        $this->app->singleton(Firestore::class, function ($app) {
            return $app->make(Factory::class)->createFirestore();
        });

        $this->app->singleton(Storage::class, function ($app) {
            return $app->make(Factory::class)->createStorage();
        });

        $this->app->singleton(Database::class, function ($app) {
            return $app->make(Factory::class)->createDatabase();
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}

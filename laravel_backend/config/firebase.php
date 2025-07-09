<?php

return [
    'projects' => [
        'app' => [
            'credentials' => [
                'file' => env('FIREBASE_CREDENTIALS_FILE', storage_path('app/firebase/service-account.json')),
            ],
            'database' => [
                'url' => env('FIREBASE_DATABASE_URL', 'https://andonapi-default-rtdb.asia-southeast1.firebasedatabase.app'),
            ],
        ],
    ],
];

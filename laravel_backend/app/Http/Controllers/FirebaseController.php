<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Kreait\Firebase\Database;
use Exception;
use Illuminate\Support\Facades\Validator;

class FirebaseController extends Controller
{
    protected $database;

    public function __construct(Database $database)
    {
        $this->database = $database;
    }

    /**
     * Menambahkan event Andon baru (menggunakan push untuk kunci unik).
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function addAndonEvent(Request $request)
    {
        $data = $request->all();

        // Jika data adalah array asosiatif tunggal, bungkus ke dalam array
        if (isset($data['machine_id']) && isset($data['status'])) {
            $data = [$data];
        }

        // Validasi setiap item dalam array
        foreach ($data as $item) {
            $validator = Validator::make($item, [
                'machine_id' => 'required|string|max:50',
                'status' => 'required|string|in:RUNNING,STOPPED,ALERT',
                'issue' => 'nullable|string|max:255',
            ]);
            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validasi gagal pada salah satu item.',
                    'errors' => $validator->errors(),
                ], 422);
            }
        }

        try {
            $results = [];
            foreach ($data as $item) {
                $eventData = [
                    'machine_id' => $item['machine_id'],
                    'status' => $item['status'],
                    'timestamp' => \Carbon\Carbon::now()->format('d/m/Y'),
                    'issue' => $item['issue'] ?? null,
                ];
                $newPostRef = $this->database->getReference('andonEvents')->push($eventData);
                $results[] = [
                    'key' => $newPostRef->getKey(),
                    'data' => $newPostRef->getValue(),
                    'path' => $newPostRef->getPath(),
                ];
            }

            return response()->json([
                'message' => 'Andon event(s) berhasil ditambahkan!',
                'results' => $results,
            ], 201);

        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menambahkan Andon event.',
                'error_detail' => $e->getMessage(),
            ], 500);
        }
    }
}

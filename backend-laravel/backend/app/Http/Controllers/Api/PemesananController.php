<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Pemesanan;

class PemesananController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return response()->json(Pemesanan::all());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'lapangan_id' => 'required|exists:lapangans,id',
            'tanggal' => 'required|date',
            'jam_mulai' => 'required',
            'jam_selesai' => 'required',
            'status' => 'in:pending,confirmed,cancelled',
            'bukti_tf' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);
        $exists = \App\Models\Pemesanan::where('lapangan_id', $validated['lapangan_id'])
            ->where('tanggal', $validated['tanggal'])
            ->where('status', 'confirmed')
            ->where(function($q) use ($validated) {
                $q->whereBetween('jam_mulai', [$validated['jam_mulai'], $validated['jam_selesai']])
                  ->orWhereBetween('jam_selesai', [$validated['jam_mulai'], $validated['jam_selesai']])
                  ->orWhere(function($q2) use ($validated) {
                      $q2->where('jam_mulai', '<', $validated['jam_mulai'])
                         ->where('jam_selesai', '>', $validated['jam_selesai']);
                  });
            })->exists();
        if ($exists) {
            return response()->json(['message' => 'Lapangan sudah terbooking silahkan pilih jam lain'], 422);
        }
        $lapangan = \App\Models\Lapangan::findOrFail($validated['lapangan_id']);
        $validated['harga'] = $lapangan->harga;
        $start = strtotime($validated['jam_mulai']);
        $end = strtotime($validated['jam_selesai']);
        $durasi = ($end - $start) / 3600;
        $validated['total_harga'] = $lapangan->harga * $durasi;
        if ($request->hasFile('bukti_tf')) {
            $file = $request->file('bukti_tf');
            $filename = time().'_'.$file->getClientOriginalName();
            $file->move(public_path('uploads/bukti_tf'), $filename);
            $validated['bukti_tf'] = 'uploads/bukti_tf/'.$filename;
        }
        $pemesanan = \App\Models\Pemesanan::create($validated);
        return response()->json($pemesanan, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $pemesanan = Pemesanan::findOrFail($id);
        return response()->json($pemesanan);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $pemesanan = \App\Models\Pemesanan::findOrFail($id);
        $validated = $request->validate([
            'user_id' => 'sometimes|exists:users,id',
            'lapangan_id' => 'sometimes|exists:lapangans,id',
            'tanggal' => 'sometimes|date',
            'jam_mulai' => 'sometimes',
            'jam_selesai' => 'sometimes',
            'status' => 'sometimes|in:pending,confirmed,cancelled',
            'bukti_tf' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);
        $lapangan_id = $validated['lapangan_id'] ?? $pemesanan->lapangan_id;
        $tanggal = $validated['tanggal'] ?? $pemesanan->tanggal;
        $jam_mulai = $validated['jam_mulai'] ?? $pemesanan->jam_mulai;
        $jam_selesai = $validated['jam_selesai'] ?? $pemesanan->jam_selesai;
        $exists = \App\Models\Pemesanan::where('lapangan_id', $lapangan_id)
            ->where('tanggal', $tanggal)
            ->where('status', 'confirmed')
            ->where('id', '!=', $id)
            ->where(function($q) use ($jam_mulai, $jam_selesai) {
                $q->whereBetween('jam_mulai', [$jam_mulai, $jam_selesai])
                  ->orWhereBetween('jam_selesai', [$jam_mulai, $jam_selesai])
                  ->orWhere(function($q2) use ($jam_mulai, $jam_selesai) {
                      $q2->where('jam_mulai', '<', $jam_mulai)
                         ->where('jam_selesai', '>', $jam_selesai);
                  });
            })->exists();
        if ($exists) {
            return response()->json(['message' => 'Lapangan sudah terbooking silahkan pilih jam lain'], 422);
        }
        $lapangan = \App\Models\Lapangan::findOrFail($lapangan_id);
        $validated['harga'] = $lapangan->harga;
        $start = strtotime($jam_mulai);
        $end = strtotime($jam_selesai);
        $durasi = ($end - $start) / 3600;
        $validated['total_harga'] = $lapangan->harga * $durasi;
        if ($request->hasFile('bukti_tf')) {
            $file = $request->file('bukti_tf');
            $filename = time().'_'.$file->getClientOriginalName();
            $file->move(public_path('uploads/bukti_tf'), $filename);
            $validated['bukti_tf'] = 'uploads/bukti_tf/'.$filename;
        }
        $pemesanan->update($validated);
        return response()->json($pemesanan);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $pemesanan = Pemesanan::findOrFail($id);
        $pemesanan->delete();
        return response()->json(['message' => 'Pemesanan deleted']);
    }

    /**
     * Check availability of the resource.
     */
    public function cekKetersediaan(Request $request)
    {
        $ada = \App\Models\Pemesanan::where('lapangan_id', $request->lapangan_id)
            ->where('tanggal', $request->tanggal)
            ->where(function($q) use ($request) {
                $q->where('jam_mulai', '<', $request->jam_selesai)
                  ->where('jam_selesai', '>', $request->jam_mulai);
            })
            ->exists();

        return response()->json(['tersedia' => !$ada]);
    }

    /**
     * Display a listing of the user's transaction history.
     */
    public function riwayatTransaksi(Request $request)
    {
        $user = $request->user();
        $transaksi = \App\Models\Pemesanan::where('user_id', $user->id)->get();

        return response()->json($transaksi);
    }
}

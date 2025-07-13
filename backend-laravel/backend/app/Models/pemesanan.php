<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pemesanan extends Model
{
    protected $table = 'pemesanans';
    protected $fillable = [
        'user_id', 'lapangan_id', 'tanggal', 'jam_mulai', 'jam_selesai', 'status', 'harga', 'total_harga', 'bukti_tf'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function lapangan()
    {
        return $this->belongsTo(Lapangan::class);
    }
}

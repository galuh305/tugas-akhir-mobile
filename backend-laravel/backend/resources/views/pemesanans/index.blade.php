@extends('layouts.app')
@section('content')
<div class="container">
    <h1>Daftar Pemesanan</h1>
    <a href="{{ route('pemesanans.create') }}" class="btn btn-primary mb-2">Tambah Pemesanan</a>
    <table class="table table-bordered">
        <thead>
            <tr>
                <th>ID</th>
                <th>User</th>
                <th>Lapangan</th>
                <th>Tanggal</th>
                <th>Jam Mulai</th>
                <th>Jam Selesai</th>
                <th>Status</th>
                <th>Harga</th>
                <th>Total Harga</th>
                <th>Aksi</th>
            </tr>
        </thead>
        <tbody>
            @foreach($pemesanans as $pemesanan)
            <tr>
                <td>{{ $pemesanan->id }}</td>
                <td>{{ $pemesanan->user->name ?? '-' }}</td>
                <td>{{ $pemesanan->lapangan->nama ?? '-' }}</td>
                <td>{{ $pemesanan->tanggal }}</td>
                <td>{{ $pemesanan->jam_mulai }}</td>
                <td>{{ $pemesanan->jam_selesai }}</td>
                <td>{{ $pemesanan->status }}</td>
                <td>{{ $pemesanan->harga ? 'Rp. ' . number_format($pemesanan->harga, 0, ',', '.') : '-' }}</td>
                <td>{{ $pemesanan->total_harga ? 'Rp. ' . number_format($pemesanan->total_harga, 0, ',', '.') : '-' }}</td>
                <td>
                    <a href="{{ route('pemesanans.show', $pemesanan->id) }}" class="btn btn-info btn-sm">Detail</a>
                    <a href="{{ route('pemesanans.edit', $pemesanan->id) }}" class="btn btn-warning btn-sm">Edit</a>
                    <form action="{{ route('pemesanans.destroy', $pemesanan->id) }}" method="POST" style="display:inline-block">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Yakin hapus?')">Hapus</button>
                    </form>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection

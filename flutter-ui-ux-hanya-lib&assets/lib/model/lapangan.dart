class Lapangan {
  final int id;
  final String nama;
  final String gambar;
  final String deskripsi;
  final int harga;

  Lapangan({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.deskripsi,
    required this.harga,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    return Lapangan(
      id: json['id'] as int,
      nama: json['nama'] as String,
      gambar: json['gambar'] as String,
      deskripsi: json['deskripsi'] as String,
      harga: json['harga'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'gambar': gambar,
      'deskripsi': deskripsi,
      'harga': harga,
    };
  }
}

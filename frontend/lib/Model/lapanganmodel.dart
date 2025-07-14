class Lapangan {
  final int id;
  final String nama;
  final String jenis;
  final String tipe;
  final int harga;
  final int aktif;

  const Lapangan({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.tipe,
    required this.harga,
    required this.aktif,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    return Lapangan(
      id: json['id'],
      nama: json['nama'],
      jenis: json['jenis'],
      tipe: json['tipe'],
      harga: json['harga'],
      aktif: json['aktif'],
    );
  }
}

class Booking {
  final int id;
  final int userId;
  final int lapanganId;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String status;
  final int? harga;
  final int? totalHarga;
  final String? buktiTf;
  final String? createdAt;
  final String? updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.lapanganId,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.status,
    this.harga,
    this.totalHarga,
    this.buktiTf,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      lapanganId: json['lapangan_id'],
      tanggal: json['tanggal'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      status: json['status'],
      harga: json['harga'],
      totalHarga: json['total_harga'],
      buktiTf: json['bukti_tf'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
} 
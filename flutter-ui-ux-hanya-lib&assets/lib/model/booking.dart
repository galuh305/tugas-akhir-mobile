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

  /// Dari JSON (API)
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      lapanganId: json['lapangan_id'] as int,
      tanggal: json['tanggal'] as String,
      jamMulai: json['jam_mulai'] as String,
      jamSelesai: json['jam_selesai'] as String,
      status: json['status'] as String,
      harga: json['harga'] as int?,
      totalHarga: json['total_harga'] as int?,
      buktiTf: json['bukti_tf'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Ke JSON (untuk simpan / kirim ke server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lapangan_id': lapanganId,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'status': status,
      'harga': harga,
      'total_harga': totalHarga,
      'bukti_tf': buktiTf,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

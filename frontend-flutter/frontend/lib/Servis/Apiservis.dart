import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/lapanganmodel.dart';
import '../Model/bookingmodel.dart';

Future<List<Lapangan>> fetchLapangan() async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/lapangans'));
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    return data.map((e) => Lapangan.fromJson(e)).toList();
  } else {
    throw Exception('Gagal memuat data');
  }
}

Future<bool> createBooking(Booking booking) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/api/bookings'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'user_id': booking.userId,
      'lapangan_id': booking.lapanganId,
      'tanggal': booking.tanggal,
      'jam_mulai': booking.jamMulai,
      'jam_selesai': booking.jamSelesai,
      'status': booking.status,
      'harga': booking.harga,
      'total_harga': booking.totalHarga,
      'bukti_tf': booking.buktiTf,
    }),
  );
  return response.statusCode == 201;
}

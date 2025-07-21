import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/lapanganmodel.dart';
import '../Model/bookingmodel.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://192.168.100.36/tugas-akhir-mobile/backend-laravel/backend/public/api'; // untuk emulator

Future<List<Booking>> fetchRiwayatTransaksiUser2() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.get(
    Uri.parse('$baseUrl/riwayat-transaksi'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    // Ambil 2 transaksi terakhir
    data = data.reversed.take(2).toList();
    return data.map((e) => Booking.fromJson(e)).toList();
  } else {
    throw Exception('Gagal memuat riwayat transaksi');
  }
}

Future<List<Booking>> fetchRiwayatTransaksiUser() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.get(
    Uri.parse('$baseUrl/riwayat-transaksi'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    // Kembalikan semua data transaksi user
    return data.map((e) => Booking.fromJson(e)).toList();
  } else {
    throw Exception('Gagal memuat riwayat transaksi');
  }
}

Future<List<Lapangan>> fetchLapangan() async {
  final response = await http.get(Uri.parse('$baseUrl/lapangans'));
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    return data.map((e) => Lapangan.fromJson(e)).toList();
  } else {
    throw Exception('Gagal memuat data');
  }
}

Future<int?> createBooking(Booking booking) async {
  try {
    var uri = Uri.parse('$baseUrl/pemesanans');
    var request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = booking.userId.toString();
    request.fields['lapangan_id'] = booking.lapanganId.toString();
    request.fields['tanggal'] = booking.tanggal;
    request.fields['jam_mulai'] = booking.jamMulai;
    request.fields['jam_selesai'] = booking.jamSelesai;
    request.fields['status'] = booking.status;
    request.fields['harga'] = booking.harga.toString();
    request.fields['total_harga'] = booking.totalHarga.toString();
    request.fields['bukti_tf'] = '';

    var response = await request.send();
    print('Status:  [33m${response.statusCode} [0m');
    final respStr = await response.stream.bytesToString();
    print('Body:  [36m$respStr [0m');
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = json.decode(respStr);
        if (data is Map && data['id'] != null) {
          return data['id'] is int ? data['id'] : int.tryParse(data['id'].toString());
        }
        if (data is List && data.isNotEmpty && data[0]['id'] != null) {
          return data[0]['id'] is int ? data[0]['id'] : int.tryParse(data[0]['id'].toString());
        }
      } catch (e) {
        print('Gagal parsing id booking: $e');
      }
    } else {
      print('Booking gagal dengan status:  [31m${response.statusCode} [0m');
      print('Response error: $respStr');
    }
  } catch (e, stack) {
    print('Terjadi error saat createBooking: $e');
    print('Stacktrace: $stack');
  }
  return null;
}

Future<bool> updateBuktiTf(int bookingId, dynamic file) async {
  final url = '$baseUrl/pemesanans/$bookingId';
  final dio = Dio();
  FormData formData;
  if (kIsWeb) {
    // Untuk web, file adalah XFile dari image_picker
    formData = FormData.fromMap({
      '_method': 'PUT',
      'bukti_tf': await MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: file.name,
      ),
    });
  } else {
    // Untuk mobile/desktop, file adalah File
    formData = FormData.fromMap({
      '_method': 'PUT',
      'bukti_tf': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });
  }
  try {
    final response = await dio.post(url, data: formData);
    print('Status: ${response.statusCode}');
    print('Body: ${response.data}');
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print('Error upload: $e');
    return false;
  }
}

Future<List<Booking>> fetchBookingUser(int userId) async {
  final response = await http.get(Uri.parse('$baseUrl/pemesanans/user/$userId'));
  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    return data.map((e) => Booking.fromJson(e)).toList();
  } else {
    throw Exception('Gagal memuat riwayat booking');
  }
}

Future<Map<String, dynamic>> updateProfileWithError(int userId, String name) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.put(
    Uri.parse('$baseUrl/users/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({'name': name}),
  );
  print('Update profile status: ${response.statusCode}');
  print('Body: ${response.body}');
  if (response.statusCode == 200 || response.statusCode == 202) {
    return {'success': true};
  } else {
    String? msg;
    try {
      // Cek apakah response JSON
      final data = json.decode(response.body);
      msg = data['message'] ?? response.body;
    } catch (e) {
      // Jika bukan JSON, tampilkan langsung
      msg = response.body;
    }
    return {'success': false, 'message': msg};
  }
}

Future<Map<String, dynamic>> changePasswordWithError(String oldPassword, String newPassword, String confirmPassword) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.put(
    Uri.parse('$baseUrl/password'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
    }),
  );
  print('Change password status: ${response.statusCode}');
  print('Body: ${response.body}');
  if (response.statusCode == 200 || response.statusCode == 202) {
    return {'success': true};
  } else {
    String? msg;
    try {
      final data = json.decode(response.body);
      msg = data['message'] ?? response.body;
    } catch (e) {
      msg = response.body;
    }
    return {'success': false, 'message': msg};
  }
}

Future<bool> cekKetersediaanLapangan(int lapanganId, String tanggal, String jamMulai, String jamSelesai) async {
  final url = '$baseUrl/cek-ketersediaan?lapangan_id=$lapanganId&tanggal=$tanggal&jam_mulai=$jamMulai&jam_selesai=$jamSelesai';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Asumsi response: {"tersedia": true/false}
      return data['tersedia'] == true;
    }
  } catch (e) {
    print('Error cek ketersediaan: $e');
  }
  return false;
}

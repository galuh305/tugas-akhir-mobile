import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/lapanganmodel.dart';
import '../Model/bookingmodel.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';

Future<List<Lapangan>> fetchLapangan() async {
  final response = await http.get(Uri.parse('http://10.152.133.163:8000/api/lapangans'));
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
    var uri = Uri.parse('http://10.152.133.163:8000/api/pemesanans');
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
  final url = 'http://10.152.133.163:8000/api/pemesanans/$bookingId';
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

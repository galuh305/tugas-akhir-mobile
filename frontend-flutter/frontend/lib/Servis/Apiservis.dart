import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/lapanganmodel.dart';

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

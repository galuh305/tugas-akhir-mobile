import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/bookingmodel.dart';
import '../Servis/Apiservis.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'payment_screen.dart';
import 'payment_qr_screen.dart';

class BookingScreen extends StatefulWidget {
  final int lapanganId;
  final int harga;
  const BookingScreen({Key? key, required this.lapanganId, required this.harga}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _tanggal;
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;
  bool _loading = false;
  int? userId;
  File? _buktiTfFile;

  int get _totalHarga {
    if (_jamMulai == null || _jamSelesai == null) return widget.harga;
    final mulai = _jamMulai!;
    final selesai = _jamSelesai!;
    int durasi = (selesai.hour * 60 + selesai.minute) - (mulai.hour * 60 + mulai.minute);
    if (durasi <= 0) durasi = 60; // minimal 1 jam
    final jam = (durasi / 60).ceil();
    return widget.harga * jam;
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      setState(() {
        userId = json.decode(userStr)['id'];
      });
    }
  }

  Future<void> _pickBuktiTf() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _buktiTfFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _tanggal == null || _jamMulai == null || _jamSelesai == null) return;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User belum login!')));
      return;
    }
    setState(() => _loading = true);
    final booking = Booking(
      id: 0,
      userId: userId!,
      lapanganId: widget.lapanganId,
      tanggal: DateFormat('yyyy-MM-dd').format(_tanggal!),
      jamMulai: _formatTimeOfDay(_jamMulai!),
      jamSelesai: _formatTimeOfDay(_jamSelesai!),
      status: 'pending',
      harga: widget.harga,
      totalHarga: _totalHarga,
      buktiTf: null,
      createdAt: null,
      updatedAt: null,
    );
    final bookingId = await createBooking(booking);
    print('Booking ID: $bookingId');
    setState(() => _loading = false);
    if (bookingId != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking berhasil! Silakan lakukan pembayaran.')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentQRScreen(
            totalHarga: _totalHarga,
            bookingId: bookingId,
          ),
        ),
      );
    } else {
      print('Booking gagal, cek response backend!');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking gagal!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Lapangan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(_tanggal == null ? 'Pilih Tanggal' : DateFormat('dd MMM yyyy').format(_tanggal!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _tanggal = picked);
                },
              ),
              ListTile(
                title: Text(_jamMulai == null ? 'Pilih Jam Mulai' : _jamMulai!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _jamMulai = picked);
                },
              ),
              ListTile(
                title: Text(_jamSelesai == null ? 'Pilih Jam Selesai' : _jamSelesai!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _jamSelesai = picked);
                },
              ),
              SizedBox(height: 16),
              Text('Harga: Rp${widget.harga}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Total Harga: Rp$_totalHarga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatTimeOfDay(TimeOfDay tod) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  return DateFormat('HH:mm:ss').format(dt);
} 
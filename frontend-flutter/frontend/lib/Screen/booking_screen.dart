import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/bookingmodel.dart';
import '../Servis/Apiservis.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'payment_qr_screen.dart';
import 'homescreen.dart';
import 'dart:ui';

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
  bool? _tersedia;
  bool _checking = false;

  int get _durasiBooking {
    if (_jamMulai == null || _jamSelesai == null) return 1;
    final mulai = _jamMulai!;
    final selesai = _jamSelesai!;
    int durasi = (selesai.hour * 60 + selesai.minute) - (mulai.hour * 60 + mulai.minute);
    if (durasi <= 0) durasi = 60; // minimal 1 jam
    return (durasi / 60).ceil();
  }

  int get _totalHarga {
    int jam = _durasiBooking;
    int total = widget.harga * jam;
    // Promo: Booking 3 jam gratis 1 jam
    if (jam >= 3) {
      total = widget.harga * 3;
    }
    // Diskon weekend
    if (_tanggal != null && (_tanggal!.weekday == 6 || _tanggal!.weekday == 7)) {
      total = (total * 0.8).round();
    }
    return total;
  }

  TimeOfDay? get _jamSelesaiPromo {
    if (_jamMulai == null || _jamSelesai == null) return _jamSelesai;
    int jam = _durasiBooking;
    if (jam == 3) {
      // Tambah 1 jam gratis
      final mulai = _jamMulai!;
      final selesai = TimeOfDay(hour: mulai.hour + 4, minute: mulai.minute);
      return selesai;
    }
    return _jamSelesai;
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

  Future<void> _cekKetersediaan() async {
    if (_tanggal == null || _jamMulai == null || _jamSelesai == null) return;
    setState(() { _checking = true; });
    final tersedia = await cekKetersediaanLapangan(
      widget.lapanganId,
      DateFormat('yyyy-MM-dd').format(_tanggal!),
      _formatTimeOfDay(_jamMulai!),
      _formatTimeOfDay(_jamSelesai!),
    );
    setState(() {
      _tersedia = tersedia;
      _checking = false;
    });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Lapangan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? (isDark ? Color(0xFF23272A) : Color(0xFF185A9D)),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Card(
                margin: EdgeInsets.all(18),
                elevation: 16,
                color: Theme.of(context).cardColor.withOpacity(isDark ? 0.85 : 0.75),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          icon: Icon(Icons.home, color: isDark ? Colors.white : Color(0xFF185A9D), size: 26),
                          label: Text('Kembali ke Home', style: TextStyle(color: isDark ? Colors.white : Color(0xFF185A9D), fontWeight: FontWeight.bold, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Color(0xFF185A9D) : Colors.white,
                            foregroundColor: isDark ? Colors.white : Color(0xFF185A9D),
                            elevation: 0,
                            side: BorderSide(color: Color(0xFF185A9D)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        SizedBox(height: 18),
                        Text('Form Booking', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Color(0xFF185A9D))),
                        SizedBox(height: 28),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.calendar_today, color: Color(0xFF43CEA2), size: 28),
                          title: Text(_tanggal == null ? 'Pilih Tanggal' : DateFormat('dd MMM yyyy').format(_tanggal!), style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
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
                        Divider(color: isDark ? Colors.white12 : Colors.black12, thickness: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.access_time, color: Color(0xFF43CEA2), size: 28),
                          title: Text(_jamMulai == null ? 'Pilih Jam Mulai' : _jamMulai!.format(context), style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) setState(() => _jamMulai = picked);
                          },
                        ),
                        Divider(color: isDark ? Colors.white12 : Colors.black12, thickness: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.access_time, color: Color(0xFF43CEA2), size: 28),
                          title: Text(_jamSelesai == null ? 'Pilih Jam Selesai' : _jamSelesaiPromo?.format(context) ?? '', style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) setState(() => _jamSelesai = picked);
                          },
                        ),
                        Divider(color: isDark ? Colors.white12 : Colors.black12, thickness: 1),
                        SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          child: _tersedia == null
                            ? SizedBox.shrink()
                            : Container(
                                key: ValueKey(_tersedia),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                                decoration: BoxDecoration(
                                  color: _tersedia == true ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _tersedia == true ? Colors.green : Colors.red, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_tersedia == true ? Icons.check_circle : Icons.cancel, color: _tersedia == true ? Colors.green : Colors.red, size: 24),
                                    SizedBox(width: 10),
                                    Text(_tersedia == true ? 'Lapangan tersedia!' : 'Lapangan sudah dibooking di jam tersebut.',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: _tersedia == true ? Colors.green : Colors.red, fontSize: 16)),
                                  ],
                                ),
                              ),
                        ),
                        ElevatedButton.icon(
                          onPressed: (_tanggal != null && _jamMulai != null && _jamSelesai != null && !_checking)
                            ? _cekKetersediaan : null,
                          icon: Icon(Icons.search, color: Colors.white, size: 24),
                          label: Text(_checking ? 'Mengecek...' : 'Cek Ketersediaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            backgroundColor: _tersedia == true
                              ? Colors.green
                              : Color(0xFF43CEA2),
                            foregroundColor: Colors.white,
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith((states) {
                              if (_tersedia == true) return Colors.green;
                              if (states.contains(MaterialState.disabled)) return Colors.grey.shade700;
                              return Color(0xFF43CEA2);
                            }),
                          ),
                        ),
                        SizedBox(height: 18),
                        Text('Harga: Rp${widget.harga}', style: TextStyle(fontSize: 17, color: isDark ? Colors.white : Colors.black)),
                        if (_durasiBooking >= 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 2),
                            child: Text('Promo: Booking 3 jam gratis 1 jam!', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                        if (_tanggal != null && (_tanggal!.weekday == 6 || _tanggal!.weekday == 7))
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 2),
                            child: Text('Diskon 20% Weekend!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ),
                        SizedBox(height: 8),
                        Text('Total Harga: Rp$_totalHarga', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _loading || _tersedia != true ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF185A9D),
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          child: _loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Booking', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
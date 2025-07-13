import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/bookingmodel.dart';
import '../Servis/Apiservis.dart';

class BookingScreen extends StatefulWidget {
  final int userId;
  final int lapanganId;
  final int harga;
  const BookingScreen({Key? key, required this.userId, required this.lapanganId, required this.harga}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _tanggal;
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _tanggal == null || _jamMulai == null || _jamSelesai == null) return;
    setState(() => _loading = true);
    final booking = Booking(
      id: 0,
      userId: widget.userId,
      lapanganId: widget.lapanganId,
      tanggal: DateFormat('yyyy-MM-dd').format(_tanggal!),
      jamMulai: _jamMulai!.format(context),
      jamSelesai: _jamSelesai!.format(context),
      status: 'pending',
      harga: widget.harga,
      totalHarga: widget.harga, // bisa dikalkulasi sesuai durasi
      buktiTf: null,
      createdAt: null,
      updatedAt: null,
    );
    final success = await createBooking(booking);
    setState(() => _loading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking berhasil!')));
      Navigator.pop(context);
    } else {
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
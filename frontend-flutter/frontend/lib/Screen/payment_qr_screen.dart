import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Servis/Apiservis.dart';
import 'homescreen.dart';

class PaymentQRScreen extends StatefulWidget {
  final int totalHarga;
  final int bookingId;

  PaymentQRScreen({required this.totalHarga, required this.bookingId});

  @override
  State<PaymentQRScreen> createState() => _PaymentQRScreenState();
}

class _PaymentQRScreenState extends State<PaymentQRScreen> {
  XFile? _buktiTfFile;
  bool _loading = false;
  bool _showSuccess = false;

  Future<void> _pickBuktiTf() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _buktiTfFile = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_buktiTfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pilih file bukti transfer terlebih dahulu!')));
      return;
    }
    setState(() => _loading = true);
    final success = await updateBuktiTf(widget.bookingId, _buktiTfFile);
    setState(() => _loading = false);
    if (success) {
      setState(() => _showSuccess = true);
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload gagal!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran DANA & Upload Bukti')),
      body: Center(
        child: _showSuccess
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 120),
                  SizedBox(height: 24),
                  Text('Bukti transfer berhasil diupload!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Scan QR ini dengan aplikasi DANA untuk membayar', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/qr_dana.png',
                      width: 250,
                      height: 250,
                    ),
                    SizedBox(height: 20),
                    Text('Nominal: Rp${widget.totalHarga}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Text('Pastikan nama penerima sesuai dengan akun DANA kamu.', style: TextStyle(fontSize: 14, color: Colors.blue)),
                    SizedBox(height: 32),
                    Text('Upload Bukti Transfer:', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickBuktiTf,
                          icon: Icon(Icons.upload_file),
                          label: Text('Pilih File'),
                        ),
                        SizedBox(width: 12),
                        if (_buktiTfFile != null)
                          Text(_buktiTfFile!.name),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Upload Bukti Transfer'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
} 
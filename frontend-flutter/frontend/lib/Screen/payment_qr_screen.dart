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
      backgroundColor: Color(0xFFE0F7FA),
      appBar: AppBar(
        title: Text('Pembayaran DANA & Upload Bukti', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF185A9D),
        elevation: 0,
      ),
      body: Center(
        child: _showSuccess
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 120),
                          SizedBox(height: 24),
                          Text('Bukti transfer berhasil diupload!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF185A9D))),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Card(
                  margin: EdgeInsets.all(24),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Scan QR ini dengan aplikasi DANA untuk membayar', style: TextStyle(fontSize: 16, color: Color(0xFF185A9D), fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/qr_dana.png',
                            width: 250,
                            height: 250,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Nominal: Rp${widget.totalHarga}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF185A9D))),
                        SizedBox(height: 20),
                        Text('Pastikan nama penerima sesuai dengan akun DANA kamu.', style: TextStyle(fontSize: 14, color: Colors.blue)),
                        SizedBox(height: 32),
                        Text('Upload Bukti Transfer:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF185A9D))),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickBuktiTf,
                              icon: Icon(Icons.upload_file, color: Colors.white),
                              label: Text('Pilih File', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF185A9D),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            SizedBox(width: 12),
                            if (_buktiTfFile != null)
                              Text(_buktiTfFile!.name, style: TextStyle(color: Color(0xFF185A9D), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF185A9D),
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Upload Bukti Transfer', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
} 
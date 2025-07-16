import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../Servis/Apiservis.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  const PaymentScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  dynamic _buktiTfFile; // File (mobile) atau XFile (web)
  bool _loading = false;
  bool _showSuccess = false;

  Future<void> _pickBuktiTf() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _buktiTfFile = picked; // XFile (web) atau File (mobile)
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
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload gagal!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F7FA),
      appBar: AppBar(
        title: Text('Upload Bukti Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF185A9D),
        elevation: 0,
      ),
      body: Center(
        child: _showSuccess
            ? Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 120),
                      SizedBox(height: 24),
                      Text('Bukti transfer berhasil diupload!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF185A9D))),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Card(
                  margin: EdgeInsets.all(24),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Upload Bukti Transfer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF185A9D)), textAlign: TextAlign.center),
                        SizedBox(height: 24),
                        Row(
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
                              Expanded(child: Text(_buktiTfFile!.name, style: TextStyle(color: Color(0xFF185A9D), fontWeight: FontWeight.bold))),
                          ],
                        ),
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF185A9D),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Upload', style: TextStyle(color: Colors.white)),
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
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bukti transfer berhasil diupload!')));
      Navigator.pop(context);
    } else {
      print('Upload bukti transfer gagal, cek response backend!');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload gagal!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Bukti Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Bukti Transfer:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickBuktiTf,
                  icon: Icon(Icons.upload_file),
                  label: Text('Pilih File'),
                ),
                SizedBox(width: 12),
                if (_buktiTfFile != null)
                  Expanded(child: Text(_buktiTfFile!.name)),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
} 
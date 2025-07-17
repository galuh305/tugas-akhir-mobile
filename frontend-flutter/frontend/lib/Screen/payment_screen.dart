import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../Servis/Apiservis.dart';
import 'dart:math';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  const PaymentScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with TickerProviderStateMixin {
  dynamic _buktiTfFile; // File (mobile) atau XFile (web)
  bool _loading = false;
  bool _showSuccess = false;
  double _successAnim = 0.7;
  double _successOpacity = 0.0;
  AnimationController? _checkController;
  Animation<double>? _checkAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1400),
    );
    _checkAnimation = CurvedAnimation(parent: _checkController!, curve: Curves.easeOutExpo);
    _checkController?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _checkController?.dispose();
    super.dispose();
  }

  Future<void> _pickBuktiTf() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _buktiTfFile = picked; // XFile (web) atau File (mobile)
      });
    }
  }

  Future<void> _showSuccessAnim() async {
    setState(() {
      _showSuccess = true;
      _successAnim = 0.7;
      _successOpacity = 0.0;
    });
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _successAnim = 1.0;
      _successOpacity = 1.0;
    });
    _checkController?.reset();
    _checkController?.forward();
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _successAnim = 0.7;
      _successOpacity = 0.0;
    });
    await Future.delayed(Duration(milliseconds: 300));
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
      await _showSuccessAnim();
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
        child: Stack(
          children: [
            if (!_showSuccess)
              SingleChildScrollView(
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
            if (_showSuccess)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _successOpacity,
                    duration: Duration(milliseconds: 300),
                    child: AnimatedScale(
                      scale: _successAnim,
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      child: Card(
                        elevation: 18,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                        child: Container(
                          width: 240,
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.18),
                                blurRadius: 32,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(0.5),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.green.shade100],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: CheckPainter(_checkAnimation?.value ?? 0),
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Bukti transfer berhasil diupload!',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 4)]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CheckPainter extends CustomPainter {
  final double progress;
  CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final start = Offset(w * 0.22, h * 0.55);
    final mid = Offset(w * 0.45, h * 0.75);
    final end = Offset(w * 0.78, h * 0.32);

    if (progress < 0.5) {
      final t = progress / 0.5;
      final current = Offset.lerp(start, mid, t)!;
      path.moveTo(start.dx, start.dy);
      path.lineTo(current.dx, current.dy);
    } else {
      path.moveTo(start.dx, start.dy);
      path.lineTo(mid.dx, mid.dy);
      final t = (progress - 0.5) / 0.5;
      final current = Offset.lerp(mid, end, t)!;
      path.lineTo(current.dx, current.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckPainter oldDelegate) => oldDelegate.progress != progress;
} 
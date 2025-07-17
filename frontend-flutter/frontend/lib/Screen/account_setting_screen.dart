import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Servis/Apiservis.dart';
import 'dart:convert';
import 'dart:math';

class AccountSettingScreen extends StatefulWidget {
  @override
  _AccountSettingScreenState createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> with TickerProviderStateMixin {
  String? email;
  String? name;
  final _formKeyNama = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confPassController = TextEditingController();
  String? _msgNama;
  String? _msgPass;
  bool _showSuccessNama = false;
  bool _showSuccessPass = false;
  double _successAnim = 0.7;
  double _successOpacity = 0.0;
  AnimationController? _checkController;
  Animation<double>? _checkAnimation;

  @override
  void initState() {
    super.initState();
    _loadUser();
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

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final user = userStr.contains('{') ? userStr : '{}';
      setState(() {
        email = RegExp('"email":"([^"]+)"').firstMatch(user)?.group(1) ?? '';
        name = RegExp('"name":"([^"]+)"').firstMatch(user)?.group(1) ?? '';
        _namaController.text = name ?? '';
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _showSuccess(bool isNama) async {
    setState(() {
      if (isNama) _showSuccessNama = true; else _showSuccessPass = true;
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
    setState(() {
      if (isNama) _showSuccessNama = false; else _showSuccessPass = false;
    });
  }

  Future<void> _updateNama() async {
    if (!_formKeyNama.currentState!.validate()) return;
    setState(() { _msgNama = null; });
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    int? userId;
    if (userStr != null) {
      userId = json.decode(userStr)['id'];
    }
    if (userId == null) {
      setState(() { _msgNama = 'User tidak ditemukan!'; });
      return;
    }
    final result = await updateProfileWithError(userId, _namaController.text);
    if (result['success']) {
      setState(() {
        name = _namaController.text;
        _msgNama = 'Nama berhasil diubah.';
      });
      if (userStr != null) {
        final updated = userStr.replaceAll(RegExp('"name":"([^"]*)"'), '"name":"${_namaController.text}"');
        await prefs.setString('user', updated);
      }
      _showSuccess(true);
    } else {
      setState(() { _msgNama = result['message'] ?? 'Gagal mengubah nama!'; });
    }
  }

  Future<void> _gantiPassword() async {
    if (!_formKeyPassword.currentState!.validate()) return;
    setState(() { _msgPass = null; });
    final result = await changePasswordWithError(
      _oldPassController.text,
      _newPassController.text,
      _confPassController.text,
    );
    if (result['success']) {
      setState(() {
        _msgPass = 'Password berhasil diganti.';
        _oldPassController.clear();
        _newPassController.clear();
        _confPassController.clear();
      });
      _showSuccess(false);
    } else {
      setState(() { _msgPass = result['message'] ?? 'Gagal mengganti password!'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Pengaturan Akun'),
            backgroundColor: Color(0xFF185A9D),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF185A9D)),
                  title: Text(name ?? 'Nama tidak tersedia'),
                  subtitle: Text(email ?? 'Email tidak tersedia'),
                ),
                SizedBox(height: 24),
                Text('Edit Nama', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF185A9D))),
                Form(
                  key: _formKeyNama,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _namaController,
                          decoration: InputDecoration(hintText: 'Nama baru'),
                          validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _updateNama,
                        child: Text('Simpan'),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF185A9D)),
                      ),
                    ],
                  ),
                ),
                if (_msgNama != null) ...[
                  SizedBox(height: 6),
                  Text(_msgNama!, style: TextStyle(color: Colors.green)),
                ],
                SizedBox(height: 32),
                Text('Ganti Password', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF185A9D))),
                Form(
                  key: _formKeyPassword,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _oldPassController,
                        decoration: InputDecoration(hintText: 'Password lama'),
                        obscureText: true,
                        validator: (v) => v == null || v.isEmpty ? 'Password lama wajib diisi' : null,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _newPassController,
                        decoration: InputDecoration(hintText: 'Password baru'),
                        obscureText: true,
                        validator: (v) => v == null || v.length < 6 ? 'Password baru minimal 6 karakter' : null,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _confPassController,
                        decoration: InputDecoration(hintText: 'Konfirmasi password baru'),
                        obscureText: true,
                        validator: (v) => v != _newPassController.text ? 'Konfirmasi password tidak sama' : null,
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _gantiPassword,
                        child: Text('Ganti Password'),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF185A9D)),
                      ),
                    ],
                  ),
                ),
                if (_msgPass != null) ...[
                  SizedBox(height: 6),
                  Text(_msgPass!, style: TextStyle(color: Colors.green)),
                ],
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showSuccessNama || _showSuccessPass)
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
                            _showSuccessNama ? 'Nama berhasil diubah!' : 'Password berhasil diganti!',
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
    );
  }
}

class CheckPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
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
    // Centang: mulai dari kiri bawah, ke tengah, lalu ke kanan atas
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
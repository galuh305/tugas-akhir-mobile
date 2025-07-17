import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Servis/Apiservis.dart';
import 'dart:convert';
import 'dart:math';
import '../../main.dart';
import 'live_chat_screen.dart';
import 'homescreen.dart';

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
  bool isEditNama = false;
  bool isEditPassword = false;

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
    final isWide = MediaQuery.of(context).size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 24, left: isWide ? 120 : 20, right: isWide ? 120 : 20, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: Icon(Icons.home, color: isDark ? Colors.white : Color(0xFF185A9D)),
                      label: Text('Kembali ke Home', style: TextStyle(color: isDark ? Colors.white : Color(0xFF185A9D), fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Color(0xFF185A9D) : Colors.white,
                        foregroundColor: isDark ? Colors.white : Color(0xFF185A9D),
                        elevation: 0,
                        side: BorderSide(color: Color(0xFF185A9D)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    Spacer(),
                    Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? Colors.amber : Color(0xFF185A9D)),
                    SizedBox(width: 8),
                    Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                    Switch(
                      value: isDark,
                      onChanged: (val) async {
                        themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                        await saveThemeMode(themeModeNotifier.value);
                      },
                      activeColor: Colors.amber,
                      inactiveThumbColor: Color(0xFF185A9D),
                    ),
                  ],
                ),
              ),
              // HEADER
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 48, left: isWide ? 80 : 24, right: isWide ? 80 : 24, bottom: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark ? [Color(0xFF23272A), Color(0xFF181C1F)] : [Color(0xFF43CEA2), Color(0xFF185A9D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF185A9D), size: 40),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? 'Nama tidak tersedia',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            email ?? 'Email tidak tersedia',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36),
              // CARD EDIT NAMA
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 120 : 20),
                child: Card(
                  color: Theme.of(context).cardColor.withOpacity(0.98),
                  elevation: 10,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Edit Nama', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF185A9D), fontSize: 18)),
                            isEditNama
                              ? TextButton(
                                  onPressed: () {
                                    setState(() { isEditNama = false; _namaController.text = name ?? ''; });
                                  },
                                  child: Text('Batal', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                )
                              : TextButton(
                                  onPressed: () { setState(() { isEditNama = true; }); },
                                  child: Text('Edit', style: TextStyle(color: Color(0xFF185A9D), fontWeight: FontWeight.bold)),
                                ),
                          ],
                        ),
                        SizedBox(height: 18),
                        Form(
                          key: _formKeyNama,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _namaController,
                                  enabled: isEditNama,
                                  style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'Nama baru',
                                    hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                                    prefixIcon: Icon(Icons.person, color: isDark ? Colors.white : Color(0xFF185A9D)),
                                    filled: true,
                                    fillColor: isDark ? Color(0xFF23272A) : Color(0xFFF7FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFF185A9D).withOpacity(0.2))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFF185A9D).withOpacity(0.15))),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                flex: 0,
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: isEditNama ? _updateNama : null,
                                    child: Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 28),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                      backgroundColor: Color(0xFF185A9D),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Color(0xFFE0E3EB),
                                      disabledForegroundColor: Color(0xFF185A9D),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_msgNama != null) ...[
                          SizedBox(height: 10),
                          Text(_msgNama!, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              // CARD GANTI PASSWORD
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 120 : 20),
                child: Card(
                  color: Theme.of(context).cardColor.withOpacity(0.98),
                  elevation: 10,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ganti Password', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF185A9D), fontSize: 18)),
                            isEditPassword
                              ? TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditPassword = false;
                                      _oldPassController.clear();
                                      _newPassController.clear();
                                      _confPassController.clear();
                                    });
                                  },
                                  child: Text('Batal', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                )
                              : TextButton(
                                  onPressed: () { setState(() { isEditPassword = true; }); },
                                  child: Text('Edit', style: TextStyle(color: Color(0xFF185A9D), fontWeight: FontWeight.bold)),
                                ),
                          ],
                        ),
                        SizedBox(height: 18),
                        Form(
                          key: _formKeyPassword,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _oldPassController,
                                enabled: isEditPassword,
                                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Password lama',
                                  hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                                  prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white : Color(0xFF185A9D)),
                                  filled: true,
                                  fillColor: isDark ? Color(0xFF23272A) : Color(0xFFF7FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFF185A9D).withOpacity(0.2))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFF185A9D).withOpacity(0.15))),
                                ),
                                obscureText: true,
                                validator: (v) => v == null || v.isEmpty ? 'Password lama wajib diisi' : null,
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: _newPassController,
                                enabled: isEditPassword,
                                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Password baru',
                                  hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                                  prefixIcon: Icon(Icons.lock, color: isDark ? Colors.white : Color(0xFF185A9D)),
                                  filled: true,
                                  fillColor: isDark ? Color(0xFF23272A) : Color(0xFFF7FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFF185A9D).withOpacity(0.2))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFF185A9D).withOpacity(0.15))),
                                ),
                                obscureText: true,
                                validator: (v) => v == null || v.length < 6 ? 'Password baru minimal 6 karakter' : null,
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: _confPassController,
                                enabled: isEditPassword,
                                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Konfirmasi password baru',
                                  hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                                  prefixIcon: Icon(Icons.lock, color: isDark ? Colors.white : Color(0xFF185A9D)),
                                  filled: true,
                                  fillColor: isDark ? Color(0xFF23272A) : Color(0xFFF7FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFF185A9D).withOpacity(0.2))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFF185A9D).withOpacity(0.15))),
                                ),
                                obscureText: true,
                                validator: (v) => v != _newPassController.text ? 'Konfirmasi password tidak sama' : null,
                              ),
                              SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isEditPassword ? _gantiPassword : null,
                                  child: Text('Ganti Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                    backgroundColor: Color(0xFF185A9D),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Color(0xFFE0E3EB),
                                    disabledForegroundColor: Color(0xFF185A9D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_msgPass != null) ...[
                          SizedBox(height: 10),
                          Text(_msgPass!, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              // CARD LOGOUT
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 120 : 20),
                child: Card(
                  color: Theme.of(context).cardColor.withOpacity(0.98),
                  elevation: 8,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: Icon(Icons.logout),
                            label: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => LiveChatScreen()));
                            },
                            icon: Icon(Icons.chat),
                            label: Text('Live Chat Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF185A9D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 36),
            ],
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
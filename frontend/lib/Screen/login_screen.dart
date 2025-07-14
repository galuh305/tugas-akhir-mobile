import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', json.encode(data['user']));
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _error = 'Login gagal. Email atau password salah.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF0055A5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ======= LOGO BRANDING =======
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hi-Sport',
                        style: GoogleFonts.rubikGlitch(
                          textStyle: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/lg_bird-removebg-preview.png',
                        height: 40,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ======= EMAIL FIELD =======
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator:
                        (v) =>
                            v == null || v.isEmpty ? 'Email wajib diisi' : null,
                  ),

                  const SizedBox(height: 16),

                  // ======= PASSWORD FIELD =======
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? 'Password wajib diisi'
                                : null,
                  ),

                  const SizedBox(height: 24),

                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                  ],

                  // ======= LOGIN BUTTON =======
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed:
                          _loading
                              ? null
                              : () {
                                if (_formKey.currentState!.validate()) _login();
                              },
                      child:
                          _loading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ======= SOCIAL ICONS (Assets) =======
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo_google-removebg-preview.PNG',
                        height: 40,
                      ),
                      const SizedBox(width: 20),
                      Image.asset(
                        'assets/logo_fb-removebg-preview.PNG',
                        height: 40,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(
                          context,
                          '/register',
                        ),
                    child: const Text(
                      'Belum punya akun? Daftar',
                      style: TextStyle(color: Colors.white),
                    ),
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

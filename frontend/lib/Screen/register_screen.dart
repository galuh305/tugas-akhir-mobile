import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _passwordConfController.text,
      }),
    );
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 201 || response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final data = json.decode(response.body);
      setState(() {
        _error = data['message'] ?? 'Registrasi gagal.';
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
                  // ======= BRANDING LOGO =======
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

                  // ======= EMAIL =======
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

                  // ======= PASSWORD =======
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
                  const SizedBox(height: 16),

                  // ======= KONFIRMASI =======
                  TextFormField(
                    controller: _passwordConfController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator:
                        (v) =>
                            v != _passwordController.text
                                ? 'Konfirmasi password tidak sama'
                                : null,
                  ),
                  const SizedBox(height: 24),

                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                  ],

                  // ======= BUTTON =======
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
                                if (_formKey.currentState!.validate()) {
                                  _register();
                                }
                              },
                      child:
                          _loading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Daftar',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      'Sudah punya akun? Login',
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

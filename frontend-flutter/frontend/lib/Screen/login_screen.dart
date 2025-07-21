import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Servis/Apiservis.dart';

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
    setState(() { _loading = true; _error = null; });
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );
    setState(() { _loading = false; });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', json.encode(data['user']));
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() { _error = 'Login gagal. Email atau password salah.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F7FA),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.asset(
                  'assets/logo.png',
                  height: 160,
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Login', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF185A9D)), textAlign: TextAlign.center),
                        SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Color(0xFF185A9D)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF185A9D)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      obscureText: true,
                      validator: (v) => v == null || v.isEmpty ? 'Password wajib diisi' : null,
                    ),
                    SizedBox(height: 28),
                    if (_error != null) ...[
                      Text(_error!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: _loading ? null : () {
                        if (_formKey.currentState!.validate()) _login();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF185A9D),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Login', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 18),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                      child: Text('Belum punya akun? Daftar', style: TextStyle(color: Color(0xFF185A9D), fontWeight: FontWeight.bold)),
                    ),
                  ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
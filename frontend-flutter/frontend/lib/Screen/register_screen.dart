import 'package:flutter/material.dart';
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
    setState(() { _loading = true; _error = null; });
    final response = await http.post(
      Uri.parse('http://10.176.85.163:8000/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _passwordConfController.text,
      }),
    );
    setState(() { _loading = false; });
    if (response.statusCode == 201 || response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final data = json.decode(response.body);
      setState(() { _error = data['message'] ?? 'Registrasi gagal.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F7FA),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
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
                    Text('Register', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF185A9D)), textAlign: TextAlign.center),
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
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordConfController,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF185A9D)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      obscureText: true,
                      validator: (v) => v != _passwordController.text ? 'Konfirmasi password tidak sama' : null,
                    ),
                    SizedBox(height: 28),
                    if (_error != null) ...[
                      Text(_error!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: _loading ? null : () {
                        if (_formKey.currentState!.validate()) _register();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF185A9D),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Daftar', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 18),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text('Sudah punya akun? Login', style: TextStyle(color: Color(0xFF185A9D), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
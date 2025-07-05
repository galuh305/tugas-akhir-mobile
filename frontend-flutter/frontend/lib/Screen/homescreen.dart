import 'package:flutter/material.dart';
import 'lapanganscreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Lapangan'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: LapanganScreen(),
      backgroundColor: Color(0xFFF5F6FA),
    );
  }
} 
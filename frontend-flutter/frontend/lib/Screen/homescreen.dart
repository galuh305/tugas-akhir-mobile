import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lapanganscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan gradient biru toska, avatar, dan tombol filter
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.sports, color: Color(0xFF185A9D), size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang!',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daftar Lapangan',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pilih lapangan favoritmu dan cek statusnya!',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  selectedType == 'badminton' ? Icons.sports_tennis : Icons.sports_tennis_outlined,
                                  color: selectedType == 'badminton'
                                      ? Colors.white
                                      : Color(0xFF185A9D),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Badminton',
                                  style: GoogleFonts.poppins(
                                    color: selectedType == 'badminton'
                                        ? Colors.white
                                        : Color(0xFF185A9D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            selected: selectedType == 'badminton',
                            backgroundColor: Color(0xFFD0F2EC),
                            selectedColor: Color(0xFF185A9D),
                            onSelected: (val) {
                              setState(() {
                                selectedType = selectedType == 'badminton' ? 'all' : 'badminton';
                              });
                            },
                          ),
                        ),
                        Flexible(
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  selectedType == 'futsal' ? Icons.sports_soccer : Icons.sports_soccer_outlined,
                                  color: selectedType == 'futsal'
                                      ? Colors.white
                                      : Color(0xFF185A9D),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Futsal',
                                  style: GoogleFonts.poppins(
                                    color: selectedType == 'futsal'
                                        ? Colors.white
                                        : Color(0xFF185A9D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            selected: selectedType == 'futsal',
                            backgroundColor: Color(0xFFD0F2EC),
                            selectedColor: Color(0xFF185A9D),
                            onSelected: (val) {
                              setState(() {
                                selectedType = selectedType == 'futsal' ? 'all' : 'futsal';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Konten list
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: LapanganScreen(filterTipe: selectedType),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
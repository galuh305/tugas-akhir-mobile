import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Servis/Apiservis.dart';
import '../Model/lapanganmodel.dart';
import 'lapanganscreen.dart';
import 'booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Lapangan>> futureLapangan;
  String userName = '';
  int selectedTab = 0;
  String searchKeyword = '';
  String selectedKategori = '';
  final List<Map<String, dynamic>> kategoriVenue = [
    {"nama": "Futsal", "icon": Icons.sports_soccer},
    {"nama": "Badminton", "icon": Icons.sports_tennis},
    {"nama": "Basket", "icon": Icons.sports_basketball},
    {"nama": "Voli", "icon": Icons.sports_volleyball},
    {"nama": "Tenis", "icon": Icons.sports_tennis},
  ];

  @override
  void initState() {
    super.initState();
    futureLapangan = fetchLapangan();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final user = userStr.contains('{') ? userStr : '{}';
      setState(() {
        userName = (user != '{}') ? (user.contains('name') ? RegExp('"name":"([^"]+)"').firstMatch(user)?.group(1) ?? '' : '') : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${userName.isNotEmpty ? userName : 'User'} 👋',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Welcome Hi-Sport',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Color(0xFF185A9D), size: 28),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          searchKeyword = val;
                        });
                        print('Search: $val');
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            // Tab Popular/Nearby/Latest
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTab('Most Viewed', 0),
                  SizedBox(width: 8),
                  _buildTab('Nearby', 1),
                  SizedBox(width: 8),
                  _buildTab('Latest', 2),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LapanganScreen()),
                      );
                    },
                    child: Text('View all'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            // Kategori Venue
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Kategori Venue', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: kategoriVenue.length,
                itemBuilder: (context, i) {
                  final kategori = kategoriVenue[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedKategori = kategori['nama'];
                      });
                      print('Kategori dipilih: ${kategori['nama']}');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: selectedKategori == kategori['nama'] ? Color(0xFF185A9D) : Color(0xFF43CEA2).withOpacity(0.15),
                            child: Icon(
                              kategori['icon'],
                              color: selectedKategori == kategori['nama'] ? Colors.white : Color(0xFF185A9D),
                              size: 28,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(kategori['nama'], style: GoogleFonts.poppins(fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Venue Populer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('Venue Populer', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            FutureBuilder<List<Lapangan>>(
              future: futureLapangan,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat venue'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Tidak ada venue'));
                }
                var populer = snapshot.data!.take(3).toList();
                // Filter dummy berdasarkan kategori atau search
                if (selectedKategori.isNotEmpty) {
                  populer = populer.where((lap) => lap.jenis.toLowerCase() == selectedKategori.toLowerCase()).toList();
                }
                if (searchKeyword.isNotEmpty) {
                  populer = populer.where((lap) => lap.nama.toLowerCase().contains(searchKeyword.toLowerCase())).toList();
                }
                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: populer.length,
                    itemBuilder: (context, i) {
                      final lap = populer[i];
                      return GestureDetector(
                        onTap: () {
                          print('Venue dipilih: ${lap.nama}');
                          // TODO: Navigasi ke halaman detail venue jika sudah ada
                        },
                        child: Container(
                          width: 180,
                          margin: EdgeInsets.only(right: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF43CEA2).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lap.nama, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                              SizedBox(height: 4),
                              Text('Jenis: ${lap.jenis}', style: GoogleFonts.poppins(fontSize: 12)),
                              SizedBox(height: 4),
                              Text('Harga: Rp${lap.harga}', style: GoogleFonts.poppins(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LapanganScreen(),
            ),
          );
        },
        child: Icon(Icons.add_shopping_cart),
        backgroundColor: Color(0xFF185A9D),
      ),
    );
  }

  Widget _buildTab(String label, int idx) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = idx;
        });
        print('Tab dipilih: $label');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedTab == idx ? Color(0xFF185A9D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF185A9D)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selectedTab == idx ? Colors.white : Color(0xFF185A9D),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 
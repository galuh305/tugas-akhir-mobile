import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Servis/Apiservis.dart';
import '../Model/lapanganmodel.dart';
import 'lapanganscreen.dart';
import 'booking_screen.dart';
import 'account_setting_screen.dart';
import 'riwayat_transaksi_screen.dart';
import '../Model/bookingmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Lapangan>> futureLapangan;
  Future<List<Booking>>? futureRiwayatTransaksi;
  String userName = '';
  int? userId;
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
  final List<Map<String, String>> promoList = [
    {"title": "Diskon 20% Booking Weekend!", "desc": "Booking lapangan di akhir pekan dapatkan diskon spesial."},
    {"title": "Gratis 1 Jam", "desc": "Booking 3 jam, gratis 1 jam untuk semua venue."},
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
        userId = (user != '{}') ? (user.contains('id') ? int.tryParse(RegExp('"id":(\d+)').firstMatch(user)?.group(1) ?? '') : null) : null;
      });
      // Panggil riwayat transaksi
      setState(() {
        futureRiwayatTransaksi = fetchRiwayatTransaksiUser2();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: isDark
                  ? LinearGradient(
                      colors: [Color(0xFF23272A), Color(0xFF181C1F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
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
                              'Hi,  ${userName.isNotEmpty ? userName : 'User'} 👋',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Welcome Hi-Sport',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.receipt_long, color: Colors.white, size: 32),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RiwayatTransaksiScreen()),
                          );
                        },
                        tooltip: 'Riwayat Transaksi',
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AccountSettingScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF23272A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          searchKeyword = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari venue...'
                            ,
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white : Color(0xFF185A9D)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // PROMO BANNER
            SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: promoList.length,
                separatorBuilder: (_, __) => SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final promo = promoList[i];
                  return Container(
                    width: 270,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF43CEA2).withOpacity(0.85), Color(0xFF185A9D).withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(promo['title']!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        Text(promo['desc']!, style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  );
                },
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
                    child: Text('View all', style: TextStyle(color: Color(0xFF185A9D), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            // Kategori Venue
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Kategori Venue', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF185A9D))),
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
                          Text(kategori['nama'], style: GoogleFonts.poppins(fontSize: 13, color: Color(0xFF185A9D))),
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
              child: Text('Venue Populer', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF185A9D))),
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
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: populer.length,
                    itemBuilder: (context, i) {
                      final lap = populer[i];
                      return GestureDetector(
                        onTap: () {
                          // TODO: Navigasi ke halaman detail venue jika sudah ada
                        },
                        child: Container(
                          width: 200,
                          margin: EdgeInsets.only(right: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF43CEA2).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lap.nama, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF185A9D))),
                              SizedBox(height: 4),
                              Text('Jenis: ${lap.jenis}', style: GoogleFonts.poppins(fontSize: 13)),
                              SizedBox(height: 4),
                              Text('Harga: Rp${lap.harga}', style: GoogleFonts.poppins(fontSize: 13)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // RIWAYAT TRANSAKSI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('Riwayat Transaksi Terakhir', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF185A9D))),
            ),
            FutureBuilder<List<Booking>>(
              future: futureRiwayatTransaksi,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat riwayat transaksi'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Belum ada riwayat transaksi'));
                }
                final transaksi = snapshot.data!;
                // Ambil data lapangan dari futureLapangan
                return FutureBuilder<List<Lapangan>>(
                  future: futureLapangan,
                  builder: (context, lapanganSnapshot) {
                    if (lapanganSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (lapanganSnapshot.hasError || !lapanganSnapshot.hasData) {
                      // Fallback ke lapanganId jika gagal
                      return Column(
                        children: transaksi.map((b) => Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFF43CEA2).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(Icons.receipt_long, color: Color(0xFF185A9D)),
                            title: Text('Lapangan: ${b.lapanganId}', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Tanggal: ${b.tanggal}\nJam: ${b.jamMulai} - ${b.jamSelesai}\nStatus: ${b.status}\nTotal: Rp${b.totalHarga}'),
                            trailing: b.status == 'pending'
                              ? Icon(Icons.timelapse, color: Colors.orange)
                              : Icon(Icons.check_circle, color: Colors.green),
                          ),
                        )).toList(),
                      );
                    }
                    final lapanganList = lapanganSnapshot.data!;
                    return Column(
                      children: transaksi.map((b) {
                        final lapangan = lapanganList.firstWhere(
                          (l) => l.id == b.lapanganId,
                          orElse: () => Lapangan(id: b.lapanganId, nama: 'Lapangan ${b.lapanganId}', jenis: '', harga: 0, tipe: '', aktif: 1),
                        );
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFF43CEA2).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(Icons.receipt_long, color: Color(0xFF185A9D)),
                            title: Text('Lapangan: ${lapangan.nama}', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Tanggal: ${b.tanggal}\nJam: ${b.jamMulai} - ${b.jamSelesai}\nStatus: ${b.status}\nTotal: Rp${b.totalHarga}'),
                            trailing: b.status == 'pending'
                              ? Icon(Icons.timelapse, color: Colors.orange)
                              : Icon(Icons.check_circle, color: Colors.green),
                          ),
                        );
                      }).toList(),
                    );
                  },
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
        child: Icon(Icons.add_shopping_cart, color: Colors.white),
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
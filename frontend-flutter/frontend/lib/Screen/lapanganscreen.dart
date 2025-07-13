import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Model/lapanganmodel.dart';
import '../Servis/Apiservis.dart';

class LapanganScreen extends StatefulWidget {
  final String filterTipe;
  const LapanganScreen({Key? key, this.filterTipe = 'all'}) : super(key: key);

  @override
  _LapanganScreenState createState() => _LapanganScreenState();
}

class _LapanganScreenState extends State<LapanganScreen> {
  late Future<List<Lapangan>> futureLapangan;

  @override
  void initState() {
    super.initState();
    futureLapangan = fetchLapangan();
  }

  IconData _getIcon(String jenis) {
    if (jenis.toLowerCase().contains('badminton')) {
      return Icons.sports_tennis;
    } else if (jenis.toLowerCase().contains('futsal')) {
      return Icons.sports_soccer;
    }
    return Icons.sports;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Lapangan>>(
      future: futureLapangan,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Lapangan> data = snapshot.data ?? [];
          if (widget.filterTipe != 'all') {
            data = data.where((e) {
              if (widget.filterTipe == 'badminton') {
                return e.jenis.toLowerCase() == 'badminton';
              } else if (widget.filterTipe == 'futsal') {
                return e.jenis.toLowerCase() == 'futsal';
              }
              return true;
            }).toList();
          }
          if (data.isEmpty) {
            return Center(child: Text('Tidak ada data lapangan untuk filter ini.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])));
          }
          return ListView.builder(
            itemCount: data.length,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            itemBuilder: (context, index) {
              final lapangan = data[index];
              bool validAktif = lapangan.aktif == 0 || lapangan.aktif == 1;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF43CEA2).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Icon(
                            _getIcon(lapangan.jenis),
                            size: 36,
                            color: const Color(0xFF185A9D),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      lapangan.nama,
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF185A9D),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: lapangan.aktif == 1 ? const Color(0xFF43CEA2) : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          lapangan.aktif == 1 ? Icons.check_circle : Icons.cancel,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          lapangan.aktif == 1 ? "Aktif" : "Tidak Aktif",
                                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.category, size: 18, color: const Color(0xFF185A9D)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Jenis: ${lapangan.jenis}",
                                    style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF185A9D)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.category, size: 18, color: const Color(0xFF185A9D)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Tipe: ${lapangan.tipe}",
                                    style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF185A9D)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.attach_money, size: 18, color: const Color(0xFF185A9D)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Harga: Rp${lapangan.harga}",
                                    style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF185A9D)),
                                  ),
                                ],
                              ),
                              if (!validAktif)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Status aktif tidak valid!",
                                    style: GoogleFonts.poppins(color: Colors.orange, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Gagal memuat data", style: GoogleFonts.poppins(color: Colors.red)));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

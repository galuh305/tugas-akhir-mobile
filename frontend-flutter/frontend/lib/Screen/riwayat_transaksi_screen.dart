import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Servis/Apiservis.dart';
import '../Model/lapanganmodel.dart';
import '../Model/bookingmodel.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({Key? key}) : super(key: key);

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  late Future<List<Booking>> futureRiwayatTransaksi;
  late Future<List<Lapangan>> futureLapangan;

  @override
  void initState() {
    super.initState();
    futureRiwayatTransaksi = fetchRiwayatTransaksiUser();
    futureLapangan = fetchLapangan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Transaksi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF185A9D),
      ),
      body: FutureBuilder<List<Booking>>(
        future: futureRiwayatTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat riwayat transaksi'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada riwayat transaksi'));
          }
          final transaksi = snapshot.data!.reversed.toList();
          return FutureBuilder<List<Lapangan>>(
            future: futureLapangan,
            builder: (context, lapanganSnapshot) {
              if (lapanganSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (lapanganSnapshot.hasError || !lapanganSnapshot.hasData) {
                // Fallback ke lapanganId jika gagal
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: transaksi.length,
                  itemBuilder: (context, i) {
                    final b = transaksi[i];
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
                        title: Text('Lapangan: ${b.lapanganId}', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tanggal: ${b.tanggal}\nJam: ${b.jamMulai} - ${b.jamSelesai}\nStatus: ${b.status}\nTotal: Rp${b.totalHarga}'),
                        trailing: b.status == 'pending'
                          ? Icon(Icons.timelapse, color: Colors.orange)
                          : Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                );
              }
              final lapanganList = lapanganSnapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: transaksi.length,
                itemBuilder: (context, i) {
                  final b = transaksi[i];
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
                },
              );
            },
          );
        },
      ),
    );
  }
}

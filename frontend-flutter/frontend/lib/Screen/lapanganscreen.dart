import 'package:flutter/material.dart';
import '../Model/lapanganmodel.dart';
import '../Servis/Apiservis.dart';

class LapanganScreen extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Lapangan>>(
      future: futureLapangan,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data ?? [];
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final lapangan = data[index];
              bool validAktif = lapangan.aktif == 0 || lapangan.aktif == 1;
              return Card(
                margin: EdgeInsets.all(12),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lapangan.nama, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Tipe: ${lapangan.tipe}"),
                      Text("Harga: Rp${lapangan.harga}"),
                      Row(
                        children: [
                          Text("Status: "),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: lapangan.aktif == 1 ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lapangan.aktif == 1 ? "Aktif" : "Tidak Aktif",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      if (!validAktif)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "Status aktif tidak valid!",
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Gagal memuat data"));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'booking_screen.dart';
import '../widgets/custom_button.dart';

class DetailScreen extends StatelessWidget {
  final String venueName;
  final String venueImage;

  const DetailScreen({
    super.key,
    required this.venueName,
    required this.venueImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(venueName)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(venueImage, height: 250, fit: BoxFit.cover),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              venueName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // ✅ Tambahan deskripsi panjang di sini
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Nikmati fasilitas olahraga terbaik dengan lapangan yang bersih dan terawat. "
              "Dilengkapi pencahayaan modern untuk sesi malam hari, ruang ganti bersih, area parkir luas, "
              "dan tribun penonton. Harga terjangkau mulai dari Rp 100.000/jam. Pemesanan fleksibel melalui aplikasi. "
              "Harap datang 10 menit sebelum jadwal. Aturan: sepatu khusus non-marking wajib, "
              "dilarang merokok di area lapangan, dan patuhi protokol kebersihan.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: "Book Now",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(
                      venueName: venueName,
                      venueImage: venueImage,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

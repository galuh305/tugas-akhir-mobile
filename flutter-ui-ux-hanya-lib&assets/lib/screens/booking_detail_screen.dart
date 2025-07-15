import 'package:flutter/material.dart';

class BookingDetailScreen extends StatelessWidget {
  final String venueName;
  final String venueImage;
  final String date;
  final String time;

  const BookingDetailScreen({
    super.key,
    required this.venueName,
    required this.venueImage,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Booking")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(venueImage, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 20),
            Text("Booking Details", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Card(child: ListTile(leading: const Icon(Icons.sports), title: Text("Venue: $venueName"))),
            Card(child: ListTile(leading: const Icon(Icons.calendar_today), title: Text("Date: $date"))),
            Card(child: ListTile(leading: const Icon(Icons.access_time), title: Text("Time: $time"))),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share),
              label: const Text("Share Pass"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

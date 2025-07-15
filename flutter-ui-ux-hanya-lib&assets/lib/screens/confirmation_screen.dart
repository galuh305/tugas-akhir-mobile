import 'package:flutter/material.dart';
import 'booking_detail_screen.dart';
import '../widgets/custom_button.dart';

class ConfirmationScreen extends StatelessWidget {
  final String venueName;
  final String venueImage;
  final String date;
  final String time;
  final String paymentMethod;

  const ConfirmationScreen({
    super.key,
    required this.venueName,
    required this.venueImage,
    required this.date,
    required this.time,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmation")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset('assets/correct.png', height: 150),
            const SizedBox(height: 20),
            const Text("Payment Successful", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Payment Method: $paymentMethod", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            CustomButton(
              text: "View Booking",
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingDetailScreen(
                      venueName: venueName,
                      venueImage: venueImage,
                      date: date,
                      time: time,
                    ),
                  ),
                  (route) => false,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'confirmation_screen.dart';

class PaymentScreen extends StatelessWidget {
  final String venueName;
  final String venueImage;
  final String date;
  final String time;

  const PaymentScreen({
    super.key,
    required this.venueName,
    required this.venueImage,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final paymentMethods = [
      {"name": "QRIS - Dana", "image": "assets/qr_dana.png"},
      {"name": "QRIS - Gopay", "image": "assets/qr_gopay.png"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Payment Method")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: paymentMethods.length,
        itemBuilder: (context, index) {
          final method = paymentMethods[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Image.asset(method['image']!, width: 50),
              title: Text(method['name']!),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfirmationScreen(
                      venueName: venueName,
                      venueImage: venueImage,
                      date: date,
                      time: time,
                      paymentMethod: method['name']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

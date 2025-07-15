import 'package:flutter/material.dart';
import 'payment_screen.dart';
import '../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final String venueName;
  final String venueImage;

  const BookingScreen({
    super.key,
    required this.venueName,
    required this.venueImage,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  bool get isButtonEnabled =>
      dateController.text.isNotEmpty && timeController.text.isNotEmpty;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('dd MMM yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      setState(() {
        timeController.text = DateFormat('HH:mm').format(selectedDateTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(widget.venueImage, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 20),
            Text(widget.venueName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_today),
                hintText: "Select Date",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              readOnly: true,
              onTap: _selectTime,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.access_time),
                hintText: "Select Time",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: "Proceed to Payment",
              onPressed: isButtonEnabled
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            venueName: widget.venueName,
                            venueImage: widget.venueImage,
                            date: dateController.text,
                            time: timeController.text,
                          ),
                        ),
                      );
                    }
                  : null,
            )
          ],
        ),
      ),
    );
  }
}

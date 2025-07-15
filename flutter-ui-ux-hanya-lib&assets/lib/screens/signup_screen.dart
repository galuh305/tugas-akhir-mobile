import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button.dart';
import 'verification_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            InputField(
              hintText: "Full Name",
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            InputField(
              hintText: "Email",
              icon: Icons.email,
            ),
            const SizedBox(height: 12),
            InputField(
              hintText: "Password",
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Sign Up",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerificationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

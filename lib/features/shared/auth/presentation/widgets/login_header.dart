import 'package:flutter/material.dart';

/// Header komponen untuk login page dengan logo dan judul
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Logo dan Header
        const Icon(Icons.mosque, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          'SiSantri',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Silakan login untuk melanjutkan',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// Widget untuk menampilkan splash screen atau loading screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mosque,
                size: 60,
                color: Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(height: 32),

            // App Name
            const Text(
              'SiSantri',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Gamifikasi Pondok Pesantren',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 48),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),

            const SizedBox(height: 16),

            const Text(
              'Memuat...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

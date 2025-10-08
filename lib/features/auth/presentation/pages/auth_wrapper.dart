import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/role_based_navigation.dart';
import '../../../../shared/widgets/splash_screen.dart';
import 'login_page.dart';
import 'rfid_setup_required_page.dart';

/// Widget wrapper untuk mengelola state autentikasi dengan Clean Architecture
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(currentUserDataProvider);

    return userData.when(
      loading: () => const SplashScreen(),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Terjadi kesalahan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(currentUserDataProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        // Not logged in - show login page
        if (user == null) {
          return const LoginPageClean();
        }

        // User needs RFID setup
        if (user.needsRfidSetup) {
          return const RfidSetupRequiredPage();
        }

        // User is logged in and ready - show main navigation
        return const RoleBasedNavigation();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/user_model.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/splash_screen.dart';
import 'main_navigation.dart';
import 'dewa_guru_navigation.dart';

/// Provider untuk mendapatkan data user saat ini
final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) return null;

  return await AuthService.getUserData(currentUser.uid);
});

/// Widget untuk menentukan navigasi berdasarkan role user
class RoleBasedNavigation extends ConsumerWidget {
  const RoleBasedNavigation({super.key});

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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserDataProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('User data tidak ditemukan')),
          );
        }

        // Navigasi berdasarkan role
        if (user.isDewaGuru) {
          return const DewaGuruNavigation();
        } else {
          // Admin dan Santri menggunakan navigasi yang sama
          return const MainNavigation();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/models/user_model.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/splash_screen.dart';
import 'main_navigation.dart';
import 'admin_navigation.dart';
import 'dewan_guru_navigation.dart';

/// Provider untuk mendapatkan data user saat ini dengan real-time updates
final currentUserDataProvider = StreamProvider<UserModel?>((ref) {
  return AuthService.authStateChanges.asyncMap((user) async {
    if (user == null) return null;

    try {
      return await AuthService.getUserData(user.uid);
    } catch (e) {
      // Error loading user data
      return null;
    }
  });
});

/// Provider untuk auth state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

/// Widget untuk menentukan navigasi berdasarkan role user dengan real-time updates
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
              const Text(
                'Terjadi kesalahan saat memuat data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentUserDataProvider),
                child: const Text('Coba Lagi'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  try {
                    await AuthService.signOut();
                  } catch (e) {
                    // Error signing out
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Data pengguna tidak ditemukan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Silakan login ulang',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Navigasi berdasarkan role dengan validasi
        if (user.isAdmin) {
          return AdminNavigation(admin: user);
        } else if (user.isDewaGuru) {
          return const DewaGuruNavigation();
        } else if (user.isSantri) {
          return const MainNavigation();
        } else {
          // Role tidak dikenali
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Role tidak dikenali',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Role: ${user.role}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await AuthService.signOut();
                      } catch (e) {
                        // Error signing out
                      }
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

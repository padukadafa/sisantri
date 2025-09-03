import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/splash_screen.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/helpers/messaging_helper.dart';
import 'login_page.dart';
import 'rfid_setup_required_page.dart';
import '../../dashboard/presentation/role_based_navigation.dart';

/// Provider untuk memeriksa dan membuat data user jika perlu
final userSetupProvider = FutureProvider.family<UserModel?, String>((
  ref,
  uid,
) async {
  try {
    // Cek apakah data user sudah ada
    UserModel? userData = await AuthService.getUserData(uid);

    if (userData == null) {
      // Jika belum ada, buat data user baru
      final currentUser = AuthService.currentUser;
      if (currentUser != null) {
        await AuthService.createUserDocument(
          uid: uid,
          email: currentUser.email ?? '',
          nama: currentUser.displayName ?? 'User',
          role: 'santri',
        );

        // Ambil data user yang baru dibuat
        userData = await AuthService.getUserData(uid);
      }
    }

    return userData;
  } catch (e) {
    throw Exception('Error setting up user: $e');
  }
});

/// Widget wrapper untuk mengelola state autentikasi
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          // Setup user data jika belum ada
          return Consumer(
            builder: (context, ref, child) {
              final userSetup = ref.watch(userSetupProvider(user.uid));

              return userSetup.when(
                loading: () => const MaterialApp(
                  home: SplashScreen(),
                  debugShowCheckedModeBanner: false,
                ),
                error: (error, stack) => MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error setup user: $error',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await AuthService.signOut();
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  debugShowCheckedModeBanner: false,
                ),
                data: (userData) {
                  if (userData != null) {
                    // Initialize messaging setelah user data berhasil dimuat
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      MessagingHelper.initializeAfterLogin().catchError((e) {
                        // Error initializing messaging
                      });
                    });

                    // Check if santri needs RFID setup
                    if (userData.needsRfidSetup) {
                      return const MaterialApp(
                        home: RfidSetupRequiredPage(),
                        debugShowCheckedModeBanner: false,
                      );
                    }

                    // User data ready and RFID setup (or is admin), show role-based navigation
                    return const RoleBasedNavigation();
                  } else {
                    // User data setup failed, logout
                    return MaterialApp(
                      home: Scaffold(
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Gagal setup data user',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  await AuthService.signOut();
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      debugShowCheckedModeBanner: false,
                    );
                  }
                },
              );
            },
          );
        } else {
          // User is not logged in, show login page
          return const LoginPage();
        }
      },
    );
  }
}

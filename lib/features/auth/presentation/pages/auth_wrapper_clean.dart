import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/auth_provider.dart';
import '../../../../shared/widgets/splash_screen.dart';
import 'login_page_clean.dart';
import 'rfid_setup_required_page.dart';
import '../../../dashboard/presentation/role_based_navigation.dart';

/// Widget wrapper untuk mengelola state autentikasi dengan Clean Architecture
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state
    final authState = ref.watch(authProvider);

    // Check current user on first load
    ref.listen(authProvider, (previous, current) {
      if (previous == null || (previous.user == null && current.user != null)) {
        // User logged in, setup messaging if needed
        _setupMessaging(current.user?.id);
      }
    });

    // Initialize auth check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.user == null && !authState.isLoading) {
        ref.read(authProvider.notifier).checkCurrentUser();
      }
    });

    // Show error if any
    if (authState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${authState.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).clearError();
                  ref.read(authProvider.notifier).checkCurrentUser();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // If user is null, show login
    if (authState.user == null) {
      return const LoginPageClean();
    }

    final user = authState.user!;

    // Check if RFID setup is required
    if (user.needsRfidSetup) {
      return const RfidSetupRequiredPage();
    }

    // Navigate based on role
    return const RoleBasedNavigation();
  }

  /// Setup messaging untuk user yang login
  void _setupMessaging(String? userId) {
    if (userId == null) return;

    // Setup messaging helper - implementasi dapat disesuaikan
    // MessagingHelper.setupMessaging(userId);
  }
}

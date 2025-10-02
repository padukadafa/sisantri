import 'package:flutter/material.dart';

import '../../../shared/services/auth_service.dart';
import '../helpers/messaging_helper.dart';

/// Widget tombol logout yang dapat ditempatkan di mana saja
class LogoutButton extends StatelessWidget {
  final VoidCallback? onLogoutSuccess;
  final bool showLabel;
  final IconData icon;
  final Color? color;

  const LogoutButton({
    super.key,
    this.onLogoutSuccess,
    this.showLabel = true,
    this.icon = Icons.logout,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return showLabel
        ? _buildButtonWithLabel(context)
        : _buildIconButton(context);
  }

  Widget _buildButtonWithLabel(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showLogoutDialog(context),
      icon: Icon(icon, size: 18),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (color ?? Colors.red).withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? Colors.red).withAlpha(50),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: () => _showLogoutDialog(context),
        icon: Icon(icon, color: color ?? Colors.red, size: 20),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withAlpha(50), width: 1),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Konfirmasi Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Anda perlu login kembali untuk mengakses aplikasi.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ya, Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    // Tampilkan loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Sedang logout...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    bool dialogClosed = false;

    try {
      // Set timeout yang lebih pendek untuk logout process
      await Future.any([
        _performLogoutSteps(),
        Future.delayed(const Duration(seconds: 8), () {
          throw Exception('Logout timeout - operasi terlalu lama');
        }),
      ]);

      // Tutup loading dialog
      if (context.mounted && !dialogClosed) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogClosed = true;
      }

      // Panggil callback jika ada
      if (onLogoutSuccess != null) {
        onLogoutSuccess!();
      }

      // Tampilkan pesan sukses
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Berhasil logout'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Tutup loading dialog jika belum ditutup
      if (context.mounted && !dialogClosed) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogClosed = true;
      }

      // Force logout bahkan jika ada error
      try {
        await AuthService.signOut();
      } catch (_) {
        // Ignore final errors
      }

      // Tampilkan pesan (sukses karena tetap berhasil logout)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Logout berhasil'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Panggil callback jika ada
      if (onLogoutSuccess != null) {
        onLogoutSuccess!();
      }
    }
  }

  Future<void> _performLogoutSteps() async {
    try {
      // Step 1: Cleanup messaging (dengan timeout singkat)
      await Future.any([
        _cleanupMessagingWithTimeout(),
        Future.delayed(const Duration(seconds: 2)),
      ]).catchError((_) {
        // Ignore messaging cleanup errors
      });

      // Step 2: Sign out dengan timeout yang lebih pendek
      await Future.any([
        _signOutWithTimeout(),
        Future.delayed(const Duration(seconds: 5)),
      ]);
    } catch (e) {
      // Jika ada error, tetep lanjut dengan force sign out
      try {
        await AuthService.signOut();
      } catch (_) {
        // Ignore final sign out errors
      }
      rethrow;
    }
  }

  Future<void> _cleanupMessagingWithTimeout() async {
    try {
      // Gunakan MessagingHelper untuk cleanup messaging
      await MessagingHelper.unsubscribeFromAllTopics();
    } catch (e) {
      // Ignore messaging cleanup errors
    }
  }

  Future<void> _signOutWithTimeout() async {
    try {
      // Gunakan AuthService.signOut() yang sudah memiliki timeout handling
      await AuthService.signOut();
    } catch (e) {
      // Ignore sign out errors
    }
  }
}

/// Widget untuk quick logout di pojok kanan atas
class QuickLogoutButton extends StatelessWidget {
  const QuickLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: SafeArea(
        child: LogoutButton(showLabel: false, color: Colors.red.withAlpha(200)),
      ),
    );
  }
}

/// Widget untuk logout dalam menu
class MenuLogoutTile extends StatelessWidget {
  final VoidCallback? onLogoutSuccess;

  const MenuLogoutTile({super.key, this.onLogoutSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(50), width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.logout, color: Colors.red, size: 20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
        ),
        subtitle: const Text(
          'Keluar dari aplikasi',
          style: TextStyle(fontSize: 12, color: Colors.red),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.red,
          size: 16,
        ),
        onTap: () {
          LogoutButton(
            onLogoutSuccess: onLogoutSuccess,
          )._showLogoutDialog(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

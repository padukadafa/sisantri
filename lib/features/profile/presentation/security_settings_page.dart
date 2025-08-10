import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() =>
      _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  bool twoFactorEnabled = false;
  bool biometricEnabled = true;
  bool securityAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Keamanan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordSection(),
            const SizedBox(height: 24),
            _buildTwoFactorSection(),
            const SizedBox(height: 24),
            _buildBiometricSection(),
            const SizedBox(height: 24),
            _buildSecurityAlertsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.vpn_key),
              title: const Text('Ubah Password'),
              subtitle: const Text('Terakhir diubah 30 hari yang lalu'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoFactorSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Autentikasi Dua Faktor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Aktifkan 2FA'),
              subtitle: Text(
                twoFactorEnabled
                    ? 'Keamanan ekstra dengan kode verifikasi'
                    : 'Tambahkan lapisan keamanan tambahan',
              ),
              value: twoFactorEnabled,
              onChanged: (bool value) {
                setState(() {
                  twoFactorEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? '2FA berhasil diaktifkan'
                          : '2FA berhasil dinonaktifkan',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fingerprint, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Biometrik',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Login dengan Sidik Jari'),
              subtitle: const Text('Gunakan sidik jari untuk login cepat'),
              value: biometricEnabled,
              onChanged: (bool value) {
                setState(() {
                  biometricEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Login biometrik diaktifkan'
                          : 'Login biometrik dinonaktifkan',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityAlertsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Peringatan Keamanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Notifikasi Login'),
              subtitle: const Text('Dapatkan notifikasi saat ada login baru'),
              value: securityAlertsEnabled,
              onChanged: (bool value) {
                setState(() {
                  securityAlertsEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Notifikasi keamanan diaktifkan'
                          : 'Notifikasi keamanan dinonaktifkan',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password berhasil diubah')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Konfirmasi password tidak sesuai'),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

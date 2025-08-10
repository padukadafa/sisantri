import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

/// Provider untuk pengaturan keamanan
final securitySettingsProvider = StateProvider<Map<String, bool>>((ref) {
  return {'twoFactorAuth': false, 'biometricLogin': true, 'loginAlerts': true};
});

/// Provider untuk visibility password
final passwordVisibilityProvider = StateProvider<Map<String, bool>>((ref) {
  return {'current': false, 'new': false, 'confirm': false};
});

/// Halaman Pengaturan Keamanan
class SecuritySettingsPage extends ConsumerWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securitySettings = ref.watch(securitySettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keamanan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password Section
            _buildSectionHeader('Password & Autentikasi'),
            _buildPasswordSection(context),

            const SizedBox(height: 32),

            // Security Features Section
            _buildSectionHeader('Fitur Keamanan'),
            _buildSecurityFeaturesSection(context, ref, securitySettings),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun Anda',
            onTap: () => _showChangePasswordDialog(context),
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.restore,
            title: 'Reset Password',
            subtitle: 'Kirim email reset password',
            onTap: () => _showResetPasswordDialog(context),
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.password,
            title: 'Generator Password',
            subtitle: 'Buat password yang kuat',
            onTap: () => _showPasswordGeneratorDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeaturesSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, bool> settings,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.security,
            title: 'Autentikasi 2 Faktor',
            subtitle: 'Tambahan keamanan dengan verifikasi kode',
            value: settings['twoFactorAuth'] ?? false,
            onChanged: (value) {
              ref
                  .read(securitySettingsProvider.notifier)
                  .update((state) => {...state, 'twoFactorAuth': value});

              if (value) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('2FA diaktifkan')));
              }
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: 'Login Biometrik',
            subtitle: 'Gunakan sidik jari atau wajah untuk login',
            value: settings['biometricLogin'] ?? true,
            onChanged: (value) {
              ref
                  .read(securitySettingsProvider.notifier)
                  .update((state) => {...state, 'biometricLogin': value});
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.login,
            title: 'Alert Login',
            subtitle: 'Notifikasi setiap kali ada aktivitas login',
            value: settings['loginAlerts'] ?? true,
            onChanged: (value) {
              ref
                  .read(securitySettingsProvider.notifier)
                  .update((state) => {...state, 'loginAlerts': value});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E2E2E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E2E2E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[200], height: 1, thickness: 1);
  }

  // Dialog Methods
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text(
          'Email reset password akan dikirim ke alamat email yang terdaftar pada akun Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email reset password telah dikirim'),
                ),
              );
            },
            child: const Text('Kirim Email'),
          ),
        ],
      ),
    );
  }

  void _showPasswordGeneratorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PasswordGeneratorDialog(),
    );
  }
}

/// Widget untuk dialog ubah password
class ChangePasswordDialog extends ConsumerWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordVisibility = ref.watch(passwordVisibilityProvider);

    return AlertDialog(
      title: const Text('Ubah Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current Password
            TextFormField(
              obscureText: !passwordVisibility['current']!,
              decoration: InputDecoration(
                labelText: 'Password Saat Ini',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisibility['current']!
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    ref
                        .read(passwordVisibilityProvider.notifier)
                        .update(
                          (state) => {...state, 'current': !state['current']!},
                        );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // New Password
            TextFormField(
              obscureText: !passwordVisibility['new']!,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisibility['new']!
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    ref
                        .read(passwordVisibilityProvider.notifier)
                        .update((state) => {...state, 'new': !state['new']!});
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              obscureText: !passwordVisibility['confirm']!,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisibility['confirm']!
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    ref
                        .read(passwordVisibilityProvider.notifier)
                        .update(
                          (state) => {...state, 'confirm': !state['confirm']!},
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password berhasil diubah')),
            );
          },
          child: const Text('Ubah Password'),
        ),
      ],
    );
  }
}

/// Widget untuk dialog generator password
class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  int passwordLength = 12;
  bool includeUppercase = true;
  bool includeLowercase = true;
  bool includeNumbers = true;
  bool includeSymbols = false;
  String generatedPassword = 'SamplePass123';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    setState(() {
      generatedPassword = 'Generated${passwordLength}Pass';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generator Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Generated Password
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      generatedPassword,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password disalin ke clipboard'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Password Length
            Row(
              children: [
                const Text('Panjang Password: '),
                Expanded(
                  child: Slider(
                    value: passwordLength.toDouble(),
                    min: 8,
                    max: 32,
                    divisions: 24,
                    label: passwordLength.toString(),
                    onChanged: (value) {
                      setState(() {
                        passwordLength = value.round();
                      });
                      _generatePassword();
                    },
                  ),
                ),
                Text('$passwordLength'),
              ],
            ),

            // Options
            CheckboxListTile(
              title: const Text('Huruf Besar'),
              value: includeUppercase,
              onChanged: (value) {
                setState(() {
                  includeUppercase = value ?? true;
                });
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: const Text('Huruf Kecil'),
              value: includeLowercase,
              onChanged: (value) {
                setState(() {
                  includeLowercase = value ?? true;
                });
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: const Text('Angka'),
              value: includeNumbers,
              onChanged: (value) {
                setState(() {
                  includeNumbers = value ?? true;
                });
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: const Text('Simbol'),
              value: includeSymbols,
              onChanged: (value) {
                setState(() {
                  includeSymbols = value ?? false;
                });
                _generatePassword();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        ElevatedButton(
          onPressed: _generatePassword,
          child: const Text('Generate Ulang'),
        ),
      ],
    );
  }
}

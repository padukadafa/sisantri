import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisantri/core/theme/app_theme.dart';

final notificationSettingsProvider = StateProvider<Map<String, bool>>(
  (ref) => {
    'pengumuman': true,
    'presensi': true,
    'kegiatan': true,
    'reminder': true,
    'leaderboard': false,
  },
);

final generalSettingsProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {
    'theme': 'light',
    'language': 'id',
    'autoSync': true,
    'saveData': false,
  },
);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final generalSettings = ref.watch(generalSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifikasi Section
            _buildSectionHeader('Notifikasi'),
            _buildNotificationSettings(context, ref, notificationSettings),

            const SizedBox(height: 32),

            // Tampilan Section
            _buildSectionHeader('Tampilan'),
            _buildDisplaySettings(context, ref, generalSettings),

            const SizedBox(height: 32),

            // Data & Sinkronisasi Section
            _buildSectionHeader('Data & Sinkronisasi'),
            _buildDataSettings(context, ref, generalSettings),

            const SizedBox(height: 32),

            // Keamanan Section
            _buildSectionHeader('Keamanan'),
            _buildSecuritySettings(context),

            const SizedBox(height: 32),

            // Tentang Section
            _buildSectionHeader('Tentang'),
            _buildAboutSettings(context),

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

  Widget _buildNotificationSettings(
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
            icon: Icons.campaign,
            title: 'Pengumuman',
            subtitle: 'Notifikasi pengumuman penting',
            value: settings['pengumuman'] ?? true,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .update((state) => {...state, 'pengumuman': value});
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.check_circle,
            title: 'Presensi',
            subtitle: 'Konfirmasi presensi dan reminder',
            value: settings['presensi'] ?? true,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .update((state) => {...state, 'presensi': value});
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.event,
            title: 'Kegiatan',
            subtitle: 'Pengingat kegiatan dan jadwal',
            value: settings['kegiatan'] ?? true,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .update((state) => {...state, 'kegiatan': value});
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.alarm,
            title: 'Pengingat Harian',
            subtitle: 'Reminder presensi dan kegiatan',
            value: settings['reminder'] ?? true,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .update((state) => {...state, 'reminder': value});
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.leaderboard,
            title: 'Leaderboard',
            subtitle: 'Update posisi ranking mingguan',
            value: settings['leaderboard'] ?? false,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .update((state) => {...state, 'leaderboard': value});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> settings,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          _buildSelectTile(
            icon: Icons.palette,
            title: 'Tema',
            subtitle: _getThemeLabel(settings['theme'] ?? 'light'),
            onTap: () => _showThemeDialog(context, ref, settings['theme']),
          ),
          _buildDivider(),
          _buildSelectTile(
            icon: Icons.language,
            title: 'Bahasa',
            subtitle: _getLanguageLabel(settings['language'] ?? 'id'),
            onTap: () =>
                _showLanguageDialog(context, ref, settings['language']),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> settings,
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
            icon: Icons.sync,
            title: 'Sinkronisasi Otomatis',
            subtitle: 'Sinkronkan data secara otomatis',
            value: settings['autoSync'] ?? true,
            onChanged: (value) {
              ref
                  .read(generalSettingsProvider.notifier)
                  .update((state) => {...state, 'autoSync': value});
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.data_saver_on,
            title: 'Hemat Data',
            subtitle: 'Kurangi penggunaan data mobile',
            value: settings['saveData'] ?? false,
            onChanged: (value) {
              ref
                  .read(generalSettingsProvider.notifier)
                  .update((state) => {...state, 'saveData': value});
            },
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.refresh,
            title: 'Sinkronkan Sekarang',
            subtitle: 'Sinkronkan semua data terbaru',
            onTap: () => _syncNow(context),
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.storage,
            title: 'Kelola Storage',
            subtitle: 'Lihat dan bersihkan cache',
            onTap: () => _showStorageDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
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
            icon: Icons.privacy_tip_outlined,
            title: 'Kebijakan Privasi',
            subtitle: 'Baca kebijakan privasi aplikasi',
            onTap: () => _showPrivacyPolicy(context),
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.gavel_outlined,
            title: 'Syarat & Ketentuan',
            subtitle: 'Baca syarat penggunaan aplikasi',
            onTap: () => _showTermsOfService(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.info_outline,
            title: 'Tentang SiSantri',
            subtitle: 'Versi 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.help_outline,
            title: 'Bantuan & FAQ',
            subtitle: 'Panduan penggunaan aplikasi',
            onTap: () => _showHelpDialog(context),
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.feedback_outlined,
            title: 'Kirim Feedback',
            subtitle: 'Berikan masukan untuk pengembangan',
            onTap: () => _showFeedbackDialog(context),
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.update,
            title: 'Periksa Update',
            subtitle: 'Cek versi terbaru aplikasi',
            onTap: () => _checkForUpdates(context),
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
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
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

  Widget _buildSelectTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 16,
      endIndent: 16,
    );
  }

  // Theme Dialog
  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    String currentTheme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, ref, 'light', 'Terang', currentTheme),
            _buildThemeOption(context, ref, 'dark', 'Gelap', currentTheme),
            _buildThemeOption(
              context,
              ref,
              'system',
              'Ikuti Sistem',
              currentTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String value,
    String label,
    String currentTheme,
  ) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: currentTheme,
      onChanged: (newValue) {
        if (newValue != null) {
          ref
              .read(generalSettingsProvider.notifier)
              .update((state) => {...state, 'theme': newValue});
          Navigator.pop(context);
        }
      },
    );
  }

  // Language Dialog
  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLanguage,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              ref,
              'id',
              'Bahasa Indonesia',
              currentLanguage,
            ),
            _buildLanguageOption(
              context,
              ref,
              'en',
              'English',
              currentLanguage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String value,
    String label,
    String currentLanguage,
  ) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: currentLanguage,
      onChanged: (newValue) {
        if (newValue != null) {
          ref
              .read(generalSettingsProvider.notifier)
              .update((state) => {...state, 'language': newValue});
          Navigator.pop(context);
        }
      },
    );
  }

  // Helper methods
  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Terang';
      case 'dark':
        return 'Gelap';
      case 'system':
        return 'Ikuti Sistem';
      default:
        return 'Terang';
    }
  }

  String _getLanguageLabel(String language) {
    switch (language) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
        return 'English';
      default:
        return 'Bahasa Indonesia';
    }
  }

  // Action methods
  void _syncNow(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sinkronisasi dimulai...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kelola Storage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cache: 12.5 MB'),
            Text('Gambar: 8.2 MB'),
            Text('Data Offline: 2.1 MB'),
            SizedBox(height: 16),
            Text('Total: 22.8 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache dibersihkan')),
              );
            },
            child: const Text('Bersihkan Cache'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ubah password akan segera hadir')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka kebijakan privasi...')),
    );
  }

  void _showTermsOfService(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka syarat & ketentuan...')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SiSantri',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.mosque, color: Colors.white, size: 30),
      ),
      children: const [
        Text(
          'Aplikasi gamifikasi untuk Pondok Pesantren Mahasiswa Al-Awwabin Sukarame – Bandar Lampung.',
        ),
        SizedBox(height: 16),
        Text(
          'Dikembangkan untuk memudahkan santri dalam mengakses jadwal, presensi, dan informasi pondok pesantren.',
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur bantuan akan segera hadir')),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Membuka form feedback...')));
  }

  void _checkForUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anda sudah menggunakan versi terbaru')),
    );
  }
}

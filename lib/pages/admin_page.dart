import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/services/dummy_data_service.dart';
import '../features/admin/presentation/rfid_management_page.dart';

/// Halaman admin untuk mengelola data aplikasi
class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildDataManagementSection(),
            const SizedBox(height: 16),
            _buildStatisticsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Selamat Datang, Admin!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Gunakan panel ini untuk mengelola data aplikasi SiSantri. Anda dapat menambah, mengedit, atau menghapus data sesuai kebutuhan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengelolaan Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.contactless,
              title: 'Manajemen RFID',
              subtitle: 'Kelola kartu RFID santri untuk presensi otomatis',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RfidManagementPage(),
                  ),
                );
              },
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.add_circle_outline,
              title: 'Buat Dummy Data',
              subtitle: 'Buat data sample untuk testing aplikasi',
              onTap: _createDummyData,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.delete_outline,
              title: 'Hapus Semua Data',
              subtitle: 'Hapus semua data dari database (hati-hati!)',
              onTap: _deleteDummyData,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.refresh,
              title: 'Reset Data',
              subtitle: 'Hapus data lama dan buat data baru',
              onTap: _resetData,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Aplikasi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.people,
                    title: 'Total Santri',
                    value: '25',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.school,
                    title: 'Pengajian',
                    value: '12',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.event,
                    title: 'Kegiatan',
                    value: '8',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.announcement,
                    title: 'Pengumuman',
                    value: '5',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withAlpha(30), width: 1),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.arrow_forward_ios, size: 12, color: color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _createDummyData() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Buat Dummy Data',
      message: 'Apakah Anda yakin ingin membuat data sample untuk testing?',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await DummyDataService.createAllDummyData();
      if (mounted) {
        _showSuccessSnackbar('Dummy data berhasil dibuat!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Gagal membuat dummy data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteDummyData() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Hapus Semua Data',
      message:
          'PERINGATAN: Semua data akan dihapus permanen. Apakah Anda yakin?',
      isDestructive: true,
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await DummyDataService.deleteAllDummyData();
      if (mounted) {
        _showSuccessSnackbar('Semua data berhasil dihapus!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Gagal menghapus data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetData() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Reset Data',
      message: 'Data lama akan dihapus dan data baru akan dibuat. Lanjutkan?',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await DummyDataService.deleteAllDummyData();
      await Future.delayed(const Duration(seconds: 1));
      await DummyDataService.createAllDummyData();
      if (mounted) {
        _showSuccessSnackbar('Data berhasil direset!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Gagal reset data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/firestore_service.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/jadwal_kegiatan_model.dart';
import '../../../shared/models/pengumuman_model.dart';
import '../../../shared/models/presensi_model.dart';

/// Provider untuk dashboard data
final dashboardDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
      return await FirestoreService.getDashboardData(userId);
    });

/// Halaman Dashboard utama aplikasi
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = AuthService.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('User tidak ditemukan')));
    }

    final dashboardData = ref.watch(dashboardDataProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur notifikasi akan segera hadir'),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: dashboardData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(dashboardDataProvider(currentUser.uid)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (data) => _buildDashboardContent(context, data),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final user = data['user'] as UserModel?;
    final todayPresensi = data['todayPresensi'] as PresensiModel?;
    final upcomingKegiatan =
        data['upcomingKegiatan'] as List<JadwalKegiatanModel>? ?? [];
    final recentPengumuman =
        data['recentPengumuman'] as List<PengumumanModel>? ?? [];

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(user),

            const SizedBox(height: 20),

            // Stats Cards Row
            _buildStatsCards(user, todayPresensi),

            const SizedBox(height: 24),

            // Upcoming Kegiatan
            _buildUpcomingKegiatan(upcomingKegiatan),

            const SizedBox(height: 24),

            // Recent Pengumuman
            _buildRecentPengumuman(recentPengumuman),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel? user) {
    return Container(
      width: double.infinity,
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: user?.fotoProfil != null
                    ? ClipOval(
                        child: Image.network(
                          user!.fotoProfil!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assalamu\'alaikum',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.nama ?? 'User',
                      style: const TextStyle(
                        color: Color(0xFF2E2E2E),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withAlpha(50),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${user?.poin ?? 0} Poin',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(UserModel? user, PresensiModel? todayPresensi) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.today,
            title: 'Presensi Hari Ini',
            value: todayPresensi?.status.label ?? 'Belum',
            color: todayPresensi != null ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            title: 'Total Poin',
            value: '${user?.poin ?? 0}',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(50), width: 1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingKegiatan(List<JadwalKegiatanModel> kegiatan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.event_available,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Kegiatan Mendatang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (kegiatan.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_busy,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada kegiatan mendatang',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...kegiatan
              .take(3)
              .map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withAlpha(50),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.event,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaKegiatan,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.formattedTanggal} • ${item.lokasi}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withAlpha(50),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Hari Ini',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildRecentPengumuman(List<PengumumanModel> pengumuman) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.campaign,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pengumuman Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all pengumuman
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (pengumuman.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.announcement_outlined,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada pengumuman',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...pengumuman
              .take(3)
              .map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: item.isPenting
                              ? Colors.red.withAlpha(15)
                              : AppTheme.primaryColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item.isPenting
                                ? Colors.red.withAlpha(50)
                                : AppTheme.primaryColor.withAlpha(50),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          item.isPenting ? Icons.priority_high : Icons.campaign,
                          color: item.isPenting
                              ? Colors.red
                              : AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.judul,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Color(0xFF2E2E2E),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.isPenting)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.red.withAlpha(50),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'Penting',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.isi,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.formattedTanggal,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  /// Menampilkan dialog konfirmasi logout
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
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService.signOut();
                // Navigation akan ditangani oleh AuthWrapper
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

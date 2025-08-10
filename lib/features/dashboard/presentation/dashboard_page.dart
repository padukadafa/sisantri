import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/firestore_service.dart';
import '../../../shared/services/presensi_service.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/jadwal_kegiatan_model.dart';
import '../../../shared/models/pengumuman_model.dart';

/// Provider untuk user data real-time
final dashboardUserProvider = StreamProvider<UserModel?>((ref) {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) {
    return Stream.value(null);
  }

  return FirestoreService.getUsers().map(
    (users) => users.where((u) => u.id == currentUser.uid).firstOrNull,
  );
});

/// Provider untuk presensi hari ini dengan real-time updates
final todayPresensiProvider = StreamProvider<PresensiModel?>((ref) {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) {
    return Stream.value(null);
  }

  return PresensiService.getPresensiTodayStream().map(
    (presensiList) =>
        presensiList.where((p) => p.userId == currentUser.uid).firstOrNull,
  );
});

/// Provider untuk kegiatan mendatang
final upcomingKegiatanProvider = StreamProvider<List<JadwalKegiatanModel>>((
  ref,
) {
  return FirestoreService.getUpcomingKegiatan();
});

/// Provider untuk pengumuman terbaru
final recentPengumumanProvider = StreamProvider<List<PengumumanModel>>((ref) {
  return FirestoreService.getRecentPengumuman();
});

/// Provider untuk dashboard data yang dikombinasikan
final dashboardDataProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final user = ref.watch(dashboardUserProvider);
  final todayPresensi = ref.watch(todayPresensiProvider);
  final upcomingKegiatan = ref.watch(upcomingKegiatanProvider);
  final recentPengumuman = ref.watch(recentPengumumanProvider);

  // Jika ada yang loading, return loading
  if (user.isLoading ||
      todayPresensi.isLoading ||
      upcomingKegiatan.isLoading ||
      recentPengumuman.isLoading) {
    return const AsyncValue.loading();
  }

  // Jika ada error, return error
  if (user.hasError) {
    return AsyncValue.error(user.error!, user.stackTrace!);
  }
  if (todayPresensi.hasError) {
    return AsyncValue.error(todayPresensi.error!, todayPresensi.stackTrace!);
  }
  if (upcomingKegiatan.hasError) {
    return AsyncValue.error(
      upcomingKegiatan.error!,
      upcomingKegiatan.stackTrace!,
    );
  }
  if (recentPengumuman.hasError) {
    return AsyncValue.error(
      recentPengumuman.error!,
      recentPengumuman.stackTrace!,
    );
  }

  // Return data yang dikombinasikan
  return AsyncValue.data({
    'user': user.value,
    'todayPresensi': todayPresensi.value,
    'upcomingKegiatan': upcomingKegiatan.value ?? [],
    'recentPengumuman': recentPengumuman.value ?? [],
  });
});

/// Provider untuk statistik user yang lebih comprehensive
final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) return {};

  try {
    // Get presensi minggu ini
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weeklyPresensi = await PresensiService.getPresensiByPeriod(
      startDate: startOfWeek,
      endDate: now,
      userId: currentUser.uid,
    );

    // Get presensi bulan ini
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthlyPresensi = await PresensiService.getPresensiByPeriod(
      startDate: startOfMonth,
      endDate: now,
      userId: currentUser.uid,
    );

    // Hitung statistik
    final weeklyHadir = weeklyPresensi.where((p) => p.status == 'hadir').length;
    final weeklyTerlambat = weeklyPresensi
        .where((p) => p.status == 'terlambat')
        .length;
    final monthlyHadir = monthlyPresensi
        .where((p) => p.status == 'hadir')
        .length;
    final monthlyTerlambat = monthlyPresensi
        .where((p) => p.status == 'terlambat')
        .length;

    return {
      'weeklyTotal': weeklyPresensi.length,
      'weeklyHadir': weeklyHadir,
      'weeklyTerlambat': weeklyTerlambat,
      'weeklyPersentase': weeklyPresensi.isNotEmpty
          ? ((weeklyHadir + weeklyTerlambat) / weeklyPresensi.length * 100)
                .round()
          : 0,
      'monthlyTotal': monthlyPresensi.length,
      'monthlyHadir': monthlyHadir,
      'monthlyTerlambat': monthlyTerlambat,
      'monthlyPersentase': monthlyPresensi.isNotEmpty
          ? ((monthlyHadir + monthlyTerlambat) / monthlyPresensi.length * 100)
                .round()
          : 0,
    };
  } catch (e) {
    return {};
  }
});

/// Provider untuk notifikasi real-time
final notificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) {
    return Stream.value([]);
  }

  // Kombinasi notifikasi dari berbagai sumber
  return Stream.periodic(const Duration(minutes: 5), (index) async {
    try {
      List<Map<String, dynamic>> notifications = [];

      // Notifikasi pengumuman penting
      final recentPengumuman =
          await FirestoreService.getRecentPengumuman().first;
      for (final pengumuman in recentPengumuman.take(2)) {
        if (pengumuman.isPenting) {
          notifications.add({
            'type': 'pengumuman',
            'title': 'Pengumuman Penting',
            'message': pengumuman.judul,
            'time': pengumuman.formattedTanggal,
            'icon': Icons.campaign,
            'color': Colors.red,
          });
        }
      }

      // Notifikasi kegiatan hari ini
      final upcomingKegiatan =
          await FirestoreService.getUpcomingKegiatan().first;
      for (final kegiatan in upcomingKegiatan) {
        if (kegiatan.isToday) {
          notifications.add({
            'type': 'kegiatan',
            'title': 'Kegiatan Hari Ini',
            'message': kegiatan.namaKegiatan,
            'time': kegiatan.formattedWaktu,
            'icon': Icons.event,
            'color': Colors.blue,
          });
        }
      }

      return notifications;
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }).asyncMap((future) => future);
});

/// Provider untuk rank user di leaderboard
final userRankProvider = FutureProvider<int?>((ref) async {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) return null;

  try {
    final leaderboard = await FirestoreService.getLeaderboard().first;
    final userIndex = leaderboard.indexWhere(
      (item) => item.userId == currentUser.uid,
    );
    return userIndex >= 0 ? userIndex + 1 : null;
  } catch (e) {
    return null;
  }
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

    final dashboardData = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Notifikasi button dengan badge
          Consumer(
            builder: (context, ref, child) {
              final notificationsAsync = ref.watch(notificationsProvider);
              return notificationsAsync.when(
                loading: () => IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                error: (error, stack) => IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                data: (notifications) => Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        _showNotificationsDialog(context, notifications);
                      },
                    ),
                    if (notifications.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${notifications.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
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
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat dashboard...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Terjadi kesalahan',
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
                onPressed: () {
                  ref.invalidate(dashboardUserProvider);
                  ref.invalidate(todayPresensiProvider);
                  ref.invalidate(upcomingKegiatanProvider);
                  ref.invalidate(recentPengumumanProvider);
                  ref.invalidate(userStatsProvider);
                  ref.invalidate(notificationsProvider);
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (data) => _buildDashboardContent(context, data, ref),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    Map<String, dynamic> data,
    WidgetRef ref,
  ) {
    final user = data['user'] as UserModel?;
    final todayPresensi = data['todayPresensi'] as PresensiModel?;
    final upcomingKegiatan =
        data['upcomingKegiatan'] as List<JadwalKegiatanModel>? ?? [];
    final recentPengumuman =
        data['recentPengumuman'] as List<PengumumanModel>? ?? [];

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh semua data dengan invalidate providers
        ref.invalidate(dashboardUserProvider);
        ref.invalidate(todayPresensiProvider);
        ref.invalidate(upcomingKegiatanProvider);
        ref.invalidate(recentPengumumanProvider);
        ref.invalidate(userStatsProvider);
        ref.invalidate(notificationsProvider);
        ref.invalidate(userRankProvider);

        // Tunggu sebentar untuk memastikan data ter-refresh
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(user),

            const SizedBox(height: 16),

            // Notifikasi Section
            _buildNotificationsSection(ref),

            const SizedBox(height: 20),

            // Stats Cards Row
            _buildStatsCards(user, todayPresensi),

            const SizedBox(height: 20),

            // Additional Stats from Firestore
            _buildAdditionalStats(ref),

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

  Widget _buildNotificationsSection(WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (notifications) {
        if (notifications.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (notification['color'] as Color).withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (notification['color'] as Color).withOpacity(
                            0.3,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            notification['icon'] as IconData,
                            color: notification['color'] as Color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  notification['title'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: notification['color'] as Color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  notification['message'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(UserModel? user, PresensiModel? todayPresensi) {
    // Fungsi helper untuk format status
    String getStatusLabel(String? status) {
      switch (status) {
        case 'hadir':
          return 'Hadir';
        case 'terlambat':
          return 'Terlambat';
        case 'alpha':
          return 'Alpha';
        default:
          return 'Belum';
      }
    }

    Color getStatusColor(String? status) {
      switch (status) {
        case 'hadir':
          return Colors.green;
        case 'terlambat':
          return Colors.orange;
        case 'alpha':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.today,
            title: 'Presensi Hari Ini',
            value: getStatusLabel(todayPresensi?.status),
            color: getStatusColor(todayPresensi?.status),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              fontSize: 11,
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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

  Widget _buildAdditionalStats(WidgetRef ref) {
    final userStatsAsync = ref.watch(userStatsProvider);

    return userStatsAsync.when(
      loading: () => Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
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
                  const Icon(
                    Icons.analytics,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Statistik Kehadiran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(
                      'Minggu Ini',
                      '${stats['weeklyPersentase']}%',
                      '${stats['weeklyHadir']}/${stats['weeklyTotal']} hadir',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStatCard(
                      'Bulan Ini',
                      '${stats['monthlyPersentase']}%',
                      '${stats['monthlyHadir']}/${stats['monthlyTotal']} hadir',
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Menampilkan dialog notifikasi
  void _showNotificationsDialog(
    BuildContext context,
    List<Map<String, dynamic>> notifications,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Notifikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: notifications.isEmpty
            ? const Text('Tidak ada notifikasi')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (notification['color'] as Color).withOpacity(
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          notification['icon'] as IconData,
                          color: notification['color'] as Color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notification['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notification['message'] as String,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['time'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/materi_service.dart';
import '../../../shared/services/progress_santri_service.dart';
import 'manual_attendance_page.dart';
import 'schedule_management_page.dart';
import 'announcement_management_page.dart';
import 'materi_management_page.dart';

/// Provider untuk statistics admin dashboard
final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Get total users by role
    final usersSnapshot = await firestore.collection('users').get();
    final users = usersSnapshot.docs
        .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();

    final santriCount = users.where((u) => u.isSantri).length;
    final guruCount = users.where((u) => u.isDewaGuru).length;
    final adminCount = users.where((u) => u.isAdmin).length;

    // Get today's attendance
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final attendanceSnapshot = await firestore
        .collection('presensi')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final todayAttendance = attendanceSnapshot.docs.length;
    final attendanceRate = santriCount > 0
        ? (todayAttendance / santriCount * 100)
        : 0.0;

    // Get recent activities
    final activitiesSnapshot = await firestore
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    final recentActivities = activitiesSnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();

    return {
      'totalSantri': santriCount,
      'totalGuru': guruCount,
      'totalAdmin': adminCount,
      'totalUsers': users.length,
      'todayAttendance': todayAttendance,
      'attendanceRate': attendanceRate,
      'recentActivities': recentActivities,
    };
  } catch (e) {
    throw Exception('Error loading admin stats: $e');
  }
});

/// Admin Dashboard Page dengan fitur lengkap
class AdminDashboardPage extends ConsumerWidget {
  final UserModel admin;

  const AdminDashboardPage({super.key, required this.admin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminStatsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 16),

              // Statistics cards
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorCard(error.toString()),
                data: (stats) => Column(
                  children: [
                    _buildStatsCards(stats),
                    const SizedBox(height: 16),
                    _buildQuickActionsSection(context),
                    const SizedBox(height: 16),
                    _buildManagementSection(context),
                    const SizedBox(height: 16),
                    _buildRecentActivities(stats['recentActivities'] as List),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang, ${admin.nama}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Administrator SiSantri',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Kelola seluruh aspek pondok pesantren dari satu tempat. Pantau presensi, atur jadwal, dan kelola pengumuman dengan mudah.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Santri',
          stats['totalSantri'].toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Dewan Guru',
          stats['totalGuru'].toString(),
          Icons.person_outline,
          Colors.green,
        ),
        _buildStatCard(
          'Presensi Hari Ini',
          stats['todayAttendance'].toString(),
          Icons.check_circle_outline,
          Colors.orange,
        ),
        _buildStatCard(
          'Tingkat Kehadiran',
          '${stats['attendanceRate'].toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
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
                Icon(Icons.flash_on, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Aksi Cepat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Absen Manual',
                    Icons.how_to_reg,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManualAttendancePage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Buat Pengumuman',
                    Icons.campaign,
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AnnouncementManagementPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Kelola Materi',
                    Icons.menu_book,
                    Colors.teal,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MateriManagementPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Atur Jadwal',
                    Icons.event,
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScheduleManagementPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context) {
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
                Icon(Icons.settings, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Manajemen Sistem',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildManagementTile(
              'Kelola RFID',
              'Atur kartu RFID santri',
              Icons.contactless,
              Colors.blue,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Halaman manajemen RFID sedang dalam pengembangan',
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            _buildManagementTile(
              'Laporan Presensi',
              'Lihat dan export laporan kehadiran',
              Icons.analytics,
              Colors.green,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halaman laporan sedang dalam pengembangan'),
                  ),
                );
              },
            ),
            const Divider(),
            _buildManagementTile(
              'Manajemen User',
              'Kelola akun santri dan dewan guru',
              Icons.people_alt,
              Colors.orange,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Halaman manajemen user sedang dalam pengembangan',
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

  Widget _buildManagementTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildRecentActivities(List activities) {
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
                Icon(Icons.history, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Belum ada aktivitas terbaru',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...activities
                  .take(5)
                  .map((activity) => _buildActivityTile(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? 'Aktivitas',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  activity['description'] ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(activity['timestamp']),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading data: $error'),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime time;
    if (timestamp is Timestamp) {
      time = timestamp.toDate();
    } else if (timestamp is String) {
      time = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return '';
    }

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    return '${diff.inDays}h yang lalu';
  }

  void _showDummyDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Data Dummy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih jenis data dummy yang ingin dibuat:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.teal),
              title: const Text('Materi Kajian'),
              subtitle: const Text('9 materi (Quran, Hadist, Fiqih, dll)'),
              onTap: () {
                Navigator.pop(context);
                _createDummyMateri(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.orange),
              title: const Text('Progress Santri'),
              subtitle: const Text('15 progress dengan sesi kajian'),
              onTap: () {
                Navigator.pop(context);
                _createDummyProgress(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.green),
              title: const Text('Jadwal Kajian'),
              subtitle: const Text('11 jadwal dengan materi terintegrasi'),
              onTap: () {
                Navigator.pop(context);
                _createDummyJadwal(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _createDummyMateri(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Membuat dummy materi...'),
          backgroundColor: Colors.orange,
        ),
      );

      await MateriService.createDummyMateri();

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Dummy materi berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _createDummyProgress(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Membuat dummy progress...'),
          backgroundColor: Colors.orange,
        ),
      );

      await ProgressSantriService.createDummyProgress();

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Dummy progress berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _createDummyJadwal(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Membuat dummy jadwal...'),
          backgroundColor: Colors.orange,
        ),
      );

      // Gunakan service yang sudah ada untuk dummy jadwal
      // Untuk sementara gunakan dummy materi sebagai alternatif
      await MateriService.createDummyMateri();

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Dummy data berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

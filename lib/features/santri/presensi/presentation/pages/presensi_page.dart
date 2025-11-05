import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/shared/models/presensi_model.dart';
import 'package:sisantri/shared/services/auth_service.dart';
import 'package:sisantri/shared/services/presensi_service.dart';

/// Provider untuk presensi hari ini
final todayPresensiProvider = FutureProvider.family<PresensiModel?, String>((
  ref,
  userId,
) async {
  return PresensiService.getCurrentPresensi(userId);
});

/// Provider untuk riwayat presensi bulan ini menggunakan PresensiService
final presensiHistoryProvider =
    FutureProvider.family<List<PresensiModel>, String>((ref, userId) async {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      return PresensiService.getPresensiByPeriod(
        startDate: startOfMonth,
        endDate: endOfMonth,
        userId: userId,
      );
    });

/// Provider untuk statistik presensi bulan ini
final presensiStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final monthlyPresensi = await PresensiService.getPresensiByPeriod(
        startDate: startOfMonth,
        endDate: endOfMonth,
        userId: userId,
      );

      final totalHadir = monthlyPresensi
          .where((p) => p.status == StatusPresensi.hadir)
          .length;
      final totalSakit = monthlyPresensi
          .where((p) => p.status == StatusPresensi.sakit)
          .length;
      final totalIzin = monthlyPresensi
          .where((p) => p.status == StatusPresensi.izin)
          .length;
      final totalAlpha = monthlyPresensi
          .where((p) => p.status == StatusPresensi.alpha)
          .length;

      return {
        'totalHadir': totalHadir,
        'totalSakit': totalSakit,
        'totalIzin': totalIzin,
        'totalAlpha': totalAlpha,
        'totalKegiatan': monthlyPresensi.length,
        'persentaseKehadiran': monthlyPresensi.isEmpty
            ? 0.0
            : (totalHadir / monthlyPresensi.length) * 100,
      };
    });

/// Halaman Presensi - Data dari Sistem RFID IoT
class PresensiPage extends ConsumerWidget {
  const PresensiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = AuthService.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('User tidak ditemukan')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Presensi RFID'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayPresensiProvider);
          ref.invalidate(presensiHistoryProvider);
          ref.invalidate(presensiStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Statistik Presensi Bulan Ini
              _buildMonthlyStats(context, ref, currentUser.uid),

              const SizedBox(height: 24),

              // Riwayat Presensi dari RFID
              _buildPresensiHistory(context, ref, currentUser.uid),
            ],
          ),
        ),
      ),
    );
  }

  /// Statistik presensi bulan ini
  Widget _buildMonthlyStats(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final stats = ref.watch(presensiStatsProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.analytics, color: AppTheme.primaryColor, size: 20),
            SizedBox(width: 8),
            Text(
              'Statistik Bulan Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        stats.when(
          loading: () => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
          data: (statsData) {
            final persentase = statsData['persentaseKehadiran'] as double;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Column(
                children: [
                  // Persentase Kehadiran
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${persentase.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Text(
                          'Tingkat Kehadiran',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Detail Statistik
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Hadir',
                          statsData['totalHadir'].toString(),
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          'Sakit',
                          statsData['totalSakit'].toString(),
                          Colors.orange,
                          Icons.local_hospital,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Izin',
                          statsData['totalIzin'].toString(),
                          Colors.blue,
                          Icons.event_available,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          'Alpha',
                          statsData['totalAlpha'].toString(),
                          Colors.red,
                          Icons.cancel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Riwayat presensi
  Widget _buildPresensiHistory(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final presensiHistory = ref.watch(presensiHistoryProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history, color: AppTheme.primaryColor, size: 20),
            SizedBox(width: 8),
            Text(
              'Riwayat Presensi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        presensiHistory.when(
          loading: () => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          data: (presensiList) {
            if (presensiList.isEmpty) {
              return Container(
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
                          Icons.history_outlined,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada riwayat presensi bulan ini',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: presensiList.length > 10 ? 10 : presensiList.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final presensi = presensiList[index];
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: presensi.status.color.withAlpha(15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: presensi.status.color.withAlpha(50),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          presensi.status.icon,
                          color: presensi.status.color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  presensi.status.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: presensi.status.color,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.green.withAlpha(50),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.contactless,
                                        color: Colors.green,
                                        size: 10,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'RFID',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              presensi.timestamp != null
                                  ? '${DateFormat('dd MMM yyyy').format(presensi.timestamp!)} • ${DateFormat('HH:mm').format(presensi.timestamp!)}'
                                  : 'Tanggal tidak tersedia',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (presensi.keterangan.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                presensi.keterangan,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

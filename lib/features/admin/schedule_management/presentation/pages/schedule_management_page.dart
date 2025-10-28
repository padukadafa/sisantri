import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/features/admin/schedule_management/presentation/models/jadwal_kegiatan_model.dart';
import 'package:sisantri/shared/helpers/messaging_helper.dart';
import 'package:sisantri/shared/models/jadwal_model.dart';
import 'package:sisantri/shared/services/attendance_service.dart';
import 'add_edit_jadwal_page.dart';

final jadwalProvider = StreamProvider<List<JadwalKegiatan>>((ref) {
  return FirebaseFirestore.instance
      .collection('jadwal')
      .orderBy('tanggal', descending: false)
      .orderBy('waktuMulai')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => JadwalKegiatan.fromJson(doc.id, doc.data()))
            .toList();
      });
});

enum ScheduleFilter {
  futureOnly, // Mendatang saja (dari hari ini)
  thisMonthAndFuture, // Bulan ini dan mendatang
  lastMonth, // 1 bulan terakhir
  last3Months, // 3 bulan terakhir
  all, // Semua jadwal
}

final scheduleFilterProvider = StateProvider<ScheduleFilter>(
  (ref) => ScheduleFilter.futureOnly,
);

class ScheduleManagementPage extends ConsumerWidget {
  const ScheduleManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalAsync = ref.watch(jadwalProvider);
    final scheduleFilter = ref.watch(scheduleFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Jadwal'),
        actions: [
          PopupMenuButton<ScheduleFilter>(
            icon: Icon(
              Icons.filter_list,
              color: scheduleFilter != ScheduleFilter.futureOnly
                  ? AppTheme.primaryColor
                  : null,
            ),
            tooltip: 'Filter Jadwal',
            onSelected: (value) {
              ref.read(scheduleFilterProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ScheduleFilter.futureOnly,
                child: Row(
                  children: [
                    Icon(
                      scheduleFilter == ScheduleFilter.futureOnly
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 18,
                      color: scheduleFilter == ScheduleFilter.futureOnly
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Mendatang Saja'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ScheduleFilter.thisMonthAndFuture,
                child: Row(
                  children: [
                    Icon(
                      scheduleFilter == ScheduleFilter.thisMonthAndFuture
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 18,
                      color: scheduleFilter == ScheduleFilter.thisMonthAndFuture
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Bulan Ini & Mendatang'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ScheduleFilter.lastMonth,
                child: Row(
                  children: [
                    Icon(
                      scheduleFilter == ScheduleFilter.lastMonth
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 18,
                      color: scheduleFilter == ScheduleFilter.lastMonth
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text('1 Bulan Terakhir'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ScheduleFilter.last3Months,
                child: Row(
                  children: [
                    Icon(
                      scheduleFilter == ScheduleFilter.last3Months
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 18,
                      color: scheduleFilter == ScheduleFilter.last3Months
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text('3 Bulan Terakhir'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ScheduleFilter.all,
                child: Row(
                  children: [
                    Icon(
                      scheduleFilter == ScheduleFilter.all
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 18,
                      color: scheduleFilter == ScheduleFilter.all
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Semua Jadwal'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _showAddEditDialog(context, ref),
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Kegiatan Baru',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(jadwalProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: jadwalAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorView(ref, jadwalProvider),
          data: (jadwalList) => _buildJadwalView(context, ref, jadwalList),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, ref),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildJadwalView(
    BuildContext context,
    WidgetRef ref,
    List<JadwalKegiatan> jadwalList,
  ) {
    final scheduleFilter = ref.watch(scheduleFilterProvider);

    // Filter jadwal berdasarkan rentang waktu yang dipilih
    final now = DateTime.now();

    List<JadwalKegiatan> filteredJadwalList;

    switch (scheduleFilter) {
      case ScheduleFilter.futureOnly:
        // Tampilkan jadwal dari hari ini dan ke depan
        final today = DateTime(now.year, now.month, now.day);
        filteredJadwalList = jadwalList.where((jadwal) {
          final jadwalDate = DateTime(
            jadwal.tanggal.year,
            jadwal.tanggal.month,
            jadwal.tanggal.day,
          );
          return jadwalDate.isAtSameMomentAs(today) ||
              jadwalDate.isAfter(today);
        }).toList();
        break;

      case ScheduleFilter.thisMonthAndFuture:
        // Tampilkan jadwal dari awal bulan ini dan ke depan
        final startOfMonth = DateTime(now.year, now.month, 1);
        filteredJadwalList = jadwalList.where((jadwal) {
          final jadwalDate = DateTime(
            jadwal.tanggal.year,
            jadwal.tanggal.month,
            jadwal.tanggal.day,
          );
          return jadwalDate.isAtSameMomentAs(startOfMonth) ||
              jadwalDate.isAfter(startOfMonth);
        }).toList();
        break;

      case ScheduleFilter.lastMonth:
        // Tampilkan jadwal 1 bulan terakhir
        final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
        filteredJadwalList = jadwalList.where((jadwal) {
          final jadwalDate = DateTime(
            jadwal.tanggal.year,
            jadwal.tanggal.month,
            jadwal.tanggal.day,
          );
          return jadwalDate.isAtSameMomentAs(oneMonthAgo) ||
              jadwalDate.isAfter(oneMonthAgo);
        }).toList();
        break;

      case ScheduleFilter.last3Months:
        // Tampilkan jadwal 3 bulan terakhir
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        filteredJadwalList = jadwalList.where((jadwal) {
          final jadwalDate = DateTime(
            jadwal.tanggal.year,
            jadwal.tanggal.month,
            jadwal.tanggal.day,
          );
          return jadwalDate.isAtSameMomentAs(threeMonthsAgo) ||
              jadwalDate.isAfter(threeMonthsAgo);
        }).toList();
        break;

      case ScheduleFilter.all:
        // Tampilkan semua jadwal
        filteredJadwalList = jadwalList;
        break;
    }

    if (filteredJadwalList.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _getEmptyStateTitle(scheduleFilter),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyStateMessage(scheduleFilter, jadwalList.isNotEmpty),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (scheduleFilter != ScheduleFilter.all &&
                    jadwalList.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(scheduleFilterProvider.notifier).state =
                          ScheduleFilter.all;
                    },
                    icon: const Icon(Icons.all_inclusive),
                    label: const Text('Lihat Semua Jadwal'),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Kegiatan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final groupedJadwal = <String, List<JadwalKegiatan>>{};

    for (final jadwal in filteredJadwalList) {
      final dateKey = _formatDateKey(jadwal.tanggal);
      groupedJadwal.putIfAbsent(dateKey, () => []);
      groupedJadwal[dateKey]!.add(jadwal);
    }

    // Sort groups by date
    final sortedKeys = groupedJadwal.keys.toList()
      ..sort((a, b) {
        final dateA = _parseDateKey(a);
        final dateB = _parseDateKey(b);
        return dateA.compareTo(dateB);
      });

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateIndex = index;
        final dateKey = sortedKeys[dateIndex];
        final jadwalHari = groupedJadwal[dateKey]!;
        final date = _parseDateKey(dateKey);

        jadwalHari.sort((a, b) {
          final aMinutes = a.waktuMulai.hour * 60 + a.waktuMulai.minute;
          final bMinutes = b.waktuMulai.hour * 60 + b.waktuMulai.minute;
          return aMinutes.compareTo(bMinutes);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              margin: EdgeInsets.only(bottom: 12, top: dateIndex == 0 ? 0 : 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isToday(date)
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isToday(date)
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isToday(date) ? Icons.today : Icons.calendar_today,
                    size: 16,
                    color: _isToday(date)
                        ? AppTheme.primaryColor
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateHeader(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isToday(date)
                          ? AppTheme.primaryColor
                          : Colors.grey[700],
                    ),
                  ),
                  if (_isToday(date)) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HARI INI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${jadwalHari.length} kegiatan',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Activities for this date
            ...jadwalHari.map(
              (jadwal) => _buildJadwalCard(context, ref, jadwal),
            ),
          ],
        );
      },
    );
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _parseDateKey(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  String _getEmptyStateTitle(ScheduleFilter filter) {
    switch (filter) {
      case ScheduleFilter.futureOnly:
        return 'Belum ada kegiatan yang akan datang';
      case ScheduleFilter.thisMonthAndFuture:
        return 'Belum ada kegiatan bulan ini';
      case ScheduleFilter.lastMonth:
        return 'Tidak ada kegiatan dalam 1 bulan terakhir';
      case ScheduleFilter.last3Months:
        return 'Tidak ada kegiatan dalam 3 bulan terakhir';
      case ScheduleFilter.all:
        return 'Belum ada kegiatan terjadwal';
    }
  }

  String _getEmptyStateMessage(ScheduleFilter filter, bool hasOtherSchedules) {
    if (!hasOtherSchedules) {
      return 'Tambahkan kegiatan baru untuk memulai';
    }

    switch (filter) {
      case ScheduleFilter.futureOnly:
        return 'Tidak ada jadwal yang akan datang.\nSemua jadwal sudah lewat atau belum ada jadwal.';
      case ScheduleFilter.thisMonthAndFuture:
        return 'Tidak ada jadwal untuk bulan ini dan mendatang.\nLihat semua jadwal untuk melihat jadwal sebelumnya.';
      case ScheduleFilter.lastMonth:
        return 'Tidak ada jadwal dalam rentang 1 bulan terakhir.\nCoba filter lain atau lihat semua jadwal.';
      case ScheduleFilter.last3Months:
        return 'Tidak ada jadwal dalam rentang 3 bulan terakhir.\nCoba filter lain atau lihat semua jadwal.';
      case ScheduleFilter.all:
        return 'Tambahkan kegiatan baru untuk memulai';
    }
  }

  String _getFilterInfoText(ScheduleFilter filter) {
    switch (filter) {
      case ScheduleFilter.futureOnly:
        return 'Menampilkan jadwal hari ini dan mendatang';
      case ScheduleFilter.thisMonthAndFuture:
        return 'Menampilkan jadwal bulan ini dan mendatang';
      case ScheduleFilter.lastMonth:
        return 'Menampilkan jadwal 1 bulan terakhir';
      case ScheduleFilter.last3Months:
        return 'Menampilkan jadwal 3 bulan terakhir';
      case ScheduleFilter.all:
        return 'Menampilkan semua jadwal';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final yesterday = now.subtract(const Duration(days: 1));

    if (_isToday(date)) {
      return 'Hari Ini, ${_formatDate(date)}';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Besok, ${_formatDate(date)}';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Kemarin, ${_formatDate(date)}';
    } else {
      return _formatDate(date);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildErrorView(WidgetRef ref, provider) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(provider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: constraints.maxHeight > 400 ? constraints.maxHeight : 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text('Terjadi kesalahan saat memuat data'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(provider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJadwalCard(
    BuildContext context,
    WidgetRef ref,
    JadwalKegiatan jadwal,
  ) {
    final kategoriColor = _getKategoriColor(jadwal.kategori);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: jadwal.kategori == TipeJadwal.libur ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: jadwal.kategori == TipeJadwal.libur
          ? Colors.green.withOpacity(0.05)
          : null,
      child: InkWell(
        onTap: () => _showAddEditDialog(context, ref, jadwal: jadwal),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: jadwal.kategori == TipeJadwal.libur
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kategoriColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: kategoriColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getKategoriDisplayName(jadwal.kategori),
                        style: TextStyle(
                          color: kategoriColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: jadwal.isAktif,
                      onChanged: (value) =>
                          _toggleActiveStatus(ref, jadwal, value),
                      activeColor: AppTheme.primaryColor,
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showAddEditDialog(context, ref, jadwal: jadwal);
                            break;
                          case 'duplicate':
                            _duplicateJadwal(ref, jadwal);
                            break;
                          case 'delete':
                            _deleteJadwal(context, ref, jadwal);
                            break;
                          case 'notify':
                            _sendNotification(jadwal);
                            break;
                          case 'convert_to_libur':
                            _convertToLibur(context, ref, jadwal);
                            break;
                          case 'restore_activity':
                            _restoreFromLibur(context, ref, jadwal);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy, size: 16),
                              SizedBox(width: 8),
                              Text('Duplikasi'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'notify',
                          child: Row(
                            children: [
                              Icon(Icons.notifications, size: 16),
                              SizedBox(width: 8),
                              Text('Kirim Notifikasi'),
                            ],
                          ),
                        ),
                        if (jadwal.kategori != TipeJadwal.libur)
                          const PopupMenuItem(
                            value: 'convert_to_libur',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.free_breakfast,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Ubah ke Libur',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                        if (jadwal.kategori == TipeJadwal.libur)
                          const PopupMenuItem(
                            value: 'restore_activity',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.restore,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Kembalikan ke Kegiatan',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  jadwal.nama,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: jadwal.kategori == TipeJadwal.libur
                        ? Colors.green[700]
                        : null,
                  ),
                ),
                if (jadwal.deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    jadwal.deskripsi,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontStyle: jadwal.kategori == TipeJadwal.libur
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
                if (jadwal.materiNama != null &&
                    jadwal.kategori != TipeJadwal.libur) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 14,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          jadwal.materiNama!,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Display informasi kajian (halaman/ayat)
                if (jadwal.kategori == TipeJadwal.kajian &&
                    (jadwal.surah != null || jadwal.halamanMulai != null)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          jadwal.surah != null ? Icons.book : Icons.article,
                          size: 14,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getKajianInfo(jadwal),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Special indicator for libur (break time)
                if (jadwal.kategori == TipeJadwal.libur) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.free_breakfast,
                          size: 14,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'WAKTU LIBUR',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      jadwal.kategori == TipeJadwal.libur
                          ? Icons.free_breakfast
                          : Icons.access_time,
                      size: 16,
                      color: jadwal.kategori == TipeJadwal.libur
                          ? Colors.green[600]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(jadwal.waktuMulai)} - ${_formatTime(jadwal.waktuSelesai)}',
                      style: TextStyle(
                        color: jadwal.kategori == TipeJadwal.libur
                            ? Colors.green[600]
                            : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: jadwal.kategori == TipeJadwal.libur
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        jadwal.tempat,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getKategoriColor(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.kajian:
        return Colors.blue;
      case TipeJadwal.tahfidz:
        return Colors.purple;
      case TipeJadwal.kerjaBakti:
        return Colors.orange;
      case TipeJadwal.olahraga:
        return Colors.red;
      case TipeJadwal.pengajian:
        return Colors.green;
      case TipeJadwal.libur:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showAddEditDialog(
    BuildContext context,
    WidgetRef ref, {
    JadwalKegiatan? jadwal,
    String? preselectedDay,
    String? jenisJadwal,
  }) async {
    final result = await Navigator.push<JadwalKegiatan>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditJadwalPage(
          jadwal: jadwal,
          preselectedDay: preselectedDay,
          jenisJadwal: jenisJadwal,
        ),
      ),
    );

    if (result != null) {
      ref.invalidate(jadwalProvider);
    }
  }

  Future<void> _addJadwal(WidgetRef ref, JadwalKegiatan jadwal) async {
    try {
      // Step 1: Save jadwal to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('jadwal')
          .add(jadwal.toJson());

      // Step 2: Generate default attendance records for all active santri
      // Only generate for non-libur activities
      if (jadwal.kategori != TipeJadwal.libur) {
        await AttendanceService.generateDefaultAttendanceForJadwal(
          jadwalId: docRef.id,
          createdBy: 'admin', // TODO: get from current user
          createdByName: 'Admin', // TODO: get from current user
        );
      }

      // Step 3: Send notification about new schedule
      await MessagingHelper.sendPengumumanToSantri(
        title: 'Jadwal Baru Ditambahkan',
        message:
            '${jadwal.nama} - ${_formatDate(jadwal.tanggal)} ${_formatTime(jadwal.waktuMulai)} di ${jadwal.tempat}',
      );
    } catch (e) {
      // Error adding jadwal
    }
  }

  Future<void> _toggleActiveStatus(
    WidgetRef ref,
    JadwalKegiatan jadwal,
    bool isAktif,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('jadwal')
          .doc(jadwal.id)
          .update({'isAktif': isAktif});
    } catch (e) {
      // Error toggling active status
    }
  }

  Future<void> _duplicateJadwal(WidgetRef ref, JadwalKegiatan jadwal) async {
    final newJadwal = JadwalKegiatan(
      id: '',
      nama: '${jadwal.nama} (Copy)',
      deskripsi: jadwal.deskripsi,
      tanggal: jadwal.tanggal,
      waktuMulai: jadwal.waktuMulai,
      waktuSelesai: jadwal.waktuSelesai,
      tempat: jadwal.tempat,
      kategori: jadwal.kategori,
      materiId: jadwal.materiId,
      materiNama: jadwal.materiNama,
      surah: jadwal.surah,
      ayatMulai: jadwal.ayatMulai,
      ayatSelesai: jadwal.ayatSelesai,
      halamanMulai: jadwal.halamanMulai,
      halamanSelesai: jadwal.halamanSelesai,
      catatan: jadwal.catatan,
      isAktif: true,
      createdAt: DateTime.now(),
    );

    await _addJadwal(ref, newJadwal); // This will handle attendance generation
  }

  Future<void> _deleteJadwal(
    BuildContext context,
    WidgetRef ref,
    JadwalKegiatan jadwal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal "${jadwal.nama}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('jadwal')
            .doc(jadwal.id)
            .delete();
      } catch (e) {
        // Error deleting jadwal
      }
    }
  }

  Future<void> _convertToLibur(
    BuildContext context,
    WidgetRef ref,
    JadwalKegiatan jadwal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah ke Libur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin mengubah "${jadwal.nama}" menjadi waktu libur?',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Perubahan ini akan:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('â€¢ Mengubah kategori menjadi "LIBUR"'),
                  const Text('â€¢ Menghilangkan materi yang terkait'),
                  const Text('â€¢ Mengubah nama menjadi "Libur"'),
                  const Text('â€¢ Memberikan notifikasi pembatalan'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text(
              'Ya, Ubah ke Libur',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Backup original data
        final originalData = {
          'nama_asli': jadwal.nama,
          'kategori_asli': jadwal.kategori,
          'materi_id_asli': jadwal.materiId,
          'materi_nama_asli': jadwal.materiNama,
          'deskripsi_asli': jadwal.deskripsi,
        };

        // Update to libur
        await FirebaseFirestore.instance
            .collection('jadwal')
            .doc(jadwal.id)
            .update({
              'nama': 'Libur',
              'kategori': TipeJadwal.libur.value,
              'materiId': null,
              'materiNama': null,
              'deskripsi': 'Kegiatan diliburkan',
              'backup_data':
                  originalData, // Store original data for restoration
            });

        // Send cancellation notification
        await MessagingHelper.sendPengumumanToSantri(
          title: 'Kegiatan Diliburkan',
          message:
              '${jadwal.nama} pada ${_formatDate(jadwal.tanggal)} ${_formatTime(jadwal.waktuMulai)} telah diliburkan.',
        );

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jadwal berhasil diubah ke libur'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Error converting to libur
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengubah jadwal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _restoreFromLibur(
    BuildContext context,
    WidgetRef ref,
    JadwalKegiatan jadwal,
  ) async {
    try {
      // Get backup data
      final doc = await FirebaseFirestore.instance
          .collection('jadwal')
          .doc(jadwal.id)
          .get();

      final data = doc.data();
      final backupData = data?['backup_data'] as Map<String, dynamic>?;

      if (backupData == null) {
        // No backup data, show manual edit dialog
        if (context.mounted) {
          final shouldEdit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Kembalikan ke Kegiatan'),
              content: const Text(
                'Data asli kegiatan tidak ditemukan. Apakah Anda ingin mengedit manual untuk mengubah kembali ke kegiatan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Edit Manual'),
                ),
              ],
            ),
          );

          if (shouldEdit == true) {
            _showAddEditDialog(context, ref, jadwal: jadwal);
          }
        }
        return;
      }

      // Confirm restoration
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kembalikan ke Kegiatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kegiatan akan dikembalikan ke:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama: ${backupData['nama_asli'] ?? 'Tidak ada'}'),
                    Text(
                      'Kategori: ${backupData['kategori_asli'] ?? 'Tidak ada'}',
                    ),
                    if (backupData['materi_nama_asli'] != null)
                      Text('Materi: ${backupData['materi_nama_asli']}'),
                    if (backupData['deskripsi_asli'] != null &&
                        backupData['deskripsi_asli'].toString().isNotEmpty)
                      Text('Deskripsi: ${backupData['deskripsi_asli']}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                'Ya, Kembalikan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Restore original data
        await FirebaseFirestore.instance
            .collection('jadwal')
            .doc(jadwal.id)
            .update({
              'nama': backupData['nama_asli'],
              'kategori': backupData['kategori_asli'],
              'materiId': backupData['materi_id_asli'],
              'materiNama': backupData['materi_nama_asli'],
              'deskripsi': backupData['deskripsi_asli'] ?? '',
              'backup_data': FieldValue.delete(), // Remove backup data
            });

        // Generate default attendance for restored activity
        try {
          await AttendanceService.generateDefaultAttendanceForJadwal(
            jadwalId: jadwal.id,
            createdBy: 'admin', // TODO: get from current user
            createdByName: 'Admin', // TODO: get from current user
          );
        } catch (e) {
          // Error generating attendance for restored activity
        }

        // Send restoration notification
        await MessagingHelper.sendPengumumanToSantri(
          title: 'Kegiatan Dikembalikan',
          message:
              '${backupData['nama_asli']} pada ${_formatDate(jadwal.tanggal)} ${_formatTime(jadwal.waktuMulai)} telah dikembalikan.',
        );

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kegiatan berhasil dikembalikan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Error restoring from libur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengembalikan kegiatan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendNotification(JadwalKegiatan jadwal) async {
    try {
      await MessagingHelper.sendKegiatanReminderToSantri(
        kegiatanName: jadwal.nama,
        waktu: DateTime.now().add(
          const Duration(minutes: 15),
        ), // 15 minutes from now
        tempat: jadwal.tempat,
      );
    } catch (e) {
      // Error sending notification
    }
  }

  String _getKajianInfo(JadwalKegiatan jadwal) {
    if (jadwal.surah != null) {
      // Untuk kajian Quran
      String info = 'Surah ${jadwal.surah}';
      if (jadwal.ayatMulai != null) {
        if (jadwal.ayatSelesai != null &&
            jadwal.ayatSelesai != jadwal.ayatMulai) {
          info += ' ayat ${jadwal.ayatMulai}-${jadwal.ayatSelesai}';
        } else {
          info += ' ayat ${jadwal.ayatMulai}';
        }
      }
      return info;
    } else if (jadwal.halamanMulai != null) {
      // Untuk kajian kitab
      if (jadwal.halamanSelesai != null &&
          jadwal.halamanSelesai != jadwal.halamanMulai) {
        return 'Halaman ${jadwal.halamanMulai}-${jadwal.halamanSelesai}';
      } else {
        return 'Halaman ${jadwal.halamanMulai}';
      }
    }
    return '';
  }

  String _getKategoriDisplayName(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.kajian:
        return 'KAJIAN';
      case TipeJadwal.tahfidz:
        return 'TAHFIDZ';
      case TipeJadwal.kerjaBakti:
        return 'KERJA BAKTI';
      case TipeJadwal.olahraga:
        return 'OLAHRAGA';
      case TipeJadwal.libur:
        return 'LIBUR';
      case TipeJadwal.pengajian:
        return 'PENGAJIAN';
      case TipeJadwal.kegiatan:
        return 'KEGIATAN';
      case TipeJadwal.umum:
        return 'UMUM';
    }
  }
}

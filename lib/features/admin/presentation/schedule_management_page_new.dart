import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/shared/models/jadwal_model.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/helpers/messaging_helper.dart';
import '../../../shared/providers/materi_provider.dart';
import '../../../shared/services/attendance_service.dart';

/// Model untuk jadwal kegiatan (disederhanakan)
class JadwalKegiatan {
  final String id;
  final String nama;
  final String deskripsi;
  final DateTime tanggal; // Semua jadwal menggunakan tanggal spesifik
  final TimeOfDay waktuMulai;
  final TimeOfDay waktuSelesai;
  final String tempat;
  final String kategori;
  final String? materiId;
  final String? materiNama;
  final bool isAktif;
  final DateTime createdAt;

  JadwalKegiatan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.tempat,
    required this.kategori,
    this.materiId,
    this.materiNama,
    this.isAktif = true,
    required this.createdAt,
  });

  factory JadwalKegiatan.fromJson(String id, Map<String, dynamic> json) {
    return JadwalKegiatan(
      id: id,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tanggal: (json['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      waktuMulai: _timeFromString(json['waktuMulai'] ?? '00:00'),
      waktuSelesai: _timeFromString(json['waktuSelesai'] ?? '00:00'),
      tempat: json['tempat'] ?? '',
      kategori: json['kategori'] ?? 'umum',
      materiId: json['materiId'],
      materiNama: json['materiNama'],
      isAktif: json['isAktif'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'tanggal': Timestamp.fromDate(tanggal),
      'waktuMulai':
          '${waktuMulai.hour.toString().padLeft(2, '0')}:${waktuMulai.minute.toString().padLeft(2, '0')}',
      'waktuSelesai':
          '${waktuSelesai.hour.toString().padLeft(2, '0')}:${waktuSelesai.minute.toString().padLeft(2, '0')}',
      'tempat': tempat,
      'kategori': kategori,
      if (materiId != null) 'materiId': materiId,
      if (materiNama != null) 'materiNama': materiNama,
      'isAktif': isAktif,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static TimeOfDay _timeFromString(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }
}

/// Provider untuk semua jadwal
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

/// Halaman manajemen jadwal yang disederhanakan
class ScheduleManagementPage extends ConsumerWidget {
  const ScheduleManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalAsync = ref.watch(jadwalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Jadwal'),
        actions: [
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
          error: (error, stack) => _buildErrorView(ref),
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

  Widget _buildErrorView(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Terjadi kesalahan saat memuat data'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(jadwalProvider),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalView(
    BuildContext context,
    WidgetRef ref,
    List<JadwalKegiatan> jadwalList,
  ) {
    if (jadwalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada kegiatan terjadwal',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan kegiatan baru untuk memulai',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 16),
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
      );
    }

    // Group jadwal by date
    final groupedJadwal = <String, List<JadwalKegiatan>>{};

    for (final jadwal in jadwalList) {
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
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final jadwalHari = groupedJadwal[dateKey]!;
        final date = _parseDateKey(dateKey);

        // Sort activities by time within each day
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
              margin: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 24),
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

  Widget _buildJadwalCard(
    BuildContext context,
    WidgetRef ref,
    JadwalKegiatan jadwal,
  ) {
    final kategoriColor = _getKategoriColor(jadwal.kategori);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: jadwal.kategori.toLowerCase() == 'libur' ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: jadwal.kategori.toLowerCase() == 'libur'
          ? Colors.green.withOpacity(0.05)
          : null,
      child: InkWell(
        onTap: () => _showAddEditDialog(context, ref, jadwal: jadwal),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: jadwal.kategori.toLowerCase() == 'libur'
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
                        jadwal.kategori.toUpperCase(),
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
                        if (jadwal.kategori.toLowerCase() != 'libur')
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
                        if (jadwal.kategori.toLowerCase() == 'libur')
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
                    color: jadwal.kategori.toLowerCase() == 'libur'
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
                      fontStyle: jadwal.kategori.toLowerCase() == 'libur'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
                if (jadwal.materiNama != null &&
                    jadwal.kategori.toLowerCase() != 'libur') ...[
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
                // Special indicator for libur (break time)
                if (jadwal.kategori.toLowerCase() == 'libur') ...[
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
                      jadwal.kategori.toLowerCase() == 'libur'
                          ? Icons.free_breakfast
                          : Icons.access_time,
                      size: 16,
                      color: jadwal.kategori.toLowerCase() == 'libur'
                          ? Colors.green[600]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(jadwal.waktuMulai)} - ${_formatTime(jadwal.waktuSelesai)}',
                      style: TextStyle(
                        color: jadwal.kategori.toLowerCase() == 'libur'
                            ? Colors.green[600]
                            : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: jadwal.kategori.toLowerCase() == 'libur'
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

  // Helper methods
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

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getKategoriColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'kajian':
        return Colors.blue;
      case 'tahfidz':
        return Colors.purple;
      case 'kerja bakti':
        return Colors.orange;
      case 'olahraga':
        return Colors.red;
      case 'libur':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // CRUD Operations
  void _showAddEditDialog(
    BuildContext context,
    WidgetRef ref, {
    JadwalKegiatan? jadwal,
  }) {
    showDialog(
      context: context,
      builder: (context) => _JadwalFormDialog(
        jadwal: jadwal,
        onSave: (newJadwal) {
          if (jadwal == null) {
            _addJadwal(ref, newJadwal);
          } else {
            _updateJadwal(ref, jadwal.id, newJadwal);
          }
        },
      ),
    );
  }

  Future<void> _addJadwal(WidgetRef ref, JadwalKegiatan jadwal) async {
    try {
      // Step 1: Save jadwal to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('jadwal')
          .add(jadwal.toJson());

      // Step 2: Generate default attendance records for all active santri
      // Only generate for non-libur activities
      if (jadwal.kategori.toLowerCase() != 'libur') {
        await AttendanceService.generateDefaultAttendanceForJadwal(
          jadwalId: docRef.id,
          createdBy: 'admin', // TODO: get from current user
          createdByName: 'Admin', // TODO: get from current user
        );
      }

      // Step 3: Send notification
      await MessagingHelper.sendPengumumanToSantri(
        title: 'Jadwal Baru Ditambahkan',
        message:
            '${jadwal.nama} - ${_formatDate(jadwal.tanggal)} ${_formatTime(jadwal.waktuMulai)} di ${jadwal.tempat}',
      );
    } catch (e) {
      // Error adding jadwal
    }
  }

  Future<void> _updateJadwal(
    WidgetRef ref,
    String id,
    JadwalKegiatan jadwal,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('jadwal')
          .doc(id)
          .update(jadwal.toJson());
    } catch (e) {
      // Error updating jadwal
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
      tanggal: jadwal.tanggal.add(
        const Duration(days: 1),
      ), // Duplikasi untuk hari berikutnya
      waktuMulai: jadwal.waktuMulai,
      waktuSelesai: jadwal.waktuSelesai,
      tempat: jadwal.tempat,
      kategori: jadwal.kategori,
      materiId: jadwal.materiId,
      materiNama: jadwal.materiNama,
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
                  const Text('• Mengubah kategori menjadi "LIBUR"'),
                  const Text('• Menghilangkan materi yang terkait'),
                  const Text('• Mengubah nama menjadi "Libur"'),
                  const Text('• Memberikan notifikasi pembatalan'),
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
        final originalData = {
          'nama_asli': jadwal.nama,
          'kategori_asli': jadwal.kategori,
          'materi_id_asli': jadwal.materiId,
          'materi_nama_asli': jadwal.materiNama,
          'deskripsi_asli': jadwal.deskripsi,
        };

        await FirebaseFirestore.instance
            .collection('jadwal')
            .doc(jadwal.id)
            .update({
              'nama': 'Libur',
              'kategori': 'libur',
              'materiId': null,
              'materiNama': null,
              'deskripsi': 'Kegiatan diliburkan',
              'backup_data': originalData,
            });

        await MessagingHelper.sendPengumumanToSantri(
          title: 'Kegiatan Diliburkan',
          message:
              '${jadwal.nama} pada ${_formatDate(jadwal.tanggal)} ${_formatTime(jadwal.waktuMulai)} telah diliburkan.',
        );

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
      final doc = await FirebaseFirestore.instance
          .collection('jadwal')
          .doc(jadwal.id)
          .get();

      final data = doc.data();
      final backupData = data?['backup_data'] as Map<String, dynamic>?;

      if (backupData == null) {
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
        await FirebaseFirestore.instance
            .collection('jadwal')
            .doc(jadwal.id)
            .update({
              'nama': backupData['nama_asli'],
              'kategori': backupData['kategori_asli'],
              'materiId': backupData['materi_id_asli'],
              'materiNama': backupData['materi_nama_asli'],
              'deskripsi': backupData['deskripsi_asli'] ?? '',
              'backup_data': FieldValue.delete(),
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

        await MessagingHelper.sendPengumumanToSantri(
          title: 'Kegiatan Dikembalikan',
          message:
              '${backupData['nama_asli']} pada ${_formatDate(jadwal.tanggal)} ${_formatTime(jadwal.waktuMulai)} telah dikembalikan.',
        );

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
        waktu: DateTime.now().add(const Duration(minutes: 15)),
        tempat: jadwal.tempat,
      );
    } catch (e) {
      // Error sending notification
    }
  }
}

/// Dialog form yang disederhanakan
class _JadwalFormDialog extends ConsumerStatefulWidget {
  final JadwalKegiatan? jadwal;
  final Function(JadwalKegiatan) onSave;

  const _JadwalFormDialog({this.jadwal, required this.onSave});

  @override
  ConsumerState<_JadwalFormDialog> createState() => _JadwalFormDialogState();
}

class _JadwalFormDialogState extends ConsumerState<_JadwalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tempatController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedKategori = 'umum';
  String? _selectedMateriId;
  String? _selectedMateriNama;
  TimeOfDay _waktuMulai = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _waktuSelesai = const TimeOfDay(hour: 9, minute: 0);
  bool _isAktif = true;

  @override
  void initState() {
    super.initState();

    if (widget.jadwal != null) {
      _namaController.text = widget.jadwal!.nama;
      _deskripsiController.text = widget.jadwal!.deskripsi;
      _tempatController.text = widget.jadwal!.tempat;
      _selectedDate = widget.jadwal!.tanggal;
      _selectedKategori = widget.jadwal!.kategori;
      _selectedMateriId = widget.jadwal!.materiId;
      _selectedMateriNama = widget.jadwal!.materiNama;
      _waktuMulai = widget.jadwal!.waktuMulai;
      _waktuSelesai = widget.jadwal!.waktuSelesai;
      _isAktif = widget.jadwal!.isAktif;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _tempatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.jadwal == null ? 'Tambah Kegiatan' : 'Edit Kegiatan'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kegiatan',
                    border: const OutlineInputBorder(),
                    hintText: _getHintTextForKategori(_selectedKategori),
                    suffixIcon: _selectedKategori == 'libur'
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.psychology),
                            tooltip: 'Template Libur',
                            onSelected: (value) {
                              _namaController.text = value;
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Istirahat',
                                child: Text('Istirahat'),
                              ),
                              const PopupMenuItem(
                                value: 'Makan Siang',
                                child: Text('Makan Siang'),
                              ),
                              const PopupMenuItem(
                                value: 'Makan Malam',
                                child: Text('Makan Malam'),
                              ),
                              const PopupMenuItem(
                                value: 'Sarapan',
                                child: Text('Sarapan'),
                              ),
                              const PopupMenuItem(
                                value: 'Waktu Sholat',
                                child: Text('Waktu Sholat'),
                              ),
                              const PopupMenuItem(
                                value: 'Persiapan',
                                child: Text('Persiapan'),
                              ),
                            ],
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama kegiatan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Kegiatan',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_formatDate(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _waktuMulai,
                          );
                          if (time != null) {
                            setState(() {
                              _waktuMulai = time;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Waktu Mulai',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_formatTime(_waktuMulai)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _waktuSelesai,
                          );
                          if (time != null) {
                            setState(() {
                              _waktuSelesai = time;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Waktu Selesai',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_formatTime(_waktuSelesai)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _tempatController,
                  decoration: InputDecoration(
                    labelText: 'Tempat',
                    border: const OutlineInputBorder(),
                    hintText: _getTempatHintForKategori(_selectedKategori),
                    suffixIcon: _selectedKategori == 'libur'
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.location_on),
                            tooltip: 'Template Tempat',
                            onSelected: (value) {
                              _tempatController.text = value;
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Kamar/Asrama',
                                child: Text('Kamar/Asrama'),
                              ),
                              const PopupMenuItem(
                                value: 'Ruang Makan',
                                child: Text('Ruang Makan'),
                              ),
                              const PopupMenuItem(
                                value: 'Masjid',
                                child: Text('Masjid'),
                              ),
                              const PopupMenuItem(
                                value: 'Halaman',
                                child: Text('Halaman'),
                              ),
                              const PopupMenuItem(
                                value: 'Ruang Santai',
                                child: Text('Ruang Santai'),
                              ),
                            ],
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tempat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: TipeJadwal.values.map((kategori) {
                    return DropdownMenuItem(
                      value: kategori.value,
                      child: Text(kategori.value.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKategori = value!;
                      if (value != 'kajian' && value != 'tahfidz' ||
                          value == 'libur') {
                        _selectedMateriId = null;
                        _selectedMateriNama = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                if ((_selectedKategori == 'kajian' ||
                        _selectedKategori == 'tahfidz') &&
                    _selectedKategori != 'libur') ...[
                  Builder(
                    builder: (context) {
                      final materiAsync = ref.watch(materiProvider);

                      return materiAsync.when(
                        data: (materiList) {
                          return DropdownButtonFormField<String>(
                            value: _selectedMateriId,
                            decoration: const InputDecoration(
                              labelText: 'Pilih Materi (Opsional)',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('-- Tanpa Materi --'),
                              ),
                              ...materiList.map((materi) {
                                return DropdownMenuItem<String>(
                                  value: materi.id,
                                  child: Text(materi.nama),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedMateriId = value;
                                _selectedMateriNama = value != null
                                    ? materiList
                                          .firstWhere((m) => m.id == value)
                                          .nama
                                    : null;
                              });
                            },
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) =>
                            const Text('Error loading materi'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    const Text('Aktif'),
                    const Spacer(),
                    Switch(
                      value: _isAktif,
                      onChanged: (value) {
                        setState(() {
                          _isAktif = value;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saveJadwal,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.jadwal == null ? 'Tambah' : 'Simpan'),
        ),
      ],
    );
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

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _saveJadwal() {
    if (!_formKey.currentState!.validate()) return;

    final jadwal = JadwalKegiatan(
      id: widget.jadwal?.id ?? '',
      nama: _namaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      tanggal: _selectedDate,
      waktuMulai: _waktuMulai,
      waktuSelesai: _waktuSelesai,
      tempat: _tempatController.text.trim(),
      kategori: _selectedKategori,
      materiId: _selectedMateriId,
      materiNama: _selectedMateriNama,
      isAktif: _isAktif,
      createdAt: widget.jadwal?.createdAt ?? DateTime.now(),
    );

    widget.onSave(jadwal);
    Navigator.pop(context);
  }

  String _getHintTextForKategori(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'kajian':
        return 'Contoh: Tafsir Al-Quran';
      case 'tahfidz':
        return 'Contoh: Hafalan Juz 1, Muraja\'ah Surah';
      case 'kerja bakti':
        return 'Contoh: Bersih-bersih Masjid, Gotong Royong';
      case 'olahraga':
        return 'Contoh: Sepak Bola, Senam Pagi';
      case 'libur':
        return 'Contoh: Istirahat, Makan Siang, Waktu Sholat';
      default:
        return 'Masukkan nama kegiatan';
    }
  }

  String _getTempatHintForKategori(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'kajian':
        return 'Contoh: Ruang Kelas, Masjid, Aula';
      case 'tahfidz':
        return 'Contoh: Ruang Hafalan, Masjid';
      case 'kerja bakti':
        return 'Contoh: Halaman, Dapur, Area Umum';
      case 'olahraga':
        return 'Contoh: Lapangan, Gym, Halaman';
      case 'libur':
        return 'Contoh: Kamar/Asrama, Ruang Makan, Masjid';
      default:
        return 'Masukkan lokasi kegiatan';
    }
  }
}

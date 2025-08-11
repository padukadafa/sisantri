import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/helpers/messaging_helper.dart';
import '../../../shared/providers/materi_provider.dart';
import '../../../shared/services/materi_service.dart';

/// Model untuk jadwal kegiatan
class JadwalKegiatan {
  final String id;
  final String nama;
  final String deskripsi;
  final String jenis; // 'harian' atau 'event'
  final String? hari; // untuk jadwal harian
  final DateTime? tanggal; // untuk jadwal event
  final TimeOfDay waktuMulai;
  final TimeOfDay waktuSelesai;
  final String tempat;
  final String kategori;
  final String? materiId; // ID materi yang dipilih
  final String? materiNama; // Nama materi untuk display
  final bool isAktif;
  final DateTime createdAt;

  JadwalKegiatan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.jenis,
    this.hari,
    this.tanggal,
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
      jenis: json['jenis'] ?? 'harian',
      hari: json['hari'],
      tanggal: json['tanggal'] != null
          ? (json['tanggal'] as Timestamp).toDate()
          : null,
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
      'jenis': jenis,
      if (hari != null) 'hari': hari,
      if (tanggal != null) 'tanggal': Timestamp.fromDate(tanggal!),
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

/// Provider untuk daftar jadwal harian
final jadwalHarianProvider = StreamProvider<List<JadwalKegiatan>>((ref) {
  return FirebaseFirestore.instance
      .collection('jadwal')
      .where('jenis', isEqualTo: 'harian')
      .orderBy('hari')
      .orderBy('waktuMulai')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => JadwalKegiatan.fromJson(doc.id, doc.data()))
            .toList();
      });
});

/// Provider untuk daftar jadwal event
final jadwalEventProvider = StreamProvider<List<JadwalKegiatan>>((ref) {
  return FirebaseFirestore.instance
      .collection('jadwal')
      .where('jenis', isEqualTo: 'event')
      .orderBy('tanggal')
      .orderBy('waktuMulai')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => JadwalKegiatan.fromJson(doc.id, doc.data()))
            .toList();
      });
});

/// Halaman manajemen jadwal kegiatan
class ScheduleManagementPage extends ConsumerWidget {
  const ScheduleManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalHarianAsync = ref.watch(jadwalHarianProvider);
    final jadwalEventAsync = ref.watch(jadwalEventProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Jadwal'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.schedule), text: 'Jadwal Harian'),
              Tab(icon: Icon(Icons.event), text: 'Event Khusus'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add_harian') {
                  _showAddEditDialog(context, ref, jenisJadwal: 'harian');
                } else if (value == 'add_event') {
                  _showAddEditDialog(context, ref, jenisJadwal: 'event');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add_harian',
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 16),
                      SizedBox(width: 8),
                      Text('Tambah Jadwal Harian'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'add_event',
                  child: Row(
                    children: [
                      Icon(Icons.event, size: 16),
                      SizedBox(width: 8),
                      Text('Tambah Event Khusus'),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab Jadwal Harian
            jadwalHarianAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorView(ref, jadwalHarianProvider),
              data: (jadwalList) =>
                  _buildJadwalHarianView(context, ref, jadwalList),
            ),
            // Tab Event Khusus
            jadwalEventAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorView(ref, jadwalEventProvider),
              data: (jadwalList) =>
                  _buildJadwalEventView(context, ref, jadwalList),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showJenisSelectionDialog(context, ref),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorView(WidgetRef ref, provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Terjadi kesalahan saat memuat data'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(provider),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showJenisSelectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Jenis Jadwal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text('Jadwal Harian'),
              subtitle: const Text('Kegiatan rutin setiap hari'),
              onTap: () {
                Navigator.pop(context);
                _showAddEditDialog(context, ref, jenisJadwal: 'harian');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.orange),
              title: const Text('Event Khusus'),
              subtitle: const Text(
                'Kegiatan tidak rutin dengan tanggal tertentu',
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddEditDialog(context, ref, jenisJadwal: 'event');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalHarianView(
    BuildContext context,
    WidgetRef ref,
    List<JadwalKegiatan> jadwalList,
  ) {
    if (jadwalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada jadwal harian',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAddEditDialog(context, ref, jenisJadwal: 'harian'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Jadwal Harian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Group by day
    final groupedJadwal = <String, List<JadwalKegiatan>>{};
    final hariUrutan = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    for (final jadwal in jadwalList) {
      if (jadwal.hari != null) {
        groupedJadwal.putIfAbsent(jadwal.hari!, () => []);
        groupedJadwal[jadwal.hari!]!.add(jadwal);
      }
    }

    return DefaultTabController(
      length: 7,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              tabs: hariUrutan
                  .map(
                    (hari) => Tab(
                      text: hari,
                      icon: Badge(
                        label: Text('${groupedJadwal[hari]?.length ?? 0}'),
                        child: const Icon(Icons.calendar_today, size: 16),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: hariUrutan.map((hari) {
                final jadwalHari = groupedJadwal[hari] ?? [];
                return _buildDaySchedule(context, ref, hari, jadwalHari);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalEventView(
    BuildContext context,
    WidgetRef ref,
    List<JadwalKegiatan> jadwalList,
  ) {
    if (jadwalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada event khusus',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAddEditDialog(context, ref, jenisJadwal: 'event'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by date
    jadwalList.sort((a, b) {
      if (a.tanggal == null && b.tanggal == null) return 0;
      if (a.tanggal == null) return 1;
      if (b.tanggal == null) return -1;
      return a.tanggal!.compareTo(b.tanggal!);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jadwalList.length,
      itemBuilder: (context, index) {
        final jadwal = jadwalList[index];
        return _buildEventCard(context, ref, jadwal);
      },
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    WidgetRef ref,
    JadwalKegiatan jadwal,
  ) {
    final kategoriColor = _getKategoriColor(jadwal.kategori);
    final formattedDate = jadwal.tanggal != null
        ? _formatDate(jadwal.tanggal!)
        : 'Tanggal tidak valid';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAddEditDialog(context, ref, jadwal: jadwal),
        borderRadius: BorderRadius.circular(12),
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
                      border: Border.all(color: kategoriColor.withOpacity(0.3)),
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'EVENT',
                      style: TextStyle(
                        color: Colors.orange,
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
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (jadwal.deskripsi.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  jadwal.deskripsi,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatTime(jadwal.waktuMulai)} - ${_formatTime(jadwal.waktuSelesai)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
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

  Widget _buildDaySchedule(
    BuildContext context,
    WidgetRef ref,
    String hari,
    List<JadwalKegiatan> jadwalHari,
  ) {
    if (jadwalHari.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada kegiatan di hari $hari',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAddEditDialog(context, ref, preselectedDay: hari),
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

    // Sort by time
    jadwalHari.sort((a, b) {
      final aMinutes = a.waktuMulai.hour * 60 + a.waktuMulai.minute;
      final bMinutes = b.waktuMulai.hour * 60 + b.waktuMulai.minute;
      return aMinutes.compareTo(bMinutes);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jadwalHari.length,
      itemBuilder: (context, index) {
        final jadwal = jadwalHari[index];
        return _buildJadwalCard(context, ref, jadwal);
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAddEditDialog(context, ref, jadwal: jadwal),
        borderRadius: BorderRadius.circular(12),
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
                      border: Border.all(color: kategoriColor.withOpacity(0.3)),
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
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (jadwal.deskripsi.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  jadwal.deskripsi,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
              if (jadwal.materiNama != null) ...[
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
                      Icon(Icons.menu_book, size: 14, color: Colors.green[700]),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatTime(jadwal.waktuMulai)} - ${_formatTime(jadwal.waktuSelesai)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
    );
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
  }) {
    showDialog(
      context: context,
      builder: (context) => _JadwalFormDialog(
        jadwal: jadwal,
        preselectedDay: preselectedDay,
        jenisJadwal: jenisJadwal,
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
      await FirebaseFirestore.instance
          .collection('jadwal')
          .add(jadwal.toJson());

      // Send notification about new schedule
      await MessagingHelper.sendPengumumanToSantri(
        title: 'Jadwal Baru Ditambahkan',
        message:
            '${jadwal.nama} - ${jadwal.hari} ${_formatTime(jadwal.waktuMulai)} di ${jadwal.tempat}',
      );
    } catch (e) {
      print('Error adding jadwal: $e');
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
      print('Error updating jadwal: $e');
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
      print('Error toggling active status: $e');
    }
  }

  Future<void> _duplicateJadwal(WidgetRef ref, JadwalKegiatan jadwal) async {
    final newJadwal = JadwalKegiatan(
      id: '',
      nama: '${jadwal.nama} (Copy)',
      deskripsi: jadwal.deskripsi,
      jenis: jadwal.jenis,
      hari: jadwal.hari,
      tanggal: jadwal.tanggal,
      waktuMulai: jadwal.waktuMulai,
      waktuSelesai: jadwal.waktuSelesai,
      tempat: jadwal.tempat,
      kategori: jadwal.kategori,
      isAktif: true,
      createdAt: DateTime.now(),
    );

    await _addJadwal(ref, newJadwal);
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
        print('Error deleting jadwal: $e');
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
      print('Error sending notification: $e');
    }
  }
}

/// Dialog form untuk menambah/edit jadwal
class _JadwalFormDialog extends ConsumerStatefulWidget {
  final JadwalKegiatan? jadwal;
  final String? preselectedDay;
  final String? jenisJadwal;
  final Function(JadwalKegiatan) onSave;

  const _JadwalFormDialog({
    this.jadwal,
    this.preselectedDay,
    this.jenisJadwal,
    required this.onSave,
  });

  @override
  ConsumerState<_JadwalFormDialog> createState() => _JadwalFormDialogState();
}

class _JadwalFormDialogState extends ConsumerState<_JadwalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tempatController = TextEditingController();

  String _selectedJenis = 'harian';
  String _selectedHari = 'Senin';
  DateTime? _selectedDate;
  String _selectedKategori = 'umum';
  String? _selectedMateriId;
  String? _selectedMateriNama;
  TimeOfDay _waktuMulai = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _waktuSelesai = const TimeOfDay(hour: 9, minute: 0);
  bool _isAktif = true;

  final List<String> _hariOptions = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  final List<String> _kategoriOptions = [
    'kajian',
    'tahfidz',
    'kerja bakti',
    'olahraga',
    'umum',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.jadwal != null) {
      _namaController.text = widget.jadwal!.nama;
      _deskripsiController.text = widget.jadwal!.deskripsi;
      _tempatController.text = widget.jadwal!.tempat;
      _selectedJenis = widget.jadwal!.jenis;
      _selectedHari = widget.jadwal!.hari ?? 'Senin';
      _selectedDate = widget.jadwal!.tanggal;
      _selectedKategori = widget.jadwal!.kategori;
      _selectedMateriId = widget.jadwal!.materiId;
      _selectedMateriNama = widget.jadwal!.materiNama;
      _waktuMulai = widget.jadwal!.waktuMulai;
      _waktuSelesai = widget.jadwal!.waktuSelesai;
      _isAktif = widget.jadwal!.isAktif;
    } else {
      if (widget.jenisJadwal != null) {
        _selectedJenis = widget.jenisJadwal!;
      }
      if (widget.preselectedDay != null) {
        _selectedHari = widget.preselectedDay!;
      }
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
      title: Text(widget.jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Jenis Jadwal
                if (widget.jadwal == null) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedJenis,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Jadwal',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'harian',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 16),
                            SizedBox(width: 8),
                            Text('Jadwal Harian'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'event',
                        child: Row(
                          children: [
                            Icon(Icons.event, size: 16),
                            SizedBox(width: 8),
                            Text('Event Khusus'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedJenis = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kegiatan',
                    border: OutlineInputBorder(),
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

                // Hari (untuk jadwal harian) atau Tanggal (untuk event)
                if (_selectedJenis == 'harian') ...[
                  DropdownButtonFormField<String>(
                    value: _selectedHari,
                    decoration: const InputDecoration(
                      labelText: 'Hari',
                      border: OutlineInputBorder(),
                    ),
                    items: _hariOptions.map((hari) {
                      return DropdownMenuItem(value: hari, child: Text(hari));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHari = value!;
                      });
                    },
                  ),
                ] else ...[
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
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
                        labelText: 'Tanggal Event',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? _formatDate(_selectedDate!)
                            : 'Pilih tanggal',
                      ),
                    ),
                  ),
                ],
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
                  decoration: const InputDecoration(
                    labelText: 'Tempat',
                    border: OutlineInputBorder(),
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
                  items: _kategoriOptions.map((kategori) {
                    return DropdownMenuItem(
                      value: kategori,
                      child: Text(kategori.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKategori = value!;
                      // Reset materi jika kategori bukan kajian/tahfidz
                      if (value != 'kajian' && value != 'tahfidz') {
                        _selectedMateriId = null;
                        _selectedMateriNama = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown untuk memilih materi (khusus kategori kajian/tahfidz)
                if (_selectedKategori == 'kajian' ||
                    _selectedKategori == 'tahfidz') ...[
                  Builder(
                    builder: (context) {
                      final materiAsync = ref.watch(materiProvider);

                      return materiAsync.when(
                        data: (materiList) {
                          print(
                            'DEBUG: Materi loaded: ${materiList.length} items',
                          );
                          if (materiList.isEmpty) {
                            return Column(
                              children: [
                                const InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Materi (Opsional)',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    'Belum ada materi tersedia',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Membuat dummy data materi...',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );

                                      await MateriService.createDummyMateri();

                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '✅ Dummy data materi berhasil dibuat!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('❌ Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.storage),
                                  label: const Text('Buat Data Dummy'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          }

                          return DropdownButtonFormField<String>(
                            value: _selectedMateriId,
                            decoration: const InputDecoration(
                              labelText: 'Materi (Opsional)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'Pilih Materi (Opsional)',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ...materiList.map((materi) {
                                return DropdownMenuItem(
                                  value: materi.id,
                                  child: Text(
                                    materi.nama,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedMateriId = value;
                                if (value != null) {
                                  final selectedMateri = materiList.firstWhere(
                                    (m) => m.id == value,
                                  );
                                  _selectedMateriNama = selectedMateri.nama;
                                } else {
                                  _selectedMateriNama = null;
                                }
                              });
                            },
                          );
                        },
                        loading: () => const InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Materi (Opsional)',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Memuat materi...'),
                            ],
                          ),
                        ),
                        error: (error, stack) => Column(
                          children: [
                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Materi (Opsional)',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                'Error: $error',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref.invalidate(materiProvider);
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    const Text('Status Aktif:'),
                    const Spacer(),
                    Switch(
                      value: _isAktif,
                      onChanged: (value) {
                        setState(() {
                          _isAktif = value;
                        });
                      },
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

    // Validasi khusus untuk event
    if (_selectedJenis == 'event' && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal untuk event'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final jadwal = JadwalKegiatan(
      id: widget.jadwal?.id ?? '',
      nama: _namaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      jenis: _selectedJenis,
      hari: _selectedJenis == 'harian' ? _selectedHari : null,
      tanggal: _selectedJenis == 'event' ? _selectedDate : null,
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
}

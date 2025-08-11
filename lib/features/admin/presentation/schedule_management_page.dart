import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/helpers/messaging_helper.dart';

/// Model untuk jadwal kegiatan
class JadwalKegiatan {
  final String id;
  final String nama;
  final String deskripsi;
  final String hari;
  final TimeOfDay waktuMulai;
  final TimeOfDay waktuSelesai;
  final String tempat;
  final String kategori;
  final bool isAktif;
  final DateTime createdAt;

  JadwalKegiatan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.hari,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.tempat,
    required this.kategori,
    this.isAktif = true,
    required this.createdAt,
  });

  factory JadwalKegiatan.fromJson(String id, Map<String, dynamic> json) {
    return JadwalKegiatan(
      id: id,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      hari: json['hari'] ?? '',
      waktuMulai: _timeFromString(json['waktuMulai'] ?? '00:00'),
      waktuSelesai: _timeFromString(json['waktuSelesai'] ?? '00:00'),
      tempat: json['tempat'] ?? '',
      kategori: json['kategori'] ?? 'umum',
      isAktif: json['isAktif'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'hari': hari,
      'waktuMulai':
          '${waktuMulai.hour.toString().padLeft(2, '0')}:${waktuMulai.minute.toString().padLeft(2, '0')}',
      'waktuSelesai':
          '${waktuSelesai.hour.toString().padLeft(2, '0')}:${waktuSelesai.minute.toString().padLeft(2, '0')}',
      'tempat': tempat,
      'kategori': kategori,
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

/// Provider untuk daftar jadwal
final jadwalProvider = StreamProvider<List<JadwalKegiatan>>((ref) {
  return FirebaseFirestore.instance
      .collection('jadwal')
      .orderBy('hari')
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
    final jadwalAsync = ref.watch(jadwalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Jadwal'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(context, ref),
          ),
        ],
      ),
      body: jadwalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(jadwalProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (jadwalList) => _buildJadwalView(context, ref, jadwalList),
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
    if (jadwalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada jadwal kegiatan',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Jadwal'),
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
      groupedJadwal.putIfAbsent(jadwal.hari, () => []);
      groupedJadwal[jadwal.hari]!.add(jadwal);
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
      case 'sholat':
        return Colors.green;
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
  }) {
    showDialog(
      context: context,
      builder: (context) => _JadwalFormDialog(
        jadwal: jadwal,
        preselectedDay: preselectedDay,
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
      hari: jadwal.hari,
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
class _JadwalFormDialog extends StatefulWidget {
  final JadwalKegiatan? jadwal;
  final String? preselectedDay;
  final Function(JadwalKegiatan) onSave;

  const _JadwalFormDialog({
    this.jadwal,
    this.preselectedDay,
    required this.onSave,
  });

  @override
  State<_JadwalFormDialog> createState() => _JadwalFormDialogState();
}

class _JadwalFormDialogState extends State<_JadwalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tempatController = TextEditingController();

  String _selectedHari = 'Senin';
  String _selectedKategori = 'umum';
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
    'sholat',
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
      _selectedHari = widget.jadwal!.hari;
      _selectedKategori = widget.jadwal!.kategori;
      _waktuMulai = widget.jadwal!.waktuMulai;
      _waktuSelesai = widget.jadwal!.waktuSelesai;
      _isAktif = widget.jadwal!.isAktif;
    } else if (widget.preselectedDay != null) {
      _selectedHari = widget.preselectedDay!;
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
                    });
                  },
                ),
                const SizedBox(height: 16),

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

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _saveJadwal() {
    if (!_formKey.currentState!.validate()) return;

    final jadwal = JadwalKegiatan(
      id: widget.jadwal?.id ?? '',
      nama: _namaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      hari: _selectedHari,
      waktuMulai: _waktuMulai,
      waktuSelesai: _waktuSelesai,
      tempat: _tempatController.text.trim(),
      kategori: _selectedKategori,
      isAktif: _isAktif,
      createdAt: widget.jadwal?.createdAt ?? DateTime.now(),
    );

    widget.onSave(jadwal);
    Navigator.pop(context);
  }
}

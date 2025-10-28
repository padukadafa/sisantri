import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/features/admin/schedule_management/presentation/models/jadwal_kegiatan_model.dart';

import 'package:sisantri/shared/helpers/messaging_helper.dart';
import 'package:sisantri/shared/providers/materi_provider.dart';
import 'package:sisantri/shared/services/materi_service.dart';
import 'package:sisantri/shared/models/jadwal_model.dart';
import 'package:sisantri/shared/services/attendance_service.dart';

class AddEditJadwalPage extends ConsumerStatefulWidget {
  final JadwalKegiatan? jadwal;
  final String? preselectedDay;
  final String? jenisJadwal;

  const AddEditJadwalPage({
    super.key,
    this.jadwal,
    this.preselectedDay,
    this.jenisJadwal,
  });

  @override
  ConsumerState<AddEditJadwalPage> createState() => _AddEditJadwalPageState();
}

class _AddEditJadwalPageState extends ConsumerState<AddEditJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tempatController = TextEditingController();

  DateTime? _selectedDate;
  TipeJadwal _selectedKategori = TipeJadwal.umum;
  String? _selectedMateriId;
  String? _selectedMateriNama;

  // Fields untuk kajian
  final _surahController = TextEditingController();
  final _ayatMulaiController = TextEditingController();
  final _ayatSelesaiController = TextEditingController();
  final _halamanMulaiController = TextEditingController();
  final _halamanSelesaiController = TextEditingController();
  final _catatanController = TextEditingController();

  TimeOfDay _waktuMulai = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _waktuSelesai = const TimeOfDay(hour: 9, minute: 0);
  bool _isAktif = true;
  bool _isLoading = false;

  final List<TipeJadwal> _kategoriOptions = [
    TipeJadwal.kajian,
    TipeJadwal.tahfidz,
    TipeJadwal.kerjaBakti,
    TipeJadwal.olahraga,
    TipeJadwal.libur,
    TipeJadwal.umum,
  ];

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

      _surahController.text = widget.jadwal!.surah ?? '';
      _ayatMulaiController.text = widget.jadwal!.ayatMulai?.toString() ?? '';
      _ayatSelesaiController.text =
          widget.jadwal!.ayatSelesai?.toString() ?? '';
      _halamanMulaiController.text =
          widget.jadwal!.halamanMulai?.toString() ?? '';
      _halamanSelesaiController.text =
          widget.jadwal!.halamanSelesai?.toString() ?? '';
      _catatanController.text = widget.jadwal!.catatan ?? '';
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _tempatController.dispose();
    _surahController.dispose();
    _ayatMulaiController.dispose();
    _ayatSelesaiController.dispose();
    _halamanMulaiController.dispose();
    _halamanSelesaiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveJadwal,
              child: Text(
                widget.jadwal == null ? 'Tambah' : 'Simpan',
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Kegiatan
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Kegiatan',
                  border: const OutlineInputBorder(),
                  hintText: _getHintTextForKategori(_selectedKategori),
                  suffixIcon: _selectedKategori == TipeJadwal.libur
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

              // Deskripsi
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
                    initialDate: _selectedDate ?? DateTime.now(),
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
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : 'Pilih tanggal',
                  ),
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
                  suffixIcon: _selectedKategori == TipeJadwal.libur
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

              // Kategori
              DropdownButtonFormField<TipeJadwal>(
                value: _selectedKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriOptions.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(_getKategoriDisplayName(kategori)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value!;
                    // Reset materi jika kategori bukan kajian/tahfidz atau jika libur
                    if (value != TipeJadwal.kajian &&
                            value != TipeJadwal.tahfidz ||
                        value == TipeJadwal.libur) {
                      _selectedMateriId = null;
                      _selectedMateriNama = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Dropdown untuk memilih materi (khusus kategori kajian/tahfidz dan bukan libur)
              if ((_selectedKategori == TipeJadwal.kajian ||
                      _selectedKategori == TipeJadwal.tahfidz) &&
                  _selectedKategori != TipeJadwal.libur) ...[
                Builder(
                  builder: (context) {
                    final materiAsync = ref.watch(materiProvider);

                    return materiAsync.when(
                      data: (materiList) {
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
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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

              // Field untuk kajian (khusus kategori kajian)
              if (_selectedKategori == TipeJadwal.kajian) ...[
                // Toggle untuk memilih jenis kajian (Quran atau Kitab)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.book, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Detail Kajian',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Field untuk kajian Quran
                      TextFormField(
                        controller: _surahController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Surah (Opsional)',
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: Al-Fatihah, Al-Baqarah',
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ayatMulaiController,
                              decoration: const InputDecoration(
                                labelText: 'Ayat Mulai (Opsional)',
                                border: OutlineInputBorder(),
                                hintText: '1',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _ayatSelesaiController,
                              decoration: const InputDecoration(
                                labelText: 'Ayat Selesai (Opsional)',
                                border: OutlineInputBorder(),
                                hintText: '10',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const Divider(),
                      const SizedBox(height: 8),

                      Text(
                        'Atau untuk kitab/buku:',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _halamanMulaiController,
                              decoration: const InputDecoration(
                                labelText: 'Halaman Mulai (Opsional)',
                                border: OutlineInputBorder(),
                                hintText: '1',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _halamanSelesaiController,
                              decoration: const InputDecoration(
                                labelText: 'Halaman Selesai (Opsional)',
                                border: OutlineInputBorder(),
                                hintText: '5',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _catatanController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Kajian (Opsional)',
                          border: OutlineInputBorder(),
                          hintText: 'Catatan tambahan untuk kajian ini',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
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
              const SizedBox(height: 24),
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

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _saveJadwal() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi tanggal
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal untuk kegiatan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final jadwal = JadwalKegiatan(
        id: widget.jadwal?.id ?? '',
        nama: _namaController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        tanggal: _selectedDate!,
        waktuMulai: _waktuMulai,
        waktuSelesai: _waktuSelesai,
        tempat: _tempatController.text.trim(),
        kategori: _selectedKategori,
        materiId: _selectedMateriId,
        materiNama: _selectedMateriNama,
        surah: _surahController.text.trim().isEmpty
            ? null
            : _surahController.text.trim(),
        ayatMulai: _ayatMulaiController.text.trim().isEmpty
            ? null
            : int.tryParse(_ayatMulaiController.text.trim()),
        ayatSelesai: _ayatSelesaiController.text.trim().isEmpty
            ? null
            : int.tryParse(_ayatSelesaiController.text.trim()),
        halamanMulai: _halamanMulaiController.text.trim().isEmpty
            ? null
            : int.tryParse(_halamanMulaiController.text.trim()),
        halamanSelesai: _halamanSelesaiController.text.trim().isEmpty
            ? null
            : int.tryParse(_halamanSelesaiController.text.trim()),
        catatan: _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
        isAktif: _isAktif,
        createdAt: widget.jadwal?.createdAt ?? DateTime.now(),
      );

      if (widget.jadwal == null) {
        await _addJadwal(jadwal);
      } else {
        await _updateJadwal(jadwal);
      }

      if (mounted) {
        Navigator.pop(context, jadwal);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addJadwal(JadwalKegiatan jadwal) async {
    final docRef = await FirebaseFirestore.instance
        .collection('jadwal')
        .add(jadwal.toJson());

    if (jadwal.kategori != TipeJadwal.libur) {
      await AttendanceService.generateDefaultAttendanceForJadwal(
        jadwalId: docRef.id,
        createdBy: 'admin',
        createdByName: 'Admin',
      );
    }

    await MessagingHelper.sendPengumumanToSantri(
      title: 'Jadwal Baru Ditambahkan',
      message:
          '${jadwal.nama} - ${_formatDate(jadwal.tanggal)} ${_formatTime(jadwal.waktuMulai)} di ${jadwal.tempat}',
    );
  }

  Future<void> _updateJadwal(JadwalKegiatan jadwal) async {
    await FirebaseFirestore.instance
        .collection('jadwal')
        .doc(jadwal.id)
        .update(jadwal.toJson());
  }

  String _getHintTextForKategori(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.kajian:
        return 'Contoh: Kajian Kitab Bulughul Maram';
      case TipeJadwal.tahfidz:
        return 'Contoh: Tahfidz Juz 30';
      case TipeJadwal.kerjaBakti:
        return 'Contoh: Kebersihan Masjid';
      case TipeJadwal.olahraga:
        return 'Contoh: Sepak Bola';
      case TipeJadwal.libur:
        return 'Contoh: Istirahat';
      case TipeJadwal.pengajian:
        return 'Contoh: Pengajian Rutin';
      case TipeJadwal.kegiatan:
        return 'Contoh: Kegiatan Sosial';
      case TipeJadwal.umum:
        return 'Contoh: Rapat Santri';
    }
  }

  String _getTempatHintForKategori(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.kajian:
        return 'Contoh: Ruang Kajian';
      case TipeJadwal.tahfidz:
        return 'Contoh: Masjid';
      case TipeJadwal.kerjaBakti:
        return 'Contoh: Halaman';
      case TipeJadwal.olahraga:
        return 'Contoh: Lapangan';
      case TipeJadwal.libur:
        return 'Contoh: Kamar';
      case TipeJadwal.pengajian:
        return 'Contoh: Aula';
      case TipeJadwal.kegiatan:
        return 'Contoh: Ruang Serbaguna';
      case TipeJadwal.umum:
        return 'Contoh: Ruang Rapat';
    }
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

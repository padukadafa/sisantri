import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sisantri/shared/helpers/messaging_helper.dart';
import 'package:sisantri/shared/models/jadwal_model.dart';
import 'package:sisantri/shared/services/attendance_service.dart';
import 'package:sisantri/core/theme/app_theme.dart';

import '../models/jadwal_kegiatan_model.dart';
import '../widgets/form_sections/basic_info_form_section.dart';
import '../widgets/form_sections/date_time_form_section.dart';
import '../widgets/form_sections/kategori_form_section.dart';

/// Halaman untuk menambah/edit jadwal kegiatan (Refactored)
class AddEditJadwalPage extends ConsumerStatefulWidget {
  final JadwalKegiatan? jadwal;

  const AddEditJadwalPage({super.key, this.jadwal});

  @override
  ConsumerState<AddEditJadwalPage> createState() =>
      _AddEditJadwalPageNewState();
}

class _AddEditJadwalPageNewState extends ConsumerState<AddEditJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tempatController = TextEditingController();

  DateTime? _selectedDate;
  TipeJadwal _selectedKategori = TipeJadwal.umum;
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
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.jadwal != null) {
      _namaController.text = widget.jadwal!.nama;
      _deskripsiController.text = widget.jadwal!.deskripsi;
      _tempatController.text = widget.jadwal!.tempat;
      _selectedDate = widget.jadwal!.tanggal;
      _selectedKategori = widget.jadwal!.kategori;
      _waktuMulai = widget.jadwal!.waktuMulai;
      _waktuSelesai = widget.jadwal!.waktuSelesai;
      _isAktif = widget.jadwal!.isAktif;
    } else {
      final currentDate = DateTime.now();
      _selectedDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
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
    final isEdit = widget.jadwal != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Jadwal' : 'Tambah Jadwal')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KategoriFormSection(
                      selectedKategori: _selectedKategori,
                      kategoriOptions: _kategoriOptions,
                      onKategoriChanged: (kategori) {
                        if (kategori != null) {
                          setState(() {
                            _selectedKategori = kategori;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    BasicInfoFormSection(
                      namaController: _namaController,
                      deskripsiController: _deskripsiController,
                      tempatController: _tempatController,
                      selectedKategori: _selectedKategori,
                    ),
                    const SizedBox(height: 24),
                    DateTimeFormSection(
                      selectedDate: _selectedDate,
                      waktuMulai: _waktuMulai,
                      waktuSelesai: _waktuSelesai,
                      onDateChanged: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      onWaktuMulaiChanged: (time) {
                        setState(() {
                          _waktuMulai = time;
                        });
                      },
                      onWaktuSelesaiChanged: (time) {
                        setState(() {
                          _waktuSelesai = time;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveJadwal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isEdit ? 'Update Jadwal' : 'Simpan Jadwal',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveJadwal() async {
    if (!_formKey.currentState!.validate()) return;

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
        materiId: null,
        materiNama: null,
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
          '${jadwal.nama} - ${jadwal.tanggal.day}/${jadwal.tanggal.month}/${jadwal.tanggal.year}',
    );
  }

  Future<void> _updateJadwal(JadwalKegiatan jadwal) async {
    await FirebaseFirestore.instance
        .collection('jadwal')
        .doc(jadwal.id)
        .update(jadwal.toJson());
  }
}

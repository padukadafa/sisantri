import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/shared/services/auth_service.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';
import 'package:sisantri/core/theme/app_theme.dart';

/// Halaman form untuk membuat/edit pengumuman
class AnnouncementFormPage extends ConsumerStatefulWidget {
  final PengumumanModel? announcement;

  const AnnouncementFormPage({super.key, this.announcement});

  @override
  ConsumerState<AnnouncementFormPage> createState() =>
      _AnnouncementFormPageState();
}

class _AnnouncementFormPageState extends ConsumerState<AnnouncementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _kontenController = TextEditingController();

  String _kategori = 'umum';
  String _prioritas = 'medium';
  String _targetAudience = 'all';
  DateTime _tanggalMulai = DateTime.now();
  DateTime? _tanggalBerakhir;
  bool _isPublished = false;
  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final announcement = widget.announcement!;
    _judulController.text = announcement.judul;
    _kontenController.text = announcement.konten;
    _kategori = announcement.kategori;
    _prioritas = announcement.prioritas;
    _targetAudience = announcement.targetAudience;
    _tanggalMulai = announcement.tanggalMulai;
    _tanggalBerakhir = announcement.tanggalBerakhir;
    _isPublished = announcement.isPublished;
    _isPinned = announcement.isPinned;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isView = widget.announcement != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isView ? 'Pengumuman' : 'Buat Pengumuman'),
        actions: [
          if (isView)
            TextButton(
              onPressed: _isLoading ? null : _saveAsDraft,
              child: const Text(
                'Simpan Draft',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Judul
            TextFormField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Judul Pengumuman *',
                hintText: 'Masukkan judul pengumuman',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              readOnly: isView,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul harus diisi';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Konten
            TextFormField(
              controller: _kontenController,
              decoration: const InputDecoration(
                labelText: 'Konten Pengumuman *',
                hintText: 'Masukkan isi pengumuman',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              readOnly: isView,

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konten harus diisi';
                }
                return null;
              },
              maxLines: 8,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _kategori,

              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'umum', child: Text('Umum')),
                DropdownMenuItem(value: 'penting', child: Text('Penting')),
                DropdownMenuItem(value: 'mendesak', child: Text('Mendesak')),
                DropdownMenuItem(value: 'akademik', child: Text('Akademik')),
                DropdownMenuItem(value: 'kegiatan', child: Text('Kegiatan')),
              ],
              onChanged: isView
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _kategori = value);
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Prioritas
            DropdownButtonFormField<String>(
              value: _prioritas,
              decoration: const InputDecoration(
                labelText: 'Prioritas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Rendah')),
                DropdownMenuItem(value: 'medium', child: Text('Sedang')),
                DropdownMenuItem(value: 'high', child: Text('Tinggi')),
              ],
              onChanged: isView
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _prioritas = value);
                      }
                    },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _targetAudience,
              decoration: const InputDecoration(
                labelText: 'Target Audience',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),

              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua')),
                DropdownMenuItem(value: 'santri', child: Text('Santri')),
                DropdownMenuItem(
                  value: 'dewan_guru',
                  child: Text('Dewan Guru'),
                ),
              ],
              onChanged: isView
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _targetAudience = value);
                      }
                    },
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('Tanggal Mulai'),
              subtitle: Text(
                '${_tanggalMulai.day}/${_tanggalMulai.month}/${_tanggalMulai.year}',
              ),
              leading: const Icon(Icons.calendar_today),
              trailing: isView ? null : const Icon(Icons.edit),
              onTap: isView
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _tanggalMulai,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _tanggalMulai = date);
                      }
                    },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('Tanggal Berakhir (Opsional)'),
              subtitle: Text(
                _tanggalBerakhir != null
                    ? '${_tanggalBerakhir!.day}/${_tanggalBerakhir!.month}/${_tanggalBerakhir!.year}'
                    : 'Tidak ada batas waktu',
              ),
              leading: const Icon(Icons.event_busy),
              trailing: isView ? null : const Icon(Icons.edit),
              onTap: isView
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _tanggalBerakhir ?? _tanggalMulai,
                        firstDate: _tanggalMulai,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      setState(() => _tanggalBerakhir = date);
                    },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Sematkan Pengumuman'),
              subtitle: const Text('Pengumuman akan muncul di bagian atas'),
              value: _isPinned,
              onChanged: isView
                  ? null
                  : (value) {
                      setState(() => _isPinned = value);
                    },
              secondary: const Icon(Icons.push_pin),
            ),
            const SizedBox(height: 24),

            Visibility(
              visible: !isView,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _saveAndPublish,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Publikasi',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAsDraft() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _saveAnnouncement(published: false);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft berhasil disimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAndPublish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _saveAnnouncement(published: true);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengumuman berhasil dipublikasi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAnnouncement({required bool published}) async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = AuthService.currentUser;

    if (currentUser == null) {
      throw Exception('User tidak ditemukan');
    }

    final now = DateTime.now();
    final data = {
      'judul': _judulController.text.trim(),
      'konten': _kontenController.text.trim(),
      'kategori': _kategori,
      'prioritas': _prioritas,
      'createdBy': currentUser.uid,
      'createdByName': currentUser.displayName ?? 'Admin',
      'targetAudience': _targetAudience,
      'targetRoles': <String>[],
      'targetClasses': <String>[],
      'lampiranUrl': null,
      'tanggalMulai': _tanggalMulai.toIso8601String(),
      'tanggalBerakhir': _tanggalBerakhir?.toIso8601String(),
      'isPublished': published,
      'isPinned': _isPinned,
      'viewCount': widget.announcement?.viewCount ?? 0,
      'updatedAt': now.toIso8601String(),
    };

    if (widget.announcement != null) {
      // Update existing
      await firestore
          .collection('pengumuman')
          .doc(widget.announcement!.id)
          .update(data);
    } else {
      // Create new
      data['createdAt'] = now.toIso8601String();
      await firestore.collection('pengumuman').add(data);
    }
  }
}

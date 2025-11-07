import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/shared/services/auth_service.dart';
import 'package:sisantri/shared/services/announcement_service.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';
import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/shared/widgets/reusable_text_field.dart';

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
  String _targetAudience = 'all';
  DateTime _tanggalMulai = DateTime.now();
  DateTime? _tanggalBerakhir;
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
    _targetAudience = announcement.targetAudience;
    _tanggalMulai = announcement.tanggalMulai;
    _tanggalBerakhir = announcement.tanggalBerakhir;
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
            ReusableTextField(
              controller: _judulController,
              labelText: 'Judul Pengumuman *',
              prefixIcon: Icons.title,
              readOnly: isView,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul harus diisi';
                }
                return null;
              },
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Konten
            ReusableTextField(
              controller: _kontenController,
              labelText: 'Konten Pengumuman *',
              prefixIcon: Icons.description,
              readOnly: isView,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konten harus diisi';
                }
                return null;
              },
              maxLines: 8,
              minLines: 4,
              textCapitalization: TextCapitalization.sentences,
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
    final currentUser = AuthService.currentUser;

    if (currentUser == null) {
      throw Exception('User tidak ditemukan');
    }

    final now = DateTime.now();

    final pengumumanModel = PengumumanModel(
      id: widget.announcement?.id ?? '',
      judul: _judulController.text.trim(),
      konten: _kontenController.text.trim(),
      kategori: _kategori,
      prioritas: 'medium',
      createdBy: currentUser.uid,
      createdByName: currentUser.displayName ?? 'Admin',
      targetAudience: _targetAudience,
      targetRoles: const [],
      targetClasses: const [],
      lampiranUrl: null,
      tanggalMulai: _tanggalMulai,
      tanggalBerakhir: _tanggalBerakhir,
      isPublished: published,
      isPinned: false,
      viewCount: widget.announcement?.viewCount ?? 0,
      createdAt: widget.announcement?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.announcement != null) {
      // Update existing
      await AnnouncementService.updatePengumuman(
        widget.announcement!.id,
        pengumumanModel,
      );
    } else {
      // Create new
      await AnnouncementService.addPengumuman(pengumumanModel);
    }
  }
}

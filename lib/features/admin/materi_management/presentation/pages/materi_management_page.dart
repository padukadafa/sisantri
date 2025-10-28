import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/materi_model.dart';
import '../../../shared/providers/materi_provider.dart';
import '../../../shared/services/materi_service.dart';

class MateriManagementPage extends ConsumerStatefulWidget {
  const MateriManagementPage({super.key});

  @override
  ConsumerState<MateriManagementPage> createState() =>
      _MateriManagementPageState();
}

class _MateriManagementPageState extends ConsumerState<MateriManagementPage> {
  JenisMateri? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kelola Materi Kajian'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddMateriDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Materi',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'dummy') {
                _createDummyData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'dummy',
                child: Row(
                  children: [
                    Icon(Icons.storage, size: 20),
                    SizedBox(width: 8),
                    Text('Buat Data Dummy'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildMateriList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Berdasarkan Jenis',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Semua', null),
              ...JenisMateri.values.map(
                (jenis) => _buildFilterChip(_getJenisDisplayName(jenis), jenis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, JenisMateri? jenis) {
    final isSelected = _selectedFilter == jenis;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? jenis : null;
        });
        ref.read(materiFilterProvider.notifier).state = jenis;
      },
      backgroundColor: Colors.grey[100],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildMateriList() {
    final materiAsync = ref.watch(filteredMateriProvider);

    return materiAsync.when(
      data: (materiList) {
        if (materiList.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(materiProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materiList.length,
            itemBuilder: (context, index) {
              final materi = materiList[index];
              return _buildMateriCard(materi);
            },
          ),
        );
      },
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
              onPressed: () => ref.invalidate(materiProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada materi kajian',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah materi baru atau buat data dummy untuk memulai',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _showAddMateriDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Materi'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _createDummyData,
                icon: const Icon(Icons.storage),
                label: const Text('Data Dummy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMateriCard(MateriModel materi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMateriDetailDialog(materi),
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
                      color: _getJenisColor(materi.jenis).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getJenisDisplayName(materi.jenis),
                      style: TextStyle(
                        color: _getJenisColor(materi.jenis),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditMateriDialog(materi);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(materi);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
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
                materi.nama,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (materi.deskripsi != null) ...[
                const SizedBox(height: 8),
                Text(
                  materi.deskripsi!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (materi.totalHalaman != null)
                    _buildInfoChip(
                      Icons.book,
                      '${materi.totalHalaman} hal',
                      Colors.blue,
                    ),
                  if (materi.totalAyat != null) ...[
                    if (materi.totalHalaman != null) const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.format_quote,
                      '${materi.totalAyat} ayat',
                      Colors.green,
                    ),
                  ],
                  if (materi.totalHadist != null) ...[
                    if (materi.totalHalaman != null || materi.totalAyat != null)
                      const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.article,
                      '${materi.totalHadist} hadist',
                      Colors.orange,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMateriDialog() {
    _showMateriFormDialog();
  }

  void _showEditMateriDialog(MateriModel materi) {
    _showMateriFormDialog(materi: materi);
  }

  void _showMateriFormDialog({MateriModel? materi}) {
    showDialog(
      context: context,
      builder: (context) => MateriFormDialog(materi: materi),
    );
  }

  void _showMateriDetailDialog(MateriModel materi) {
    showDialog(
      context: context,
      builder: (context) => MateriDetailDialog(materi: materi),
    );
  }

  void _showDeleteConfirmation(MateriModel materi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Materi'),
        content: Text('Yakin ingin menghapus materi "${materi.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMateri(materi);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMateri(MateriModel materi) async {
    try {
      await MateriService.deleteMateri(materi.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Materi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _createDummyData() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Membuat dummy data...'),
          backgroundColor: Colors.orange,
        ),
      );

      await MateriService.createDummyMateri();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 9 dummy materi berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getJenisDisplayName(JenisMateri jenis) {
    switch (jenis) {
      case JenisMateri.quran:
        return 'Al-Quran';
      case JenisMateri.hadist:
        return 'Hadist';
      case JenisMateri.nahwu:
        return 'Nahwu';
      case JenisMateri.shorof:
        return 'Shorof';
      case JenisMateri.lainnya:
        return 'Lainnya';
    }
  }

  Color _getJenisColor(JenisMateri jenis) {
    switch (jenis) {
      case JenisMateri.quran:
        return Colors.green;
      case JenisMateri.hadist:
        return Colors.blue;
      case JenisMateri.nahwu:
        return Colors.red;
      case JenisMateri.shorof:
        return Colors.pink;
      case JenisMateri.lainnya:
        return Colors.grey;
    }
  }
}

// Dialog untuk form tambah/edit materi
class MateriFormDialog extends StatefulWidget {
  final MateriModel? materi;

  const MateriFormDialog({super.key, this.materi});

  @override
  State<MateriFormDialog> createState() => _MateriFormDialogState();
}

class _MateriFormDialogState extends State<MateriFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _totalHalamanController = TextEditingController();
  final _totalAyatController = TextEditingController();
  final _totalHadistController = TextEditingController();

  JenisMateri _selectedJenis = JenisMateri.lainnya;

  @override
  void initState() {
    super.initState();
    if (widget.materi != null) {
      _namaController.text = widget.materi!.nama;
      _deskripsiController.text = widget.materi!.deskripsi ?? '';
      _totalHalamanController.text =
          widget.materi!.totalHalaman?.toString() ?? '';
      _totalAyatController.text = widget.materi!.totalAyat?.toString() ?? '';
      _totalHadistController.text =
          widget.materi!.totalHadist?.toString() ?? '';
      _selectedJenis = widget.materi!.jenis;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.materi == null ? 'Tambah Materi' : 'Edit Materi'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Materi *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama materi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JenisMateri>(
                  value: _selectedJenis,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Materi *',
                    border: OutlineInputBorder(),
                  ),
                  items: JenisMateri.values.map((jenis) {
                    return DropdownMenuItem(
                      value: jenis,
                      child: Text(_getJenisDisplayName(jenis)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedJenis = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _totalHalamanController,
                        decoration: const InputDecoration(
                          labelText: 'Total Halaman',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _totalAyatController,
                        decoration: const InputDecoration(
                          labelText: 'Total Ayat',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _totalHadistController,
                  decoration: const InputDecoration(
                    labelText: 'Total Hadist',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
          onPressed: _saveMateri,
          child: Text(widget.materi == null ? 'Tambah' : 'Simpan'),
        ),
      ],
    );
  }

  Future<void> _saveMateri() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final materi = MateriModel(
        id: widget.materi?.id ?? '',
        nama: _namaController.text.trim(),
        jenis: _selectedJenis,
        pengarang: null,
        deskripsi: _deskripsiController.text.trim().isEmpty
            ? null
            : _deskripsiController.text.trim(),
        totalHalaman: _totalHalamanController.text.trim().isEmpty
            ? null
            : int.tryParse(_totalHalamanController.text.trim()),
        totalAyat: _totalAyatController.text.trim().isEmpty
            ? null
            : int.tryParse(_totalAyatController.text.trim()),
        totalHadist: _totalHadistController.text.trim().isEmpty
            ? null
            : int.tryParse(_totalHadistController.text.trim()),
        tags: null,
        createdAt: widget.materi?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.materi == null) {
        await MateriService.createMateri(materi);
      } else {
        await MateriService.updateMateri(widget.materi!.id, materi);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.materi == null
                  ? '✅ Materi berhasil ditambahkan'
                  : '✅ Materi berhasil diupdate',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getJenisDisplayName(JenisMateri jenis) {
    switch (jenis) {
      case JenisMateri.quran:
        return 'Al-Quran';
      case JenisMateri.hadist:
        return 'Hadist';
      case JenisMateri.nahwu:
        return 'Nahwu';
      case JenisMateri.shorof:
        return 'Shorof';
      case JenisMateri.lainnya:
        return 'Lainnya';
    }
  }
}

// Dialog untuk detail materi
class MateriDetailDialog extends StatelessWidget {
  final MateriModel materi;

  const MateriDetailDialog({super.key, required this.materi});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(materi.nama),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Jenis', _getJenisDisplayName(materi.jenis)),
              if (materi.deskripsi != null)
                _buildDetailRow('Deskripsi', materi.deskripsi!),
              if (materi.totalHalaman != null)
                _buildDetailRow('Total Halaman', '${materi.totalHalaman}'),
              if (materi.totalAyat != null)
                _buildDetailRow('Total Ayat', '${materi.totalAyat}'),
              if (materi.totalHadist != null)
                _buildDetailRow('Total Hadist', '${materi.totalHadist}'),
              const SizedBox(height: 12),
              Text(
                'Dibuat: ${_formatDateTime(materi.createdAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                'Diupdate: ${_formatDateTime(materi.updatedAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getJenisDisplayName(JenisMateri jenis) {
    switch (jenis) {
      case JenisMateri.quran:
        return 'Al-Quran';
      case JenisMateri.hadist:
        return 'Hadist';
      case JenisMateri.nahwu:
        return 'Nahwu';
      case JenisMateri.shorof:
        return 'Shorof';
      case JenisMateri.lainnya:
        return 'Lainnya';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

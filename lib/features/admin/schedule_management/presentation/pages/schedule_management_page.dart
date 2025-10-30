import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/core/theme/app_theme.dart';

import '../models/jadwal_kegiatan_model.dart';
import '../providers/schedule_providers.dart';
import '../widgets/schedule_filter_menu.dart';
import '../widgets/schedule_list_view.dart';
import 'add_edit_jadwal_page.dart';

class ScheduleManagementPage extends ConsumerWidget {
  const ScheduleManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalAsync = ref.watch(jadwalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Jadwal'),
        actions: [const ScheduleFilterMenu()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(jadwalProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: jadwalAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorView(ref),
          data: (jadwalList) => ScheduleListView(
            jadwalList: jadwalList,
            onAddPressed: () => _showAddEditDialog(context, ref),
            onJadwalTap: (jadwal) =>
                _showAddEditDialog(context, ref, jadwal: jadwal),
            onJadwalDelete: (jadwal) =>
                _showDeleteConfirmation(context, ref, jadwal),
          ),
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
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(jadwalProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
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
                      onPressed: () => ref.invalidate(jadwalProvider),
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

  void _showAddEditDialog(
    BuildContext context,
    WidgetRef ref, {
    JadwalKegiatan? jadwal,
  }) async {
    final result = await Navigator.push<JadwalKegiatan>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditJadwalPage(jadwal: jadwal),
      ),
    );

    if (result != null) {
      // Jadwal sudah disimpan di AddEditJadwalPage
      // Hanya refresh provider untuk update UI
      ref.invalidate(jadwalProvider);
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    JadwalKegiatan jadwal,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jadwal.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${jadwal.tanggal.day}/${jadwal.tanggal.month}/${jadwal.tanggal.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        jadwal.waktuFormatted,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteJadwal(context, ref, jadwal);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteJadwal(
    BuildContext context,
    WidgetRef ref,
    JadwalKegiatan jadwal,
  ) async {
    try {
      EasyLoading.show(
        status: 'Menghapus jadwal...',
        maskType: EasyLoadingMaskType.black,
      );

      await FirebaseFirestore.instance
          .collection('jadwal')
          .doc(jadwal.id)
          .delete();
      final presensis = await FirebaseFirestore.instance
          .collection('presensi')
          .where("activity", isEqualTo: jadwal.id)
          .get();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in presensis.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      EasyLoading.dismiss();

      ref.invalidate(jadwalProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Jadwal "${jadwal.nama}" berhasil dihapus'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus jadwal: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

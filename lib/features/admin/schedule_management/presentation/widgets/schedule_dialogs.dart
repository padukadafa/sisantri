import 'package:flutter/material.dart';
import '../models/jadwal_kegiatan_model.dart';

/// Widget untuk dialog-dialog pada schedule management
class ScheduleDialogs {
  static void showConfirmDelete(
    BuildContext context,
    JadwalKegiatan jadwal,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus jadwal "${jadwal.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  static void showErrorWidget(
    BuildContext context,
    dynamic error,
    VoidCallback onRetry,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  static void showAddDialog(BuildContext context) {
    // TODO: Implement add dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add dialog belum diimplementasikan')),
    );
  }

  static void showEditDialog(BuildContext context, JadwalKegiatan jadwal) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit dialog untuk ${jadwal.nama} belum diimplementasikan',
        ),
      ),
    );
  }

  static void showDetailDialog(BuildContext context, JadwalKegiatan jadwal) {
    // TODO: Implement detail dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail untuk ${jadwal.nama} belum diimplementasikan'),
      ),
    );
  }

  static void showDuplicateDialog(BuildContext context, JadwalKegiatan jadwal) {
    // TODO: Implement duplicate dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplikasi ${jadwal.nama} belum diimplementasikan'),
      ),
    );
  }
}

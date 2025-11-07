import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/shared/services/announcement_service.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/providers/announcement_providers.dart';

class AnnouncementDeleteDialog extends ConsumerWidget {
  final String announcementId;

  const AnnouncementDeleteDialog({super.key, required this.announcementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Hapus Pengumuman'),
      content: const Text('Apakah Anda yakin ingin menghapus pengumuman ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => _handleDelete(context, ref),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);

    try {
      await AnnouncementService.deletePengumuman(announcementId);
      ref.invalidate(announcementProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengumuman berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus pengumuman: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

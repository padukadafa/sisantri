import 'package:flutter/material.dart';
import '../models/jadwal_kegiatan_model.dart';

/// Widget untuk menu actions pada schedule card
class ScheduleCardMenu extends StatelessWidget {
  final JadwalKegiatan jadwal;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const ScheduleCardMenu({
    super.key,
    required this.jadwal,
    this.onEdit,
    this.onDuplicate,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'duplicate':
            onDuplicate?.call();
            break;
          case 'toggle':
            onToggleStatus?.call();
            break;
          case 'delete':
            onDelete?.call();
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
    );
  }
}

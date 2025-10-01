import 'package:flutter/material.dart';
import '../models/pengumuman_model.dart';

/// Widget untuk menu actions pada list item pengumuman
class AnnouncementListItemMenu extends StatelessWidget {
  final Pengumuman pengumuman;
  final Function(String) onMenuSelected;

  const AnnouncementListItemMenu({
    super.key,
    required this.pengumuman,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onMenuSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 16),
              SizedBox(width: 8),
              Text('Lihat'),
            ],
          ),
        ),
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
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                pengumuman.isActive ? Icons.visibility_off : Icons.visibility,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(pengumuman.isActive ? 'Sembunyikan' : 'Tampilkan'),
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

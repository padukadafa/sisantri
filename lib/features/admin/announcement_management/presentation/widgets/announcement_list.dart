import 'package:flutter/material.dart';
import '../models/pengumuman_model.dart';
import 'announcement_empty_widget.dart';
import 'announcement_list_item_menu.dart';

/// Widget untuk menampilkan daftar pengumuman
class AnnouncementList extends StatelessWidget {
  final List<Pengumuman> pengumumanList;
  final Function(Pengumuman) onTap;
  final Function(Pengumuman) onEdit;
  final Function(Pengumuman) onDelete;
  final Function(Pengumuman) onToggleStatus;

  const AnnouncementList({
    super.key,
    required this.pengumumanList,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (pengumumanList.isEmpty) {
      return const AnnouncementEmptyWidget();
    }

    return ListView.builder(
      itemCount: pengumumanList.length,
      itemBuilder: (context, index) {
        final pengumuman = pengumumanList[index];
        return _buildAnnouncementCard(pengumuman);
      },
    );
  }

  Widget _buildAnnouncementCard(Pengumuman pengumuman) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: pengumuman.isHighPriority ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: pengumuman.isHighPriority
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        title: Text(
          pengumuman.judul,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          pengumuman.konten,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: AnnouncementListItemMenu(
          pengumuman: pengumuman,
          onMenuSelected: (value) {
            switch (value) {
              case 'view':
                onTap(pengumuman);
                break;
              case 'edit':
                onEdit(pengumuman);
                break;
              case 'toggle':
                onToggleStatus(pengumuman);
                break;
              case 'delete':
                onDelete(pengumuman);
                break;
            }
          },
        ),
        onTap: () => onTap(pengumuman),
      ),
    );
  }
}

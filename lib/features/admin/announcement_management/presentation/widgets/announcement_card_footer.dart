import 'package:flutter/material.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';

/// Widget footer untuk menampilkan tanggal dan view count
class AnnouncementCardFooter extends StatelessWidget {
  final PengumumanModel pengumuman;

  const AnnouncementCardFooter({super.key, required this.pengumuman});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          _formatDate(pengumuman.tanggalPost),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const Spacer(),
        Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${pengumuman.viewCount}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/announcement_model.dart';

/// Widget untuk menampilkan konten announcement
class AnnouncementCardContent extends StatelessWidget {
  final AnnouncementModel pengumuman;

  const AnnouncementCardContent({super.key, required this.pengumuman});

  @override
  Widget build(BuildContext context) {
    return Text(
      pengumuman.konten,
      style: TextStyle(color: Colors.grey[700], height: 1.4),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

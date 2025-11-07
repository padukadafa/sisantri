import 'package:flutter/material.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/announcement_model.dart';

/// Widget header untuk announcement card dengan judul dan menu popup
class AnnouncementCardHeader extends StatelessWidget {
  final AnnouncementModel pengumuman;

  const AnnouncementCardHeader({super.key, required this.pengumuman});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            pengumuman.judul,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

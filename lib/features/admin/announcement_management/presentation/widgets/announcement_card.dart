import 'package:flutter/material.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';
import 'announcement_card_header.dart';
import 'announcement_card_content.dart';
import 'announcement_card_chips.dart';
import 'announcement_card_footer.dart';

/// Widget untuk menampilkan card pengumuman individual
class AnnouncementCard extends StatelessWidget {
  final PengumumanModel pengumuman;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const AnnouncementCard({
    super.key,
    required this.pengumuman,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: pengumuman.isHighPriority ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: pengumuman.isHighPriority
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnnouncementCardHeader(
                pengumuman: pengumuman,
                onEdit: onEdit,
                onDelete: onDelete,
                onToggleStatus: onToggleStatus,
              ),
              const SizedBox(height: 8),

              AnnouncementCardContent(pengumuman: pengumuman),
              const SizedBox(height: 12),

              AnnouncementCardChips(pengumuman: pengumuman),
              const SizedBox(height: 8),

              AnnouncementCardFooter(pengumuman: pengumuman),
            ],
          ),
        ),
      ),
    );
  }
}

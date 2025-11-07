import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/announcement_model.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/providers/announcement_providers.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_card.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_delete_dialog.dart';

class AnnouncementListView extends ConsumerWidget {
  final List<AnnouncementModel> announcements;

  const AnnouncementListView({super.key, required this.announcements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(announcementProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return AnnouncementCard(
            pengumuman: announcement,
            onDelete: () => _showDeleteDialog(context, ref, announcement.id),
            onToggleStatus: () async {},
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String announcementId,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          AnnouncementDeleteDialog(announcementId: announcementId),
    );
  }
}

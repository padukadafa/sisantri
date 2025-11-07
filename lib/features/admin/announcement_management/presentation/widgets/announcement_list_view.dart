import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/providers/announcement_providers.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_card.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/pages/announcement_form_page.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_delete_dialog.dart';

class AnnouncementListView extends ConsumerWidget {
  final List<PengumumanModel> announcements;

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
            onEdit: () => _navigateToEditPage(context, announcement),
            onDelete: () => _showDeleteDialog(context, ref, announcement.id),
            onToggleStatus: () async {},
          );
        },
      ),
    );
  }

  void _navigateToEditPage(BuildContext context, PengumumanModel announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementFormPage(announcement: announcement),
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

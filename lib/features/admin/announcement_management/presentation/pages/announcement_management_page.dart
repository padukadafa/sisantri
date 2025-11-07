import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/providers/announcement_providers.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_stats_bar.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_empty_state.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_error_state.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_list_view.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_fab.dart';

class AnnouncementManagementPage extends ConsumerWidget {
  const AnnouncementManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementProvider);
    final stats = ref.watch(announcementStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Pengumuman')),
      body: Column(
        children: [
          AnnouncementStatsBar(stats: stats),
          Expanded(
            child: announcementsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => AnnouncementErrorState(error: error),
              data: (announcements) {
                if (announcements.isEmpty) {
                  return const AnnouncementEmptyState();
                }
                return AnnouncementListView(announcements: announcements);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const AnnouncementFab(),
    );
  }
}

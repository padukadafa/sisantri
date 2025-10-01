import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pengumuman_model.dart';
import '../providers/announcement_providers.dart';
import '../widgets/announcement_stats_bar.dart';
import '../widgets/announcement_search_filter.dart';
import '../widgets/announcement_list.dart';
import '../widgets/announcement_dialogs.dart';
import '../widgets/announcement_error_widget.dart';
import '../services/announcement_service.dart';
import '../utils/announcement_filter.dart';

/// Halaman manajemen pengumuman yang telah dipecah
class AnnouncementManagementPageClean extends ConsumerStatefulWidget {
  const AnnouncementManagementPageClean({super.key});

  @override
  ConsumerState<AnnouncementManagementPageClean> createState() =>
      _AnnouncementManagementPageCleanState();
}

class _AnnouncementManagementPageCleanState
    extends ConsumerState<AnnouncementManagementPageClean> {
  String _selectedFilter = 'semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final AnnouncementService _announcementService = AnnouncementService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pengumumanAsync = ref.watch(announcementProvider);
    final stats = ref.watch(announcementStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengumuman'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AnnouncementDialogs.showAddEditDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          AnnouncementStatsBar(stats: stats),

          AnnouncementSearchFilter(
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedFilter: _selectedFilter,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            onFilterChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),

          Expanded(
            child: pengumumanAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => AnnouncementErrorWidget(
                error: error,
                onRetry: () => setState(() {}),
              ),
              data: (pengumumanList) {
                final filteredList = AnnouncementFilter.filterPengumuman(
                  pengumumanList,
                  _searchQuery,
                  _selectedFilter,
                );

                return AnnouncementList(
                  pengumumanList: filteredList,
                  onTap: (pengumuman) =>
                      AnnouncementDialogs.showDetailDialog(context, pengumuman),
                  onEdit: (pengumuman) => AnnouncementDialogs.showAddEditDialog(
                    context,
                    pengumuman: pengumuman,
                  ),
                  onDelete: (pengumuman) => _confirmDelete(pengumuman),
                  onToggleStatus: (pengumuman) => _toggleStatus(pengumuman),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Pengumuman pengumuman) {
    AnnouncementDialogs.showConfirmDelete(
      context,
      pengumuman,
      () => _announcementService.deleteAnnouncement(pengumuman.id),
    );
  }

  void _toggleStatus(Pengumuman pengumuman) {
    _announcementService.toggleAnnouncementStatus(
      pengumuman.id,
      pengumuman.isActive,
    );
  }
}

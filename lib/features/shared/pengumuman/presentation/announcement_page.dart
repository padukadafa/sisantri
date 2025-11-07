import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/announcement_model.dart';
import 'package:sisantri/features/shared/pengumuman/presentation/pages/announcement_detail_page.dart';
import 'package:sisantri/shared/services/announcement_service.dart';

/// Provider untuk announcement
final announcementProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return AnnouncementService.getActivePengumuman();
});

/// Provider untuk filter announcement
final announcementFilterProvider = StateProvider<String>((ref) => 'all');

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementStream = ref.watch(announcementProvider);
    final currentFilter = ref.watch(announcementFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              ref.read(announcementFilterProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'penting', child: Text('Penting')),
              const PopupMenuItem(value: 'umum', child: Text('Umum')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Header
          if (currentFilter != 'all')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter: ${_getFilterLabel(currentFilter)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(announcementFilterProvider.notifier).state =
                          'all';
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: announcementStream.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(announcementProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (announcementList) {
                // Filter announcement berdasarkan filter yang dipilih
                final filteredPengumuman = _filterPengumuman(
                  announcementList,
                  currentFilter,
                );

                if (filteredPengumuman.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.announcement_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentFilter == 'all'
                              ? 'Belum ada announcement'
                              : 'Tidak ada announcement ${_getFilterLabel(currentFilter).toLowerCase()}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(announcementProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPengumuman.length,
                    itemBuilder: (context, index) {
                      final announcement = filteredPengumuman[index];
                      return _buildPengumumanCard(context, announcement);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengumumanCard(
    BuildContext context,
    AnnouncementModel announcement,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: announcement.isHighPriority
              ? Colors.red[200]!
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showPengumumanDetail(context, announcement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan status dan tanggal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: announcement.isHighPriority
                          ? Colors.red[50]
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: announcement.isHighPriority
                            ? Colors.red[200]!
                            : AppTheme.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      announcement.isHighPriority
                          ? Icons.priority_high
                          : Icons.campaign,
                      color: announcement.isHighPriority
                          ? Colors.red[600]
                          : AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title dengan badge penting
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                announcement.judul,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E2E2E),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (announcement.isHighPriority)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.red[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'PENTING',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Content preview
                        Text(
                          announcement.konten,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Footer info
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              announcement.createdByName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'dd MMM yyyy HH:mm',
                              ).format(announcement.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPengumumanDetail(
    BuildContext context,
    AnnouncementModel announcement,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AnnouncementDetailPage(announcement: announcement),
      ),
    );
  }

  List<AnnouncementModel> _filterPengumuman(
    List<AnnouncementModel> announcementList,
    String filter,
  ) {
    switch (filter) {
      case 'penting':
        return announcementList.where((p) => p.isHighPriority).toList();
      case 'umum':
        return announcementList.where((p) => !p.isHighPriority).toList();
      default:
        return announcementList;
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'penting':
        return 'Penting';
      case 'umum':
        return 'Umum';
      default:
        return 'Semua';
    }
  }
}

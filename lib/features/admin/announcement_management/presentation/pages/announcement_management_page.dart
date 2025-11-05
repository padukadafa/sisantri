import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/shared/services/announcement_service.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/providers/announcement_providers.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_card.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/widgets/announcement_stats_bar.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/pages/announcement_form_page.dart';

/// Halaman manajemen pengumuman untuk admin
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
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(announcementProvider);
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (announcements) {
                if (announcements.isEmpty) {
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
                          'Belum ada pengumuman',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AnnouncementFormPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Buat Pengumuman'),
                        ),
                      ],
                    ),
                  );
                }

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
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnnouncementFormPage(
                                announcement: announcement,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          _showDeleteConfirmation(
                            context,
                            ref,
                            announcement.id,
                          );
                        },
                        onToggleStatus: () async {},
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnnouncementFormPage(),
            ),
          );
        },
        label: Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String announcementId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pengumuman ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AnnouncementService.deletePengumuman(announcementId);

                ref.invalidate(announcementProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengumuman berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus pengumuman: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

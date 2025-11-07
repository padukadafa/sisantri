import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';
import 'package:sisantri/shared/services/announcement_service.dart';

final announcementProvider = StreamProvider<List<PengumumanModel>>((ref) {
  return AnnouncementService.getAllPengumuman();
});

final activeAnnouncementProvider = Provider<List<PengumumanModel>>((ref) {
  final announcements = ref.watch(announcementProvider).asData?.value ?? [];
  return announcements.where((a) => a.isActive && !a.isExpired).toList();
});

final announcementStatsProvider = Provider<Map<String, int>>((ref) {
  final announcements = ref.watch(announcementProvider).asData?.value ?? [];

  return {
    'total': announcements.length,
    'active': announcements.where((a) => a.isActive).length,
    'expired': announcements.where((a) => a.isExpired).length,
    'high_priority': announcements.where((a) => a.isHighPriority).length,
    'draft': announcements.where((a) => !a.isActive).length,
  };
});

final announcementByCategoryProvider =
    Provider.family<List<PengumumanModel>, String>((ref, category) {
      final announcements = ref.watch(announcementProvider).asData?.value ?? [];

      if (category == 'all') return announcements;
      return announcements.where((a) => a.kategori == category).toList();
    });

final announcementByPriorityProvider =
    Provider.family<List<PengumumanModel>, String>((ref, priority) {
      final announcements = ref.watch(announcementProvider).asData?.value ?? [];

      if (priority == 'all') return announcements;
      return announcements.where((a) => a.prioritas == priority).toList();
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';

/// Provider untuk semua pengumuman
final announcementProvider = StreamProvider<List<PengumumanModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('pengumuman')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map(
              (doc) => PengumumanModel.fromJson({'id': doc.id, ...doc.data()}),
            )
            .toList();
      });
});

/// Provider untuk pengumuman yang aktif saja
final activeAnnouncementProvider = Provider<List<PengumumanModel>>((ref) {
  final announcements = ref.watch(announcementProvider).asData?.value ?? [];
  return announcements.where((a) => a.isActive && !a.isExpired).toList();
});

/// Provider untuk statistik pengumuman
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

/// Provider untuk pengumuman berdasarkan kategori
final announcementByCategoryProvider =
    Provider.family<List<PengumumanModel>, String>((ref, category) {
      final announcements = ref.watch(announcementProvider).asData?.value ?? [];

      if (category == 'all') return announcements;
      return announcements.where((a) => a.kategori == category).toList();
    });

/// Provider untuk pengumuman berdasarkan prioritas
final announcementByPriorityProvider =
    Provider.family<List<PengumumanModel>, String>((ref, priority) {
      final announcements = ref.watch(announcementProvider).asData?.value ?? [];

      if (priority == 'all') return announcements;
      return announcements.where((a) => a.prioritas == priority).toList();
    });

import '../entities/pengumuman.dart';

abstract class PengumumanRepository {
  /// Get all pengumuman with optional filters
  Future<List<Pengumuman>> getAllPengumuman({
    String? kategori,
    String? targetAudience,
    bool? isPublished,
  });

  /// Get pengumuman by ID
  Future<Pengumuman> getPengumumanById(String id);

  /// Get pengumuman for specific user based on role and class
  Future<List<Pengumuman>> getPengumumanForUser({
    required String userRole,
    String? userClass,
  });

  /// Create new pengumuman
  Future<String> createPengumuman(Pengumuman pengumuman);

  /// Update existing pengumuman
  Future<void> updatePengumuman(Pengumuman pengumuman);

  /// Delete pengumuman
  Future<void> deletePengumuman(String id);

  /// Mark pengumuman as read by user
  Future<void> markAsRead({
    required String pengumumanId,
    required String userId,
  });

  /// Check if user has read pengumuman
  Future<bool> hasUserRead({
    required String pengumumanId,
    required String userId,
  });

  /// Increment view count
  Future<void> incrementViewCount(String id);
}

import '../models/pengumuman_model.dart';

abstract class PengumumanRemoteDataSource {
  /// Get all pengumuman with optional filters
  Future<List<PengumumanModel>> getAllPengumuman({
    String? kategori,
    String? targetAudience,
    bool? isPublished,
  });

  /// Get pengumuman by ID
  Future<PengumumanModel> getPengumumanById(String id);

  /// Get pengumuman for specific user based on role and class
  Future<List<PengumumanModel>> getPengumumanForUser({
    required String userRole,
    String? userClass,
  });

  /// Create new pengumuman
  Future<String> createPengumuman(PengumumanModel pengumuman);

  /// Update existing pengumuman
  Future<void> updatePengumuman(PengumumanModel pengumuman);

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

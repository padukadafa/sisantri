import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  /// Get all announcement with optional filters
  Future<List<Announcement>> getAllAnnouncement({
    String? kategori,
    String? targetAudience,
    bool? isPublished,
  });

  /// Get announcement by ID
  Future<Announcement> getAnnouncementById(String id);

  /// Get announcement for specific user based on role and class
  Future<List<Announcement>> getAnnouncementForUser({
    required String userRole,
    String? userClass,
  });

  /// Create new announcement
  Future<String> createAnnouncement(Announcement announcement);

  /// Update existing announcement
  Future<void> updateAnnouncement(Announcement announcement);

  /// Delete announcement
  Future<void> deleteAnnouncement(String id);

  /// Mark announcement as read by user
  Future<void> markAsRead({
    required String announcementId,
    required String userId,
  });

  /// Check if user has read announcement
  Future<bool> hasUserRead({
    required String announcementId,
    required String userId,
  });

  /// Increment view count
  Future<void> incrementViewCount(String id);
}

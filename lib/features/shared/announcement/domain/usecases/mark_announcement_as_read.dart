import '../repositories/announcement_repository.dart';

class MarkPengumumanAsRead {
  final AnnouncementRepository repository;

  MarkPengumumanAsRead(this.repository);

  Future<void> call({
    required String announcementId,
    required String userId,
  }) async {
    return await repository.markAsRead(
      announcementId: announcementId,
      userId: userId,
    );
  }
}

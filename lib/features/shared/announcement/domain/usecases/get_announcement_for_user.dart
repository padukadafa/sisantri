import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncementForUser {
  final AnnouncementRepository repository;

  GetAnnouncementForUser(this.repository);

  Future<List<Announcement>> call({
    required String userRole,
    String? userClass,
  }) async {
    return await repository.getAnnouncementForUser(
      userRole: userRole,
      userClass: userClass,
    );
  }
}

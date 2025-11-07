import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class CreateAnnouncement {
  final AnnouncementRepository repository;

  CreateAnnouncement(this.repository);

  Future<String> call(Announcement pengumuman) async {
    return await repository.createAnnouncement(pengumuman);
  }
}

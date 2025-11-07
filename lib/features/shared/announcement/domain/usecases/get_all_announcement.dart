import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class GetAllAnnouncement {
  final AnnouncementRepository repository;

  GetAllAnnouncement(this.repository);

  Future<List<Announcement>> call({
    String? kategori,
    String? targetAudience,
    bool? isPublished,
  }) async {
    return await repository.getAllAnnouncement(
      kategori: kategori,
      targetAudience: targetAudience,
      isPublished: isPublished,
    );
  }
}

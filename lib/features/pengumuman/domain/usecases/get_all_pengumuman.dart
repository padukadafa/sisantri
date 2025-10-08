import '../entities/pengumuman.dart';
import '../repositories/pengumuman_repository.dart';

class GetAllPengumuman {
  final PengumumanRepository repository;

  GetAllPengumuman(this.repository);

  Future<List<Pengumuman>> call({
    String? kategori,
    String? targetAudience,
    bool? isPublished,
  }) async {
    return await repository.getAllPengumuman(
      kategori: kategori,
      targetAudience: targetAudience,
      isPublished: isPublished,
    );
  }
}

import '../entities/pengumuman.dart';
import '../repositories/pengumuman_repository.dart';

class GetPengumumanForUser {
  final PengumumanRepository repository;

  GetPengumumanForUser(this.repository);

  Future<List<Pengumuman>> call({
    required String userRole,
    String? userClass,
  }) async {
    return await repository.getPengumumanForUser(
      userRole: userRole,
      userClass: userClass,
    );
  }
}

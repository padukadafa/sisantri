import '../entities/pengumuman.dart';
import '../repositories/pengumuman_repository.dart';

class CreatePengumuman {
  final PengumumanRepository repository;

  CreatePengumuman(this.repository);

  Future<String> call(Pengumuman pengumuman) async {
    return await repository.createPengumuman(pengumuman);
  }
}

import '../repositories/pengumuman_repository.dart';

class MarkPengumumanAsRead {
  final PengumumanRepository repository;

  MarkPengumumanAsRead(this.repository);

  Future<void> call({
    required String pengumumanId,
    required String userId,
  }) async {
    return await repository.markAsRead(
      pengumumanId: pengumumanId,
      userId: userId,
    );
  }
}

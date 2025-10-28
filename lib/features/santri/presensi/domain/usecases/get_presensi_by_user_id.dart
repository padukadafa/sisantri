import '../entities/presensi.dart';
import '../repositories/presensi_repository.dart';
import '../../../../core/utils/result.dart';

/// Use case untuk mendapatkan presensi berdasarkan user ID
class GetPresensiByUserId {
  final PresensiRepository repository;

  const GetPresensiByUserId(this.repository);

  Future<Result<List<Presensi>>> call(String userId) async {
    return await repository.getPresensiByUserId(userId);
  }
}

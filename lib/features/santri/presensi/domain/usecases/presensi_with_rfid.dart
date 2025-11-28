import '../entities/presensi.dart';
import '../repositories/presensi_repository.dart';
import 'package:sisantri/core/utils/result.dart';
import 'package:sisantri/core/error/failures.dart';
import 'package:sisantri/features/shared/auth/domain/repositories/auth_repository.dart';

/// Use case untuk presensi dengan RFID
class PresensiWithRfid {
  final PresensiRepository presensiRepository;
  final AuthRepository authRepository;

  const PresensiWithRfid({
    required this.presensiRepository,
    required this.authRepository,
  });

  Future<Result<Presensi>> call({
    required String rfidCardId,
    required String jadwalId,
    required DateTime tanggal,
    String? keterangan,
  }) async {
    // Validasi input
    if (rfidCardId.isEmpty) {
      return Error(
        ValidationFailure(message: 'RFID Card ID tidak boleh kosong'),
      );
    }

    if (jadwalId.isEmpty) {
      return Error(ValidationFailure(message: 'Jadwal ID tidak boleh kosong'));
    }

    // Cari user berdasarkan RFID
    final userResult = await authRepository.getUserByRfid(rfidCardId);

    return userResult.fold(
      onSuccess: (user) {
        if (user == null) {
          return Error(ValidationFailure(message: 'RFID Card tidak terdaftar'));
        }

        // Lakukan presensi
        return presensiRepository.presensiWithRfid(
          rfidCardId: rfidCardId,
          jadwalId: jadwalId,
          tanggal: tanggal,
          keterangan: keterangan,
        );
      },
      onError: (failure) => Error(failure),
    );
  }
}

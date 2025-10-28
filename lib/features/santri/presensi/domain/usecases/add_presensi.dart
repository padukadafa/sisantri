import '../entities/presensi.dart';
import '../repositories/presensi_repository.dart';
import 'package:sisantri/core/utils/result.dart';
import 'package:sisantri/core/error/failures.dart';

/// Use case untuk menambah presensi
class AddPresensi {
  final PresensiRepository repository;

  const AddPresensi(this.repository);

  Future<Result<Presensi>> call(Presensi presensi) async {
    // Validasi input
    if (presensi.userId.isEmpty) {
      return Error(ValidationFailure(message: 'User ID tidak boleh kosong'));
    }

    // Cek apakah sudah presensi hari ini
    final existingPresensi = await repository.getPresensiByUserAndDate(
      userId: presensi.userId,
      date: presensi.tanggal,
    );

    return existingPresensi.fold(
      onSuccess: (existing) {
        if (existing != null) {
          return Error(
            ValidationFailure(
              message: 'Sudah melakukan presensi pada tanggal ini',
            ),
          );
        }
        // Jika belum ada presensi, tambahkan yang baru
        return repository.addPresensi(presensi);
      },
      onError: (failure) {
        // Jika error saat cek, tetap lanjutkan tambah presensi
        return repository.addPresensi(presensi);
      },
    );
  }
}

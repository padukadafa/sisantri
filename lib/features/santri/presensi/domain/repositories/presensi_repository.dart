import '../entities/presensi.dart';
import '../../../../core/utils/result.dart';

/// Abstract Repository untuk Presensi operations
abstract class PresensiRepository {
  /// Tambah presensi baru
  Future<Result<Presensi>> addPresensi(Presensi presensi);

  /// Get presensi berdasarkan user ID dan tanggal
  Future<Result<Presensi?>> getPresensiByUserAndDate({
    required String userId,
    required DateTime date,
  });

  /// Get list presensi berdasarkan user ID
  Future<Result<List<Presensi>>> getPresensiByUserId(String userId);

  /// Get list presensi berdasarkan tanggal
  Future<Result<List<Presensi>>> getPresensiByDate(DateTime date);

  /// Get list presensi berdasarkan range tanggal
  Future<Result<List<Presensi>>> getPresensiByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update presensi
  Future<Result<Presensi>> updatePresensi(Presensi presensi);

  /// Delete presensi
  Future<Result<void>> deletePresensi(String presensiId);

  /// Get statistik presensi user
  Future<Result<Map<String, int>>> getPresensiStats(String userId);

  /// Presensi dengan RFID
  Future<Result<Presensi>> presensiWithRfid({
    required String rfidCardId,
    required DateTime tanggal,
    String? keterangan,
  });
}

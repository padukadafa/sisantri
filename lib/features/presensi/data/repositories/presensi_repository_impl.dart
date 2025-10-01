import '../../domain/entities/presensi.dart';
import '../../domain/repositories/presensi_repository.dart';
import '../datasources/presensi_remote_data_source.dart';
import '../models/presensi_model.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';

/// Implementation Presensi Repository
class PresensiRepositoryImpl implements PresensiRepository {
  final PresensiRemoteDataSource remoteDataSource;

  PresensiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Presensi>> addPresensi(Presensi presensi) async {
    try {
      final presensiModel = PresensiModel.fromEntity(presensi);
      final result = await remoteDataSource.addPresensi(presensiModel);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Presensi?>> getPresensiByUserAndDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final result = await remoteDataSource.getPresensiByUserAndDate(
        userId: userId,
        date: date,
      );
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Presensi>>> getPresensiByUserId(String userId) async {
    try {
      final result = await remoteDataSource.getPresensiByUserId(userId);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Presensi>>> getPresensiByDate(DateTime date) async {
    try {
      final result = await remoteDataSource.getPresensiByDate(date);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Presensi>>> getPresensiByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await remoteDataSource.getPresensiByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Presensi>> updatePresensi(Presensi presensi) async {
    try {
      final presensiModel = PresensiModel.fromEntity(presensi);
      final result = await remoteDataSource.updatePresensi(presensiModel);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePresensi(String presensiId) async {
    try {
      await remoteDataSource.deletePresensi(presensiId);
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Map<String, int>>> getPresensiStats(String userId) async {
    try {
      final result = await remoteDataSource.getPresensiStats(userId);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Presensi>> presensiWithRfid({
    required String rfidCardId,
    required DateTime tanggal,
    String? keterangan,
  }) async {
    try {
      final result = await remoteDataSource.presensiWithRfid(
        rfidCardId: rfidCardId,
        tanggal: tanggal,
        keterangan: keterangan,
      );
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }
}

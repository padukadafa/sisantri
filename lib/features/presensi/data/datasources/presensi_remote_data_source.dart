import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/presensi_model.dart';
import '../../domain/entities/presensi.dart';

/// Abstract DataSource untuk Presensi remote operations
abstract class PresensiRemoteDataSource {
  /// Tambah presensi baru
  Future<PresensiModel> addPresensi(PresensiModel presensi);

  /// Get presensi berdasarkan user ID dan tanggal
  Future<PresensiModel?> getPresensiByUserAndDate({
    required String userId,
    required DateTime date,
  });

  /// Get list presensi berdasarkan user ID
  Future<List<PresensiModel>> getPresensiByUserId(String userId);

  /// Get list presensi berdasarkan tanggal
  Future<List<PresensiModel>> getPresensiByDate(DateTime date);

  /// Get list presensi berdasarkan range tanggal
  Future<List<PresensiModel>> getPresensiByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update presensi
  Future<PresensiModel> updatePresensi(PresensiModel presensi);

  /// Delete presensi
  Future<void> deletePresensi(String presensiId);

  /// Get statistik presensi user
  Future<Map<String, int>> getPresensiStats(String userId);

  /// Presensi dengan RFID
  Future<PresensiModel> presensiWithRfid({
    required String rfidCardId,
    required DateTime tanggal,
    String? keterangan,
  });
}

/// Implementation Presensi Remote DataSource dengan Firebase
class PresensiRemoteDataSourceImpl implements PresensiRemoteDataSource {
  final FirebaseFirestore _firestore;

  PresensiRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<PresensiModel> addPresensi(PresensiModel presensi) async {
    try {
      final docRef = await _firestore
          .collection('presensi')
          .add(presensi.toJson());

      final newPresensi = presensi.copyWith(id: docRef.id);
      await docRef.update({'id': docRef.id});

      return newPresensi;
    } catch (e) {
      throw Exception('Add presensi error: $e');
    }
  }

  @override
  Future<PresensiModel?> getPresensiByUserAndDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      // Buat range tanggal untuk hari tersebut
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('presensi')
          .where('userId', isEqualTo: userId)
          .where(
            'tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return PresensiModel.fromJson({'id': doc.id, ...doc.data()});
    } catch (e) {
      throw Exception('Get presensi by user and date error: $e');
    }
  }

  @override
  Future<List<PresensiModel>> getPresensiByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('presensi')
          .where('userId', isEqualTo: userId)
          .orderBy('tanggal', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return PresensiModel.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Get presensi by user ID error: $e');
    }
  }

  @override
  Future<List<PresensiModel>> getPresensiByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('presensi')
          .where(
            'tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs.map((doc) {
        return PresensiModel.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Get presensi by date error: $e');
    }
  }

  @override
  Future<List<PresensiModel>> getPresensiByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('presensi')
          .where(
            'tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('tanggal', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return PresensiModel.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Get presensi by date range error: $e');
    }
  }

  @override
  Future<PresensiModel> updatePresensi(PresensiModel presensi) async {
    try {
      final updatedPresensi = presensi.copyWith(
        // Bisa tambah updatedAt field jika diperlukan
      );

      await _firestore
          .collection('presensi')
          .doc(presensi.id)
          .update(updatedPresensi.toJson());

      return updatedPresensi;
    } catch (e) {
      throw Exception('Update presensi error: $e');
    }
  }

  @override
  Future<void> deletePresensi(String presensiId) async {
    try {
      await _firestore.collection('presensi').doc(presensiId).delete();
    } catch (e) {
      throw Exception('Delete presensi error: $e');
    }
  }

  @override
  Future<Map<String, int>> getPresensiStats(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('presensi')
          .where('userId', isEqualTo: userId)
          .get();

      final stats = <String, int>{
        'hadir': 0,
        'izin': 0,
        'sakit': 0,
        'alpha': 0,
      };

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'hadir';
        final key = status.toLowerCase();
        if (stats.containsKey(key)) {
          stats[key] = stats[key]! + 1;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Get presensi stats error: $e');
    }
  }

  @override
  Future<PresensiModel> presensiWithRfid({
    required String rfidCardId,
    required DateTime tanggal,
    String? keterangan,
  }) async {
    try {
      // Pertama, cari user berdasarkan RFID
      final userQuerySnapshot = await _firestore
          .collection('users')
          .where('rfidCardId', isEqualTo: rfidCardId)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isEmpty) {
        throw Exception('RFID Card tidak terdaftar');
      }

      final userId = userQuerySnapshot.docs.first.id;

      // Cek apakah sudah presensi hari ini
      final existingPresensi = await getPresensiByUserAndDate(
        userId: userId,
        date: tanggal,
      );

      if (existingPresensi != null) {
        throw Exception('Sudah melakukan presensi pada tanggal ini');
      }

      // Buat presensi baru
      final presensi = PresensiModel(
        id: '', // Akan di-set oleh Firestore
        userId: userId,
        tanggal: tanggal,
        status: StatusPresensi.hadir,
        keterangan: keterangan,
        poinDiperoleh: Presensi.getPoinByStatus(StatusPresensi.hadir),
        createdAt: DateTime.now(),
      );

      return await addPresensi(presensi);
    } catch (e) {
      throw Exception('Presensi with RFID error: $e');
    }
  }
}

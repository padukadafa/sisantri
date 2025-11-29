import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/shared/models/jadwal_kegiatan_model.dart';
import '../models/user_model.dart';
import '../models/presensi_model.dart';

/// Service untuk mengelola attendance/presensi
class AttendanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> generateDefaultAttendanceForJadwal({
    required String jadwalId,
    required String createdBy,
    required String createdByName,
    required JadwalModel jadwal,
    List<String>? specificSantriIds,
  }) async {
    try {
      List<UserModel> activeSantri;

      if (specificSantriIds != null && specificSantriIds.isNotEmpty) {
        final userFutures = specificSantriIds.map(
          (id) => _firestore.collection('users').doc(id).get(),
        );
        final userDocs = await Future.wait(userFutures);

        activeSantri = userDocs
            .where((doc) => doc.exists)
            .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()!}))
            .where((user) => user.isSantri)
            .toList();
      } else {
        final usersSnapshot = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'santri')
            .where("statusAktif", isEqualTo: true)
            .get();

        activeSantri = usersSnapshot.docs
            .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList();
      }

      final existingRecords = await _firestore
          .collection('presensi')
          .where('jadwalId', isEqualTo: jadwalId)
          .get();

      final existingSantriIds = existingRecords.docs
          .map((doc) => doc.data()['userId'] as String)
          .toSet();

      final santriNeedingRecords = activeSantri
          .where((santri) => !existingSantriIds.contains(santri.id))
          .toList();

      if (santriNeedingRecords.isEmpty) return;

      final batch = _firestore.batch();
      final timestamp = Timestamp.now();

      for (final santri in santriNeedingRecords) {
        final newRecordRef = _firestore.collection('presensi').doc();
        final attendanceData = {
          'userId': santri.id,
          'userName': santri.nama,
          'jadwalId': jadwalId,
          'status': 'alpha',
          'timestamp': timestamp,
          'createdAt': FieldValue.serverTimestamp(),
          'recordedBy': createdBy,
          'recordedByName': createdByName,
          'isManual': true,
          'keterangan': 'Auto-generated default record',
          'poin': jadwal.poin,
        };

        batch.set(newRecordRef, attendanceData);
      }

      await batch.commit();
      await _firestore.collection('jadwal').doc(jadwalId).update({
        'totalPresensi': santriNeedingRecords.length,
        'presensiAlpha': santriNeedingRecords.length,
      });
    } catch (e) {
      throw Exception('Failed to generate default attendance: $e');
    }
  }

  static Future<void> updateAttendanceStatus({
    required String attendanceId,
    required StatusPresensi newStatus,
    required String updatedBy,
    required String updatedByName,
    String? keterangan,
  }) async {
    try {
      await _firestore.collection('presensi').doc(attendanceId).update({
        'status': newStatus.label.toLowerCase(),
        'keterangan': keterangan ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': updatedBy,
        'updatedByName': updatedByName,
      });
    } catch (e) {
      throw Exception('Failed to update attendance status: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendanceForJadwal(
    String jadwalId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('presensi')
          .where('jadwalId', isEqualTo: jadwalId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get attendance for jadwal: $e');
    }
  }
}

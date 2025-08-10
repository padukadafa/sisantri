import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/jadwal_pengajian_model.dart';
import '../models/jadwal_kegiatan_model.dart';
import '../models/presensi_model.dart';
import '../models/pengumuman_model.dart';
import '../models/leaderboard_model.dart';

/// Service untuk mengelola operasi Firestore
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== USER OPERATIONS =====

  /// Get semua users
  static Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  /// Get user by ID
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Error mengambil data user: $e');
    }
  }

  /// Update poin user
  static Future<void> updateUserPoin(String userId, int poin) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'poin': FieldValue.increment(poin),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error mengupdate poin user: $e');
    }
  }

  // ===== JADWAL PENGAJIAN OPERATIONS =====

  /// Get jadwal pengajian
  static Stream<List<JadwalPengajianModel>> getJadwalPengajian() {
    return _firestore
        .collection('jadwal_pengajian')
        .orderBy('tanggal', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => JadwalPengajianModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }),
              )
              .toList(),
        );
  }

  /// Tambah jadwal pengajian
  static Future<void> addJadwalPengajian(JadwalPengajianModel jadwal) async {
    try {
      await _firestore.collection('jadwal_pengajian').add(jadwal.toJson());
    } catch (e) {
      throw Exception('Error menambah jadwal pengajian: $e');
    }
  }

  /// Update jadwal pengajian
  static Future<void> updateJadwalPengajian(
    String id,
    JadwalPengajianModel jadwal,
  ) async {
    try {
      await _firestore
          .collection('jadwal_pengajian')
          .doc(id)
          .update(jadwal.toJson());
    } catch (e) {
      throw Exception('Error mengupdate jadwal pengajian: $e');
    }
  }

  /// Delete jadwal pengajian
  static Future<void> deleteJadwalPengajian(String id) async {
    try {
      await _firestore.collection('jadwal_pengajian').doc(id).delete();
    } catch (e) {
      throw Exception('Error menghapus jadwal pengajian: $e');
    }
  }

  // ===== JADWAL KEGIATAN OPERATIONS =====

  /// Get jadwal kegiatan
  static Stream<List<JadwalKegiatanModel>> getJadwalKegiatan() {
    return _firestore
        .collection('jadwal_kegiatan')
        .orderBy('tanggal', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    JadwalKegiatanModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }

  /// Get jadwal kegiatan hari ini dan besok
  static Stream<List<JadwalKegiatanModel>> getUpcomingKegiatan() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 2); // sampai besok

    return _firestore
        .collection('jadwal_kegiatan')
        .where('tanggal', isGreaterThanOrEqualTo: now)
        .where('tanggal', isLessThan: tomorrow)
        .orderBy('tanggal', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    JadwalKegiatanModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }

  /// Tambah jadwal kegiatan
  static Future<void> addJadwalKegiatan(JadwalKegiatanModel jadwal) async {
    try {
      await _firestore.collection('jadwal_kegiatan').add(jadwal.toJson());
    } catch (e) {
      throw Exception('Error menambah jadwal kegiatan: $e');
    }
  }

  // ===== PRESENSI OPERATIONS =====

  /// Get presensi by user ID
  static Stream<List<PresensiModel>> getPresensiByUser(String userId) {
    return _firestore
        .collection('presensi')
        .where('userId', isEqualTo: userId)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PresensiModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }

  /// Get presensi hari ini untuk user
  static Future<PresensiModel?> getTodayPresensi(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final query = await _firestore
          .collection('presensi')
          .where('userId', isEqualTo: userId)
          .where('tanggal', isGreaterThanOrEqualTo: startOfDay)
          .where('tanggal', isLessThanOrEqualTo: endOfDay)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return PresensiModel.fromJson({'id': doc.id, ...doc.data()});
      }
      return null;
    } catch (e) {
      throw Exception('Error mengambil presensi hari ini: $e');
    }
  }

  /// Tambah presensi
  static Future<void> addPresensi(PresensiModel presensi) async {
    try {
      // Tambah presensi
      await _firestore.collection('presensi').add(presensi.toJson());

      // Update poin user
      final poin = PresensiModel.getPoinByStatus(presensi.status);
      await updateUserPoin(presensi.userId, poin);
    } catch (e) {
      throw Exception('Error menambah presensi: $e');
    }
  }

  // ===== PENGUMUMAN OPERATIONS =====

  /// Get pengumuman
  static Stream<List<PengumumanModel>> getPengumuman() {
    return _firestore
        .collection('pengumuman')
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    PengumumanModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }

  /// Get pengumuman terbaru (limit 5)
  static Stream<List<PengumumanModel>> getRecentPengumuman() {
    return _firestore
        .collection('pengumuman')
        .orderBy('tanggal', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    PengumumanModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }

  /// Tambah pengumuman
  static Future<void> addPengumuman(PengumumanModel pengumuman) async {
    try {
      await _firestore.collection('pengumuman').add(pengumuman.toJson());
    } catch (e) {
      throw Exception('Error menambah pengumuman: $e');
    }
  }

  // ===== LEADERBOARD OPERATIONS =====

  /// Get leaderboard santri
  static Stream<List<LeaderboardModel>> getLeaderboard() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'santri')
        .orderBy('poin', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
              .toList();

          // Convert ke LeaderboardModel dengan ranking
          return users.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            return LeaderboardModel(
              id: user.id,
              userId: user.id,
              nama: user.nama,
              poin: user.poin,
              fotoProfil: user.fotoProfil,
              ranking: index + 1,
              lastUpdated: user.updatedAt,
            );
          }).toList();
        });
  }

  /// Get leaderboard mingguan
  static Stream<List<LeaderboardModel>> getWeeklyLeaderboard() {
    // TODO: Implement logic untuk poin mingguan
    return getLeaderboard();
  }

  /// Get leaderboard bulanan
  static Stream<List<LeaderboardModel>> getMonthlyLeaderboard() {
    // TODO: Implement logic untuk poin bulanan
    return getLeaderboard();
  }

  // ===== DASHBOARD DATA =====

  /// Get data dashboard untuk santri
  static Future<Map<String, dynamic>> getDashboardData(String userId) async {
    try {
      // Get user data
      final user = await getUserById(userId);

      // Get presensi hari ini
      final todayPresensi = await getTodayPresensi(userId);

      // Get upcoming kegiatan
      final upcomingKegiatanSnapshot = await _firestore
          .collection('jadwal_kegiatan')
          .where('tanggal', isGreaterThan: DateTime.now())
          .orderBy('tanggal')
          .limit(3)
          .get();

      final upcomingKegiatan = upcomingKegiatanSnapshot.docs
          .map(
            (doc) =>
                JadwalKegiatanModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();

      // Get recent pengumuman
      final recentPengumumanSnapshot = await _firestore
          .collection('pengumuman')
          .orderBy('tanggal', descending: true)
          .limit(3)
          .get();

      final recentPengumuman = recentPengumumanSnapshot.docs
          .map((doc) => PengumumanModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      return {
        'user': user,
        'todayPresensi': todayPresensi,
        'upcomingKegiatan': upcomingKegiatan,
        'recentPengumuman': recentPengumuman,
      };
    } catch (e) {
      throw Exception('Error mengambil data dashboard: $e');
    }
  }
}

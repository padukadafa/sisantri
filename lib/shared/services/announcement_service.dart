import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';

/// Service untuk mengelola operasi pengumuman/announcement
class AnnouncementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'pengumuman';

  // ===== READ OPERATIONS =====

  /// Get semua pengumuman (stream)
  static Stream<List<PengumumanModel>> getAllPengumuman() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    PengumumanModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();
        });
  }

  /// Get pengumuman by ID (one-time fetch)
  static Future<PengumumanModel?> getPengumumanById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return PengumumanModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Error mengambil pengumuman: $e');
    }
  }

  /// Get pengumuman yang aktif saja (stream)
  static Stream<List<PengumumanModel>> getActivePengumuman() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    PengumumanModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .where((pengumuman) => !pengumuman.isExpired) // Filter expired
              .toList();
        });
  }

  static Stream<List<PengumumanModel>> getRecentPengumuman({int limit = 5}) {
    return _firestore
        .collection(_collectionName)
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    PengumumanModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .where((pengumuman) => !pengumuman.isExpired)
              .toList();
        });
  }

  /// Get pengumuman berdasarkan kategori (stream)
  static Stream<List<PengumumanModel>> getPengumumanByCategory(
    String kategori,
  ) {
    return _firestore
        .collection(_collectionName)
        .where('kategori', isEqualTo: kategori)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    PengumumanModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList();
        });
  }

  /// Get pengumuman berdasarkan prioritas (stream)
  static Stream<List<PengumumanModel>> getPengumumanByPriority(
    String prioritas,
  ) {
    return _firestore
        .collection(_collectionName)
        .where('prioritas', isEqualTo: prioritas)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    PengumumanModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList();
        });
  }

  /// Get pengumuman high priority (stream)
  static Stream<List<PengumumanModel>> getHighPriorityPengumuman() {
    return _firestore
        .collection(_collectionName)
        .where('prioritas', isEqualTo: 'tinggi')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    PengumumanModel.fromJson({'id': doc.id, ...doc.data()}),
              )
              .where((pengumuman) => !pengumuman.isExpired)
              .toList();
        });
  }

  /// Get pengumuman dalam periode tertentu
  static Future<List<PengumumanModel>> getPengumumanByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PengumumanModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Error mengambil pengumuman by period: $e');
    }
  }

  // ===== CREATE OPERATIONS =====

  /// Tambah pengumuman baru
  static Future<String> addPengumuman(PengumumanModel pengumuman) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(pengumuman.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Error menambah pengumuman: $e');
    }
  }

  // ===== UPDATE OPERATIONS =====

  /// Update pengumuman
  static Future<void> updatePengumuman(
    String id,
    PengumumanModel pengumuman,
  ) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update(pengumuman.toJson());
    } catch (e) {
      throw Exception('Error mengupdate pengumuman: $e');
    }
  }

  /// Update status aktif pengumuman
  static Future<void> updateActiveStatus(String id, bool isActive) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error mengupdate status pengumuman: $e');
    }
  }

  /// Toggle status aktif pengumuman
  static Future<void> toggleActiveStatus(String id) async {
    try {
      final pengumuman = await getPengumumanById(id);
      if (pengumuman != null) {
        await updateActiveStatus(id, !pengumuman.isActive);
      }
    } catch (e) {
      throw Exception('Error toggle status pengumuman: $e');
    }
  }

  /// Update prioritas pengumuman
  static Future<void> updatePriority(String id, String prioritas) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'prioritas': prioritas,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error mengupdate prioritas pengumuman: $e');
    }
  }

  // ===== DELETE OPERATIONS =====

  /// Delete pengumuman
  static Future<void> deletePengumuman(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Error menghapus pengumuman: $e');
    }
  }

  /// Soft delete pengumuman (set isActive = false)
  static Future<void> softDeletePengumuman(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error soft delete pengumuman: $e');
    }
  }

  // ===== BATCH OPERATIONS =====

  /// Delete multiple pengumuman
  static Future<void> deleteBatchPengumuman(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.delete(_firestore.collection(_collectionName).doc(id));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error menghapus batch pengumuman: $e');
    }
  }

  /// Update batch status aktif
  static Future<void> updateBatchActiveStatus(
    List<String> ids,
    bool isActive,
  ) async {
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.update(_firestore.collection(_collectionName).doc(id), {
          'isActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error update batch status pengumuman: $e');
    }
  }

  // ===== STATISTICS =====

  /// Get statistik pengumuman
  static Future<Map<String, int>> getPengumumanStats() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      final allPengumuman = snapshot.docs
          .map((doc) => PengumumanModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      return {
        'total': allPengumuman.length,
        'active': allPengumuman.where((p) => p.isActive).length,
        'inactive': allPengumuman.where((p) => !p.isActive).length,
        'expired': allPengumuman.where((p) => p.isExpired).length,
        'high_priority': allPengumuman.where((p) => p.isHighPriority).length,
        'medium_priority': allPengumuman
            .where((p) => p.prioritas == 'sedang')
            .length,
        'low_priority': allPengumuman
            .where((p) => p.prioritas == 'rendah')
            .length,
      };
    } catch (e) {
      throw Exception('Error mengambil statistik pengumuman: $e');
    }
  }

  /// Get jumlah pengumuman by kategori
  static Future<Map<String, int>> getPengumumanCountByCategory() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final pengumumanList = snapshot.docs
          .map((doc) => PengumumanModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      final Map<String, int> categoryCount = {};

      for (final pengumuman in pengumumanList) {
        categoryCount[pengumuman.kategori] =
            (categoryCount[pengumuman.kategori] ?? 0) + 1;
      }

      return categoryCount;
    } catch (e) {
      throw Exception('Error mengambil count by kategori: $e');
    }
  }

  // ===== SEARCH & FILTER =====

  /// Search pengumuman berdasarkan judul atau konten
  static Future<List<PengumumanModel>> searchPengumuman(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      final allPengumuman = snapshot.docs
          .map((doc) => PengumumanModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      final lowercaseQuery = query.toLowerCase();

      return allPengumuman.where((pengumuman) {
        final titleMatch = pengumuman.judul.toLowerCase().contains(
          lowercaseQuery,
        );
        final contentMatch = pengumuman.konten.toLowerCase().contains(
          lowercaseQuery,
        );
        return titleMatch || contentMatch;
      }).toList();
    } catch (e) {
      throw Exception('Error searching pengumuman: $e');
    }
  }

  /// Filter pengumuman dengan multiple criteria
  static Future<List<PengumumanModel>> filterPengumuman({
    String? kategori,
    String? prioritas,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collectionName);

      if (kategori != null) {
        query = query.where('kategori', isEqualTo: kategori);
      }

      if (prioritas != null) {
        query = query.where('prioritas', isEqualTo: prioritas);
      }

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PengumumanModel.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      throw Exception('Error filtering pengumuman: $e');
    }
  }

  // ===== UTILITY =====

  /// Check if pengumuman exists
  static Future<bool> isPengumumanExists(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Increment view count
  static Future<void> incrementViewCount(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Error incrementing view count: $e');
    }
  }

  /// Get total count pengumuman
  static Future<int> getTotalPengumumanCount() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error getting total count: $e');
    }
  }

  /// Get active count pengumuman
  static Future<int> getActivePengumumanCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error getting active count: $e');
    }
  }
}

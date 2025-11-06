import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/materi_model.dart';

class MateriService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'materi';

  // Membuat materi baru
  static Future<String> createMateri(MateriModel materi) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(materi.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal membuat materi: $e');
    }
  }

  // Mendapatkan semua materi
  static Future<List<MateriModel>> getAllMateri() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isAktif', isEqualTo: true)
          .orderBy('jenis')
          .orderBy('nama')
          .get();

      return snapshot.docs
          .map((doc) => MateriModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data materi: $e');
    }
  }

  // Mendapatkan materi berdasarkan jenis
  static Future<List<MateriModel>> getMateriByJenis(JenisMateri jenis) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('jenis', isEqualTo: jenis.value)
          .where('isAktif', isEqualTo: true)
          .orderBy('nama')
          .get();

      return snapshot.docs
          .map((doc) => MateriModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil materi berdasarkan jenis: $e');
    }
  }

  // Mendapatkan materi berdasarkan ID
  static Future<MateriModel?> getMateriById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) return null;

      return MateriModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Gagal mengambil materi: $e');
    }
  }

  // Update materi
  static Future<void> updateMateri(String id, MateriModel materi) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(materi.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      throw Exception('Gagal mengupdate materi: $e');
    }
  }

  // Soft delete materi
  static Future<void> deleteMateri(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isAktif': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal menghapus materi: $e');
    }
  }

  // Stream untuk real-time updates
  static Stream<List<MateriModel>> streamAllMateri() {
    return _firestore
        .collection(_collection)
        .where('isAktif', isEqualTo: true)
        .orderBy('jenis')
        .orderBy('nama')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MateriModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // Stream materi berdasarkan jenis
  static Stream<List<MateriModel>> streamMateriByJenis(JenisMateri jenis) {
    return _firestore
        .collection(_collection)
        .where('jenis', isEqualTo: jenis.value)
        .where('isAktif', isEqualTo: true)
        .orderBy('nama')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MateriModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // Membuat dummy data materi
  static Future<void> createDummyMateri() async {
    try {
      final dummyMateri = [
        // Materi Quran
        MateriModel(
          id: '',
          nama: 'Al-Quran 30 Juz',
          jenis: JenisMateri.quran,
          deskripsi: 'Kitab suci Al-Quran lengkap 30 juz',
          totalAyat: 6236,
          totalHalaman: 604,
          tags: ['quran', 'hafalan', 'tilawah'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),

        // Materi Hadist
        MateriModel(
          id: '',
          nama: 'Shahih Bukhari',
          jenis: JenisMateri.hadist,
          deskripsi: 'Kumpulan hadist shahih dari Imam Bukhari',
          pengarang: 'Imam Bukhari',
          totalHadist: 7563,
          totalHalaman: 850,
          tags: ['hadist', 'shahih', 'bukhari'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),

        MateriModel(
          id: '',
          nama: 'Riyadhus Shalihin',
          jenis: JenisMateri.hadist,
          deskripsi: 'Kumpulan hadist pilihan untuk pembinaan akhlak',
          pengarang: 'Imam An-Nawawi',
          totalHadist: 1896,
          totalHalaman: 400,
          tags: ['hadist', 'akhlak', 'riyadhus shalihin'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Batch write untuk efisiensi
      final batch = _firestore.batch();

      for (final materi in dummyMateri) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, materi.toJson());
      }

      await batch.commit();
      // Dummy materi created successfully
    } catch (e) {
      throw Exception('Gagal membuat dummy materi: $e');
    }
  }
}

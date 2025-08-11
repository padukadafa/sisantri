import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_santri_model.dart';
import '../models/sesi_kajian_model.dart';
import '../models/materi_model.dart';

class ProgressSantriService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _progressCollection = 'progress_santri';
  static const String _sesiCollection = 'sesi_kajian';

  // Membuat progress baru untuk santri
  static Future<String> createProgress(ProgressSantriModel progress) async {
    try {
      final docRef = await _firestore
          .collection(_progressCollection)
          .add(progress.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal membuat progress santri: $e');
    }
  }

  // Mendapatkan progress santri berdasarkan santri ID
  static Future<List<ProgressSantriModel>> getProgressBySantri(
    String santriId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_progressCollection)
          .where('santriId', isEqualTo: santriId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                ProgressSantriModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil progress santri: $e');
    }
  }

  // Mendapatkan progress berdasarkan materi
  static Future<List<ProgressSantriModel>> getProgressByMateri(
    String materiId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_progressCollection)
          .where('materiId', isEqualTo: materiId)
          .orderBy('totalSesiMengikuti', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                ProgressSantriModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil progress berdasarkan materi: $e');
    }
  }

  // Update progress santri
  static Future<void> updateProgress(
    String id,
    ProgressSantriModel progress,
  ) async {
    try {
      await _firestore
          .collection(_progressCollection)
          .doc(id)
          .update(progress.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      throw Exception('Gagal mengupdate progress santri: $e');
    }
  }

  // Update progress santri ketika menghadiri sesi kajian
  static Future<void> updateProgressFromSesi(SesiKajianModel sesi) async {
    try {
      // Cari progress santri yang sesuai
      final progressSnapshot = await _firestore
          .collection(_progressCollection)
          .where('santriId', isEqualTo: sesi.santriId)
          .where('materiId', isEqualTo: sesi.materiId)
          .limit(1)
          .get();

      ProgressSantriModel progress;

      if (progressSnapshot.docs.isEmpty) {
        // Buat progress baru jika belum ada
        progress = ProgressSantriModel(
          id: '',
          santriId: sesi.santriId,
          materiId: sesi.materiId,
          ayatTerakhir: sesi.ayatSelesai,
          halamanTerakhir: sesi.halamanSelesai,
          hadistTerakhir: sesi.hadistSelesai,
          totalSesiMengikuti: 1,
          kajianPertama: sesi.tanggal,
          kajianTerakhir: sesi.tanggal,
          sesiKajianIds: [sesi.id],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await createProgress(progress);
      } else {
        // Update progress yang sudah ada
        final doc = progressSnapshot.docs.first;
        progress = ProgressSantriModel.fromJson({...doc.data(), 'id': doc.id});

        final updatedSesiIds = List<String>.from(progress.sesiKajianIds);
        if (!updatedSesiIds.contains(sesi.id)) {
          updatedSesiIds.add(sesi.id);
        }

        final updatedProgress = progress.copyWith(
          ayatTerakhir:
              sesi.ayatSelesai != null &&
                  (progress.ayatTerakhir == null ||
                      sesi.ayatSelesai! > progress.ayatTerakhir!)
              ? sesi.ayatSelesai
              : progress.ayatTerakhir,
          halamanTerakhir:
              sesi.halamanSelesai != null &&
                  (progress.halamanTerakhir == null ||
                      sesi.halamanSelesai! > progress.halamanTerakhir!)
              ? sesi.halamanSelesai
              : progress.halamanTerakhir,
          hadistTerakhir:
              sesi.hadistSelesai != null &&
                  (progress.hadistTerakhir == null ||
                      sesi.hadistSelesai! > progress.hadistTerakhir!)
              ? sesi.hadistSelesai
              : progress.hadistTerakhir,
          totalSesiMengikuti: progress.totalSesiMengikuti + 1,
          kajianTerakhir: sesi.tanggal,
          sesiKajianIds: updatedSesiIds,
          updatedAt: DateTime.now(),
        );

        await updateProgress(doc.id, updatedProgress);
      }
    } catch (e) {
      throw Exception('Gagal mengupdate progress dari sesi: $e');
    }
  }

  // Mencatat sesi kajian baru
  static Future<String> createSesiKajian(SesiKajianModel sesi) async {
    try {
      final docRef = await _firestore
          .collection(_sesiCollection)
          .add(sesi.toJson());

      // Update progress santri
      await updateProgressFromSesi(sesi);

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal mencatat sesi kajian: $e');
    }
  }

  // Mendapatkan riwayat sesi kajian santri
  static Future<List<SesiKajianModel>> getSesiKajianBySantri(
    String santriId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_sesiCollection)
          .where('santriId', isEqualTo: santriId)
          .orderBy('tanggal', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => SesiKajianModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil riwayat sesi kajian: $e');
    }
  }

  // Mendapatkan statistik progress materi
  static Future<Map<String, dynamic>> getStatistikMateri(
    String materiId,
  ) async {
    try {
      final progressSnapshot = await _firestore
          .collection(_progressCollection)
          .where('materiId', isEqualTo: materiId)
          .get();

      final sesiSnapshot = await _firestore
          .collection(_sesiCollection)
          .where('materiId', isEqualTo: materiId)
          .get();

      final totalSantri = progressSnapshot.docs.length;
      final totalSesi = sesiSnapshot.docs.length;

      double rataRataSesi = 0.0;
      if (totalSantri > 0) {
        final totalSesiMengikuti = progressSnapshot.docs
            .map((doc) => doc.data()['totalSesiMengikuti'] as int? ?? 0)
            .reduce((a, b) => a + b);
        rataRataSesi = totalSesiMengikuti / totalSantri;
      }

      return {
        'totalSantri': totalSantri,
        'totalSesi': totalSesi,
        'rataRataSesi': rataRataSesi,
        'santriAktif': progressSnapshot.docs
            .where((doc) => (doc.data()['totalSesiMengikuti'] as int? ?? 0) > 0)
            .length,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik materi: $e');
    }
  }

  // Stream untuk real-time progress santri
  static Stream<List<ProgressSantriModel>> streamProgressBySantri(
    String santriId,
  ) {
    return _firestore
        .collection(_progressCollection)
        .where('santriId', isEqualTo: santriId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    ProgressSantriModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Stream untuk leaderboard progress
  static Stream<List<ProgressSantriModel>> streamLeaderboard(String materiId) {
    return _firestore
        .collection(_progressCollection)
        .where('materiId', isEqualTo: materiId)
        .orderBy('totalSesiMengikuti', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    ProgressSantriModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Hitung persentase progress berdasarkan materi
  static double calculatePercentage(
    ProgressSantriModel progress,
    MateriModel materi,
  ) {
    double persentase = 0.0;

    switch (materi.jenis) {
      case JenisMateri.quran:
        if (materi.totalAyat != null &&
            materi.totalAyat! > 0 &&
            progress.ayatTerakhir != null) {
          persentase = (progress.ayatTerakhir! / materi.totalAyat!) * 100;
        }
        break;
      case JenisMateri.hadist:
        if (materi.totalHadist != null &&
            materi.totalHadist! > 0 &&
            progress.hadistTerakhir != null) {
          persentase = (progress.hadistTerakhir! / materi.totalHadist!) * 100;
        }
        break;
      default:
        if (materi.totalHalaman != null &&
            materi.totalHalaman! > 0 &&
            progress.halamanTerakhir != null) {
          persentase = (progress.halamanTerakhir! / materi.totalHalaman!) * 100;
        }
        break;
    }

    // Pastikan tidak lebih dari 100%
    return persentase > 100 ? 100 : persentase;
  }

  // Membuat dummy data progress
  static Future<void> createDummyProgress() async {
    try {
      // Simulasi data santri dan materi
      final santriIds = ['santri1', 'santri2', 'santri3', 'santri4', 'santri5'];
      final materiIds = ['materi1', 'materi2', 'materi3'];

      final dummyProgress = <ProgressSantriModel>[];
      final dummySesi = <SesiKajianModel>[];

      for (final santriId in santriIds) {
        for (final materiId in materiIds) {
          // Buat progress dengan nilai random
          final progress = ProgressSantriModel(
            id: '',
            santriId: santriId,
            materiId: materiId,
            ayatTerakhir: 50 + (santriId.hashCode % 100),
            halamanTerakhir: 25 + (santriId.hashCode % 50),
            hadistTerakhir: 10 + (santriId.hashCode % 20),
            totalSesiMengikuti: 5 + (santriId.hashCode % 10),
            kajianPertama: DateTime.now().subtract(Duration(days: 30)),
            kajianTerakhir: DateTime.now().subtract(Duration(days: 1)),
            sesiKajianIds: [],
            createdAt: DateTime.now().subtract(Duration(days: 30)),
            updatedAt: DateTime.now().subtract(Duration(days: 1)),
          );
          dummyProgress.add(progress);

          // Buat beberapa sesi kajian
          for (int i = 0; i < 3; i++) {
            final sesi = SesiKajianModel(
              id: '',
              santriId: santriId,
              jadwalId: 'jadwal$i',
              materiId: materiId,
              tanggal: DateTime.now().subtract(Duration(days: i * 7)),
              ayatMulai: 1 + (i * 10),
              ayatSelesai: 10 + (i * 10),
              halamanMulai: 1 + (i * 5),
              halamanSelesai: 5 + (i * 5),
              topikBahasan: 'Topik Bahasan ${i + 1}',
              catatan: 'Catatan sesi kajian ${i + 1}',
              ustadz: 'Ustadz ${i + 1}',
              createdAt: DateTime.now().subtract(Duration(days: i * 7)),
            );
            dummySesi.add(sesi);
          }
        }
      }

      // Batch write untuk progress
      final progressBatch = _firestore.batch();
      for (final progress in dummyProgress) {
        final docRef = _firestore.collection(_progressCollection).doc();
        progressBatch.set(docRef, progress.toJson());
      }
      await progressBatch.commit();

      // Batch write untuk sesi
      final sesiBatch = _firestore.batch();
      for (final sesi in dummySesi) {
        final docRef = _firestore.collection(_sesiCollection).doc();
        sesiBatch.set(docRef, sesi.toJson());
      }
      await sesiBatch.commit();

      print(
        '✅ Dummy progress berhasil dibuat: ${dummyProgress.length} progress, ${dummySesi.length} sesi',
      );
    } catch (e) {
      throw Exception('Gagal membuat dummy progress: $e');
    }
  }
}

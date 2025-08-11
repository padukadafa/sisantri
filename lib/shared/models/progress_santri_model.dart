import 'package:cloud_firestore/cloud_firestore.dart';
import 'materi_model.dart';

/// Model untuk progress kajian santri
class ProgressSantriModel {
  final String id;
  final String santriId;
  final String materiId;
  final String? surahTerakhir; // untuk Quran
  final int? ayatTerakhir; // untuk Quran
  final int? halamanTerakhir; // untuk kitab umum
  final int? hadistTerakhir; // untuk kitab hadist
  final int totalSesiMengikuti;
  final DateTime? kajianPertama;
  final DateTime? kajianTerakhir;
  final List<String> sesiKajianIds; // referensi ke sesi yang diikuti
  final String? catatan;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgressSantriModel({
    required this.id,
    required this.santriId,
    required this.materiId,
    this.surahTerakhir,
    this.ayatTerakhir,
    this.halamanTerakhir,
    this.hadistTerakhir,
    this.totalSesiMengikuti = 0,
    this.kajianPertama,
    this.kajianTerakhir,
    this.sesiKajianIds = const [],
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgressSantriModel.fromJson(Map<String, dynamic> json) {
    return ProgressSantriModel(
      id: json['id'] ?? '',
      santriId: json['santriId'] ?? '',
      materiId: json['materiId'] ?? '',
      surahTerakhir: json['surahTerakhir'],
      ayatTerakhir: json['ayatTerakhir'],
      halamanTerakhir: json['halamanTerakhir'],
      hadistTerakhir: json['hadistTerakhir'],
      totalSesiMengikuti: json['totalSesiMengikuti'] ?? 0,
      kajianPertama: json['kajianPertama'] is Timestamp
          ? (json['kajianPertama'] as Timestamp).toDate()
          : json['kajianPertama'] != null
          ? DateTime.tryParse(json['kajianPertama'])
          : null,
      kajianTerakhir: json['kajianTerakhir'] is Timestamp
          ? (json['kajianTerakhir'] as Timestamp).toDate()
          : json['kajianTerakhir'] != null
          ? DateTime.tryParse(json['kajianTerakhir'])
          : null,
      sesiKajianIds: json['sesiKajianIds'] != null
          ? List<String>.from(json['sesiKajianIds'])
          : [],
      catatan: json['catatan'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'santriId': santriId,
      'materiId': materiId,
      'surahTerakhir': surahTerakhir,
      'ayatTerakhir': ayatTerakhir,
      'halamanTerakhir': halamanTerakhir,
      'hadistTerakhir': hadistTerakhir,
      'totalSesiMengikuti': totalSesiMengikuti,
      'kajianPertama': kajianPertama != null
          ? Timestamp.fromDate(kajianPertama!)
          : null,
      'kajianTerakhir': kajianTerakhir != null
          ? Timestamp.fromDate(kajianTerakhir!)
          : null,
      'sesiKajianIds': sesiKajianIds,
      'catatan': catatan,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProgressSantriModel copyWith({
    String? id,
    String? santriId,
    String? materiId,
    String? surahTerakhir,
    int? ayatTerakhir,
    int? halamanTerakhir,
    int? hadistTerakhir,
    int? totalSesiMengikuti,
    DateTime? kajianPertama,
    DateTime? kajianTerakhir,
    List<String>? sesiKajianIds,
    String? catatan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgressSantriModel(
      id: id ?? this.id,
      santriId: santriId ?? this.santriId,
      materiId: materiId ?? this.materiId,
      surahTerakhir: surahTerakhir ?? this.surahTerakhir,
      ayatTerakhir: ayatTerakhir ?? this.ayatTerakhir,
      halamanTerakhir: halamanTerakhir ?? this.halamanTerakhir,
      hadistTerakhir: hadistTerakhir ?? this.hadistTerakhir,
      totalSesiMengikuti: totalSesiMengikuti ?? this.totalSesiMengikuti,
      kajianPertama: kajianPertama ?? this.kajianPertama,
      kajianTerakhir: kajianTerakhir ?? this.kajianTerakhir,
      sesiKajianIds: sesiKajianIds ?? this.sesiKajianIds,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display progress
  String get displayProgress {
    if (surahTerakhir != null) {
      if (ayatTerakhir != null) {
        return '$surahTerakhir ayat $ayatTerakhir';
      }
      return '$surahTerakhir';
    } else if (halamanTerakhir != null) {
      return 'Halaman $halamanTerakhir';
    } else if (hadistTerakhir != null) {
      return 'Hadist $hadistTerakhir';
    }
    return 'Belum ada progress';
  }

  /// Get percentage if total is known
  double? getPercentage(MateriModel materi) {
    if (materi.jenis == JenisMateri.quran &&
        materi.totalAyat != null &&
        ayatTerakhir != null) {
      return (ayatTerakhir! / materi.totalAyat!) * 100;
    } else if (materi.jenis == JenisMateri.hadist &&
        materi.totalHadist != null &&
        hadistTerakhir != null) {
      return (hadistTerakhir! / materi.totalHadist!) * 100;
    } else if (materi.totalHalaman != null && halamanTerakhir != null) {
      return (halamanTerakhir! / materi.totalHalaman!) * 100;
    }
    return null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk sesi kajian individual yang menghubungkan santri dengan jadwal
class SesiKajianModel {
  final String id;
  final String santriId; // ID santri yang mengikuti
  final String materiId; // ID materi yang dikaji
  final String jadwalId; // ID jadwal pengajian
  final DateTime tanggal; // Tanggal sesi kajian
  final String? surah; // untuk Quran
  final int? ayatMulai; // untuk Quran
  final int? ayatSelesai; // untuk Quran
  final int? halamanMulai; // untuk kitab umum
  final int? halamanSelesai; // untuk kitab umum
  final int? hadistMulai; // untuk kitab hadist
  final int? hadistSelesai; // untuk kitab hadist
  final String? topikBahasan;
  final String? catatan;
  final String? ustadz; // pengajar sesi
  final DateTime createdAt;

  SesiKajianModel({
    required this.id,
    required this.santriId,
    required this.materiId,
    required this.jadwalId,
    required this.tanggal,
    this.surah,
    this.ayatMulai,
    this.ayatSelesai,
    this.halamanMulai,
    this.halamanSelesai,
    this.hadistMulai,
    this.hadistSelesai,
    this.topikBahasan,
    this.catatan,
    this.ustadz,
    required this.createdAt,
  });

  factory SesiKajianModel.fromJson(Map<String, dynamic> json) {
    return SesiKajianModel(
      id: json['id'] ?? '',
      santriId: json['santriId'] ?? '',
      materiId: json['materiId'] ?? '',
      jadwalId: json['jadwalId'] ?? '',
      tanggal: json['tanggal'] is Timestamp
          ? (json['tanggal'] as Timestamp).toDate()
          : DateTime.parse(json['tanggal'] ?? DateTime.now().toIso8601String()),
      surah: json['surah'],
      ayatMulai: json['ayatMulai'],
      ayatSelesai: json['ayatSelesai'],
      halamanMulai: json['halamanMulai'],
      halamanSelesai: json['halamanSelesai'],
      hadistMulai: json['hadistMulai'],
      hadistSelesai: json['hadistSelesai'],
      topikBahasan: json['topikBahasan'],
      catatan: json['catatan'],
      ustadz: json['ustadz'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              json['createdAt'] ?? DateTime.now().toIso8601String(),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'santriId': santriId,
      'materiId': materiId,
      'jadwalId': jadwalId,
      'tanggal': tanggal.toIso8601String(),
      'surah': surah,
      'ayatMulai': ayatMulai,
      'ayatSelesai': ayatSelesai,
      'halamanMulai': halamanMulai,
      'halamanSelesai': halamanSelesai,
      'hadistMulai': hadistMulai,
      'hadistSelesai': hadistSelesai,
      'topikBahasan': topikBahasan,
      'catatan': catatan,
      'ustadz': ustadz,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Deskripsi singkat sesi kajian
  String get deskripsi {
    final parts = <String>[];

    if (surah != null) {
      parts.add('Surah $surah');
      if (ayatMulai != null && ayatSelesai != null) {
        parts.add('ayat $ayatMulai-$ayatSelesai');
      }
    } else if (halamanMulai != null && halamanSelesai != null) {
      parts.add('halaman $halamanMulai-$halamanSelesai');
    } else if (hadistMulai != null && hadistSelesai != null) {
      parts.add('hadist $hadistMulai-$hadistSelesai');
    }

    if (topikBahasan != null && topikBahasan!.isNotEmpty) {
      parts.add('($topikBahasan)');
    }

    return parts.isEmpty ? 'Sesi kajian' : parts.join(' ');
  }

  /// Method untuk copy dengan perubahan tertentu
  SesiKajianModel copyWith({
    String? id,
    String? santriId,
    String? materiId,
    String? jadwalId,
    DateTime? tanggal,
    String? surah,
    int? ayatMulai,
    int? ayatSelesai,
    int? halamanMulai,
    int? halamanSelesai,
    int? hadistMulai,
    int? hadistSelesai,
    String? topikBahasan,
    String? catatan,
    String? ustadz,
    DateTime? createdAt,
  }) {
    return SesiKajianModel(
      id: id ?? this.id,
      santriId: santriId ?? this.santriId,
      materiId: materiId ?? this.materiId,
      jadwalId: jadwalId ?? this.jadwalId,
      tanggal: tanggal ?? this.tanggal,
      surah: surah ?? this.surah,
      ayatMulai: ayatMulai ?? this.ayatMulai,
      ayatSelesai: ayatSelesai ?? this.ayatSelesai,
      halamanMulai: halamanMulai ?? this.halamanMulai,
      halamanSelesai: halamanSelesai ?? this.halamanSelesai,
      hadistMulai: hadistMulai ?? this.hadistMulai,
      hadistSelesai: hadistSelesai ?? this.hadistSelesai,
      topikBahasan: topikBahasan ?? this.topikBahasan,
      catatan: catatan ?? this.catatan,
      ustadz: ustadz ?? this.ustadz,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

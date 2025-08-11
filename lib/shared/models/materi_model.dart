import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum untuk jenis materi kajian
enum JenisMateri {
  quran('quran'),
  hadist('hadist'),
  fiqih('fiqih'),
  akidah('akidah'),
  akhlak('akhlak'),
  sirah('sirah'),
  tafsir('tafsir'),
  nahwu('nahwu'),
  shorof('shorof'),
  lainnya('lainnya');

  const JenisMateri(this.value);
  final String value;

  static JenisMateri fromString(String value) {
    return JenisMateri.values.firstWhere(
      (e) => e.value == value,
      orElse: () => JenisMateri.lainnya,
    );
  }
}

/// Model untuk materi kajian
class MateriModel {
  final String id;
  final String nama;
  final JenisMateri jenis;
  final String? deskripsi;
  final String? pengarang;
  final int? totalHalaman;
  final int? totalAyat; // untuk Quran
  final int? totalHadist; // untuk kitab hadist
  final List<String>? tags;
  final bool isAktif;
  final DateTime createdAt;
  final DateTime updatedAt;

  MateriModel({
    required this.id,
    required this.nama,
    required this.jenis,
    this.deskripsi,
    this.pengarang,
    this.totalHalaman,
    this.totalAyat,
    this.totalHadist,
    this.tags,
    this.isAktif = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MateriModel.fromJson(Map<String, dynamic> json) {
    return MateriModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      jenis: JenisMateri.fromString(json['jenis'] ?? 'lainnya'),
      deskripsi: json['deskripsi'],
      pengarang: json['pengarang'],
      totalHalaman: json['totalHalaman'],
      totalAyat: json['totalAyat'],
      totalHadist: json['totalHadist'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isAktif: json['isAktif'] ?? true,
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
      'nama': nama,
      'jenis': jenis.value,
      'deskripsi': deskripsi,
      'pengarang': pengarang,
      'totalHalaman': totalHalaman,
      'totalAyat': totalAyat,
      'totalHadist': totalHadist,
      'tags': tags,
      'isAktif': isAktif,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MateriModel copyWith({
    String? id,
    String? nama,
    JenisMateri? jenis,
    String? deskripsi,
    String? pengarang,
    int? totalHalaman,
    int? totalAyat,
    int? totalHadist,
    List<String>? tags,
    bool? isAktif,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MateriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenis: jenis ?? this.jenis,
      deskripsi: deskripsi ?? this.deskripsi,
      pengarang: pengarang ?? this.pengarang,
      totalHalaman: totalHalaman ?? this.totalHalaman,
      totalAyat: totalAyat ?? this.totalAyat,
      totalHadist: totalHadist ?? this.totalHadist,
      tags: tags ?? this.tags,
      isAktif: isAktif ?? this.isAktif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name with author if available
  String get displayName {
    if (pengarang != null && pengarang!.isNotEmpty) {
      return '$nama - $pengarang';
    }
    return nama;
  }

  /// Get jenis display name
  String get jenisDisplayName {
    switch (jenis) {
      case JenisMateri.quran:
        return 'Al-Quran';
      case JenisMateri.hadist:
        return 'Hadist';
      case JenisMateri.fiqih:
        return 'Fiqih';
      case JenisMateri.akidah:
        return 'Akidah';
      case JenisMateri.akhlak:
        return 'Akhlak';
      case JenisMateri.sirah:
        return 'Sirah';
      case JenisMateri.tafsir:
        return 'Tafsir';
      case JenisMateri.nahwu:
        return 'Nahwu';
      case JenisMateri.shorof:
        return 'Shorof';
      case JenisMateri.lainnya:
        return 'Lainnya';
    }
  }

  /// Get progress description
  String get progressDescription {
    if (jenis == JenisMateri.quran && totalAyat != null) {
      return '$totalAyat ayat';
    } else if (jenis == JenisMateri.hadist && totalHadist != null) {
      return '$totalHadist hadist';
    } else if (totalHalaman != null) {
      return '$totalHalaman halaman';
    }
    return '';
  }
}

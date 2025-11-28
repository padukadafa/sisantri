/// Enum untuk tipe jadwal
enum TipeJadwal {
  kegiatan('kegiatan'),
  pengajian('pengajian'),
  tahfidz('tahfidz'),
  bacaan('bacaan'),
  olahraga('olahraga');

  const TipeJadwal(this.value);
  final String value;

  static TipeJadwal fromString(String value) {
    return TipeJadwal.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipeJadwal.kegiatan,
    );
  }
}

class JadwalModel {
  final String id;
  final String nama;
  final DateTime tanggal;
  final String? waktuMulai;
  final String? waktuSelesai;
  final TipeJadwal kategori;
  final String? tempat;
  final String? deskripsi;
  final String? pemateriId; // ID user pemateri
  final String? pemateriNama; // Nama pemateri untuk display
  final String? materiId; // Reference ke materi kajian
  final int? ayatMulai; // Untuk materi jenis Quran
  final int? ayatSelesai; // Untuk materi jenis Quran
  final int? halamanMulai; // Untuk materi jenis hadist/lainnya
  final int? halamanSelesai; // Untuk materi jenis hadist/lainnya

  final bool isAktif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JadwalModel({
    required this.id,
    required this.nama,
    required this.tanggal,
    this.waktuMulai,
    this.waktuSelesai,
    required this.kategori,
    this.tempat,
    this.deskripsi,
    this.pemateriId,
    this.pemateriNama,
    this.materiId,
    this.ayatMulai,
    this.ayatSelesai,
    this.halamanMulai,
    this.halamanSelesai,
    this.isAktif = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat JadwalModel dari JSON
  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      tanggal: json['tanggal'] is DateTime
          ? json['tanggal']
          : DateTime.fromMillisecondsSinceEpoch(
              json['tanggal'].millisecondsSinceEpoch,
            ),
      waktuMulai: json['waktuMulai'] as String?,
      waktuSelesai: json['waktuSelesai'] as String?,
      kategori: TipeJadwal.fromString(json['kategori'] as String? ?? 'umum'),
      tempat: json['tempat'] as String?,
      deskripsi: json['deskripsi'] as String?,
      pemateriId: json['pemateriId'] as String?,
      pemateriNama: json['pemateriNama'] as String?,
      materiId: json['materiId'] as String?,
      ayatMulai: json['ayatMulai'] as int?,
      ayatSelesai: json['ayatSelesai'] as int?,
      halamanMulai: json['halamanMulai'] as int?,
      halamanSelesai: json['halamanSelesai'] as int?,
      isAktif: json['isAktif'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
                ? json['createdAt']
                : DateTime.fromMillisecondsSinceEpoch(
                    json['createdAt'].millisecondsSinceEpoch,
                  ))
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is DateTime
                ? json['updatedAt']
                : DateTime.fromMillisecondsSinceEpoch(
                    json['updatedAt'].millisecondsSinceEpoch,
                  ))
          : null,
    );
  }

  /// Method untuk convert JadwalModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'tanggal': tanggal,
      'waktuMulai': waktuMulai,
      'waktuSelesai': waktuSelesai,
      'kategori': kategori.value,
      'tempat': tempat,
      'deskripsi': deskripsi,
      'pemateriId': pemateriId,
      'pemateriNama': pemateriNama,
      'materiId': materiId,
      'ayatMulai': ayatMulai,
      'ayatSelesai': ayatSelesai,
      'halamanMulai': halamanMulai,
      'halamanSelesai': halamanSelesai,
      'isAktif': isAktif,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Method untuk copy dengan perubahan tertentu
  JadwalModel copyWith({
    String? id,
    String? nama,
    DateTime? tanggal,
    String? waktuMulai,
    String? waktuSelesai,
    String? hari,
    TipeJadwal? kategori,
    String? tempat,
    String? deskripsi,
    String? pemateriId,
    String? pemateriNama,
    String? tema,
    String? materiId,
    int? ayatMulai,
    int? ayatSelesai,
    int? halamanMulai,
    int? halamanSelesai,
    int? hadistMulai,
    int? hadistSelesai,
    String? topikBahasan,
    bool? isAktif,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JadwalModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tanggal: tanggal ?? this.tanggal,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      kategori: kategori ?? this.kategori,
      tempat: tempat ?? this.tempat,
      deskripsi: deskripsi ?? this.deskripsi,
      pemateriId: pemateriId ?? this.pemateriId,
      pemateriNama: pemateriNama ?? this.pemateriNama,
      materiId: materiId ?? this.materiId,
      ayatMulai: ayatMulai ?? this.ayatMulai,
      ayatSelesai: ayatSelesai ?? this.ayatSelesai,
      halamanMulai: halamanMulai ?? this.halamanMulai,
      halamanSelesai: halamanSelesai ?? this.halamanSelesai,
      isAktif: isAktif ?? this.isAktif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted tanggal string
  String get formattedTanggal {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
  }

  /// Get formatted waktu string
  String get formattedWaktu {
    if (waktuMulai != null) {
      return waktuMulai!;
    }
    return '${tanggal.hour.toString().padLeft(2, '0')}:${tanggal.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted waktu range string
  String get formattedWaktuRange {
    if (waktuMulai != null && waktuSelesai != null) {
      return '$waktuMulai - $waktuSelesai';
    } else if (waktuMulai != null) {
      return waktuMulai!;
    }
    return formattedWaktu;
  }

  /// Check apakah jadwal ini hari ini
  bool get isToday {
    final now = DateTime.now();
    return tanggal.year == now.year &&
        tanggal.month == now.month &&
        tanggal.day == now.day;
  }

  /// Check apakah jadwal ini besok
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tanggal.year == tomorrow.year &&
        tanggal.month == tomorrow.month &&
        tanggal.day == tomorrow.day;
  }

  /// Check apakah ini jadwal pengajian
  bool get isPengajian {
    return kategori == TipeJadwal.pengajian || kategori == TipeJadwal.pengajian;
  }

  /// Check apakah ini jadwal kegiatan umum
  bool get isKegiatan {
    return !isPengajian;
  }

  /// Get display title (nama untuk kegiatan, tema untuk pengajian)
  String get displayTitle {
    return nama;
  }

  /// Get subtitle info
  String get subtitle {
    final List<String> info = [];

    if (isPengajian && pemateriNama != null) {
      info.add('Pemateri: $pemateriNama');
    }

    if (tempat != null) {
      info.add('Tempat: $tempat');
    }

    if (formattedWaktuRange.isNotEmpty) {
      info.add('Waktu: $formattedWaktuRange');
    }

    return info.join(' • ');
  }

  @override
  String toString() {
    return 'JadwalModel(id: $id, nama: $nama, tanggal: $tanggal, kategori: ${kategori.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JadwalModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

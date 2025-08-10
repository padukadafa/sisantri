/// Model untuk jadwal kegiatan pondok
class JadwalKegiatanModel {
  final String id;
  final String namaKegiatan;
  final DateTime tanggal;
  final String lokasi;
  final String? deskripsi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JadwalKegiatanModel({
    required this.id,
    required this.namaKegiatan,
    required this.tanggal,
    required this.lokasi,
    this.deskripsi,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat JadwalKegiatanModel dari JSON
  factory JadwalKegiatanModel.fromJson(Map<String, dynamic> json) {
    return JadwalKegiatanModel(
      id: json['id'] as String,
      namaKegiatan: json['nama_kegiatan'] as String,
      tanggal: DateTime.fromMillisecondsSinceEpoch(
        json['tanggal'].millisecondsSinceEpoch,
      ),
      lokasi: json['lokasi'] as String,
      deskripsi: json['deskripsi'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['createdAt'].millisecondsSinceEpoch,
            )
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['updatedAt'].millisecondsSinceEpoch,
            )
          : null,
    );
  }

  /// Method untuk convert JadwalKegiatanModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kegiatan': namaKegiatan,
      'tanggal': tanggal,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Method untuk copy dengan perubahan tertentu
  JadwalKegiatanModel copyWith({
    String? id,
    String? namaKegiatan,
    DateTime? tanggal,
    String? lokasi,
    String? deskripsi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JadwalKegiatanModel(
      id: id ?? this.id,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      tanggal: tanggal ?? this.tanggal,
      lokasi: lokasi ?? this.lokasi,
      deskripsi: deskripsi ?? this.deskripsi,
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
    return '${tanggal.hour.toString().padLeft(2, '0')}:${tanggal.minute.toString().padLeft(2, '0')}';
  }

  /// Check apakah kegiatan ini hari ini
  bool get isToday {
    final now = DateTime.now();
    return tanggal.year == now.year &&
        tanggal.month == now.month &&
        tanggal.day == now.day;
  }

  /// Check apakah kegiatan ini besok
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tanggal.year == tomorrow.year &&
        tanggal.month == tomorrow.month &&
        tanggal.day == tomorrow.day;
  }

  @override
  String toString() {
    return 'JadwalKegiatanModel(id: $id, namaKegiatan: $namaKegiatan, tanggal: $tanggal, lokasi: $lokasi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JadwalKegiatanModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

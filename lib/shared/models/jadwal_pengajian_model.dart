/// Model untuk jadwal pengajian
class JadwalPengajianModel {
  final String id;
  final DateTime tanggal;
  final String tema;
  final String pemateri;
  final String? deskripsi;
  final String? lokasi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JadwalPengajianModel({
    required this.id,
    required this.tanggal,
    required this.tema,
    required this.pemateri,
    this.deskripsi,
    this.lokasi,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat JadwalPengajianModel dari JSON
  factory JadwalPengajianModel.fromJson(Map<String, dynamic> json) {
    return JadwalPengajianModel(
      id: json['id'] as String,
      tanggal: DateTime.fromMillisecondsSinceEpoch(
        json['tanggal'].millisecondsSinceEpoch,
      ),
      tema: json['tema'] as String,
      pemateri: json['pemateri'] as String,
      deskripsi: json['deskripsi'] as String?,
      lokasi: json['lokasi'] as String?,
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

  /// Method untuk convert JadwalPengajianModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal,
      'tema': tema,
      'pemateri': pemateri,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Method untuk copy dengan perubahan tertentu
  JadwalPengajianModel copyWith({
    String? id,
    DateTime? tanggal,
    String? tema,
    String? pemateri,
    String? deskripsi,
    String? lokasi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JadwalPengajianModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      tema: tema ?? this.tema,
      pemateri: pemateri ?? this.pemateri,
      deskripsi: deskripsi ?? this.deskripsi,
      lokasi: lokasi ?? this.lokasi,
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

  @override
  String toString() {
    return 'JadwalPengajianModel(id: $id, tanggal: $tanggal, tema: $tema, pemateri: $pemateri)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JadwalPengajianModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

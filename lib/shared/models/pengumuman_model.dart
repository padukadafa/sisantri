/// Model untuk pengumuman
class PengumumanModel {
  final String id;
  final String judul;
  final String isi;
  final DateTime tanggal;
  final String? gambarUrl;
  final String authorId;
  final String? authorName;
  final bool isPenting;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PengumumanModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tanggal,
    this.gambarUrl,
    required this.authorId,
    this.authorName,
    this.isPenting = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat PengumumanModel dari JSON
  factory PengumumanModel.fromJson(Map<String, dynamic> json) {
    return PengumumanModel(
      id: json['id'] as String,
      judul: json['judul'] as String,
      isi: json['isi'] as String,
      tanggal: DateTime.fromMillisecondsSinceEpoch(
        json['tanggal'].millisecondsSinceEpoch,
      ),
      gambarUrl: json['gambarUrl'] as String?,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String?,
      isPenting: json['isPenting'] as bool? ?? false,
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

  /// Method untuk convert PengumumanModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'tanggal': tanggal,
      'gambarUrl': gambarUrl,
      'authorId': authorId,
      'authorName': authorName,
      'isPenting': isPenting,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Method untuk copy dengan perubahan tertentu
  PengumumanModel copyWith({
    String? id,
    String? judul,
    String? isi,
    DateTime? tanggal,
    String? gambarUrl,
    String? authorId,
    String? authorName,
    bool? isPenting,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PengumumanModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isPenting: isPenting ?? this.isPenting,
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

  /// Get relative time (berapa jam/hari yang lalu)
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(tanggal);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  String toString() {
    return 'PengumumanModel(id: $id, judul: $judul, tanggal: $tanggal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PengumumanModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

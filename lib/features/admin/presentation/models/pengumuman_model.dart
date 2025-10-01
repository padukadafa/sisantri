/// Model untuk pengumuman
class Pengumuman {
  final String id;
  final String judul;
  final String konten;
  final String kategori;
  final String prioritas;
  final List<String> targetAudience;
  final DateTime tanggalPost;
  final DateTime? tanggalExpired;
  final bool isActive;
  final String authorId;
  final String authorName;
  final int viewCount;
  final List<String> attachments;

  Pengumuman({
    required this.id,
    required this.judul,
    required this.konten,
    required this.kategori,
    required this.prioritas,
    required this.targetAudience,
    required this.tanggalPost,
    this.tanggalExpired,
    required this.isActive,
    required this.authorId,
    required this.authorName,
    this.viewCount = 0,
    this.attachments = const [],
  });

  factory Pengumuman.fromJson(Map<String, dynamic> json) {
    return Pengumuman(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      konten: json['konten'] ?? '',
      kategori: json['kategori'] ?? '',
      prioritas: json['prioritas'] ?? 'normal',
      targetAudience: List<String>.from(json['targetAudience'] ?? []),
      tanggalPost: DateTime.fromMillisecondsSinceEpoch(
        json['tanggalPost'] ?? 0,
      ),
      tanggalExpired: json['tanggalExpired'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['tanggalExpired'])
          : null,
      isActive: json['isActive'] ?? true,
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'konten': konten,
      'kategori': kategori,
      'prioritas': prioritas,
      'targetAudience': targetAudience,
      'tanggalPost': tanggalPost.millisecondsSinceEpoch,
      'tanggalExpired': tanggalExpired?.millisecondsSinceEpoch,
      'isActive': isActive,
      'authorId': authorId,
      'authorName': authorName,
      'viewCount': viewCount,
      'attachments': attachments,
    };
  }

  Pengumuman copyWith({
    String? id,
    String? judul,
    String? konten,
    String? kategori,
    String? prioritas,
    List<String>? targetAudience,
    DateTime? tanggalPost,
    DateTime? tanggalExpired,
    bool? isActive,
    String? authorId,
    String? authorName,
    int? viewCount,
    List<String>? attachments,
  }) {
    return Pengumuman(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      konten: konten ?? this.konten,
      kategori: kategori ?? this.kategori,
      prioritas: prioritas ?? this.prioritas,
      targetAudience: targetAudience ?? this.targetAudience,
      tanggalPost: tanggalPost ?? this.tanggalPost,
      tanggalExpired: tanggalExpired ?? this.tanggalExpired,
      isActive: isActive ?? this.isActive,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      viewCount: viewCount ?? this.viewCount,
      attachments: attachments ?? this.attachments,
    );
  }

  bool get isExpired {
    if (tanggalExpired == null) return false;
    return DateTime.now().isAfter(tanggalExpired!);
  }

  bool get isHighPriority => prioritas == 'tinggi';
  bool get isMediumPriority => prioritas == 'sedang';
  bool get isLowPriority => prioritas == 'rendah';
}

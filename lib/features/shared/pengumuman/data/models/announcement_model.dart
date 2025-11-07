import '../../domain/entities/pengumuman.dart';

class AnnouncementModel extends Pengumuman {
  const AnnouncementModel({
    required super.id,
    required super.judul,
    required super.konten,
    required super.kategori,
    required super.prioritas,
    required super.createdBy,
    required super.createdByName,
    required super.targetAudience,
    required super.targetRoles,
    required super.targetClasses,
    super.lampiranUrl,
    required super.tanggalMulai,
    super.tanggalBerakhir,
    required super.isPublished,
    required super.isPinned,
    required super.viewCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      judul: json['judul'] as String,
      konten: json['konten'] as String,
      kategori: json['kategori'] as String,
      prioritas: json['prioritas'] as String,
      createdBy: json['createdBy'] as String,
      createdByName: json['createdByName'] as String? ?? '',
      targetAudience: json['targetAudience'] as String,
      targetRoles:
          (json['targetRoles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      targetClasses:
          (json['targetClasses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lampiranUrl: json['lampiranUrl'] as String?,
      tanggalMulai: DateTime.parse(json['tanggalMulai'] as String),
      tanggalBerakhir: json['tanggalBerakhir'] != null
          ? DateTime.parse(json['tanggalBerakhir'] as String)
          : null,
      isPublished: json['isPublished'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'konten': konten,
      'kategori': kategori,
      'prioritas': prioritas,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'targetAudience': targetAudience,
      'targetRoles': targetRoles,
      'targetClasses': targetClasses,
      'lampiranUrl': lampiranUrl,
      'tanggalMulai': tanggalMulai.toIso8601String(),
      'tanggalBerakhir': tanggalBerakhir?.toIso8601String(),
      'isPublished': isPublished,
      'isPinned': isPinned,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? judul,
    String? konten,
    String? kategori,
    String? prioritas,
    String? createdBy,
    String? createdByName,
    String? targetAudience,
    List<String>? targetRoles,
    List<String>? targetClasses,
    String? lampiranUrl,
    DateTime? tanggalMulai,
    DateTime? tanggalBerakhir,
    bool? isPublished,
    bool? isPinned,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      konten: konten ?? this.konten,
      kategori: kategori ?? this.kategori,
      prioritas: prioritas ?? this.prioritas,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      targetAudience: targetAudience ?? this.targetAudience,
      targetRoles: targetRoles ?? this.targetRoles,
      targetClasses: targetClasses ?? this.targetClasses,
      lampiranUrl: lampiranUrl ?? this.lampiranUrl,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalBerakhir: tanggalBerakhir ?? this.tanggalBerakhir,
      isPublished: isPublished ?? this.isPublished,
      isPinned: isPinned ?? this.isPinned,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

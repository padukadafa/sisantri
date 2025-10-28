import '../../domain/entities/user.dart';

/// Model untuk User dalam Data Layer
/// Model adalah implementasi dari Entity yang dapat di-convert ke/dari JSON
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.nama,
    required super.email,
    required super.role,
    super.poin = 0,
    super.fotoProfil,
    super.statusAktif = true,
    super.rfidCardId,
    super.createdAt,
    super.updatedAt,
    super.nim,
    super.jurusan,
    super.kampus,
    super.tempatKos,
    super.deviceTokens,
  });

  /// Factory constructor untuk membuat UserModel dari JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      poin: json['poin'] as int? ?? 0,
      fotoProfil: json['fotoProfil'] as String?,
      statusAktif: json['statusAktif'] as bool? ?? true,
      rfidCardId: json['rfidCardId'] as String?,
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
      nim: json['nim'] as String?,
      jurusan: json['jurusan'] as String?,
      kampus: json['kampus'] as String?,
      tempatKos: json['tempatKos'] as String?,
      deviceTokens: json['deviceTokens'] != null
          ? List<String>.from(json['deviceTokens'] as List)
          : null,
    );
  }

  /// Factory constructor untuk membuat UserModel dari Entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      nama: user.nama,
      email: user.email,
      role: user.role,
      poin: user.poin,
      fotoProfil: user.fotoProfil,
      statusAktif: user.statusAktif,
      rfidCardId: user.rfidCardId,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      nim: user.nim,
      jurusan: user.jurusan,
      kampus: user.kampus,
      tempatKos: user.tempatKos,
      deviceTokens: user.deviceTokens,
    );
  }

  /// Method untuk convert UserModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'poin': poin,
      'fotoProfil': fotoProfil,
      'statusAktif': statusAktif,
      'rfidCardId': rfidCardId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'nim': nim,
      'jurusan': jurusan,
      'kampus': kampus,
      'tempatKos': tempatKos,
      'deviceTokens': deviceTokens,
    };
  }

  /// Method untuk copy dengan perubahan tertentu
  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? role,
    int? poin,
    String? fotoProfil,
    bool? statusAktif,
    String? rfidCardId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nim,
    String? jurusan,
    String? kampus,
    String? tempatKos,
    List<String>? deviceTokens,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      poin: poin ?? this.poin,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      statusAktif: statusAktif ?? this.statusAktif,
      rfidCardId: rfidCardId ?? this.rfidCardId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nim: nim ?? this.nim,
      jurusan: jurusan ?? this.jurusan,
      kampus: kampus ?? this.kampus,
      tempatKos: tempatKos ?? this.tempatKos,
      deviceTokens: deviceTokens ?? this.deviceTokens,
    );
  }

  /// Method untuk menambah device token baru (tanpa duplikasi)
  UserModel addDeviceToken(String token) {
    final currentTokens = safeDeviceTokens;
    if (!currentTokens.contains(token)) {
      return copyWith(deviceTokens: [...currentTokens, token]);
    }
    return this;
  }

  /// Method untuk menghapus device token
  UserModel removeDeviceToken(String token) {
    final currentTokens = safeDeviceTokens;
    return copyWith(
      deviceTokens: currentTokens.where((t) => t != token).toList(),
    );
  }

  /// Daftar pilihan tempat kos
  static const List<String> tempatKosPilihan = [
    'Asrama Putra',
    'Kos Pak Harsono',
    'Kos Pak Sigit',
    'Asrama Putri',
    'Kos Pak Sukadi',
    'Kos Abah Rahmat',
    'Kos Biru',
    'Kos Bu Mardiana',
    'Kos Pak Sugi',
    'Lainnya',
  ];

  /// Daftar pilihan kampus (contoh - bisa disesuaikan)
  static const List<String> kampusPilihan = [
    'Institut Teknologi Sumatera',
    'UIN Raden Intan Lampung',
    'Universitas Lampung',
    'Institut Maritim Prasetya Mandiri',
    'Universitas Bandar Lampung',
    'Universitas Teknokrat Indonesia',
    'Universitas Muhammadiyah Metro',
    'Universitas Muhammadiyah Lampung',
    'Universitas Malahayati',
    'Universitas Mitra Indonesia',
    'Universitas Saburai',
    'Universitas Tulang bawang',
    'Institut Informatika dan Bisnis Darmajaya',
    'STIKP PGRI Lampung',
    'Politeknik Negeri Lampung',
    'Universitas Terbuka',
    'Lainnya',
  ];
}

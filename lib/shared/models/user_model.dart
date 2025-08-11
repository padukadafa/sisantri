/// Model untuk user/santri dalam aplikasi
class UserModel {
  final String id;
  final String nama;
  final String email;
  final String role; // 'admin', 'santri', atau 'dewan_guru'
  final int poin;
  final String? fotoProfil;
  final bool statusAktif;
  final String? rfidCardId; // ID kartu RFID untuk presensi otomatis
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? nim;
  final String? jurusan;
  final String? kampus;
  final String? tempatKos;
  final List<String>? deviceTokens; // FCM tokens untuk push notifications

  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.poin = 0,
    this.fotoProfil,
    this.statusAktif = true,
    this.rfidCardId,
    this.createdAt,
    this.updatedAt,
    this.nim,
    this.jurusan,
    this.kampus,
    this.tempatKos,
    this.deviceTokens,
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

  /// Check apakah user adalah admin
  bool get isAdmin => role == 'admin';

  /// Check apakah user adalah santri
  bool get isSantri => role == 'santri';

  /// Check apakah user adalah dewan guru
  bool get isDewaGuru => role == 'dewan_guru';

  /// Check apakah RFID sudah di-setup
  bool get hasRfidSetup => rfidCardId != null && rfidCardId!.isNotEmpty;

  /// Check apakah user perlu setup RFID (santri tanpa RFID)
  bool get needsRfidSetup => isSantri && !hasRfidSetup;

  /// Check apakah user memiliki device tokens untuk push notifications
  bool get hasDeviceTokens => deviceTokens != null && deviceTokens!.isNotEmpty;

  /// Get list device tokens (tidak null)
  List<String> get safeDeviceTokens => deviceTokens ?? [];

  /// Method untuk menambah device token baru (tanpa duplikasi)
  List<String> addDeviceToken(String token) {
    final currentTokens = safeDeviceTokens;
    if (!currentTokens.contains(token)) {
      return [...currentTokens, token];
    }
    return currentTokens;
  }

  /// Method untuk menghapus device token
  List<String> removeDeviceToken(String token) {
    final currentTokens = safeDeviceTokens;
    return currentTokens.where((t) => t != token).toList();
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

  /// Helper method untuk mendapatkan icon tempat kos
  static String getTempatKosIcon(String? tempatKos) {
    if (tempatKos == null) return '🏠';

    switch (tempatKos.toLowerCase()) {
      case 'asrama putra':
      case 'asrama putri':
        return '🏢';
      case 'kos pak harsono':
      case 'kos pak sigit':
      case 'kos pak sukadi':
      case 'kos pak sugi':
        return '🏘️';
      case 'kos abah rahmat':
        return '🕌';
      case 'kos biru':
        return '🔵';
      case 'kos bu mardiana':
        return '🏡';
      default:
        return '🏠';
    }
  }

  /// Helper method untuk format tempat kos dengan icon
  String get formattedTempatKos {
    if (tempatKos == null || tempatKos!.isEmpty) return 'Belum diatur';
    return '${getTempatKosIcon(tempatKos)} $tempatKos';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, nama: $nama, email: $email, role: $role, poin: $poin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

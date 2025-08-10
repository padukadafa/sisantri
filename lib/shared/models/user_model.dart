/// Model untuk user/santri dalam aplikasi
class UserModel {
  final String id;
  final String nama;
  final String email;
  final String role; // 'admin' atau 'santri'
  final int poin;
  final String? fotoProfil;
  final bool statusAktif;
  final String? rfidCardId; // ID kartu RFID untuk presensi otomatis
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    );
  }

  /// Check apakah user adalah admin
  bool get isAdmin => role == 'admin';

  /// Check apakah user adalah santri
  bool get isSantri => role == 'santri';

  /// Check apakah RFID sudah di-setup
  bool get hasRfidSetup => rfidCardId != null && rfidCardId!.isNotEmpty;

  /// Check apakah user perlu setup RFID (santri tanpa RFID)
  bool get needsRfidSetup => isSantri && !hasRfidSetup;

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

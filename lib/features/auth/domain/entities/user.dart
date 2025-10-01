import 'package:equatable/equatable.dart';

/// Entity untuk User dalam Domain Layer
/// Entity adalah objek bisnis murni tanpa ketergantungan pada framework eksternal
class User extends Equatable {
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

  const User({
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

  /// Helper method untuk format tempat kos dengan icon
  String get formattedTempatKos {
    if (tempatKos == null || tempatKos!.isEmpty) return 'Belum diatur';
    return '${_getTempatKosIcon(tempatKos)} $tempatKos';
  }

  /// Helper method untuk mendapatkan icon tempat kos
  static String _getTempatKosIcon(String? tempatKos) {
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

  @override
  List<Object?> get props => [
    id,
    nama,
    email,
    role,
    poin,
    fotoProfil,
    statusAktif,
    rfidCardId,
    createdAt,
    updatedAt,
    nim,
    jurusan,
    kampus,
    tempatKos,
    deviceTokens,
  ];

  @override
  String toString() {
    return 'User(id: $id, nama: $nama, email: $email, role: $role, poin: $poin)';
  }
}

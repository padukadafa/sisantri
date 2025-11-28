import 'package:equatable/equatable.dart';

/// Enum untuk status presensi
enum StatusPresensi {
  hadir('Hadir'),
  izin('Izin'),
  sakit('Sakit'),
  alpha('Alpha');

  const StatusPresensi(this.label);
  final String label;

  /// Get status dari string
  static StatusPresensi fromString(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return StatusPresensi.hadir;
      case 'izin':
        return StatusPresensi.izin;
      case 'sakit':
        return StatusPresensi.sakit;
      case 'alpha':
        return StatusPresensi.alpha;
      default:
        return StatusPresensi.hadir;
    }
  }
}

/// Entity untuk Presensi dalam Domain Layer
/// Entity adalah objek bisnis murni tanpa ketergantungan pada framework eksternal
class Presensi extends Equatable {
  final String id;
  final String userId;
  final String jadwalId;
  final DateTime tanggal;
  final StatusPresensi status;
  final String? keterangan;
  final int poinDiperoleh;
  final DateTime? createdAt;

  const Presensi({
    required this.id,
    required this.userId,
    required this.jadwalId,
    required this.tanggal,
    required this.status,
    this.keterangan,
    this.poinDiperoleh = 0,
    this.createdAt,
  });

  /// Get formatted tanggal string
  String get formattedTanggal {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
  }

  /// Get formatted date string
  String get formattedDate {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
  }

  /// Get formatted time string
  String get formattedTime {
    final hour = tanggal.hour.toString().padLeft(2, '0');
    final minute = tanggal.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get poin berdasarkan status
  static int getPoinByStatus(StatusPresensi status) {
    switch (status) {
      case StatusPresensi.hadir:
        return 10; // Poin untuk hadir
      case StatusPresensi.izin:
        return 5; // Poin untuk izin
      case StatusPresensi.sakit:
        return 5; // Poin untuk sakit
      case StatusPresensi.alpha:
        return 0; // Poin untuk alpha
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    tanggal,
    status,
    keterangan,
    poinDiperoleh,
    createdAt,
  ];

  @override
  String toString() {
    return 'Presensi(id: $id, userId: $userId, tanggal: $tanggal, status: ${status.label})';
  }
}

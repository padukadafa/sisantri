import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum untuk status presensi
enum StatusPresensi {
  hadir('Hadir'),
  izin('Izin'),
  sakit('Sakit'),
  alpha('Alpha');

  const StatusPresensi(this.label);
  final String label;

  /// Get icon untuk status
  IconData get icon {
    switch (this) {
      case StatusPresensi.hadir:
        return Icons.check_circle;
      case StatusPresensi.izin:
        return Icons.event_available;
      case StatusPresensi.sakit:
        return Icons.local_hospital;
      case StatusPresensi.alpha:
        return Icons.cancel;
    }
  }

  /// Get color untuk status
  Color get color {
    switch (this) {
      case StatusPresensi.hadir:
        return Colors.green;
      case StatusPresensi.izin:
        return Colors.blue;
      case StatusPresensi.sakit:
        return Colors.orange;
      case StatusPresensi.alpha:
        return Colors.red;
    }
  }

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

class PresensiModel {
  final String id;
  final String jadwalId;
  final String userId;
  final String userName;
  final DateTime? timestamp;
  final StatusPresensi status;
  final String keterangan;
  final bool isManual;
  final int poin;
  final DateTime createdAt;
  final String recordedBy;
  final String recordedByName;

  const PresensiModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.createdAt,
    required this.timestamp,
    required this.isManual,
    required this.recordedBy,
    required this.recordedByName,
    required this.jadwalId,
    this.keterangan = '',
    this.poin = 1,
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return PresensiModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      status: StatusPresensi.fromString(json['status'] as String? ?? 'hadir'),
      createdAt: parseTimestamp(json['createdAt']),
      timestamp: json['timestamp'] != null
          ? parseTimestamp(json['timestamp'])
          : null,
      isManual: json['isManual'] as bool? ?? false,
      recordedBy: json['recordedBy'] as String? ?? '',
      recordedByName: json['recordedByName'] as String? ?? '',
      jadwalId:
          json['jadwalId'] as String? ?? json['activity'] as String? ?? '',
      keterangan: json['keterangan'] as String? ?? '',
      poin: json['poin'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'isManual': isManual,
      'recordedBy': recordedBy,
      'recordedByName': recordedByName,
      'jadwalId': jadwalId,
      'keterangan': keterangan,
      'poin': poin,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PresensiModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

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

/// Model untuk presensi santri
class PresensiModel {
  final String id;
  final String userId;
  final DateTime tanggal;
  final StatusPresensi status;
  final String? keterangan;
  final int poinDiperoleh;
  final DateTime? createdAt;

  const PresensiModel({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.status,
    this.keterangan,
    this.poinDiperoleh = 0,
    this.createdAt,
  });

  /// Factory constructor untuk membuat PresensiModel dari JSON
  factory PresensiModel.fromJson(Map<String, dynamic> json) {
    // Parsing JSON data

    DateTime tanggalParsed;
    try {
      // Try tanggal field first, then timestamp
      dynamic dateField = json['tanggal'] ?? json['timestamp'];

      if (dateField is DateTime) {
        tanggalParsed = dateField;
      } else if (dateField is Timestamp) {
        tanggalParsed = dateField.toDate();
      } else if (dateField is int) {
        tanggalParsed = DateTime.fromMillisecondsSinceEpoch(dateField);
      } else {
        // Unknown date format
        // Available fields
        tanggalParsed = DateTime.now();
      }
    } catch (e) {
      // Error parsing date
      tanggalParsed = DateTime.now();
    }

    DateTime? createdAtParsed;
    try {
      if (json['createdAt'] != null) {
        if (json['createdAt'] is DateTime) {
          createdAtParsed = json['createdAt'];
        } else if (json['createdAt'] is Timestamp) {
          createdAtParsed = (json['createdAt'] as Timestamp).toDate();
        } else if (json['createdAt'] is int) {
          createdAtParsed = DateTime.fromMillisecondsSinceEpoch(
            json['createdAt'],
          );
        }
      }
    } catch (e) {
      // Error parsing createdAt
    }

    final result = PresensiModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tanggal: tanggalParsed,
      status: StatusPresensi.fromString(json['status'] as String? ?? 'hadir'),
      keterangan: json['keterangan'] as String?,
      poinDiperoleh: json['poinDiperoleh'] as int? ?? 0,
      createdAt: createdAtParsed,
    );

    // Successfully parsed PresensiModel
    return result;
  }

  /// Method untuk convert PresensiModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tanggal': Timestamp.fromDate(tanggal),
      'status': status.label,
      'keterangan': keterangan,
      'poinDiperoleh': poinDiperoleh,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  /// Method untuk copy dengan perubahan tertentu
  PresensiModel copyWith({
    String? id,
    String? userId,
    DateTime? tanggal,
    StatusPresensi? status,
    String? keterangan,
    int? poinDiperoleh,
    DateTime? createdAt,
  }) {
    return PresensiModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      poinDiperoleh: poinDiperoleh ?? this.poinDiperoleh,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
  String toString() {
    return 'PresensiModel(id: $id, userId: $userId, tanggal: $tanggal, status: ${status.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PresensiModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/presensi.dart';

class PresensiModel extends Presensi {
  const PresensiModel({
    required super.id,
    required super.userId,
    required super.tanggal,
    required super.status,
    super.keterangan,
    super.poinDiperoleh = 0,
    super.createdAt,
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) {
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

    return PresensiModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tanggal: tanggalParsed,
      status: StatusPresensi.fromString(json['status'] as String? ?? 'hadir'),
      keterangan: json['keterangan'] as String?,
      poinDiperoleh: json['poinDiperoleh'] as int? ?? 0,
      createdAt: createdAtParsed,
    );
  }

  /// Factory constructor untuk membuat PresensiModel dari Entity
  factory PresensiModel.fromEntity(Presensi presensi) {
    return PresensiModel(
      id: presensi.id,
      userId: presensi.userId,
      tanggal: presensi.tanggal,
      status: presensi.status,
      keterangan: presensi.keterangan,
      poinDiperoleh: presensi.poinDiperoleh,
      createdAt: presensi.createdAt,
    );
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
}

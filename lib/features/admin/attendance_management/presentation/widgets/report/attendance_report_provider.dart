import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisantri/shared/models/user_model.dart';
import 'package:sisantri/shared/models/presensi_model.dart';
import 'package:sisantri/shared/services/presensi_service.dart';

/// Filter untuk laporan presensi
class AttendanceReportFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userId;
  final String? status;

  const AttendanceReportFilter({
    this.startDate,
    this.endDate,
    this.userId,
    this.status,
  });

  AttendanceReportFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? status,
  }) {
    return AttendanceReportFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      userId: userId ?? this.userId,
      status: status ?? this.status,
    );
  }
}

/// Provider untuk data laporan presensi
final attendanceReportProvider =
    FutureProvider.family<Map<String, dynamic>, AttendanceReportFilter>((
      ref,
      filter,
    ) async {
      try {
        final firestore = FirebaseFirestore.instance;

        // Get users data
        final usersSnapshot = await firestore.collection('users').get();
        final users = usersSnapshot.docs
            .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
            .where((user) => user.isSantri)
            .toList();

        // Use PresensiService to get attendance records with date filtering
        List<PresensiModel> attendanceRecords;

        if (filter.startDate != null && filter.endDate != null) {
          attendanceRecords = await PresensiService.getPresensiByPeriod(
            startDate: filter.startDate!,
            endDate: filter.endDate!,
            userId: filter.userId,
          );
        } else {
          final endDate = DateTime.now();
          final startDate = DateTime(2020, 1, 1);

          attendanceRecords = await PresensiService.getPresensiByPeriod(
            startDate: startDate,
            endDate: endDate,
            userId: filter.userId,
          );
        }

        if (filter.status != null) {
          attendanceRecords = attendanceRecords
              .where((record) => record.status.name == filter.status)
              .toList();
        }

        final presentCount = attendanceRecords
            .where((a) => a.status == StatusPresensi.hadir)
            .length;

        final absentCount = attendanceRecords
            .where((a) => a.status == StatusPresensi.alpha)
            .length;

        final sickCount = attendanceRecords
            .where((a) => a.status == StatusPresensi.sakit)
            .length;

        final excusedCount = attendanceRecords
            .where((a) => a.status == StatusPresensi.izin)
            .length;

        final totalExpectedAttendance = attendanceRecords.length;
        final rawAttendanceRate = totalExpectedAttendance > 0
            ? (presentCount / totalExpectedAttendance * 100)
            : 0.0;
        final attendanceRate = rawAttendanceRate.clamp(0.0, 100.0);

        final userAttendanceSummary = <String, Map<String, dynamic>>{};

        for (final user in users) {
          final userRecords = attendanceRecords
              .where((a) => a.userId == user.id)
              .toList();

          final userPresent = userRecords
              .where((a) => a.status == StatusPresensi.hadir)
              .length;

          final userAbsent = userRecords
              .where((a) => a.status == StatusPresensi.alpha)
              .length;

          final userSick = userRecords
              .where((a) => a.status == StatusPresensi.sakit)
              .length;

          final userExcused = userRecords
              .where((a) => a.status == StatusPresensi.izin)
              .length;

          final userExpectedTotal = userRecords.length;
          final rawUserAttendanceRate = userExpectedTotal > 0
              ? (userPresent / userExpectedTotal * 100)
              : 0.0;
          final userAttendanceRate = rawUserAttendanceRate.clamp(0.0, 100.0);

          userAttendanceSummary[user.id] = {
            'user': user,
            'totalRecords': userExpectedTotal,
            'presentCount': userPresent,
            'absentCount': userAbsent,
            'sickCount': userSick,
            'excusedCount': userExcused,
            'attendanceRate': userAttendanceRate,
          };
        }

        return {
          'attendanceRecords': attendanceRecords,
          'users': users,
          'statistics': {
            'totalRecords': totalExpectedAttendance,
            'presentCount': presentCount,
            'absentCount': absentCount,
            'sickCount': sickCount,
            'excusedCount': excusedCount,
            'attendanceRate': attendanceRate,
          },
          'userSummary': userAttendanceSummary,
        };
      } catch (e) {
        throw Exception('Error loading attendance report: $e');
      }
    });

/// State provider untuk filter
final attendanceFilterProvider = StateProvider<AttendanceReportFilter>((ref) {
  return const AttendanceReportFilter();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../shared/models/user_model.dart';
import '../../../../../shared/models/presensi_model.dart';
import '../models/attendance_report_filter.dart';

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

        // Build attendance query with proper date filtering
        Query attendanceQuery = firestore.collection('presensi');

        // Apply date filter to attendance records
        if (filter.startDate != null) {
          attendanceQuery = attendanceQuery.where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(filter.startDate!),
          );
        }
        if (filter.endDate != null) {
          final endOfDay = DateTime(
            filter.endDate!.year,
            filter.endDate!.month,
            filter.endDate!.day,
            23,
            59,
            59,
          );
          attendanceQuery = attendanceQuery.where(
            'timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          );
        }

        // Apply user filter
        if (filter.userId != null) {
          attendanceQuery = attendanceQuery.where(
            'userId',
            isEqualTo: filter.userId,
          );
        }

        // Apply status filter
        if (filter.status != null) {
          attendanceQuery = attendanceQuery.where(
            'status',
            isEqualTo: filter.status,
          );
        }

        final attendanceSnapshot = await attendanceQuery.get();

        // Parse to PresensiModel
        final attendanceRecords = <PresensiModel>[];
        for (var doc in attendanceSnapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final record = PresensiModel.fromJson({'id': doc.id, ...data});
            attendanceRecords.add(record);
          } catch (e) {
            // Skip invalid records
            continue;
          }
        }

        return _calculateAttendanceStatistics(attendanceRecords, users);
      } catch (e) {
        throw Exception('Failed to fetch attendance report: $e');
      }
    });

/// State provider untuk filter
final attendanceFilterProvider = StateProvider<AttendanceReportFilter>((ref) {
  return const AttendanceReportFilter();
});

Map<String, dynamic> _calculateAttendanceStatistics(
  List<PresensiModel> attendanceRecords,
  List<UserModel> users,
) {
  // Calculate statistics
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

  // Group by user for summary
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
        ? ((userPresent + userSick + userExcused) / userExpectedTotal * 100)
        : 0.0;

    userAttendanceSummary[user.id] = {
      'user': user,
      'present': userPresent,
      'absent': userAbsent,
      'sick': userSick,
      'excused': userExcused,
      'total': userExpectedTotal,
      'attendanceRate': rawUserAttendanceRate.clamp(0.0, 100.0),
      'records': userRecords,
    };
  }

  return {
    'attendanceRecords': attendanceRecords,
    'users': users,
    'presentCount': presentCount,
    'absentCount': absentCount,
    'sickCount': sickCount,
    'excusedCount': excusedCount,
    'totalExpectedAttendance': totalExpectedAttendance,
    'attendanceRate': attendanceRate,
    'userAttendanceSummary': userAttendanceSummary,
  };
}

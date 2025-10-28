import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisantri/shared/services/auth_service.dart';
import 'package:sisantri/shared/services/firestore_service.dart';
import 'package:sisantri/shared/services/presensi_service.dart';

/// Provider untuk statistik user yang lebih comprehensive
final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) return {};

  try {
    // Get presensi minggu ini
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weeklyPresensi = await PresensiService.getPresensiByPeriod(
      startDate: startOfWeek,
      endDate: now,
      userId: currentUser.uid,
    );

    // Get presensi bulan ini
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthlyPresensi = await PresensiService.getPresensiByPeriod(
      startDate: startOfMonth,
      endDate: now,
      userId: currentUser.uid,
    );

    // Hitung statistik
    final weeklyHadir = weeklyPresensi.where((p) => p.status == 'hadir').length;
    final weeklyTerlambat = weeklyPresensi
        .where((p) => p.status == 'terlambat')
        .length;
    final monthlyHadir = monthlyPresensi
        .where((p) => p.status == 'hadir')
        .length;
    final monthlyTerlambat = monthlyPresensi
        .where((p) => p.status == 'terlambat')
        .length;

    return {
      'weeklyTotal': weeklyPresensi.length,
      'weeklyHadir': weeklyHadir,
      'weeklyTerlambat': weeklyTerlambat,
      'weeklyPersentase': weeklyPresensi.isNotEmpty
          ? ((weeklyHadir + weeklyTerlambat) / weeklyPresensi.length * 100)
                .round()
          : 0,
      'monthlyTotal': monthlyPresensi.length,
      'monthlyHadir': monthlyHadir,
      'monthlyTerlambat': monthlyTerlambat,
      'monthlyPersentase': monthlyPresensi.isNotEmpty
          ? ((monthlyHadir + monthlyTerlambat) / monthlyPresensi.length * 100)
                .round()
          : 0,
    };
  } catch (e) {
    return {};
  }
});

/// Provider untuk rank user di leaderboard
final userRankProvider = FutureProvider<int?>((ref) async {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) return null;

  try {
    final leaderboard = await FirestoreService.getLeaderboard().first;
    final userIndex = leaderboard.indexWhere(
      (item) => item.userId == currentUser.uid,
    );
    return userIndex >= 0 ? userIndex + 1 : null;
  } catch (e) {
    return null;
  }
});

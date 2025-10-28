import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisantri/shared/services/auth_service.dart';
import 'package:sisantri/shared/services/firestore_service.dart';
import 'package:sisantri/shared/services/presensi_service.dart';
import 'package:sisantri/shared/models/presensi_model.dart';

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

    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthlyPresensi = await PresensiService.getPresensiByPeriod(
      startDate: startOfMonth,
      endDate: now,
      userId: currentUser.uid,
    );

    final weeklyHadir = weeklyPresensi
        .where((p) => p.status == StatusPresensi.hadir)
        .length;
    final monthlyHadir = monthlyPresensi
        .where((p) => p.status == StatusPresensi.hadir)
        .length;

    return {
      'weeklyTotal': weeklyPresensi.length,
      'weeklyHadir': weeklyHadir,
      'weeklyPersentase': weeklyPresensi.isNotEmpty
          ? (weeklyHadir / weeklyPresensi.length * 100).round()
          : 0,
      'monthlyTotal': monthlyPresensi.length,
      'monthlyHadir': monthlyHadir,
      'monthlyPersentase': monthlyPresensi.isNotEmpty
          ? (monthlyHadir / monthlyPresensi.length * 100).round()
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/firestore_service.dart';

/// Provider untuk notifikasi real-time
final notificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) {
    return Stream.value([]);
  }

  // Kombinasi notifikasi dari berbagai sumber
  return Stream.periodic(const Duration(minutes: 5), (index) async {
    try {
      List<Map<String, dynamic>> notifications = [];

      // Notifikasi pengumuman penting
      final recentPengumuman =
          await FirestoreService.getRecentPengumuman().first;
      for (final pengumuman in recentPengumuman.take(2)) {
        if (pengumuman.isPenting) {
          notifications.add({
            'type': 'pengumuman',
            'title': 'Pengumuman Penting',
            'message': pengumuman.judul,
            'time': pengumuman.formattedTanggal,
            'icon': Icons.campaign,
            'color': Colors.red,
          });
        }
      }

      // Notifikasi kegiatan hari ini
      final upcomingKegiatan =
          await FirestoreService.getUpcomingKegiatan().first;
      for (final kegiatan in upcomingKegiatan) {
        if (kegiatan.isToday) {
          notifications.add({
            'type': 'kegiatan',
            'title': 'Kegiatan Hari Ini',
            'message': kegiatan.nama,
            'time': kegiatan.formattedWaktu,
            'icon': Icons.event,
            'color': Colors.blue,
          });
        }
      }

      return notifications;
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }).asyncMap((future) => future);
});

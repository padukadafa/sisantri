import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/firestore_service.dart';
import '../../../../shared/services/presensi_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/jadwal_kegiatan_model.dart';
import '../../../../shared/models/pengumuman_model.dart';

/// Provider untuk user data real-time
final dashboardUserProvider = StreamProvider<UserModel?>((ref) {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) {
    return Stream.value(null);
  }

  return FirestoreService.getUsers().map(
    (users) => users.where((u) => u.id == currentUser.uid).firstOrNull,
  );
});

/// Provider untuk presensi hari ini dengan real-time updates
final todayPresensiProvider = StreamProvider<PresensiModel?>((ref) {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) {
    return Stream.value(null);
  }

  return PresensiService.getPresensiTodayStream().map(
    (presensiList) =>
        presensiList.where((p) => p.userId == currentUser.uid).firstOrNull,
  );
});

/// Provider untuk kegiatan mendatang
final upcomingKegiatanProvider = StreamProvider<List<JadwalKegiatanModel>>((
  ref,
) {
  return FirestoreService.getUpcomingKegiatan();
});

/// Provider untuk pengumuman terbaru
final recentPengumumanProvider = StreamProvider<List<PengumumanModel>>((ref) {
  return FirestoreService.getRecentPengumuman();
});

/// Provider untuk dashboard data yang dikombinasikan
final dashboardDataProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final user = ref.watch(dashboardUserProvider);
  final todayPresensi = ref.watch(todayPresensiProvider);
  final upcomingKegiatan = ref.watch(upcomingKegiatanProvider);
  final recentPengumuman = ref.watch(recentPengumumanProvider);

  // Jika ada yang loading, return loading
  if (user.isLoading ||
      todayPresensi.isLoading ||
      upcomingKegiatan.isLoading ||
      recentPengumuman.isLoading) {
    return const AsyncValue.loading();
  }

  // Jika ada error, return error
  if (user.hasError) {
    return AsyncValue.error(user.error!, user.stackTrace!);
  }
  if (todayPresensi.hasError) {
    return AsyncValue.error(todayPresensi.error!, todayPresensi.stackTrace!);
  }
  if (upcomingKegiatan.hasError) {
    return AsyncValue.error(
      upcomingKegiatan.error!,
      upcomingKegiatan.stackTrace!,
    );
  }
  if (recentPengumuman.hasError) {
    return AsyncValue.error(
      recentPengumuman.error!,
      recentPengumuman.stackTrace!,
    );
  }

  // Return data yang dikombinasikan
  return AsyncValue.data({
    'user': user.value,
    'todayPresensi': todayPresensi.value,
    'upcomingKegiatan': upcomingKegiatan.value ?? [],
    'recentPengumuman': recentPengumuman.value ?? [],
  });
});

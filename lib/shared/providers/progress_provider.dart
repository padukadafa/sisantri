import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_santri_model.dart';
import '../models/sesi_kajian_model.dart';
import '../services/progress_santri_service.dart';

// Provider untuk progress santri berdasarkan santri ID
final progressBySantriProvider =
    StreamProvider.family<List<ProgressSantriModel>, String>((ref, santriId) {
      return ProgressSantriService.streamProgressBySantri(santriId);
    });

// Provider untuk leaderboard berdasarkan materi
final leaderboardProvider =
    StreamProvider.family<List<ProgressSantriModel>, String>((ref, materiId) {
      return ProgressSantriService.streamLeaderboard(materiId);
    });

// Provider untuk sesi kajian santri
final sesiKajianBySantriProvider =
    FutureProvider.family<List<SesiKajianModel>, String>((ref, santriId) {
      return ProgressSantriService.getSesiKajianBySantri(santriId);
    });

// Provider untuk statistik materi
final statistikMateriProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, materiId) {
      return ProgressSantriService.getStatistikMateri(materiId);
    });

// State provider untuk santri yang sedang dipilih
final selectedSantriProvider = StateProvider<String?>((ref) => null);

// State provider untuk materi yang sedang dipilih
final selectedMateriProvider = StateProvider<String?>((ref) => null);

// Provider untuk progress santri yang sedang dipilih
final selectedSantriProgressProvider =
    Provider<AsyncValue<List<ProgressSantriModel>>>((ref) {
      final santriId = ref.watch(selectedSantriProvider);

      if (santriId == null) {
        return const AsyncValue.data([]);
      }

      return ref.watch(progressBySantriProvider(santriId));
    });

// Provider untuk leaderboard materi yang sedang dipilih
final selectedMateriLeaderboardProvider =
    Provider<AsyncValue<List<ProgressSantriModel>>>((ref) {
      final materiId = ref.watch(selectedMateriProvider);

      if (materiId == null) {
        return const AsyncValue.data([]);
      }

      return ref.watch(leaderboardProvider(materiId));
    });

// Notifier untuk operasi progress santri
class ProgressSantriNotifier extends StateNotifier<AsyncValue<void>> {
  ProgressSantriNotifier() : super(const AsyncValue.data(null));

  // Membuat progress baru
  Future<void> createProgress(ProgressSantriModel progress) async {
    state = const AsyncValue.loading();
    try {
      await ProgressSantriService.createProgress(progress);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Update progress
  Future<void> updateProgress(String id, ProgressSantriModel progress) async {
    state = const AsyncValue.loading();
    try {
      await ProgressSantriService.updateProgress(id, progress);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Mencatat sesi kajian baru
  Future<void> createSesiKajian(SesiKajianModel sesi) async {
    state = const AsyncValue.loading();
    try {
      await ProgressSantriService.createSesiKajian(sesi);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Buat dummy data
  Future<void> createDummyProgress() async {
    state = const AsyncValue.loading();
    try {
      await ProgressSantriService.createDummyProgress();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final progressSantriNotifierProvider =
    StateNotifierProvider<ProgressSantriNotifier, AsyncValue<void>>((ref) {
      return ProgressSantriNotifier();
    });

// Provider untuk progress summary (ringkasan progress santri)
final progressSummaryProvider = Provider.family<Map<String, dynamic>, String>((
  ref,
  santriId,
) {
  final progressAsync = ref.watch(progressBySantriProvider(santriId));

  return progressAsync.when(
    data: (progressList) {
      if (progressList.isEmpty) {
        return {
          'totalMateri': 0,
          'totalSesi': 0,
          'materiSelesai': 0,
          'rataRataKehadiran': 0.0,
        };
      }

      final totalMateri = progressList.length;
      final totalSesi = progressList.fold<int>(
        0,
        (sum, progress) => sum + progress.totalSesiMengikuti,
      );

      // Asumsi materi selesai jika total sesi > 10 (bisa disesuaikan)
      final materiSelesai = progressList
          .where((progress) => progress.totalSesiMengikuti >= 10)
          .length;

      final rataRataKehadiran = totalSesi / totalMateri;

      return {
        'totalMateri': totalMateri,
        'totalSesi': totalSesi,
        'materiSelesai': materiSelesai,
        'rataRataKehadiran': rataRataKehadiran,
      };
    },
    loading: () => {
      'totalMateri': 0,
      'totalSesi': 0,
      'materiSelesai': 0,
      'rataRataKehadiran': 0.0,
    },
    error: (_, __) => {
      'totalMateri': 0,
      'totalSesi': 0,
      'materiSelesai': 0,
      'rataRataKehadiran': 0.0,
    },
  );
});

// Provider untuk recent activity (aktivitas terbaru)
final recentActivityProvider =
    Provider.family<AsyncValue<List<SesiKajianModel>>, String>((ref, santriId) {
      final sesiAsync = ref.watch(sesiKajianBySantriProvider(santriId));

      return sesiAsync.when(
        data: (sesiList) {
          // Ambil 5 sesi terakhir
          final recentSesi = sesiList.take(5).toList();
          return AsyncValue.data(recentSesi);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    });

// Provider untuk filter tanggal sesi kajian
final sesiDateFilterProvider = StateProvider<DateTime?>((ref) => null);

// Provider untuk sesi kajian yang difilter berdasarkan tanggal
final filteredSesiKajianProvider =
    Provider.family<AsyncValue<List<SesiKajianModel>>, String>((ref, santriId) {
      final sesiAsync = ref.watch(sesiKajianBySantriProvider(santriId));
      final dateFilter = ref.watch(sesiDateFilterProvider);

      return sesiAsync.when(
        data: (sesiList) {
          if (dateFilter == null) {
            return AsyncValue.data(sesiList);
          }

          final filteredSesi = sesiList.where((sesi) {
            return sesi.tanggal.year == dateFilter.year &&
                sesi.tanggal.month == dateFilter.month &&
                sesi.tanggal.day == dateFilter.day;
          }).toList();

          return AsyncValue.data(filteredSesi);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    });

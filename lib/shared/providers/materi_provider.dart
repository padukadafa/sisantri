import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/materi_model.dart';
import '../services/materi_service.dart';

// Provider untuk semua materi
final materiProvider = StreamProvider<List<MateriModel>>((ref) {
  return MateriService.streamAllMateri();
});

// Provider untuk materi berdasarkan jenis
final materiByJenisProvider =
    StreamProvider.family<List<MateriModel>, JenisMateri>((ref, jenis) {
      return MateriService.streamMateriByJenis(jenis);
    });

// Provider untuk materi berdasarkan ID
final materiByIdProvider = FutureProvider.family<MateriModel?, String>((
  ref,
  id,
) {
  return MateriService.getMateriById(id);
});

// State provider untuk filter jenis materi
final materiFilterProvider = StateProvider<JenisMateri?>((ref) => null);

// Provider untuk materi yang sudah difilter
final filteredMateriProvider = Provider<AsyncValue<List<MateriModel>>>((ref) {
  final filter = ref.watch(materiFilterProvider);

  if (filter == null) {
    return ref.watch(materiProvider);
  } else {
    return ref.watch(materiByJenisProvider(filter));
  }
});

// Provider untuk loading state
final materiLoadingProvider = StateProvider<bool>((ref) => false);

// Provider untuk error state
final materiErrorProvider = StateProvider<String?>((ref) => null);

// Notifier untuk operasi CRUD materi
class MateriNotifier extends StateNotifier<AsyncValue<List<MateriModel>>> {
  MateriNotifier() : super(const AsyncValue.loading());

  // Membuat materi baru
  Future<void> createMateri(MateriModel materi) async {
    try {
      await MateriService.createMateri(materi);
      // Stream akan otomatis update
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update materi
  Future<void> updateMateri(String id, MateriModel materi) async {
    try {
      await MateriService.updateMateri(id, materi);
      // Stream akan otomatis update
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Hapus materi
  Future<void> deleteMateri(String id) async {
    try {
      await MateriService.deleteMateri(id);
      // Stream akan otomatis update
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Buat dummy data
  Future<void> createDummyData() async {
    try {
      await MateriService.createDummyMateri();
      // Stream akan otomatis update
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final materiNotifierProvider =
    StateNotifierProvider<MateriNotifier, AsyncValue<List<MateriModel>>>((ref) {
      return MateriNotifier();
    });

// Provider untuk statistik materi
final materiStatsProvider = Provider<Map<JenisMateri, int>>((ref) {
  final materiAsync = ref.watch(materiProvider);

  return materiAsync.when(
    data: (materiList) {
      final stats = <JenisMateri, int>{};

      for (final jenis in JenisMateri.values) {
        stats[jenis] = materiList
            .where((materi) => materi.jenis == jenis)
            .length;
      }

      return stats;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// Provider untuk materi yang paling populer (berdasarkan tags)
final popularMateriProvider = Provider<AsyncValue<List<MateriModel>>>((ref) {
  final materiAsync = ref.watch(materiProvider);

  return materiAsync.when(
    data: (materiList) {
      // Sort berdasarkan jumlah tags (asumsi lebih banyak tag = lebih populer)
      final sortedMateri = List<MateriModel>.from(materiList);
      sortedMateri.sort(
        (a, b) => (b.tags?.length ?? 0).compareTo(a.tags?.length ?? 0),
      );

      return AsyncValue.data(sortedMateri.take(5).toList());
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

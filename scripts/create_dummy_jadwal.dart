import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import '../lib/shared/services/dummy_data_service.dart';
import '../lib/firebase_options.dart';

/// Script untuk membuat dummy jadwal data
///
/// Usage:
/// dart scripts/create_dummy_jadwal.dart
///
/// Options:
/// --recreate : Hapus jadwal lama dan buat baru
/// --all      : Buat semua dummy data (users, jadwal, pengumuman)

void main(List<String> args) async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Firebase initialized successfully
    // Creating dummy jadwal data

    if (args.contains('--recreate')) {
      // Mode: Recreate jadwal data
      await DummyDataService.recreateJadwalData();
    } else if (args.contains('--all')) {
      // Mode: Create all dummy data
      await DummyDataService.createAllDummyData();
    } else {
      // Mode: Create jadwal data only
      await DummyDataService.createDummyJadwal();
    }

    // Script completed successfully
    // Data created summary:
    //   • 2 jadwal kajian (Tafsir & Akhlak)
    //   • 2 jadwal kajian/pengajian
    //   • 2 jadwal tahfidz
    //   • 1 jadwal kerja bakti
    //   • 2 jadwal olahraga
    //   • 1 jadwal kegiatan umum
    //   • 1 jadwal tidak aktif (untuk testing)
    // Total: 11 jadwal berhasil dibuat
  } catch (e) {
    // Error occurred
    exit(1);
  }

  exit(0);
}

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

    print('🚀 Firebase berhasil diinisialisasi');
    print('📅 Membuat dummy jadwal data...\n');

    if (args.contains('--recreate')) {
      print('🔄 Mode: Recreate jadwal data');
      await DummyDataService.recreateJadwalData();
    } else if (args.contains('--all')) {
      print('📋 Mode: Buat semua dummy data');
      await DummyDataService.createAllDummyData();
    } else {
      print('📅 Mode: Buat jadwal data saja');
      await DummyDataService.createDummyJadwal();
    }

    print('\n✅ Script selesai dijalankan!');
    print('\n📊 Data yang dibuat:');
    print('   • 2 jadwal kajian (Tafsir & Akhlak)');
    print('   • 2 jadwal kajian/pengajian');
    print('   • 2 jadwal tahfidz');
    print('   • 1 jadwal kerja bakti');
    print('   • 2 jadwal olahraga');
    print('   • 1 jadwal kegiatan umum');
    print('   • 1 jadwal tidak aktif (untuk testing)');
    print('\n🎯 Total: 11 jadwal berhasil dibuat');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }

  exit(0);
}

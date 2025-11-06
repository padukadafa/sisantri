import 'package:sisantri/shared/models/jadwal_model.dart';

/// Helper class untuk form jadwal
class JadwalFormHelpers {
  /// Get hint text untuk nama kegiatan berdasarkan kategori
  static String getHintTextForKategori(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.tahfidz:
        return 'Contoh: Tahfidz Juz 30';
      case TipeJadwal.bacaan:
        return 'Contoh: Bacaan Surah Al-Fatihah';
      case TipeJadwal.olahraga:
        return 'Contoh: Sepak Bola';
      case TipeJadwal.pengajian:
        return 'Contoh: Pengajian Rutin';
      case TipeJadwal.kegiatan:
        return 'Contoh: Kegiatan Sosial';
    }
  }

  /// Get hint text untuk tempat berdasarkan kategori
  static String getTempatHintForKategori(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.tahfidz:
        return 'Contoh: Masjid';
      case TipeJadwal.bacaan:
        return 'Contoh: Masjid';
      case TipeJadwal.olahraga:
        return 'Contoh: Lapangan';
      case TipeJadwal.pengajian:
        return 'Contoh: Masjid';
      case TipeJadwal.kegiatan:
        return 'Contoh: Aula';
    }
  }

  /// Get display name untuk kategori
  static String getKategoriDisplayName(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.tahfidz:
        return 'Tahfidz';
      case TipeJadwal.bacaan:
        return 'Bacaan';
      case TipeJadwal.olahraga:
        return 'Olahraga';
      case TipeJadwal.pengajian:
        return 'Pengajian';
      case TipeJadwal.kegiatan:
        return 'Kegiatan';
    }
  }
}

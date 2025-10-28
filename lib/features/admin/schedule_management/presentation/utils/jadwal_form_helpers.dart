import 'package:sisantri/shared/models/jadwal_model.dart';

/// Helper class untuk form jadwal
class JadwalFormHelpers {
  /// Get hint text untuk nama kegiatan berdasarkan kategori
  static String getHintTextForKategori(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.kajian:
        return 'Contoh: Kajian Kitab Bulughul Maram';
      case TipeJadwal.tahfidz:
        return 'Contoh: Tahfidz Juz 30';
      case TipeJadwal.kerjaBakti:
        return 'Contoh: Kebersihan Masjid';
      case TipeJadwal.olahraga:
        return 'Contoh: Sepak Bola';
      case TipeJadwal.libur:
        return 'Contoh: Istirahat';
      case TipeJadwal.pengajian:
        return 'Contoh: Pengajian Rutin';
      case TipeJadwal.kegiatan:
        return 'Contoh: Kegiatan Sosial';
      case TipeJadwal.umum:
        return 'Contoh: Rapat Santri';
    }
  }

  /// Get hint text untuk tempat berdasarkan kategori
  static String getTempatHintForKategori(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.kajian:
        return 'Contoh: Ruang Kajian';
      case TipeJadwal.tahfidz:
        return 'Contoh: Masjid';
      case TipeJadwal.kerjaBakti:
        return 'Contoh: Halaman Pondok';
      case TipeJadwal.olahraga:
        return 'Contoh: Lapangan';
      case TipeJadwal.libur:
        return 'Contoh: Kamar/Asrama';
      case TipeJadwal.pengajian:
        return 'Contoh: Masjid';
      case TipeJadwal.kegiatan:
        return 'Contoh: Aula';
      case TipeJadwal.umum:
        return 'Contoh: Ruang Rapat';
    }
  }

  /// Get display name untuk kategori
  static String getKategoriDisplayName(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.kajian:
        return 'Kajian';
      case TipeJadwal.tahfidz:
        return 'Tahfidz';
      case TipeJadwal.kerjaBakti:
        return 'Kerja Bakti';
      case TipeJadwal.olahraga:
        return 'Olahraga';
      case TipeJadwal.libur:
        return 'Libur';
      case TipeJadwal.pengajian:
        return 'Pengajian';
      case TipeJadwal.kegiatan:
        return 'Kegiatan';
      case TipeJadwal.umum:
        return 'Umum';
    }
  }
}

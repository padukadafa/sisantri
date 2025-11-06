import 'package:flutter/material.dart';
import 'package:sisantri/shared/models/jadwal_model.dart';
import '../providers/schedule_providers.dart';

/// Helper class untuk fungsi-fungsi utility jadwal
class ScheduleHelpers {
  /// Format tanggal ke string key (YYYY-MM-DD)
  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse string key ke DateTime
  static DateTime parseDateKey(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Cek apakah tanggal adalah hari ini
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Format DateTime ke string tanggal yang user-friendly
  static String formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format DateTime dengan label (Hari Ini, Besok, Kemarin)
  static String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final yesterday = now.subtract(const Duration(days: 1));

    if (isToday(date)) {
      return 'Hari Ini, ${formatDate(date)}';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Besok, ${formatDate(date)}';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Kemarin, ${formatDate(date)}';
    } else {
      return formatDate(date);
    }
  }

  /// Format TimeOfDay ke string (HH:MM)
  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Get warna berdasarkan kategori jadwal
  static Color getKategoriColor(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.tahfidz:
        return Colors.purple;
      case TipeJadwal.bacaan:
        return Colors.orange;
      case TipeJadwal.olahraga:
        return Colors.red;
      case TipeJadwal.pengajian:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get display name untuk kategori jadwal
  static String getKategoriDisplayName(TipeJadwal kategori) {
    switch (kategori) {
      case TipeJadwal.tahfidz:
        return 'TAHFIDZ';
      case TipeJadwal.bacaan:
        return 'BACAN';
      case TipeJadwal.olahraga:
        return 'OLAHRAGA';
      case TipeJadwal.pengajian:
        return 'PENGAJIAN';
      case TipeJadwal.kegiatan:
        return 'KEGIATAN';
    }
  }

  /// Get empty state title berdasarkan filter
  static String getEmptyStateTitle(ScheduleFilter filter) {
    switch (filter) {
      case ScheduleFilter.futureOnly:
        return 'Belum ada kegiatan yang akan datang';
      case ScheduleFilter.thisMonthAndFuture:
        return 'Belum ada kegiatan bulan ini';
      case ScheduleFilter.lastMonth:
        return 'Tidak ada kegiatan dalam 1 bulan terakhir';
      case ScheduleFilter.last3Months:
        return 'Tidak ada kegiatan dalam 3 bulan terakhir';
      case ScheduleFilter.all:
        return 'Belum ada kegiatan terjadwal';
    }
  }

  /// Get empty state message berdasarkan filter
  static String getEmptyStateMessage(
    ScheduleFilter filter,
    bool hasOtherSchedules,
  ) {
    if (!hasOtherSchedules) {
      return 'Tambahkan kegiatan baru untuk memulai';
    }

    switch (filter) {
      case ScheduleFilter.futureOnly:
        return 'Tidak ada jadwal yang akan datang.\nSemua jadwal sudah lewat atau belum ada jadwal.';
      case ScheduleFilter.thisMonthAndFuture:
        return 'Tidak ada jadwal untuk bulan ini dan mendatang.\nLihat semua jadwal untuk melihat jadwal sebelumnya.';
      case ScheduleFilter.lastMonth:
        return 'Tidak ada jadwal dalam rentang 1 bulan terakhir.\nCoba filter lain atau lihat semua jadwal.';
      case ScheduleFilter.last3Months:
        return 'Tidak ada jadwal dalam rentang 3 bulan terakhir.\nCoba filter lain atau lihat semua jadwal.';
      case ScheduleFilter.all:
        return 'Tambahkan kegiatan baru untuk memulai';
    }
  }

  /// Get filter info text
  static String getFilterInfoText(ScheduleFilter filter) {
    switch (filter) {
      case ScheduleFilter.futureOnly:
        return 'Menampilkan jadwal hari ini dan mendatang';
      case ScheduleFilter.thisMonthAndFuture:
        return 'Menampilkan jadwal bulan ini dan mendatang';
      case ScheduleFilter.lastMonth:
        return 'Menampilkan jadwal 1 bulan terakhir';
      case ScheduleFilter.last3Months:
        return 'Menampilkan jadwal 3 bulan terakhir';
      case ScheduleFilter.all:
        return 'Menampilkan semua jadwal';
    }
  }
}

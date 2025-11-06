import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/shared/models/jadwal_model.dart';

class JadwalKegiatan {
  final String id;
  final String nama;
  final String deskripsi;
  final DateTime tanggal;
  final TimeOfDay waktuMulai;
  final TimeOfDay waktuSelesai;
  final String tempat;
  final TipeJadwal kategori;
  final String? materiId;
  final String? materiNama;

  final String? pemateriId;
  final String? pemateriNama;
  final String? tema;

  final String? surah; // Nama surah untuk kajian Quran
  final int? ayatMulai; // Ayat mulai untuk kajian Quran
  final int? ayatSelesai; // Ayat selesai untuk kajian Quran
  final int? halamanMulai; // Halaman mulai untuk kitab
  final int? halamanSelesai; // Halaman selesai untuk kitab
  final int? hadistMulai; // Hadist mulai untuk kitab hadist
  final int? hadistSelesai; // Hadist selesai untuk kitab hadist
  final String? topikBahasan; // Topik spesifik yang dibahas
  final String? catatan; // Catatan tambahan untuk kajian

  final bool isAktif;
  final DateTime createdAt;

  JadwalKegiatan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.tempat,
    required this.kategori,
    this.materiId,
    this.materiNama,
    this.pemateriId,
    this.pemateriNama,
    this.tema,
    this.surah,
    this.ayatMulai,
    this.ayatSelesai,
    this.halamanMulai,
    this.halamanSelesai,
    this.hadistMulai,
    this.hadistSelesai,
    this.topikBahasan,
    this.catatan,
    this.isAktif = true,
    required this.createdAt,
  });

  factory JadwalKegiatan.fromJson(String id, Map<String, dynamic> json) {
    return JadwalKegiatan(
      id: id,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tanggal: (json['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      waktuMulai: _timeFromString(json['waktuMulai'] ?? '00:00'),
      waktuSelesai: _timeFromString(json['waktuSelesai'] ?? '00:00'),
      tempat: json['tempat'] ?? '',
      kategori: TipeJadwal.fromString(json['kategori'] ?? 'umum'),
      materiId: json['materiId'],
      materiNama: json['materiNama'],
      pemateriId: json['pemateriId'],
      pemateriNama: json['pemateriNama'],
      tema: json['tema'],
      surah: json['surah'],
      ayatMulai: json['ayatMulai'],
      ayatSelesai: json['ayatSelesai'],
      halamanMulai: json['halamanMulai'],
      halamanSelesai: json['halamanSelesai'],
      hadistMulai: json['hadistMulai'],
      hadistSelesai: json['hadistSelesai'],
      topikBahasan: json['topikBahasan'],
      catatan: json['catatan'],
      isAktif: json['isAktif'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'tanggal': Timestamp.fromDate(tanggal),
      'waktuMulai':
          '${waktuMulai.hour.toString().padLeft(2, '0')}:${waktuMulai.minute.toString().padLeft(2, '0')}',
      'waktuSelesai':
          '${waktuSelesai.hour.toString().padLeft(2, '0')}:${waktuSelesai.minute.toString().padLeft(2, '0')}',
      'tempat': tempat,
      'kategori': kategori.value,
      if (materiId != null) 'materiId': materiId,
      if (materiNama != null) 'materiNama': materiNama,
      if (pemateriId != null) 'pemateriId': pemateriId,
      if (pemateriNama != null) 'pemateriNama': pemateriNama,
      if (tema != null) 'tema': tema,
      if (surah != null) 'surah': surah,
      if (ayatMulai != null) 'ayatMulai': ayatMulai,
      if (ayatSelesai != null) 'ayatSelesai': ayatSelesai,
      if (halamanMulai != null) 'halamanMulai': halamanMulai,
      if (halamanSelesai != null) 'halamanSelesai': halamanSelesai,
      if (hadistMulai != null) 'hadistMulai': hadistMulai,
      if (hadistSelesai != null) 'hadistSelesai': hadistSelesai,
      if (topikBahasan != null) 'topikBahasan': topikBahasan,
      if (catatan != null) 'catatan': catatan,
      'isAktif': isAktif,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static TimeOfDay _timeFromString(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  /// Helper getter untuk durasi kegiatan dalam menit
  int get durationInMinutes {
    final start = waktuMulai.hour * 60 + waktuMulai.minute;
    final end = waktuSelesai.hour * 60 + waktuSelesai.minute;
    return end - start;
  }

  /// Helper getter untuk format waktu yang mudah dibaca
  String get waktuFormatted {
    return '${_formatTime(waktuMulai)} - ${_formatTime(waktuSelesai)}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

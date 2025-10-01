import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jadwal_kegiatan_model.dart';

/// Provider untuk daftar semua jadwal kegiatan
final jadwalProvider = StreamProvider<List<JadwalKegiatan>>((ref) {
  return FirebaseFirestore.instance
      .collection('jadwal')
      .orderBy('tanggal', descending: false)
      .orderBy('waktuMulai')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => JadwalKegiatan.fromJson(doc.id, doc.data()))
            .toList();
      });
});

/// Provider untuk jadwal hari ini
final jadwalHariIniProvider = Provider<List<JadwalKegiatan>>((ref) {
  final jadwalList = ref.watch(jadwalProvider).value ?? [];
  final today = DateTime.now();

  return jadwalList.where((jadwal) {
    return jadwal.tanggal.year == today.year &&
        jadwal.tanggal.month == today.month &&
        jadwal.tanggal.day == today.day &&
        jadwal.isAktif;
  }).toList();
});

/// Provider untuk statistik jadwal
final jadwalStatsProvider = Provider<Map<String, int>>((ref) {
  final jadwalList = ref.watch(jadwalProvider).value ?? [];
  final today = DateTime.now();

  return {
    'total': jadwalList.length,
    'aktif': jadwalList.where((j) => j.isAktif).length,
    'hari_ini': jadwalList
        .where(
          (j) =>
              j.tanggal.year == today.year &&
              j.tanggal.month == today.month &&
              j.tanggal.day == today.day &&
              j.isAktif,
        )
        .length,
    'mendatang': jadwalList
        .where((j) => j.tanggal.isAfter(today) && j.isAktif)
        .length,
  };
});

/// Provider untuk jadwal berdasarkan kategori
final jadwalByKategoriProvider = Provider.family<List<JadwalKegiatan>, String>((
  ref,
  kategori,
) {
  final jadwalList = ref.watch(jadwalProvider).value ?? [];

  if (kategori == 'semua') {
    return jadwalList;
  }

  return jadwalList
      .where((jadwal) => jadwal.kategori.value == kategori && jadwal.isAktif)
      .toList();
});

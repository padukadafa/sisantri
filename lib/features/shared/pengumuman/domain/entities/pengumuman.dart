import 'package:equatable/equatable.dart';

class Pengumuman extends Equatable {
  final String id;
  final String judul;
  final String konten;
  final String kategori; // umum, penting, mendesak
  final String prioritas; // low, medium, high
  final String createdBy;
  final String createdByName;
  final String targetAudience; // all, santri, dewan_guru, kelas_tertentu
  final List<String> targetRoles;
  final List<String> targetClasses;
  final String? lampiranUrl;
  final DateTime tanggalMulai;
  final DateTime? tanggalBerakhir;
  final bool isPublished;
  final bool isPinned;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Pengumuman({
    required this.id,
    required this.judul,
    required this.konten,
    required this.kategori,
    required this.prioritas,
    required this.createdBy,
    required this.createdByName,
    required this.targetAudience,
    required this.targetRoles,
    required this.targetClasses,
    this.lampiranUrl,
    required this.tanggalMulai,
    this.tanggalBerakhir,
    required this.isPublished,
    required this.isPinned,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    judul,
    konten,
    kategori,
    prioritas,
    createdBy,
    createdByName,
    targetAudience,
    targetRoles,
    targetClasses,
    lampiranUrl,
    tanggalMulai,
    tanggalBerakhir,
    isPublished,
    isPinned,
    viewCount,
    createdAt,
    updatedAt,
  ];
}

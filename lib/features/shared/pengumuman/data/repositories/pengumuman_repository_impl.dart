import '../../domain/entities/pengumuman.dart';
import '../../domain/repositories/pengumuman_repository.dart';
import '../datasources/pengumuman_remote_data_source.dart';
import '../models/announcement_model.dart';

class PengumumanRepositoryImpl implements PengumumanRepository {
  final PengumumanRemoteDataSource remoteDataSource;

  PengumumanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Pengumuman>> getAllPengumuman({
    String? kategori,
    String? targetAudience,
    bool? isPublished,
  }) async {
    return await remoteDataSource.getAllPengumuman(
      kategori: kategori,
      targetAudience: targetAudience,
      isPublished: isPublished,
    );
  }

  @override
  Future<Pengumuman> getPengumumanById(String id) async {
    return await remoteDataSource.getPengumumanById(id);
  }

  @override
  Future<List<Pengumuman>> getPengumumanForUser({
    required String userRole,
    String? userClass,
  }) async {
    return await remoteDataSource.getPengumumanForUser(
      userRole: userRole,
      userClass: userClass,
    );
  }

  @override
  Future<String> createPengumuman(Pengumuman pengumuman) async {
    final model = AnnouncementModel(
      id: pengumuman.id,
      judul: pengumuman.judul,
      konten: pengumuman.konten,
      kategori: pengumuman.kategori,
      prioritas: pengumuman.prioritas,
      createdBy: pengumuman.createdBy,
      createdByName: pengumuman.createdByName,
      targetAudience: pengumuman.targetAudience,
      targetRoles: pengumuman.targetRoles,
      targetClasses: pengumuman.targetClasses,
      lampiranUrl: pengumuman.lampiranUrl,
      tanggalMulai: pengumuman.tanggalMulai,
      tanggalBerakhir: pengumuman.tanggalBerakhir,
      isPublished: pengumuman.isPublished,
      isPinned: pengumuman.isPinned,
      viewCount: pengumuman.viewCount,
      createdAt: pengumuman.createdAt,
      updatedAt: pengumuman.updatedAt,
    );
    return await remoteDataSource.createPengumuman(model);
  }

  @override
  Future<void> updatePengumuman(Pengumuman pengumuman) async {
    final model = AnnouncementModel(
      id: pengumuman.id,
      judul: pengumuman.judul,
      konten: pengumuman.konten,
      kategori: pengumuman.kategori,
      prioritas: pengumuman.prioritas,
      createdBy: pengumuman.createdBy,
      createdByName: pengumuman.createdByName,
      targetAudience: pengumuman.targetAudience,
      targetRoles: pengumuman.targetRoles,
      targetClasses: pengumuman.targetClasses,
      lampiranUrl: pengumuman.lampiranUrl,
      tanggalMulai: pengumuman.tanggalMulai,
      tanggalBerakhir: pengumuman.tanggalBerakhir,
      isPublished: pengumuman.isPublished,
      isPinned: pengumuman.isPinned,
      viewCount: pengumuman.viewCount,
      createdAt: pengumuman.createdAt,
      updatedAt: pengumuman.updatedAt,
    );
    return await remoteDataSource.updatePengumuman(model);
  }

  @override
  Future<void> deletePengumuman(String id) async {
    return await remoteDataSource.deletePengumuman(id);
  }

  @override
  Future<void> markAsRead({
    required String pengumumanId,
    required String userId,
  }) async {
    return await remoteDataSource.markAsRead(
      pengumumanId: pengumumanId,
      userId: userId,
    );
  }

  @override
  Future<bool> hasUserRead({
    required String pengumumanId,
    required String userId,
  }) async {
    return await remoteDataSource.hasUserRead(
      pengumumanId: pengumumanId,
      userId: userId,
    );
  }

  @override
  Future<void> incrementViewCount(String id) async {
    return await remoteDataSource.incrementViewCount(id);
  }
}

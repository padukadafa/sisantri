import 'package:sisantri/features/shared/announcement/data/datasources/announcement_remote_data_source.dart';

import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;

  AnnouncementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Announcement>> getAllAnnouncement({
    String? kategori,
    String? targetAudience,
    bool? isPublished,
  }) async {
    return await remoteDataSource.getAllAnnouncement(
      kategori: kategori,
      targetAudience: targetAudience,
      isPublished: isPublished,
    );
  }

  @override
  Future<Announcement> getAnnouncementById(String id) async {
    return await remoteDataSource.getAnnouncementById(id);
  }

  @override
  Future<List<Announcement>> getAnnouncementForUser({
    required String userRole,
    String? userClass,
  }) async {
    return await remoteDataSource.getAnnouncementForUser(
      userRole: userRole,
      userClass: userClass,
    );
  }

  @override
  Future<String> createAnnouncement(Announcement announcement) async {
    final model = AnnouncementModel(
      id: announcement.id,
      judul: announcement.judul,
      konten: announcement.konten,
      kategori: announcement.kategori,
      prioritas: announcement.prioritas,
      createdBy: announcement.createdBy,
      createdByName: announcement.createdByName,
      targetAudience: announcement.targetAudience,
      targetRoles: announcement.targetRoles,
      targetClasses: announcement.targetClasses,
      lampiranUrl: announcement.lampiranUrl,
      tanggalMulai: announcement.tanggalMulai,
      tanggalBerakhir: announcement.tanggalBerakhir,
      isPublished: announcement.isPublished,
      isPinned: announcement.isPinned,
      viewCount: announcement.viewCount,
      createdAt: announcement.createdAt,
      updatedAt: announcement.updatedAt,
    );
    return await remoteDataSource.createAnnouncement(model);
  }

  @override
  Future<void> updateAnnouncement(Announcement announcement) async {
    final model = AnnouncementModel(
      id: announcement.id,
      judul: announcement.judul,
      konten: announcement.konten,
      kategori: announcement.kategori,
      prioritas: announcement.prioritas,
      createdBy: announcement.createdBy,
      createdByName: announcement.createdByName,
      targetAudience: announcement.targetAudience,
      targetRoles: announcement.targetRoles,
      targetClasses: announcement.targetClasses,
      lampiranUrl: announcement.lampiranUrl,
      tanggalMulai: announcement.tanggalMulai,
      tanggalBerakhir: announcement.tanggalBerakhir,
      isPublished: announcement.isPublished,
      isPinned: announcement.isPinned,
      viewCount: announcement.viewCount,
      createdAt: announcement.createdAt,
      updatedAt: announcement.updatedAt,
    );
    return await remoteDataSource.updateAnnouncement(model);
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    return await remoteDataSource.deleteAnnouncement(id);
  }

  @override
  Future<void> markAsRead({
    required String announcementId,
    required String userId,
  }) async {
    return await remoteDataSource.markAsRead(
      announcementId: announcementId,
      userId: userId,
    );
  }

  @override
  Future<bool> hasUserRead({
    required String announcementId,
    required String userId,
  }) async {
    return await remoteDataSource.hasUserRead(
      announcementId: announcementId,
      userId: userId,
    );
  }

  @override
  Future<void> incrementViewCount(String id) async {
    return await remoteDataSource.incrementViewCount(id);
  }
}

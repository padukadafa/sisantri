import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/core/error/exceptions.dart';
import '../models/announcement_model.dart';
import 'announcement_remote_data_source.dart';

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  final FirebaseFirestore firestore;

  AnnouncementRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AnnouncementModel>> getAllAnnouncement({
    String? kategori,
    String? targetAudience,
    bool? isPublished,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore.collection('announcement');

      if (kategori != null) {
        query = query.where('kategori', isEqualTo: kategori);
      }

      if (targetAudience != null) {
        query = query.where('targetAudience', isEqualTo: targetAudience);
      }

      if (isPublished != null) {
        query = query.where('isPublished', isEqualTo: isPublished);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => AnnouncementModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AnnouncementModel> getAnnouncementById(String id) async {
    try {
      final doc = await firestore.collection('announcement').doc(id).get();

      if (!doc.exists) {
        throw ServerException(message: 'Announcement tidak ditemukan');
      }

      return AnnouncementModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncementForUser({
    required String userRole,
    String? userClass,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore
          .collection('announcement')
          .where('isPublished', isEqualTo: true);

      final snapshot = await query.orderBy('createdAt', descending: true).get();

      // Filter based on user role and class
      final filtered = snapshot.docs.where((doc) {
        final data = doc.data();
        final targetAudience = data['targetAudience'] as String;
        final targetRoles =
            (data['targetRoles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
        final targetClasses =
            (data['targetClasses'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];

        // If target audience is 'all', include it
        if (targetAudience == 'all') return true;

        // Check if user's role matches target roles
        if (targetRoles.isNotEmpty && targetRoles.contains(userRole)) {
          // If specific classes are targeted and user has a class
          if (targetClasses.isNotEmpty && userClass != null) {
            return targetClasses.contains(userClass);
          }
          return true;
        }

        return false;
      }).toList();

      return filtered
          .map(
            (doc) => AnnouncementModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> createAnnouncement(AnnouncementModel announcement) async {
    try {
      final docRef = await firestore
          .collection('announcement')
          .add(announcement.toJson()..remove('id'));
      return docRef.id;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      await firestore
          .collection('announcement')
          .doc(announcement.id)
          .update(announcement.toJson());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    try {
      await firestore.collection('announcement').doc(id).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead({
    required String announcementId,
    required String userId,
  }) async {
    try {
      await firestore
          .collection('announcement')
          .doc(announcementId)
          .collection('reads')
          .doc(userId)
          .set({
            'userId': userId,
            'readAt': FieldValue.serverTimestamp(),
            'isRead': true,
          });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> hasUserRead({
    required String announcementId,
    required String userId,
  }) async {
    try {
      final doc = await firestore
          .collection('announcement')
          .doc(announcementId)
          .collection('reads')
          .doc(userId)
          .get();

      return doc.exists && (doc.data()?['isRead'] as bool? ?? false);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> incrementViewCount(String id) async {
    try {
      await firestore.collection('announcement').doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

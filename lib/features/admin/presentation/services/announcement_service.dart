import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pengumuman_model.dart';
import '../../../../shared/helpers/messaging_helper.dart';

/// Service untuk CRUD operations pengumuman
class AnnouncementService {
  final FirebaseFirestore _firestore;

  AnnouncementService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Tambah pengumuman baru
  Future<String> addAnnouncement(Pengumuman pengumuman) async {
    try {
      final docRef = await _firestore
          .collection('pengumuman')
          .add(pengumuman.toJson());

      // Send notification if active
      if (pengumuman.isActive) {
        await _sendNotificationToTargetAudience(pengumuman);
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add announcement: $e');
    }
  }

  /// Update pengumuman
  Future<void> updateAnnouncement(Pengumuman pengumuman) async {
    try {
      await _firestore
          .collection('pengumuman')
          .doc(pengumuman.id)
          .update(pengumuman.toJson());
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  /// Delete pengumuman (soft delete)
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection('pengumuman').doc(id).update({
        'isActive': false,
        'deletedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  /// Toggle status aktif pengumuman
  Future<void> toggleAnnouncementStatus(String id, bool currentStatus) async {
    try {
      await _firestore.collection('pengumuman').doc(id).update({
        'isActive': !currentStatus,
      });
    } catch (e) {
      throw Exception('Failed to toggle announcement status: $e');
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String id) async {
    try {
      await _firestore.collection('pengumuman').doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  /// Send notification to target audience
  Future<void> _sendNotificationToTargetAudience(Pengumuman pengumuman) async {
    try {
      if (pengumuman.targetAudience.contains('all')) {
        await MessagingHelper.sendPengumumanToSantri(
          title: pengumuman.judul,
          message: pengumuman.konten,
        );
      } else if (pengumuman.targetAudience.contains('santri')) {
        await MessagingHelper.sendPengumumanToSantri(
          title: pengumuman.judul,
          message: pengumuman.konten,
        );
      }
    } catch (e) {
      // Log error but don't fail the announcement creation
      print('Failed to send notification: $e');
    }
  }

  /// Publish draft announcement
  Future<void> publishAnnouncement(String id) async {
    try {
      final doc = await _firestore.collection('pengumuman').doc(id).get();
      if (doc.exists) {
        final pengumuman = Pengumuman.fromJson({'id': id, ...doc.data()!});

        await _firestore.collection('pengumuman').doc(id).update({
          'isActive': true,
        });

        // Send notification
        await _sendNotificationToTargetAudience(pengumuman);
      }
    } catch (e) {
      throw Exception('Failed to publish announcement: $e');
    }
  }

  /// Get announcements by date range
  Future<List<Pengumuman>> getAnnouncementsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('pengumuman')
          .where(
            'tanggalPost',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'tanggalPost',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('tanggalPost', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Pengumuman.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get announcements by date range: $e');
    }
  }
}

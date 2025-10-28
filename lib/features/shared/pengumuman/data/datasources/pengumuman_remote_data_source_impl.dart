import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/pengumuman_model.dart';
import 'pengumuman_remote_data_source.dart';

class PengumumanRemoteDataSourceImpl implements PengumumanRemoteDataSource {
  final FirebaseFirestore firestore;

  PengumumanRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<PengumumanModel>> getAllPengumuman({
    String? kategori,
    String? targetAudience,
    bool? isPublished,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore.collection('pengumuman');

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
          .map((doc) => PengumumanModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PengumumanModel> getPengumumanById(String id) async {
    try {
      final doc = await firestore.collection('pengumuman').doc(id).get();

      if (!doc.exists) {
        throw ServerException(message: 'Pengumuman tidak ditemukan');
      }

      return PengumumanModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PengumumanModel>> getPengumumanForUser({
    required String userRole,
    String? userClass,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore
          .collection('pengumuman')
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
          .map((doc) => PengumumanModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> createPengumuman(PengumumanModel pengumuman) async {
    try {
      final docRef = await firestore
          .collection('pengumuman')
          .add(pengumuman.toJson()..remove('id'));
      return docRef.id;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updatePengumuman(PengumumanModel pengumuman) async {
    try {
      await firestore
          .collection('pengumuman')
          .doc(pengumuman.id)
          .update(pengumuman.toJson());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePengumuman(String id) async {
    try {
      await firestore.collection('pengumuman').doc(id).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead({
    required String pengumumanId,
    required String userId,
  }) async {
    try {
      await firestore
          .collection('pengumuman')
          .doc(pengumumanId)
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
    required String pengumumanId,
    required String userId,
  }) async {
    try {
      final doc = await firestore
          .collection('pengumuman')
          .doc(pengumumanId)
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
      await firestore.collection('pengumuman').doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

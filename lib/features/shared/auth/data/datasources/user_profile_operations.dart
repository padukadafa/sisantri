import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// User profile and RFID operations
class UserProfileOperations {
  final FirebaseFirestore _firestore;

  UserProfileOperations({required FirebaseFirestore firestore})
    : _firestore = firestore;

  /// Update user profile
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('users')
          .doc(user.id)
          .update(updatedUser.toJson());

      return updatedUser;
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  /// Update RFID Card ID
  Future<UserModel> updateRfidCardId({
    required String userId,
    required String rfidCardId,
  }) async {
    try {
      // Check if RFID already exists
      final existingRfid = await _firestore
          .collection('users')
          .where('rfidCardId', isEqualTo: rfidCardId)
          .get();

      if (existingRfid.docs.isNotEmpty) {
        final existingUser = existingRfid.docs.first;
        if (existingUser.id != userId) {
          throw Exception('RFID card already registered to another user');
        }
      }

      // Update user dengan RFID
      await _firestore.collection('users').doc(userId).update({
        'rfidCardId': rfidCardId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Get updated user
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromJson({'id': userId, ...userDoc.data()!});
    } catch (e) {
      throw Exception('Update RFID error: $e');
    }
  }

  /// Get user by RFID
  Future<UserModel?> getUserByRfid(String rfidCardId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('rfidCardId', isEqualTo: rfidCardId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final userDoc = querySnapshot.docs.first;
      return UserModel.fromJson({'id': userDoc.id, ...userDoc.data()});
    } catch (e) {
      throw Exception('Get user by RFID error: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/user_model.dart';

/// Service untuk CRUD operations user management
class UserManagementService {
  final FirebaseFirestore _firestore;

  UserManagementService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Update user profile
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Toggle user status (aktif/tidak aktif)
  Future<void> toggleUserStatus(String userId, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'statusAktif': !currentStatus,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to toggle user status: $e');
    }
  }

  /// Delete user (soft delete dengan flag isDeleted)
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isDeleted': true,
        'deletedAt': DateTime.now().millisecondsSinceEpoch,
        'statusAktif': false,
      });
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Assign RFID to user
  Future<void> assignRfidToUser(String userId, String rfidCardId) async {
    try {
      // Check if RFID already exists
      final existingRfid = await _firestore
          .collection('users')
          .where('rfidCardId', isEqualTo: rfidCardId)
          .get();

      if (existingRfid.docs.isNotEmpty) {
        final existingUser = existingRfid.docs.first;
        if (existingUser.id != userId) {
          throw Exception('RFID card already assigned to another user');
        }
      }

      await _firestore.collection('users').doc(userId).update({
        'rfidCardId': rfidCardId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to assign RFID: $e');
    }
  }

  /// Remove RFID from user
  Future<void> removeRfidFromUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'rfidCardId': FieldValue.delete(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to remove RFID: $e');
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Firebase Auth operations untuk login dan register
class FirebaseAuthOperations {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthOperations({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  /// Login dengan email dan password
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Login failed');
      }

      // Get user data dari Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromJson({
        'id': credential.user!.uid,
        ...userDoc.data()!,
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Register user baru
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Registration failed');
      }

      final user = UserModel(
        id: credential.user!.uid,
        nama: nama,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simpan user data ke Firestore
      await _firestore.collection('users').doc(user.id).set(user.toJson());

      // Send email verification
      await credential.user!.sendEmailVerification();

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromJson({'id': firebaseUser.uid, ...userDoc.data()!});
    } catch (e) {
      throw Exception('Get current user error: $e');
    }
  }
}

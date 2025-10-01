import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/error/auth_error_mapper.dart';

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
        throw Exception(AuthErrorMapper.mapFirebaseAuthError('null-user'));
      }

      // Get user data dari Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception(
          AuthErrorMapper.mapFirebaseAuthError('user-data-not-found'),
        );
      }

      return UserModel.fromJson({
        'id': credential.user!.uid,
        ...userDoc.data()!,
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Map Firebase error code ke pesan Indonesia
      final errorMessage = AuthErrorMapper.mapFirebaseAuthError(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      // Handle generic errors
      final errorMessage = AuthErrorMapper.getErrorMessage(e);
      throw Exception(errorMessage);
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
      // Validasi input sebelum proses registrasi
      final emailError = AuthErrorMapper.validateEmailFormat(email);
      if (emailError != null) {
        throw Exception(emailError);
      }

      final passwordError = AuthErrorMapper.validatePasswordFormat(password);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

      final namaError = AuthErrorMapper.validateNamaLengkap(nama);
      if (namaError != null) {
        throw Exception(namaError);
      }

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception(AuthErrorMapper.mapFirebaseAuthError('null-user'));
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
      // Map Firebase error code ke pesan Indonesia
      final errorMessage = AuthErrorMapper.mapFirebaseAuthError(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      // Handle generic errors
      final errorMessage = AuthErrorMapper.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      // Handle logout errors dengan pesan Indonesia
      final errorMessage = AuthErrorMapper.getErrorMessage(e);
      throw Exception(errorMessage);
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

      if (!userDoc.exists) {
        // User ada di Firebase Auth tapi tidak ada di Firestore
        throw Exception(
          AuthErrorMapper.mapFirebaseAuthError('user-data-not-found'),
        );
      }

      return UserModel.fromJson({'id': firebaseUser.uid, ...userDoc.data()!});
    } catch (e) {
      // Handle errors dengan pesan Indonesia
      final errorMessage = AuthErrorMapper.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/auth_error_mapper.dart';

/// Auth utility operations (email verification, password reset)
class AuthUtilityOperations {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthUtilityOperations({required firebase_auth.FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      // Validasi format email terlebih dahulu
      final emailError = AuthErrorMapper.validateEmailFormat(email);
      if (emailError != null) {
        throw Exception(emailError);
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email);
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

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception(AuthErrorMapper.mapFirebaseAuthError('null-user'));
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
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

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception(AuthErrorMapper.mapFirebaseAuthError('null-user'));
      }

      await user.reload();
      return user.emailVerified;
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
}

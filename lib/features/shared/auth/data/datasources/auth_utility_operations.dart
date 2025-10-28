import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sisantri/core/error/auth_error_mapper.dart';

class AuthUtilityOperations {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthUtilityOperations({required firebase_auth.FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  Future<void> resetPassword(String email) async {
    try {
      final emailError = AuthErrorMapper.validateEmailFormat(email);
      if (emailError != null) {
        throw Exception(emailError);
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final errorMessage = AuthErrorMapper.mapFirebaseAuthError(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = AuthErrorMapper.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

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
      final errorMessage = AuthErrorMapper.mapFirebaseAuthError(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = AuthErrorMapper.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception(AuthErrorMapper.mapFirebaseAuthError('null-user'));
      }

      await user.reload();
      return user.emailVerified;
    } on firebase_auth.FirebaseAuthException catch (e) {
      final errorMessage = AuthErrorMapper.mapFirebaseAuthError(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = AuthErrorMapper.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }
}

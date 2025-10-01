import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Auth utility operations (email verification, password reset)
class AuthUtilityOperations {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthUtilityOperations({required firebase_auth.FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Password reset error: ${e.message}');
    } catch (e) {
      throw Exception('Password reset error: $e');
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Send email verification error: $e');
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      throw Exception('Check email verification error: $e');
    }
  }
}

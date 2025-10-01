import '../models/user_model.dart';

/// Abstract DataSource untuk Auth remote operations
abstract class AuthRemoteDataSource {
  /// Login dengan email dan password
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register user baru
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String role,
  });

  /// Login dengan Google
  Future<UserModel> loginWithGoogle();

  /// Logout user
  Future<void> logout();

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Update user profile
  Future<UserModel> updateUserProfile(UserModel user);

  /// Reset password
  Future<void> resetPassword(String email);

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Check if email is verified
  Future<bool> isEmailVerified();

  /// Update RFID Card ID
  Future<UserModel> updateRfidCardId({
    required String userId,
    required String rfidCardId,
  });

  /// Get user by RFID
  Future<UserModel?> getUserByRfid(String rfidCardId);
}

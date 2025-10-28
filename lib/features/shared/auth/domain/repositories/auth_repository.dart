import '../entities/user.dart';
import 'package:sisantri/core/utils/result.dart';

/// Abstract Repository untuk Auth operations
/// Repository pattern memisahkan business logic dari implementation detail
abstract class AuthRepository {
  /// Login dengan email dan password
  Future<Result<User>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register user baru
  Future<Result<User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String role,
  });

  /// Login dengan Google
  Future<Result<User>> loginWithGoogle();

  /// Logout user
  Future<Result<void>> logout();

  /// Get current user
  Future<Result<User?>> getCurrentUser();

  /// Update user profile
  Future<Result<User>> updateUserProfile(User user);

  /// Reset password
  Future<Result<void>> resetPassword(String email);

  /// Send email verification
  Future<Result<void>> sendEmailVerification();

  /// Check if email is verified
  Future<Result<bool>> isEmailVerified();

  /// Update RFID Card ID
  Future<Result<User>> updateRfidCardId({
    required String userId,
    required String rfidCardId,
  });

  /// Get user by RFID
  Future<Result<User?>> getUserByRfid(String rfidCardId);
}

import '../models/user_model.dart';

/// Abstract DataSource untuk Auth remote operations
abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String role,
  });

  Future<UserModel> loginWithGoogle();

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateUserProfile(UserModel user);

  Future<void> resetPassword(String email);

  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();

  Future<UserModel> updateRfidCardId({
    required String userId,
    required String rfidCardId,
  });

  Future<UserModel?> getUserByRfid(String rfidCardId);
}

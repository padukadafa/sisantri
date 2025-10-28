import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source_interface.dart';
import '../models/user_model.dart';
import 'package:sisantri/core/utils/result.dart';
import 'package:sisantri/core/error/failures.dart';

/// Implementation Auth Repository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<User>> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(userModel);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      final userModel = await remoteDataSource.registerWithEmailAndPassword(
        email: email,
        password: password,
        nama: nama,
        role: role,
      );
      return Success(userModel);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> loginWithGoogle() async {
    try {
      final userModel = await remoteDataSource.loginWithGoogle();
      return Success(userModel);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await remoteDataSource.logout();
      return Success(null);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Success(userModel);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> updateUserProfile(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final updatedUserModel = await remoteDataSource.updateUserProfile(
        userModel,
      );
      return Success(updatedUserModel);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return Success(null);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return Success(null);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> isEmailVerified() async {
    try {
      final isVerified = await remoteDataSource.isEmailVerified();
      return Success(isVerified);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> updateRfidCardId({
    required String userId,
    required String rfidCardId,
  }) async {
    try {
      final userModel = await remoteDataSource.updateRfidCardId(
        userId: userId,
        rfidCardId: rfidCardId,
      );
      return Success(userModel);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User?>> getUserByRfid(String rfidCardId) async {
    try {
      final userModel = await remoteDataSource.getUserByRfid(rfidCardId);
      return Success(userModel);
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }
}

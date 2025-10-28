import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:sisantri/core/utils/result.dart';

/// Use case untuk mendapatkan current user
class GetCurrentUser {
  final AuthRepository repository;

  const GetCurrentUser(this.repository);

  Future<Result<User?>> call() async {
    return await repository.getCurrentUser();
  }
}

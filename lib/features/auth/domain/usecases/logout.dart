import '../repositories/auth_repository.dart';
import '../../../../core/utils/result.dart';

/// Use case untuk logout
class Logout {
  final AuthRepository repository;

  const Logout(this.repository);

  Future<Result<void>> call() async {
    return await repository.logout();
  }
}

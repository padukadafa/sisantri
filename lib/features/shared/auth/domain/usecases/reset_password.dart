import '../repositories/auth_repository.dart';
import 'package:sisantri/core/utils/result.dart';
import 'package:sisantri/core/error/failures.dart';

/// Use case untuk reset password
class ResetPassword {
  final AuthRepository repository;

  const ResetPassword(this.repository);

  Future<Result<void>> call({required String email}) async {
    // Validasi input
    if (email.isEmpty) {
      return Error(ValidationFailure(message: 'Email tidak boleh kosong'));
    }

    if (!email.contains('@')) {
      return Error(ValidationFailure(message: 'Format email tidak valid'));
    }

    return await repository.resetPassword(email);
  }
}

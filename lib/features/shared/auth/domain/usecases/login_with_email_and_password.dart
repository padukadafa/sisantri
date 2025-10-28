import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:sisantri/core/utils/result.dart';
import 'package:sisantri/core/error/failures.dart';

/// Use case untuk login dengan email dan password
class LoginWithEmailAndPassword {
  final AuthRepository repository;

  const LoginWithEmailAndPassword(this.repository);

  Future<Result<User>> call({
    required String email,
    required String password,
  }) async {
    // Validasi input
    if (email.isEmpty) {
      return Error(ValidationFailure(message: 'Email tidak boleh kosong'));
    }

    if (password.isEmpty) {
      return Error(ValidationFailure(message: 'Password tidak boleh kosong'));
    }

    if (!email.contains('@')) {
      return Error(ValidationFailure(message: 'Format email tidak valid'));
    }

    if (password.length < 6) {
      return Error(ValidationFailure(message: 'Password minimal 6 karakter'));
    }

    return await repository.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

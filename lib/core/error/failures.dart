/// Base class untuk semua failures/errors dalam aplikasi
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure: $message';
}

/// Server failure - untuk error dari backend/API
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Cache failure - untuk error cache/local storage
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Network failure - untuk error jaringan
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Auth failure - untuk error authentication
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Validation failure - untuk error validasi input
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Permission failure - untuk error permission
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

/// Unknown failure - untuk error yang tidak diketahui
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}

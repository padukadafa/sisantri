/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

/// Exception thrown when there's a server error
class ServerException extends AppException {
  ServerException({required super.message, super.code});
}

/// Exception thrown when there's a network error
class NetworkException extends AppException {
  NetworkException({required super.message, super.code});
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  CacheException({required super.message, super.code});
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  AuthException({required super.message, super.code});
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  ValidationException({required super.message, super.code});
}

/// Exception thrown when permission is denied
class PermissionException extends AppException {
  PermissionException({required super.message, super.code});
}

/// Exception thrown when resource is not found
class NotFoundException extends AppException {
  NotFoundException({required super.message, super.code});
}

/// Exception thrown when there's a timeout
class TimeoutException extends AppException {
  TimeoutException({required super.message, super.code});
}

/// Exception thrown when Firebase operations fail
class FirebaseException extends AppException {
  FirebaseException({required super.message, super.code});
}

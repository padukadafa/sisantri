import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exceptions.dart' as app_exceptions;
import 'failures.dart';

/// Helper class untuk mengkonversi exceptions menjadi failures
class ErrorHandler {
  /// Convert Firebase Auth exceptions to AuthFailure
  static AuthFailure handleFirebaseAuthException(
    firebase_auth.FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure(
          message: 'Email tidak terdaftar',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Password salah',
          code: 'wrong-password',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'Email sudah digunakan',
          code: 'email-already-in-use',
        );
      case 'invalid-email':
        return const AuthFailure(
          message: 'Format email tidak valid',
          code: 'invalid-email',
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'Password terlalu lemah',
          code: 'weak-password',
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'Akun dinonaktifkan',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Terlalu banyak percobaan, coba lagi nanti',
          code: 'too-many-requests',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          message: 'Operasi tidak diizinkan',
          code: 'operation-not-allowed',
        );
      default:
        return AuthFailure(
          message: e.message ?? 'Terjadi kesalahan autentikasi',
          code: e.code,
        );
    }
  }

  /// Convert Firestore exceptions to ServerFailure
  static ServerFailure handleFirestoreException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const ServerFailure(
          message: 'Akses ditolak',
          code: 'permission-denied',
        );
      case 'not-found':
        return const ServerFailure(
          message: 'Data tidak ditemukan',
          code: 'not-found',
        );
      case 'already-exists':
        return const ServerFailure(
          message: 'Data sudah ada',
          code: 'already-exists',
        );
      case 'resource-exhausted':
        return const ServerFailure(
          message: 'Kuota terlampaui',
          code: 'resource-exhausted',
        );
      case 'failed-precondition':
        return const ServerFailure(
          message: 'Kondisi tidak terpenuhi',
          code: 'failed-precondition',
        );
      case 'aborted':
        return const ServerFailure(
          message: 'Operasi dibatalkan',
          code: 'aborted',
        );
      case 'out-of-range':
        return const ServerFailure(
          message: 'Data di luar jangkauan',
          code: 'out-of-range',
        );
      case 'unimplemented':
        return const ServerFailure(
          message: 'Fitur belum diimplementasikan',
          code: 'unimplemented',
        );
      case 'internal':
        return const ServerFailure(
          message: 'Kesalahan server internal',
          code: 'internal',
        );
      case 'unavailable':
        return const ServerFailure(
          message: 'Layanan tidak tersedia',
          code: 'unavailable',
        );
      case 'data-loss':
        return const ServerFailure(
          message: 'Kehilangan data',
          code: 'data-loss',
        );
      case 'unauthenticated':
        return const ServerFailure(
          message: 'Tidak terautentikasi',
          code: 'unauthenticated',
        );
      default:
        return ServerFailure(
          message: e.message ?? 'Terjadi kesalahan server',
          code: e.code,
        );
    }
  }

  /// Convert general exceptions to appropriate failures
  static Failure handleException(Exception e) {
    if (e is firebase_auth.FirebaseAuthException) {
      return handleFirebaseAuthException(e);
    } else if (e is FirebaseException) {
      return handleFirestoreException(e);
    } else if (e is app_exceptions.ServerException) {
      return ServerFailure(message: e.message, code: e.code);
    } else if (e is app_exceptions.NetworkException) {
      return NetworkFailure(message: e.message, code: e.code);
    } else if (e is app_exceptions.CacheException) {
      return CacheFailure(message: e.message, code: e.code);
    } else if (e is app_exceptions.AuthException) {
      return AuthFailure(message: e.message, code: e.code);
    } else if (e is app_exceptions.ValidationException) {
      return ValidationFailure(message: e.message, code: e.code);
    } else if (e is app_exceptions.PermissionException) {
      return PermissionFailure(message: e.message, code: e.code);
    } else {
      return UnknownFailure(message: e.toString());
    }
  }

  /// Get user-friendly error message
  static String getErrorMessage(Failure failure) {
    if (failure is AuthFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Periksa koneksi internet Anda';
    } else if (failure is CacheFailure) {
      return 'Gagal menyimpan data lokal';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is PermissionFailure) {
      return 'Anda tidak memiliki izin untuk operasi ini';
    } else {
      return 'Terjadi kesalahan yang tidak diketahui';
    }
  }
}

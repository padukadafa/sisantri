/// Utility class untuk mapping Firebase Auth error codes ke pesan error bahasa Indonesia
class AuthErrorMapper {
  /// Map Firebase Auth error code ke pesan error bahasa Indonesia
  static String mapFirebaseAuthError(String errorCode) {
    switch (errorCode) {
      // Email/Password related errors
      case 'wrong-password':
        return 'Password yang Anda masukkan salah. Silakan coba lagi.';

      case 'user-not-found':
        return 'Akun dengan email tersebut tidak ditemukan. Pastikan email Anda sudah terdaftar.';

      case 'invalid-email':
        return 'Format email tidak valid. Silakan periksa kembali email Anda.';

      case 'user-disabled':
        return 'Akun Anda telah dinonaktifkan. Hubungi administrator untuk informasi lebih lanjut.';

      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Silakan tunggu beberapa saat sebelum mencoba lagi.';

      case 'email-already-in-use':
        return 'Email ini sudah terdaftar dengan akun lain. Silakan gunakan email berbeda atau login.';

      case 'weak-password':
        return 'Password terlalu lemah. Gunakan kombinasi huruf, angka, dan simbol minimal 6 karakter.';

      case 'operation-not-allowed':
        return 'Metode login ini tidak diizinkan. Hubungi administrator sistem.';

      case 'invalid-credential':
        return 'Email atau password tidak valid. Silakan periksa kembali data login Anda.';

      case 'account-exists-with-different-credential':
        return 'Akun dengan email ini sudah ada dengan metode login berbeda.';

      case 'invalid-verification-code':
        return 'Kode verifikasi tidak valid atau sudah kedaluwarsa.';

      case 'invalid-verification-id':
        return 'ID verifikasi tidak valid. Silakan minta kode verifikasi baru.';

      case 'expired-action-code':
        return 'Kode aksi sudah kedaluwarsa. Silakan minta kode baru.';

      case 'invalid-action-code':
        return 'Kode aksi tidak valid atau sudah digunakan.';

      case 'missing-email':
        return 'Email harus diisi untuk melanjutkan proses ini.';

      case 'missing-password':
        return 'Password tidak boleh kosong.';

      case 'internal-error':
        return 'Terjadi kesalahan sistem. Silakan coba lagi dalam beberapa saat.';

      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.';

      case 'timeout':
        return 'Koneksi timeout. Silakan coba lagi.';

      case 'unavailable':
        return 'Layanan sedang tidak tersedia. Silakan coba lagi nanti.';

      case 'unauthenticated':
        return 'Sesi login Anda telah berakhir. Silakan login ulang.';

      case 'permission-denied':
        return 'Anda tidak memiliki izin untuk melakukan tindakan ini.';

      case 'requires-recent-login':
        return 'Untuk keamanan, silakan login ulang untuk melakukan tindakan ini.';

      case 'provider-already-linked':
        return 'Metode login ini sudah terhubung dengan akun Anda.';

      case 'no-such-provider':
        return 'Metode login ini belum terhubung dengan akun Anda.';

      case 'invalid-user-token':
        return 'Token akses tidak valid. Silakan login ulang.';

      case 'user-token-expired':
        return 'Sesi login telah berakhir. Silakan login ulang.';

      case 'null-user':
        return 'Tidak ada pengguna yang sedang login.';

      case 'keychain-error':
        return 'Terjadi kesalahan sistem keamanan. Silakan coba lagi.';

      // Google Sign-In specific errors
      case 'sign_in_canceled':
        return 'Login dengan Google dibatalkan.';

      case 'sign_in_failed':
        return 'Login dengan Google gagal. Silakan coba lagi.';

      case 'network_error':
        return 'Koneksi internet bermasalah. Periksa koneksi Anda.';

      // Custom application errors
      case 'user-data-not-found':
        return 'Data pengguna tidak ditemukan. Silakan hubungi administrator.';

      case 'invalid-role':
        return 'Role pengguna tidak valid. Hubungi administrator untuk verifikasi akun.';

      case 'account-not-verified':
        return 'Akun Anda belum diverifikasi. Silakan cek email untuk link verifikasi.';

      case 'registration-disabled':
        return 'Pendaftaran akun baru sedang dinonaktifkan. Hubungi administrator.';

      case 'maintenance-mode':
        return 'Sistem sedang dalam pemeliharaan. Silakan coba lagi nanti.';

      // Default error
      default:
        return 'Terjadi kesalahan yang tidak diketahui. Silakan coba lagi atau hubungi administrator.';
    }
  }

  /// Ekstrak error code dari Firebase Auth Exception message
  static String extractErrorCode(String errorMessage) {
    // Firebase Auth errors biasanya dalam format:
    // "[firebase_auth/error-code] Error message"
    final regex = RegExp(r'\[firebase_auth/([^\]]+)\]');
    final match = regex.firstMatch(errorMessage);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }

    // Jika tidak ada pattern yang cocok, coba ekstrak dari format lain
    if (errorMessage.toLowerCase().contains('wrong-password')) {
      return 'wrong-password';
    } else if (errorMessage.toLowerCase().contains('user-not-found')) {
      return 'user-not-found';
    } else if (errorMessage.toLowerCase().contains('invalid-email')) {
      return 'invalid-email';
    } else if (errorMessage.toLowerCase().contains('too-many-requests')) {
      return 'too-many-requests';
    } else if (errorMessage.toLowerCase().contains('network')) {
      return 'network-request-failed';
    } else if (errorMessage.toLowerCase().contains('timeout')) {
      return 'timeout';
    }

    return 'unknown-error';
  }

  /// Generate user-friendly error message dari exception
  static String getErrorMessage(dynamic error) {
    if (error == null) return mapFirebaseAuthError('unknown-error');

    String errorMessage = error.toString();

    // Extract error code dan convert ke pesan Indonesia
    String errorCode = extractErrorCode(errorMessage);
    return mapFirebaseAuthError(errorCode);
  }

  /// Validasi error khusus untuk form validation
  static String? validateEmailFormat(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid (contoh: nama@domain.com)';
    }

    return null;
  }

  /// Validasi password format
  static String? validatePasswordFormat(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }

    if (password.length > 128) {
      return 'Password maksimal 128 karakter';
    }

    return null;
  }

  /// Validasi nama lengkap
  static String? validateNamaLengkap(String? nama) {
    if (nama == null || nama.isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }

    if (nama.length < 2) {
      return 'Nama minimal 2 karakter';
    }

    if (nama.length > 100) {
      return 'Nama maksimal 100 karakter';
    }

    // Check if contains only letters, spaces, apostrophes, and hyphens
    final nameRegex = RegExp(r"^[a-zA-Z\s\'\-\.]+$");
    if (!nameRegex.hasMatch(nama)) {
      return 'Nama hanya boleh mengandung huruf, spasi, titik, tanda petik, dan tanda hubung';
    }

    return null;
  }

  /// Get error severity level untuk UI styling
  static ErrorSeverity getErrorSeverity(String errorCode) {
    switch (errorCode) {
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
      case 'invalid-credential':
        return ErrorSeverity.warning;

      case 'user-disabled':
      case 'too-many-requests':
      case 'operation-not-allowed':
        return ErrorSeverity.error;

      case 'network-request-failed':
      case 'timeout':
      case 'unavailable':
        return ErrorSeverity.info;

      case 'internal-error':
      case 'unauthenticated':
      case 'permission-denied':
        return ErrorSeverity.critical;

      default:
        return ErrorSeverity.warning;
    }
  }
}

/// Enum untuk tingkat keparahan error
enum ErrorSeverity {
  info, // Informational - biru
  warning, // Warning - orange
  error, // Error - merah
  critical, // Critical - merah gelap
}

/// Konstanta untuk aplikasi SiSantri
class AppConstants {
  // App Info
  static const String appName = 'SiSantri';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Aplikasi gamifikasi untuk Pondok Pesantren Mahasiswa Al-Awwabin Sukarame – Bandar Lampung';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String jadwalPengajianCollection = 'jadwal_pengajian';
  static const String jadwalKegiatanCollection = 'jadwal_kegiatan';
  static const String presensiCollection = 'presensi';
  static const String pengumumanCollection = 'pengumuman';
  static const String leaderboardCollection = 'leaderboard';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleSantri = 'santri';

  // Poin System
  static const int poinHadir = 10;
  static const int poinIzin = 5;
  static const int poinSakit = 5;

  // Shared Preferences Keys
  static const String keyFirstTime = 'first_time';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';

  // Firebase Cloud Messaging
  static const String fcmTopicAll = 'all_users';
  static const String fcmTopicSantri = 'santri';
  static const String fcmTopicAdmin = 'admin';

  // Notification Channels
  static const String notificationChannelDefault = 'sisantri_channel';
  static const String notificationChannelKegiatan = 'kegiatan_reminder';

  // Error Messages
  static const String errorNetworkConnection = 'Tidak ada koneksi internet';
  static const String errorSomethingWrong =
      'Terjadi kesalahan, silakan coba lagi';
  static const String errorUserNotFound = 'User tidak ditemukan';
  static const String errorPermissionDenied = 'Akses ditolak';

  // Success Messages
  static const String successLogin = 'Login berhasil';
  static const String successRegister = 'Registrasi berhasil';
  static const String successPresensi = 'Presensi berhasil disimpan';
  static const String successUpdateProfile = 'Profil berhasil diupdate';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNamaLength = 50;
  static const int maxKeteranganLength = 200;
}

/// Enum untuk status loading
enum LoadingStatus { initial, loading, success, error }

/// Enum untuk environment
enum Environment { development, staging, production }

/// Current environment
const Environment currentEnvironment = Environment.development;

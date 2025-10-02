# Kebutuhan Sistem SiSantri

## 3.1 Kebutuhan Fungsional

### 3.1.1 Modul Autentikasi

- **RF-01**: Sistem dapat melakukan login dengan Google Authentication
- **RF-02**: Sistem dapat menampilkan pesan error spesifik ketika login gagal
- **RF-03**: Sistem dapat melakukan logout pengguna
- **RF-04**: Sistem dapat mengelola profil pengguna (nama, foto, email)
- **RF-05**: Sistem dapat mengatur RFID untuk presensi

### 3.1.2 Modul Dashboard

- **RF-06**: Sistem dapat menampilkan welcome card dengan informasi pengguna
- **RF-07**: Sistem dapat menampilkan statistik presensi harian
- **RF-08**: Sistem dapat menampilkan notifikasi real-time
- **RF-09**: Sistem dapat menampilkan kegiatan mendatang
- **RF-10**: Sistem dapat menampilkan pengumuman terbaru
- **RF-11**: Sistem dapat menampilkan statistik kehadiran mingguan dan bulanan

### 3.1.3 Modul Presensi

- **RF-11**: Sistem dapat mencatat presensi menggunakan RFID/NFC
- **RF-12**: Sistem dapat melakukan presensi manual oleh admin
- **RF-13**: Sistem dapat menampilkan riwayat presensi
- **RF-14**: Sistem dapat mengekspor laporan presensi ke Excel
- **RF-15**: Sistem dapat menghitung statistik kehadiran

### 3.1.4 Modul Pengumuman

- **RF-16**: Admin dapat membuat pengumuman baru
- **RF-17**: Admin dapat mengedit pengumuman
- **RF-18**: Admin dapat menghapus pengumuman
- **RF-19**: Sistem dapat menandai pengumuman penting
- **RF-20**: Pengguna dapat melihat daftar pengumuman

### 3.1.5 Modul Jadwal Kegiatan

- **RF-21**: Admin dapat membuat jadwal kegiatan
- **RF-22**: Admin dapat mengedit jadwal kegiatan
- **RF-23**: Admin dapat menghapus jadwal kegiatan
- **RF-24**: Sistem dapat menampilkan kalender kegiatan
- **RF-25**: Sistem dapat mengirim notifikasi kegiatan

### 3.1.6 Modul Manajemen Pengguna

- **RF-26**: Admin dapat melihat daftar pengguna
- **RF-27**: Admin dapat menambah pengguna baru
- **RF-28**: Admin dapat mengedit informasi pengguna
- **RF-29**: Admin dapat menghapus pengguna
- **RF-30**: Admin dapat mengatur role pengguna (santri/admin/dewan guru)

### 3.1.7 Modul Laporan

- **RF-31**: Admin dapat melihat laporan presensi
- **RF-32**: Admin dapat memfilter laporan berdasarkan tanggal
- **RF-33**: Admin dapat memfilter laporan berdasarkan pengguna
- **RF-34**: Admin dapat mengekspor laporan ke Excel
- **RF-35**: Sistem dapat menampilkan grafik statistik

### 3.1.8 Modul Gamifikasi

- **RF-36**: Sistem dapat menghitung poin berdasarkan aktivitas pengguna
- **RF-37**: Sistem dapat memberikan bonus poin untuk pencapaian khusus
- **RF-38**: Sistem dapat mengelola sistem level pengguna (1-5)
- **RF-39**: Sistem dapat mengelola achievement/badge system
- **RF-40**: Sistem dapat menampilkan leaderboard harian/mingguan/bulanan
- **RF-41**: Sistem dapat memberikan notifikasi achievement baru
- **RF-42**: Sistem dapat menampilkan progress bar untuk achievement
- **RF-43**: Sistem dapat memberikan penalty poin untuk keterlambatan/alpha
- **RF-44**: Sistem dapat menghitung streak kehadiran
- **RF-45**: Sistem dapat memberikan reward untuk partisipasi kegiatan

## 3.2 Kebutuhan Non-Fungsional

### 3.2.1 Performance

- **RNF-01**: Aplikasi dapat memuat dalam waktu maksimal 3 detik
- **RNF-02**: Sistem dapat menangani hingga 500 pengguna bersamaan
- **RNF-03**: Response time untuk operasi CRUD maksimal 2 detik

### 3.2.2 Security

- **RNF-04**: Sistem menggunakan Firebase Authentication untuk keamanan
- **RNF-05**: Data pengguna terenkripsi dalam database
- **RNF-06**: Akses role-based untuk fitur admin

### 3.2.3 Usability

- **RNF-07**: Interface menggunakan Material Design
- **RNF-08**: Aplikasi responsif di berbagai ukuran layar
- **RNF-09**: Navigasi intuitif dengan bottom navigation

### 3.2.4 Reliability

- **RNF-10**: Sistem tersedia 99.9% uptime
- **RNF-11**: Data backup otomatis ke Firebase
- **RNF-12**: Error handling yang comprehensive

### 3.2.5 Compatibility

- **RNF-13**: Support Android 6.0+ dan iOS 12+
- **RNF-14**: Kompatibel dengan perangkat NFC/RFID
- **RNF-15**: Support offline mode untuk beberapa fitur

### 3.2.6 Error Handling

#### 3.2.6.1 Login Error Messages

| Error Code | Error Type                    | User Message (Indonesian)                                       | Technical Description                    |
| ---------- | ----------------------------- | --------------------------------------------------------------- | ---------------------------------------- |
| AUTH_001   | NETWORK_ERROR                 | "Tidak ada koneksi internet. Periksa koneksi Anda."             | No internet connection available         |
| AUTH_002   | SIGN_IN_CANCELLED             | "Login dibatalkan oleh pengguna."                               | User cancelled the sign-in flow          |
| AUTH_003   | SIGN_IN_FAILED                | "Gagal login dengan Google. Silakan coba lagi."                 | General Google sign-in failure           |
| AUTH_004   | ACCOUNT_EXISTS_DIFFERENT_CRED | "Akun sudah terdaftar dengan metode login lain."                | Account exists with different credential |
| AUTH_005   | INVALID_CREDENTIAL            | "Kredensial tidak valid. Silakan coba lagi."                    | Invalid or expired credential            |
| AUTH_006   | USER_DISABLED                 | "Akun Anda telah dinonaktifkan oleh administrator."             | User account has been disabled           |
| AUTH_007   | OPERATION_NOT_ALLOWED         | "Metode login tidak diizinkan."                                 | Google sign-in not configured            |
| AUTH_008   | USER_NOT_FOUND                | "Pengguna tidak terdaftar dalam sistem. Hubungi administrator." | User not found in database               |
| AUTH_009   | ACCOUNT_INACTIVE              | "Akun Anda tidak aktif. Hubungi administrator."                 | User account is inactive                 |
| AUTH_010   | INVALID_ROLE                  | "Role pengguna tidak valid."                                    | User role is not recognized              |
| AUTH_011   | PENDING_APPROVAL              | "Akun menunggu persetujuan administrator."                      | Account pending admin approval           |
| AUTH_012   | ACCESS_DENIED                 | "Akses ditolak. Anda tidak memiliki izin."                      | General access denied                    |

#### 3.2.6.2 Error Handling Strategy

- **User-Friendly Messages**: Semua error ditampilkan dalam bahasa Indonesia yang mudah dipahami
- **Error Logging**: Semua error dicatat untuk debugging dan monitoring
- **Retry Mechanism**: Beberapa error memiliki opsi retry otomatis
- **Graceful Degradation**: Aplikasi tetap berfungsi meskipun ada error non-critical
- **Error Recovery**: Panduan recovery untuk user ketika mengalami error
- **Error Analytics**: Tracking error patterns untuk improvement

#### 3.2.6.3 Error UI Components

- **Error Dialog**: Modal dialog dengan pesan error dan action button
- **Error Banner**: Persistent banner untuk non-critical errors
- **Retry Button**: Allow users to retry failed operations
- **Help Link**: Link ke troubleshooting guide untuk complex errors
- **Error Animation**: Visual feedback untuk error states

#### 3.2.6.4 Implementasi Error Handler (Contoh)

```dart
class LoginErrorHandler {
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa koneksi Anda.';
      case 'sign_in_canceled':
        return 'Login dibatalkan oleh pengguna.';
      case 'sign_in_failed':
        return 'Gagal login dengan Google. Silakan coba lagi.';
      case 'account-exists-with-different-credential':
        return 'Akun sudah terdaftar dengan metode login lain.';
      case 'invalid-credential':
        return 'Kredensial tidak valid. Silakan coba lagi.';
      case 'user-disabled':
        return 'Akun Anda telah dinonaktifkan oleh administrator.';
      case 'operation-not-allowed':
        return 'Metode login tidak diizinkan.';
      case 'user-not-found':
        return 'Pengguna tidak terdaftar dalam sistem. Hubungi administrator.';
      case 'account-inactive':
        return 'Akun Anda tidak aktif. Hubungi administrator.';
      case 'invalid-role':
        return 'Role pengguna tidak valid.';
      case 'pending-approval':
        return 'Akun menunggu persetujuan administrator.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  static void showErrorDialog(BuildContext context, String errorCode, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(getErrorMessage(errorCode)),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Coba Lagi'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
```

## 3.3 Data Flow Diagram (DFD)

### 3.3.1 DFD Context (Level 0)

```
                          EXTERNAL ENTITIES
                                  │
        ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
        │   SANTRI    │    │    ADMIN    │    │ DEWAN GURU  │
        └─────────────┘    └─────────────┘    └─────────────┘
              │                    │                    │
              │ ┌─────────────────────────────────────────────────────────┐ │
              │ │                                                         │ │
              ▼ │ ▼                SISTEM SISANTRI                      ▼ │ ▼
    ┌──────────────────────────────────────────────────────────────────────────┐
    │                                                                          │
    │  • Login/Logout                    • Kelola Pengumuman                   │
    │  • Presensi RFID/Manual           • Kelola Jadwal Kegiatan               │
    │  • Lihat Jadwal Kegiatan          • Manajemen User                       │
    │  • Lihat Pengumuman               • Generate Laporan                     │
    │  • View Dashboard                 • Export Data Excel/PDF                │
    │  • Achievement & Points           • Dashboard Analytics                  │
    │  • Profile Management             • RFID Card Management                 │
    │  • Notification Preferences       • System Configuration                 │
    │                                                                          │
    └──────────────────────────────────────────────────────────────────────────┘
              │ ▲                                                        │ ▲
              │ │                                                        │ │
              ▼ │                                                        ▼ │
    ┌──────────────────────────────────────────────────────────────────────────┐
    │                         EXTERNAL SYSTEMS                                 │
    │                                                                          │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
    │  │   GOOGLE    │  │  FIREBASE   │  │    RFID     │  │    FCM      │     │
    │  │    AUTH     │  │  FIRESTORE  │  │   READER    │  │ NOTIFICATION│     │
    │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘     │
    │                                                                          │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
    │  │  FIREBASE   │  │    EMAIL    │  │ FILE SYSTEM │  │   CALENDAR  │     │
    │  │   STORAGE   │  │   SERVICE   │  │  (EXPORT)   │  │ INTEGRATION │     │
    │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘     │
    └──────────────────────────────────────────────────────────────────────────┘

INPUT FLOWS (ke Sistem):
• login_credentials (dari Santri/Admin/Dewan Guru)
• rfid_scan_data (dari RFID Reader)
• pengumuman_data (dari Admin)
• jadwal_kegiatan_data (dari Admin)
• user_management_data (dari Admin/Dewan Guru)
• filter_laporan (dari Admin/Dewan Guru)
• presensi_manual (dari Admin)
• profile_updates (dari Santri/Admin/Dewan Guru)
• notification_preferences (dari Users)
• achievement_triggers (dari System Events)

OUTPUT FLOWS (dari Sistem):
• authentication_result (ke Users)
• presensi_status (ke Santri/Admin)
• notification_push (ke FCM Service)
• laporan_excel (ke File System)
• dashboard_data (ke Users)
• pengumuman_list (ke Users)
• jadwal_calendar (ke Users)
• user_statistics (ke Admin/Dewan Guru)
• achievement_notification (ke Users)
• leaderboard_updates (ke Users)
• email_notifications (ke Email Service)
• file_attachments (ke Firebase Storage)

EXTERNAL SYSTEM INTERACTIONS:
• Google Authentication Service - OAuth login/logout
• Firebase Firestore - Data persistence dan real-time sync
• Firebase Storage - File upload/download untuk attachments
• Firebase Cloud Messaging (FCM) - Push notifications
• RFID Reader Hardware - Card scanning untuk presensi
• Email Service - Welcome emails dan notifications
• File System - Export laporan ke local storage
• Calendar Integration - Sync jadwal dengan calendar apps
```

### 3.3.2 DFD Level 1

```
                    [SANTRI]                   [ADMIN]                [DEWAN GURU]
                        |                         |                        |
                        v                         v                        v
            ┌──────────────────────────────────────────────────────────────────┐
            │                    SISTEM SISANTRI                               │
            │                                                                  │
            │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
            │  │     1.0     │  │     2.0     │  │     3.0     │              │
            │  │ AUTENTIKASI │  │  PRESENSI   │  │ PENGUMUMAN  │              │
            │  │             │  │             │  │             │              │
            │  └─────────────┘  └─────────────┘  └─────────────┘              │
            │         │               │               │                       │
            │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
            │  │     4.0     │  │     5.0     │  │     6.0     │              │
            │  │   JADWAL    │  │  LAPORAN    │  │  DASHBOARD  │              │
            │  │             │  │             │  │             │              │
            │  └─────────────┘  └─────────────┘  └─────────────┘              │
            │         │               │               │                       │
            │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
            │  │     7.0     │  │     8.0     │  │     9.0     │              │
            │  │ GAMIFIKASI  │  │ MANAJEMEN   │  │ NOTIFIKASI  │              │
            │  │             │  │   USER      │  │             │              │
            │  └─────────────┘  └─────────────┘  └─────────────┘              │
            └──────────────────────────────────────────────────────────────────┘
                        |                         |                        |
                        v                         v                        v
            ┌──────────────────────────────────────────────────────────────────┐
            │                     DATA STORES                                  │
            │                                                                  │
            │  D1 Users    D2 Presensi    D3 Pengumuman    D4 Jadwal          │
            │  D5 Notifications    D6 Achievements    D7 UserAchievements      │
            │  D8 Leaderboards    D9 PointHistory                             │
            └──────────────────────────────────────────────────────────────────┘

1.0 AUTENTIKASI
- Input: data login Google, validasi token
- Output: token akses, profil user, error handling
- Data Store: D1 Users
- External: Google Auth Services

2.0 PRESENSI
- Input: RFID scan, presensi manual, GPS location
- Output: status presensi, notifikasi, update poin
- Data Store: D2 Presensi, D9 PointHistory
- External: RFID Reader, GPS Services

3.0 PENGUMUMAN
- Input: data pengumuman, attachment files
- Output: list pengumuman, notifikasi push
- Data Store: D3 Pengumuman, D5 Notifications
- External: Firebase Storage, FCM

4.0 JADWAL
- Input: data kegiatan, participant list
- Output: kalender, reminder, konfirmasi kehadiran
- Data Store: D4 Jadwal, D5 Notifications
- External: Calendar Integration

5.0 LAPORAN
- Input: filter periode, user selection, export format
- Output: Excel/PDF file, statistik visual, dashboard data
- Data Store: D1 Users, D2 Presensi, D4 Jadwal
- External: File System, Excel Services

6.0 DASHBOARD
- Input: request real-time data, user preferences
- Output: summary statistik, chart data, recent activities
- Data Store: D1-D9 All Stores
- External: Analytics Services

7.0 GAMIFIKASI
- Input: user activities, achievement triggers
- Output: poin calculation, level update, achievement unlock
- Data Store: D6 Achievements, D7 UserAchievements, D8 Leaderboards, D9 PointHistory
- External: Achievement Engine

8.0 MANAJEMEN USER
- Input: user data, role assignment, RFID mapping
- Output: user profile, access control, user statistics
- Data Store: D1 Users
- External: Role Management

9.0 NOTIFIKASI
- Input: system events, user preferences, notification templates
- Output: push notifications, in-app notifications, email notifications
- Data Store: D5 Notifications
- External: FCM, Email Services
```

### 3.3.3 DFD Level 2 - Proses Autentikasi (1.0)

```
                    [USER]
                      |
               login request
                      |
                      v
            ┌─────────────────┐
            │       1.1       │
            │ GOOGLE AUTH     │ ──→ Google Services
            │                 │
            └─────────────────┘
                      |
               auth response
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       1.2       │ ────────────→   │     D1      │
            │ VALIDASI USER   │                 │   Users     │
            │                 │ ←────────────   │             │
            └─────────────────┘   user data     └─────────────┘
                      |
               validation result
                      |
                      v
            ┌─────────────────┐
            │       1.3       │
            │ GENERATE TOKEN  │
            │                 │
            └─────────────────┘
                      |
               access token
                      |
                      v
            ┌─────────────────┐
            │       1.4       │
            │ ERROR HANDLING  │
            │                 │
            └─────────────────┘
                      |
            success/error message
                      |
                      v
                   [USER]

1.1 GOOGLE AUTH
- Input: login request
- Process: Google authentication flow
- Output: auth credentials/error
- PSPEC: P1.1

1.2 VALIDASI USER
- Input: auth response, user credentials
- Process: check user exists, validate role, check status
- Output: user data/validation error
- PSPEC: P1.2

1.3 GENERATE TOKEN
- Input: validated user data
- Process: create access token, set session
- Output: access token, user profile
- PSPEC: P1.3

1.4 ERROR HANDLING
- Input: authentication errors
- Process: map error codes to Indonesian messages
- Output: user-friendly error messages
- PSPEC: P1.4
```

### 3.3.4 DFD Level 2 - Proses Presensi (2.0)

```
                [SANTRI/ADMIN]
                      |
               RFID/Manual Input
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       2.1       │ ────────────→   │     D1      │
            │   SCAN RFID     │                 │   Users     │
            │                 │ ←────────────   │             │
            └─────────────────┘   user data     └─────────────┘
                      |
               validated scan
                      |
                      v
            ┌─────────────────┐      check      ┌─────────────┐
            │       2.2       │ ────────────→   │     D2      │
            │ VALIDASI        │                 │  Presensi   │
            │ PRESENSI        │ ←────────────   │             │
            └─────────────────┘   existing data └─────────────┘
                      |
               presensi record
                      |
                      v
            ┌─────────────────┐      save       ┌─────────────┐
            │       2.3       │ ────────────→   │     D2      │
            │ SIMPAN          │                 │  Presensi   │
            │ PRESENSI        │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               save confirmation
                      |
                      v
            ┌─────────────────┐      update     ┌─────────────┐
            │       2.4       │ ────────────→   │     D9      │
            │ UPDATE POIN     │                 │ PointHistory│
            │                 │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               points updated
                      |
                      v
            ┌─────────────────┐      create     ┌─────────────┐
            │       2.5       │ ────────────→   │     D5      │
            │ KIRIM           │                 │Notifications│
            │ NOTIFIKASI      │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
            notification sent
                      |
                      v
               [SANTRI/ADMIN]

2.1 SCAN RFID
- Input: RFID data, manual input
- Process: validasi kartu, cek jadwal, validate format
- Output: validated scan data
- PSPEC: P2.1

2.2 VALIDASI PRESENSI
- Input: user ID, timestamp, scan data
- Process: cek duplikasi, tentukan status berdasarkan waktu
- Output: presensi record dengan status
- PSPEC: P2.2

2.3 SIMPAN PRESENSI
- Input: validated presensi data
- Process: insert to database dengan metadata
- Output: save confirmation
- PSPEC: P2.3

2.4 UPDATE POIN
- Input: presensi success data
- Process: calculate points, update user score
- Output: points calculation result
- PSPEC: P2.4

2.5 KIRIM NOTIFIKASI
- Input: presensi berhasil, points earned
- Process: generate notification, send push notification
- Output: notification sent confirmation
- PSPEC: P2.5
```

### 3.3.5 DFD Level 2 - Proses Pengumuman (3.0)

```
                    [ADMIN]
                      |
            pengumuman data + files
                      |
                      v
            ┌─────────────────┐      validate
            │       3.1       │
            │ VALIDASI        │
            │ PENGUMUMAN      │
            └─────────────────┘
                      |
               validated data
                      |
                      v
            ┌─────────────────┐      upload     [Firebase Storage]
            │       3.2       │ ────────────→
            │ UPLOAD          │
            │ ATTACHMENT      │ ←────────────
            └─────────────────┘   file URLs
                      |
               complete data
                      |
                      v
            ┌─────────────────┐      save       ┌─────────────┐
            │       3.3       │ ────────────→   │     D3      │
            │ SIMPAN          │                 │ Pengumuman  │
            │ PENGUMUMAN      │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               save confirmation
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       3.4       │ ────────────→   │     D1      │
            │ GET TARGET      │                 │   Users     │
            │ USERS           │ ←────────────   │             │
            └─────────────────┘   user list     └─────────────┘
                      |
               target users
                      |
                      v
            ┌─────────────────┐      create     ┌─────────────┐
            │       3.5       │ ────────────→   │     D5      │
            │ GENERATE        │                 │Notifications│
            │ NOTIFIKASI      │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               notifications created
                      |
                      v
            ┌─────────────────┐      send       [FCM Service]
            │       3.6       │ ────────────→
            │ KIRIM PUSH      │
            │ NOTIFICATION    │
            └─────────────────┘
                      |
            notification sent
                      |
                      v
                [ALL USERS]

                    [SANTRI]
                      |
               request pengumuman
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       3.7       │ ────────────→   │     D3      │
            │ GET             │                 │ Pengumuman  │
            │ PENGUMUMAN      │ ←────────────   │             │
            └─────────────────┘   pengumuman    └─────────────┘
                      |
               pengumuman list
                      |
                      v
                   [SANTRI]

3.1 VALIDASI PENGUMUMAN
- Input: judul, isi, tanggal, isPenting, attachments
- Process: validate required fields, check content
- Output: validated pengumuman data
- PSPEC: P3.1

3.2 UPLOAD ATTACHMENT
- Input: file attachments
- Process: upload to Firebase Storage, generate URLs
- Output: attachment URLs
- PSPEC: P3.2

3.3 SIMPAN PENGUMUMAN
- Input: complete pengumuman data
- Process: save to Firestore with metadata
- Output: save confirmation with ID
- PSPEC: P3.3

3.4 GET TARGET USERS
- Input: notification scope (all users/specific roles)
- Process: query users based on criteria
- Output: target user list
- PSPEC: P3.4

3.5 GENERATE NOTIFIKASI
- Input: pengumuman data, target users
- Process: create notification records
- Output: notification batch created
- PSPEC: P3.5

3.6 KIRIM PUSH NOTIFICATION
- Input: notification data, user tokens
- Process: send via FCM service
- Output: delivery confirmation
- PSPEC: P3.6

3.7 GET PENGUMUMAN
- Input: user request, filter criteria
- Process: query active announcements, sort by date
- Output: filtered pengumuman list
- PSPEC: P3.7
```

### 3.3.6 DFD Level 2 - Proses Laporan (5.0)

```
                    [ADMIN]
                      |
            filter criteria + format
                      |
                      v
            ┌─────────────────┐
            │       5.1       │
            │ VALIDASI        │
            │ FILTER          │
            └─────────────────┘
                      |
               validated filters
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       5.2       │ ────────────→   │     D2      │
            │ QUERY DATA      │                 │  Presensi   │
            │ PRESENSI        │ ←────────────   │             │
            └─────────────────┘   presensi data └─────────────┘
                      |              |
                      |              |
                      |              v
                      |     ┌─────────────┐
                      |     │     D1      │
                      └───→ │   Users     │
                            │             │
                            └─────────────┘
                                  |
                            combined data
                                  |
                                  v
            ┌─────────────────┐
            │       5.3       │
            │ GENERATE        │
            │ STATISTICS      │
            └─────────────────┘
                      |
               statistical analysis
                      |
                      v
            ┌─────────────────┐
            │       5.4       │
            │ FORMAT DATA     │
            │ FOR EXPORT      │
            └─────────────────┘
                      |
               formatted data
                      |
                      v
            ┌─────────────────┐      create     [File System]
            │       5.5       │ ────────────→
            │ GENERATE        │
            │ EXCEL/PDF       │ ←────────────
            └─────────────────┘   file created
                      |
               export file
                      |
                      v
            ┌─────────────────┐      log        ┌─────────────┐
            │       5.6       │ ────────────→   │   System    │
            │ LOG EXPORT      │                 │    Logs     │
            │ ACTIVITY        │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               file ready
                      |
                      v
                    [ADMIN]

5.1 VALIDASI FILTER
- Input: tanggal mulai/selesai, user filter, status filter
- Process: validate date range, check user permissions
- Output: validated filter criteria
- PSPEC: P5.1

5.2 QUERY DATA PRESENSI
- Input: validated filters
- Process: join presensi with user data, apply filters
- Output: filtered presensi records with user info
- PSPEC: P5.2

5.3 GENERATE STATISTICS
- Input: presensi data
- Process: calculate attendance rates, late counts, trends
- Output: statistical summary and charts data
- PSPEC: P5.3

5.4 FORMAT DATA FOR EXPORT
- Input: raw data + statistics
- Process: structure data for export format
- Output: formatted data ready for file generation
- PSPEC: P5.4

5.5 GENERATE EXCEL/PDF
- Input: formatted data, export format preference
- Process: create Excel workbook or PDF document
- Output: downloadable file with data
- PSPEC: P5.5

5.6 LOG EXPORT ACTIVITY
- Input: export details, admin ID, timestamp
- Process: record export activity for audit
- Output: audit log entry
- PSPEC: P5.6
```

### 3.3.7 DFD Level 2 - Proses Gamifikasi (7.0)

```
                [SYSTEM EVENTS]
                      |
            activity triggers
                      |
                      v
            ┌─────────────────┐
            │       7.1       │
            │ DETECT EVENT    │
            │ TYPE            │
            └─────────────────┘
                      |
               event categorized
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       7.2       │ ────────────→   │     D1      │
            │ CALCULATE       │                 │   Users     │
            │ POINTS          │ ←────────────   │             │
            └─────────────────┘   user data     └─────────────┘
                      |
               points calculated
                      |
                      v
            ┌─────────────────┐      save       ┌─────────────┐
            │       7.3       │ ────────────→   │     D9      │
            │ RECORD POINT    │                 │ PointHistory│
            │ TRANSACTION     │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               transaction recorded
                      |
                      v
            ┌─────────────────┐      update     ┌─────────────┐
            │       7.4       │ ────────────→   │     D1      │
            │ UPDATE USER     │                 │   Users     │
            │ TOTAL POINTS    │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               points updated
                      |
                      v
            ┌─────────────────┐      check      ┌─────────────┐
            │       7.5       │ ────────────→   │     D6      │
            │ CHECK           │                 │Achievements │
            │ ACHIEVEMENTS    │ ←────────────   │             │
            └─────────────────┘   criteria      └─────────────┘
                      |
               achievement check
                      |
                      v
            ┌─────────────────┐      create     ┌─────────────┐
            │       7.6       │ ────────────→   │     D7      │
            │ UNLOCK          │                 │UserAchieve- │
            │ ACHIEVEMENTS    │                 │ments        │
            └─────────────────┘                 └─────────────┘
                      |
               achievements unlocked
                      |
                      v
            ┌─────────────────┐      update     ┌─────────────┐
            │       7.7       │ ────────────→   │     D8      │
            │ UPDATE          │                 │Leaderboards │
            │ LEADERBOARD     │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               leaderboard updated
                      |
                      v
            ┌─────────────────┐      create     ┌─────────────┐
            │       7.8       │ ────────────→   │     D5      │
            │ GENERATE        │                 │Notifications│
            │ NOTIFICATIONS   │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               notifications sent
                      |
                      v
                   [USER]

7.1 DETECT EVENT TYPE
- Input: system activity (presensi, kegiatan, etc.)
- Process: categorize event type for point calculation
- Output: event type with metadata
- PSPEC: P7.1

7.2 CALCULATE POINTS
- Input: event type, user data, current streak
- Process: apply point rules, bonuses, penalties
- Output: calculated points with breakdown
- PSPEC: P7.2

7.3 RECORD POINT TRANSACTION
- Input: calculated points, event details
- Process: create point history record
- Output: transaction confirmation
- PSPEC: P7.3

7.4 UPDATE USER TOTAL POINTS
- Input: new points, user ID
- Process: add/subtract from user total, update level
- Output: updated user profile
- PSPEC: P7.4

7.5 CHECK ACHIEVEMENTS
- Input: user activity, current achievements
- Process: evaluate achievement criteria
- Output: eligible achievements list
- PSPEC: P7.5

7.6 UNLOCK ACHIEVEMENTS
- Input: eligible achievements, user ID
- Process: create achievement records, award points
- Output: achievement unlock confirmation
- PSPEC: P7.6

7.7 UPDATE LEADERBOARD
- Input: user points, period type
- Process: recalculate rankings for all periods
- Output: updated leaderboard positions
- PSPEC: P7.7

7.8 GENERATE NOTIFICATIONS
- Input: points earned, achievements unlocked, rank changes
- Process: create notification messages
- Output: notifications for user engagement
- PSPEC: P7.8
```

### 3.3.8 DFD Level 2 - Proses Jadwal (4.0)

```
                    [ADMIN]
                      |
            kegiatan data + settings
                      |
                      v
            ┌─────────────────┐
            │       4.1       │
            │ VALIDASI        │
            │ JADWAL          │
            └─────────────────┘
                      |
               validated data
                      |
                      v
            ┌─────────────────┐      check      ┌─────────────┐
            │       4.2       │ ────────────→   │     D4      │
            │ CEK KONFLIK     │                 │   Jadwal    │
            │ JADWAL          │ ←────────────   │             │
            └─────────────────┘   existing events └─────────────┘
                      |
               conflict check result
                      |
                      v
            ┌─────────────────┐      save       ┌─────────────┐
            │       4.3       │ ────────────→   │     D4      │
            │ SIMPAN          │                 │   Jadwal    │
            │ JADWAL          │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               save confirmation
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       4.4       │ ────────────→   │     D1      │
            │ GET TARGET      │                 │   Users     │
            │ PARTICIPANTS    │ ←────────────   │             │
            └─────────────────┘   user list     └─────────────┘
                      |
               participant list
                      |
                      v
            ┌─────────────────┐      create     ┌─────────────┐
            │       4.5       │ ────────────→   │     D5      │
            │ GENERATE        │                 │Notifications│
            │ REMINDER        │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               reminders created
                      |
                      v
            ┌─────────────────┐      sync       [Calendar Service]
            │       4.6       │ ────────────→
            │ SYNC CALENDAR   │
            │                 │ ←────────────
            └─────────────────┘   sync confirmed
                      |
            calendar synced
                      |
                      v
                [ALL PARTICIPANTS]

                    [SANTRI]
                      |
               request jadwal
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       4.7       │ ────────────→   │     D4      │
            │ GET JADWAL      │                 │   Jadwal    │
            │ KEGIATAN        │ ←────────────   │             │
            └─────────────────┘   event list    └─────────────┘
                      |
               formatted calendar
                      |
                      v
                   [SANTRI]

4.1 VALIDASI JADWAL
- Input: nama kegiatan, tanggal, waktu, tempat, max participants
- Process: validate required fields, check date format, capacity limits
- Output: validated jadwal data
- PSPEC: P4.1

4.2 CEK KONFLIK JADWAL
- Input: tanggal, waktu mulai, waktu selesai, tempat
- Process: check overlapping events, venue availability
- Output: conflict check result
- PSPEC: P4.2

4.3 SIMPAN JADWAL
- Input: validated jadwal data
- Process: save to Firestore with metadata
- Output: save confirmation with event ID
- PSPEC: P4.3

4.4 GET TARGET PARTICIPANTS
- Input: event scope, role filters, manual selection
- Process: query users based on criteria
- Output: target participant list
- PSPEC: P4.4

4.5 GENERATE REMINDER
- Input: event data, participant list, reminder schedule
- Process: create reminder notifications with scheduling
- Output: scheduled reminders created
- PSPEC: P4.5

4.6 SYNC CALENDAR
- Input: event data, calendar integration settings
- Process: sync with external calendar services
- Output: calendar sync confirmation
- PSPEC: P4.6

4.7 GET JADWAL KEGIATAN
- Input: user request, date range, filter criteria
- Process: query active events, format for calendar display
- Output: formatted calendar data
- PSPEC: P4.7
```

### 3.3.9 DFD Level 2 - Proses Dashboard (6.0)

```
                [SANTRI/ADMIN/DEWAN GURU]
                      |
            dashboard request + preferences
                      |
                      v
            ┌─────────────────┐
            │       6.1       │
            │ AUTHENTICATE    │
            │ & AUTHORIZE     │
            └─────────────────┘
                      |
               auth success
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       6.2       │ ────────────→   │     D1      │
            │ LOAD USER       │                 │   Users     │
            │ PROFILE         │ ←────────────   │             │
            └─────────────────┘   user data     └─────────────┘
                      |
               user profile loaded
                      |
                      v
                    Parallel{Load Dashboard Components}
                      |
        ┌─────────────┼─────────────┼─────────────┼─────────────┐
        │             │             │             │             │
        ▼             ▼             ▼             ▼             ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│     6.3     │ │     6.4     │ │     6.5     │ │     6.6     │ │     6.7     │
│LOAD PRESENSI│ │LOAD KEGIATAN│ │LOAD PENGUMU-│ │LOAD NOTIFI- │ │LOAD GAMIFI- │
│ STATISTICS  │ │  MENDATANG  │ │    MAN      │ │   KASI      │ │   KASI      │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
        │             │             │             │             │
        ▼             ▼             ▼             ▼             ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│     D2      │ │     D4      │ │     D3      │ │     D5      │ │D6,D7,D8,D9  │
│  Presensi   │ │   Jadwal    │ │ Pengumuman  │ │Notifications│ │Gamification │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
        │             │             │             │             │
        └─────────────┼─────────────┼─────────────┼─────────────┘
                      │             │             │
                      ▼             ▼             ▼
            ┌─────────────────┐
            │       6.8       │
            │ AGGREGATE &     │
            │ FORMAT DATA     │
            └─────────────────┘
                      |
               formatted dashboard data
                      |
                      v
            ┌─────────────────┐
            │       6.9       │
            │ GENERATE        │
            │ WIDGETS         │
            └─────────────────┘
                      |
               dashboard widgets
                      |
                      v
            ┌─────────────────┐      create     [Real-time Listeners]
            │       6.10      │ ────────────→
            │ SETUP REAL-TIME │
            │ LISTENERS       │
            └─────────────────┘
                      |
            dashboard ready
                      |
                      v
              [USER DASHBOARD]

6.1 AUTHENTICATE & AUTHORIZE
- Input: user request, session token
- Process: validate authentication, check role permissions
- Output: authorization result
- PSPEC: P6.1

6.2 LOAD USER PROFILE
- Input: authenticated user ID
- Process: fetch user profile, preferences, settings
- Output: complete user profile data
- PSPEC: P6.2

6.3 LOAD PRESENSI STATISTICS
- Input: user ID, date range
- Process: calculate attendance stats, trends, streaks
- Output: presensi summary and charts data
- PSPEC: P6.3

6.4 LOAD KEGIATAN MENDATANG
- Input: user ID, role, date filter
- Process: query upcoming events, participant status
- Output: upcoming events list
- PSPEC: P6.4

6.5 LOAD PENGUMUMAN
- Input: user role, importance filter
- Process: query recent announcements, mark as read
- Output: announcement list with read status
- PSPEC: P6.5

6.6 LOAD NOTIFIKASI
- Input: user ID, unread filter
- Process: fetch recent notifications, update read status
- Output: notification list with metadata
- PSPEC: P6.6

6.7 LOAD GAMIFIKASI
- Input: user ID, leaderboard period
- Process: fetch points, level, achievements, rankings
- Output: gamification summary data
- PSPEC: P6.7

6.8 AGGREGATE & FORMAT DATA
- Input: all loaded component data
- Process: combine data, apply user preferences, format for display
- Output: structured dashboard data
- PSPEC: P6.8

6.9 GENERATE WIDGETS
- Input: formatted dashboard data, user role
- Process: create role-based widgets, apply responsive layout
- Output: dashboard widget configuration
- PSPEC: P6.9

6.10 SETUP REAL-TIME LISTENERS
- Input: user ID, dashboard components
- Process: establish WebSocket connections, set up data sync
- Output: real-time dashboard with live updates
- PSPEC: P6.10
```

### 3.3.10 DFD Level 2 - Proses Manajemen User (8.0)

```
                    [ADMIN/DEWAN GURU]
                      |
            user management request
                      |
                      v
            ┌─────────────────┐
            │       8.1       │
            │ VALIDASI        │
            │ PERMISSION      │
            └─────────────────┘
                      |
               permission granted
                      |
                      v
            Decision{Operation Type}
                      |
        ┌─────────────┼─────────────┼─────────────┐
        │             │             │             │
        ▼             ▼             ▼             ▼
   [ADD USER]    [EDIT USER]   [DELETE USER]  [VIEW USERS]
        │             │             │             │
        ▼             ▼             ▼             ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│     8.2     │ │     8.4     │ │     8.6     │ │     8.8     │
│ VALIDASI    │ │ LOAD USER   │ │ CONFIRM     │ │ QUERY USER  │
│ USER BARU   │ │ DATA        │ │ DELETE      │ │ LIST        │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
        │             │             │             │
        ▼             ▼             ▼             ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│     8.3     │ │     8.5     │ │     8.7     │ │     D1      │
│ CREATE USER │ │ UPDATE USER │ │ SOFT DELETE │ │   Users     │
│ ACCOUNT     │ │ PROFILE     │ │ USER        │ │             │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
        │             │             │             │
        └─────────────┼─────────────┼─────────────┘
                      │             │
                      ▼             ▼
            ┌─────────────────┐      save       ┌─────────────┐
            │       8.9       │ ────────────→   │     D1      │
            │ LOG USER        │                 │   Users     │
            │ ACTIVITY        │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               activity logged
                      |
                      v
            ┌─────────────────┐      send       [Email Service]
            │       8.10      │ ────────────→
            │ SEND USER       │
            │ NOTIFICATION    │
            └─────────────────┘
                      |
            notification sent
                      |
                      v
                [ADMIN/DEWAN GURU]

8.1 VALIDASI PERMISSION
- Input: admin request, operation type, target user
- Process: check admin role, validate permissions for operation
- Output: permission validation result
- PSPEC: P8.1

8.2 VALIDASI USER BARU
- Input: nama, email, role, RFID card (optional)
- Process: validate email format, check duplicates, role validation
- Output: validated user data
- PSPEC: P8.2

8.3 CREATE USER ACCOUNT
- Input: validated user data
- Process: create Firebase Auth account, generate initial profile
- Output: new user account with credentials
- PSPEC: P8.3

8.4 LOAD USER DATA
- Input: user ID to edit
- Process: fetch complete user profile and metadata
- Output: editable user data
- PSPEC: P8.4

8.5 UPDATE USER PROFILE
- Input: modified user data, change tracking
- Process: validate changes, update profile, handle role changes
- Output: updated user profile
- PSPEC: P8.5

8.6 CONFIRM DELETE
- Input: user ID to delete, confirmation flag
- Process: check delete permissions, validate dependencies
- Output: delete confirmation result
- PSPEC: P8.6

8.7 SOFT DELETE USER
- Input: confirmed user ID, deletion reason
- Process: deactivate account, preserve data for audit
- Output: user deactivation confirmation
- PSPEC: P8.7

8.8 QUERY USER LIST
- Input: filter criteria, pagination, sorting
- Process: query users with filters, format for display
- Output: paginated user list with metadata
- PSPEC: P8.8

8.9 LOG USER ACTIVITY
- Input: operation type, admin ID, target user, timestamp
- Process: create audit log entry for user management
- Output: audit log confirmation
- PSPEC: P8.9

8.10 SEND USER NOTIFICATION
- Input: operation result, user data, notification type
- Process: send welcome/update/deactivation emails
- Output: notification delivery confirmation
- PSPEC: P8.10
```

### 3.3.11 DFD Level 2 - Proses Notifikasi (9.0)

```
                [SYSTEM EVENTS]
                      |
            notification triggers
                      |
                      v
            ┌─────────────────┐
            │       9.1       │
            │ DETECT EVENT    │
            │ TYPE            │
            └─────────────────┘
                      |
               event categorized
                      |
                      v
            ┌─────────────────┐      query      ┌─────────────┐
            │       9.2       │ ────────────→   │     D1      │
            │ GET TARGET      │                 │   Users     │
            │ RECIPIENTS      │ ←────────────   │             │
            └─────────────────┘   user list     └─────────────┘
                      |
               recipient list
                      |
                      v
            ┌─────────────────┐
            │       9.3       │
            │ GENERATE        │
            │ MESSAGE         │
            └─────────────────┘
                      |
               notification message
                      |
                      v
            ┌─────────────────┐
            │       9.4       │
            │ APPLY USER      │
            │ PREFERENCES     │
            └─────────────────┘
                      |
               filtered notifications
                      |
                      v
            ┌─────────────────┐      save       ┌─────────────┐
            │       9.5       │ ────────────→   │     D5      │
            │ SAVE            │                 │Notifications│
            │ NOTIFICATION    │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
               notification saved
                      |
                      v
                    Parallel{Send Multiple Channels}
                      |
        ┌─────────────┼─────────────┼─────────────┐
        │             │             │             │
        ▼             ▼             ▼             ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│     9.6     │ │     9.7     │ │     9.8     │ │     9.9     │
│ SEND PUSH   │ │ SEND EMAIL  │ │ SEND IN-APP │ │ SEND SMS    │
│NOTIFICATION │ │NOTIFICATION │ │NOTIFICATION │ │(OPTIONAL)   │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
        │             │             │             │
        ▼             ▼             ▼             ▼
 [FCM Service]  [Email Service] [WebSocket]   [SMS Service]
        │             │             │             │
        └─────────────┼─────────────┼─────────────┘
                      │             │
                      ▼             ▼
            ┌─────────────────┐
            │       9.10      │
            │ TRACK DELIVERY  │
            │ STATUS          │
            └─────────────────┘
                      |
               delivery tracking
                      |
                      v
            ┌─────────────────┐      update     ┌─────────────┐
            │       9.11      │ ────────────→   │     D5      │
            │ UPDATE          │                 │Notifications│
            │ READ STATUS     │                 │             │
            └─────────────────┘                 └─────────────┘
                      |
            status updated
                      |
                      v
                   [RECIPIENTS]

9.1 DETECT EVENT TYPE
- Input: system event (presensi, pengumuman, achievement, etc.)
- Process: categorize event, determine notification priority
- Output: event type with notification metadata
- PSPEC: P9.1

9.2 GET TARGET RECIPIENTS
- Input: event type, scope, role filters
- Process: query users based on notification scope and preferences
- Output: filtered recipient list
- PSPEC: P9.2

9.3 GENERATE MESSAGE
- Input: event data, notification template, recipient info
- Process: create personalized notification content
- Output: formatted notification message
- PSPEC: P9.3

9.4 APPLY USER PREFERENCES
- Input: notification message, recipient preferences
- Process: filter by user notification settings, quiet hours
- Output: preference-filtered notifications
- PSPEC: P9.4

9.5 SAVE NOTIFICATION
- Input: final notification data, recipient list
- Process: create notification records in database
- Output: notification IDs and save confirmation
- PSPEC: P9.5

9.6 SEND PUSH NOTIFICATION
- Input: notification data, FCM tokens
- Process: send via Firebase Cloud Messaging
- Output: push delivery confirmation
- PSPEC: P9.6

9.7 SEND EMAIL NOTIFICATION
- Input: notification data, email addresses
- Process: format HTML email, send via email service
- Output: email delivery confirmation
- PSPEC: P9.7

9.8 SEND IN-APP NOTIFICATION
- Input: notification data, active user sessions
- Process: send real-time notification via WebSocket
- Output: in-app delivery confirmation
- PSPEC: P9.8

9.9 SEND SMS (OPTIONAL)
- Input: critical notifications, phone numbers
- Process: send SMS for urgent notifications only
- Output: SMS delivery confirmation
- PSPEC: P9.9

9.10 TRACK DELIVERY STATUS
- Input: delivery confirmations from all channels
- Process: aggregate delivery status, track failures
- Output: comprehensive delivery report
- PSPEC: P9.10

9.11 UPDATE READ STATUS
- Input: user interaction, notification ID
- Process: mark notifications as read, update timestamps
- Output: read status update confirmation
- PSPEC: P9.11
```

## 3.4 Process Specification (PSPEC)

### PSPEC P3.1 - Validasi Pengumuman

```
Process Name: Validate Announcement Data
Input: Judul, isi, tanggal, isPenting, attachments, author data
Output: Validated announcement data or validation errors
Data Store: None (validation only)
External: File Validation Service

Logic:
1. Validate required fields (judul, isi, tanggal)
2. Check judul length (max 200 characters)
3. Validate content format and length
4. Check tanggal format and validity
5. Validate attachment files (type, size, virus scan)
6. Check author permissions
7. Sanitize input content

Error Handling:
- MISSING_REQUIRED_FIELD: "Field wajib tidak boleh kosong"
- TITLE_TOO_LONG: "Judul terlalu panjang (max 200 karakter)"
- INVALID_DATE: "Format tanggal tidak valid"
- FILE_TOO_LARGE: "Ukuran file terlalu besar (max 10MB)"
- INVALID_FILE_TYPE: "Tipe file tidak didukung"

Business Rules:
- Judul maksimal 200 karakter
- Isi pengumuman maksimal 5000 karakter
- Maksimal 5 attachment per pengumuman
- File attachment maksimal 10MB
- Hanya admin yang bisa membuat pengumuman penting
```

### PSPEC P3.2 - Upload Attachment

```
Process Name: Upload Announcement Attachments
Input: File attachments, announcement ID, user permissions
Output: Attachment URLs, upload confirmation
Data Store: None (files stored externally)
External: Firebase Storage

Logic:
1. Validate file permissions and size limits
2. Generate unique file names with UUID
3. Create folder structure by date and announcement ID
4. Upload files to Firebase Storage
5. Generate secure download URLs
6. Create file metadata records
7. Return attachment URLs for database storage

Error Handling:
- UPLOAD_FAILED: "Gagal mengupload file"
- STORAGE_QUOTA_EXCEEDED: "Kuota penyimpanan penuh"
- NETWORK_ERROR: "Koneksi internet bermasalah"
- PERMISSION_DENIED: "Tidak memiliki izin upload"

Business Rules:
- Files stored in hierarchical structure: /pengumuman/YYYY/MM/announcementId/
- Generate secure URLs with expiration
- Virus scanning for all uploaded files
- Automatic thumbnail generation for images
```

### PSPEC P3.3 - Simpan Pengumuman

```
Process Name: Save Announcement to Database
Input: Validated announcement data, attachment URLs, author ID
Output: Save confirmation with announcement ID
Data Store: D3 Pengumuman (for announcement records)
External: None

Logic:
1. Generate unique announcement ID
2. Create announcement document structure
3. Include attachment URLs and metadata
4. Set creation and update timestamps
5. Save to Firestore collection
6. Create search index for announcement content
7. Return confirmation with generated ID

Error Handling:
- DATABASE_SAVE_FAILED: "Gagal menyimpan pengumuman"
- DUPLICATE_TITLE: "Judul pengumuman sudah ada"
- FIRESTORE_ERROR: "Error database"

Business Rules:
- Auto-generate unique IDs
- Store creation and modification timestamps
- Index title and content for search
- Maintain version history for edits
```

### PSPEC P3.4 - Get Target Users

```
Process Name: Get Notification Target Users
Input: Notification scope, role filters, manual selection
Output: Target user list with notification tokens
Data Store: D1 Users (for user data and tokens)
External: None

Logic:
1. Determine notification scope (all users, specific roles, manual)
2. Query users based on scope criteria
3. Filter active users only
4. Get device tokens for push notifications
5. Apply user notification preferences
6. Exclude users who opted out
7. Return filtered user list with tokens

Error Handling:
- USER_QUERY_FAILED: "Gagal mengambil data pengguna"
- NO_VALID_TOKENS: "Tidak ada token notifikasi valid"

Business Rules:
- Respect user notification preferences
- Include only active accounts
- Filter by quiet hours settings
- Maximum 1000 recipients per batch
```

### PSPEC P3.5 - Generate Notifikasi

```
Process Name: Generate Notification Records
Input: Pengumuman data, target users, notification template
Output: Notification batch created
Data Store: D5 Notifications (for notification records)
External: None

Logic:
1. Create notification template with announcement data
2. Personalize notifications for each target user
3. Set notification priority based on isPenting flag
4. Create notification records in database
5. Set delivery scheduling if needed
6. Generate notification IDs for tracking
7. Mark notifications as pending delivery

Error Handling:
- NOTIFICATION_CREATE_FAILED: "Gagal membuat notifikasi"
- TEMPLATE_ERROR: "Error template notifikasi"

Business Rules:
- Important announcements get high priority
- Notifications scheduled for optimal delivery time
- Include announcement summary in notification
- Track notification creation timestamps
```

### PSPEC P3.6 - Kirim Push Notification

```
Process Name: Send Push Notifications
Input: Notification data, user device tokens, delivery schedule
Output: Delivery confirmation and status
Data Store: D5 Notifications (for delivery status updates)
External: FCM Service (Firebase Cloud Messaging)

Logic:
1. Format notification payload for FCM
2. Include deep linking for announcement details
3. Set notification priority and TTL
4. Send batch notifications via FCM
5. Handle delivery confirmations
6. Update notification status in database
7. Retry failed deliveries

Error Handling:
- FCM_SEND_FAILED: "Gagal mengirim push notification"
- INVALID_TOKEN: "Token perangkat tidak valid"
- QUOTA_EXCEEDED: "Kuota FCM terlampaui"

Business Rules:
- Batch notifications for efficiency
- Include action buttons for important announcements
- Set appropriate TTL for notifications
- Retry failed deliveries up to 3 times
```

### PSPEC P3.7 - Get Pengumuman

```
Process Name: Retrieve Announcements List
Input: User request, filter criteria, pagination parameters
Output: Filtered announcement list with metadata
Data Store: D3 Pengumuman (for announcement data)
External: None

Logic:
1. Apply user role-based filtering
2. Sort announcements by date (newest first)
3. Apply pagination parameters
4. Include read status for each user
5. Format announcement data for display
6. Include attachment metadata
7. Return paginated results

Error Handling:
- QUERY_FAILED: "Gagal mengambil data pengumuman"
- INVALID_FILTER: "Filter tidak valid"

Business Rules:
- Show active announcements only
- Important announcements appear first
- Include read/unread status
- Paginate results for performance
```

### PSPEC P4.1 - Validasi Jadwal

```
Process Name: Validate Schedule Data
Input: Nama kegiatan, tanggal, waktu, tempat, max participants, creator permissions
Output: Validated schedule data or validation errors
Data Store: None (validation only)
External: Calendar Validation Service

Logic:
1. Validate required fields (nama, tanggal, waktu)
2. Check nama kegiatan length and format
3. Validate date format and ensure future date
4. Validate time format and logical sequence (start < end)
5. Check tempat availability and format
6. Validate max participants limit
7. Check creator permissions for event creation

Error Handling:
- MISSING_REQUIRED_FIELD: "Field wajib tidak boleh kosong"
- INVALID_DATE_FORMAT: "Format tanggal tidak valid"
- PAST_DATE_ERROR: "Tanggal tidak boleh masa lalu"
- INVALID_TIME_SEQUENCE: "Waktu mulai harus sebelum waktu selesai"
- VENUE_FORMAT_ERROR: "Format tempat tidak valid"
- PARTICIPANT_LIMIT_EXCEEDED: "Jumlah peserta melebihi batas maksimal"

Business Rules:
- Event name maksimal 200 karakter
- Tanggal kegiatan minimal H+1 dari sekarang
- Durasi kegiatan minimal 30 menit, maksimal 12 jam
- Maksimal 500 peserta per kegiatan
- Hanya admin dan dewan guru yang bisa membuat jadwal
```

### PSPEC P4.2 - Cek Konflik Jadwal

```
Process Name: Check Schedule Conflicts
Input: Tanggal, waktu mulai, waktu selesai, tempat, creator ID
Output: Conflict check result with details
Data Store: D4 Jadwal (for existing events), D1 Users (for user schedules)
External: None

Logic:
1. Query existing events for the same date
2. Check time overlap with existing events
3. Check venue availability for the time slot
4. Check creator's existing commitments
5. Validate resource conflicts (equipment, personnel)
6. Check holiday and special event conflicts
7. Return conflict details if any found

Error Handling:
- QUERY_FAILED: "Gagal memeriksa konflik jadwal"
- VENUE_CONFLICT: "Tempat sudah digunakan pada waktu tersebut"
- TIME_OVERLAP: "Waktu bertabrakan dengan kegiatan lain"
- CREATOR_CONFLICT: "Pembuat sudah memiliki kegiatan pada waktu tersebut"

Business Rules:
- Same venue cannot host multiple events simultaneously
- 30-minute buffer between events in same venue
- Check for national holidays and special events
- Admin can override conflicts with justification
```

### PSPEC P4.3 - Simpan Jadwal

```
Process Name: Save Schedule to Database
Input: Validated schedule data, conflict check results
Output: Save confirmation with event ID
Data Store: D4 Jadwal (for schedule records)
External: None

Logic:
1. Generate unique event ID
2. Create schedule document structure
3. Set creation and update timestamps
4. Initialize participant list (empty initially)
5. Set default event status (active)
6. Save to Firestore collection
7. Create calendar index entry
8. Return confirmation with generated ID

Error Handling:
- DATABASE_SAVE_FAILED: "Gagal menyimpan jadwal"
- FIRESTORE_ERROR: "Error database"
- INDEX_UPDATE_FAILED: "Gagal mengupdate indeks kalender"

Business Rules:
- Auto-generate unique event IDs
- Store creation and modification timestamps
- Initialize with zero participants
- Index by date for efficient querying
```

### PSPEC P4.4 - Get Target Participants

```
Process Name: Get Event Target Participants
Input: Event scope, role filters, manual selection, event capacity
Output: Target participant list
Data Store: D1 Users (for user data and preferences)
External: None

Logic:
1. Determine participant scope (all users, specific roles, manual)
2. Query users based on scope criteria
3. Filter active and eligible users
4. Apply user event preferences
5. Check user availability for event time
6. Exclude users who opt-out of events
7. Limit to event capacity if specified
8. Return filtered participant list

Error Handling:
- USER_QUERY_FAILED: "Gagal mengambil data peserta"
- CAPACITY_EXCEEDED: "Jumlah peserta melebihi kapasitas"
- NO_ELIGIBLE_PARTICIPANTS: "Tidak ada peserta yang memenuhi kriteria"

Business Rules:
- Respect user event notification preferences
- Check user availability conflicts
- First-come-first-served for limited capacity events
- Include only active accounts
```

### PSPEC P4.5 - Generate Reminder

```
Process Name: Generate Event Reminders
Input: Event data, participant list, reminder schedule settings
Output: Scheduled reminders created
Data Store: D5 Notifications (for reminder records)
External: Scheduling Service

Logic:
1. Calculate reminder times (24h, 2h, 30min before event)
2. Create reminder notification templates
3. Personalize reminders for each participant
4. Schedule reminders with appropriate timing
5. Set reminder priorities and channels
6. Create reminder records in database
7. Set up reminder delivery tracking

Error Handling:
- REMINDER_SCHEDULE_FAILED: "Gagal menjadwalkan reminder"
- TEMPLATE_ERROR: "Error template reminder"
- NOTIFICATION_CREATE_FAILED: "Gagal membuat notifikasi reminder"

Business Rules:
- Send reminders 24 hours, 2 hours, and 30 minutes before event
- Include event details and location in reminders
- Allow users to customize reminder preferences
- Important events get additional reminder channels
```

### PSPEC P4.6 - Sync Calendar

```
Process Name: Sync with External Calendars
Input: Event data, calendar integration settings, user preferences
Output: Calendar sync confirmation
Data Store: None (external calendar storage)
External: Google Calendar API, Outlook Calendar API

Logic:
1. Check user calendar integration preferences
2. Format event data for external calendar format
3. Create calendar event with appropriate details
4. Set event reminders in external calendar
5. Handle calendar permissions and authentication
6. Sync event updates and cancellations
7. Return sync status and external event ID

Error Handling:
- CALENDAR_AUTH_FAILED: "Gagal autentikasi kalender eksternal"
- SYNC_FAILED: "Gagal sinkronisasi dengan kalender"
- PERMISSION_DENIED: "Tidak memiliki izin akses kalender"
- EXTERNAL_API_ERROR: "Error API kalender eksternal"

Business Rules:
- Sync only for users who enabled calendar integration
- Include all event details and location
- Handle timezone conversions appropriately
- Respect external calendar privacy settings
```

### PSPEC P4.7 - Get Jadwal Kegiatan

```
Process Name: Retrieve Event Schedule
Input: User request, date range, filter criteria, view type (calendar/list)
Output: Formatted schedule data for display
Data Store: D4 Jadwal (for event data)
External: None

Logic:
1. Apply user role-based filtering
2. Filter events by date range
3. Include user participation status
4. Sort events by date and time
5. Format data for requested view type (calendar/list)
6. Include event capacity and current participants
7. Add user-specific event actions (join/leave)
8. Return formatted event data

Error Handling:
- QUERY_FAILED: "Gagal mengambil data jadwal"
- INVALID_DATE_RANGE: "Rentang tanggal tidak valid"
- FORMAT_ERROR: "Error format data kalender"

Business Rules:
- Show only active events
- Include past events in history view
- Show participation status for each user
- Filter by user permissions and roles
```

### PSPEC P2.1 - Scan RFID

```
Process Name: Scan RFID
Input: RFID card data
Output: Scan status
Logic:
1. Baca data RFID dari kartu
2. Validasi format RFID
3. Cek apakah kartu terdaftar
4. Return status (valid/invalid)
```

### PSPEC P2.2 - Validasi Presensi

```
Process Name: Validasi Presensi
Input: User ID, timestamp, RFID
Output: Presensi record
Logic:
1. Cek apakah user sudah presensi hari ini
2. Tentukan status berdasarkan waktu:
   - Hadir: sebelum jam 08:00
   - Terlambat: 08:00 - 10:00
   - Alpha: tidak presensi
3. Generate record presensi
```

### PSPEC P2.3 - Simpan Presensi

```
Process Name: Simpan Presensi
Input: Validated presensi data
Output: Save confirmation
Logic:
1. Insert data ke collection 'presensi'
2. Update user points
3. Log activity
4. Return success/error status
```

### PSPEC P2.4 - Update Poin

```
Process Name: Update User Points
Input: Presensi success data, user ID, attendance status
Output: Points calculation result, updated user profile
Data Store: D1 Users (for point updates), D9 PointHistory (for transactions)
External: Gamification Engine

Logic:
1. Determine point value based on attendance status:
   - Hadir: +10 points
   - Terlambat: +5 points
   - Alpha: -5 points penalty
2. Calculate bonus points for streaks
3. Check for special event bonuses
4. Create point transaction record
5. Update user total points
6. Check for level progression
7. Update user statistics

Error Handling:
- POINT_CALCULATION_ERROR: "Gagal menghitung poin"
- DATABASE_UPDATE_FAILED: "Gagal mengupdate poin pengguna"
- TRANSACTION_FAILED: "Gagal mencatat transaksi poin"

Business Rules:
- Points awarded immediately after valid attendance
- Bonus points for consecutive attendance (streak)
- Penalty points for absence without excuse
- Maximum 50 bonus points per day
```

### PSPEC P2.5 - Kirim Notifikasi

```
Process Name: Send Attendance Notification
Input: Presensi record, points earned, user data
Output: Notification delivery confirmation
Data Store: D5 Notifications (for notification records)
External: FCM Service (for push notifications)

Logic:
1. Generate personalized notification message
2. Include attendance status and points earned
3. Create notification record in database
4. Send push notification via FCM
5. Send in-app notification for active users
6. Update notification delivery status
7. Log notification activity

Error Handling:
- NOTIFICATION_GENERATION_FAILED: "Gagal membuat notifikasi"
- PUSH_DELIVERY_FAILED: "Gagal mengirim push notification"
- DATABASE_SAVE_FAILED: "Gagal menyimpan notifikasi"

Business Rules:
- Notifications sent immediately after attendance
- Include motivational messages for achievements
- Reminder notifications for missed attendance
- Respect user notification preferences
```

### PSPEC P1.1 - Proses Login Google

```
Process Name: Google Authentication Login
Input: Google Account Credentials
Output: Authentication Result + Error Details
Logic:
1. Inisialisasi Google Sign In
2. Request Google Authentication
3. Validasi response dari Google
4. Jika berhasil: ambil user profile
5. Jika gagal: return error dengan keterangan:
   - NETWORK_ERROR: "Tidak ada koneksi internet"
   - SIGN_IN_CANCELLED: "Login dibatalkan oleh pengguna"
   - SIGN_IN_FAILED: "Gagal login dengan Google"
   - ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL: "Akun sudah terdaftar dengan metode login lain"
   - INVALID_CREDENTIAL: "Kredensial tidak valid"
   - USER_DISABLED: "Akun pengguna telah dinonaktifkan"
   - OPERATION_NOT_ALLOWED: "Metode login tidak diizinkan"
```

### PSPEC P1.2 - Validasi Role Pengguna

```
Process Name: User Role Validation
Input: User Profile Data
Output: Access Permission + Error Details
Logic:
1. Cek apakah user terdaftar dalam database
2. Validasi role pengguna (santri/admin/dewan_guru)
3. Cek status aktif akun
4. Jika berhasil: grant access
5. Jika gagal: return error dengan keterangan:
   - USER_NOT_FOUND: "Pengguna tidak terdaftar dalam sistem"
   - ACCOUNT_INACTIVE: "Akun Anda telah dinonaktifkan"
   - INVALID_ROLE: "Role pengguna tidak valid"
   - PENDING_APPROVAL: "Akun menunggu persetujuan admin"
   - ACCESS_DENIED: "Akses ditolak"
```

```
Process Name: Kirim Notifikasi
Input: Presensi success data
Output: Notification sent
Logic:
1. Generate notification message
2. Send push notification to user
3. Save notification to database
4. Update notification status
```

### PSPEC P5.1 - Validasi Filter

```
Process Name: Validate Report Filters
Input: Tanggal mulai/selesai, user filter, status filter, admin permissions
Output: Validated filter criteria or validation errors
Data Store: None (validation only)
External: None

Logic:
1. Validate date range format and logical sequence
2. Check date range limits (max 1 year)
3. Validate user filter permissions
4. Check status filter values
5. Verify admin has report access rights
6. Sanitize filter parameters
7. Return validated filter object

Error Handling:
- INVALID_DATE_FORMAT: "Format tanggal tidak valid"
- INVALID_DATE_RANGE: "Rentang tanggal tidak valid (max 1 tahun)"
- PERMISSION_DENIED: "Tidak memiliki izin akses laporan"
- INVALID_STATUS_FILTER: "Filter status tidak valid"

Business Rules:
- Maximum date range is 1 year
- Only admin and dewan_guru can access reports
- Default filter is current month if not specified
- All filters are optional except date range
```

### PSPEC P5.2 - Query Data Presensi

```
Process Name: Query Attendance Data
Input: Validated filters, user permissions
Output: Filtered attendance records with user info
Data Store: D2 Presensi (for attendance data), D1 Users (for user details)
External: None

Logic:
1. Build query with validated filters
2. Join presensi data with user information
3. Apply date range filtering
4. Filter by user IDs if specified
5. Filter by attendance status if specified
6. Sort results by date and user name
7. Apply pagination for large datasets
8. Return structured attendance data

Error Handling:
- QUERY_FAILED: "Gagal mengambil data presensi"
- NO_DATA_FOUND: "Tidak ada data presensi untuk filter yang dipilih"
- DATABASE_ERROR: "Error koneksi database"

Business Rules:
- Include user details (nama, role) in results
- Show only data user has permission to see
- Paginate results for performance (max 1000 records per page)
- Include calculated fields (streak, total days)
```

### PSPEC P5.3 - Generate Statistics

```
Process Name: Generate Attendance Statistics
Input: Attendance data, calculation parameters
Output: Statistical summary and chart data
Data Store: None (calculation only)
External: None

Logic:
1. Calculate overall attendance rate
2. Calculate individual user statistics
3. Generate attendance trends over time
4. Calculate late arrival statistics
5. Identify attendance patterns
6. Generate comparative analysis
7. Create chart data for visualization
8. Return comprehensive statistics object

Error Handling:
- CALCULATION_ERROR: "Gagal menghitung statistik"
- INSUFFICIENT_DATA: "Data tidak cukup untuk analisis"

Business Rules:
- Attendance rate = (Hadir + Terlambat) / Total Days * 100
- Exclude weekends and holidays from calculations
- Include trend analysis for insights
- Generate both summary and detailed statistics
```

### PSPEC P5.4 - Format Data for Export

```
Process Name: Format Data for Export
Input: Raw data + statistics, export format preference
Output: Formatted data ready for file generation
Data Store: None (formatting only)
External: None

Logic:
1. Structure data according to export format
2. Add headers and metadata
3. Format dates and numbers appropriately
4. Include summary statistics section
5. Add charts and visualizations if supported
6. Apply localization for Indonesian format
7. Validate data completeness
8. Return formatted export data structure

Error Handling:
- FORMAT_ERROR: "Gagal memformat data untuk export"
- UNSUPPORTED_FORMAT: "Format export tidak didukung"
- DATA_CORRUPTION: "Data tidak lengkap atau rusak"

Business Rules:
- Support Excel (.xlsx) and PDF formats
- Include company/institution branding
- Add export timestamp and user info
- Format numbers with Indonesian locale
```

### PSPEC P5.5 - Generate Excel/PDF

```
Process Name: Generate Export File
Input: Formatted data, export format, file preferences
Output: Downloadable file with attendance data
Data Store: None (file generation only)
External: File System, Excel Library, PDF Library

Logic:
1. Initialize document based on format (Excel/PDF)
2. Create document structure with headers
3. Insert attendance data into document
4. Add charts and visualizations
5. Apply styling and formatting
6. Add summary page with statistics
7. Save file to temporary location
8. Return file download URL

Error Handling:
- FILE_GENERATION_FAILED: "Gagal membuat file export"
- DISK_SPACE_ERROR: "Ruang penyimpanan tidak cukup"
- LIBRARY_ERROR: "Error library export"

Business Rules:
- Excel files include multiple worksheets (data, summary, charts)
- PDF files include professional formatting
- Files are automatically deleted after 24 hours
- Maximum file size 50MB
```

### PSPEC P5.6 - Log Export Activity

```
Process Name: Log Export Activity
Input: Export details, admin ID, timestamp, file info
Output: Audit log entry
Data Store: System Logs (for audit trail)
External: None

Logic:
1. Create export activity log entry
2. Include user ID, timestamp, filters used
3. Record file format and size
4. Log export success/failure status
5. Include IP address and user agent
6. Store for audit and compliance
7. Update export statistics

Error Handling:
- LOG_FAILED: "Gagal mencatat aktivitas export"
- STORAGE_ERROR: "Gagal menyimpan log audit"

Business Rules:
- All export activities must be logged
- Logs retained for 2 years minimum
- Include sensitive data access tracking
- Generate monthly export reports for admin
```

## 3.5 Object Oriented Design

### PSPEC P6.1 - Authenticate & Authorize

```
Process Name: Dashboard Authentication & Authorization
Input: User request, session token, requested dashboard components
Output: Authorization result with permitted components
Data Store: D1 Users (for user permissions)
External: Firebase Auth (for token validation)

Logic:
1. Validate session token with Firebase Auth
2. Retrieve user profile and role information
3. Check user permissions for dashboard access
4. Determine allowed dashboard components based on role
5. Validate component-specific permissions
6. Create authorized component list
7. Return authorization result

Error Handling:
- INVALID_TOKEN: "Token tidak valid atau expired"
- PERMISSION_DENIED: "Tidak memiliki izin akses dashboard"
- USER_NOT_FOUND: "Data pengguna tidak ditemukan"

Business Rules:
- Santri: basic dashboard with personal stats
- Dewan Guru: extended dashboard with class management
- Admin: full dashboard with system management
- Token must be refreshed every 24 hours
```

### PSPEC P6.2 - Load User Profile

```
Process Name: Load User Profile Data
Input: Authenticated user ID, profile preferences
Output: Complete user profile data
Data Store: D1 Users (for profile data)
External: Firebase Storage (for profile images)

Logic:
1. Fetch user profile from database
2. Load user preferences and settings
3. Get profile image URL if exists
4. Calculate user level and progress
5. Include role-specific profile data
6. Format profile data for display
7. Return complete user profile object

Error Handling:
- PROFILE_LOAD_FAILED: "Gagal memuat profil pengguna"
- IMAGE_LOAD_FAILED: "Gagal memuat foto profil"
- DATABASE_ERROR: "Error koneksi database"

Business Rules:
- Cache profile data for 30 minutes
- Include user statistics in profile
- Show achievement badges and level
- Default avatar if no profile image
```

### PSPEC P6.3 - Load Presensi Statistics

```
Process Name: Load Attendance Statistics
Input: User ID, date range, statistics type
Output: Attendance summary and chart data
Data Store: D2 Presensi (for attendance records)
External: None

Logic:
1. Query attendance data for specified period
2. Calculate attendance rate and trends
3. Identify attendance streaks
4. Generate weekly/monthly comparisons
5. Create chart data for visualization
6. Calculate performance metrics
7. Return formatted statistics object

Error Handling:
- STATS_CALCULATION_FAILED: "Gagal menghitung statistik presensi"
- INSUFFICIENT_DATA: "Data presensi tidak mencukupi"

Business Rules:
- Show last 30 days by default
- Include streak information
- Compare with class/system average
- Highlight improvements or concerns
```

### PSPEC P6.4 - Load Kegiatan Mendatang

```
Process Name: Load Upcoming Events
Input: User ID, role, date filter, limit
Output: Upcoming events list with participation status
Data Store: D4 Jadwal (for event data)
External: None

Logic:
1. Query events starting from current date
2. Filter events by user role and permissions
3. Check user participation status for each event
4. Sort events by date and priority
5. Include event details and requirements
6. Add participation actions (join/leave)
7. Return formatted events list

Error Handling:
- EVENTS_LOAD_FAILED: "Gagal memuat kegiatan mendatang"
- PERMISSION_ERROR: "Tidak memiliki izin melihat kegiatan"

Business Rules:
- Show next 7 days by default
- Include only events user can participate in
- Show registration deadlines
- Highlight mandatory events
```

### PSPEC P6.5 - Load Pengumuman

```
Process Name: Load Recent Announcements
Input: User role, importance filter, read status
Output: Announcement list with read status
Data Store: D3 Pengumuman (for announcements)
External: None

Logic:
1. Query recent announcements (last 30 days)
2. Filter announcements by user role permissions
3. Check read status for each announcement
4. Sort by importance and date
5. Include announcement summaries
6. Add read/unread indicators
7. Return formatted announcements list

Error Handling:
- ANNOUNCEMENTS_LOAD_FAILED: "Gagal memuat pengumuman"
- READ_STATUS_ERROR: "Gagal memuat status baca"

Business Rules:
- Important announcements shown first
- Show max 10 announcements in dashboard
- Include attachment indicators
- Auto-mark as read when clicked
```

### PSPEC P6.6 - Load Notifikasi

```
Process Name: Load Recent Notifications
Input: User ID, unread filter, notification types
Output: Notification list with metadata
Data Store: D5 Notifications (for notifications)
External: None

Logic:
1. Fetch recent notifications for user
2. Filter by notification types and preferences
3. Sort by timestamp (newest first)
4. Include notification actions and links
5. Update read status for displayed notifications
6. Format notifications for display
7. Return notification list with metadata

Error Handling:
- NOTIFICATIONS_LOAD_FAILED: "Gagal memuat notifikasi"
- READ_STATUS_UPDATE_FAILED: "Gagal mengupdate status baca"

Business Rules:
- Show last 20 notifications
- Group similar notifications
- Include deep links to related content
- Auto-expire old notifications
```

### PSPEC P6.7 - Load Gamifikasi

```
Process Name: Load Gamification Data
Input: User ID, leaderboard period, achievement filters
Output: Gamification summary with points and achievements
Data Store: D6 Achievements, D7 UserAchievements, D8 Leaderboards, D9 PointHistory
External: None

Logic:
1. Get user current points and level
2. Fetch recent achievements and progress
3. Load leaderboard position and ranking
4. Calculate points earned this period
5. Show achievement progress bars
6. Include level progression information
7. Return complete gamification summary

Error Handling:
- GAMIFICATION_LOAD_FAILED: "Gagal memuat data gamifikasi"
- LEADERBOARD_ERROR: "Gagal memuat ranking"
- ACHIEVEMENT_ERROR: "Gagal memuat pencapaian"

Business Rules:
- Show current level and progress to next level
- Include recent achievements (last 7 days)
- Display current ranking position
- Show points breakdown by category
```

### PSPEC P6.8 - Aggregate & Format Data

```
Process Name: Aggregate Dashboard Data
Input: All loaded component data, user preferences
Output: Structured dashboard data ready for display
Data Store: None (aggregation only)
External: None

Logic:
1. Combine data from all dashboard components
2. Apply user customization preferences
3. Calculate cross-component statistics
4. Prioritize important information
5. Format data for efficient rendering
6. Include real-time update timestamps
7. Return structured dashboard object

Error Handling:
- AGGREGATION_FAILED: "Gagal menggabungkan data dashboard"
- FORMAT_ERROR: "Error format data"

Business Rules:
- Prioritize critical information first
- Apply user's preferred data refresh intervals
- Include data freshness indicators
- Optimize for mobile and desktop display
```

### PSPEC P6.9 - Generate Widgets

```
Process Name: Generate Dashboard Widgets
Input: Formatted dashboard data, user role, device type
Output: Dashboard widget configuration
Data Store: None (widget generation only)
External: None

Logic:
1. Determine widgets based on user role
2. Configure widget layouts for device type
3. Set widget refresh intervals
4. Apply user customization settings
5. Include interactive elements and actions
6. Set widget priorities and positioning
7. Return complete widget configuration

Error Handling:
- WIDGET_GENERATION_FAILED: "Gagal membuat widget dashboard"
- LAYOUT_ERROR: "Error konfigurasi layout"

Business Rules:
- Santri: 6 basic widgets (profile, attendance, events, announcements, achievements, notifications)
- Admin: 12+ widgets including management tools
- Responsive layout for different screen sizes
- User can customize widget order and visibility
```

### PSPEC P6.10 - Setup Real-time Listeners

```
Process Name: Setup Real-time Dashboard Updates
Input: User ID, dashboard components, connection preferences
Output: Real-time dashboard with live updates
Data Store: All relevant collections for real-time sync
External: Firebase Realtime Database, WebSocket connections

Logic:
1. Establish WebSocket connections for real-time data
2. Set up Firestore listeners for relevant collections
3. Configure update frequencies by component
4. Handle connection state management
5. Implement efficient data synchronization
6. Manage listener lifecycle and cleanup
7. Return active real-time dashboard

Error Handling:
- CONNECTION_FAILED: "Gagal koneksi real-time"
- LISTENER_ERROR: "Error listener database"
- SYNC_FAILED: "Gagal sinkronisasi data"

Business Rules:
- Update critical data (notifications) immediately
- Batch non-critical updates every 30 seconds
- Automatically reconnect on connection loss
- Limit concurrent listeners for performance
```

### PSPEC P7.1 - Detect Event Type

```
Process Name: Detect Gamification Event Type
Input: System activity (presensi, kegiatan, etc.), user context, timestamp
Output: Event type with metadata for point calculation
Data Store: None (event classification only)
External: None

Logic:
1. Analyze incoming system activity
2. Classify event type (attendance, activity_participation, achievement_unlock, etc.)
3. Extract relevant metadata (timing, duration, quality)
4. Determine event significance and rarity
5. Check for special conditions or bonuses
6. Add contextual information (streak, first-time, etc.)
7. Return classified event with calculation metadata

Error Handling:
- EVENT_CLASSIFICATION_FAILED: "Gagal mengklasifikasi event"
- INVALID_EVENT_DATA: "Data event tidak valid"
- METADATA_EXTRACTION_ERROR: "Gagal mengekstrak metadata event"

Business Rules:
- Each activity type has specific point values
- Special events get multiplier bonuses
- Consecutive activities get streak bonuses
- First-time activities get discovery bonuses
```

### PSPEC P7.2 - Calculate Points

```
Process Name: Calculate Points for Event
Input: Event type, user data, current streak, special conditions
Output: Calculated points with breakdown
Data Store: D1 Users (for user level and streak data)
External: Point Calculation Engine

Logic:
1. Get base points for event type
2. Apply user level multipliers
3. Calculate streak bonuses
4. Apply time-based bonuses (early arrival, perfect week)
5. Check for special event multipliers
6. Apply penalty deductions if applicable
7. Ensure points stay within daily/event limits
8. Return detailed point calculation

Error Handling:
- POINT_CALCULATION_ERROR: "Gagal menghitung poin"
- INVALID_MULTIPLIER: "Multiplier tidak valid"
- CALCULATION_OVERFLOW: "Perhitungan poin melebihi batas"

Business Rules:
- Base attendance points: 10 (on time), 5 (late), -5 (absent)
- Streak bonus: +2 points per consecutive day (max +20)
- Level multiplier: 1.0-1.5x based on user level
- Daily point limit: 100 points maximum
```

### PSPEC P7.3 - Record Point Transaction

```
Process Name: Record Point Transaction
Input: Calculated points, event details, user ID, transaction metadata
Output: Transaction confirmation with record ID
Data Store: D9 PointHistory (for transaction records)
External: None

Logic:
1. Create point transaction record
2. Include event details and calculation breakdown
3. Add transaction timestamp and unique ID
4. Store transaction metadata for audit
5. Link transaction to source event
6. Set transaction status (pending/completed)
7. Save to point history collection
8. Return transaction confirmation

Error Handling:
- TRANSACTION_SAVE_FAILED: "Gagal menyimpan transaksi poin"
- DUPLICATE_TRANSACTION: "Transaksi duplikat terdeteksi"
- DATABASE_ERROR: "Error database saat menyimpan"

Business Rules:
- Each transaction must have unique ID
- Include detailed audit trail
- Transactions are immutable once created
- Support both positive and negative point transactions
```

### PSPEC P7.4 - Update User Total Points

```
Process Name: Update User Total Points and Level
Input: New points, user ID, transaction reference
Output: Updated user profile with new points and level
Data Store: D1 Users (for user profile updates)
External: Level Calculation Service

Logic:
1. Fetch current user points and level
2. Add/subtract new points from total
3. Recalculate user level based on new total
4. Update user statistics (total earned, total spent)
5. Check for level progression
6. Update user profile in database
7. Trigger level change events if applicable
8. Return updated user profile

Error Handling:
- USER_UPDATE_FAILED: "Gagal mengupdate profil pengguna"
- LEVEL_CALCULATION_ERROR: "Gagal menghitung level baru"
- NEGATIVE_POINTS_ERROR: "Total poin tidak boleh negatif"

Business Rules:
- Level thresholds: L1(0-99), L2(100-299), L3(300-599), L4(600-999), L5(1000+)
- Points cannot go below zero
- Level changes trigger achievement checks
- Update user statistics atomically
```

### PSPEC P7.5 - Check Achievements

```
Process Name: Check Achievement Eligibility
Input: User activity, current achievements, updated stats
Output: List of eligible achievements to unlock
Data Store: D6 Achievements (for achievement criteria), D7 UserAchievements (for current status)
External: Achievement Engine

Logic:
1. Get all available achievements
2. Filter achievements user hasn't unlocked
3. Evaluate achievement criteria against user data
4. Check attendance-based achievements (streaks, totals)
5. Check activity-based achievements (participation, leadership)
6. Check social achievements (helping others, collaboration)
7. Return list of newly eligible achievements

Error Handling:
- ACHIEVEMENT_CHECK_FAILED: "Gagal memeriksa pencapaian"
- CRITERIA_EVALUATION_ERROR: "Error evaluasi kriteria achievement"
- DATABASE_QUERY_ERROR: "Error query database achievement"

Business Rules:
- Achievements are checked after every point transaction
- Each achievement can only be unlocked once
- Some achievements are mutually exclusive
- Special achievements require admin approval
```

### PSPEC P7.6 - Unlock Achievements

```
Process Name: Unlock User Achievements
Input: Eligible achievements, user ID, unlock context
Output: Achievement unlock confirmation with rewards
Data Store: D7 UserAchievements (for user achievement records)
External: None

Logic:
1. Process each eligible achievement
2. Create user achievement records
3. Award achievement bonus points
4. Set unlock timestamp and context
5. Calculate achievement rarity bonuses
6. Update user achievement statistics
7. Prepare achievement notification data
8. Return unlock confirmation with rewards

Error Handling:
- ACHIEVEMENT_UNLOCK_FAILED: "Gagal membuka achievement"
- BONUS_CALCULATION_ERROR: "Gagal menghitung bonus achievement"
- DUPLICATE_ACHIEVEMENT: "Achievement sudah dibuka sebelumnya"

Business Rules:
- Common achievements: +25 bonus points
- Rare achievements: +50 bonus points
- Epic achievements: +100 bonus points
- Legendary achievements: +250 bonus points
```

### PSPEC P7.7 - Update Leaderboard

```
Process Name: Update Leaderboard Rankings
Input: User points, period type (daily/weekly/monthly/all-time)
Output: Updated leaderboard positions
Data Store: D8 Leaderboards (for ranking data)
External: Ranking Calculation Service

Logic:
1. Recalculate rankings for specified period
2. Update user position in relevant leaderboards
3. Handle ties with consistent tie-breaking rules
4. Update leaderboard metadata (last updated, participant count)
5. Identify position changes for notifications
6. Optimize leaderboard data for efficient querying
7. Return updated leaderboard with changes

Error Handling:
- LEADERBOARD_UPDATE_FAILED: "Gagal mengupdate leaderboard"
- RANKING_CALCULATION_ERROR: "Error perhitungan ranking"
- CONCURRENCY_ERROR: "Konflik update leaderboard bersamaan"

Business Rules:
- Daily leaderboard resets at midnight
- Weekly leaderboard resets on Monday
- Monthly leaderboard resets on 1st of month
- All-time leaderboard never resets
- Tie-breaking: earlier achievement wins
```

### PSPEC P7.8 - Generate Notifications

```
Process Name: Generate Gamification Notifications
Input: Points earned, achievements unlocked, rank changes, user preferences
Output: Notifications for user engagement
Data Store: D5 Notifications (for notification records)
External: None

Logic:
1. Create notifications for points earned
2. Generate achievement unlock celebrations
3. Create rank change notifications
4. Add motivational messages for milestones
5. Include progress updates toward next level
6. Create challenge completion notifications
7. Format notifications with engaging content
8. Return notification batch for delivery

Error Handling:
- NOTIFICATION_GENERATION_FAILED: "Gagal membuat notifikasi gamifikasi"
- TEMPLATE_ERROR: "Error template notifikasi"
- PREFERENCE_CHECK_FAILED: "Gagal memeriksa preferensi pengguna"

Business Rules:
- Achievement notifications have high priority
- Include celebration animations and effects
- Respect user notification preferences
- Group multiple achievements in single notification
```

### PSPEC P8.1 - Validasi Permission

```
Process Name: Validate User Management Permissions
Input: Admin request, operation type, target user, requesting user permissions
Output: Permission validation result
Data Store: D1 Users (for permission checking)
External: None

Logic:
1. Verify requesting user has admin or dewan_guru role
2. Check specific operation permissions (create/read/update/delete)
3. Validate target user access rights
4. Check for self-modification restrictions
5. Verify role hierarchy permissions
6. Apply business rule constraints
7. Return permission validation result

Error Handling:
- INSUFFICIENT_PERMISSIONS: "Tidak memiliki izin untuk operasi ini"
- INVALID_OPERATION: "Operasi tidak valid"
- SELF_MODIFICATION_ERROR: "Tidak dapat mengubah role sendiri"
- HIERARCHY_VIOLATION: "Pelanggaran hierarki role"

Business Rules:
- Admin can manage all users
- Dewan Guru can only manage santri
- Users cannot modify their own role
- Cannot delete users with active dependencies
```

### PSPEC P8.2 - Validasi User Baru

```
Process Name: Validate New User Data
Input: Nama, email, role, RFID card (optional), admin permissions
Output: Validated user data or validation errors
Data Store: D1 Users (for duplicate checking)
External: Email Validation Service

Logic:
1. Validate required fields (nama, email, role)
2. Check email format and domain validity
3. Verify email uniqueness in system
4. Validate nama format and length
5. Check role validity and permissions
6. Validate RFID card format if provided
7. Check RFID card uniqueness
8. Return validated user data

Error Handling:
- MISSING_REQUIRED_FIELD: "Field wajib tidak boleh kosong"
- INVALID_EMAIL_FORMAT: "Format email tidak valid"
- EMAIL_ALREADY_EXISTS: "Email sudah terdaftar"
- INVALID_NAME_FORMAT: "Format nama tidak valid"
- INVALID_ROLE: "Role tidak valid"
- RFID_ALREADY_EXISTS: "Kartu RFID sudah terdaftar"

Business Rules:
- Email must be unique in system
- Nama must be 2-50 characters
- RFID card must be unique if provided
- Default role is 'santri' if not specified
```

### PSPEC P8.3 - Create User Account

```
Process Name: Create New User Account
Input: Validated user data, initial settings
Output: New user account with credentials
Data Store: D1 Users (for user creation)
External: Firebase Auth (for account creation)

Logic:
1. Generate temporary password for user
2. Create Firebase Auth account
3. Create user document in Firestore
4. Set initial user settings and preferences
5. Initialize user statistics (points = 0, level = 1)
6. Create default RFID mapping if provided
7. Send welcome email with credentials
8. Return created user account details

Error Handling:
- ACCOUNT_CREATION_FAILED: "Gagal membuat akun pengguna"
- EMAIL_SEND_FAILED: "Gagal mengirim email welcome"
- DATABASE_SAVE_FAILED: "Gagal menyimpan data pengguna"
- AUTH_CREATION_ERROR: "Error membuat akun Firebase"

Business Rules:
- Generate secure random password (12 characters)
- Send welcome email with login instructions
- User must change password on first login
- Initialize with default notification preferences
```

### PSPEC P8.4 - Load User Data

```
Process Name: Load User Data for Editing
Input: User ID to edit, requesting admin permissions
Output: Editable user data with metadata
Data Store: D1 Users (for user data)
External: None

Logic:
1. Validate edit permissions for target user
2. Fetch complete user profile data
3. Include user statistics and activity summary
4. Get user preferences and settings
5. Include role change history if admin
6. Add modification timestamps and audit info
7. Return complete editable user data

Error Handling:
- USER_NOT_FOUND: "Pengguna tidak ditemukan"
- PERMISSION_DENIED: "Tidak memiliki izin edit pengguna ini"
- DATA_LOAD_FAILED: "Gagal memuat data pengguna"

Business Rules:
- Include audit trail for admin users
- Mask sensitive information based on permissions
- Show read-only fields clearly
- Include user activity summary
```

### PSPEC P8.5 - Update User Profile

```
Process Name: Update User Profile Data
Input: Modified user data, change tracking, admin permissions
Output: Updated user profile confirmation
Data Store: D1 Users (for profile updates)
External: Firebase Auth (for auth updates)

Logic:
1. Compare changes against current data
2. Validate all modified fields
3. Handle role changes with proper workflow
4. Update Firebase Auth profile if needed
5. Update user document in Firestore
6. Create audit log entry for changes
7. Send notification to user about changes
8. Return update confirmation

Error Handling:
- UPDATE_VALIDATION_FAILED: "Validasi update gagal"
- ROLE_CHANGE_ERROR: "Gagal mengubah role pengguna"
- DATABASE_UPDATE_FAILED: "Gagal mengupdate database"
- AUDIT_LOG_FAILED: "Gagal mencatat perubahan"

Business Rules:
- Role changes require additional confirmation
- Email changes require verification
- Track all profile modifications
- Notify user of significant changes
```

### PSPEC P8.6 - Confirm Delete

```
Process Name: Confirm User Deletion
Input: User ID to delete, confirmation flag, deletion reason
Output: Delete confirmation result with dependencies
Data Store: D1 Users, D2 Presensi, D3 Pengumuman, D4 Jadwal (for dependency checking)
External: None

Logic:
1. Check user deletion permissions
2. Validate user exists and is deletable
3. Check for active dependencies (created content, participations)
4. Calculate impact of deletion
5. Require explicit confirmation for cascading deletes
6. Prepare deletion summary and warnings
7. Return confirmation result with impact analysis

Error Handling:
- USER_NOT_DELETABLE: "Pengguna tidak dapat dihapus"
- ACTIVE_DEPENDENCIES: "Pengguna memiliki data aktif terkait"
- PERMISSION_DENIED: "Tidak memiliki izin hapus pengguna"
- SELF_DELETE_ERROR: "Tidak dapat menghapus akun sendiri"

Business Rules:
- Cannot delete users with active content
- Require reason for user deletion
- Cannot delete last admin user
- Show full impact before deletion
```

### PSPEC P8.7 - Soft Delete User

```
Process Name: Soft Delete User Account
Input: Confirmed user ID, deletion reason, admin ID
Output: User deactivation confirmation
Data Store: D1 Users (for status updates)
External: Firebase Auth (for account disabling)

Logic:
1. Disable Firebase Auth account
2. Set user status to 'inactive'
3. Remove user from active participant lists
4. Preserve user data for audit purposes
5. Create deletion audit log entry
6. Send account deactivation notification
7. Update user statistics and reports
8. Return deactivation confirmation

Error Handling:
- DEACTIVATION_FAILED: "Gagal menonaktifkan akun"
- AUTH_DISABLE_ERROR: "Gagal disable akun Firebase"
- AUDIT_LOG_FAILED: "Gagal mencatat penghapusan"

Business Rules:
- Soft delete preserves data for audit
- User cannot login after deactivation
- Data remains for reporting purposes
- Can be reactivated by admin if needed
```

### PSPEC P8.8 - Query User List

```
Process Name: Query User List with Filters
Input: Filter criteria, pagination, sorting, admin permissions
Output: Paginated user list with metadata
Data Store: D1 Users (for user data)
External: None

Logic:
1. Apply role-based access filters
2. Process search and filter criteria
3. Apply sorting preferences
4. Implement pagination for large datasets
5. Include user statistics and status
6. Format user data for list display
7. Add user management actions based on permissions
8. Return paginated user list with metadata

Error Handling:
- QUERY_FAILED: "Gagal mengambil daftar pengguna"
- INVALID_FILTER: "Filter tidak valid"
- PAGINATION_ERROR: "Error paginasi data"

Business Rules:
- Show users based on admin role permissions
- Include user activity indicators
- Support search by name, email, role
- Default sort by name ascending
```

### PSPEC P8.9 - Log User Activity

```
Process Name: Log User Management Activity
Input: Operation type, admin ID, target user, timestamp, details
Output: Audit log confirmation
Data Store: System Logs (for audit records)
External: None

Logic:
1. Create detailed audit log entry
2. Include operation type and parameters
3. Record admin user performing action
4. Include target user information
5. Add timestamp and IP address
6. Store operation result and any errors
7. Return audit log confirmation

Error Handling:
- AUDIT_LOG_FAILED: "Gagal mencatat audit log"
- LOG_STORAGE_ERROR: "Error penyimpanan log"

Business Rules:
- All user management operations must be logged
- Logs are immutable once created
- Include sufficient detail for compliance
- Retain logs for minimum 2 years
```

### PSPEC P8.10 - Send User Notification

```
Process Name: Send User Management Notifications
Input: Operation result, user data, notification type, admin info
Output: Notification delivery confirmation
Data Store: D5 Notifications (for notification records)
External: Email Service, FCM Service

Logic:
1. Determine appropriate notification channels
2. Create personalized notification content
3. Include relevant operation details
4. Send email notifications for account changes
5. Send push notifications for updates
6. Create in-app notification records
7. Return delivery confirmation

Error Handling:
- NOTIFICATION_SEND_FAILED: "Gagal mengirim notifikasi"
- EMAIL_DELIVERY_ERROR: "Gagal mengirim email"
- PUSH_NOTIFICATION_ERROR: "Gagal mengirim push notification"

Business Rules:
- Account creation sends welcome email
- Profile changes send update notification
- Account deactivation sends final notification
- Include contact information for support
```

### PSPEC P9.1 - Detect Event Type

```
Process Name: Detect Notification Event Type
Input: System event (presensi, pengumuman, achievement, etc.), event metadata
Output: Event type with notification metadata
Data Store: None (event classification only)
External: None

Logic:
1. Analyze incoming system event
2. Classify event into notification categories
3. Determine notification priority level
4. Extract relevant event metadata
5. Identify target audience scope
6. Set notification timing preferences
7. Return classified event with notification config

Error Handling:
- EVENT_CLASSIFICATION_ERROR: "Gagal mengklasifikasi event"
- INVALID_EVENT_DATA: "Data event tidak valid"
- METADATA_EXTRACTION_FAILED: "Gagal mengekstrak metadata"

Business Rules:
- Critical events (emergency) get immediate notification
- Important events (announcements) get high priority
- Routine events (attendance) get normal priority
- Social events (achievements) can be batched
```

### PSPEC P9.2 - Get Target Recipients

```
Process Name: Get Notification Target Recipients
Input: Event type, scope, role filters, notification preferences
Output: Filtered recipient list with delivery preferences
Data Store: D1 Users (for user data and preferences)
External: None

Logic:
1. Determine notification scope (global, role-based, individual)
2. Query users based on scope criteria
3. Apply user notification preferences
4. Filter by active status and opt-in settings
5. Check quiet hours and do-not-disturb settings
6. Get user device tokens and contact methods
7. Return filtered recipient list with preferences

Error Handling:
- RECIPIENT_QUERY_FAILED: "Gagal mengambil daftar penerima"
- PREFERENCE_CHECK_ERROR: "Error memeriksa preferensi notifikasi"
- TOKEN_RETRIEVAL_FAILED: "Gagal mengambil token perangkat"

Business Rules:
- Respect user notification preferences
- Apply quiet hours (22:00-06:00) for non-critical notifications
- Include only users with valid device tokens
- Maximum 1000 recipients per notification batch
```

### PSPEC P9.3 - Generate Message

```
Process Name: Generate Notification Message
Input: Event data, notification template, recipient info, localization settings
Output: Formatted notification message
Data Store: None (message generation only)
External: Template Engine, Localization Service

Logic:
1. Select appropriate notification template
2. Personalize message content for recipient
3. Apply localization and language preferences
4. Include relevant event details and context
5. Add call-to-action buttons if needed
6. Format message for different channels (push, email, in-app)
7. Return formatted notification message

Error Handling:
- TEMPLATE_NOT_FOUND: "Template notifikasi tidak ditemukan"
- PERSONALIZATION_ERROR: "Gagal personalisasi pesan"
- LOCALIZATION_FAILED: "Gagal lokalisasi pesan"
- MESSAGE_FORMAT_ERROR: "Error format pesan"

Business Rules:
- Messages must be under 100 characters for push notifications
- Include deep links for relevant actions
- Use Indonesian language by default
- Include sender identification
```

### PSPEC P9.4 - Apply User Preferences

```
Process Name: Apply User Notification Preferences
Input: Notification message, recipient preferences, delivery channels
Output: Preference-filtered notifications
Data Store: None (filtering only)
External: None

Logic:
1. Check user's notification channel preferences
2. Apply category-specific settings (announcements, reminders, social)
3. Check delivery time preferences and quiet hours
4. Apply frequency limits and batching preferences
5. Filter by notification importance vs user threshold
6. Respect global do-not-disturb settings
7. Return filtered notifications ready for delivery

Error Handling:
- PREFERENCE_APPLICATION_ERROR: "Gagal menerapkan preferensi"
- INVALID_PREFERENCE_DATA: "Data preferensi tidak valid"
- FILTER_LOGIC_ERROR: "Error logika filter notifikasi"

Business Rules:
- Critical notifications override user preferences
- Quiet hours: 22:00-06:00 (configurable per user)
- Maximum 10 notifications per user per day (non-critical)
- Batch similar notifications to reduce spam
```

### PSPEC P9.5 - Save Notification

```
Process Name: Save Notification Records
Input: Final notification data, recipient list, delivery schedule
Output: Notification IDs and save confirmation
Data Store: D5 Notifications (for notification records)
External: None

Logic:
1. Create notification records for each recipient
2. Generate unique notification IDs
3. Set initial delivery status (pending)
4. Include notification metadata and tracking info
5. Set delivery scheduling information
6. Create batch tracking for grouped notifications
7. Return notification IDs and save confirmation

Error Handling:
- NOTIFICATION_SAVE_FAILED: "Gagal menyimpan notifikasi"
- ID_GENERATION_ERROR: "Gagal generate ID notifikasi"
- BATCH_CREATION_FAILED: "Gagal membuat batch notifikasi"

Business Rules:
- Each notification must have unique ID
- Include creation timestamp and expiry
- Track notification lifecycle states
- Enable notification analytics and reporting
```

### PSPEC P9.6 - Send Push Notification

```
Process Name: Send Push Notifications
Input: Notification data, FCM tokens, delivery priority
Output: Push delivery confirmation and status
Data Store: D5 Notifications (for delivery status updates)
External: Firebase Cloud Messaging (FCM)

Logic:
1. Format notification payload for FCM
2. Include notification data and custom parameters
3. Set appropriate priority and TTL
4. Send notifications via FCM service
5. Handle delivery responses and errors
6. Update notification delivery status
7. Retry failed deliveries according to policy
8. Return delivery confirmation with statistics

Error Handling:
- FCM_DELIVERY_FAILED: "Gagal mengirim push notification"
- INVALID_TOKEN: "Token FCM tidak valid"
- QUOTA_EXCEEDED: "Kuota FCM terlampaui"
- PAYLOAD_TOO_LARGE: "Payload notifikasi terlalu besar"

Business Rules:
- High priority for critical notifications
- Normal priority for routine notifications
- TTL: 24 hours for push notifications
- Retry failed deliveries up to 3 times
```

### PSPEC P9.7 - Send Email Notification

```
Process Name: Send Email Notifications
Input: Notification data, email addresses, email template
Output: Email delivery confirmation
Data Store: D5 Notifications (for delivery tracking)
External: Email Service Provider (SendGrid/SMTP)

Logic:
1. Format notification content for email
2. Apply HTML email template with branding
3. Include unsubscribe links and preferences
4. Set appropriate email headers and metadata
5. Send via email service provider
6. Handle delivery confirmations and bounces
7. Update email delivery status
8. Return email delivery confirmation

Error Handling:
- EMAIL_SEND_FAILED: "Gagal mengirim email"
- TEMPLATE_RENDER_ERROR: "Error render template email"
- INVALID_EMAIL_ADDRESS: "Alamat email tidak valid"
- SMTP_CONNECTION_ERROR: "Gagal koneksi email server"

Business Rules:
- Include institution branding in email template
- Provide easy unsubscribe mechanism
- Track email open and click rates
- Respect email sending limits
```

### PSPEC P9.8 - Send In-App Notification

```
Process Name: Send In-App Notifications
Input: Notification data, active user sessions, real-time channels
Output: In-app delivery confirmation
Data Store: D5 Notifications (for notification display)
External: WebSocket Service, Real-time Database

Logic:
1. Identify active user sessions
2. Format notification for in-app display
3. Send via real-time WebSocket connections
4. Display notification in app notification center
5. Handle user interactions (read, dismiss, action)
6. Update notification read status
7. Return in-app delivery confirmation

Error Handling:
- WEBSOCKET_SEND_FAILED: "Gagal mengirim notifikasi real-time"
- SESSION_NOT_FOUND: "Sesi pengguna tidak aktif"
- DISPLAY_ERROR: "Error tampil notifikasi in-app"

Business Rules:
- Show notifications immediately for active users
- Store in notification center for offline users
- Auto-mark as delivered when displayed
- Support rich notifications with actions
```

### PSPEC P9.9 - Send SMS (Optional)

```
Process Name: Send SMS Notifications
Input: Critical notifications, phone numbers, SMS gateway config
Output: SMS delivery confirmation
Data Store: D5 Notifications (for SMS tracking)
External: SMS Gateway Service

Logic:
1. Validate phone numbers for SMS delivery
2. Format notification content for SMS (160 chars max)
3. Check SMS sending quotas and limits
4. Send via SMS gateway service
5. Handle delivery confirmations
6. Update SMS delivery status
7. Return SMS delivery confirmation

Error Handling:
- SMS_SEND_FAILED: "Gagal mengirim SMS"
- INVALID_PHONE_NUMBER: "Nomor telepon tidak valid"
- SMS_QUOTA_EXCEEDED: "Kuota SMS terlampaui"
- GATEWAY_ERROR: "Error SMS gateway"

Business Rules:
- SMS only for critical/emergency notifications
- Maximum 160 characters per SMS
- Include opt-out instructions
- Track SMS costs and usage
```

### PSPEC P9.10 - Track Delivery Status

```
Process Name: Track Notification Delivery Status
Input: Delivery confirmations from all channels, notification IDs
Output: Comprehensive delivery report
Data Store: D5 Notifications (for status updates)
External: None

Logic:
1. Aggregate delivery status from all channels
2. Update notification records with delivery results
3. Track delivery times and success rates
4. Identify failed deliveries for retry
5. Generate delivery analytics and reports
6. Update user engagement metrics
7. Return comprehensive delivery status report

Error Handling:
- STATUS_UPDATE_FAILED: "Gagal update status pengiriman"
- ANALYTICS_ERROR: "Error tracking analytics"
- REPORT_GENERATION_FAILED: "Gagal generate laporan pengiriman"

Business Rules:
- Track delivery status for all notification channels
- Generate daily delivery reports
- Identify and fix delivery issues proactively
- Measure notification engagement rates
```

### PSPEC P9.11 - Update Read Status

```
Process Name: Update Notification Read Status
Input: User interaction, notification ID, interaction type
Output: Read status update confirmation
Data Store: D5 Notifications (for read status tracking)
External: None

Logic:
1. Validate user permissions for notification
2. Update notification read status and timestamp
3. Track user interaction type (read, clicked, dismissed)
4. Update user notification statistics
5. Trigger follow-up actions if configured
6. Generate user engagement analytics
7. Return read status update confirmation

Error Handling:
- READ_STATUS_UPDATE_FAILED: "Gagal update status baca"
- INVALID_NOTIFICATION_ID: "ID notifikasi tidak valid"
- PERMISSION_DENIED: "Tidak memiliki izin akses notifikasi"

Business Rules:
- Mark as read when user views notification
- Track click-through rates for actionable notifications
- Update user engagement scores
- Clean up old read notifications automatically
```

### 3.5.1 Use Case Diagram

**Aktor: Santri**

- Login/Logout
- Lihat Dashboard
- Presensi RFID
- Lihat Jadwal
- Lihat Pengumuman
- Edit Profil

**Aktor: Admin**

- Semua use case Santri
- Kelola Pengguna
- Kelola Pengumuman
- Kelola Jadwal
- Presensi Manual
- Lihat Laporan
- Export Data

**Aktor: Dewan Guru**

- Semua use case Santri
- Dashboard Monitoring
- Approve/Disapprove
- Lihat Statistik

### 3.5.2 Activity Diagram - Proses Login

```
Start
  ↓
[Input Google Account]
  ↓
[Google Auth]
  ↓
Decision{Auth Success?}
  ├─No──→ [Determine Error Type]
  │        ├─Network Error──→ [Show "Tidak ada koneksi internet"]
  │        ├─Cancelled──────→ [Show "Login dibatalkan"]
  │        ├─Invalid Cred───→ [Show "Kredensial tidak valid"]
  │        ├─User Disabled──→ [Show "Akun dinonaktifkan"]
  │        └─Other Error────→ [Show "Gagal login dengan Google"]
  │                           ↓
  │                     [Back to Input] ──→ [Input Google Account]
  │
  └─Yes─→ [Get User Profile]
           ↓
         [Check User in Database]
           ↓
         Decision{User Exists?}
           ├─No──→ [Show "Pengguna tidak terdaftar"]
           │        ↓
           │     [Contact Admin] ──→ End
           │
           └─Yes─→ [Check Role & Status]
                    ↓
                  Decision{Role Valid & Active?}
                    ├─No──→ [Determine Access Error]
                    │        ├─Inactive──→ [Show "Akun dinonaktifkan"]
                    │        ├─Invalid Role──→ [Show "Role tidak valid"]
                    │        ├─Pending──→ [Show "Menunggu persetujuan"]
                    │        └─Access Denied──→ [Show "Akses ditolak"]
                    │                           ↓
                    │                        [End]
                    │
                    └─Yes─→ [Load Dashboard]
                             ↓
                           [Initialize Providers]
                             ↓
                           [Show Main App]
                             ↓
                            End
```

### 3.5.3 Activity Diagram - Proses Presensi RFID

```
Start
  ↓
[Santri mendekatkan kartu RFID]
  ↓
[NFC Reader membaca kartu]
  ↓
Decision{Kartu terdeteksi?}
  ├─No──→ [Show "Kartu tidak terdeteksi"]
  │        ↓
  │     [Instruksi posisikan ulang kartu] ──→ [Santri mendekatkan kartu RFID]
  │
  └─Yes─→ [Validasi format RFID]
           ↓
         Decision{Format valid?}
           ├─No──→ [Show "Format kartu tidak valid"]
           │        ↓
           │     [Contact Admin] ──→ End
           │
           └─Yes─→ [Cek kartu di database]
                    ↓
                  Decision{Kartu terdaftar?}
                    ├─No──→ [Show "Kartu tidak terdaftar"]
                    │        ↓
                    │     [Contact Admin] ──→ End
                    │
                    └─Yes─→ [Cek status pengguna]
                             ↓
                           Decision{User aktif?}
                             ├─No──→ [Show "Akun tidak aktif"]
                             │        ↓
                             │     [Contact Admin] ──→ End
                             │
                             └─Yes─→ [Cek presensi hari ini]
                                      ↓
                                    Decision{Sudah presensi?}
                                      ├─Yes──→ [Show "Sudah presensi hari ini"]
                                      │         ↓
                                      │       [Tampilkan status] ──→ End
                                      │
                                      └─No─→ [Tentukan status berdasarkan waktu]
                                              ├─Sebelum 08:00 ──→ [Status: Hadir]
                                              ├─08:00-10:00 ────→ [Status: Terlambat]
                                              └─Setelah 10:00 ──→ [Status: Alpha]
                                                       ↓
                                                     [Simpan record presensi]
                                                       ↓
                                                     [Update poin user]
                                                       ↓
                                                     [Kirim notifikasi]
                                                       ↓
                                                     [Show "Presensi berhasil"]
                                                       ↓
                                                      End
```

### 3.5.4 Activity Diagram - Kelola Pengumuman (Admin)

```
Start
  ↓
[Admin pilih "Kelola Pengumuman"]
  ↓
[Tampilkan daftar pengumuman]
  ↓
Decision{Pilih aksi}
  ├─Tambah──→ [Form pengumuman baru]
  │            ↓
  │          [Input judul, isi, tanggal]
  │            ↓
  │          Decision{Pengumuman penting?}
  │            ├─Yes──→ [Set flag isPenting = true]
  │            └─No───→ [Set flag isPenting = false]
  │                      ↓
  │                    [Validasi input]
  │                      ↓
  │                    Decision{Input valid?}
  │                      ├─No──→ [Show error message] ──→ [Form pengumuman baru]
  │                      └─Yes─→ [Simpan ke database]
  │                              ↓
  │                            [Kirim notifikasi ke users]
  │                              ↓
  │                            [Show "Pengumuman berhasil dibuat"]
  │                              ↓
  │                            [Kembali ke daftar] ──→ [Tampilkan daftar pengumuman]
  │
  ├─Edit────→ [Pilih pengumuman dari daftar]
  │            ↓
  │          [Load data pengumuman]
  │            ↓
  │          [Form edit dengan data existing]
  │            ↓
  │          [Modify judul/isi/tanggal/flag penting]
  │            ↓
  │          [Validasi input]
  │            ↓
  │          Decision{Input valid?}
  │            ├─No──→ [Show error message] ──→ [Form edit dengan data existing]
  │            └─Yes─→ [Update database]
  │                    ↓
  │                  [Show "Pengumuman berhasil diupdate"]
  │                    ↓
  │                  [Kembali ke daftar] ──→ [Tampilkan daftar pengumuman]
  │
  └─Hapus───→ [Pilih pengumuman dari daftar]
               ↓
             [Konfirmasi hapus]
               ↓
             Decision{Yakin hapus?}
               ├─No──→ [Cancel] ──→ [Tampilkan daftar pengumuman]
               └─Yes─→ [Hapus dari database]
                       ↓
                     [Show "Pengumuman berhasil dihapus"]
                       ↓
                     [Refresh daftar] ──→ [Tampilkan daftar pengumuman]
                       ↓
                      End
```

### 3.5.5 Activity Diagram - Export Laporan Presensi

```
Start
  ↓
[Admin pilih "Laporan Presensi"]
  ↓
[Tampilkan filter options]
  ↓
[Set filter periode]
  ├─Tanggal mulai
  ├─Tanggal akhir
  ├─User tertentu (optional)
  └─Status presensi (optional)
  ↓
[Apply filter]
  ↓
[Query database dengan filter]
  ↓
Decision{Data ditemukan?}
  ├─No──→ [Show "Tidak ada data presensi"]
  │        ↓
  │      [Kembali ke filter] ──→ [Tampilkan filter options]
  │
  └─Yes─→ [Tampilkan preview laporan]
           ↓
         [Admin pilih format export]
         Decision{Format}
           ├─Excel──→ [Generate Excel file]
           │          ├─Create workbook
           │          ├─Add headers
           │          ├─Add data rows
           │          ├─Format cells
           │          └─Apply styling
           │            ↓
           │          [Request storage permission]
           │            ↓
           │          Decision{Permission granted?}
           │            ├─No──→ [Show permission error]
           │            │       ↓
           │            │     [Request again] ──→ [Request storage permission]
           │            │
           │            └─Yes─→ [Save file to Downloads]
           │                    ↓
           │                  Decision{Save success?}
           │                    ├─No──→ [Show "Gagal menyimpan file"]
           │                    │       ↓
           │                    │     [Retry] ──→ [Save file to Downloads]
           │                    │
           │                    └─Yes─→ [Show "File berhasil disimpan"]
           │                            ↓
           │                          [Option: Buka file]
           │                            ↓
           │                          Decision{Buka file?}
           │                            ├─Yes──→ [Open Excel app]
           │                            └─No───→ End
           │
           └─PDF────→ [Generate PDF file]
                      ├─Create PDF document
                      ├─Add header & title
                      ├─Add table with data
                      ├─Add summary statistics
                      └─Add footer
                        ↓
                      [Save PDF to Downloads]
                        ↓
                      [Show "PDF berhasil disimpan"]
                        ↓
                       End
```

### 3.5.6 Activity Diagram - Registrasi User Baru (Admin)

```
Start
  ↓
[Admin pilih "Tambah User"]
  ↓
[Form registrasi user baru]
  ↓
[Input data user]
  ├─Nama lengkap
  ├─Email
  ├─Role (Santri/Admin/Dewan Guru)
  ├─RFID Card ID (optional)
  └─Upload foto profil (optional)
  ↓
[Validasi input]
  ↓
Decision{Semua field required terisi?}
  ├─No──→ [Highlight missing fields]
  │        ↓
  │      [Show "Lengkapi data yang diperlukan"] ──→ [Form registrasi user baru]
  │
  └─Yes─→ [Validasi format email]
           ↓
         Decision{Email valid?}
           ├─No──→ [Show "Format email tidak valid"] ──→ [Form registrasi user baru]
           │
           └─Yes─→ [Cek email sudah terdaftar]
                    ↓
                  Decision{Email sudah ada?}
                    ├─Yes──→ [Show "Email sudah terdaftar"]
                    │         ↓
                    │       [Suggest different email] ──→ [Form registrasi user baru]
                    │
                    └─No─→ [Cek RFID card (jika diisi)]
                            ↓
                          Decision{RFID diisi?}
                            ├─No──→ [Skip RFID validation]
                            │
                            └─Yes─→ [Cek RFID sudah terdaftar]
                                     ↓
                                   Decision{RFID sudah ada?}
                                     ├─Yes──→ [Show "RFID sudah terdaftar"]
                                     │         ↓
                                     │       [Suggest different RFID] ──→ [Form registrasi user baru]
                                     │
                                     └─No─→ [Validasi selesai]
                                             ↓
                                           [Simpan user ke database]
                                             ↓
                                           Decision{Save berhasil?}
                                             ├─No──→ [Show "Gagal menyimpan user"]
                                             │        ↓
                                             │      [Log error] ──→ End
                                             │
                                             └─Yes─→ [Send welcome email]
                                                      ↓
                                                    [Update user count statistics]
                                                      ↓
                                                    [Show "User berhasil ditambahkan"]
                                                      ↓
                                                    Decision{Tambah user lagi?}
                                                      ├─Yes──→ [Clear form] ──→ [Form registrasi user baru]
                                                      └─No───→ [Kembali ke user list]
                                                                ↓
                                                               End
```

### 3.5.7 Activity Diagram - Loading Dashboard

```
Start
  ↓
[User berhasil login]
  ↓
[Initialize Dashboard Providers]
  ↓
[Show loading screen]
  ↓
Parallel{Load multiple data sources}
  ├─[Load User Profile]
  │  ├─Query Firebase users collection
  │  ├─Filter by current user ID
  │  └─Return user data
  │
  ├─[Load Today's Presensi]
  │  ├─Query Firebase presensi collection
  │  ├─Filter by user ID and today's date
  │  └─Return presensi status
  │
  ├─[Load Upcoming Kegiatan]
  │  ├─Query Firebase jadwal collection
  │  ├─Filter by date >= today
  │  ├─Order by date ascending
  │  └─Take first 3 items
  │
  ├─[Load Recent Pengumuman]
  │  ├─Query Firebase pengumuman collection
  │  ├─Filter by active = true
  │  ├─Order by date descending
  │  └─Take first 3 items
  │
  └─[Load User Statistics]
     ├─Calculate weekly attendance
     ├─Calculate monthly attendance
     ├─Calculate total points
     └─Return statistics map
End Parallel
  ↓
Decision{All data loaded successfully?}
  ├─No──→ [Check which data failed]
  │        ├─Critical data failed ──→ [Show error message]
  │        │                          ↓
  │        │                        [Offer retry] ──→ Decision{User retry?}
  │        │                                           ├─Yes──→ [Initialize Dashboard Providers]
  │        │                                           └─No───→ [Show minimal dashboard]
  │        │                                                    ↓
  │        │                                                   End
  │        │
  │        └─Non-critical failed ───→ [Load with placeholder data]
  │                                   ↓
  │                                 [Show partial dashboard]
  │                                   ↓
  │                                 [Background retry failed data]
  │                                   ↓
  │                                  End
  │
  └─Yes─→ [Combine all data]
           ↓
         [Build dashboard widgets]
           ├─Welcome card with user info
           ├─Notification section
           ├─Stats cards (presensi, points)
           ├─Additional stats (weekly/monthly)
           ├─Upcoming kegiatan list
           └─Recent pengumuman list
           ↓
         [Hide loading screen]
           ↓
         [Show complete dashboard]
           ↓
         [Initialize real-time listeners]
           ├─Listen to user changes
           ├─Listen to new notifications
           ├─Listen to presensi updates
           └─Listen to new pengumuman
           ↓
         [Dashboard ready for interaction]
           ↓
          End
```

### 3.5.8 Activity Diagram - Sistem Gamifikasi (Poin & Achievement)

```
Start (Trigger Event)
  ↓
Decision{Jenis Event}
  ├─Presensi Hadir─────→ [Calculate attendance points]
  │                      ├─Base points: +10
  │                      ├─Bonus perfect week: +5
  │                      ├─Bonus early arrival: +3
  │                      └─Bonus streak: +2 per streak
  │                        ↓
  │                      [Update user points]
  │                        ↓
  │                      [Check attendance achievements]
  │                        ├─Perfect Week (7 days)
  │                        ├─Perfect Month (30 days)
  │                        ├─Early Bird (>10x before 7:30)
  │                        ├─Streak Master (15 days streak)
  │                        └─Attendance King (100 days)
  │
  ├─Presensi Terlambat──→ [Calculate late points]
  │                        ├─Base points: +5
  │                        ├─Penalty: No bonus
  │                        └─Break streak
  │                          ↓
  │                        [Update user points]
  │                          ↓
  │                        [Reset streak counter]
  │
  ├─Alpha/Tidak Hadir───→ [Apply penalties]
  │                        ├─Points deduction: -5
  │                        ├─Break streak
  │                        └─Reset weekly bonus
  │                          ↓
  │                        [Update user points]
  │                          ↓
  │                        [Check negative achievements]
  │                          ├─Late Starter (>5x alpha in month)
  │                          └─Needs Improvement (streak broken >3x)
  │
  ├─Kegiatan Participation→ [Calculate activity points]
  │                         ├─Join event: +15
  │                         ├─Event completion: +20
  │                         ├─Event organizer: +30
  │                         └─Event winner: +50
  │                           ↓
  │                         [Update user points]
  │                           ↓
  │                         [Check activity achievements]
  │                           ├─Event Enthusiast (join 10 events)
  │                           ├─Active Participant (complete 20 events)
  │                           ├─Event Organizer (organize 5 events)
  │                           └─Event Champion (win 3 events)
  │
  ├─Baca Pengumuman─────→ [Calculate engagement points]
  │                       ├─Read announcement: +1
  │                       ├─Important announcement: +2
  │                       └─Share announcement: +3
  │                         ↓
  │                       [Update user points]
  │                         ↓
  │                       [Check engagement achievements]
  │                         ├─News Reader (read 50 announcements)
  │                         ├─Info Seeker (read all important news)
  │                         └─Community Sharer (share 20 announcements)
  │
  └─Weekly/Monthly Review→ [Calculate period bonus]
                           ├─Weekly perfect: +25
                           ├─Monthly perfect: +100
                           ├─Top 3 weekly: +15
                           └─Top 3 monthly: +75
                             ↓
                           [Update user points]
                             ↓
                           [Check leaderboard achievements]
                             ├─Weekly Champion (1st place weekly)
                             ├─Monthly Champion (1st place monthly)
                             ├─Consistent Performer (top 10 for 3 months)
                             └─Rising Star (biggest improvement)
End Decision
  ↓
[Calculate total points earned]
  ↓
[Update user profile with new points]
  ↓
[Update user level based on points]
  ├─Level 1: 0-99 points (Pemula)
  ├─Level 2: 100-299 points (Rajin)
  ├─Level 3: 300-599 points (Berprestasi)
  ├─Level 4: 600-999 points (Teladan)
  └─Level 5: 1000+ points (Master)
  ↓
Decision{Level naik?}
  ├─Yes──→ [Trigger level up celebration]
  │         ├─Show congratulations popup
  │         ├─Play level up animation
  │         ├─Send notification
  │         └─Award level up badge
  │           ↓
  │         [Check for new achievement unlocks]
  │
  └─No───→ [Check for new achievements]
            ↓
          Decision{New achievement earned?}
            ├─Yes──→ [Trigger achievement notification]
            │         ├─Show achievement popup
            │         ├─Play achievement sound
            │         ├─Add badge to profile
            │         ├─Send push notification
            │         └─Share option to social
            │           ↓
            │         [Update achievement progress]
            │           ├─Save achievement to user profile
            │           ├─Update achievement stats
            │           └─Log achievement event
            │             ↓
            │           [Check for achievement combo]
            │             ├─Multiple achievements → Bonus +20 points
            │             └─Rare achievement → Special badge
            │
            └─No───→ [Update leaderboard]
                      ├─Daily leaderboard
                      ├─Weekly leaderboard
                      ├─Monthly leaderboard
                      └─All-time leaderboard
                        ↓
                      [Send ranking update notification]
                        ├─Rank improved → Congratulations
                        ├─Top 10 → Special mention
                        └─Top 3 → Champion notification
                        ↓
                      [Update user dashboard]
                        ├─Display new points
                        ├─Show current level
                        ├─Display achievements
                        ├─Show leaderboard rank
                        └─Display progress bars
                        ↓
                      [Log gamification event]
                        ├─Event type
                        ├─Points earned
                        ├─Achievement unlocked
                        ├─Level change
                        └─Timestamp
                        ↓
                       End
```

### 3.5.9 Activity Diagram - Achievement System Detail

```
Start (Achievement Check Triggered)
  ↓
[Get user's current achievements]
  ↓
[Get user's activity history]
  ↓
[Check all achievement criteria]
  ↓
Parallel{Evaluate Achievement Categories}
  ├─[Attendance Achievements]
  │  ├─Perfect Week: 7 consecutive days hadir
  │  ├─Perfect Month: 30 days hadir in month
  │  ├─Early Bird: 10+ presensi before 7:30 AM
  │  ├─Streak Master: 15+ consecutive days
  │  ├─Attendance King: 100+ total attendance
  │  ├─Never Late: 30 days without terlambat
  │  └─Punctuality Expert: 50+ on-time arrivals
  │
  ├─[Activity Achievements]
  │  ├─Event Enthusiast: Join 10+ events
  │  ├─Active Participant: Complete 20+ events
  │  ├─Event Organizer: Organize 5+ events
  │  ├─Event Champion: Win 3+ competitions
  │  ├─Social Butterfly: Participate in all event types
  │  └─Community Leader: Help organize major events
  │
  ├─[Learning Achievements]
  │  ├─News Reader: Read 50+ announcements
  │  ├─Info Seeker: Read all important announcements
  │  ├─Knowledge Seeker: Perfect quiz scores
  │  ├─Study Group Leader: Lead study sessions
  │  └─Academic Excellence: High performance metrics
  │
  ├─[Social Achievements]
  │  ├─Community Sharer: Share 20+ announcements
  │  ├─Helpful Friend: Help other users
  │  ├─Mentor: Guide new users
  │  ├─Team Player: Group activity participation
  │  └─Popular Member: High interaction rates
  │
  ├─[Leadership Achievements]
  │  ├─Weekly Champion: #1 in weekly leaderboard
  │  ├─Monthly Champion: #1 in monthly leaderboard
  │  ├─Consistent Performer: Top 10 for 3+ months
  │  ├─Rising Star: Biggest monthly improvement
  │  ├─Elite Member: Top 1% all-time
  │  └─Legend: Hold multiple champion titles
  │
  └─[Special Achievements]
     ├─First Day: Complete first presensi
     ├─Welcome: Complete profile setup
     ├─Explorer: Use all app features
     ├─Milestone: Reach point milestones
     ├─Anniversary: App usage anniversaries
     └─Rare Events: Special occasion participation
End Parallel
  ↓
[Combine all achievement results]
  ↓
Decision{New achievements found?}
  ├─No───→ [Update achievement progress bars]
  │         ├─Show current progress
  │         ├─Show next milestone
  │         └─Motivational message
  │           ↓
  │         End
  │
  └─Yes──→ [Sort achievements by rarity]
           ├─Common: Standard achievements
           ├─Rare: Difficult achievements
           ├─Epic: Very challenging achievements
           └─Legendary: Extremely rare achievements
           ↓
         [Calculate achievement rewards]
           ├─Common: +10 points
           ├─Rare: +25 points
           ├─Epic: +50 points
           └─Legendary: +100 points
           ↓
         [Create achievement notifications]
           ├─Achievement title
           ├─Achievement description
           ├─Points reward
           ├─Rarity level
           └─Unlock timestamp
           ↓
         [Show achievement celebration]
           ├─Achievement popup modal
           ├─Confetti animation
           ├─Achievement badge reveal
           ├─Sound effect
           └─Social share option
           ↓
         [Update user profile]
           ├─Add achievement badge
           ├─Add bonus points
           ├─Update achievement count
           ├─Update profile showcase
           └─Update achievement history
           ↓
         [Check for achievement combos]
           ├─Multiple achievements → Combo bonus
           ├─Complete category → Category master
           ├─Rare combo → Special title
           └─Perfect score → Perfectionist badge
           ↓
         [Send push notification]
           ├─Achievement unlock notification
           ├─Points reward notification
           ├─New level notification (if applicable)
           └─Leaderboard update notification
           ↓
         [Log achievement analytics]
           ├─Achievement earned frequency
           ├─User engagement metrics
           ├─Achievement difficulty analysis
           └─Reward effectiveness tracking
           ↓
          End
```

### 3.5.10 Sequence Diagram - Proses Login dengan Error Handling

```
User -> Login Page: Tap "Login dengan Google"
Login Page -> Google Auth: Initialize sign-in
Google Auth -> Google Services: Request authentication
Google Services -> Google Auth: Return auth result

alt Authentication Success
    Google Auth -> Auth Service: Process auth result
    Auth Service -> Firebase Firestore: Check user exists

    alt User Found & Active
        Firebase Firestore -> Auth Service: Return user data
        Auth Service -> Dashboard: Navigate with user data
        Dashboard -> User: Show welcome screen
    else User Not Found
        Firebase Firestore -> Auth Service: User not found
        Auth Service -> Error Handler: Handle AUTH_008
        Error Handler -> Login Page: Show "Pengguna tidak terdaftar"
        Login Page -> User: Display error dialog
    else User Inactive
        Firebase Firestore -> Auth Service: User inactive
        Auth Service -> Error Handler: Handle AUTH_009
        Error Handler -> Login Page: Show "Akun tidak aktif"
        Login Page -> User: Display error dialog
    end

else Authentication Failed
    Google Auth -> Auth Service: Return error
    Auth Service -> Error Handler: Determine error type

    alt Network Error
        Error Handler -> Login Page: Show AUTH_001 message
    else Sign-in Cancelled
        Error Handler -> Login Page: Show AUTH_002 message
    else Invalid Credential
        Error Handler -> Login Page: Show AUTH_005 message
    else User Disabled
        Error Handler -> Login Page: Show AUTH_006 message
    else Other Error
        Error Handler -> Login Page: Show AUTH_003 message
    end

    Login Page -> User: Display error dialog with retry option
    User -> Login Page: Tap "Coba Lagi" (optional)
end
```

### 3.5.11 Sequence Diagram - Proses Presensi RFID

```
Santri -> RFID Reader: Scan kartu
RFID Reader -> NFC Service: Read RFID data
NFC Service -> Presensi Service: Validate card
Presensi Service -> Firebase: Check user exists
Firebase -> Presensi Service: User data
Presensi Service -> Firebase: Save presensi record
Firebase -> Presensi Service: Save confirmation
Presensi Service -> Notification Service: Send notification
Notification Service -> Santri: Push notification
Presensi Service -> Dashboard: Update statistics
Dashboard -> Santri: Show success message
```

### 3.5.12 Class Diagram (Complete)

```
                                  ┌─────────────────────────┐
                                  │      <<Entity>>         │
                                  │      UserModel          │
                                  ├─────────────────────────┤
                                  │ + String id             │
                                  │ + String nama           │
                                  │ + String email          │
                                  │ + String? fotoProfil    │
                                  │ + Role role             │
                                  │ + int poin              │
                                  │ + int level             │
                                  │ + int streak            │
                                  │ + String? rfidCard      │
                                  │ + bool isActive         │
                                  │ + DateTime createdAt    │
                                  │ + DateTime updatedAt    │
                                  ├─────────────────────────┤
                                  │ + bool isSantri()       │
                                  │ + bool isAdmin()        │
                                  │ + bool isDewaGuru()     │
                                  │ + void updatePoin(int)  │
                                  │ + void calculateLevel() │
                                  │ + Map<String,dynamic>   │
                                  │   toJson()              │
                                  │ + fromJson(Map)         │
                                  └─────────────────────────┘
                                             │
                              ┌──────────────┼──────────────┐
                              │              │              │
                              ▼              ▼              ▼
               ┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
               │     PresensiModel       │ │   PengumumanModel       │ │  JadwalKegiatanModel    │
               ├─────────────────────────┤ ├─────────────────────────┤ ├─────────────────────────┤
               │ + String id             │ │ + String id             │ │ + String id             │
               │ + String userId         │ │ + String judul          │ │ + String nama           │
               │ + DateTime timestamp    │ │ + String isi            │ │ + DateTime tanggal      │
               │ + StatusPresensi status │ │ + DateTime tanggal      │ │ + TimeOfDay waktuMulai  │
               │ + String? keterangan    │ │ + bool isPenting        │ │ + TimeOfDay waktuSelesai│
               │ + PresensiMethod method │ │ + String authorId       │ │ + String? tempat        │
               │ + String? rfidData      │ │ + List<String> attach.  │ │ + String? deskripsi     │
               │ + double? latitude      │ │ + bool isActive         │ │ + bool isActive         │
               │ + double? longitude     │ │ + int viewCount         │ │ + List<String> partici. │
               │ + DateTime createdAt    │ │ + DateTime createdAt    │ │ + int? maxParticipants  │
               ├─────────────────────────┤ │ + DateTime updatedAt    │ │ + String createdBy      │
               │ + bool isOnTime()       │ ├─────────────────────────┤ │ + DateTime createdAt    │
               │ + Duration getDelay()   │ │ + void incrementView()  │ │ + DateTime updatedAt    │
               │ + Map toJson()          │ │ + bool canEdit(User)    │ ├─────────────────────────┤
               │ + fromJson(Map)         │ │ + Map toJson()          │ │ + bool canJoin(User)    │
               └─────────────────────────┘ │ + fromJson(Map)         │ │ + void addParticipant() │
                                          └─────────────────────────┘ │ + bool isFull()         │
                                                                      │ + Map toJson()          │
                                                                      │ + fromJson(Map)         │
                                                                      └─────────────────────────┘

               ┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
               │   NotificationModel     │ │   AchievementModel      │ │  UserAchievementModel   │
               ├─────────────────────────┤ ├─────────────────────────┤ ├─────────────────────────┤
               │ + String id             │ │ + String id             │ │ + String id             │
               │ + String title          │ │ + String name           │ │ + String userId         │
               │ + String message        │ │ + String description    │ │ + String achievementId  │
               │ + NotificationType type │ │ + AchievementType type  │ │ + DateTime unlockedAt   │
               │ + String? targetUserId  │ │ + AchievementRarity     │ │ + Map<String,dynamic>   │
               │ + bool isGlobal         │ │   rarity                │ │   progress              │
               │ + bool isRead           │ │ + int points            │ │ + bool isCompleted      │
               │ + DateTime createdAt    │ │ + Map<String,dynamic>   │ │ + int pointsEarned      │
               │ + DateTime? readAt      │ │   criteria              │ ├─────────────────────────┤
               ├─────────────────────────┤ │ + String? icon          │ │ + void updateProgress() │
               │ + void markAsRead()     │ │ + bool isActive         │ │ + bool checkComplete()  │
               │ + bool isExpired()      │ │ + DateTime createdAt    │ │ + Map toJson()          │
               │ + Map toJson()          │ ├─────────────────────────┤ │ + fromJson(Map)         │
               │ + fromJson(Map)         │ │ + bool checkCriteria()  │ └─────────────────────────┘
               └─────────────────────────┘ │ + int calculatePoints() │
                                          │ + Map toJson()          │
                                          │ + fromJson(Map)         │
                                          └─────────────────────────┘

               ┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
               │   LeaderboardModel      │ │   PointHistoryModel     │ │    ErrorHandlerModel    │
               ├─────────────────────────┤ ├─────────────────────────┤ ├─────────────────────────┤
               │ + String id             │ │ + String id             │ │ + String errorCode      │
               │ + String userId         │ │ + String userId         │ │ + String errorType      │
               │ + LeaderboardPeriod     │ │ + PointEventType        │ │ + String userMessage    │
               │   period                │ │   eventType             │ │ + String technicalDesc  │
               │ + int rank              │ │ + int points            │ │ + ErrorSeverity severity│
               │ + int points            │ │ + String description    │ ├─────────────────────────┤
               │ + DateTime periodDate   │ │ + Map<String,dynamic>   │ │ + String getMessage()   │
               │ + DateTime updatedAt    │ │   metadata              │ │ + Color getColor()      │
               ├─────────────────────────┤ │ + DateTime createdAt    │ │ + IconData getIcon()    │
               │ + void updateRank()     │ ├─────────────────────────┤ │ + bool canRetry()       │
               │ + bool isCurrentPeriod()│ │ + bool isPositive()     │ │ + Map toJson()          │
               │ + Map toJson()          │ │ + String getCategory()  │ │ + fromJson(Map)         │
               │ + fromJson(Map)         │ │ + Map toJson()          │ └─────────────────────────┘
               └─────────────────────────┘ │ + fromJson(Map)         │
                                          └─────────────────────────┘

                                    ┌─────────────────────────┐
                                    │   <<Service>>           │
                                    │   AuthService           │
                                    ├─────────────────────────┤
                                    │ - FirebaseAuth _auth    │
                                    │ - Firestore _firestore  │
                                    ├─────────────────────────┤
                                    │ + Future<User?> login() │
                                    │ + Future<void> logout() │
                                    │ + User? getCurrentUser()│
                                    │ + Future<bool> validate │
                                    │   Role(User user)       │
                                    └─────────────────────────┘

                                    ┌─────────────────────────┐
                                    │   <<Service>>           │
                                    │   GamificationService   │
                                    ├─────────────────────────┤
                                    │ - PointCalculator calc  │
                                    │ - AchievementEngine eng │
                                    ├─────────────────────────┤
                                    │ + void calculatePoints()│
                                    │ + void checkAchieve.()  │
                                    │ + void updateLeader.()  │
                                    │ + List<Achievement>     │
                                    │   getEligible()         │
                                    └─────────────────────────┘

// ENUMS
enum StatusPresensi {
  hadir,
  terlambat,
  alpha,
  sakit,
  izin
}

enum Role {
  santri,
  admin,
  dewan_guru
}

enum PresensiMethod {
  rfid,
  manual,
  qr_code
}

enum NotificationType {
  pengumuman,
  kegiatan,
  presensi,
  achievement,
  system
}

enum AchievementType {
  attendance,
  activity,
  learning,
  social,
  leadership,
  special
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary
}

enum LeaderboardPeriod {
  daily,
  weekly,
  monthly,
  allTime
}

enum PointEventType {
  attendance,
  activity,
  achievement,
  penalty,
  bonus
}

enum ErrorSeverity {
  info,
  warning,
  error,
  critical
}

// RELATIONSHIPS
UserModel ||--o{ PresensiModel : "has many"
UserModel ||--o{ PengumumanModel : "creates"
UserModel ||--o{ JadwalKegiatanModel : "creates"
UserModel ||--o{ NotificationModel : "receives"
UserModel ||--o{ UserAchievementModel : "earns"
UserModel ||--o{ LeaderboardModel : "ranked in"
UserModel ||--o{ PointHistoryModel : "has history"

AchievementModel ||--o{ UserAchievementModel : "unlocked by users"
JadwalKegiatanModel }o--o{ UserModel : "participants"
PengumumanModel }o--o{ UserModel : "viewed by"

// INTERFACES
<<interface>>
AuthRepository {
  + Future<Result<User>> login(credentials)
  + Future<Result<void>> logout()
  + Future<Result<User?>> getCurrentUser()
}

<<interface>>
PresensiRepository {
  + Future<Result<void>> savePresensi(data)
  + Future<Result<List<Presensi>>> getHistory(userId)
  + Future<Result<PresensiStats>> getStatistics(userId)
}

<<interface>>
GamificationRepository {
  + Future<Result<void>> updatePoints(userId, points)
  + Future<Result<List<Achievement>>> checkAchievements(userId)
  + Future<Result<Leaderboard>> getLeaderboard(period)
}
```

## 3.6 Data Store / Data Dictionary

### D1 - Users Collection

| Field      | Type      | Description    | Constraints             |
| ---------- | --------- | -------------- | ----------------------- |
| id         | String    | Primary Key    | Not Null, Unique        |
| nama       | String    | Nama lengkap   | Not Null, Max 100       |
| email      | String    | Email address  | Not Null, Valid Email   |
| fotoProfil | String    | URL foto       | Nullable                |
| role       | Enum      | User role      | santri/admin/dewan_guru |
| poin       | Integer   | User points    | Default 0               |
| rfidCard   | String    | RFID card ID   | Nullable, Unique        |
| isActive   | Boolean   | Account status | Default true            |
| createdAt  | Timestamp | Created date   | Auto-generated          |
| updatedAt  | Timestamp | Last updated   | Auto-updated            |

### D2 - Presensi Collection

| Field      | Type      | Description      | Constraints                      |
| ---------- | --------- | ---------------- | -------------------------------- |
| id         | String    | Primary Key      | Not Null, Unique                 |
| userId     | String    | Foreign Key      | Not Null, Ref Users              |
| timestamp  | Timestamp | Presensi time    | Not Null                         |
| status     | Enum      | Presensi status  | hadir/terlambat/alpha/sakit/izin |
| keterangan | String    | Additional notes | Nullable                         |
| method     | Enum      | Scan method      | rfid/manual/qr_code              |
| rfidData   | String    | RFID card data   | Nullable                         |
| latitude   | Double    | GPS coordinate   | Nullable                         |
| longitude  | Double    | GPS coordinate   | Nullable                         |
| createdAt  | Timestamp | Record created   | Auto-generated                   |

### D3 - Pengumuman Collection

| Field       | Type      | Description        | Constraints         |
| ----------- | --------- | ------------------ | ------------------- |
| id          | String    | Primary Key        | Not Null, Unique    |
| judul       | String    | Announcement title | Not Null, Max 200   |
| isi         | String    | Content            | Not Null            |
| tanggal     | Timestamp | Published date     | Not Null            |
| isPenting   | Boolean   | Important flag     | Default false       |
| authorId    | String    | Creator ID         | Not Null, Ref Users |
| attachments | Array     | File attachments   | Nullable            |
| isActive    | Boolean   | Published status   | Default true        |
| viewCount   | Integer   | View counter       | Default 0           |
| createdAt   | Timestamp | Created date       | Auto-generated      |
| updatedAt   | Timestamp | Last updated       | Auto-updated        |

### D4 - Jadwal Collection

| Field           | Type      | Description     | Constraints         |
| --------------- | --------- | --------------- | ------------------- |
| id              | String    | Primary Key     | Not Null, Unique    |
| nama            | String    | Activity name   | Not Null, Max 200   |
| tanggal         | Timestamp | Activity date   | Not Null            |
| waktuMulai      | Time      | Start time      | Not Null            |
| waktuSelesai    | Time      | End time        | Not Null            |
| tempat          | String    | Location        | Nullable            |
| deskripsi       | String    | Description     | Nullable            |
| isActive        | Boolean   | Event status    | Default true        |
| participants    | Array     | Participant IDs | Nullable            |
| maxParticipants | Integer   | Max capacity    | Nullable            |
| createdBy       | String    | Creator ID      | Not Null, Ref Users |
| createdAt       | Timestamp | Created date    | Auto-generated      |
| updatedAt       | Timestamp | Last updated    | Auto-updated        |

### D5 - Notifications Collection

| Field        | Type      | Description         | Constraints                  |
| ------------ | --------- | ------------------- | ---------------------------- |
| id           | String    | Primary Key         | Not Null, Unique             |
| title        | String    | Notification title  | Not Null, Max 100            |
| message      | String    | Notification body   | Not Null                     |
| type         | Enum      | Notification type   | pengumuman/kegiatan/presensi |
| targetUserId | String    | Target user         | Nullable, Ref Users          |
| isGlobal     | Boolean   | Global notification | Default false                |
| isRead       | Boolean   | Read status         | Default false                |
| createdAt    | Timestamp | Created date        | Auto-generated               |
| readAt       | Timestamp | Read timestamp      | Nullable                     |

### D6 - Achievements Collection

| Field       | Type      | Description             | Constraints                                            |
| ----------- | --------- | ----------------------- | ------------------------------------------------------ |
| id          | String    | Primary Key             | Not Null, Unique                                       |
| name        | String    | Achievement name        | Not Null, Max 100                                      |
| description | String    | Achievement description | Not Null                                               |
| type        | Enum      | Achievement category    | attendance/activity/learning/social/leadership/special |
| rarity      | Enum      | Achievement rarity      | common/rare/epic/legendary                             |
| points      | Integer   | Points reward           | Default 10                                             |
| criteria    | Map       | Achievement criteria    | JSON object with conditions                            |
| icon        | String    | Achievement icon URL    | Nullable                                               |
| isActive    | Boolean   | Achievement status      | Default true                                           |
| createdAt   | Timestamp | Created date            | Auto-generated                                         |

### D7 - UserAchievements Collection

| Field         | Type      | Description             | Constraints                    |
| ------------- | --------- | ----------------------- | ------------------------------ |
| id            | String    | Primary Key             | Not Null, Unique               |
| userId        | String    | User reference          | Not Null, Ref Users            |
| achievementId | String    | Achievement reference   | Not Null, Ref Achievements     |
| unlockedAt    | Timestamp | Achievement unlock date | Not Null                       |
| progress      | Map       | Progress tracking       | JSON object with progress data |
| isCompleted   | Boolean   | Completion status       | Default false                  |
| pointsEarned  | Integer   | Points earned           | Default 0                      |

### D8 - Leaderboards Collection

| Field      | Type      | Description        | Constraints                   |
| ---------- | --------- | ------------------ | ----------------------------- |
| id         | String    | Primary Key        | Not Null, Unique              |
| userId     | String    | User reference     | Not Null, Ref Users           |
| period     | Enum      | Leaderboard period | daily/weekly/monthly/all-time |
| rank       | Integer   | User ranking       | Not Null                      |
| points     | Integer   | Total points       | Not Null                      |
| periodDate | Timestamp | Period reference   | Date for the ranking period   |
| updatedAt  | Timestamp | Last update        | Auto-updated                  |

### D9 - PointHistory Collection

| Field       | Type      | Description         | Constraints                             |
| ----------- | --------- | ------------------- | --------------------------------------- |
| id          | String    | Primary Key         | Not Null, Unique                        |
| userId      | String    | User reference      | Not Null, Ref Users                     |
| eventType   | Enum      | Point event type    | attendance/activity/achievement/penalty |
| points      | Integer   | Points change (+/-) | Not Null                                |
| description | String    | Point event desc    | Not Null                                |
| metadata    | Map       | Additional data     | JSON object with event details          |
| createdAt   | Timestamp | Transaction date    | Auto-generated                          |

## 3.7 Entity Relationship Diagram (ERD)

```
[Users] ||--o{ [Presensi] : records
[Users] ||--o{ [Pengumuman] : creates
[Users] ||--o{ [Jadwal] : creates
[Users] ||--o{ [Notifications] : receives

[Presensi] }o--|| [StatusPresensi] : has_status
[Jadwal] }o--o{ [Users] : participates
[Pengumuman] }o--o{ [Users] : views

Relationships:
- Users(1) : Presensi(N) - One user can have many attendance records
- Users(1) : Pengumuman(N) - One user can create many announcements
- Users(1) : Jadwal(N) - One user can create many events
- Users(1) : Notifications(N) - One user can receive many notifications
- Jadwal(N) : Users(N) - Many-to-many relationship for event participation
- Pengumuman(N) : Users(N) - Many-to-many for announcement views
```

## 3.8 Kebutuhan Data

### 3.8.1 Pengelolaan Data

Data dalam sistem SiSantri dikelola menggunakan:

1. **Firebase Firestore** - Database NoSQL untuk menyimpan semua data aplikasi
2. **Firebase Authentication** - Manajemen autentikasi pengguna
3. **Firebase Storage** - Penyimpanan file dan gambar
4. **Local Storage** - Cache data untuk mode offline

### 3.8.2 Backup dan Recovery

- Backup otomatis setiap hari ke Firebase
- Export manual data ke Excel/CSV
- Sinkronisasi real-time antar device

### 3.8.3 Data Security

- Enkripsi data sensitive
- Rule-based access control
- Audit trail untuk semua operasi

### 3.8.4 Data Migration

- Versioning schema database
- Migration scripts untuk update struktur
- Rollback mechanism jika diperlukan

## 3.9 Arsitektur Sistem

### 3.9.1 Clean Architecture

```
Presentation Layer (UI)
├── Pages (Screens)
├── Widgets (Components)
├── Providers (State Management)
└── Routes (Navigation)

Domain Layer (Business Logic)
├── Entities (Models)
├── Use Cases (Business Rules)
├── Repositories (Interfaces)
└── Services (Business Services)

Data Layer (External)
├── Data Sources (Remote/Local)
├── Repository Implementations
├── Models (Data Transfer Objects)
└── External Services (Firebase, etc)
```

### 3.9.2 State Management

- **Riverpod** untuk state management global
- **Provider pattern** untuk dependency injection
- **Stream providers** untuk real-time data
- **Future providers** untuk async operations

### 3.9.3 Teknologi Stack

- **Frontend**: Flutter/Dart
- **Backend**: Firebase (Firestore, Auth, Storage, Functions)
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Local Database**: Hive/SQLite
- **Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics

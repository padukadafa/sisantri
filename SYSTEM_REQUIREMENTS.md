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

### PSPEC P2.4 - Kirim Notifikasi

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

## 3.5 Object Oriented Design

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

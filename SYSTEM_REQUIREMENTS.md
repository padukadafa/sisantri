# Kebutuhan Sistem SiSantri

## 3.1 Kebutuhan Fungsional

### 3.1.1 Modul Autentikasi

- **RF-01**: Sistem dapat melakukan login dengan Google Authentication
- **RF-02**: Sistem dapat melakukan logout pengguna
- **RF-03**: Sistem dapat mengelola profil pengguna (nama, foto, email)
- **RF-04**: Sistem dapat mengatur RFID untuk presensi

### 3.1.2 Modul Dashboard

- **RF-05**: Sistem dapat menampilkan welcome card dengan informasi pengguna
- **RF-06**: Sistem dapat menampilkan statistik presensi harian
- **RF-07**: Sistem dapat menampilkan notifikasi real-time
- **RF-08**: Sistem dapat menampilkan kegiatan mendatang
- **RF-09**: Sistem dapat menampilkan pengumuman terbaru
- **RF-10**: Sistem dapat menampilkan statistik kehadiran mingguan dan bulanan

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
- **RF-30**: Admin dapat mengatur role pengguna (santri/admin/dewa guru)

### 3.1.7 Modul Laporan

- **RF-31**: Admin dapat melihat laporan presensi
- **RF-32**: Admin dapat memfilter laporan berdasarkan tanggal
- **RF-33**: Admin dapat memfilter laporan berdasarkan pengguna
- **RF-34**: Admin dapat mengekspor laporan ke Excel
- **RF-35**: Sistem dapat menampilkan grafik statistik

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

## 3.3 Data Flow Diagram (DFD)

### 3.3.1 DFD Context (Level 0)

```
[Santri] -----> |login, presensi, lihat jadwal| -----> [SISTEM SISANTRI] -----> |data presensi, notifikasi| -----> [Santri]
                                                             |
[Admin] ------> |kelola data, laporan| -----------------> [SISTEM SISANTRI] -----> |laporan, statistik| -----> [Admin]
                                                             |
[Dewa Guru] ---> |monitoring, approval| ----------------> [SISTEM SISANTRI] -----> |dashboard, laporan| ---> [Dewa Guru]
                                                             |
                                                    [DATABASE FIREBASE]
```

### 3.3.2 DFD Level 1

```
1.0 AUTENTIKASI
- Input: data login, google auth
- Output: token akses, profil user
- Data Store: D1 Users

2.0 PRESENSI
- Input: RFID scan, data manual
- Output: status presensi, notifikasi
- Data Store: D2 Presensi

3.0 PENGUMUMAN
- Input: data pengumuman
- Output: list pengumuman, notifikasi
- Data Store: D3 Pengumuman

4.0 JADWAL
- Input: data kegiatan
- Output: kalender, reminder
- Data Store: D4 Jadwal

5.0 LAPORAN
- Input: filter laporan
- Output: excel file, statistik
- Data Store: D2 Presensi, D1 Users

6.0 DASHBOARD
- Input: request data
- Output: summary, statistik
- Data Store: D1-D4 All Stores
```

### 3.3.3 DFD Level 2 - Proses Presensi (2.0)

```
2.1 SCAN RFID
- Input: RFID data
- Process: validasi kartu, cek jadwal
- Output: status scan
- PSPEC: P2.1

2.2 VALIDASI PRESENSI
- Input: user ID, timestamp
- Process: cek duplikasi, tentukan status
- Output: record presensi
- PSPEC: P2.2

2.3 SIMPAN PRESENSI
- Input: validated data
- Process: insert to database
- Output: confirmation
- PSPEC: P2.3

2.4 KIRIM NOTIFIKASI
- Input: presensi berhasil
- Process: generate notification
- Output: push notification
- PSPEC: P2.4
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

**Aktor: Dewa Guru**

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
  ├─No──→ [Show Error] ──→ [Input Google Account]
  └─Yes─→ [Get User Profile]
           ↓
         [Check Role]
           ↓
         Decision{Role Valid?}
           ├─No──→ [Access Denied] ──→ End
           └─Yes─→ [Load Dashboard]
                    ↓
                  [Initialize Providers]
                    ↓
                  [Show Main App]
                    ↓
                   End
```

### 3.5.3 Sequence Diagram - Proses Presensi RFID

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

### 3.5.4 Class Diagram (Simplified)

```dart
class UserModel {
  + String id
  + String nama
  + String email
  + String? fotoProfil
  + Role role
  + int poin
  + bool isSantri
  + bool isAdmin
  + bool isDewaGuru
  + DateTime createdAt
  + DateTime updatedAt
}

class PresensiModel {
  + String id
  + String userId
  + DateTime timestamp
  + StatusPresensi status
  + String? keterangan
  + PresensiMethod method
  + String? rfidData
}

class PengumumanModel {
  + String id
  + String judul
  + String isi
  + DateTime tanggal
  + bool isPenting
  + String authorId
  + List<String> attachments
}

class JadwalKegiatanModel {
  + String id
  + String nama
  + DateTime tanggal
  + TimeOfDay waktuMulai
  + TimeOfDay waktuSelesai
  + String? tempat
  + String? deskripsi
  + bool isActive
  + List<String> participants
}

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
  dewa_guru
}

enum PresensiMethod {
  rfid,
  manual,
  qr_code
}
```

## 3.6 Data Store / Data Dictionary

### D1 - Users Collection

| Field      | Type      | Description    | Constraints            |
| ---------- | --------- | -------------- | ---------------------- |
| id         | String    | Primary Key    | Not Null, Unique       |
| nama       | String    | Nama lengkap   | Not Null, Max 100      |
| email      | String    | Email address  | Not Null, Valid Email  |
| fotoProfil | String    | URL foto       | Nullable               |
| role       | Enum      | User role      | santri/admin/dewa_guru |
| poin       | Integer   | User points    | Default 0              |
| rfidCard   | String    | RFID card ID   | Nullable, Unique       |
| isActive   | Boolean   | Account status | Default true           |
| createdAt  | Timestamp | Created date   | Auto-generated         |
| updatedAt  | Timestamp | Last updated   | Auto-updated           |

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

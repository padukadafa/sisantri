# ER Diagram Alternatif - SiSantri (Format Visual)

## Diagram ER dengan Chen Notation

```mermaid
erDiagram
    %% Core Entities
    USERS {
        varchar uid PK "Firebase UID"
        varchar email UNIQUE
        varchar nama
        enum role "santri|dewan_guru|admin"
        varchar nisn
        varchar nip
        varchar kelas
        varchar foto_url
        varchar rfid_tag_id UNIQUE
        varchar no_telepon
        text alamat
        date tanggal_lahir
        char jenis_kelamin
        int total_poin
        int level
        boolean is_active
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
        json preferences
    }

    PRESENSI {
        varchar id PK
        varchar user_id FK
        date tanggal
        time waktu_masuk
        time waktu_keluar
        enum status "hadir|terlambat|izin|sakit|alpha"
        enum metode "rfid|manual|qr_code"
        text keterangan
        varchar verified_by FK
        boolean is_verified
        varchar lokasi
        json metadata
        timestamp created_at
        timestamp updated_at
    }

    PENGUMUMAN {
        varchar id PK
        varchar judul
        text konten
        enum kategori "umum|penting|mendesak"
        enum prioritas "low|medium|high"
        varchar created_by FK
        varchar target_audience
        json target_roles
        json target_classes
        varchar lampiran_url
        datetime tanggal_mulai
        datetime tanggal_berakhir
        boolean is_published
        boolean is_pinned
        int view_count
        timestamp created_at
        timestamp updated_at
    }

    JADWAL {
        varchar id PK
        varchar nama_kegiatan
        text deskripsi
        enum jenis "pembelajaran|ibadah|ekstrakurikuler|acara_khusus"
        datetime tanggal_mulai
        datetime tanggal_selesai
        varchar lokasi
        varchar created_by FK
        varchar target_peserta
        json target_roles
        json target_classes
        int kapasitas
        int current_participants
        boolean is_mandatory
        enum status "scheduled|ongoing|completed|cancelled"
        boolean enable_reminders
        json reminder_schedule
        varchar calendar_sync_id
        datetime registration_deadline
        timestamp created_at
        timestamp updated_at
    }

    NOTIFIKASI {
        varchar id PK
        varchar user_id FK
        varchar judul
        text pesan
        enum tipe "presensi|pengumuman|jadwal|gamifikasi|sistem"
        enum prioritas "low|medium|high"
        json data
        varchar action_type
        varchar action_payload
        boolean is_read
        datetime read_at
        enum channel "push|in_app|email"
        varchar source_id
        varchar source_type
        timestamp created_at
        datetime scheduled_at
        datetime sent_at
    }

    POINT_TRANSACTIONS {
        varchar id PK
        varchar user_id FK
        enum transaction_type "attendance|achievement|event|penalty"
        int points
        varchar event_type
        text description
        varchar reference_id
        varchar reference_type
        timestamp created_at
        json metadata
    }

    ACHIEVEMENTS {
        varchar id PK
        varchar nama
        text deskripsi
        enum kategori "attendance|streak|participation|special"
        varchar icon_url
        json criteria
        int points_reward
        enum rarity "common|rare|epic|legendary"
        boolean is_active
        timestamp created_at
    }

    USER_ACHIEVEMENTS {
        varchar id PK
        varchar user_id FK
        varchar achievement_id FK
        datetime unlocked_at
        int progress
        boolean is_completed
        datetime completed_at
    }

    LEADERBOARD {
        varchar id PK
        varchar user_id FK
        enum period "daily|weekly|monthly|all_time"
        int rank
        int total_points
        datetime period_start
        datetime period_end
        timestamp updated_at
    }

    EVENT_PARTICIPANTS {
        varchar id PK
        varchar event_id FK
        varchar user_id FK
        enum status "registered|confirmed|attended|absent|cancelled"
        datetime registered_at
        datetime confirmed_at
        text notes
    }

    EVENT_REMINDERS {
        varchar id PK
        varchar event_id FK
        varchar user_id FK
        enum reminder_type "24h|2h|30m"
        datetime scheduled_time
        boolean is_sent
        datetime sent_at
    }

    ANNOUNCEMENT_READS {
        varchar id PK
        varchar announcement_id FK
        varchar user_id FK
        datetime read_at
        boolean is_read
    }

    REPORTS {
        varchar id PK
        varchar nama_laporan
        enum tipe "attendance|statistics|custom"
        enum format "pdf|excel"
        datetime tanggal_mulai
        datetime tanggal_selesai
        json filters
        varchar generated_by FK
        varchar file_url
        enum status "pending|processing|completed|failed"
        json schedule
        json recipients
        timestamp created_at
        datetime completed_at
    }

    AUDIT_LOG {
        varchar id PK
        varchar user_id FK
        enum action "create|update|delete|login|logout"
        varchar entity_type
        varchar entity_id
        json old_data
        json new_data
        varchar ip_address
        varchar user_agent
        timestamp created_at
    }

    %% Relationships
    USERS ||--o{ PRESENSI : "mencatat"
    USERS ||--o{ PENGUMUMAN : "membuat"
    USERS ||--o{ JADWAL : "mengatur"
    USERS ||--o{ NOTIFIKASI : "menerima"
    USERS ||--o{ POINT_TRANSACTIONS : "memiliki"
    USERS ||--o{ USER_ACHIEVEMENTS : "meraih"
    USERS ||--o{ AUDIT_LOG : "aktivitas"
    USERS ||--o{ EVENT_PARTICIPANTS : "ikut_serta"
    USERS ||--o{ EVENT_REMINDERS : "menerima_reminder"
    USERS ||--o{ ANNOUNCEMENT_READS : "membaca"
    USERS ||--o{ LEADERBOARD : "terdaftar_di"
    USERS ||--o{ REPORTS : "membuat"

    PRESENSI }o--|| USERS : "milik"
    PRESENSI }o--|| USERS : "diverifikasi_oleh"

    JADWAL ||--o{ EVENT_PARTICIPANTS : "memiliki_peserta"
    JADWAL ||--o{ EVENT_REMINDERS : "memiliki_reminder"
    JADWAL }o--|| USERS : "dibuat_oleh"

    EVENT_PARTICIPANTS }o--|| JADWAL : "untuk_event"
    EVENT_PARTICIPANTS }o--|| USERS : "peserta"

    EVENT_REMINDERS }o--|| JADWAL : "untuk_event"
    EVENT_REMINDERS }o--|| USERS : "untuk_user"

    PENGUMUMAN ||--o{ ANNOUNCEMENT_READS : "dibaca"
    PENGUMUMAN }o--|| USERS : "dibuat_oleh"

    ANNOUNCEMENT_READS }o--|| PENGUMUMAN : "untuk_pengumuman"
    ANNOUNCEMENT_READS }o--|| USERS : "oleh_user"

    ACHIEVEMENTS ||--o{ USER_ACHIEVEMENTS : "diraih"
    USER_ACHIEVEMENTS }o--|| USERS : "oleh_user"

    NOTIFIKASI }o--|| USERS : "untuk_user"

    POINT_TRANSACTIONS }o--|| USERS : "untuk_user"

    LEADERBOARD }o--|| USERS : "untuk_user"

    REPORTS }o--|| USERS : "dibuat_oleh"

    AUDIT_LOG }o--|| USERS : "oleh_user"
```

## Penjelasan Simbol Kardinalitas

| Simbol       | Arti         | Keterangan                                        |
| ------------ | ------------ | ------------------------------------------------- |
| `\|\|--o{`   | One to Many  | Satu entitas bisa memiliki banyak relasi          |
| `}o--\|\|`   | Many to One  | Banyak entitas terkait dengan satu entitas        |
| `\|\|--\|\|` | One to One   | Satu entitas terkait dengan satu entitas lain     |
| `}o--o{`     | Many to Many | Banyak ke banyak (biasanya dengan tabel junction) |

## Tabel Lookup/Reference

### Status Kehadiran (PRESENSI.status)

- `hadir` - Hadir tepat waktu
- `terlambat` - Hadir terlambat
- `izin` - Tidak hadir dengan izin
- `sakit` - Tidak hadir karena sakit
- `alpha` - Tidak hadir tanpa keterangan

### Role Pengguna (USERS.role)

- `santri` - Siswa/Santri
- `dewan_guru` - Guru/Pengajar
- `admin` - Administrator sistem

### Metode Presensi (PRESENSI.metode)

- `rfid` - Menggunakan kartu RFID
- `manual` - Input manual oleh admin/guru
- `qr_code` - Scan QR Code

### Jenis Kegiatan (JADWAL.jenis)

- `pembelajaran` - Kegiatan belajar mengajar
- `ibadah` - Kegiatan ibadah
- `ekstrakurikuler` - Kegiatan ekstrakurikuler
- `acara_khusus` - Acara khusus/event

### Tipe Notifikasi (NOTIFIKASI.tipe)

- `presensi` - Notifikasi terkait kehadiran
- `pengumuman` - Notifikasi pengumuman baru
- `jadwal` - Notifikasi event/kegiatan
- `gamifikasi` - Notifikasi achievement/poin
- `sistem` - Notifikasi sistem

### Kategori Achievement (ACHIEVEMENTS.kategori)

- `attendance` - Terkait kehadiran
- `streak` - Terkait konsistensi
- `participation` - Terkait partisipasi
- `special` - Achievement khusus

### Rarity Achievement (ACHIEVEMENTS.rarity)

- `common` - Umum/mudah didapat
- `rare` - Jarang/cukup sulit
- `epic` - Epik/sulit
- `legendary` - Legendaris/sangat sulit

## Aturan Integritas Referensial

### CASCADE DELETE

Ketika user dihapus (soft delete):

- PRESENSI → Tetap dipertahankan (untuk audit)
- NOTIFIKASI → Tetap dipertahankan
- POINT_TRANSACTIONS → Tetap dipertahankan
- USER_ACHIEVEMENTS → Tetap dipertahankan
- AUDIT_LOG → Tetap dipertahankan

### ON DELETE SET NULL

- PENGUMUMAN.created_by → Set NULL jika creator dihapus
- JADWAL.created_by → Set NULL jika creator dihapus

### RESTRICT DELETE

- USER_ACHIEVEMENTS.achievement_id → Tidak bisa hapus achievement jika ada user yang sudah meraihnya
- ANNOUNCEMENT_READS.announcement_id → Tidak bisa hapus pengumuman jika sudah ada yang membaca

## Constraint & Validasi

### USERS

- `email` harus format email valid dan unique
- `rfid_tag_id` harus unique jika diisi
- `role` harus salah satu dari enum yang ditentukan
- `total_poin` tidak boleh negatif
- `level` dimulai dari 1

### PRESENSI

- `tanggal` tidak boleh di masa depan
- `waktu_keluar` harus lebih besar dari `waktu_masuk`
- Tidak boleh ada duplikat `(user_id, tanggal)` untuk metode RFID

### JADWAL

- `tanggal_selesai` harus >= `tanggal_mulai`
- `current_participants` tidak boleh > `kapasitas`
- `registration_deadline` harus < `tanggal_mulai`

### POINT_TRANSACTIONS

- Untuk `transaction_type = 'penalty'`, `points` harus negatif
- Untuk tipe lain, `points` harus positif

### LEADERBOARD

- `rank` harus unique per `period`
- `total_points` tidak boleh negatif

## View yang Disarankan

### v_user_statistics

```sql
CREATE VIEW v_user_statistics AS
SELECT
    u.uid,
    u.nama,
    u.kelas,
    u.total_poin,
    u.level,
    COUNT(p.id) as total_presensi,
    SUM(CASE WHEN p.status = 'hadir' THEN 1 ELSE 0 END) as hadir,
    SUM(CASE WHEN p.status = 'terlambat' THEN 1 ELSE 0 END) as terlambat,
    SUM(CASE WHEN p.status IN ('izin', 'sakit') THEN 1 ELSE 0 END) as izin_sakit,
    SUM(CASE WHEN p.status = 'alpha' THEN 1 ELSE 0 END) as alpha
FROM USERS u
LEFT JOIN PRESENSI p ON u.uid = p.user_id
GROUP BY u.uid;
```

### v_active_events

```sql
CREATE VIEW v_active_events AS
SELECT
    j.*,
    u.nama as creator_name,
    COUNT(ep.id) as participant_count
FROM JADWAL j
LEFT JOIN USERS u ON j.created_by = u.uid
LEFT JOIN EVENT_PARTICIPANTS ep ON j.id = ep.event_id
WHERE j.status IN ('scheduled', 'ongoing')
AND j.tanggal_mulai >= NOW()
GROUP BY j.id;
```

### v_unread_notifications

```sql
CREATE VIEW v_unread_notifications AS
SELECT
    n.*,
    u.nama as user_name
FROM NOTIFIKASI n
JOIN USERS u ON n.user_id = u.uid
WHERE n.is_read = false
ORDER BY n.created_at DESC;
```

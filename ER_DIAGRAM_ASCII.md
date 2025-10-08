# ER Diagram - SiSantri (Text Art Visualization)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          SISTEM INFORMASI SANTRI (SISANTRI)                      │
│                                  ER DIAGRAM OVERVIEW                              │
└─────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│       USERS          │ ◄────────────────────────┐
│ ==================== │                          │
│ PK: uid              │                          │
│ UK: email            │                          │
│ UK: rfid_tag_id      │                          │
│ - nama               │                          │
│ - role               │                          │
│ - nisn               │                          │
│ - kelas              │                          │
│ - total_poin         │                          │
│ - level              │                          │
└──────┬───────────────┘                          │
       │ 1                                        │
       │                                          │
       │ N (has many)                             │
       ▼                                          │
┌──────────────────────┐                         │
│     PRESENSI         │                         │
│ ==================== │                         │
│ PK: id               │                         │
│ FK: user_id ─────────┼─────────────────────────┘
│ FK: verified_by      │
│ - tanggal            │
│ - waktu_masuk        │
│ - waktu_keluar       │
│ - status             │ ◄─── (hadir, terlambat, izin, sakit, alpha)
│ - metode             │ ◄─── (rfid, manual, qr_code)
│ - is_verified        │
└──────────────────────┘


┌──────────────────────┐
│       USERS          │
└──────┬───────────────┘
       │ 1
       │
       │ N (creates)
       ▼
┌──────────────────────┐                    ┌──────────────────────┐
│    PENGUMUMAN        │                    │ ANNOUNCEMENT_READS   │
│ ==================== │ 1                N │ ==================== │
│ PK: id               │◄───────────────────│ PK: id               │
│ FK: created_by       │                    │ FK: announcement_id  │
│ - judul              │                    │ FK: user_id          │
│ - konten             │                    │ - read_at            │
│ - kategori           │                    │ - is_read            │
│ - prioritas          │                    └──────────────────────┘
│ - target_audience    │
│ - is_published       │
│ - is_pinned          │
└──────────────────────┘


┌──────────────────────┐
│       USERS          │
└──────┬───────────────┘
       │ 1
       │
       │ N (organizes)
       ▼
┌──────────────────────┐                    ┌──────────────────────┐
│      JADWAL          │                    │ EVENT_PARTICIPANTS   │
│ ==================== │ 1                N │ ==================== │
│ PK: id               │◄───────────────────│ PK: id               │
│ FK: created_by       │                    │ FK: event_id         │
│ - nama_kegiatan      │                    │ FK: user_id          │
│ - deskripsi          │                    │ - status             │
│ - jenis              │                    │ - registered_at      │
│ - tanggal_mulai      │                    └──────────────────────┘
│ - tanggal_selesai    │
│ - lokasi             │                    ┌──────────────────────┐
│ - kapasitas          │ 1                N │  EVENT_REMINDERS     │
│ - is_mandatory       │◄───────────────────│ ==================== │
│ - status             │                    │ PK: id               │
└──────────────────────┘                    │ FK: event_id         │
                                            │ FK: user_id          │
                                            │ - reminder_type      │
                                            │ - scheduled_time     │
                                            │ - is_sent            │
                                            └──────────────────────┘


┌──────────────────────┐
│       USERS          │
└──────┬───────────────┘
       │ 1
       │
       │ N (receives)
       ▼
┌──────────────────────┐
│    NOTIFIKASI        │
│ ==================== │
│ PK: id               │
│ FK: user_id          │
│ - judul              │
│ - pesan              │
│ - tipe               │ ◄─── (presensi, pengumuman, jadwal, gamifikasi, sistem)
│ - prioritas          │
│ - is_read            │
│ - channel            │ ◄─── (push, in_app, email)
│ - action_type        │
└──────────────────────┘


┌──────────────────────┐
│       USERS          │
└──────┬───────────────┘
       │ 1
       │
       │ N (earns)
       ▼
┌──────────────────────┐
│ POINT_TRANSACTIONS   │
│ ==================== │
│ PK: id               │
│ FK: user_id          │
│ - transaction_type   │ ◄─── (attendance, achievement, event, penalty)
│ - points             │
│ - event_type         │
│ - description        │
│ - reference_id       │
│ - reference_type     │
└──────────────────────┘


┌──────────────────────┐                    ┌──────────────────────┐
│    ACHIEVEMENTS      │                    │  USER_ACHIEVEMENTS   │
│ ==================== │ 1                N │ ==================== │
│ PK: id               │◄───────────────────│ PK: id               │
│ - nama               │                    │ FK: user_id          │
│ - deskripsi          │                    │ FK: achievement_id   │
│ - kategori           │                    │ - unlocked_at        │
│ - icon_url           │                    │ - progress           │
│ - criteria           │                    │ - is_completed       │
│ - points_reward      │                    └──────────────────────┘
│ - rarity             │
└──────────────────────┘


┌──────────────────────┐
│       USERS          │
└──────┬───────────────┘
       │ 1
       │
       │ N (ranked in)
       ▼
┌──────────────────────┐
│    LEADERBOARD       │
│ ==================== │
│ PK: id               │
│ FK: user_id          │
│ - period             │ ◄─── (daily, weekly, monthly, all_time)
│ - rank               │
│ - total_points       │
│ - period_start       │
│ - period_end         │
└──────────────────────┘


┌──────────────────────┐
│       USERS          │
└──────┬───────────────┘
       │ 1
       │
       │ N (generates)
       ▼
┌──────────────────────┐
│      REPORTS         │
│ ==================== │
│ PK: id               │
│ FK: generated_by     │
│ - nama_laporan       │
│ - tipe               │ ◄─── (attendance, statistics, custom)
│ - format             │ ◄─── (pdf, excel)
│ - tanggal_mulai      │
│ - tanggal_selesai    │
│ - filters            │
│ - file_url           │
│ - status             │
└──────────────────────┘


┌──────────────────────┐
│       USERS          │
└──────┬───────────────┘
       │ 1
       │
       │ N (logged in)
       ▼
┌──────────────────────┐
│     AUDIT_LOG        │
│ ==================== │
│ PK: id               │
│ FK: user_id          │
│ - action             │ ◄─── (create, update, delete, login, logout)
│ - entity_type        │
│ - entity_id          │
│ - old_data           │
│ - new_data           │
│ - ip_address         │
│ - user_agent         │
└──────────────────────┘


╔═══════════════════════════════════════════════════════════════════════════════╗
║                              RELASI SUMMARY                                    ║
╚═══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────┬──────────────────┬────────────────────┬──────────────────┐
│  Parent Table       │  Relationship    │  Child Table       │  Cardinality     │
├─────────────────────┼──────────────────┼────────────────────┼──────────────────┤
│ USERS               │  mencatat        │  PRESENSI          │  1 : N           │
│ USERS               │  verifikasi      │  PRESENSI          │  1 : N           │
│ USERS               │  membuat         │  PENGUMUMAN        │  1 : N           │
│ USERS               │  mengatur        │  JADWAL            │  1 : N           │
│ USERS               │  menerima        │  NOTIFIKASI        │  1 : N           │
│ USERS               │  memiliki        │  POINT_TRANS...    │  1 : N           │
│ USERS               │  meraih          │  USER_ACHIEVE...   │  1 : N           │
│ USERS               │  berpartisipasi  │  EVENT_PARTIC...   │  1 : N           │
│ USERS               │  tercatat        │  AUDIT_LOG         │  1 : N           │
│ USERS               │  terdaftar       │  LEADERBOARD       │  1 : N           │
│ USERS               │  membuat         │  REPORTS           │  1 : N           │
│ JADWAL              │  memiliki        │  EVENT_PARTIC...   │  1 : N           │
│ JADWAL              │  memiliki        │  EVENT_REMIND...   │  1 : N           │
│ PENGUMUMAN          │  dibaca          │  ANNOUNCEMENT_R... │  1 : N           │
│ ACHIEVEMENTS        │  diraih          │  USER_ACHIEVE...   │  1 : N           │
└─────────────────────┴──────────────────┴────────────────────┴──────────────────┘


╔═══════════════════════════════════════════════════════════════════════════════╗
║                          DATA FLOW OVERVIEW                                    ║
╚═══════════════════════════════════════════════════════════════════════════════╝

[RFID Reader] ──── Check-in ────► [PRESENSI]
                                        │
                                        ├──► Trigger Gamification
                                        │         │
                                        │         ▼
                                        │    [POINT_TRANSACTIONS]
                                        │         │
                                        │         ▼
                                        │    Update [USERS.total_poin]
                                        │         │
                                        │         ▼
                                        │    Check [ACHIEVEMENTS]
                                        │         │
                                        │         ▼
                                        │    Unlock [USER_ACHIEVEMENTS]
                                        │         │
                                        │         ▼
                                        │    Update [LEADERBOARD]
                                        │
                                        ├──► Generate [NOTIFIKASI]
                                        │
                                        └──► Log to [AUDIT_LOG]


[Admin/Guru] ──── Create ────► [PENGUMUMAN]
                                      │
                                      ├──► Target filtering
                                      │         │
                                      │         ▼
                                      │    Get target [USERS]
                                      │         │
                                      │         ▼
                                      │    Generate [NOTIFIKASI]
                                      │         │
                                      │         └──► Push/Email
                                      │
                                      └──► Track [ANNOUNCEMENT_READS]


[Admin/Guru] ──── Schedule ────► [JADWAL]
                                      │
                                      ├──► Create [EVENT_PARTICIPANTS]
                                      │         │
                                      │         ▼
                                      │    Generate [EVENT_REMINDERS]
                                      │         │
                                      │         ▼
                                      │    Schedule [NOTIFIKASI]
                                      │         │
                                      │         └──► Send at reminder_time
                                      │
                                      └──► Sync to External Calendar


[User Activity] ──► Log all actions ──► [AUDIT_LOG]
                          │
                          └──► Track (create, update, delete, login, logout)


[System Scheduler] ──── Daily/Weekly/Monthly ────► [REPORTS]
                                                         │
                                                         ├──► Aggregate [PRESENSI]
                                                         │
                                                         ├──► Generate Statistics
                                                         │
                                                         ├──► Format (PDF/Excel)
                                                         │
                                                         └──► Send to Recipients


╔═══════════════════════════════════════════════════════════════════════════════╗
║                          FITUR UTAMA SISTEM                                    ║
╚═══════════════════════════════════════════════════════════════════════════════╝

1. 📋 PRESENSI OTOMATIS
   └─► RFID-based attendance tracking
   └─► Real-time verification
   └─► Multiple check-in methods

2. 📢 PENGUMUMAN & NOTIFIKASI
   └─► Targeted announcements
   └─► Multi-channel notifications
   └─► Read tracking

3. 📅 MANAJEMEN JADWAL
   └─► Event scheduling
   └─► Automated reminders
   └─► Calendar sync

4. 🎮 GAMIFIKASI
   └─► Point system
   └─► Achievement unlocking
   └─► Leaderboard ranking

5. 📊 REPORTING
   └─► Attendance reports
   └─► Statistical analysis
   └─► Export to PDF/Excel

6. 🔐 AUDIT & SECURITY
   └─► Activity logging
   └─► Role-based access
   └─► Data integrity

7. 👥 USER MANAGEMENT
   └─► Multi-role support
   └─► Profile management
   └─► Soft delete capability
```

## Database Size Estimation

### Estimasi Jumlah Record (1 tahun operasi)

```
┌─────────────────────┬──────────────┬──────────────────┬─────────────────┐
│  Table              │  Records     │  Avg Size/Row    │  Total Size     │
├─────────────────────┼──────────────┼──────────────────┼─────────────────┤
│ USERS               │  1,000       │  2 KB            │  2 MB           │
│ PRESENSI            │  200,000     │  1 KB            │  200 MB         │
│ PENGUMUMAN          │  500         │  5 KB            │  2.5 MB         │
│ JADWAL              │  1,000       │  3 KB            │  3 MB           │
│ NOTIFIKASI          │  500,000     │  1 KB            │  500 MB         │
│ POINT_TRANSACTIONS  │  300,000     │  0.5 KB          │  150 MB         │
│ ACHIEVEMENTS        │  100         │  2 KB            │  200 KB         │
│ USER_ACHIEVEMENTS   │  10,000      │  0.5 KB          │  5 MB           │
│ LEADERBOARD         │  4,000       │  0.5 KB          │  2 MB           │
│ EVENT_PARTICIPANTS  │  20,000      │  0.5 KB          │  10 MB          │
│ EVENT_REMINDERS     │  60,000      │  0.5 KB          │  30 MB          │
│ ANNOUNCEMENT_READS  │  50,000      │  0.3 KB          │  15 MB          │
│ REPORTS             │  1,000       │  10 KB           │  10 MB          │
│ AUDIT_LOG           │  1,000,000   │  2 KB            │  2 GB           │
├─────────────────────┼──────────────┼──────────────────┼─────────────────┤
│ TOTAL               │  ~2,147,600  │  -               │  ~2.9 GB        │
└─────────────────────┴──────────────┴──────────────────┴─────────────────┘
```

**Catatan:**

- Estimasi untuk sekolah dengan ~1000 user (santri + guru)
- Asumsi presensi 2x sehari, 200 hari/tahun
- Belum termasuk index dan overhead
- Recommended storage: **10 GB** untuk data + index + growth

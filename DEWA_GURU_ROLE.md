# Role Dewan Guru - Dokumentasi

## Overview
Role "Dewan Guru" telah ditambahkan ke dalam aplikasi SiSantri dengan fitur-fitur khusus untuk monitoring dan pengawasan santri.

## Fitur Dewan Guru

### 1. Dashboard Khusus
- Halaman dashboard dengan informasi ringkas
- Kartu selamat datang dengan identitas Dewan Guru
- Statistik cepat (Total Santri, Kehadiran Hari Ini)
- Menu navigasi khusus untuk fitur-fitur Dewan Guru

### 2. Rangkuman Presensi (`PresensiSummaryPage`)
- **Tab Ringkasan**: Kartu statistik kehadiran, grafik harian, aktivitas terbaru
- **Tab Per Santri**: Daftar presensi per santri dengan detail hadir, terlambat, alpha
- **Tab Statistik**: Distribusi kehadiran, trend mingguan, ranking kehadiran
- Filter berdasarkan periode (Hari Ini, Minggu Ini, Bulan Ini, Semester Ini)

### 3. Bottom Navigation Khusus
- Dashboard (Halaman utama Dewan Guru)
- Pengumuman (Melihat pengumuman)
- Jadwal (Jadwal kegiatan)
- Ranking (Leaderboard santri)
- Presensi (Rangkuman presensi)
- Profil (Pengaturan akun)

### 4. Akses Melalui Profile
- Menu "Dashboard Dewan Guru" di halaman profil
- Badge role "Dewan Guru" dengan warna ungu

## Perubahan Teknis

### 1. Model User (`UserModel`)
```dart
// Tambahan field role
final String role; // 'admin', 'santri', atau 'dewan_guru'

// Tambahan getter
bool get isDewaGuru => role == 'dewan_guru';
```

### 2. Navigation System
- `RoleBasedNavigation`: Menentukan navigasi berdasarkan role
- `DewaGuruNavigation`: Bottom navigation khusus Dewan Guru
- `MainNavigation`: Untuk Admin dan Santri

### 3. Files Baru
- `/features/admin/presentation/dewa_guru_dashboard_page.dart`
- `/features/presensi/presentation/presensi_summary_page.dart`
- `/features/dashboard/presentation/dewa_guru_navigation.dart`
- `/features/dashboard/presentation/role_based_navigation.dart`

## Cara Membuat User Dewan Guru

### 1. Manual di Database
Update field `role` user di Firestore menjadi `'dewan_guru'`

### 2. Programmatically
```dart
await AuthService.updateUserRole(userId, 'dewan_guru');
```

### 3. Admin Panel
Tambahkan fitur di Admin Panel untuk mengubah role user

## Testing

### 1. Login sebagai Dewan Guru
1. Buat user dengan role `'dewan_guru'`
2. Login dengan kredensial user tersebut
3. Verifikasi bottom navigation menampilkan 6 tab
4. Verifikasi akses ke semua fitur Dewan Guru

### 2. Verifikasi Profile Page
1. Buka halaman Profile
2. Pastikan badge menampilkan "Dewan Guru" dengan warna ungu
3. Pastikan menu "Dashboard Dewan Guru" tersedia

### 3. Test Presensi Summary
1. Buka tab Presensi di bottom navigation
2. Test semua 3 tab (Ringkasan, Per Santri, Statistik)
3. Test filter periode
4. Test detail santri

## Hak Akses Dewan Guru

### Yang Bisa Diakses:
- ✅ Dashboard khusus Dewan Guru
- ✅ Melihat pengumuman
- ✅ Melihat jadwal kegiatan
- ✅ Melihat ranking/leaderboard
- ✅ Melihat rangkuman presensi semua santri
- ✅ Mengubah profil sendiri
- ✅ Pengaturan keamanan akun

### Yang Tidak Bisa Diakses:
- ❌ Admin Panel (khusus admin)
- ❌ Melakukan presensi (khusus santri)
- ❌ Dashboard santri biasa

## Future Enhancements

### 1. Laporan Detail
- Export data presensi ke PDF/Excel
- Laporan bulanan/semester
- Analitik mendalam

### 2. Notifikasi
- Alert untuk santri yang sering terlambat
- Notifikasi presensi real-time
- Summary harian via email

### 3. Manajemen Santri
- Melihat detail profil santri
- Riwayat pelanggaran
- Catatan pembinaan

### 4. Integrasi RFID
- Monitor aktivitas RFID real-time
- Laporan penggunaan kartu RFID
- Troubleshooting kartu bermasalah

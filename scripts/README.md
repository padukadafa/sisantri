# Dummy Jadwal Data Script

Script untuk membuat data dummy jadwal dalam database Firestore.

## 🚀 Cara Penggunaan

### 1. Buat Jadwal Data Saja
```bash
cd /home/android/Documents/flutter/sisantri
dart scripts/create_dummy_jadwal.dart
```

### 2. Recreate Jadwal (Hapus lama, buat baru)
```bash
dart scripts/create_dummy_jadwal.dart --recreate
```

### 3. Buat Semua Dummy Data (Users, Jadwal, Pengumuman)
```bash
dart scripts/create_dummy_jadwal.dart --all
```

## 📅 Data Yang Dibuat

Script akan membuat 11 jadwal dengan kategori berbeda:

### 🕌 Sholat (2 jadwal)
- Sholat Subuh Berjamaah (04:30-05:00)
- Sholat Maghrib Berjamaah (18:00-18:30)

### 📖 Kajian/Pengajian (2 jadwal)
- Kajian Tafsir Al-Quran (Selasa 19:30-21:00)
- Pengajian Akhlak (Rabu 20:00-21:30)

### 📚 Tahfidz (2 jadwal)
- Tahfidz Al-Quran Senin (06:00-07:30) - Juz 30
- Tahfidz Al-Quran Kamis (06:00-07:30) - Juz 1

### 🧹 Kerja Bakti (1 jadwal)
- Kerja Bakti Kebersihan (Sabtu 07:00-09:00)

### 🏃 Olahraga (2 jadwal)
- Senam Pagi (Minggu 05:30-06:30)
- Futsal Santri (Jumat 16:00-17:30)

### 📋 Kegiatan Umum (1 jadwal)
- Rapat Koordinasi Santri (Senin 19:00-20:30)

### ❌ Testing (1 jadwal tidak aktif)
- Kegiatan Lama (isAktif: false)

## 🔧 Features

- **isAktif field**: Semua jadwal memiliki status aktif/tidak aktif
- **Kategori lengkap**: Sholat, Kajian, Tahfidz, Kerja Bakti, Olahraga, Kegiatan
- **Data pengajian**: Pemateri dan tema untuk kajian/pengajian
- **Waktu detail**: Waktu mulai dan selesai
- **Timestamp**: CreatedAt dan updatedAt otomatis

## 📱 Integrasi dengan Manual Attendance

Data ini akan langsung tersedia di halaman **Manual Attendance** admin:
- Dropdown akan menampilkan 5 kegiatan terbaru yang aktif
- Jika tidak ada jadwal aktif, akan fallback ke jadwal terbaru
- Kategori ditampilkan dengan color coding
- Info detail: hari, waktu, tempat

## 🛠️ Maintenance

### Hapus Semua Data
```dart
await DummyDataService.deleteAllDummyData();
```

### Recreate Jadwal Saja
```dart
await DummyDataService.recreateJadwalData();
```

### Cek Data Existing
```dart
bool hasData = await DummyDataService.hasExistingData();
```

## ⚠️ Catatan Penting

1. Script membutuhkan Firebase sudah dikonfigurasi
2. Firestore harus sudah diaktifkan
3. Pastikan index tersedia untuk query dengan `orderBy`
4. Data akan ditambahkan ke collection `jadwal`

## 📊 Collection Structure

```firestore
jadwal/
├── document_id/
│   ├── nama: string
│   ├── tanggal: timestamp
│   ├── waktuMulai: string?
│   ├── waktuSelesai: string?
│   ├── hari: string
│   ├── kategori: string (enum)
│   ├── tempat: string?
│   ├── deskripsi: string?
│   ├── pemateri: string? (untuk pengajian)
│   ├── tema: string? (untuk pengajian)
│   ├── isAktif: boolean
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
```

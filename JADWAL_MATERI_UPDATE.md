# Update Form Tambah/Edit Jadwal

## Perubahan yang Dilakukan

### 1. Model JadwalKegiatan (jadwal_kegiatan_model.dart)

Menambahkan field baru untuk informasi materi kajian/pengajian:

**Field Baru:**

- `pemateri` - Nama pemateri/ustadz (untuk pengajian/kajian)
- `tema` - Tema/judul kajian (untuk pengajian/kajian)
- `hadistMulai` - Nomor hadist mulai (untuk kitab hadist)
- `hadistSelesai` - Nomor hadist selesai (untuk kitab hadist)
- `topikBahasan` - Topik spesifik yang dibahas

**Field yang Sudah Ada (dipertahankan):**

- `surah` - Nama surah (untuk kajian Quran/Tahfidz)
- `ayatMulai` - Ayat mulai
- `ayatSelesai` - Ayat selesai
- `halamanMulai` - Halaman mulai (untuk kitab umum)
- `halamanSelesai` - Halaman selesai (untuk kitab umum)
- `catatan` - Catatan tambahan

### 2. Widget MateriFormSection (materi_form_section.dart)

Widget baru untuk menampilkan form input materi kajian secara dinamis berdasarkan kategori jadwal.

**Fitur:**

- Tampil otomatis hanya untuk kategori: `pengajian`, `kajian`, `tahfidz`
- Field yang ditampilkan disesuaikan dengan kategori:
  - **Pengajian/Kajian:** Pemateri, Tema, Topik Bahasan
  - **Kajian Al-Quran/Tahfidz:** Surah, Ayat Mulai, Ayat Selesai
  - **Kajian Kitab:** Halaman Mulai, Halaman Selesai
  - **Kajian Hadist:** Hadist Mulai, Hadist Selesai
- Validasi input untuk field numerik (ayat, halaman, hadist)
- Validasi range (nilai selesai >= nilai mulai)

### 3. Add/Edit Jadwal Page (add_edit_jadwal_page.dart)

Update halaman form untuk mengintegrasikan form materi:

**Perubahan:**

- Menambahkan 10 TextEditingController baru untuk field materi
- Menambahkan kategori `pengajian` ke daftar pilihan
- Integrasi `MateriFormSection` widget
- Update logic `_initializeForm()` untuk load data materi saat edit
- Update logic `_saveJadwal()` untuk save data materi
- Helper function untuk parsing data (parseIntOrNull, stringOrNull)

## Cara Menggunakan

### Menambah Jadwal Pengajian/Kajian:

1. Pilih kategori: **Pengajian**, **Kajian**, atau **Tahfidz**
2. Isi informasi dasar (nama, deskripsi, tempat, waktu)
3. **Form materi akan muncul otomatis** dengan field:
   - Pemateri/Ustadz (opsional)
   - Tema/Judul Kajian (opsional)
   - Topik Bahasan (opsional)
   - Surah (opsional) - untuk kajian Quran
   - Ayat Mulai & Selesai (opsional)
   - Halaman Mulai & Selesai (opsional) - untuk kitab
   - Hadist Mulai & Selesai (opsional) - untuk kitab hadist
4. Isi field yang relevan sesuai kebutuhan
5. Simpan jadwal

### Catatan Penting:

- ✅ Semua field materi bersifat **opsional**
- ✅ Form materi **hanya muncul** untuk kategori pengajian/kajian/tahfidz
- ✅ Validasi otomatis untuk field numerik (harus angka > 0)
- ✅ Validasi range (ayat/halaman/hadist selesai >= mulai)
- ✅ Data materi tersimpan di Firestore bersama jadwal

## Contoh Use Case

### Contoh 1: Kajian Al-Quran

```
Kategori: Kajian
Nama: Kajian Tafsir
Pemateri: Ustadz Ahmad
Tema: Tafsir Surah Al-Baqarah
Surah: Al-Baqarah
Ayat Mulai: 1
Ayat Selesai: 20
Topik Bahasan: Pembahasan awal surah tentang orang beriman
```

### Contoh 2: Pengajian Kitab

```
Kategori: Pengajian
Nama: Pengajian Bulughul Maram
Pemateri: Ustadz Ibrahim
Tema: Bab Thaharah
Halaman Mulai: 15
Halaman Selesai: 25
Topik Bahasan: Hukum-hukum bersuci
```

### Contoh 3: Tahfidz

```
Kategori: Tahfidz
Nama: Setoran Hafalan
Surah: Al-Mulk
Ayat Mulai: 1
Ayat Selesai: 10
Topik Bahasan: Hafalan Juz 29
```

## Testing

- [x] Model update - compile success
- [x] Widget MateriFormSection - compile success
- [x] Add/Edit page integration - compile success
- [ ] Manual test: Tambah jadwal pengajian
- [ ] Manual test: Tambah jadwal kajian
- [ ] Manual test: Tambah jadwal tahfidz
- [ ] Manual test: Edit jadwal dengan data materi
- [ ] Manual test: Validasi form materi

---

**Update Date:** 6 November 2025  
**Status:** ✅ Implementation Complete - Ready for Testing

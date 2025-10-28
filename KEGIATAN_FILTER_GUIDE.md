# Filter Tanggal Kegiatan - User Guide

## 📅 Overview

Fitur filter tanggal kegiatan memungkinkan pengguna untuk menyaring dan melihat jadwal kegiatan berdasarkan:

- **Tanggal Tertentu**: Lihat kegiatan di tanggal spesifik (contoh: 21 Oktober 2025)
- **Bulan Tertentu**: Lihat semua kegiatan dalam bulan tertentu (contoh: Oktober 2025)
- **Rentang Tanggal**: Lihat kegiatan dalam periode waktu (contoh: 21 Oktober - 30 Oktober 2025)
- **Semua Kegiatan**: Tampilkan semua kegiatan tanpa filter

## 🎯 Fitur Utama

### 1. **Mode Filter**

#### a. Semua Kegiatan (Default)

- Menampilkan semua jadwal kegiatan yang tersedia
- Tidak ada pembatasan tanggal
- Icon: ♾️ (all_inclusive)

#### b. Filter Tanggal Tertentu

- Pilih satu tanggal spesifik
- Hanya menampilkan kegiatan di tanggal yang dipilih
- Icon: 📅 (event)
- Format: "21 Okt 2025"

#### c. Filter Bulan

- Pilih bulan dan tahun
- Menampilkan semua kegiatan dalam bulan tersebut
- Icon: 📆 (calendar_month)
- Format: "Oktober 2025"

#### d. Filter Rentang Tanggal

- Pilih tanggal mulai dan tanggal akhir
- Menampilkan kegiatan dalam rentang tersebut
- Icon: 📊 (date_range)
- Format: "21 Okt 2025 - 30 Okt 2025"

### 2. **UI Components**

#### Filter Chips

```
┌─────────────────────────────────────────────┐
│ 🔍 Filter Kegiatan:            [Reset]      │
├─────────────────────────────────────────────┤
│ [♾️ Semua] [📅 Tanggal] [📆 Bulan] [📊 Rentang]│
├─────────────────────────────────────────────┤
│ ℹ️ Oktober 2025                              │
└─────────────────────────────────────────────┘
```

- **Filter Chips**: Tombol pilihan untuk memilih mode filter
- **Reset Button**: Menghapus filter dan kembali ke "Semua Kegiatan"
- **Info Banner**: Menampilkan filter aktif dengan format yang jelas

#### Date Pickers

1. **Single Date Picker**: Dialog kalender standar Flutter
2. **Month Picker**: Dialog custom dengan grid bulan (3 kolom)
3. **Date Range Picker**: Dialog range picker standar Flutter

## 🔧 Implementasi Teknis

### Architecture

```
jadwal_page.dart
├── DateFilterMode (Enum)
│   ├── all
│   ├── singleDate
│   ├── month
│   └── dateRange
│
├── DateFilterModel (Class)
│   ├── mode: DateFilterMode
│   ├── singleDate: DateTime?
│   ├── startDate: DateTime?
│   ├── endDate: DateTime?
│   ├── month: int?
│   ├── year: int?
│   ├── matchesDate(DateTime) → bool
│   └── displayText → String
│
├── Providers
│   ├── kegiatanDateFilterProvider (StateProvider)
│   └── filteredKegiatanProvider (Provider)
│
└── Widgets
    ├── _JadwalKegiatanTab
    ├── _buildFilterChip
    ├── _showDatePickerForMode
    └── _MonthPickerDialog
```

### State Management (Riverpod)

#### 1. **kegiatanDateFilterProvider**

```dart
final kegiatanDateFilterProvider = StateProvider<DateFilterModel>((ref) {
  return DateFilterModel(); // Default: mode = all
});
```

- Menyimpan state filter yang aktif
- Dapat di-update dengan berbagai mode filter

#### 2. **filteredKegiatanProvider**

```dart
final filteredKegiatanProvider = Provider<AsyncValue<List<JadwalKegiatanModel>>>((ref) {
  final kegiatanAsync = ref.watch(jadwalKegiatanProvider);
  final filter = ref.watch(kegiatanDateFilterProvider);

  return kegiatanAsync.whenData((kegiatanList) {
    if (filter.mode == DateFilterMode.all) {
      return kegiatanList;
    }
    return kegiatanList.where((kegiatan) {
      return filter.matchesDate(kegiatan.tanggal);
    }).toList();
  });
});
```

- Reaktif terhadap perubahan filter
- Otomatis mem-filter data kegiatan
- Mengembalikan AsyncValue untuk handling loading/error state

### Filter Logic

#### DateFilterModel.matchesDate()

```dart
bool matchesDate(DateTime date) {
  switch (mode) {
    case DateFilterMode.all:
      return true; // Semua kegiatan lolos filter

    case DateFilterMode.singleDate:
      // Cek apakah tanggal sama persis (tahun, bulan, hari)
      return date.year == singleDate!.year &&
          date.month == singleDate!.month &&
          date.day == singleDate!.day;

    case DateFilterMode.month:
      // Cek apakah bulan dan tahun sama
      return date.month == month && date.year == year;

    case DateFilterMode.dateRange:
      // Cek apakah tanggal dalam rentang (inklusif)
      return date.isAfter(startDate!.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate!.add(const Duration(days: 1)));
  }
}
```

## 🎨 User Experience

### Workflow Pengguna

1. **Buka Tab Kegiatan**

   - Navigasi: Dashboard → Kalender → Tab "Kegiatan"
   - Default: Menampilkan semua kegiatan

2. **Pilih Mode Filter**

   - Tap salah satu chip filter: Tanggal / Bulan / Rentang
   - Dialog picker akan muncul otomatis

3. **Pilih Tanggal/Bulan/Rentang**

   - **Tanggal**: Pilih dari kalender
   - **Bulan**: Pilih bulan dari grid, adjust tahun dengan arrow
   - **Rentang**: Pilih tanggal mulai dan akhir

4. **Lihat Hasil Filter**

   - List otomatis ter-update
   - Info banner menampilkan filter aktif
   - Empty state jika tidak ada kegiatan

5. **Reset Filter** (Optional)
   - Tap tombol "Reset" di kanan atas
   - Kembali ke mode "Semua Kegiatan"

### Visual Feedback

- ✅ **Selected Chip**: Background hijau, text bold, checkmark
- ℹ️ **Info Banner**: Background hijau transparan dengan icon info
- 📭 **Empty State**: Icon dan text abu-abu dengan pesan kontekstual
- 🔄 **Loading**: Circular progress indicator saat fetch data
- ❌ **Error**: Icon error merah dengan tombol "Coba Lagi"

## 📱 Screenshots (Conceptual)

### Filter Semua

```
┌─────────────────────────────────┐
│ 🔍 Filter Kegiatan:             │
│ [✓ Semua] [ Tanggal] [ Bulan]   │
│                                 │
│ Kajian Tafsir                   │
│ 📅 21 Okt 2025  🕐 08:00       │
│                                 │
│ Olahraga Pagi                   │
│ 📅 22 Okt 2025  🕐 06:00       │
│                                 │
│ Halaqah Hafalan                 │
│ 📅 25 Okt 2025  🕐 14:00       │
└─────────────────────────────────┘
```

### Filter Tanggal (21 Oktober)

```
┌─────────────────────────────────┐
│ 🔍 Filter Kegiatan:      [Reset]│
│ [ Semua] [✓ Tanggal] [ Bulan]  │
│ ℹ️ 21 Okt 2025                  │
│                                 │
│ Kajian Tafsir                   │
│ 📅 21 Okt 2025  🕐 08:00       │
│                                 │
│ Dzikir Bersama                  │
│ 📅 21 Okt 2025  🕐 16:00       │
└─────────────────────────────────┘
```

### Filter Bulan (Oktober 2025)

```
┌─────────────────────────────────┐
│ 🔍 Filter Kegiatan:      [Reset]│
│ [ Semua] [ Tanggal] [✓ Bulan]  │
│ ℹ️ Oktober 2025                 │
│                                 │
│ 15 kegiatan dalam Oktober 2025  │
│                                 │
│ Kajian Tafsir                   │
│ 📅 21 Okt 2025  🕐 08:00       │
│ ...                             │
└─────────────────────────────────┘
```

### Empty State dengan Filter

```
┌─────────────────────────────────┐
│ 🔍 Filter Kegiatan:      [Reset]│
│ [ Semua] [✓ Tanggal] [ Bulan]  │
│ ℹ️ 15 Nov 2025                  │
│                                 │
│          📭                     │
│   Tidak ada kegiatan            │
│   15 Nov 2025                   │
│                                 │
└─────────────────────────────────┘
```

## 🧪 Testing Scenarios

### 1. Filter Tanggal Tertentu

- [ ] Pilih tanggal hari ini → Harus muncul kegiatan hari ini
- [ ] Pilih tanggal tanpa kegiatan → Empty state dengan pesan jelas
- [ ] Pilih tanggal lalu switch ke filter lain → State ter-reset

### 2. Filter Bulan

- [ ] Pilih bulan sekarang → Muncul kegiatan bulan ini
- [ ] Ganti tahun dengan arrow → Grid bulan tetap stabil
- [ ] Pilih bulan lalu → Data ter-filter sesuai bulan lalu

### 3. Filter Rentang Tanggal

- [ ] Pilih rentang 1 minggu → Kegiatan dalam minggu itu muncul
- [ ] Pilih rentang dengan satu tanggal → Error handling
- [ ] Rentang melewati ganti bulan → Filter tetap akurat

### 4. Reset Filter

- [ ] Tap Reset saat ada filter aktif → Kembali ke mode "Semua"
- [ ] Reset button hidden saat mode "Semua"

### 5. Edge Cases

- [ ] Tidak ada koneksi internet → Error state dengan retry
- [ ] Data kosong dari Firebase → Empty state "Belum ada jadwal"
- [ ] Filter terlalu spesifik → Empty state "Tidak ada kegiatan [filter]"

## 🚀 Future Enhancements

### Potential Features

1. **Quick Filters**: "Hari ini", "Minggu ini", "Bulan ini" shortcut buttons
2. **Filter Kategori**: Filter berdasarkan jenis kegiatan (Kajian, Olahraga, dll)
3. **Save Filters**: Simpan preferensi filter pengguna
4. **Calendar View**: Visualisasi kegiatan dalam bentuk kalender
5. **Export**: Export kegiatan ter-filter ke PDF/Excel
6. **Reminder**: Set reminder untuk kegiatan yang akan datang
7. **Search**: Pencarian nama kegiatan dalam hasil filter
8. **Sort Options**: Urutkan berdasarkan tanggal/nama/lokasi

### Performance Improvements

1. **Caching**: Cache hasil filter untuk performa lebih cepat
2. **Pagination**: Lazy loading untuk list kegiatan yang panjang
3. **Optimistic Updates**: Update UI sebelum data dari Firebase
4. **Index Firebase**: Tambah composite index untuk query lebih cepat

## 📚 Related Files

- **Page**: `/lib/features/jadwal/presentation/jadwal_page.dart`
- **Models**: `/lib/shared/models/jadwal_kegiatan_model.dart`
- **Service**: `/lib/shared/services/firestore_service.dart`
- **Theme**: `/lib/core/theme/app_theme.dart`

## 🎓 Learning Resources

### Flutter Date Pickers

- [showDatePicker](https://api.flutter.dev/flutter/material/showDatePicker.html)
- [showDateRangePicker](https://api.flutter.dev/flutter/material/showDateRangePicker.html)
- [DateFormat (intl)](https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html)

### Riverpod State Management

- [StateProvider](https://riverpod.dev/docs/providers/state_provider)
- [Provider](https://riverpod.dev/docs/providers/provider)
- [Combining Providers](https://riverpod.dev/docs/concepts/combining_providers)

---

**Created**: 21 Oktober 2025  
**Version**: 1.0.0  
**Status**: ✅ Implemented & Documented

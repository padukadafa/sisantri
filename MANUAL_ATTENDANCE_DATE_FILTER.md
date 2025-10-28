# Manual Attendance - Date Filter Feature

## 📋 Overview

Fitur filter tanggal pada halaman **Manual Attendance** memungkinkan admin untuk memilih tanggal tertentu dan melihat kegiatan yang sesuai dengan hari tersebut.

---

## ✨ Features

### 1. **Date Picker**

- Pilih tanggal dari date picker (default English locale)
- Display format: "Senin, 21 Oktober 2025" (custom Indonesian format)
- DatePicker dialog: English (no locale initialization required)
- Selected date display: Indonesian via custom formatter
- Range: 2020 - 1 tahun ke depan
- Default: Hari ini

### 2. **Auto Filter Activities**

- Kegiatan otomatis di-filter berdasarkan hari dari tanggal yang dipilih
- Contoh: Pilih tanggal Senin → muncul semua kegiatan hari Senin
- Limit: 10 kegiatan per hari

### 3. **Smart Fallback**

- Jika tidak ada kegiatan di hari tersebut, tampilkan semua kegiatan aktif
- Fallback jika index Firebase tidak tersedia

---

## 🎯 How It Works

### Flow:

1. User membuka halaman **Absensi Manual**
2. Default tanggal adalah hari ini
3. User tap pada field tanggal untuk membuka date picker
4. Pilih tanggal → Sistem mencari hari (Senin, Selasa, dst)
5. Provider `activitiesByDateProvider` query kegiatan berdasarkan hari
6. Dropdown "Kegiatan" menampilkan kegiatan yang sesuai
7. Selected activity otomatis direset saat ganti tanggal

### Provider Logic:

```dart
activitiesByDateProvider(DateTime selectedDate)
├─ Get day name (Senin, Selasa, ..., Minggu)
├─ Query: jadwal collection
│  ├─ where('isAktif', isEqualTo: true)
│  ├─ where('hari', isEqualTo: selectedDay)
│  ├─ orderBy('createdAt', descending: true)
│  └─ limit(10)
├─ Fallback 1: Jika kosong, ambil semua kegiatan aktif
└─ Fallback 2: Jika error index, ambil tanpa filter hari
```

---

## 🔧 Technical Implementation

### Custom Date Formatter:

```dart
String _formatDateIndonesia(DateTime date) {
  final dayNames = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
  final monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final dayName = dayNames[date.weekday % 7];
  final day = date.day;
  final monthName = monthNames[date.month - 1];
  final year = date.year;

  return '$dayName, $day $monthName $year';
}
```

**Why Custom Formatter?**

- ✅ No need for `initializeDateFormatting()`
- ✅ No `intl` package dependency for this feature
- ✅ Avoids "Locale data has not been initialized" error
- ✅ Lightweight and performant

### State Management:

```dart
class _ManualAttendancePageState {
  DateTime _selectedDate = DateTime.now(); // Filter tanggal
  String? _selectedActivity; // Reset saat ganti tanggal
}
```

### Provider:

```dart
final activitiesByDateProvider = FutureProvider.family<List<JadwalModel>, DateTime>
```

### UI Components:

1. **Date Picker Field**

   - Icon: `Icons.calendar_today`
   - Format: `DateFormat('EEEE, dd MMMM yyyy', 'id_ID')`
   - Tap to open date picker

2. **Activity Dropdown**
   - Auto-refresh saat tanggal berubah
   - Show kategori badge (Ibadah, Belajar, Olahraga, etc)
   - Show waktu mulai-selesai

---

## 📱 UI/UX

### Layout:

```
┌─────────────────────────────────┐
│ [Absensi Manual]          [✓][≡]│
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ [Cari nama santri...]   [x] │ │
│ └─────────────────────────────┘ │
│                                  │
│ Pilih Tanggal:                  │
│ ┌─────────────────────────────┐ │
│ │ 📅 Senin, 21 Oktober 2025  ▼│ │
│ └─────────────────────────────┘ │
│                                  │
│ Kegiatan:                       │
│ ┌─────────────────────────────┐ │
│ │ 📅 IBADAH Sholat Subuh     ▼│ │
│ │     05:00 - 06:00           │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### User Interactions:

1. **Tap Date Field** → Opens date picker dialog
2. **Select Date** → Activities auto-refresh
3. **Select Activity** → Load santri list with attendance status
4. **Pull to Refresh** → Refresh data dengan tanggal saat ini

---

## 🎨 Visual Indicators

### Date Display:

- **Icon**: Calendar (blue)
- **Text**: Full date with day name in Indonesian
- **Format**: Custom helper function `_formatDateIndonesia()`
- **Example**: "Senin, 21 Oktober 2025"
- **Arrow**: Dropdown indicator
- **No Locale Init**: Uses custom formatting to avoid locale initialization

### Activity Badges:

- **IBADAH**: Purple
- **BELAJAR**: Blue
- **OLAHRAGA**: Green
- **LAINNYA**: Orange

---

## 🔄 Data Sync

### Refresh Behavior:

```dart
onRefresh() {
  ref.invalidate(santriListProvider);
  ref.invalidate(activitiesByDateProvider(_selectedDate)); // Use current date
  ref.invalidate(attendanceStatusProvider(_selectedActivity));
}
```

### Auto-reset:

- Selected activity direset saat ganti tanggal
- Memastikan tidak ada mismatch antara tanggal dan kegiatan

---

## 📊 Benefits

1. ✅ **Organized Attendance**

   - Admin bisa absen kegiatan di hari tertentu
   - Tidak perlu scroll banyak kegiatan

2. ✅ **Better UX**

   - Filter otomatis berdasarkan hari
   - Clear visual feedback

3. ✅ **Flexible**

   - Bisa absen kegiatan masa lalu (untuk koreksi)
   - Bisa lihat kegiatan masa depan

4. ✅ **Performance**
   - Query lebih spesifik (where hari)
   - Limit 10 kegiatan per query

---

## 🚀 Future Enhancements

Potential improvements:

1. Quick date shortcuts (Kemarin, Hari ini, Besok)
2. Date range picker (untuk bulk attendance)
3. Show jumlah kegiatan per tanggal
4. Calendar view dengan dots untuk tanggal yang ada kegiatan
5. Export attendance by date range

---

## 📝 Notes

- **Date Picker Dialog**: Uses default locale (English) - no initialization required
- **Display Format**: Custom Indonesian formatter `_formatDateIndonesia()`
- **No Locale Dependencies**: Avoids MaterialLocalizations issues
- Format hari: Senin, Selasa, Rabu, Kamis, Jumat, Sabtu, Minggu
- Kegiatan diurutkan berdasarkan `createdAt` descending
- Fallback mechanism untuk handling missing data/index

### Why No Indonesian Locale in DatePicker?

Using `locale: Locale('id', 'ID')` in `showDatePicker()` requires:

1. `MaterialLocalizations` to be initialized
2. `intl` package with locale data initialization
3. Additional setup in `MaterialApp`

**Solution**: Use default English picker + custom Indonesian display format

- ✅ No setup required
- ✅ No MaterialLocalizations errors
- ✅ Still shows Indonesian format to user
- ✅ Cleaner implementation

---

**Status**: ✅ Implemented and Working
**File**: `lib/features/admin/attendance_management/presentation/pages/manual_attendance_page.dart`

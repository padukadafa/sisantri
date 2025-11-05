# AnnouncementService Migration

## Overview

Pemisahan operasi pengumuman dari `FirestoreService` ke dedicated `AnnouncementService` untuk better separation of concerns dan code organization.

## Tanggal: November 5, 2025

---

## 🎯 Tujuan

1. **Separation of Concerns**: Memisahkan logic pengumuman dari FirestoreService
2. **Centralized Management**: Semua operasi pengumuman di satu tempat
3. **Better Maintainability**: Lebih mudah untuk maintain dan extend
4. **Consistent API**: API yang konsisten untuk semua operasi pengumuman

---

## 📁 File Baru yang Dibuat

### `lib/shared/services/announcement_service.dart`

Service baru yang menangani semua operasi pengumuman dengan fitur lengkap:

#### **READ OPERATIONS**

- ✅ `getAllPengumuman()` - Get semua pengumuman (Stream)
- ✅ `getPengumumanById(String id)` - Get pengumuman by ID (Future)
- ✅ `getActivePengumuman()` - Get pengumuman aktif saja (Stream)
- ✅ `getRecentPengumuman({int limit})` - Get recent pengumuman (Stream)
- ✅ `getPengumumanByCategory(String kategori)` - Filter by kategori (Stream)
- ✅ `getPengumumanByPriority(String prioritas)` - Filter by prioritas (Stream)
- ✅ `getHighPriorityPengumuman()` - Get high priority saja (Stream)
- ✅ `getPengumumanByPeriod({startDate, endDate})` - Get by periode (Future)

#### **CREATE OPERATIONS**

- ✅ `addPengumuman(PengumumanModel)` - Tambah pengumuman baru
- ✅ Returns document ID setelah create

#### **UPDATE OPERATIONS**

- ✅ `updatePengumuman(String id, PengumumanModel)` - Update pengumuman
- ✅ `updateActiveStatus(String id, bool isActive)` - Update status aktif
- ✅ `toggleActiveStatus(String id)` - Toggle status aktif
- ✅ `updatePriority(String id, String prioritas)` - Update prioritas

#### **DELETE OPERATIONS**

- ✅ `deletePengumuman(String id)` - Hard delete
- ✅ `softDeletePengumuman(String id)` - Soft delete (set isActive = false)

#### **BATCH OPERATIONS**

- ✅ `deleteBatchPengumuman(List<String> ids)` - Delete multiple
- ✅ `updateBatchActiveStatus(List<String> ids, bool isActive)` - Update batch status

#### **STATISTICS**

- ✅ `getPengumumanStats()` - Get statistik lengkap
  - total, active, inactive, expired
  - high_priority, medium_priority, low_priority
- ✅ `getPengumumanCountByCategory()` - Count by kategori

#### **SEARCH & FILTER**

- ✅ `searchPengumuman(String query)` - Search by judul/konten
- ✅ `filterPengumuman({kategori, prioritas, isActive, startDate, endDate})` - Filter dengan multiple criteria

#### **UTILITY**

- ✅ `isPengumumanExists(String id)` - Check existence
- ✅ `getTotalPengumumanCount()` - Total count
- ✅ `getActivePengumumanCount()` - Active count

---

## 🔄 File yang Dimodifikasi

### 1. **`lib/shared/services/firestore_service.dart`**

#### Before:

```dart
// Get recent pengumuman
final recentPengumumanSnapshot = await _firestore
    .collection('pengumuman')
    .orderBy('tanggal', descending: true)
    .limit(3)
    .get();
```

#### After:

```dart
import 'package:sisantri/shared/services/announcement_service.dart';

/// Service untuk mengelola operasi Firestore
/// Note: Untuk operasi pengumuman, gunakan AnnouncementService
class FirestoreService {
  // ...

  // Get recent pengumuman - use AnnouncementService
  final recentPengumumanStream =
      AnnouncementService.getRecentPengumuman(limit: 3);
  final recentPengumuman = await recentPengumumanStream.first;

  // ===== PENGUMUMAN OPERATIONS (Wrapper untuk AnnouncementService) =====

  /// Get recent pengumuman (wrapper method)
  static Stream<List<PengumumanModel>> getRecentPengumuman({int limit = 5}) {
    return AnnouncementService.getRecentPengumuman(limit: limit);
  }

  /// Get all pengumuman (wrapper method)
  static Stream<List<PengumumanModel>> getAllPengumuman() {
    return AnnouncementService.getAllPengumuman();
  }
}
```

**Changes**:

- ✅ Added import untuk AnnouncementService
- ✅ getDashboardData() sekarang menggunakan AnnouncementService
- ✅ Added wrapper methods untuk backward compatibility
- ✅ Added documentation note

---

### 2. **`lib/features/admin/announcement_management/presentation/providers/announcement_providers.dart`**

#### Before:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

final announcementProvider = StreamProvider<List<PengumumanModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('pengumuman')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) { ... });
});
```

#### After:

```dart
import 'package:sisantri/shared/services/announcement_service.dart';

final announcementProvider = StreamProvider<List<PengumumanModel>>((ref) {
  return AnnouncementService.getAllPengumuman();
});
```

**Changes**:

- ✅ Removed direct Firestore dependency
- ✅ Using AnnouncementService.getAllPengumuman()
- ✅ Cleaner code, single source of truth

---

### 3. **`lib/features/admin/announcement_management/presentation/pages/announcement_form_page.dart`**

#### Before:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _saveAnnouncement({required bool published}) async {
  final firestore = FirebaseFirestore.instance;
  // ... manual data mapping

  if (widget.announcement != null) {
    await firestore.collection('pengumuman').doc(id).update(data);
  } else {
    await firestore.collection('pengumuman').add(data);
  }
}
```

#### After:

```dart
import 'package:sisantri/shared/services/announcement_service.dart';

Future<void> _saveAnnouncement({required bool published}) async {
  final pengumumanModel = PengumumanModel(
    // ... proper model construction
  );

  if (widget.announcement != null) {
    await AnnouncementService.updatePengumuman(id, pengumumanModel);
  } else {
    await AnnouncementService.addPengumuman(pengumumanModel);
  }
}
```

**Changes**:

- ✅ Removed Firestore import
- ✅ Using PengumumanModel properly
- ✅ Using AnnouncementService methods
- ✅ Type-safe operations

---

### 4. **`lib/features/admin/announcement_management/presentation/pages/announcement_management_page.dart`**

#### Before:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Delete announcement from Firestore
await FirebaseFirestore.instance
    .collection('pengumuman')
    .doc(announcementId)
    .delete();
```

#### After:

```dart
import 'package:sisantri/shared/services/announcement_service.dart';

// Delete announcement using AnnouncementService
await AnnouncementService.deletePengumuman(announcementId);
```

**Changes**:

- ✅ Removed Firestore import
- ✅ Using AnnouncementService.deletePengumuman()
- ✅ Cleaner delete operation

---

### 5. **`lib/features/shared/pengumuman/presentation/pengumuman_page.dart`**

#### Before:

```dart
import 'package:sisantri/shared/services/firestore_service.dart';

final pengumumanProvider = StreamProvider<List<PengumumanModel>>((ref) {
  return FirestoreService.getPengumuman();
});
```

#### After:

```dart
import 'package:sisantri/shared/services/announcement_service.dart';

final pengumumanProvider = StreamProvider<List<PengumumanModel>>((ref) {
  return AnnouncementService.getActivePengumuman();
});
```

**Changes**:

- ✅ Using AnnouncementService.getActivePengumuman()
- ✅ Better semantic naming

---

## 📊 Statistics

### Lines of Code

- **AnnouncementService**: ~450 lines
- **Modified Files**: 5 files
- **Total Changes**: ~100 lines modified

### Methods Count

- **Total Methods**: 25 methods
- **Read Operations**: 8 methods
- **Create Operations**: 1 method
- **Update Operations**: 3 methods
- **Delete Operations**: 2 methods
- **Batch Operations**: 2 methods
- **Statistics**: 2 methods
- **Search & Filter**: 2 methods
- **Utility**: 3 methods

---

## ✅ Benefits

### 1. **Separation of Concerns**

- Pengumuman logic terpisah dari general Firestore operations
- Easier to locate announcement-related code
- Clear responsibility boundaries

### 2. **Code Reusability**

- Single source of truth untuk semua operasi pengumuman
- Consistent API across the app
- No code duplication

### 3. **Maintainability**

- Easier to update/modify announcement logic
- Centralized error handling
- Better testing capabilities

### 4. **Scalability**

- Easy to add new features
- Batch operations support
- Advanced filtering & search

### 5. **Type Safety**

- Proper use of PengumumanModel
- Compile-time error checking
- Better IDE support

---

## 🔍 Testing Checklist

### Read Operations

- [ ] getAllPengumuman() returns all pengumuman
- [ ] getActivePengumuman() filters inactive & expired
- [ ] getRecentPengumuman() respects limit parameter
- [ ] getPengumumanByCategory() filters correctly
- [ ] getPengumumanByPriority() filters correctly
- [ ] Search functionality works

### Create/Update Operations

- [ ] addPengumuman() creates new document
- [ ] updatePengumuman() updates existing document
- [ ] updateActiveStatus() changes status
- [ ] toggleActiveStatus() toggles correctly

### Delete Operations

- [ ] deletePengumuman() removes document
- [ ] softDeletePengumuman() sets isActive = false
- [ ] Batch delete works for multiple IDs

### Statistics

- [ ] getPengumumanStats() returns correct counts
- [ ] Category counts are accurate

### Integration

- [ ] Admin management page works
- [ ] Announcement form save/update works
- [ ] Dashboard shows recent pengumuman
- [ ] Providers refresh correctly

---

## 🚀 Usage Examples

### Get All Pengumuman

```dart
final stream = AnnouncementService.getAllPengumuman();
await for (final pengumumanList in stream) {
  print('Total: ${pengumumanList.length}');
}
```

### Get Active Pengumuman Only

```dart
final stream = AnnouncementService.getActivePengumuman();
```

### Add New Pengumuman

```dart
final newPengumuman = PengumumanModel(/* ... */);
final id = await AnnouncementService.addPengumuman(newPengumuman);
print('Created with ID: $id');
```

### Update Pengumuman

```dart
await AnnouncementService.updatePengumuman(id, updatedModel);
```

### Delete Pengumuman

```dart
// Hard delete
await AnnouncementService.deletePengumuman(id);

// Soft delete
await AnnouncementService.softDeletePengumuman(id);
```

### Search Pengumuman

```dart
final results = await AnnouncementService.searchPengumuman('kegiatan');
```

### Filter with Multiple Criteria

```dart
final filtered = await AnnouncementService.filterPengumuman(
  kategori: 'akademik',
  prioritas: 'tinggi',
  isActive: true,
  startDate: DateTime(2025, 1, 1),
);
```

### Get Statistics

```dart
final stats = await AnnouncementService.getPengumumanStats();
print('Total: ${stats['total']}');
print('Active: ${stats['active']}');
print('High Priority: ${stats['high_priority']}');
```

---

## 🔄 Migration Guide

### For Existing Code

#### Replace Direct Firestore Queries:

```dart
// Before
FirebaseFirestore.instance
    .collection('pengumuman')
    .where('isActive', isEqualTo: true)
    .snapshots();

// After
AnnouncementService.getActivePengumuman();
```

#### Replace FirestoreService Calls:

```dart
// Before (if existed)
FirestoreService.getPengumuman();

// After
AnnouncementService.getAllPengumuman();
```

#### Use Proper Models:

```dart
// Before
final data = {'judul': '...', 'konten': '...', ...};
await firestore.collection('pengumuman').add(data);

// After
final pengumuman = PengumumanModel(judul: '...', konten: '...', ...);
await AnnouncementService.addPengumuman(pengumuman);
```

---

## 📝 Notes

1. **Backward Compatibility**: FirestoreService masih memiliki wrapper methods untuk compatibility
2. **Stream vs Future**: Gunakan Stream untuk realtime updates, Future untuk one-time fetch
3. **Error Handling**: Semua methods throw Exception dengan descriptive message
4. **Firestore Rules**: Pastikan Firestore security rules sudah di-configure

---

## 🎓 Best Practices

1. **Always use AnnouncementService** untuk operasi pengumuman
2. **Don't access Firestore directly** untuk pengumuman
3. **Use proper models** (PengumumanModel) instead of raw maps
4. **Handle errors** properly dengan try-catch
5. **Use appropriate methods** (Stream vs Future)
6. **Invalidate providers** setelah create/update/delete

---

## 🔮 Future Enhancements

Possible improvements untuk AnnouncementService:

1. **Caching**: Add local caching untuk better performance
2. **Pagination**: Implement pagination untuk large datasets
3. **Image Upload**: Add support untuk upload gambar lampiran
4. **Push Notifications**: Integrate dengan FCM untuk push notifications
5. **Analytics**: Track views, clicks, engagement
6. **Scheduling**: Auto-publish pada waktu tertentu
7. **Versioning**: Track history/versions of pengumuman
8. **Templates**: Save dan reuse announcement templates

---

## ✅ Conclusion

Migration ke AnnouncementService memberikan:

- ✅ Better code organization
- ✅ Consistent API
- ✅ Type safety
- ✅ Easier maintenance
- ✅ Scalability

**Status**: ✅ **COMPLETED**
**No Breaking Changes**: Wrapper methods ensure backward compatibility
**No Errors**: All main announcement files compile successfully

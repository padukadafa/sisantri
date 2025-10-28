# Migrasi Role-Based Structure - Status Update

## Progress Migrasi: ~75%

### ✅ Completed Tasks:

1. **Folder Structure Created (100%)**

   - ✅ `/lib/features/admin/` dengan 8 subfeatures
   - ✅ `/lib/features/santri/` dengan 4 subfeatures
   - ✅ `/lib/features/dewan_guru/` dengan 3 subfeatures
   - ✅ `/lib/features/shared/` dengan 7 features

2. **Files Copied (100%)**

   - ✅ ~50 files sudah di-copy ke lokasi baru
   - ✅ Core navigation files sudah updated
   - ✅ DashboardPage → SantriDashboardPage renamed

3. **Import Paths Fixed (~90%)**

   - ✅ Relative imports (../) converted to absolute (package:sisantri/)
   - ✅ Core imports fixed
   - ✅ Shared imports fixed
   - ✅ Model imports mostly fixed
   - ✅ Pengumuman entity updated with compatibility getters

4. **Migration Scripts Created**
   - ✅ `migrate_role_based_imports.sh` - Main migration script
   - ✅ `fix_relative_imports.sh` - Fix relative imports
   - ✅ `comprehensive_import_fix.sh` - Comprehensive fix
   - ✅ `fix_pengumuman_imports.sh` - Fix Pengumuman imports
   - ✅ `fix_pengumuman_entity.sh` - Fix to use entity
   - ✅ `fix_to_pengumuman_model.sh` - Fix to use model

### 🔄 Remaining Issues:

#### 1. announcement_management_page.dart (~40 errors)

**Problem**: File ini merupakan copy dari versi lama yang menggunakan struktur PengumumanModel berbeda.

**Solution Options**:

- **A. Rewrite file** menggunakan PengumumanModel yang ada di shared
- **B. Delete dan recreate** dari scratch dengan model baru
- **C. Keep untuk reference**, buat file baru announcement_list_page.dart

**Recommended**: Option B - Delete dan create simple version dulu

#### 2. Old Feature Folders Cleanup

**Files to Delete**:

```
lib/features/auth/          → Moved to shared/auth/
lib/features/dashboard/     → Moved to santri/dashboard/
lib/features/presensi/      → Moved to santri/presensi/
lib/features/pengumuman/    → Moved to shared/pengumuman/
lib/features/leaderboard/   → Moved to santri/leaderboard/
lib/features/calendar/      → Moved to shared/calendar/
lib/features/notifications/ → Moved to shared/notifications/
lib/features/help/          → Moved to shared/help/
lib/features/settings/      → Moved to shared/settings/
lib/features/jadwal/        → Moved to shared/jadwal/
```

**Note**: Harus verify dulu bahwa semua yang penting sudah di-copy

#### 3. Provider References

Beberapa file masih reference provider yang salah:

- `pengumumanProvider` → harus `announcementProvider`
- `pengumumanStatsProvider` → harus `announcementStatsProvider`

### 📊 Error Count Progress:

- Start: **335 errors**
- After relative import fix: **61 errors**
- After pengumuman fix: **27 errors**
- Current: **~43 errors**

Most errors are from:

1. `announcement_management_page.dart` - duplicate model definition
2. `lib/features/presensi/presentation/bloc/presensi_provider.dart` - old folder
3. Property mismatches (authorName, tanggalExpired, attachments tidak ada di PengumumanModel baru)

### 🎯 Next Actions:

#### Immediate (High Priority):

1. **Fix announcement_management_page.dart**
   - Either refactor to use shared PengumumanModel
   - Or create new simpler version
2. **Delete old feature folders** setelah verify

   - Akan eliminate ~3 errors dari presensi_provider

3. **Add missing properties to PengumumanModel** (if needed)
   - Or update usage to use existing properties

#### Medium Priority:

4. **Test Navigation** untuk semua 3 roles
5. **Update main.dart** jika ada yang reference old structure
6. **Run flutter build** untuk check compilation

#### Low Priority:

7. Update PROJECT_STRUCTURE.md
8. Update README.md
9. Create migration documentation

### 🔍 Model Property Mapping:

**Old Pengumuman Model** (di announcement_management_page):

- `id`, `judul`, `konten`, `kategori`, `prioritas`
- `targetAudience` (List<String>)
- `tanggalPost` (DateTime)
- `tanggalExpired` (DateTime?)
- `isActive` (bool)
- `authorId`, `authorName`
- `viewCount` (int)
- `attachments` (List<String>)

**New PengumumanModel** (di shared/pengumuman):

- `id`, `judul`, `konten`, `kategori`, `prioritas`
- `targetAudience` (String) ← **DIFFERENT**
- `targetRoles` (List<String>)
- `targetClasses` (List<String>)
- `tanggalMulai` (DateTime)
- `tanggalBerakhir` (DateTime?)
- `isPublished` (bool) ← `isActive` as getter
- `createdBy`, `createdByName` ← instead of authorId/Name
- `viewCount` (int)
- `lampiranUrl` (String?) ← instead of attachments list
- `isPinned` (bool)
- `createdAt`, `updatedAt`

**Added Getters** for compatibility:

- `isActive` → returns `isPublished`
- `isExpired` → computed from `tanggalBerakhir`
- `isHighPriority` → `prioritas == 'high'`
- `tanggalPost` → returns `createdAt`

### 💡 Recommendations:

1. **For announcement_management**:

   - Update UI to use new model properties
   - Map `targetAudience` String to `targetRoles` List
   - Use `createdBy`/`createdByName` instead of `authorId`/`authorName`
   - Use `lampiranUrl` instead of `attachments` list

2. **For migration completion**:

   - Focus on getting new structure working
   - Delete old folders only after 100% verified
   - Keep one backup before deleting

3. **For testing**:
   - Test each role navigation separately
   - Verify Firebase data structure matches new model
   - May need to migrate Firebase data if structure changed

## Commands to Run Next:

```bash
# 1. Delete old feature folders (after backup)
rm -rf lib/features/auth lib/features/dashboard lib/features/presensi
rm -rf lib/features/pengumuman lib/features/leaderboard lib/features/calendar
rm -rf lib/features/notifications lib/features/help lib/features/settings lib/features/jadwal

# 2. Check remaining errors
flutter analyze 2>&1 | grep "error •" | wc -l

# 3. Test build
flutter build apk --debug
```

## Conclusion:

Migrasi sudah 75% selesai dengan struktur folder dan mayoritas import sudah fixed. Yang tersisa adalah:

1. Refactor announcement_management_page.dart
2. Cleanup old folders
3. Test dan verifikasi

Target: Selesaikan dalam 1-2 iterasi lagi.

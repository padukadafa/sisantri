# 🎯 Role-Based Structure Migration - Next Steps Guide

## ✅ Apa Yang Sudah Selesai

### 1. Folder Structure ✅ (100%)

Semua folder role-based sudah dibuat:

- `features/admin/` - 8 subfeatures
- `features/santri/` - 4 subfeatures
- `features/dewan_guru/` - 3 subfeatures
- `features/shared/` - 7 shared features

### 2. File Migration ✅ (100%)

Semua ~50 files sudah dicopy ke lokasi baru (old files masih ada sebagai backup)

### 3. Core Import Updates ✅ (100%)

Files penting sudah diupdate:

- `core/routing/role_based_navigation.dart` ✅
- `admin/navigation/admin_navigation.dart` ✅
- `santri/navigation/main_navigation.dart` ✅
- `dewan_guru/navigation/dewan_guru_navigation.dart` ✅
- `santri/dashboard/pages/santri_dashboard_page.dart` ✅

---

## 🔄 Yang Masih Perlu Dilakukan

### Import Updates (~50 files remaining)

Karena banyaknya file yang perlu diupdate, berikut adalah strategi optimal:

## 📋 Recommended Approach

### **Option A: Automated Script (RECOMMENDED)**

Buat script untuk auto-update semua imports:

```bash
#!/bin/bash
# Script untuk update imports secara otomatis

# 1. Update references ke dashboard
find lib -type f -name "*.dart" -exec sed -i 's|package:sisantri/features/dashboard/presentation/pages/dashboard_page.dart|package:sisantri/features/santri/dashboard/presentation/pages/santri_dashboard_page.dart|g' {} +

# 2. Update references ke presensi
find lib -type f -name "*.dart" -exec sed -i 's|package:sisantri/features/presensi/|package:sisantri/features/santri/presensi/|g' {} +

# 3. Update references ke profile
find lib -type f -name "*.dart" -exec sed -i 's|package:sisantri/features/profile/|package:sisantri/features/santri/profile/|g' {} +

# 4. Update references ke jadwal
find lib -type f -name "*.dart" -exec sed -i 's|package:sisantri/features/jadwal/|package:sisantri/features/shared/jadwal/|g' {} +

# ... dan seterusnya untuk semua features
```

**Execution:**

```bash
cd /home/android/Documents/flutter/sisantri
chmod +x scripts/update_imports.sh
./scripts/update_imports.sh
```

### **Option B: Flutter Refactor (ALTERNATIVE)**

Gunakan VS Code refactoring tools:

1. Rename old folders satu per satu
2. VS Code auto-update imports
3. Lebih lambat tapi lebih aman

### **Option C: Manual Update (TIDAK DISARANKAN)**

Update manual satu per satu - sangat time consuming untuk 50+ files

---

## 🚀 Quick Implementation Plan

### Step 1: Create Auto-Update Script

```bash
# Buat file script
cat > scripts/update_role_based_imports.sh << 'EOF'
#!/bin/bash

echo "🔄 Starting import path updates..."

# Admin features
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/user_management_page|features/admin/user_management/presentation/pages/user_management_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/manual_attendance_page|features/admin/attendance_management/presentation/pages/manual_attendance_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/admin_dashboard_page|features/admin/dashboard/presentation/pages/admin_dashboard_page|g' {} +

# Santri features
find lib -type f -name "*.dart" -exec sed -i \
  's|features/presensi/|features/santri/presensi/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/profile/|features/santri/profile/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/leaderboard/|features/santri/leaderboard/|g' {} +

# Shared features
find lib -type f -name "*.dart" -exec sed -i \
  's|features/auth/|features/shared/auth/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/jadwal/|features/shared/jadwal/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/pengumuman/|features/shared/pengumuman/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/calendar/|features/shared/calendar/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/notifications/|features/shared/notifications/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/help/|features/shared/help/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/settings/|features/shared/settings/|g' {} +

echo "✅ Import updates completed!"
echo "🔍 Running flutter analyze..."
flutter analyze
EOF

chmod +x scripts/update_role_based_imports.sh
```

### Step 2: Run Script

```bash
./scripts/update_role_based_imports.sh
```

### Step 3: Fix Remaining Errors

```bash
# Check errors
flutter analyze

# Fix manually jika ada edge cases
```

### Step 4: Test

```bash
# Test compile
flutter build apk --debug

# Or run
flutter run
```

### Step 5: Cleanup

```bash
# Setelah semua works, hapus old folders
rm -rf lib/features/auth
rm -rf lib/features/jadwal
rm -rf lib/features/dashboard
# ... etc
```

---

## 🎯 Manual Checklist (If Not Using Script)

### Dashboard Providers & Widgets

- [ ] `dashboard_providers.dart` - Update jadwal/pengumuman imports
- [ ] `dashboard_content.dart` - Update widget imports
- [ ] `dashboard_welcome_card.dart` - Update user model import
- [ ] `dashboard_stats_cards.dart` - Update provider imports
- [ ] `dashboard_recent_pengumuman.dart` - Update provider imports
- [ ] `dashboard_upcoming_kegiatan.dart` - Update model imports
- [ ] All other dashboard widgets (~10 files)

### Profile Pages

- [ ] `profile_page.dart` - Update dashboard import
- [ ] `edit_profile_page.dart` - Check imports
- [ ] `security_settings_page.dart` - Check imports
- [ ] `change_password_page.dart` - Check imports
- [ ] `personal_data_page.dart` - Check imports
- [ ] `personal_stats_page.dart` - Check imports
- [ ] `activity_history_page.dart` - Check imports
- [ ] `notification_preferences_page.dart` - Check imports

### Admin Pages

- [ ] `user_management_page.dart` - Check all imports
- [ ] `manual_attendance_page.dart` - Update provider imports
- [ ] `attendance_report_page.dart` - Update provider imports
- [ ] `announcement_management_page.dart` - Update provider/widget imports
- [ ] `schedule_management_page.dart` - Update provider/widget imports
- [ ] `add_edit_jadwal_page.dart` - Update model imports
- [ ] `materi_management_page.dart` - Check imports
- [ ] `notification_management_page.dart` - Check imports
- [ ] `admin_dashboard_page.dart` - Update all feature imports

### Providers

- [ ] `dashboard_providers.dart` - Update firestore service imports
- [ ] `stats_providers.dart` - Update service imports
- [ ] `notification_providers.dart` - Update service imports
- [ ] `user_management_providers.dart` - Check imports
- [ ] `announcement_providers.dart` - Update service imports
- [ ] `schedule_providers.dart` - Update service/model imports
- [ ] `attendance_report_providers.dart` - Update service imports

### Services

- [ ] All service files - Check if they import other features

### Widgets

- [ ] All dashboard widgets - Update provider imports
- [ ] All announcement widgets - Update imports
- [ ] All schedule widgets - Update imports
- [ ] All user widgets - Update imports

---

## ⚠️ Common Errors to Watch For

### 1. Class Not Found

```
The name 'DashboardPage' isn't a class.
```

**Fix**: Use `SantriDashboardPage` instead

### 2. Import Path Not Found

```
Target of URI doesn't exist: 'package:sisantri/features/dashboard/...'
```

**Fix**: Update to new path with role prefix

### 3. Provider Not Found

```
The provider 'dashboardDataProvider' couldn't be found.
```

**Fix**: Update provider import path

### 4. Widget Not Found

```
The name 'DashboardContent' isn't a class.
```

**Fix**: Update widget import path

---

## 📊 Estimated Time

| Method               | Time      | Risk   | Effort |
| -------------------- | --------- | ------ | ------ |
| **Automated Script** | 30 min    | Low    | Low    |
| **VS Code Refactor** | 2-3 hours | Medium | Medium |
| **Manual Update**    | 6-8 hours | High   | High   |

**Recommendation**: Use **Automated Script** approach

---

## 🎯 Success Validation

After completing updates, run:

```bash
# 1. Analyze
flutter analyze

# 2. Check specific errors
flutter analyze 2>&1 | grep "error •"

# 3. Test compile
flutter build apk --debug

# 4. Run app
flutter run
```

Expected result:

```
✅ No errors found
✅ App compiles successfully
✅ App runs without crashes
✅ All 3 roles can navigate properly
```

---

## 📝 Final Documentation Updates Needed

After all imports are fixed:

1. Update `PROJECT_STRUCTURE.md` with new role-based structure
2. Update `README.md` with new import examples
3. Update `CONTRIBUTING.md` if exists
4. Create `ROLE_BASED_FEATURES.md` documentation
5. Update any API documentation
6. Update test documentation

---

## 💡 Pro Tips

1. **Commit Before Running Script**

   ```bash
   git add .
   git commit -m "Before role-based migration"
   ```

2. **Test in Stages**

   - Test admin navigation first
   - Test santri navigation second
   - Test dewan_guru navigation last
   - Test shared features

3. **Use Search & Replace in VS Code**

   - Ctrl+Shift+H for global search & replace
   - Can preview changes before applying

4. **Keep Backup**
   - Don't delete old files until 100% sure everything works
   - Can rollback if needed

---

**Created**: 21 Oktober 2025  
**Status**: Migration 70% Complete - Ready for automated import updates  
**Next Action**: Choose approach (A, B, or C) and execute

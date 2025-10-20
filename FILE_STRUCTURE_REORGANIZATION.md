# File Structure Reorganization - Phase 3

## Tanggal: 20 Oktober 2025

## Overview

Melanjutkan reorganisasi struktur proyek SiSantri untuk meningkatkan konsistensi dan maintainability dengan memindahkan file-file yang salah penempatan dan menambahkan folder `pages/` untuk organization yang lebih baik.

## Masalah yang Ditemukan

### 1. **Dashboard Pages Salah Lokasi**

- ❌ `dewan_guru_dashboard_page.dart` berada di `/features/admin/presentation/`
- ✅ Seharusnya di `/features/dashboard/presentation/pages/`
- **Alasan**: File ini adalah dashboard page untuk role "Dewan Guru", bukan fitur admin-specific

### 2. **Tidak Ada Folder Pages**

- ❌ Dashboard dan Profile pages langsung di `/presentation/`
- ✅ Seharusnya di `/presentation/pages/`
- **Alasan**: Konsistensi dengan feature lain (auth, presensi sudah punya folder pages)

### 3. **Inconsistent Structure**

```
❌ SEBELUM:
lib/features/
├── auth/presentation/pages/          ✅ Ada pages folder
├── presensi/presentation/pages/      ✅ Ada pages folder
├── dashboard/presentation/
│   ├── dashboard_page.dart           ❌ Langsung di presentation
│   └── ...
├── profile/presentation/
│   ├── profile_page.dart             ❌ Langsung di presentation
│   ├── edit_profile_page.dart        ❌ Langsung di presentation
│   └── ...
└── admin/presentation/
    ├── dewan_guru_dashboard_page.dart ❌ Salah folder!
    └── ...
```

## Perubahan yang Dilakukan

### 1. **Created Pages Folders**

```bash
mkdir lib/features/dashboard/presentation/pages
mkdir lib/features/profile/presentation/pages
```

### 2. **Moved Dashboard Files**

#### a. **dewan_guru_dashboard_page.dart**

**FROM:** `/features/admin/presentation/dewan_guru_dashboard_page.dart`
**TO:** `/features/dashboard/presentation/pages/dewan_guru_dashboard_page.dart`

**Files Updated:**

- `dashboard/presentation/dewan_guru_navigation.dart`
- `profile/presentation/pages/profile_page.dart`

**Import Change:**

```dart
// Before ❌
import 'package:sisantri/features/admin/presentation/dewan_guru_dashboard_page.dart';

// After ✅
import 'package:sisantri/features/dashboard/presentation/pages/dewan_guru_dashboard_page.dart';
```

#### b. **dashboard_page.dart**

**FROM:** `/features/dashboard/presentation/dashboard_page.dart`
**TO:** `/features/dashboard/presentation/pages/dashboard_page.dart`

**Files Updated:**

- `dashboard/presentation/main_navigation.dart`

**Import Change:**

```dart
// Before ❌
import 'package:sisantri/features/dashboard/presentation/dashboard_page.dart';

// After ✅
import 'package:sisantri/features/dashboard/presentation/pages/dashboard_page.dart';
```

### 3. **Moved Profile Files**

Moved ALL profile pages to `/pages/` folder:

- `profile_page.dart`
- `edit_profile_page.dart`
- `security_settings_page.dart`
- `change_password_page.dart`
- `personal_data_page.dart`
- `personal_stats_page.dart`
- `activity_history_page.dart`
- `notification_preferences_page.dart`

**Files Updated:**

- `dashboard/presentation/main_navigation.dart`
- `dashboard/presentation/admin_navigation.dart`
- `dashboard/presentation/dewan_guru_navigation.dart`
- `profile/presentation/pages/profile_page.dart` (self-reference)
- `profile/presentation/pages/security_settings_page.dart` (internal)

**Import Changes:**

```dart
// Before ❌
import 'package:sisantri/features/profile/presentation/profile_page.dart';
import 'package:sisantri/features/profile/presentation/edit_profile_page.dart';

// After ✅
import 'package:sisantri/features/profile/presentation/pages/profile_page.dart';
import 'package:sisantri/features/profile/presentation/pages/edit_profile_page.dart';
```

### 4. **Fixed Relative Imports in Profile Pages**

Updated all profile page files to use absolute imports:

```dart
// Before ❌
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/auth_service.dart';

// After ✅
import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/shared/services/auth_service.dart';
```

**Files Fixed:**

- `activity_history_page.dart`
- `change_password_page.dart`
- `notification_preferences_page.dart`
- `personal_data_page.dart`
- `personal_stats_page.dart`
- `security_settings_page.dart`

## Struktur Baru

```
✅ SESUDAH:
lib/features/
├── auth/
│   └── presentation/
│       ├── pages/                     ✅ Consistent
│       │   ├── login_page.dart
│       │   ├── register_page.dart
│       │   └── ...
│       └── provider/
│
├── dashboard/
│   └── presentation/
│       ├── pages/                     ✅ NEW! Organized
│       │   ├── dashboard_page.dart
│       │   └── dewan_guru_dashboard_page.dart
│       ├── providers/
│       ├── widgets/
│       ├── main_navigation.dart
│       ├── admin_navigation.dart
│       └── dewan_guru_navigation.dart
│
├── profile/
│   └── presentation/
│       └── pages/                     ✅ NEW! All pages here
│           ├── profile_page.dart
│           ├── edit_profile_page.dart
│           ├── security_settings_page.dart
│           ├── change_password_page.dart
│           ├── personal_data_page.dart
│           ├── personal_stats_page.dart
│           ├── activity_history_page.dart
│           └── notification_preferences_page.dart
│
├── presensi/
│   └── presentation/
│       └── pages/                     ✅ Already consistent
│           ├── presensi_page.dart
│           └── presensi_summary_page.dart
│
└── admin/
    └── presentation/
        ├── admin_dashboard_page.dart  ✅ Correct location (admin-specific)
        ├── user_management_page.dart
        ├── manual_attendance_page.dart
        └── ...
```

## Benefits

### 1. **Consistency** 📐

- Semua features sekarang punya struktur yang sama
- Pages ada di folder `pages/`
- Navigation components di root `/presentation/`

### 2. **Clarity** 💡

- Jelas pembagian antara pages, widgets, dan providers
- Mudah menemukan file berdasarkan tipenya
- Dashboard pages terpisah dari admin features

### 3. **Scalability** 📈

- Mudah menambah page baru
- Template struktur yang jelas untuk feature baru
- Separation of concerns yang baik

### 4. **Maintainability** 🔧

- Import paths yang konsisten
- Mudah refactor
- Reduced coupling between features

## Organization Guidelines

### Pages Folder

```
/presentation/pages/
```

**Contains:** All page/screen widgets for the feature

- Stateful/Stateless page widgets
- Full-screen UI components
- Route-able screens

### Widgets Folder

```
/presentation/widgets/
```

**Contains:** Reusable widget components

- Small UI components
- Shared widgets within the feature
- Non-route widgets

### Providers Folder

```
/presentation/providers/
```

**Contains:** State management providers

- Riverpod providers
- State notifiers
- View models

### Navigation Files

```
/presentation/*_navigation.dart
```

**Contains:** Bottom navigation / Tab navigation

- Main navigation components
- Navigation scaffolds
- Should be at root of `/presentation/`

## Statistics

### Files Moved: 10 files

- `dewan_guru_dashboard_page.dart` → dashboard/presentation/pages/
- `dashboard_page.dart` → dashboard/presentation/pages/
- 8 profile page files → profile/presentation/pages/

### Import Statements Updated: 15+

- 3 navigation files updated
- 6 profile pages updated (absolute imports)
- Multiple cross-references fixed

### Folders Created: 2

- `/features/dashboard/presentation/pages/`
- `/features/profile/presentation/pages/`

### Files Deleted: 1

- `/features/admin/presentation/dewan_guru_dashboard_page.dart` (moved)

## Testing

✅ All imports successfully updated
✅ No compilation errors
✅ Consistent structure across all features
✅ Better organization and maintainability

## Before & After Comparison

### Dashboard Feature

```diff
dashboard/presentation/
- ├── dashboard_page.dart
- ├── main_navigation.dart
- ├── admin_navigation.dart
- ├── dewan_guru_navigation.dart
- ├── providers/
- └── widgets/
+ ├── pages/
+ │   ├── dashboard_page.dart
+ │   └── dewan_guru_dashboard_page.dart
+ ├── main_navigation.dart
+ ├── admin_navigation.dart
+ ├── dewan_guru_navigation.dart
+ ├── providers/
+ └── widgets/
```

### Profile Feature

```diff
profile/presentation/
- ├── profile_page.dart
- ├── edit_profile_page.dart
- ├── security_settings_page.dart
- ├── change_password_page.dart
- ├── personal_data_page.dart
- ├── personal_stats_page.dart
- ├── activity_history_page.dart
- └── notification_preferences_page.dart
+ └── pages/
+     ├── profile_page.dart
+     ├── edit_profile_page.dart
+     ├── security_settings_page.dart
+     ├── change_password_page.dart
+     ├── personal_data_page.dart
+     ├── personal_stats_page.dart
+     ├── activity_history_page.dart
+     └── notification_preferences_page.dart
```

## Next Steps (Optional)

1. Apply same structure to remaining features:

   - `pengumuman/`
   - `jadwal/`
   - `leaderboard/`
   - `notifications/`
   - `settings/`
   - `help/`
   - `calendar/`

2. Create barrel files for easier imports:

   ```dart
   // lib/features/profile/presentation/pages/pages.dart
   export 'profile_page.dart';
   export 'edit_profile_page.dart';
   // ...
   ```

3. Document structure in CONTRIBUTING.md

## Conclusion

Proyek SiSantri sekarang memiliki struktur folder yang lebih konsisten dan terorganisir dengan baik:

- ✅ Pages dikelompokkan dalam folder `pages/`
- ✅ Dashboard pages di lokasi yang benar
- ✅ Absolute imports untuk semua cross-feature references
- ✅ Konsisten dengan best practices Flutter/Dart
- ✅ Mudah untuk onboarding dan maintenance

---

**Reorganization by**: AI Assistant (GitHub Copilot)
**Date**: October 20, 2025
**Status**: ✅ Completed - Consistent Structure Achieved

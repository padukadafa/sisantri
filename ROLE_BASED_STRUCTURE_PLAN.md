# 🔄 Role-Based Feature Structure Reorganization Plan

## 📋 Current vs Proposed Structure

### ❌ **Current Structure** (Feature-based)

```
lib/features/
├── admin/                    # Mixed: admin-only & shared
├── auth/                     # Shared
├── calendar/                 # Shared
├── dashboard/                # Mixed: all roles
├── help/                     # Shared
├── jadwal/                   # Shared
├── leaderboard/              # Santri-focused
├── notifications/            # Shared
├── pengumuman/               # Shared (view), Admin (manage)
├── presensi/                 # Santri-focused
├── profile/                  # Shared
└── settings/                 # Shared
```

### ✅ **Proposed Structure** (Role-based)

```
lib/features/
├── admin/                           # 🔴 ADMIN ONLY
│   ├── user_management/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── user_management_page.dart
│   │   │   ├── providers/
│   │   │   └── widgets/
│   │   └── services/
│   ├── attendance_management/
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       ├── manual_attendance_page.dart
│   │   │       └── attendance_report_page.dart
│   ├── announcement_management/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── announcement_management_page.dart
│   │   │   ├── providers/
│   │   │   ├── widgets/
│   │   │   └── services/
│   ├── schedule_management/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── schedule_management_page.dart
│   │   │   │   └── add_edit_jadwal_page.dart
│   │   │   ├── providers/
│   │   │   ├── widgets/
│   │   │   └── services/
│   ├── materi_management/
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       └── materi_management_page.dart
│   ├── notification_management/
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       └── notification_management_page.dart
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── admin_dashboard_page.dart
│   │   │   └── widgets/
│   └── navigation/
│       └── admin_navigation.dart
│
├── santri/                          # 🔵 SANTRI ONLY
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── santri_dashboard_page.dart
│   │   │   ├── providers/
│   │   │   └── widgets/
│   ├── presensi/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── presensi_page.dart
│   │       │   └── presensi_summary_page.dart
│   │       └── bloc/
│   ├── leaderboard/
│   │   └── presentation/
│   │       └── pages/
│   │           └── leaderboard_page.dart
│   ├── profile/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── profile_page.dart
│   │       │   ├── edit_profile_page.dart
│   │       │   ├── security_settings_page.dart
│   │       │   ├── change_password_page.dart
│   │       │   ├── personal_data_page.dart
│   │       │   ├── personal_stats_page.dart
│   │       │   ├── activity_history_page.dart
│   │       │   └── notification_preferences_page.dart
│   └── navigation/
│       └── main_navigation.dart
│
├── dewan_guru/                      # 🟠 DEWAN GURU ONLY
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── dewan_guru_dashboard_page.dart
│   │   │   ├── providers/
│   │   │   └── widgets/
│   ├── monitoring/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── santri_monitoring_page.dart
│   │       │   └── attendance_monitoring_page.dart
│   │       └── widgets/
│   ├── approval/
│   │   └── presentation/
│   │       └── pages/
│   │           └── approval_page.dart
│   └── navigation/
│       └── dewan_guru_navigation.dart
│
└── shared/                          # 🟢 SHARED (All Roles)
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │       ├── pages/
    │       │   ├── login_page.dart
    │       │   ├── register_page.dart
    │       │   ├── auth_wrapper.dart
    │       │   └── rfid_setup_required_page.dart
    │       ├── provider/
    │       └── widgets/
    ├── jadwal/
    │   └── presentation/
    │       └── pages/
    │           └── jadwal_page.dart
    ├── pengumuman/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │       └── pages/
    │           └── pengumuman_page.dart
    ├── calendar/
    │   └── presentation/
    │       └── calendar_page.dart
    ├── notifications/
    │   └── presentation/
    │       └── pages/
    │           └── notification_page.dart
    ├── help/
    │   └── presentation/
    │       └── pages/
    │           └── help_page.dart
    └── settings/
        └── presentation/
            └── pages/
                └── settings_page.dart
```

## 📊 Feature Distribution by Role

### 🔴 **Admin Features** (admin/)

| Feature                 | Current Location           | New Location                      | Access     |
| ----------------------- | -------------------------- | --------------------------------- | ---------- |
| User Management         | `/admin/presentation/`     | `/admin/user_management/`         | Admin only |
| Manual Attendance       | `/admin/presentation/`     | `/admin/attendance_management/`   | Admin only |
| Attendance Report       | `/admin/presentation/`     | `/admin/attendance_management/`   | Admin only |
| Announcement Management | `/admin/presentation/`     | `/admin/announcement_management/` | Admin only |
| Schedule Management     | `/admin/presentation/`     | `/admin/schedule_management/`     | Admin only |
| Materi Management       | `/admin/presentation/`     | `/admin/materi_management/`       | Admin only |
| Notification Management | `/admin/presentation/`     | `/admin/notification_management/` | Admin only |
| Admin Dashboard         | `/admin/presentation/`     | `/admin/dashboard/`               | Admin only |
| Admin Navigation        | `/dashboard/presentation/` | `/admin/navigation/`              | Admin only |

### 🔵 **Santri Features** (santri/)

| Feature          | Current Location                 | New Location           | Access               |
| ---------------- | -------------------------------- | ---------------------- | -------------------- |
| Santri Dashboard | `/dashboard/presentation/pages/` | `/santri/dashboard/`   | Santri only          |
| Presensi         | `/presensi/`                     | `/santri/presensi/`    | Santri primary       |
| Leaderboard      | `/leaderboard/`                  | `/santri/leaderboard/` | Santri focus         |
| Profile Pages    | `/profile/presentation/pages/`   | `/santri/profile/`     | All (santri context) |
| Main Navigation  | `/dashboard/presentation/`       | `/santri/navigation/`  | Santri only          |

### 🟠 **Dewan Guru Features** (dewan_guru/)

| Feature               | Current Location                 | New Location              | Access          |
| --------------------- | -------------------------------- | ------------------------- | --------------- |
| Dewan Guru Dashboard  | `/dashboard/presentation/pages/` | `/dewan_guru/dashboard/`  | Dewan Guru only |
| Monitoring            | NEW                              | `/dewan_guru/monitoring/` | Dewan Guru only |
| Approval System       | NEW                              | `/dewan_guru/approval/`   | Dewan Guru only |
| Dewan Guru Navigation | `/dashboard/presentation/`       | `/dewan_guru/navigation/` | Dewan Guru only |

### 🟢 **Shared Features** (shared/)

| Feature       | Current Location  | New Location             | Access           |
| ------------- | ----------------- | ------------------------ | ---------------- |
| Auth          | `/auth/`          | `/shared/auth/`          | All roles        |
| Jadwal        | `/jadwal/`        | `/shared/jadwal/`        | All roles (view) |
| Pengumuman    | `/pengumuman/`    | `/shared/pengumuman/`    | All roles (view) |
| Calendar      | `/calendar/`      | `/shared/calendar/`      | All roles        |
| Notifications | `/notifications/` | `/shared/notifications/` | All roles        |
| Help          | `/help/`          | `/shared/help/`          | All roles        |
| Settings      | `/settings/`      | `/shared/settings/`      | All roles        |

## 🎯 Benefits of Role-Based Structure

### 1. **Clear Separation of Concerns**

- Each role has dedicated folder
- Easy to identify feature ownership
- Better code organization

### 2. **Better Access Control**

- Role-based imports
- Easy to enforce permissions
- Clear security boundaries

### 3. **Easier Maintenance**

- Features grouped by role
- Easier to find relevant code
- Better for team collaboration

### 4. **Scalability**

- Easy to add new role-specific features
- Clear structure for new developers
- Better for large teams

### 5. **Testing & Documentation**

- Test role features in isolation
- Role-specific documentation
- Easier to demo per role

## 🔧 Migration Steps

### Phase 1: Create New Structure

1. Create role folders: `admin/`, `santri/`, `dewan_guru/`, `shared/`
2. Create subfolders for each feature
3. Maintain Clean Architecture within each feature

### Phase 2: Move Admin Features

1. Move user management → `admin/user_management/`
2. Move attendance management → `admin/attendance_management/`
3. Move announcement management → `admin/announcement_management/`
4. Move schedule management → `admin/schedule_management/`
5. Move admin dashboard → `admin/dashboard/`
6. Move admin navigation → `admin/navigation/`

### Phase 3: Move Santri Features

1. Move santri dashboard → `santri/dashboard/`
2. Move presensi → `santri/presensi/`
3. Move leaderboard → `santri/leaderboard/`
4. Move profile → `santri/profile/`
5. Move main navigation → `santri/navigation/`

### Phase 4: Move Dewan Guru Features

1. Move dewan guru dashboard → `dewan_guru/dashboard/`
2. Create monitoring features → `dewan_guru/monitoring/`
3. Create approval features → `dewan_guru/approval/`
4. Move dewan guru navigation → `dewan_guru/navigation/`

### Phase 5: Organize Shared Features

1. Move auth → `shared/auth/`
2. Move jadwal → `shared/jadwal/`
3. Move pengumuman → `shared/pengumuman/`
4. Move calendar → `shared/calendar/`
5. Move notifications → `shared/notifications/`
6. Move help → `shared/help/`
7. Move settings → `shared/settings/`

### Phase 6: Update Imports

1. Update all import paths to new structure
2. Convert to absolute imports: `package:sisantri/features/admin/...`
3. Update navigation references
4. Update provider imports

### Phase 7: Update Navigation

1. Update role-based navigation in `core/routing/`
2. Update each navigation file to import from new locations
3. Test navigation for each role

### Phase 8: Testing & Verification

1. Test admin features and navigation
2. Test santri features and navigation
3. Test dewan guru features and navigation
4. Test shared features across all roles
5. Verify no import errors
6. Run flutter analyze

## 📝 Import Path Examples

### Before (Feature-based)

```dart
// Admin importing from admin folder
import 'package:sisantri/features/admin/presentation/user_management_page.dart';

// Santri importing from dashboard
import 'package:sisantri/features/dashboard/presentation/pages/dashboard_page.dart';

// Importing presensi
import 'package:sisantri/features/presensi/presentation/pages/presensi_page.dart';
```

### After (Role-based)

```dart
// Admin importing user management
import 'package:sisantri/features/admin/user_management/presentation/pages/user_management_page.dart';

// Santri importing dashboard
import 'package:sisantri/features/santri/dashboard/presentation/pages/santri_dashboard_page.dart';

// Santri importing presensi
import 'package:sisantri/features/santri/presensi/presentation/pages/presensi_page.dart';

// Shared auth for all roles
import 'package:sisantri/features/shared/auth/presentation/pages/login_page.dart';
```

## 🗂️ File Count Summary

### Admin Features: ~20 files

- User management pages (1)
- Attendance pages (2)
- Announcement pages (1)
- Schedule pages (2)
- Materi pages (1)
- Notification pages (1)
- Dashboard page (1)
- Navigation (1)
- Providers (~5)
- Widgets (~5)

### Santri Features: ~15 files

- Dashboard page (1)
- Presensi pages (2)
- Leaderboard page (1)
- Profile pages (8)
- Navigation (1)
- Providers (~2)

### Dewan Guru Features: ~8 files

- Dashboard page (1)
- Monitoring pages (2)
- Approval pages (1)
- Navigation (1)
- Providers (~2)
- Widgets (~1)

### Shared Features: ~10 files

- Auth pages (4)
- Jadwal page (1)
- Pengumuman page (1)
- Calendar page (1)
- Notifications page (1)
- Help page (1)
- Settings page (1)

**Total files to reorganize: ~53 files**

## ⚠️ Important Considerations

### 1. **Backward Compatibility**

- Keep old files temporarily during migration
- Add deprecation notices
- Gradual migration approach

### 2. **Testing Strategy**

- Test each role independently
- Integration tests for shared features
- E2E tests for navigation flows

### 3. **Documentation**

- Update PROJECT_STRUCTURE.md
- Create ROLE_BASED_STRUCTURE.md
- Update README.md with new structure

### 4. **Team Communication**

- Notify team about structure change
- Provide migration guide
- Update onboarding docs

## 🎯 Success Criteria

- [ ] All admin features in `admin/` folder
- [ ] All santri features in `santri/` folder
- [ ] All dewan guru features in `dewan_guru/` folder
- [ ] All shared features in `shared/` folder
- [ ] Zero import errors
- [ ] All navigation working
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Flutter analyze clean

## 📅 Timeline Estimate

- **Phase 1-2**: 2 hours (structure + admin)
- **Phase 3**: 1 hour (santri)
- **Phase 4**: 1 hour (dewan guru)
- **Phase 5**: 1 hour (shared)
- **Phase 6-7**: 2 hours (imports + navigation)
- **Phase 8**: 1 hour (testing)

**Total: ~8 hours** for complete reorganization

---

**Status**: 📋 Planning Complete - Ready for Implementation  
**Date**: 21 Oktober 2025  
**Type**: Major Structural Refactor

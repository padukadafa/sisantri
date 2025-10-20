# Struktur Proyek SiSantri (Clean Architecture)

## Struktur Folder Saat Ini

```
sisantri/
│
├── lib/
│   │
│   ├── core/                                    # 🎯 Core Functionality
│   │   ├── constants/                           # App-wide constants
│   │   ├── di/                                  # Dependency Injection
│   │   │   └── injection.dart
│   │   ├── error/                               # Error handling
│   │   ├── routing/                             # 🆕 App Routing (Moved here!)
│   │   │   ├── role_based_navigation.dart      # Role-based navigation logic
│   │   │   └── README.md
│   │   ├── theme/                               # App theming
│   │   │   └── app_theme.dart
│   │   └── utils/                               # Utility functions
│   │
│   ├── features/                                # 📦 Feature Modules
│   │   │
│   │   ├── auth/                                # Authentication Feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── auth_wrapper.dart
│   │   │       │   ├── login_page.dart
│   │   │       │   ├── register_page.dart
│   │   │       │   └── rfid_setup_required_page.dart
│   │   │       ├── provider/
│   │   │       └── widgets/
│   │   │
│   │   ├── dashboard/                           # Dashboard Feature
│   │   │   └── presentation/
│   │   │       ├── admin_navigation.dart       # Admin dashboard
│   │   │       ├── dewan_guru_navigation.dart  # Teacher dashboard
│   │   │       ├── main_navigation.dart        # Student dashboard
│   │   │       ├── dashboard_page.dart
│   │   │       ├── providers/
│   │   │       └── widgets/
│   │   │
│   │   ├── presensi/                            # Attendance Feature
│   │   ├── jadwal/                              # Schedule Feature
│   │   ├── pengumuman/                          # Announcement Feature
│   │   ├── profile/                             # Profile Feature
│   │   ├── settings/                            # Settings Feature
│   │   ├── calendar/                            # Calendar Feature
│   │   ├── leaderboard/                         # Leaderboard Feature
│   │   ├── notifications/                       # Notifications Feature
│   │   ├── help/                                # Help Feature
│   │   └── admin/                               # Admin-specific features
│   │
│   ├── shared/                                  # 🔗 Shared Resources
│   │   ├── helpers/                             # Helper functions
│   │   ├── models/                              # Shared data models
│   │   │   └── user_model.dart
│   │   ├── providers/                           # Global providers
│   │   │   ├── materi_provider.dart
│   │   │   └── progress_provider.dart
│   │   ├── services/                            # Shared services
│   │   │   └── auth_service.dart
│   │   └── widgets/                             # Reusable widgets
│   │       ├── logout_button.dart
│   │       ├── reusable_text_field.dart        # 🆕 New reusable widget
│   │       └── splash_screen.dart
│   │
│   ├── firebase_options.dart                    # Firebase configuration
│   └── main.dart                                # App entry point
│
├── android/                                     # Android-specific files
├── ios/                                         # iOS-specific files
├── web/                                         # Web-specific files
├── linux/                                       # Linux-specific files
├── macos/                                       # macOS-specific files
├── windows/                                     # Windows-specific files
│
├── iot/                                         # IoT device code
│   └── rfid_device_code.ino                    # RFID reader Arduino code
│
├── scripts/                                     # Utility scripts
│   ├── create_dummy_jadwal.dart
│   └── README.md
│
├── test/                                        # Unit & Widget tests
├── integration_test/                            # Integration tests
│
├── pubspec.yaml                                 # Dependencies
├── analysis_options.yaml                        # Linter rules
│
└── Documentation/                               # Project documentation
    ├── CLEAN_ARCHITECTURE_GUIDE.md
    ├── DEPENDENCY_INJECTION_GUIDE.md
    ├── DESIGN_GUIDE.md
    ├── DUMMY_DATA_GUIDE.md
    ├── ER_DIAGRAM.md
    ├── EXCEL_EXPORT_GUIDE.md
    ├── OPEN_FILE_IMPLEMENTATION.md
    ├── REORGANIZATION_LOG.md                   # 🆕 This reorganization log
    ├── RFID_IMPLEMENTATION_NOTES.md
    ├── RFID_IMPLEMENTATION_STATUS.md
    ├── RFID_INTEGRATION.md
    ├── RFID_SETUP_GUIDE.md
    ├── SETUP_GUIDE.md
    └── SYSTEM_REQUIREMENTS.md
```

## 📋 Prinsip Organisasi

### 1. **Core (`/lib/core/`)**

Berisi fungsi inti aplikasi yang tidak terikat pada fitur spesifik:

- **routing**: Logika navigasi dan role-based routing
- **di**: Dependency injection setup
- **theme**: Tema dan styling aplikasi
- **constants**: Konstanta aplikasi
- **utils**: Fungsi utilitas umum
- **error**: Error handling

### 2. **Features (`/lib/features/`)**

Setiap fitur dalam folder terpisah mengikuti Clean Architecture:

```
feature_name/
├── data/           # Data layer (API calls, local storage)
├── domain/         # Business logic (entities, use cases)
└── presentation/   # UI layer (pages, widgets, providers)
```

### 3. **Shared (`/lib/shared/`)**

Resource yang digunakan di banyak fitur:

- **models**: Data models yang digunakan di banyak fitur
- **services**: Services yang digunakan globally
- **widgets**: Reusable UI components
- **providers**: Global state management
- **helpers**: Helper functions

## 🔄 Data Flow (Clean Architecture)

```
┌─────────────────────────────────────────────────────────────┐
│                       PRESENTATION LAYER                     │
│  (UI, Widgets, Pages, State Management)                     │
│  - Riverpod Providers                                       │
│  - ConsumerWidget / ConsumerStatefulWidget                  │
└────────────────┬────────────────────────────────────────────┘
                 │ Uses
                 ↓
┌─────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                          │
│  (Business Logic, Use Cases, Entities)                      │
│  - Pure Dart code                                           │
│  - No framework dependencies                                │
└────────────────┬────────────────────────────────────────────┘
                 │ Uses
                 ↓
┌─────────────────────────────────────────────────────────────┐
│                         DATA LAYER                           │
│  (Repositories, Data Sources, Models)                       │
│  - Firebase, API calls                                      │
│  - Local storage                                            │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Recent Improvements

### 1. ✅ Role-Based Navigation

- Moved from `features/dashboard/` to `core/routing/`
- Better separation of concerns
- Clearer project structure

### 2. ✅ Reusable Text Field

- Created `shared/widgets/reusable_text_field.dart`
- Auto unfocus on tap outside
- Used in login and register pages

### 3. ✅ EasyLoading Integration

- Better loading indicators
- Improved UX in RFID setup page

## 📝 Best Practices

1. **Import Style**: Use absolute imports

   ```dart
   // ✅ Good
   import 'package:sisantri/core/routing/role_based_navigation.dart';

   // ❌ Avoid
   import '../../../../core/routing/role_based_navigation.dart';
   ```

2. **Feature Independence**: Features should be independent

   - Don't import from other features
   - Use shared resources instead

3. **Provider Organization**:

   - Global providers → `shared/providers/`
   - Feature providers → `features/[feature]/presentation/providers/`
   - Routing providers → `core/routing/`

4. **Widget Reusability**:
   - Feature-specific widgets → in feature folder
   - Reusable widgets → `shared/widgets/`

## 🚀 Navigation Flow

```
main.dart
    ↓
MyApp (MaterialApp)
    ↓
AuthWrapper
    ↓
    ├─→ [No User] → LoginPage
    ├─→ [User without RFID] → RfidSetupRequiredPage
    └─→ [User with RFID] → RoleBasedNavigation
                              ↓
                              ├─→ [Admin] → AdminNavigation
                              ├─→ [Dewan Guru] → DewaGuruNavigation
                              ├─→ [Santri] → MainNavigation
                              └─→ [Unknown] → Error Screen
```

## 📦 Key Dependencies

- **flutter_riverpod**: State management
- **firebase_auth**: Authentication
- **cloud_firestore**: Database
- **flutter_easyloading**: Loading indicators
- **google_sign_in**: Google authentication
- **nfc_manager**: RFID/NFC functionality

## 🎨 UI Components

### Reusable Widgets

- `ReusableTextField`: Auto-unfocus text field
- `LogoutButton`: Logout button with customization
- `SplashScreen`: Loading screen

### Navigation Widgets

- `RoleBasedNavigation`: Main routing logic
- `AuthWrapper`: Authentication wrapper
- `MainNavigation`: Bottom nav for students
- `AdminNavigation`: Bottom nav for admins
- `DewaGuruNavigation`: Bottom nav for teachers

---

**Last Updated**: October 20, 2025
**Project**: SiSantri - Sistem Informasi Santri
**Architecture**: Clean Architecture + Riverpod

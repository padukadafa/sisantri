# Reorganisasi Struktur Proyek

## Tanggal: 20 Oktober 2025

## Perubahan yang Dilakukan

### 1. Pemindahan Role-Based Navigation

**Sebelum:**

```
lib/features/dashboard/presentation/role_based_navigation.dart
```

**Sesudah:**

```
lib/core/routing/role_based_navigation.dart
```

**Alasan:**

- `role_based_navigation.dart` adalah komponen routing inti aplikasi, bukan bagian dari feature dashboard
- Lebih masuk akal jika file routing ada di `/lib/core/routing/`
- Memisahkan concerns: routing logic terpisah dari UI dashboard
- Memudahkan maintenance dan reusability

### 2. File yang Diupdate

File-file berikut telah diupdate import path-nya:

1. **lib/features/auth/presentation/pages/rfid_setup_required_page.dart**

   - Old: `import 'package:sisantri/features/dashboard/presentation/role_based_navigation.dart';`
   - New: `import 'package:sisantri/core/routing/role_based_navigation.dart';`

2. **lib/features/auth/presentation/pages/auth_wrapper.dart**
   - Old: `import '../../../dashboard/presentation/role_based_navigation.dart';`
   - New: `import '../../../../core/routing/role_based_navigation.dart';`

### 3. Struktur Folder Baru

```
lib/
├── core/
│   ├── routing/
│   │   ├── role_based_navigation.dart  ← MOVED HERE
│   │   └── README.md                   ← NEW DOCUMENTATION
│   ├── di/
│   ├── error/
│   ├── theme/
│   └── utils/
├── features/
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── admin_navigation.dart
│   │       ├── main_navigation.dart
│   │       ├── dewan_guru_navigation.dart
│   │       └── dashboard_page.dart
│   └── ...
└── shared/
    ├── models/
    ├── services/
    ├── widgets/
    ├── helpers/
    └── providers/
```

## Benefits dari Reorganisasi

### 1. **Separation of Concerns**

- Routing logic tidak tercampur dengan dashboard UI
- Setiap module punya tanggung jawab yang jelas

### 2. **Better Organization**

- File-file core (routing, DI, theme) ada di `/lib/core/`
- Feature-specific code ada di `/lib/features/`
- Shared components ada di `/lib/shared/`

### 3. **Scalability**

- Mudah menambah routing baru
- Mudah menambah role baru
- Struktur yang jelas untuk developer baru

### 4. **Maintainability**

- Import path yang konsisten
- Mudah mencari file
- Dokumentasi yang jelas

## Rekomendasi Struktur Folder (Best Practice)

```
lib/
├── core/                          # Core functionality
│   ├── routing/                   # App routing & navigation
│   ├── di/                        # Dependency Injection
│   ├── error/                     # Error handling
│   ├── theme/                     # App theming
│   ├── utils/                     # Utilities
│   └── constants/                 # App constants
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   │
│   ├── dashboard/                 # Dashboard feature
│   ├── presensi/                  # Attendance feature
│   └── ...                        # Other features
│
└── shared/                        # Shared across features
    ├── models/                    # Shared data models
    ├── services/                  # Shared services
    ├── widgets/                   # Reusable widgets
    ├── helpers/                   # Helper functions
    └── providers/                 # Global providers
```

## Next Steps (Optional Improvements)

### 1. Reorganisasi Provider

Consider memindahkan providers ke lokasi yang lebih tepat:

- `currentUserDataProvider` → sudah dipindah ke `core/routing/`
- Feature-specific providers → di feature masing-masing
- Global providers → tetap di `shared/providers/`

### 2. Konsistensi Import

Gunakan absolute imports untuk konsistensi:

```dart
// Good ✅
import 'package:sisantri/core/routing/role_based_navigation.dart';

// Avoid ❌
import '../../../../core/routing/role_based_navigation.dart';
```

### 3. Barrel Exports

Create index files untuk simplify imports:

```dart
// lib/core/routing/routing.dart
export 'role_based_navigation.dart';

// Usage
import 'package:sisantri/core/routing/routing.dart';
```

## Testing

Semua import telah diupdate dan tidak ada error kompilasi:

- ✅ No compilation errors
- ✅ All imports resolved correctly
- ✅ App structure improved

## Conclusion

Struktur proyek sekarang lebih rapi dan mengikuti best practice Flutter/Dart:

- Clear separation of concerns
- Better organization
- Easier to maintain and scale
- More intuitive for new developers

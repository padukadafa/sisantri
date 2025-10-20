# Core Routing Module

## Overview

Module ini berisi komponen-komponen routing inti aplikasi yang menangani navigasi berdasarkan authentication state dan user role.

## Files

### role_based_navigation.dart

File ini berisi:

- **currentUserDataProvider**: StreamProvider yang mendengarkan perubahan authentication state dan mengambil data user dari Firestore
- **RoleBasedNavigation**: Widget yang mengarahkan user ke halaman yang sesuai berdasarkan role mereka

## Role-Based Navigation Flow

```
User Login
    ↓
AuthWrapper
    ↓
RoleBasedNavigation
    ↓
    ├── Admin → AdminNavigation
    ├── Dewan Guru → DewaGuruNavigation
    ├── Santri → MainNavigation
    └── Unknown Role → Error Screen
```

## Provider: currentUserDataProvider

Provider ini:

1. Mendengarkan `AuthService.authStateChanges`
2. Setiap kali ada perubahan auth state, fetch data user dari Firestore
3. Return `UserModel?` yang berisi informasi lengkap user termasuk role
4. Handle error dengan graceful fallback ke null

## Usage

```dart
// Di widget mana saja yang butuh data user
final userData = ref.watch(currentUserDataProvider);

// Untuk trigger refresh manual
ref.invalidate(currentUserDataProvider);

// Untuk read sekali tanpa listen
final userData = ref.read(currentUserDataProvider);
```

## Benefits of This Structure

1. **Separation of Concerns**: Routing logic terpisah dari business logic dashboard
2. **Reusability**: Provider bisa digunakan di widget mana saja
3. **Centralized**: Semua logic routing ada di satu tempat
4. **Maintainable**: Mudah untuk menambah role baru atau mengubah routing logic

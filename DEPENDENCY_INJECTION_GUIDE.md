# Dependency Injection Implementation Guide

## Overview

Proyek SiSantri menggunakan **Riverpod** untuk dependency injection management. Semua dependencies didefinisikan di `lib/core/di/injection.dart`.

## Struktur Clean Architecture

Setiap feature mengikuti struktur:

```
feature/
├── data/
│   ├── datasources/
│   │   ├── feature_remote_data_source.dart (interface)
│   │   └── feature_remote_data_source_impl.dart (implementation)
│   ├── models/
│   │   └── feature_model.dart
│   └── repositories/
│       └── feature_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── feature.dart
│   ├── repositories/
│   │   └── feature_repository.dart (interface)
│   └── usecases/
│       ├── usecase_1.dart
│       ├── usecase_2.dart
│       └── ...
└── presentation/
    ├── bloc/ atau providers/
    ├── pages/
    └── widgets/
```

## Features yang Sudah Diimplementasikan

### ✅ 1. Auth Feature

**Data Sources:**

- `AuthRemoteDataSource` - Interface
- `AuthRemoteDataSourceImpl` - Firebase implementation

**Repository:**

- `AuthRepository` - Interface
- `AuthRepositoryImpl` - Implementation

**Use Cases:**

- `LoginWithEmailAndPassword`
- `GetCurrentUser`
- `Logout`

**Providers:**

```dart
final authRemoteDataSourceProvider
final authRepositoryProvider
final loginWithEmailAndPasswordProvider
final getCurrentUserProvider
final logoutProvider
```

**Cara Menggunakan di Widget:**

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginUseCase = ref.read(loginWithEmailAndPasswordProvider);

    // Use the use case
    final result = await loginUseCase(
      email: 'user@example.com',
      password: 'password123',
    );
  }
}
```

### ✅ 2. Presensi Feature

**Data Sources:**

- `PresensiRemoteDataSource` - Interface
- `PresensiRemoteDataSourceImpl` - Firebase implementation

**Repository:**

- `PresensiRepository` - Interface
- `PresensiRepositoryImpl` - Implementation

**Use Cases:**

- `AddPresensi`
- `GetPresensiByUserId`
- `PresensiWithRfid`

**Providers:**

```dart
final presensiRemoteDataSourceProvider
final presensiRepositoryProvider
final addPresensiProvider
final getPresensiByUserIdProvider
final presensiWithRfidProvider
```

**Cara Menggunakan:**

```dart
class PresensiWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addPresensi = ref.read(addPresensiProvider);
    final getPresensi = ref.read(getPresensiByUserIdProvider);

    // Add presensi
    await addPresensi(presensiEntity);

    // Get presensi
    final presensiList = await getPresensi(userId: 'user123');
  }
}
```

### ✅ 3. Pengumuman Feature

**Data Sources:**

- `PengumumanRemoteDataSource` - Interface
- `PengumumanRemoteDataSourceImpl` - Firebase implementation

**Repository:**

- `PengumumanRepository` - Interface
- `PengumumanRepositoryImpl` - Implementation

**Use Cases:**

- `GetAllPengumuman`
- `GetPengumumanForUser`
- `CreatePengumuman`
- `MarkPengumumanAsRead`

**Providers:**

```dart
final pengumumanRemoteDataSourceProvider
final pengumumanRepositoryProvider
final getAllPengumumanProvider
final getPengumumanForUserProvider
final createPengumumanProvider
final markPengumumanAsReadProvider
```

**Cara Menggunakan:**

```dart
class PengumumanPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getPengumumanForUser = ref.read(getPengumumanForUserProvider);

    // Get pengumuman for specific user
    try {
      final pengumumanList = await getPengumumanForUser(
        userRole: 'santri',
        userClass: '10A',
      );

      // Display pengumuman
    } catch (e) {
      // Handle error
    }
  }
}
```

## Features yang Perlu Diimplementasikan

### ⏳ 4. Jadwal/Event Feature

**Entities:**

- Jadwal (Event)
- EventParticipant
- EventReminder

**Use Cases yang Diperlukan:**

- `GetAllJadwal`
- `GetJadwalForUser`
- `CreateJadwal`
- `UpdateJadwal`
- `DeleteJadwal`
- `JoinEvent`
- `LeaveEvent`
- `GetEventParticipants`

### ⏳ 5. Notifications Feature

**Entities:**

- Notifikasi

**Use Cases yang Diperlukan:**

- `GetNotificationsForUser`
- `MarkNotificationAsRead`
- `MarkAllNotificationsAsRead`
- `DeleteNotification`
- `GetUnreadCount`

### ⏳ 6. Dashboard Feature

**Use Cases yang Diperlukan:**

- `GetDashboardData`
- `GetAttendanceStatistics`
- `GetUpcomingEvents`
- `GetRecentAnnouncements`

### ⏳ 7. Profile Feature

**Use Cases yang Diperlukan:**

- `GetUserProfile`
- `UpdateUserProfile`
- `UploadProfilePicture`
- `ChangePassword`

### ⏳ 8. Leaderboard/Gamification Feature

**Entities:**

- PointTransaction
- Achievement
- UserAchievement
- Leaderboard

**Use Cases yang Diperlukan:**

- `GetUserPoints`
- `GetPointTransactions`
- `GetLeaderboard`
- `GetAchievements`
- `GetUserAchievements`
- `UnlockAchievement`

## Best Practices

### 1. Menggunakan Provider di Widget

```dart
// ❌ JANGAN seperti ini
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = AuthRepositoryImpl(...); // WRONG
  }
}

// ✅ LAKUKAN seperti ini
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginUseCase = ref.read(loginWithEmailAndPasswordProvider);
  }
}
```

### 2. Menggunakan AsyncValue untuk Async Operations

```dart
final pengumumanListProvider = FutureProvider<List<Pengumuman>>((ref) async {
  final getPengumumanForUser = ref.read(getPengumumanForUserProvider);
  return await getPengumumanForUser(
    userRole: 'santri',
  );
});

// Di widget
class PengumumanList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pengumumanAsync = ref.watch(pengumumanListProvider);

    return pengumumanAsync.when(
      data: (pengumumanList) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 3. Membuat StateNotifier untuk State Management

```dart
// Create StateNotifier
class PengumumanNotifier extends StateNotifier<AsyncValue<List<Pengumuman>>> {
  final GetPengumumanForUser getPengumumanForUser;

  PengumumanNotifier(this.getPengumumanForUser) : super(const AsyncValue.loading());

  Future<void> loadPengumuman(String userRole, String? userClass) async {
    state = const AsyncValue.loading();
    try {
      final pengumuman = await getPengumumanForUser(
        userRole: userRole,
        userClass: userClass,
      );
      state = AsyncValue.data(pengumuman);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider
final pengumumanNotifierProvider =
    StateNotifierProvider<PengumumanNotifier, AsyncValue<List<Pengumuman>>>((ref) {
  return PengumumanNotifier(ref.read(getPengumumanForUserProvider));
});

// Di widget
class PengumumanPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pengumumanState = ref.watch(pengumumanNotifierProvider);

    return pengumumanState.when(
      data: (data) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error'),
    );
  }
}
```

### 4. Error Handling

```dart
try {
  final result = await useCase.call(params);
  // Handle success
} on ServerException catch (e) {
  // Handle server error
  print('Server error: ${e.message}');
} on NetworkException catch (e) {
  // Handle network error
  print('Network error: ${e.message}');
} catch (e) {
  // Handle general error
  print('Unknown error: $e');
}
```

## Testing dengan DI

### Unit Testing Use Case

```dart
void main() {
  late MockPengumumanRepository mockRepository;
  late GetAllPengumuman useCase;

  setUp(() {
    mockRepository = MockPengumumanRepository();
    useCase = GetAllPengumuman(mockRepository);
  });

  test('should get all pengumuman from repository', () async {
    // Arrange
    final testPengumuman = [PengumumanModel(...)];
    when(mockRepository.getAllPengumuman())
        .thenAnswer((_) async => testPengumuman);

    // Act
    final result = await useCase();

    // Assert
    expect(result, testPengumuman);
    verify(mockRepository.getAllPengumuman());
  });
}
```

### Widget Testing dengan Provider Override

```dart
testWidgets('should display pengumuman list', (tester) async {
  final container = ProviderContainer(
    overrides: [
      getPengumumanForUserProvider.overrideWithValue(
        MockGetPengumumanForUser(),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: PengumumanPage()),
    ),
  );

  // Test widget
});
```

## Firebase Instance Providers

```dart
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});
```

## Menambahkan Feature Baru

1. **Buat struktur folder** sesuai clean architecture
2. **Buat entity** di `domain/entities/`
3. **Buat repository interface** di `domain/repositories/`
4. **Buat use cases** di `domain/usecases/`
5. **Buat model** di `data/models/`
6. **Buat data source interface** di `data/datasources/`
7. **Implementasi data source** dengan Firebase
8. **Implementasi repository**
9. **Tambahkan providers** di `injection.dart`
10. **Gunakan di presentation layer** dengan Riverpod

## Referensi

- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Package](https://pub.dev/packages/flutter_clean_architecture)

## Status Implementasi DI

- [x] Auth Feature
- [x] Presensi Feature
- [x] Pengumuman Feature
- [ ] Jadwal/Event Feature
- [ ] Notifications Feature
- [ ] Dashboard Feature
- [ ] Profile Feature
- [ ] Leaderboard/Gamification Feature
- [ ] Reports Feature
- [ ] Settings Feature

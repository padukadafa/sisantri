# Clean Architecture Implementation Guide

## Overview

Proyek SiSantri telah direfactor menggunakan Clean Architecture untuk meningkatkan maintainability, testability, dan separation of concerns. Struktur baru mengikuti prinsip-prinsip Clean Architecture dengan pembagian yang jelas antara domain, data, dan presentation layer.

## Struktur Folder

```
lib/
├── core/                           # Core utilities dan shared components
│   ├── di/                        # Dependency Injection
│   ├── error/                     # Error handling
│   ├── utils/                     # Utilities (Result pattern, dll)
│   ├── constants/                 # App constants
│   └── theme/                     # App theme
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── domain/               # Business logic layer
│   │   │   ├── entities/         # Business entities
│   │   │   ├── repositories/     # Repository abstracts
│   │   │   └── usecases/         # Use cases/interactors
│   │   ├── data/                 # Data layer
│   │   │   ├── models/           # Data models (extends entities)
│   │   │   ├── datasources/      # Data sources (remote/local)
│   │   │   └── repositories/     # Repository implementations
│   │   └── presentation/         # Presentation layer
│   │       ├── bloc/             # State management (Riverpod)
│   │       ├── pages/            # UI pages
│   │       └── widgets/          # UI widgets
│   └── presensi/                 # Presensi feature (same structure)
└── shared/                       # Shared/legacy components
```

## Layer Description

### 1. Domain Layer (Business Logic)

- **Entities**: Pure business objects tanpa dependency eksternal
- **Repositories**: Interface/abstract class untuk data operations
- **Use Cases**: Business logic dan rules aplikasi

### 2. Data Layer

- **Models**: Implementation dari entities yang bisa di-convert ke/dari JSON
- **DataSources**: Interface dan implementation untuk remote/local data
- **Repositories**: Implementation dari domain repositories

### 3. Presentation Layer

- **Bloc/Providers**: State management menggunakan Riverpod
- **Pages**: UI screens
- **Widgets**: Reusable UI components

## Key Concepts

### Result Pattern

Menggantikan try-catch dengan Result pattern untuk error handling yang lebih explicit:

```dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
```

### Dependency Injection

Menggunakan Riverpod untuk dependency injection:

```dart
// Core providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Data source providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

// Use case providers
final loginWithEmailAndPasswordProvider = Provider<LoginWithEmailAndPassword>((ref) {
  return LoginWithEmailAndPassword(ref.read(authRepositoryProvider));
});
```

## How to Use

### 1. Creating New Feature

1. **Create folder structure**:

```
features/
└── your_feature/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    ├── data/
    │   ├── models/
    │   ├── datasources/
    │   └── repositories/
    └── presentation/
        ├── bloc/
        ├── pages/
        └── widgets/
```

2. **Define Entity** (domain/entities):

```dart
class YourEntity extends Equatable {
  final String id;
  final String name;

  const YourEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
```

3. **Define Repository Interface** (domain/repositories):

```dart
abstract class YourRepository {
  Future<Result<YourEntity>> getEntity(String id);
  Future<Result<List<YourEntity>>> getAllEntities();
}
```

4. **Create Use Case** (domain/usecases):

```dart
class GetEntity {
  final YourRepository repository;

  const GetEntity(this.repository);

  Future<Result<YourEntity>> call(String id) async {
    if (id.isEmpty) {
      return Error(ValidationFailure(message: 'ID tidak boleh kosong'));
    }
    return await repository.getEntity(id);
  }
}
```

5. **Implement Model** (data/models):

```dart
class YourModel extends YourEntity {
  const YourModel({required super.id, required super.name});

  factory YourModel.fromJson(Map<String, dynamic> json) {
    return YourModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

6. **Implement DataSource** (data/datasources):

```dart
abstract class YourRemoteDataSource {
  Future<YourModel> getEntity(String id);
}

class YourRemoteDataSourceImpl implements YourRemoteDataSource {
  final FirebaseFirestore firestore;

  YourRemoteDataSourceImpl({required this.firestore});

  @override
  Future<YourModel> getEntity(String id) async {
    try {
      final doc = await firestore.collection('your_collection').doc(id).get();
      return YourModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Error getting entity: $e');
    }
  }
}
```

7. **Implement Repository** (data/repositories):

```dart
class YourRepositoryImpl implements YourRepository {
  final YourRemoteDataSource remoteDataSource;

  YourRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<YourEntity>> getEntity(String id) async {
    try {
      final model = await remoteDataSource.getEntity(id);
      return Success(model);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }
}
```

8. **Create State Management** (presentation/bloc):

```dart
class YourState {
  final YourEntity? entity;
  final bool isLoading;
  final String? error;

  const YourState({this.entity, this.isLoading = false, this.error});
}

class YourNotifier extends StateNotifier<YourState> {
  final GetEntity _getEntityUseCase;

  YourNotifier({required GetEntity getEntityUseCase})
      : _getEntityUseCase = getEntityUseCase,
        super(const YourState());

  Future<void> getEntity(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getEntityUseCase(id);

    result.fold(
      onSuccess: (entity) {
        state = state.copyWith(entity: entity, isLoading: false);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }
}

final yourProvider = StateNotifierProvider<YourNotifier, YourState>((ref) {
  return YourNotifier(getEntityUseCase: ref.read(getEntityProvider));
});
```

9. **Setup Dependency Injection** (core/di/injection.dart):

```dart
// Add providers for your feature
final yourRemoteDataSourceProvider = Provider<YourRemoteDataSource>((ref) {
  return YourRemoteDataSourceImpl(
    firestore: ref.read(firestoreProvider),
  );
});

final yourRepositoryProvider = Provider<YourRepository>((ref) {
  return YourRepositoryImpl(
    remoteDataSource: ref.read(yourRemoteDataSourceProvider),
  );
});

final getEntityProvider = Provider<GetEntity>((ref) {
  return GetEntity(ref.read(yourRepositoryProvider));
});
```

### 2. Using in UI

```dart
class YourPage extends ConsumerWidget {
  const YourPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(yourProvider);

    return Scaffold(
      body: state.isLoading
          ? const CircularProgressIndicator()
          : state.error != null
              ? Text('Error: ${state.error}')
              : state.entity != null
                  ? Text('Entity: ${state.entity!.name}')
                  : const Text('No data'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(yourProvider.notifier).getEntity('some-id');
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

## Migration Strategy

### Existing Files

File-file lama masih ada di folder `shared/` dan dapat tetap digunakan sambil secara bertahap dipindahkan ke struktur Clean Architecture.

### Example Migration

1. **AuthWrapper**: Gunakan `AuthWrapperClean` sebagai contoh implementasi baru
2. **LoginPage**: Gunakan `LoginPageClean` sebagai contoh dengan state management baru
3. **Services**: Pindahkan logic dari services ke use cases dan repositories

### Testing

Struktur Clean Architecture memudahkan testing:

- **Unit test** untuk use cases dan entities
- **Integration test** untuk repositories dengan mock data sources
- **Widget test** untuk presentation layer

## Benefits

1. **Separation of Concerns**: Setiap layer memiliki tanggung jawab yang jelas
2. **Testability**: Mudah membuat unit test untuk business logic
3. **Maintainability**: Perubahan di satu layer tidak mempengaruhi layer lain
4. **Scalability**: Mudah menambah fitur baru dengan struktur yang konsisten
5. **Error Handling**: Result pattern memberikan error handling yang explicit
6. **Dependency Inversion**: Business logic tidak bergantung pada framework eksternal

## Next Steps

1. Migrasikan fitur-fitur lain secara bertahap
2. Tambahkan unit tests untuk use cases
3. Implement caching di data layer jika diperlukan
4. Setup CI/CD dengan testing otomatis
5. Dokumentasikan API contracts antar layer

## File Examples

Contoh implementasi dapat dilihat di:

- `lib/features/auth/` - Implementasi lengkap untuk authentication
- `lib/features/presensi/` - Implementasi untuk presensi
- `lib/core/` - Core utilities dan dependency injection

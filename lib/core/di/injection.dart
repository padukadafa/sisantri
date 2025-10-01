import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Data Sources
import '../../features/auth/data/datasources/auth_data_source_interface.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/presensi/data/datasources/presensi_remote_data_source.dart';

// Repositories
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/presensi/data/repositories/presensi_repository_impl.dart';
import '../../features/presensi/domain/repositories/presensi_repository.dart';

// Use Cases
import '../../features/auth/domain/usecases/login_with_email_and_password.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/presensi/domain/usecases/add_presensi.dart';
import '../../features/presensi/domain/usecases/get_presensi_by_user_id.dart';
import '../../features/presensi/domain/usecases/presensi_with_rfid.dart';

/// Firebase Auth Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firestore Provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Google Sign In Provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

// Data Source Providers

/// Auth Remote Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

/// Presensi Remote Data Source Provider
final presensiRemoteDataSourceProvider = Provider<PresensiRemoteDataSource>((
  ref,
) {
  return PresensiRemoteDataSourceImpl(firestore: ref.read(firestoreProvider));
});

// Repository Providers

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

/// Presensi Repository Provider
final presensiRepositoryProvider = Provider<PresensiRepository>((ref) {
  return PresensiRepositoryImpl(
    remoteDataSource: ref.read(presensiRemoteDataSourceProvider),
  );
});

// Use Case Providers

/// Login Use Case Provider
final loginWithEmailAndPasswordProvider = Provider<LoginWithEmailAndPassword>((
  ref,
) {
  return LoginWithEmailAndPassword(ref.read(authRepositoryProvider));
});

/// Get Current User Use Case Provider
final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.read(authRepositoryProvider));
});

/// Logout Use Case Provider
final logoutProvider = Provider<Logout>((ref) {
  return Logout(ref.read(authRepositoryProvider));
});

/// Add Presensi Use Case Provider
final addPresensiProvider = Provider<AddPresensi>((ref) {
  return AddPresensi(ref.read(presensiRepositoryProvider));
});

/// Get Presensi By User ID Use Case Provider
final getPresensiByUserIdProvider = Provider<GetPresensiByUserId>((ref) {
  return GetPresensiByUserId(ref.read(presensiRepositoryProvider));
});

/// Presensi With RFID Use Case Provider
final presensiWithRfidProvider = Provider<PresensiWithRfid>((ref) {
  return PresensiWithRfid(
    presensiRepository: ref.read(presensiRepositoryProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});

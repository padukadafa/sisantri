import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Data Sources
import '../../features/auth/data/datasources/auth_data_source_interface.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/presensi/data/datasources/presensi_remote_data_source.dart';
import '../../features/pengumuman/data/datasources/pengumuman_remote_data_source.dart';
import '../../features/pengumuman/data/datasources/pengumuman_remote_data_source_impl.dart';

// Repositories
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/presensi/data/repositories/presensi_repository_impl.dart';
import '../../features/presensi/domain/repositories/presensi_repository.dart';
import '../../features/pengumuman/data/repositories/pengumuman_repository_impl.dart';
import '../../features/pengumuman/domain/repositories/pengumuman_repository.dart';

// Use Cases
import '../../features/auth/domain/usecases/login_with_email_and_password.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/presensi/domain/usecases/add_presensi.dart';
import '../../features/presensi/domain/usecases/get_presensi_by_user_id.dart';
import '../../features/presensi/domain/usecases/presensi_with_rfid.dart';
import '../../features/pengumuman/domain/usecases/get_all_pengumuman.dart';
import '../../features/pengumuman/domain/usecases/get_pengumuman_for_user.dart';
import '../../features/pengumuman/domain/usecases/create_pengumuman.dart';
import '../../features/pengumuman/domain/usecases/mark_pengumuman_as_read.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

final presensiRemoteDataSourceProvider = Provider<PresensiRemoteDataSource>((
  ref,
) {
  return PresensiRemoteDataSourceImpl(firestore: ref.read(firestoreProvider));
});
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

final presensiRepositoryProvider = Provider<PresensiRepository>((ref) {
  return PresensiRepositoryImpl(
    remoteDataSource: ref.read(presensiRemoteDataSourceProvider),
  );
});

final loginWithEmailAndPasswordProvider = Provider<LoginWithEmailAndPassword>((
  ref,
) {
  return LoginWithEmailAndPassword(ref.read(authRepositoryProvider));
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.read(authRepositoryProvider));
});

final logoutProvider = Provider<Logout>((ref) {
  return Logout(ref.read(authRepositoryProvider));
});

final addPresensiProvider = Provider<AddPresensi>((ref) {
  return AddPresensi(ref.read(presensiRepositoryProvider));
});

final getPresensiByUserIdProvider = Provider<GetPresensiByUserId>((ref) {
  return GetPresensiByUserId(ref.read(presensiRepositoryProvider));
});

final presensiWithRfidProvider = Provider<PresensiWithRfid>((ref) {
  return PresensiWithRfid(
    presensiRepository: ref.read(presensiRepositoryProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});

// =====================================================
// PENGUMUMAN FEATURE PROVIDERS
// =====================================================

final pengumumanRemoteDataSourceProvider = Provider<PengumumanRemoteDataSource>(
  (ref) {
    return PengumumanRemoteDataSourceImpl(
      firestore: ref.read(firestoreProvider),
    );
  },
);

final pengumumanRepositoryProvider = Provider<PengumumanRepository>((ref) {
  return PengumumanRepositoryImpl(
    remoteDataSource: ref.read(pengumumanRemoteDataSourceProvider),
  );
});

final getAllPengumumanProvider = Provider<GetAllPengumuman>((ref) {
  return GetAllPengumuman(ref.read(pengumumanRepositoryProvider));
});

final getPengumumanForUserProvider = Provider<GetPengumumanForUser>((ref) {
  return GetPengumumanForUser(ref.read(pengumumanRepositoryProvider));
});

final createPengumumanProvider = Provider<CreatePengumuman>((ref) {
  return CreatePengumuman(ref.read(pengumumanRepositoryProvider));
});

final markPengumumanAsReadProvider = Provider<MarkPengumumanAsRead>((ref) {
  return MarkPengumumanAsRead(ref.read(pengumumanRepositoryProvider));
});

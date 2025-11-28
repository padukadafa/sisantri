import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Data Sources
import '../../features/shared/auth/data/datasources/auth_data_source_interface.dart';
import '../../features/shared/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/santri/presensi/data/datasources/presensi_remote_data_source.dart';
import '../../features/shared/announcement/data/datasources/announcement_remote_data_source.dart';
import '../../features/shared/announcement/data/datasources/announcement_remote_data_source_impl.dart';

// Repositories
import '../../features/shared/auth/data/repositories/auth_repository_impl.dart';
import '../../features/shared/auth/domain/repositories/auth_repository.dart';
import '../../features/santri/presensi/data/repositories/presensi_repository_impl.dart';
import '../../features/santri/presensi/domain/repositories/presensi_repository.dart';
import '../../features/shared/announcement/data/repositories/announcement_repository_impl.dart';
import '../../features/shared/announcement/domain/repositories/announcement_repository.dart';

// Use Cases
import '../../features/shared/auth/domain/usecases/login_with_email_and_password.dart';
import '../../features/shared/auth/domain/usecases/get_current_user.dart';
import '../../features/shared/auth/domain/usecases/logout.dart';
import '../../features/shared/auth/domain/usecases/reset_password.dart';
import '../../features/santri/presensi/domain/usecases/add_presensi.dart';
import '../../features/santri/presensi/domain/usecases/get_presensi_by_user_id.dart';
import '../../features/santri/presensi/domain/usecases/presensi_with_rfid.dart';
import '../../features/shared/announcement/domain/usecases/get_all_announcement.dart';
import '../../features/shared/announcement/domain/usecases/get_announcement_for_user.dart';
import '../../features/shared/announcement/domain/usecases/create_announcement.dart';
import '../../features/shared/announcement/domain/usecases/mark_announcement_as_read.dart';

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

final resetPasswordProvider = Provider<ResetPassword>((ref) {
  return ResetPassword(ref.read(authRepositoryProvider));
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

final pengumumanRemoteDataSourceProvider =
    Provider<AnnouncementRemoteDataSource>((ref) {
      return AnnouncementRemoteDataSourceImpl(
        firestore: ref.read(firestoreProvider),
      );
    });

final pengumumanRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(
    remoteDataSource: ref.read(pengumumanRemoteDataSourceProvider),
  );
});

final getAllAnnouncementProvider = Provider<GetAllAnnouncement>((ref) {
  return GetAllAnnouncement(ref.read(pengumumanRepositoryProvider));
});

final getAnnouncementForUserProvider = Provider<GetAnnouncementForUser>((ref) {
  return GetAnnouncementForUser(ref.read(pengumumanRepositoryProvider));
});

final createAnnouncementProvider = Provider<CreateAnnouncement>((ref) {
  return CreateAnnouncement(ref.read(pengumumanRepositoryProvider));
});

final markAnnouncementAsReadProvider = Provider<MarkPengumumanAsRead>((ref) {
  return MarkPengumumanAsRead(ref.read(pengumumanRepositoryProvider));
});

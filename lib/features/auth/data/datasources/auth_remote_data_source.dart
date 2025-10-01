import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'auth_data_source_interface.dart';
import 'firebase_auth_operations.dart';
import 'google_auth_operations.dart';
import 'user_profile_operations.dart';
import 'auth_utility_operations.dart';

/// Implementation Auth Remote DataSource dengan Firebase
/// Menggunakan dependency injection untuk operations yang berbeda
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuthOperations _firebaseOperations;
  final GoogleAuthOperations _googleOperations;
  final UserProfileOperations _profileOperations;
  final AuthUtilityOperations _utilityOperations;

  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseOperations = FirebaseAuthOperations(
         firebaseAuth: firebaseAuth,
         firestore: firestore,
       ),
       _googleOperations = GoogleAuthOperations(
         googleSignIn: googleSignIn,
         firebaseAuth: firebaseAuth,
         firestore: firestore,
       ),
       _profileOperations = UserProfileOperations(firestore: firestore),
       _utilityOperations = AuthUtilityOperations(firebaseAuth: firebaseAuth);

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseOperations.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    return await _firebaseOperations.registerWithEmailAndPassword(
      email: email,
      password: password,
      nama: nama,
      role: role,
    );
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    return await _googleOperations.loginWithGoogle();
  }

  @override
  Future<void> logout() async {
    return await _firebaseOperations.logout();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await _firebaseOperations.getCurrentUser();
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    return await _profileOperations.updateUserProfile(user);
  }

  @override
  Future<void> resetPassword(String email) async {
    return await _utilityOperations.resetPassword(email);
  }

  @override
  Future<void> sendEmailVerification() async {
    return await _utilityOperations.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    return await _utilityOperations.isEmailVerified();
  }

  @override
  Future<UserModel> updateRfidCardId({
    required String userId,
    required String rfidCardId,
  }) async {
    return await _profileOperations.updateRfidCardId(
      userId: userId,
      rfidCardId: rfidCardId,
    );
  }

  @override
  Future<UserModel?> getUserByRfid(String rfidCardId) async {
    return await _profileOperations.getUserByRfid(rfidCardId);
  }
}

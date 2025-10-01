import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Abstract DataSource untuk Auth remote operations
abstract class AuthRemoteDataSource {
  /// Login dengan email dan password
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register user baru
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String role,
  });

  /// Login dengan Google
  Future<UserModel> loginWithGoogle();

  /// Logout user
  Future<void> logout();

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Update user profile
  Future<UserModel> updateUserProfile(UserModel user);

  /// Reset password
  Future<void> resetPassword(String email);

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Check if email is verified
  Future<bool> isEmailVerified();

  /// Update RFID Card ID
  Future<UserModel> updateRfidCardId({
    required String userId,
    required String rfidCardId,
  });

  /// Get user by RFID
  Future<UserModel?> getUserByRfid(String rfidCardId);
}

/// Implementation Auth Remote DataSource dengan Firebase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Login failed');
      }

      // Get user data dari Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromJson({
        'id': credential.user!.uid,
        ...userDoc.data()!,
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Registration failed');
      }

      final user = UserModel(
        id: credential.user!.uid,
        nama: nama,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simpan user data ke Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toJson());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw Exception('Google login failed');
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      UserModel user;
      if (userDoc.exists) {
        user = UserModel.fromJson({
          'id': userCredential.user!.uid,
          ...userDoc.data()!,
        });
      } else {
        // Create new user
        user = UserModel(
          id: userCredential.user!.uid,
          nama: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email!,
          role: 'santri', // Default role
          fotoProfil: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toJson());
      }

      return user;
    } catch (e) {
      throw Exception('Google login error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromJson({'id': firebaseUser.uid, ...userDoc.data()!});
    } catch (e) {
      throw Exception('Get current user error: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('users')
          .doc(user.id)
          .update(updatedUser.toJson());

      return updatedUser;
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Reset password error: ${e.message}');
    } catch (e) {
      throw Exception('Reset password error: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      await user.sendEmailVerification();
    } catch (e) {
      throw Exception('Send email verification error: $e');
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      await user.reload();
      return user.emailVerified;
    } catch (e) {
      throw Exception('Check email verification error: $e');
    }
  }

  @override
  Future<UserModel> updateRfidCardId({
    required String userId,
    required String rfidCardId,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'rfidCardId': rfidCardId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userDoc = await _firestore.collection('users').doc(userId).get();

      return UserModel.fromJson({'id': userId, ...userDoc.data()!});
    } catch (e) {
      throw Exception('Update RFID error: $e');
    }
  }

  @override
  Future<UserModel?> getUserByRfid(String rfidCardId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('rfidCardId', isEqualTo: rfidCardId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return UserModel.fromJson({'id': doc.id, ...doc.data()});
    } catch (e) {
      throw Exception('Get user by RFID error: $e');
    }
  }
}

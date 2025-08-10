import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Service untuk mengelola autentikasi Firebase
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Stream untuk auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login dengan email dan password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register dengan email dan password
  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    String role = 'santri',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Buat dokumen user di Firestore
        await createUserDocument(
          uid: credential.user!.uid,
          email: email,
          nama: nama,
          role: role,
        );

        // Update display name
        await credential.user!.updateDisplayName(nama);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Login dengan Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in dibatalkan');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user document exists, if not create one
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          await createUserDocument(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email!,
            nama: userCredential.user!.displayName ?? 'User',
            role: 'santri',
          );
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error saat login dengan Google: $e');
    }
  }

  /// Logout
  static Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Error saat logout: $e');
    }
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Get user data dari Firestore
  static Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Error mengambil data user: $e');
    }
  }

  /// Update user data di Firestore
  static Future<void> updateUserData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error mengupdate data user: $e');
    }
  }

  /// Buat dokumen user baru di Firestore (public method)
  static Future<void> createUserDocument({
    required String uid,
    required String email,
    required String nama,
    required String role,
  }) async {
    await _createUserDocument(uid: uid, email: email, nama: nama, role: role);
  }

  /// Buat dokumen user baru di Firestore
  static Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String nama,
    required String role,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'nama': nama,
        'email': email,
        'role': role,
        'poin': 0,
        'fotoProfil': null,
        'statusAktif': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error membuat dokumen user: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Tidak ada user yang ditemukan dengan email tersebut.';
      case 'wrong-password':
        return 'Password yang dimasukkan salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan oleh akun lain.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun user telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Coba lagi nanti.';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }

  /// Check apakah user sudah login
  static bool get isSignedIn => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.uid;

  /// Get current user email
  static String? get currentUserEmail => currentUser?.email;
}

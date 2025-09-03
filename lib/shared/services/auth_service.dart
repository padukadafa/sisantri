import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

      // Setelah login berhasil, update device token
      if (credential.user != null) {
        await _updateDeviceTokenAfterLogin();
      }

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

        // Update device token setelah login berhasil
        await _updateDeviceTokenAfterLogin();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error saat login dengan Google: $e');
    }
  }

  /// Logout dengan timeout dan error handling yang lebih baik
  static Future<void> signOut() async {
    try {
      // Step 1: Hapus device token dengan timeout (3 detik)
      await Future.any([
        _safeRemoveDeviceToken(),
        Future.delayed(const Duration(seconds: 3)),
      ]).catchError((_) {
        // Ignore timeout errors untuk device token removal
      });

      // Step 2: Sign out dengan timeout (5 detik)
      await Future.any([
        Future.wait([_auth.signOut(), _googleSignIn.signOut()]),
        Future.delayed(const Duration(seconds: 5)),
      ]).catchError((_) {
        // Jika timeout, coba sign out satu per satu
        _forceSignOut();
      });
    } catch (e) {
      // Jika semua gagal, coba force sign out
      await _forceSignOut();
      throw Exception('Error saat logout: $e');
    }
  }

  /// Helper method untuk safe device token removal
  static Future<void> _safeRemoveDeviceToken() async {
    try {
      final token = await _getDeviceToken();
      if (token != null) {
        await removeDeviceToken(token);
      }
    } catch (e) {
      // Ignore device token removal errors
    }
  }

  /// Force sign out tanpa timeout
  static Future<void> _forceSignOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Ignore auth sign out errors
    }

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore google sign out errors
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

  /// Update role user
  static Future<void> updateUserRole(String uid, String newRole) async {
    try {
      // Validasi role yang diizinkan
      const allowedRoles = ['admin', 'santri', 'dewan_guru'];
      if (!allowedRoles.contains(newRole)) {
        throw Exception(
          'Role tidak valid. Role yang diizinkan: ${allowedRoles.join(', ')}',
        );
      }

      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error mengupdate role user: $e');
    }
  }

  /// Get semua users berdasarkan role
  static Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .orderBy('nama')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Error mengambil users berdasarkan role: $e');
    }
  }

  /// Get semua dewan guru
  static Future<List<UserModel>> getDewaGuruList() async {
    return getUsersByRole('dewan_guru');
  }

  /// Get semua santri
  static Future<List<UserModel>> getSantriList() async {
    return getUsersByRole('santri');
  }

  /// Get semua admin
  static Future<List<UserModel>> getAdminList() async {
    return getUsersByRole('admin');
  }

  /// Stream untuk realtime data semua users
  static Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('nama')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  /// Stream untuk realtime data users berdasarkan role
  static Stream<List<UserModel>> getUsersByRoleStream(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .orderBy('nama')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  /// Promote santri menjadi dewan guru
  static Future<void> promoteSantriToDewaGuru(String uid) async {
    try {
      final userData = await getUserData(uid);
      if (userData == null) {
        throw Exception('User tidak ditemukan');
      }

      if (userData.role != 'santri') {
        throw Exception(
          'Hanya santri yang bisa dipromosikan menjadi dewan guru',
        );
      }

      await updateUserRole(uid, 'dewan_guru');
    } catch (e) {
      throw Exception('Error promoting santri to dewan guru: $e');
    }
  }

  /// Demote dewan guru menjadi santri
  static Future<void> demoteDewaGuruToSantri(String uid) async {
    try {
      final userData = await getUserData(uid);
      if (userData == null) {
        throw Exception('User tidak ditemukan');
      }

      if (userData.role != 'dewan_guru') {
        throw Exception('Hanya dewan guru yang bisa diturunkan menjadi santri');
      }

      await updateUserRole(uid, 'santri');
    } catch (e) {
      throw Exception('Error demoting dewan guru to santri: $e');
    }
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

  /// Update device token untuk user saat ini
  static Future<void> updateDeviceToken(String token) async {
    final user = currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = UserModel.fromJson({
          'id': user.uid,
          ...userDoc.data()!,
        });

        // Tambah token baru ke list (tanpa duplikasi)
        final updatedTokens = userData.addDeviceToken(token);

        await _firestore.collection('users').doc(user.uid).update({
          'deviceTokens': updatedTokens,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Error updating device token: $e');
    }
  }

  /// Remove device token untuk user saat ini
  static Future<void> removeDeviceToken(String token) async {
    final user = currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = UserModel.fromJson({
          'id': user.uid,
          ...userDoc.data()!,
        });

        // Hapus token dari list
        final updatedTokens = userData.removeDeviceToken(token);

        await _firestore.collection('users').doc(user.uid).update({
          'deviceTokens': updatedTokens,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Error removing device token: $e');
    }
  }

  /// Helper method untuk update device token setelah login
  static Future<void> _updateDeviceTokenAfterLogin() async {
    try {
      // Import NotificationService di atas jika belum ada
      // Dapatkan FCM token dari NotificationService
      final token = await _getDeviceToken();
      if (token != null) {
        await updateDeviceToken(token);
      }
    } catch (e) {
      // Warning: Failed to update device token after login
    }
  }

  /// Helper method untuk mendapatkan device token
  static Future<String?> _getDeviceToken() async {
    try {
      // Kita akan import NotificationService atau langsung gunakan FirebaseMessaging
      final messaging = FirebaseMessaging.instance;
      return await messaging.getToken();
    } catch (e) {
      // Error getting device token
      return null;
    }
  }

  /// Get all users yang memiliki device tokens (untuk keperluan push notification)
  static Future<List<UserModel>> getUsersWithDeviceTokens() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('deviceTokens', isNotEqualTo: null)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
          .where((user) => user.hasDeviceTokens)
          .toList();
    } catch (e) {
      throw Exception('Error getting users with device tokens: $e');
    }
  }

  /// Get device tokens untuk role tertentu (contoh: semua santri)
  static Future<List<String>> getDeviceTokensByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .where('deviceTokens', isNotEqualTo: null)
          .get();

      List<String> allTokens = [];

      for (final doc in querySnapshot.docs) {
        final userData = UserModel.fromJson({'id': doc.id, ...doc.data()});

        allTokens.addAll(userData.safeDeviceTokens);
      }

      return allTokens;
    } catch (e) {
      throw Exception('Error getting device tokens by role: $e');
    }
  }

  /// Get current user email
  static String? get currentUserEmail => currentUser?.email;
}

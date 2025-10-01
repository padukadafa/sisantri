import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Google Sign-In operations
class GoogleAuthOperations {
  final GoogleSignIn _googleSignIn;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  GoogleAuthOperations({
    required GoogleSignIn googleSignIn,
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _googleSignIn = googleSignIn,
       _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  /// Login dengan Google
  Future<UserModel> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
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
        throw Exception('Google sign in failed');
      }

      final firebaseUser = userCredential.user!;

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      UserModel user;
      if (!userDoc.exists) {
        // Create new user dengan role default 'santri'
        user = UserModel(
          id: firebaseUser.uid,
          nama: firebaseUser.displayName ?? 'Unknown',
          email: firebaseUser.email!,
          role: 'santri',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set(user.toJson());
      } else {
        user = UserModel.fromJson({'id': firebaseUser.uid, ...userDoc.data()!});
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Google Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Google sign in error: $e');
    }
  }
}

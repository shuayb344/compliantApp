import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Stream of user changes
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel> signIn(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('User not found after login');
      }

      final userData = await getUserData(credential.user!.uid);
      if (userData == null) {
        throw Exception('User profile not found in database');
      }

      return userData;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Register with email and password
  Future<UserModel?> register(String name, String email, String password, String role) async {
    try {
      debugPrint('AUTH_SERVICE: Attempting register for $email');
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('AUTH_SERVICE: Firebase Auth success: ${credential.user?.uid}');
      
      final UserModel newUser = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user profile to Firestore
      await _db.collection('users').doc(newUser.uid).set(newUser.toJson());
      debugPrint('AUTH_SERVICE: Firestore profile created');
      return newUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('AUTH_SERVICE: FirebaseAuthException: [${e.code}] ${e.message}');
      throw Exception('${e.message} (Code: ${e.code})');
    } catch (e) {
      debugPrint('AUTH_SERVICE: Unknown Error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) return null;

      // Check if user already exists in Firestore
      UserModel? existingUser = await getUserData(user.uid);
      
      if (existingUser != null) {
        return existingUser;
      }

      // Create new user profile if it doesn't exist
      final UserModel newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Google User',
        email: user.email ?? '',
        role: 'user', // Default role for Google Sign-in
        avatarUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.collection('users').doc(newUser.uid).set(newUser.toJson());
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }
      return null;
    } catch (e) {
      log('Error fetching user data: $e');
      return null;
    }
  }

  // Update user profile in Firestore
  Future<UserModel?> updateProfile(String uid, {String? name}) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now(),
      };
      if (name != null && name.isNotEmpty) {
        updates['name'] = name;
      }

      await _db.collection('users').doc(uid).update(updates);

      // Also update Firebase Auth display name
      final currentUser = _auth.currentUser;
      if (currentUser != null && name != null) {
        await currentUser.updateDisplayName(name);
      }

      return await getUserData(uid);
    } catch (e) {
      log('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Handle Firebase Auth errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This user has been disabled.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }

  void log(String message) {
    print('AuthService: $message');
  }
}

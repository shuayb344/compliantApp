import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of user changes
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Mock sign in for now if Firebase is not fully configured
  Future<UserModel> signIn(String email, String password) async {
    try {
      // In a real app, you'd use _auth.signInWithEmailAndPassword
      // For now, let's pretend it succeeds and returns a mock user
      
      // Simulation delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock user logic
      final isEmailAdmin = email.contains('admin');
      
      return UserModel(
        uid: isEmailAdmin ? 'admin_123' : 'user_123',
        name: isEmailAdmin ? 'Admin James' : 'Alex Thompson',
        email: email,
        role: isEmailAdmin ? 'admin' : 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> register(String name, String email, String password, String role) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      return UserModel(
        uid: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    // await _auth.signOut();
  }

  Future<UserModel?> getUserData(String uid) async {
    // try {
    //   DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    //   if (doc.exists) {
    //     return UserModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
    //   }
    // } catch (e) {}
    return null;
  }
}

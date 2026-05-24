import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaint_app/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:complaint_app/models/user_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {
  @override
  String get id => 'user123';
}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  String get id => 'user123';
}

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockDb;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockDb = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    authService = AuthService(auth: mockAuth, db: mockDb, googleSignIn: mockGoogleSignIn);

    when(() => mockUser.uid).thenReturn('user123');
    when(() => mockUserCredential.user).thenReturn(mockUser);
  });

  group('AuthService Unit Tests', () {
    test('signIn returns UserModel on success', () async {
      // Setup
      when(() => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => mockUserCredential);

      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();

      when(() => mockDb.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc('user123')).thenReturn(mockDoc);
      when(() => mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({
        'uid': 'user123',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'user',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Execute
      final result = await authService.signIn('test@example.com', 'password123');

      // Verify
      expect(result.uid, 'user123');
      expect(result.email, 'test@example.com');
      verify(() => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    test('signIn throws exception on FirebaseAuthException', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: 'wrong@example.com',
            password: 'pass',
          )).thenThrow(FirebaseAuthException(code: 'user-not-found', message: 'User not found'));

      expect(
        () => authService.signIn('wrong@example.com', 'pass'),
        throwsA(isA<String>()),
      );
    });

    test('signOut calls FirebaseAuth and GoogleSignIn signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async => {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      
      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });
  });
}

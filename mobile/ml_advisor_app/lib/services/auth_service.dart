import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      print("STEP 1: Creating auth user");

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Don't touch cred.user — get currentUser directly instead
      final user = _auth.currentUser;
      if (user == null) throw Exception('User creation failed');

      print("STEP 2: Auth created ${user.uid}");

      // Update display name via currentUser, not the credential
      await user.updateDisplayName(displayName);
      await user.reload(); // force refresh

      print("STEP 3: Saving Firestore user");

      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("STEP 4: Firestore save success");

      return UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: role,
      );
    } catch (e) {
      print("REGISTER ERROR: $e");
      rethrow;
    }
  }

  Future<UserModel> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    final user = _auth.currentUser;
    if (user == null) throw Exception('Login failed');

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({'uid': user.uid, ...doc.data()!});
      }
    } catch (e) {
      print(e);
    }

    return UserModel(
      uid: user.uid,
      email: user.email ?? email,
      displayName: user.displayName ?? '',
      role: 'student',
    );
  }

  Future<void> logout() => _auth.signOut();

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({'uid': user.uid, ...doc.data()!});
      }
    } catch (e) {
      print(e);
    }

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      role: 'student',
    );
  }
}

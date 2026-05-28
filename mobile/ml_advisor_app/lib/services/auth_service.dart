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
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await cred.user!.updateDisplayName(displayName);

    final user = UserModel(
      uid: cred.user!.uid,
      email: email,
      displayName: displayName,
      role: role,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'role': user.role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  Future<UserModel> login(
    String email,
    String password,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _db.collection('users').doc(cred.user!.uid).get();

    if (!doc.exists) {
      return UserModel(
        uid: cred.user!.uid,
        email: email,
        displayName: cred.user!.displayName ?? '',
        role: 'student',
      );
    }

    return UserModel.fromJson(doc.data()!);
  }

  Future<void> logout() => _auth.signOut();

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }
}

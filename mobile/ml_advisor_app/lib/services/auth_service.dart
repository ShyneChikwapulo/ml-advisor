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
        email: email, password: password);
    
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

  Future<UserModel> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    
    // Don't use the credential directly — get current user after sign in
    final user = _auth.currentUser;
    if (user == null) throw Exception('Login failed');
    
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({'id': user.uid, ...doc.data()!});
      }
    } catch (_) {}
    
    // Fallback if Firestore doc doesn't exist yet
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
    } catch (_) {}
    
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      role: 'student',
    );
  }
}
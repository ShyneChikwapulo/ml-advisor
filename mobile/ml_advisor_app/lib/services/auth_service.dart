import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ✅ FIX 1: Access the modern plugin singleton framework instance directly
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final doc = await _db.collection('users').doc(cred.user!.uid).get();
    if (!doc.exists) {
      return UserModel(
          uid: cred.user!.uid,
          email: email,
          displayName: cred.user!.displayName ?? '',
          role: 'student');
    }
    return UserModel.fromJson(doc.data()!);
  }

  // ── FEDERATED GOOGLE OAUTH SECURITY CHANNEL (v7.0.0+ Compliant) ───────────
  Future<UserModel?> signInWithGoogle() async {
    // Pass your Firebase Web Client ID directly into the initializer here
    await _googleSignIn.initialize(
      serverClientId: '941156980455-085bc80j15f3dd4qcmvovgrkpalakvcc.apps.googleusercontent.com',
    );
    // ✅ FIX 3: Trigger 'authenticate' instead of the deprecated 'signIn'
    final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
    if (googleUser == null) return null; // Flow safely aborted by the user

    // ✅ FIX 4: Request authorization permissions explicitly to obtain the access token
    final List<String> scopes = ['email', 'profile'];
    final clientAuth = await googleUser.authorizationClient.authorizeScopes(scopes);

    // 5. Compile the Firebase token credential mapping from both distinct pipelines
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken, // Identity (Authentication)
      accessToken: clientAuth.accessToken,        // Permissions (Authorization)
    );

    // 6. Sign in to Firebase with the verified credential mapping
    final UserCredential cred = await _auth.signInWithCredential(credential);
    final User? firebaseUser = cred.user;
    if (firebaseUser == null) return null;

    // 7. Synchronize data profile with Firestore
    final doc = await _db.collection('users').doc(firebaseUser.uid).get();
    
    if (!doc.exists) {
      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Google Node',
        role: 'student', 
      );

      await _db.collection('users').doc(firebaseUser.uid).set({
        'uid': newUser.uid,
        'email': newUser.email,
        'displayName': newUser.displayName,
        'role': newUser.role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return newUser;
    }

    return UserModel.fromJson(doc.data()!);
  }

  // ── RECOVERY & VERIFICATION ORCHESTRATION ───────────────────────────────
  Future<void> initializePasswordResetSequence({
    required String target, 
    required bool isPhoneFlow,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    if (!isPhoneFlow) {
      // Standard Email Link Pipeline
      await _auth.sendPasswordResetEmail(email: target);
    } else {
      // Native Firebase Phone Verification/MFA Pipeline
      await _auth.verifyPhoneNumber(
        phoneNumber: target,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Optional: Auto-signing in or resolving if instant verification occurs
        },
        verificationFailed: onVerificationFailed,
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut(); 
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }
}
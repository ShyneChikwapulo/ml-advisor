import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> refreshUserSession() async {
    await init(); 
    notifyListeners(); 
  }

  Future<void> init() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.login(email, password);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }



  Future<bool> register(
      String email, String password, String name, String role) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.register(
          email: email, password: password, displayName: name, role: role);
      _user = await _authService.getCurrentUser();
      return true;
    } on FirebaseAuthException catch (e) {
      // Captures clean codes like 'email-already-in-use' or the actual message
      _error = e.message ?? e.code;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ✅ ADDED: Google Sign-In telemetry transmission hook
  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.signInWithGoogle();
      return _user != null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> sendPasswordRecovery({
      required String target,
      required bool isPhoneFlow,
      Function(String vid)? onSmsSent,
    }) async {
      _loading = true;
      _error = null;
      notifyListeners();
      try {
        await _authService.initializePasswordResetSequence(
          target: target,
          isPhoneFlow: isPhoneFlow,
          onCodeSent: (verificationId) {
            _loading = false;
            notifyListeners();
            if (onSmsSent != null) onSmsSent(verificationId);
          },
          onVerificationFailed: (e) {
            _error = e.message;
            _loading = false;
            notifyListeners();
          },
        );
        if (!isPhoneFlow) {
          _loading = false;
          notifyListeners();
        }
        return true;
      } catch (e) {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
        notifyListeners();
        return false;
      }
    }
}
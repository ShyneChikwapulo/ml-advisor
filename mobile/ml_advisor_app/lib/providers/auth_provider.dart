//ChangeNotifier notifies other widgets/screens of the change in data. It basically tells the UI when data changes
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthDataProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get loading => _loading;

  bool get isLoggedIn =>
      _user !=
      null; //will return false coz at first user is not logged in tehrefore _user will store null and null is NOT not equal to null(!=null), because it is equalt to null, tehrefore returns false
  bool get isAdmin => _user?.email == "admin@email.com";

  final FirebaseAuth _authDetails = FirebaseAuth.instance;

  Future<void> init() async {
    //checks if someone is already logged in
    //initializes something when the app satrts
    _user = _authDetails.currentUser;
    notifyListeners(); //tell flutter to update the UI because something has changed
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    notifyListeners();

    try {
      final result = await _authDetails.signInWithEmailAndPassword(
          email: email, password: password);

      _user = result.user;
      return true;
    } catch (e) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      String email, String password, String name, String role) async {
    _loading = true;
    notifyListeners();

    try {
      final result = await _authDetails.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = result.user;

      return true;
    } catch (e) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authDetails.signOut();
    _user = null;
    notifyListeners();
  }
}

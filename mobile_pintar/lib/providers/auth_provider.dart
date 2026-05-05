import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  firebase_auth.User? _user;
  bool _isLoading = false;

  firebase_auth.User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> checkInitialAuth() async {
    _setLoading(true);
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Login gagal: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _auth.signOut();
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

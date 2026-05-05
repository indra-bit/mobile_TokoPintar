import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> checkInitialAuth() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null) {
      try {
        final userData = await _authService.getUser();
        if (userData != null) {
          _user = userData;
        } else {
          await _clearLocalAuth();
        }
      } catch (e) {
        await _clearLocalAuth();
      }
    }
    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _user = result['user'];
        _token = result['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        _setLoading(false);
        return true;
      } else {
        debugPrint('Login gagal dari server: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Exception saat login: $e');
    }

    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (e) {
      // Ignore error if offline or token expired
    } finally {
      await _clearLocalAuth();
      _setLoading(false);
    }
  }

  Future<void> _clearLocalAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

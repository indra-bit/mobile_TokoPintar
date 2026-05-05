import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'user': User.fromJson(data['user']),
        'token': data['token'],
      };
    } else {
      return {
        'success': false,
        'message': jsonDecode(response.body)['message'] ?? 'Login failed',
      };
    }
  }

  Future<void> logout() async {
    await _apiService.post('/auth/logout', {});
  }

  Future<User?> getUser() async {
    final response = await _apiService.get('/auth/me');

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}

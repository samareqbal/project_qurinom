import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio dio;
  AuthRepository(this.dio);

  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    final resp = await dio.post('/user/login', data: {"email": email, "password": password, "role": role});
    final body = resp.data as Map<String, dynamic>;
    String? token;
    String? userId;
    if (body['token'] != null) token = body['token'] as String;
    if (body['data'] != null) {
      if (body['data']['token'] != null) token = body['data']['token'] as String?;
      userId = body['data']['_id']?.toString() ?? body['data']['id']?.toString();
    }
    final prefs = await SharedPreferences.getInstance();
    if (token != null) await prefs.setString('auth_token', token);
    if (userId != null) await prefs.setString('user_id', userId);
    await prefs.setString('user_role', role);
    return body;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}

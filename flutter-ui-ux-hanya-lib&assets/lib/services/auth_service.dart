import 'api_service.dart';

class AuthService {
  static Future<dynamic> login(String email, String password) async {
    return await ApiService.post('/login', {
      'email': email,
      'password': password,
    });
  }

  static Future<dynamic> register(String email, String password) async {
    return await ApiService.post('/register', {
      'email': email,
      'password': password,
    });
  }

  static Future<dynamic> verifyEmail(String code) async {
    return await ApiService.post('/verify', {
      'code': code,
    });
  }
}

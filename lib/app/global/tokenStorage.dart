import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage{
  static const _tokenKey = "auth_token";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // static Future<void> saveToken(String token) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('auth_token', token);
  // }
  //
  // static Future<String?> getToken() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('auth_token');
  // }
  //
  // static Future<void> removeToken() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('auth_token');
  // }
}
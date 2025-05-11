// lib/services/token_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userIdKey = 'user_id';

  Future<void> saveTokenAndUserDetails(
    String token,
    String userName,
    int userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userNameKey, userName);
    await prefs.setInt(_userIdKey, userId);
    debugPrint('TokenService: Token and user details saved.');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString(_userNameKey);
    final int? id = prefs.getInt(_userIdKey);
    final String? tokenUsr = prefs.getString(_tokenKey);
    if (name != null && id != null) {
      debugPrint('TokenService: Token: $tokenUsr and user details deleted.');
      return {'name': name, 'id': id};
    }
    return null;
  }

  Future<void> deleteTokenAndUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userIdKey);
    debugPrint('TokenService: Token and user details deleted.');
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _tokenKey = 'club_echecs_access_token';
  static const _userKey = 'club_echecs_user';

  Future<void> save(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final token = payload['tokens'] is Map<String, dynamic>
        ? payload['tokens']['access']?.toString()
        : null;
    final user = payload['user'] as Map<String, dynamic>?;
    if (token != null) await prefs.setString(_tokenKey, token);
    if (user != null) await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> user() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}

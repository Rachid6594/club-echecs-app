import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    this.baseUrl = const String.fromEnvironment(
      'MOBILE_API_BASE_URL',
      defaultValue: 'http://localhost:8000/api',
    ),
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'display_name': displayName,
      }),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, body);
    }
    return body;
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;
}


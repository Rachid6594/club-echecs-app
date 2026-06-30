import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    this.baseUrl = const String.fromEnvironment(
      'MOBILE_API_BASE_URL',
      defaultValue: 'https://club-echecs-api.vercel.app/api',
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

  Future<Map<String, dynamic>> appLogin(String email, String password) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/app/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> appRegister({
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/app/auth/register/'),
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

  Future<List<dynamic>> getList(String path) async {
    if (const bool.fromEnvironment('USE_FAKE_AUTH')) {
      if (path.contains('badges')) {
        return [
          {'name': 'Premiere victoire'},
          {'name': 'Champion de tournoi'},
        ];
      }
      if (path.contains('tournaments')) {
        return [
          {'name': 'Coupe du Club', 'format': 'single_elimination', 'status': 'registration_open'},
        ];
      }
      if (path.contains('rankings')) {
        return [
          {'display_name': 'Rachid', 'points': 120, 'rank_name': 'Novice I'},
        ];
      }
      if (path.contains('notifications')) {
        return [
          {'title': 'Invitation recue', 'body': 'Awa vous invite a jouer.'},
        ];
      }
      if (path.contains('live-matches')) {
        return [
          {'white_username': 'Blancs', 'black_username': 'Noirs', 'status': 'active', 'tournament_name': 'Table 1'},
        ];
      }
      return <dynamic>[];
    }
    final response = await _httpClient.get(Uri.parse('$baseUrl$path'));
    final body = _decode(response);
    return (body['results'] as List<dynamic>?) ?? <dynamic>[];
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


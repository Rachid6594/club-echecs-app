import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_store.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    SessionStore? sessionStore,
    this.baseUrl = const String.fromEnvironment(
      'MOBILE_API_BASE_URL',
      defaultValue: 'https://club-echecs-api.vercel.app/api',
    ),
  })  : _httpClient = httpClient ?? http.Client(),
        _sessionStore = sessionStore ?? SessionStore();

  final http.Client _httpClient;
  final SessionStore _sessionStore;
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
    final payload = _decode(response);
    await _sessionStore.save(payload);
    return payload;
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
    final payload = _decode(response);
    await _sessionStore.save(payload);
    return payload;
  }

  Future<Map<String, dynamic>?> cachedUser() => _sessionStore.user();

  Future<void> logout() => _sessionStore.clear();

  Future<List<dynamic>> getList(String path) async {
    if (const bool.fromEnvironment('USE_FAKE_AUTH')) {
      if (path.contains('members')) {
        return [
          {
            'user_id': 'member-1',
            'username': 'awa',
            'display_name': 'Awa',
            'rank_name': 'Novice I',
            'points': 80,
            'email': 'awa@test.local'
          },
        ];
      }
      if (path.contains('invitations/received')) {
        return [
          {
            'id': 'invite-1',
            'other_display_name': 'Awa',
            'status': 'pending',
            'message': 'Partie amicale'
          },
        ];
      }
      if (path.contains('invitations/sent')) {
        return <dynamic>[];
      }
      if (path.contains('games/history')) {
        return [
          {
            'white_username': 'Joueur du club',
            'black_username': 'Awa',
            'status': 'completed',
            'result': '1-0'
          },
        ];
      }
      if (path.contains('badges')) {
        return [
          {'name': 'Premiere victoire'},
          {'name': 'Champion de tournoi'},
        ];
      }
      if (path.contains('tournaments')) {
        return [
          {
            'name': 'Coupe du Club',
            'format': 'single_elimination',
            'status': 'registration_open'
          },
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
          {
            'white_username': 'Blancs',
            'black_username': 'Noirs',
            'status': 'active',
            'tournament_name': 'Table 1'
          },
        ];
      }
      return <dynamic>[];
    }
    final response = await _httpClient.get(Uri.parse('$baseUrl$path'),
        headers: await _headers());
    final body = _decode(response);
    return (body['results'] as List<dynamic>?) ?? <dynamic>[];
  }

  Future<Map<String, dynamic>> getMap(String path) async {
    if (const bool.fromEnvironment('USE_FAKE_AUTH')) {
      if (path == '/app/me/') {
        return {
          'user': {
            'display_name': 'Joueur du club',
            'rank_name': 'Novice I',
            'points': 0,
            'email': 'joueur@test.local'
          }
        };
      }
      return <String, dynamic>{};
    }
    final response = await _httpClient.get(Uri.parse('$baseUrl$path'),
        headers: await _headers());
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    if (const bool.fromEnvironment('USE_FAKE_AUTH')) {
      return {'ok': true};
    }
    final response = await _httpClient.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _sessionStore.token();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.trim().isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
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

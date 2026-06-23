import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_session.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _client = http.Client();

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
    final headers = {..._jsonHeaders};
    if (auth) {
      final token = AuthSession.instance.accessToken;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final response = await _client.get(uri, headers: headers);
    return _parse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = {..._jsonHeaders};
      if (auth) {
        final token = AuthSession.instance.accessToken;
        if (token != null) headers['Authorization'] = 'Bearer $token';
      }
      final response = await _client.post(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
      return _parse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Cannot reach server at ${ApiConfig.baseUrl}. Is the API running?',
      );
    }
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = {..._jsonHeaders};
    final token = AuthSession.instance.accessToken;
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final response = await _client.patch(
      uri,
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _parse(response);
  }

  Map<String, dynamic> _parse(http.Response response) {
    Map<String, dynamic>? json;
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) json = decoded;
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok) {
      final message = json?['message'] as String? ??
          json?['error'] as String? ??
          'Request failed (${response.statusCode})';
      throw ApiException(message, statusCode: response.statusCode);
    }

    return json ?? {'success': true};
  }
}

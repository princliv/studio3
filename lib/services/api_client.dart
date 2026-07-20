import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_session.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Dio? _dio;
  CookieJar? _cookieJar;
  bool _initializing = false;
  bool _refreshing = false;

  Future<void> _ensureInitialized() async {
    if (_dio != null || _initializing) return;
    _initializing = true;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _cookieJar = PersistCookieJar(
        storage: FileStorage('${dir.path}/.cookies/'),
      );
      _dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
      _dio!.interceptors.add(CookieManager(_cookieJar!));
      _dio!.interceptors.add(InterceptorsWrapper(
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          if (status == 401 &&
              error.requestOptions.extra['retried'] != true &&
              !path.contains('/api/auth/refresh') &&
              !path.contains('/api/auth/login') &&
              !path.contains('/api/auth/register')) {
            try {
              await _refreshToken();
              final opts = error.requestOptions;
              opts.extra['retried'] = true;
              opts.headers['Authorization'] =
                  'Bearer ${AuthSession.instance.accessToken}';
              final response = await _dio!.fetch(opts);
              return handler.resolve(response);
            } catch (_) {
              await AuthSession.instance.clear();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ));
    } finally {
      _initializing = false;
    }
  }

  Future<Dio> get _client async {
    await _ensureInitialized();
    return _dio!;
  }

  Map<String, String> _authHeaders({bool auth = false}) {
    final headers = <String, String>{};
    if (auth) {
      final token = AuthSession.instance.accessToken;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = false,
  }) async {
    try {
      final dio = await _client;
      final response = await dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
        options: Options(headers: _authHeaders(auth: auth)),
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException(
        'Cannot reach server at ${ApiConfig.baseUrl}. Is the API running?',
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    try {
      final dio = await _client;
      final response = await dio.post<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(headers: _authHeaders(auth: auth)),
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _toApiException(e);
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
    try {
      final dio = await _client;
      final response = await dio.patch<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(headers: _authHeaders(auth: auth)),
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException(
        'Cannot reach server at ${ApiConfig.baseUrl}. Is the API running?',
      );
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final dio = await _client;
      final response = await dio.delete<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(headers: _authHeaders(auth: auth)),
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException(
        'Cannot reach server at ${ApiConfig.baseUrl}. Is the API running?',
      );
    }
  }

  Future<void> uploadToPresignedUrl({
    required String presignedPutUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final uploadDio = Dio();
    try {
      await uploadDio.put<void>(
        presignedPutUrl,
        data: bytes,
        options: Options(
          headers: {'Content-Type': contentType},
          contentType: contentType,
        ),
      );
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> _refreshToken() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final json = await post('/api/auth/refresh');
      final data = json['data'] as Map<String, dynamic>? ?? {};
      final token = data['accessToken'] as String?;
      final userJson = data['user'] as Map<String, dynamic>?;
      if (token != null) {
        await AuthSession.instance.updateToken(token);
        if (userJson != null) {
          await AuthSession.instance.updateUserFromJson(userJson);
        }
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<void> refreshToken() => _refreshToken();

  Map<String, dynamic> _parseResponse(Response<Map<String, dynamic>> response) {
    return response.data ?? {'success': true};
  }

  ApiException _toApiException(DioException e) {
    final response = e.response;
    if (response?.data is Map<String, dynamic>) {
      final json = response!.data as Map<String, dynamic>;
      final message = json['message'] as String? ??
          json['error'] as String? ??
          'Request failed (${response.statusCode})';
      return ApiException(message, statusCode: response.statusCode);
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return ApiException(
        'Cannot reach server at ${ApiConfig.baseUrl}. Is the API running?',
      );
    }
    return ApiException(
      e.message ?? 'Request failed',
      statusCode: response?.statusCode,
    );
  }

  dynamic extractData(Map<String, dynamic> json) {
    return json['data'] ?? json;
  }

  List<Map<String, dynamic>> extractList(Map<String, dynamic> json) {
    final data = extractData(json);
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      for (final key in [
        'items',
        'pieces',
        'posts',
        'feed',
        'results',
        'orders',
        'sales',
        'addresses',
        'methods',
      ]) {
        final list = data[key];
        if (list is List) {
          return list.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }
}

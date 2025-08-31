import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as getx;

class ApiService {
  static const String _baseUrl = 'https://your-api-base-url.com'; // TODO: Replace with actual API URL
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add pretty logging in debug mode
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add access token to requests
        final token = await getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 errors (token expired)
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshAccessToken();
          if (refreshed) {
            // Retry the original request with new token
            final newToken = await getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            
            final retryResponse = await _dio.request(
              error.requestOptions.path,
              options: Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              ),
              data: error.requestOptions.data,
              queryParameters: error.requestOptions.queryParameters,
            );
            handler.resolve(retryResponse);
          } else {
            // Refresh failed, redirect to login
            await clearTokens();
            getx.Get.offAllNamed('/login');
            handler.next(error);
          }
        } else {
          handler.next(error);
        }
      },
    ));
  }

  // Token management
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Don't include auth header for refresh
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

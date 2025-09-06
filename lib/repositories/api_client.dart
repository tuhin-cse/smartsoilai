import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import 'exceptions/api_exception.dart';

class ApiClient {
  late Dio _dio;
  static ApiClient? _instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient._internal() {
    _dio = Dio();
    _setupInterceptors();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = Duration(
      milliseconds: AppConfig.connectTimeoutMs,
    );
    _dio.options.receiveTimeout = Duration(
      milliseconds: AppConfig.receiveTimeoutMs,
    );
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    // Request interceptor for adding auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(
            key: AppConfig.accessTokenKey,
          );

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Retry the original request
              final originalRequest = error.requestOptions;
              final newToken = await _secureStorage.read(
                key: AppConfig.accessTokenKey,
              );

              if (newToken != null) {
                originalRequest.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.fetch(originalRequest);
                handler.resolve(response);
                return;
              }
            }
            // If refresh failed, clear tokens and redirect to login
            await _clearTokens();
          }

          handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    if (AppConfig.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) {
            print(object);
          },
        ),
      );
    }
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: AppConfig.refreshTokenKey,
      );

      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Don't include old token
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _secureStorage.write(
          key: AppConfig.accessTokenKey,
          value: data['accessToken'],
        );
        await _secureStorage.write(
          key: AppConfig.refreshTokenKey,
          value: data['refreshToken'],
        );
        return true;
      }
    } catch (e) {
      // Refresh failed
    }

    return false;
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
    await _secureStorage.delete(key: AppConfig.userKey);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException(
            message: 'Request timeout. Please check your internet connection.',
          );
        case DioExceptionType.connectionError:
          return NetworkException(
            message: 'Network error. Please check your internet connection.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = _extractErrorMessage(error.response?.data);
          final errorType = _getErrorType(error.response?.data);

          switch (statusCode) {
            case 400:
              return ValidationException(
                message: message,
                errors: _extractValidationErrors(error.response?.data),
              );
            case 401:
              if (errorType == 'EMAIL_NOT_VERIFIED') {
                return ApiException(
                  message: message,
                  statusCode: statusCode,
                  errorCode: errorType,
                );
              }
              return UnauthorizedException(message: message);
            case 409:
              return ApiException(message: message, statusCode: statusCode);
            case 500:
            default:
              return ServerException(message: message);
          }
        default:
          return ApiException(
            message: error.message ?? 'An unexpected error occurred',
          );
      }
    }

    return ApiException(message: error.toString());
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? 'An error occurred';
    }
    return 'An error occurred';
  }

  String _getErrorType(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['error'] ?? 'UNKNOWN';
    }
    return 'UNKNOWN';
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.cast<String>());
          } else if (value is String) {
            return MapEntry(key, [value]);
          }
          return MapEntry(key, [value.toString()]);
        });
      }
    }
    return null;
  }
}

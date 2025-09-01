import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class NetworkService extends GetxService {
  static const String baseUrl = AppConfig.baseUrl;
  static const Duration timeout = Duration(
    milliseconds: AppConfig.connectTimeoutMs,
  );

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.accessTokenKey);

    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final authHeaders = await _getAuthHeaders();
      final allHeaders = {...authHeaders, ...?headers};

      final response = await http
          .get(url, headers: allHeaders)
          .timeout(timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timeout';
    } on SocketException {
      throw 'No internet connection';
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final authHeaders = await _getAuthHeaders();
      final allHeaders = {...authHeaders, ...?headers};

      final response = await http
          .post(
            url,
            headers: allHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timeout';
    } on SocketException {
      throw 'No internet connection';
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final authHeaders = await _getAuthHeaders();
      final allHeaders = {...authHeaders, ...?headers};

      final response = await http
          .put(
            url,
            headers: allHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timeout';
    } on SocketException {
      throw 'No internet connection';
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final authHeaders = await _getAuthHeaders();
      final allHeaders = {...authHeaders, ...?headers};

      final response = await http
          .delete(url, headers: allHeaders)
          .timeout(timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timeout';
    } on SocketException {
      throw 'No internet connection';
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    switch (statusCode) {
      case 200:
      case 201:
        if (body.isEmpty) return {};
        return jsonDecode(body);
      case 400:
        throw 'Bad request: ${jsonDecode(body)['message'] ?? 'Invalid request'}';
      case 401:
        throw 'Unauthorized: Please login again';
      case 403:
        throw 'Forbidden: Access denied';
      case 404:
        throw 'Not found: Resource not found';
      case 422:
        throw 'Validation error: ${jsonDecode(body)['message'] ?? 'Invalid data'}';
      case 500:
        throw 'Server error: Please try again later';
      default:
        throw 'HTTP $statusCode: ${jsonDecode(body)['message'] ?? 'Unknown error'}';
    }
  }

  // Check internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

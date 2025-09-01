import '../repositories/api_client.dart';
import '../repositories/exceptions/api_exception.dart';

class ProfileRepository {
  final _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updateData) async {
    try {
      await _apiClient.put('/auth/profile', data: updateData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(dynamic error) {
    if (error is ApiException) return error;
    return ApiException(message: error.toString());
  }
}

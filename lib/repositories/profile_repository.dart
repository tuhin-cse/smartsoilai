import 'package:get/get.dart';
import '../services/network_service.dart';
import '../repositories/exceptions/api_exception.dart';

class ProfileRepository {
  final NetworkService _networkService = Get.find<NetworkService>();

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      return await _networkService.get('/auth/profile');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updateData) async {
    try {
      await _networkService.put('/auth/profile', body: updateData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(dynamic error) {
    if (error is ApiException) return error;
    return ApiException(message: error.toString());
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../config/farmbrite_config.dart';

class FarmbriteService extends GetxService {
  final String apiKey = FarmbriteConfig.apiKey;
  final String baseUrl = FarmbriteConfig.baseUrl;

  final isLoading = false.obs;
  final error = ''.obs;

  // Observable data
  final fieldData = <String, dynamic>{}.obs;
  final satelliteImageUrl = ''.obs;
  final soilMoisture = ''.obs;
  final cropHealth = ''.obs;
  final fieldSize = ''.obs;
  final cropType = ''.obs;
  final lastUpdated = ''.obs;

  Future<void> fetchFieldData([String? fieldId]) async {
    final actualFieldId = fieldId ?? FarmbriteConfig.defaultFieldId;

    if (actualFieldId == 'your_field_id_here') {
      loadMockData();
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.get(
        Uri.parse('$baseUrl/fields/$actualFieldId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic>) {
          fieldData.value = jsonData;

          // Extract and format field information
          final area = jsonData['area'] ?? jsonData['size'] ?? 0;
          fieldSize.value = '${area.toString()} acres';

          final moisture =
              jsonData['soil_moisture'] ?? jsonData['moisture'] ?? 0;
          soilMoisture.value = _getSoilMoistureStatus(moisture.toDouble());

          final health = jsonData['crop_health'] ?? jsonData['health'] ?? 0;
          cropHealth.value = _getCropHealthStatus(health.toDouble());

          cropType.value =
              jsonData['crop_type'] ?? jsonData['crop'] ?? 'Unknown';

          final updated = jsonData['last_updated'] ?? jsonData['updated_at'];
          if (updated != null) {
            lastUpdated.value =
                'Last updated: ${DateTime.parse(updated.toString()).toLocal()}';
          }

          // Fetch satellite imagery
          await fetchSatelliteImage(actualFieldId);
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401) {
        error.value = 'Authentication failed. Please check your API key.';
      } else if (response.statusCode == 404) {
        error.value = 'Field not found. Please check the field ID.';
      } else {
        error.value = 'Failed to fetch field data (${response.statusCode})';
      }
    } catch (e) {
      error.value = 'Network error: ${e.toString()}';
      // Fallback to mock data on error
      loadMockData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSatelliteImage(String fieldId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fields/$fieldId/satellite-image'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final imageJson = json.decode(response.body);
        satelliteImageUrl.value =
            imageJson['image_url'] ?? imageJson['url'] ?? '';
      }
    } catch (e) {
      // Satellite image is optional, use fallback
      satelliteImageUrl.value = 'assets/images/field.png';
    }
  }

  String _getSoilMoistureStatus(double moisture) {
    if (moisture < 20) return 'Very Low';
    if (moisture < 40) return 'Low';
    if (moisture < 60) return 'Moderate';
    if (moisture < 80) return 'Good';
    return 'High';
  }

  String _getCropHealthStatus(double health) {
    if (health < 30) return 'Poor';
    if (health < 50) return 'Fair';
    if (health < 70) return 'Good';
    if (health < 90) return 'Very Good';
    return 'Excellent';
  }

  Future<void> refreshData([String? fieldId]) async {
    await fetchFieldData(fieldId);
  }

  // Mock data for testing when API is not configured
  void loadMockData() {
    fieldData.value = {
      'id': 'mock_field_001',
      'name': 'Demo Field',
      'area': 2.5,
      'size': 2.5,
      'soil_moisture': 65.0,
      'moisture': 65.0,
      'crop_health': 88.0,
      'health': 88.0,
      'crop_type': 'Corn',
      'crop': 'Corn',
      'last_updated': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    fieldSize.value = '2.5 acres';
    soilMoisture.value = 'Good';
    cropHealth.value = 'Excellent';
    cropType.value = 'Corn';
    lastUpdated.value = 'Last updated: ${DateTime.now().toLocal()}';
    satelliteImageUrl.value = 'assets/images/field.png';
    error.value = '';
  }

  // Get field summary for display
  String getFieldSummary() {
    if (fieldData.isEmpty) return 'No field data available';

    return 'Field: ${fieldSize.value}\n'
        'Crop: ${cropType.value}\n'
        'Soil Moisture: ${soilMoisture.value}\n'
        'Crop Health: ${cropHealth.value}\n'
        '${lastUpdated.value}';
  }
}

import 'package:get/get.dart';

class SoilMeterController extends GetxController {
  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isConnected = false.obs; // Sensor connection status
  final RxInt currentStyle = 0.obs; // 0 = style 1, 1 = style 2, 2 = style 3

  // Soil meter data
  final RxDouble temperature = 0.0.obs;
  final RxDouble humidity = 0.0.obs;
  final RxDouble ph = 0.0.obs;
  final RxDouble ec = 0.0.obs;
  final RxDouble nitrogen = 0.0.obs;
  final RxDouble phosphorus = 0.0.obs;
  final RxDouble potassium = 0.0.obs;
  final RxDouble salinity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Start with disconnected state
    isConnected.value = false;
  }

  /// Toggle sensor connection status
  void toggleConnection() {
    isConnected.value = !isConnected.value;
    if (isConnected.value) {
      loadSoilData();
    }
  }

  /// Toggle between different UI styles
  void toggleStyle() {
    currentStyle.value = (currentStyle.value + 1) % 3;
  }

  /// Load soil sensor data
  Future<void> loadSoilData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Simulate sensor connection check
      await Future.delayed(const Duration(seconds: 1));

      if (!isConnected.value) {
        isLoading.value = false;
        return;
      }

      // Mock data - matching the design values
      temperature.value = 21.3;
      humidity.value = 28.0; // Soil moisture
      ph.value = 6.3;
      ec.value = 0.3;
      nitrogen.value = 93.0;
      phosphorus.value = 122.22;
      potassium.value = 22.03;
      salinity.value = 17.30;
    } catch (e) {
      errorMessage.value = 'Failed to load soil data';
      Get.snackbar(
        'Error',
        'Failed to load soil sensor data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh soil data
  Future<void> refreshSoilData() async {
    await loadSoilData();
  }

  /// Get soil health status based on parameters
  String getSoilHealthStatus() {
    if (ph.value < 5.5 || ph.value > 8.5) return 'Poor';
    if (nitrogen.value < 20 || phosphorus.value < 10 || potassium.value < 100)
      return 'Fair';
    return 'Good';
  }

  /// Get recommendations based on soil data
  List<String> getRecommendations() {
    List<String> recommendations = [];

    if (ph.value < 6.0) {
      recommendations.add('Consider adding lime to increase soil pH');
    } else if (ph.value > 7.5) {
      recommendations.add('Consider adding sulfur to decrease soil pH');
    }

    if (nitrogen.value < 30) {
      recommendations.add(
        'Nitrogen levels are low, consider nitrogen-rich fertilizers',
      );
    }

    if (phosphorus.value < 15) {
      recommendations.add(
        'Phosphorus levels are low, consider phosphorus fertilizers',
      );
    }

    if (potassium.value < 150) {
      recommendations.add(
        'Potassium levels are low, consider potassium fertilizers',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Soil conditions look good, continue monitoring');
    }

    return recommendations;
  }
}

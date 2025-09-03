import 'package:get/get.dart';
import '../models/reports/report.dart';
import '../repositories/reports_repository.dart';
import '../repositories/exceptions/api_exception.dart';

class ReportDetailController extends GetxController {
  final ReportsRepository _reportsRepository = ReportsRepository();
  final String reportId;

  ReportDetailController(this.reportId);

  // Reactive variables
  final RxBool isLoading = true.obs;
  final Rx<ReportResponseDto?> report = Rx<ReportResponseDto?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadReportDetails();
  }

  /// Load report details from the API
  Future<void> loadReportDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final reportData = await _reportsRepository.getReportById(reportId);
      report.value = reportData;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _handleApiError(e);
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'Failed to load report details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh report details
  Future<void> refreshReport() async {
    await loadReportDetails();
  }

  /// Handle API errors with appropriate user feedback
  void _handleApiError(ApiException e) {
    String userMessage;
    
    switch (e.statusCode) {
      case 404:
        userMessage = 'Report not found';
        // Navigate back after showing error
        Future.delayed(const Duration(seconds: 2), () {
          if (Get.isRegistered<ReportDetailController>()) {
            Get.back();
          }
        });
        break;
      case 401:
        userMessage = 'Please log in to view this report';
        break;
      case 403:
        userMessage = 'You don\'t have permission to view this report';
        break;
      case 500:
        userMessage = 'Server error. Please try again later';
        break;
      default:
        userMessage = e.message;
    }

    Get.snackbar(
      'Error',
      userMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Navigate back to previous screen
  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}

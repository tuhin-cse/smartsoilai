import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../models/reports/report.dart';
import '../../repositories/reports_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class ReportsController extends GetxController {
  final ReportsRepository _reportsRepository = ReportsRepository();
  final AuthController _authController = Get.find<AuthController>();

  // Observable state
  final reports = <ReportListItemDto>[].obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  // Load reports from API
  Future<void> loadReports() async {
    if (!_authController.isAuthenticated) return;

    try {
      final fetchedReports = await _reportsRepository.getReports();
      reports.value = fetchedReports;
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to load reports. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh reports
  Future<void> onRefresh() async {
    isRefreshing.value = true;
    await loadReports();
    isRefreshing.value = false;
  }

  // Format date string
  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get crop icon or default
  String getCropIcon(String? cropIcon) {
    return cropIcon?.isNotEmpty == true ? cropIcon! : '🌱';
  }

  // Navigate to report detail
  void handleReportPress(String reportId) {
    Get.toNamed(AppRoutes.reportDetail, arguments: {'reportId': reportId});
  }

  // Delete report with confirmation
  Future<void> handleDeleteReport(String reportId, String reportName) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "$reportName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog first
              try {
                await _reportsRepository.deleteReport(reportId);
                reports.removeWhere((r) => r.id == reportId);
                Get.snackbar(
                  'Success',
                  'Report deleted successfully',
                  backgroundColor: AppColors.successLight,
                  colorText: AppColors.textPrimary,
                );
              } catch (e) {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Error'),
                    content: const Text('Failed to delete report'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Navigate to fertilizer calculator
  void createFirstReport() {
    Get.toNamed(AppRoutes.fertilizerCalculator);
  }

  // Navigate back to main navigation
  void goBack() {
    Get.back();
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());
    
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(controller),
            
            // Content
            Expanded(
              child: Obx(() {
                if (!controller._authController.isAuthenticated) {
                  return _buildAuthRequiredState();
                }
                
                return RefreshIndicator(
                  onRefresh: controller.onRefresh,
                  color: AppColors.primary500,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildContent(controller),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ReportsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF435862),
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Reports',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildContent(ReportsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }
      
      if (controller.reports.isEmpty) {
        return _buildEmptyState(controller);
      }
      
      return Column(
        children: controller.reports
            .map((report) => _buildReportCard(controller, report))
            .toList(),
      );
    });
  }

  Widget _buildReportCard(ReportsController controller, ReportListItemDto report) {
    return GestureDetector(
      onTap: () => controller.handleReportPress(report.id),
      onLongPress: () => controller.handleDeleteReport(report.id, report.name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8EBE8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Report icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  controller.getCropIcon(report.cropIcon),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Report content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${controller.formatDate(report.date)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ReportsController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Column(
          children: [
            // Empty icon
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: const Icon(
                Icons.description_outlined,
                size: 64,
                color: Color(0xFFD1D5DB),
              ),
            ),
            
            // Empty title
            const Text(
              'No Reports Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Empty text
            const Text(
              'Start analyzing your soil to generate your first report. Your analysis history will appear here.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Create report button
            CustomButton(
              title: 'Create Your First Report',
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              onPressed: controller.createFirstReport,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your reports...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthRequiredState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Please sign in to view your reports',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

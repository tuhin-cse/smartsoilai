import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../controllers/disease_analysis_controller.dart';
import '../../models/chat/crop_disease_analysis.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loader.dart';

class DiseaseAnalysisScreen extends StatelessWidget {
  const DiseaseAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DiseaseAnalysisController());
    
    // Get arguments if passed from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['analysis'] != null) {
        controller.setAnalysisData(args['analysis'] as DiseaseAnalysisDto);
      }
      if (args['imageFile'] != null) {
        controller.setImageFile(args['imageFile'] as File);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: Loader());
                }
                
                if (!controller.hasAnalysis.value) {
                  return _buildNoAnalysisView();
                }

                return SingleChildScrollView(
                  child: controller.currentView.value == 'results'
                      ? _buildResultsView(controller)
                      : _buildAdviceView(controller),
                );
              }),
            ),
            _buildBottomButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DiseaseAnalysisController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8EAE7), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (controller.currentView.value == 'advice') {
                controller.switchToResultsView();
              } else {
                Get.back();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF435862),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() => Text(
              controller.currentView.value == 'results' 
                  ? 'Analysis Results' 
                  : 'Plant Care Advice',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            )),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildNoAnalysisView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No Analysis Data Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please capture or select an image to analyze crop diseases.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(DiseaseAnalysisController controller) {
    return Obx(() {
      final analysis = controller.analysisData.value;
      if (analysis == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview if available
            if (controller.imageFile.value != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(controller.imageFile.value!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],

            // Diagnosis Results Section
            const Text(
              'Diagnosis Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            ...analysis.results.map((result) => Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result.title}:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      );
    });
  }

  Widget _buildAdviceView(DiseaseAnalysisController controller) {
    return Obx(() {
      final analysis = controller.analysisData.value;
      if (analysis == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: analysis.advices.map((adviceSection) => Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Icon(
                      controller.getAdviceIcon(adviceSection.key),
                      size: 20,
                      color: controller.getAdviceColor(adviceSection.key),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.getAdviceTitle(adviceSection.key),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Advice Items
                ...adviceSection.advices.map((advice) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            decoration: BoxDecoration(
                              color: controller.getAdviceColor(adviceSection.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${advice.title}:',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Text(
                          advice.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          )).toList(),
        ),
      );
    });
  }

  Widget _buildBottomButton(DiseaseAnalysisController controller) {
    return Obx(() {
      if (!controller.hasAnalysis.value || controller.currentView.value == 'advice') {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE8EAE7), width: 1),
          ),
        ),
        child: SafeArea(
          child: CustomButton(
            title: 'Get Advice',
            variant: ButtonVariant.primary,
            fullWidth: true,
            onPressed: controller.switchToAdviceView,
          ),
        ),
      );
    });
  }
}

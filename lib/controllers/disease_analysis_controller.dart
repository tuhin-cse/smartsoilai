import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/chat/crop_disease_analysis.dart';
import '../repositories/chat_repository.dart';
import '../repositories/exceptions/api_exception.dart';
import '../controllers/auth_controller.dart';

class DiseaseAnalysisController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthController _authController = Get.find<AuthController>();
  
  // Observable states
  final isLoading = false.obs;
  final error = ''.obs;
  final currentView = 'results'.obs; // 'results' or 'advice'
  
  // Analysis data
  final analysisData = Rxn<DiseaseAnalysisDto>();
  final imageFile = Rxn<File>();
  final imageBase64 = ''.obs;

  // State tracking
  final hasAnalysis = false.obs;

  /// Set the image file and convert to base64
  void setImageFile(File file) {
    imageFile.value = file;
    _convertImageToBase64(file);
  }

  /// Convert image file to base64 string
  Future<void> _convertImageToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      imageBase64.value = base64String;
    } catch (e) {
      error.value = 'Failed to process image: $e';
    }
  }

  /// Set analysis data directly (for testing or passing from other screens)
  void setAnalysisData(DiseaseAnalysisDto data) {
    analysisData.value = data;
    hasAnalysis.value = true;
    currentView.value = 'results';
  }

  /// Analyze crop disease using the API
  Future<void> analyzeCropDisease() async {
    if (!_authController.isAuthenticated) {
      Get.dialog(
        AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text('Please log in to analyze crop diseases'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (imageBase64.value.isEmpty) {
      error.value = 'Please select an image first';
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final requestDto = CropDiseaseAnalysisRequestDto(
        imageBase64: imageBase64.value,
      );

      final response = await _chatRepository.analyzeCropDisease(requestDto);
      
      analysisData.value = response.diseaseAnalysis;
      hasAnalysis.value = true;
      currentView.value = 'results';

      // Show success message
      Get.snackbar(
        'Success',
        'Disease analysis completed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

    } on ApiException catch (e) {
      error.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      error.value = 'An unexpected error occurred: $e';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Switch between results and advice views
  void switchToAdviceView() {
    currentView.value = 'advice';
  }

  void switchToResultsView() {
    currentView.value = 'results';
  }

  /// Get advice icon based on category key
  IconData getAdviceIcon(String key) {
    switch (key) {
      case 'fertilizer':
        return Icons.eco;
      case 'watering':
        return Icons.water_drop;
      case 'pest_control':
        return Icons.bug_report;
      case 'location':
        return Icons.location_on;
      default:
        return Icons.info;
    }
  }

  /// Get advice color based on category key
  Color getAdviceColor(String key) {
    switch (key) {
      case 'fertilizer':
        return const Color(0xFF8B5CF6);
      case 'watering':
        return const Color(0xFF3B82F6);
      case 'pest_control':
        return const Color(0xFFF59E0B);
      case 'location':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF62BE24);
    }
  }

  /// Get advice title based on category key
  String getAdviceTitle(String key) {
    switch (key) {
      case 'fertilizer':
        return 'Fertilizer Recommendations';
      case 'watering':
        return 'Watering Guidelines';
      case 'pest_control':
        return 'Pest Control';
      case 'location':
        return 'Location & Environment';
      default:
        return 'Recommendations';
    }
  }

  /// Clear all data
  void clearData() {
    analysisData.value = null;
    imageFile.value = null;
    imageBase64.value = '';
    hasAnalysis.value = false;
    currentView.value = 'results';
    error.value = '';
    isLoading.value = false;
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}

// Fertilizer Calculator Screen
// 
// This screen provides a comprehensive fertilizer calculation functionality that includes:
// 1. Two-step process: Sensor data input and calculation parameters
// 2. AI-powered crop recommendations based on soil sensor data
// 3. Fertilizer calculation using ChatRepository API
// 4. Report saving functionality using ReportsRepository
// 5. Modal interfaces for crop selection and report saving
// 
// Features:
// - Sensor data collection (temperature, humidity, EC, pH, NPK, salinity)
// - AI crop recommendations with suitability scores
// - Fertilizer calculations for organic and non-organic options
// - Save reports with custom names and dates
// - Responsive UI with proper validation

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../models/chat/fertilizer_calculation.dart';
import '../../models/chat/crop_recommendation.dart';
import '../../models/reports/report.dart';
import '../../repositories/chat_repository.dart';
import '../../repositories/reports_repository.dart';
import '../../widgets/input.dart';
import '../../widgets/custom_button.dart';

class FertilizerCalculatorController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();
  final ReportsRepository _reportsRepository = ReportsRepository();
  final AuthController _authController = Get.find<AuthController>();

  // Observable state
  final currentStep = 1.obs;
  final isLoading = false.obs;
  final isCropRecommendationsLoading = false.obs;
  final showResults = false.obs;
  final showCropModal = false.obs;
  final showSaveModal = false.obs;
  final showSuccessModal = false.obs;
  final showAiRecommendations = false.obs;
  final isSaving = false.obs;

  // Data models
  final sensorData = <String, String>{
    'temperature': '',
    'humidity': '',
    'ec': '',
    'ph': '',
    'nitrogen': '',
    'phosphorus': '',
    'potassium': '',
    'salinity': '',
  }.obs;

  final calculationData = <String, String>{
    'areaSize': '',
    'numberOfTrees': '',
  }.obs;

  final aiRecommendedCrops = <CropRecommendationDto>[].obs;
  final selectedCrop = Rxn<CropRecommendationDto>();
  final recommendation = Rxn<FertilizerRecommendationDto>();
  final searchQuery = ''.obs;

  // Save form data
  final saveForm = <String, dynamic>{
    'fileName': '',
    'date': DateTime.now(),
  }.obs;

  // Validation helpers
  bool get isStep1Valid {
    final requiredFields = ['temperature', 'humidity', 'ec', 'ph'];
    return requiredFields.every((field) => sensorData[field]!.trim().isNotEmpty);
  }

  bool get isCalculationDataValid {
    return calculationData['areaSize']!.isNotEmpty &&
        calculationData['numberOfTrees']!.isNotEmpty &&
        selectedCrop.value != null;
  }

  // Update sensor data
  void updateSensorData(String field, String value) {
    sensorData[field] = value;
  }

  // Update calculation data
  void updateCalculationData(String field, String value) {
    calculationData[field] = value;
  }

  // Update save form
  void updateSaveForm(String field, dynamic value) {
    saveForm[field] = value;
  }

  // Get AI crop recommendations
  Future<void> getAICropRecommendations() async {
    if (!_authController.isAuthenticated) {
      Get.dialog(
        AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text('Please log in to get AI recommendations'),
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

    if (!_validateSensorData()) return;

    isCropRecommendationsLoading.value = true;

    try {
      final sensorDto = CropSensorDataDto(
        temperature: double.parse(sensorData['temperature']!),
        humidity: double.parse(sensorData['humidity']!),
        ec: double.parse(sensorData['ec']!),
        ph: double.parse(sensorData['ph']!),
        nitrogen: double.tryParse(sensorData['nitrogen']!) ?? 0,
        phosphorus: double.tryParse(sensorData['phosphorus']!) ?? 0,
        potassium: double.tryParse(sensorData['potassium']!) ?? 0,
        salinity: double.tryParse(sensorData['salinity']!) ?? 0,
      );

      final requestDto = CropRecommendationRequestDto(sensorData: sensorDto);
      final response = await _chatRepository.getCropRecommendations(requestDto);

      aiRecommendedCrops.value = response.recommendations;

      if (response.recommendations.isNotEmpty) {
        selectedCrop.value = response.recommendations.first;
        showAiRecommendations.value = true;

        Get.dialog(
          AlertDialog(
            title: const Text('AI Recommendations Ready'),
            content: Text(
              "We've analyzed your soil data and found ${response.recommendations.length} suitable crops for your field. The top recommendation is ${response.recommendations.first.name}.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  currentStep.value = 2;
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text('No Recommendations Available'),
            content: const Text(
              'No crop recommendations are available for your soil conditions at the moment. Please try again later or contact support.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  getAICropRecommendations();
                },
                child: const Text('Try Again'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  currentStep.value = 2;
                },
                child: const Text('Continue Anyway'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('AI Service Unavailable'),
          content: const Text(
            'Unable to get AI recommendations at the moment. This could be due to network issues or service maintenance. Please check your connection and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                getAICropRecommendations();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                currentStep.value = 2;
              },
              child: const Text('Continue Without AI'),
            ),
          ],
        ),
      );
    } finally {
      isCropRecommendationsLoading.value = false;
    }
  }

  // Calculate fertilizer with AI
  Future<void> calculateFertilizerAI() async {
    if (!_validateCalculationData()) return;
    if (!_authController.isAuthenticated) {
      Get.dialog(
        AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text('Please log in to get AI calculations'),
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

    isLoading.value = true;

    try {
      final sensorDto = SensorDataDto(
        temperature: double.parse(sensorData['temperature']!),
        humidity: double.parse(sensorData['humidity']!),
        ec: double.parse(sensorData['ec']!),
        ph: double.parse(sensorData['ph']!),
        nitrogen: double.tryParse(sensorData['nitrogen']!) ?? 0,
        phosphorus: double.tryParse(sensorData['phosphorus']!) ?? 0,
        potassium: double.tryParse(sensorData['potassium']!) ?? 0,
        salinity: double.tryParse(sensorData['salinity']!) ?? 0,
      );

      final calculationDto = CalculationDataDto(
        areaSize: calculationData['areaSize']!,
        numberOfTrees: calculationData['numberOfTrees']!,
        selectedCrop: SelectedCropDto(name: selectedCrop.value!.name),
      );

      final fertilizerDto = FertilizerCalculationDto(
        sensorData: sensorDto,
        calculationData: calculationDto,
      );

      final response = await _chatRepository.calculateFertilizer(fertilizerDto);
      recommendation.value = response.recommendation;
      showResults.value = true;

      Get.dialog(
        AlertDialog(
          title: const Text('AI Calculation Complete'),
          content: const Text(
            'Your personalized fertilizer recommendation has been calculated based on your soil conditions and selected crop.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Calculation Error'),
          content: const Text(
            'Failed to calculate fertilizer recommendation. Please check your internet connection and try again.',
          ),
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

  // Save report
  Future<void> saveReport() async {
    if (saveForm['fileName'].toString().isEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please enter a file name'),
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

    if (recommendation.value == null) {
      Get.dialog(
        AlertDialog(
          title: const Text('No Data'),
          content: const Text('No fertilizer recommendation data to save'),
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

    isSaving.value = true;

    try {
      final sensorDto = SensorDataDto(
        temperature: double.parse(sensorData['temperature']!),
        humidity: double.parse(sensorData['humidity']!),
        ec: double.parse(sensorData['ec']!),
        ph: double.parse(sensorData['ph']!),
        nitrogen: double.tryParse(sensorData['nitrogen']!) ?? 0,
        phosphorus: double.tryParse(sensorData['phosphorus']!) ?? 0,
        potassium: double.tryParse(sensorData['potassium']!) ?? 0,
        salinity: double.tryParse(sensorData['salinity']!) ?? 0,
      );

      final calculationDto = CalculationDataDto(
        areaSize: calculationData['areaSize']!,
        numberOfTrees: calculationData['numberOfTrees']!,
        selectedCrop: SelectedCropDto(name: selectedCrop.value!.name),
      );

      final reportDto = CreateReportDto(
        name: saveForm['fileName'],
        date: DateFormat('yyyy-MM-dd').format(saveForm['date']),
        sensorData: sensorDto,
        calculationData: calculationDto,
        selectedCrop: SelectedCropDto(name: selectedCrop.value!.name),
        cropRecommendations: aiRecommendedCrops.toList(),
        fertilizerRecommendation: recommendation.value!,
      );

      await _reportsRepository.createReport(reportDto);

      showSaveModal.value = false;
      saveForm['fileName'] = '';
      saveForm['date'] = DateTime.now();
      showSuccessModal.value = true;
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to save report: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Validation methods
  bool _validateSensorData() {
    final requiredFields = ['temperature', 'humidity', 'ec', 'ph'];
    final missingFields = requiredFields
        .where((field) => sensorData[field]!.trim().isEmpty)
        .toList();

    if (missingFields.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please fill in all required sensor data fields'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateCalculationData() {
    if (calculationData['areaSize']!.isEmpty ||
        calculationData['numberOfTrees']!.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please fill in both area size and number of trees'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }

    if (selectedCrop.value == null) {
      Get.dialog(
        AlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please select a crop from the recommendations'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  // Navigation methods
  void goToStep2() {
    if (!_validateSensorData()) return;
    getAICropRecommendations();
  }

  void goBack() {
    if (currentStep.value == 1) {
      Get.back();
    } else {
      currentStep.value = 1;
    }
  }
}

class FertilizerCalculatorScreen extends StatelessWidget {
  const FertilizerCalculatorScreen({super.key});

  // Helper method to parse color from hex string
  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        colorString = colorString.substring(1);
      }
      if (colorString.length == 6) {
        colorString = 'FF$colorString'; // Add alpha channel
      }
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return AppColors.primary500; // Fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FertilizerCalculatorController());
    
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                _buildHeader(controller),
                
                // Content
                Expanded(
                  child: _buildContent(controller),
                ),
                
                // Bottom button for step 1
                Obx(() {
                  if (controller.currentStep.value == 1) {
                    return _buildBottomButton(controller);
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
            
            // Modals
            _buildModals(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FertilizerCalculatorController controller) {
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
              'Fertilizer Calculator',
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

  Widget _buildContent(FertilizerCalculatorController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => controller.currentStep.value == 1
          ? _buildStep1Content(controller)
          : _buildStep2Content(controller)),
    );
  }

  Widget _buildStep1Content(FertilizerCalculatorController controller) {
    final inputData = [
      {'key': 'temperature', 'label': 'Temperature', 'unit': '°C', 'placeholder': '25.0'},
      {'key': 'humidity', 'label': 'Humidity', 'unit': '%', 'placeholder': '70.0'},
      {'key': 'ec', 'label': 'EC', 'unit': 'µS/cm', 'placeholder': '1500'},
      {'key': 'ph', 'label': 'pH Level', 'unit': '', 'placeholder': '6.5'},
      {'key': 'nitrogen', 'label': 'Nitrogen', 'unit': 'mg/kg', 'placeholder': '45'},
      {'key': 'phosphorus', 'label': 'Phosphorus', 'unit': 'mg/kg', 'placeholder': '25'},
      {'key': 'potassium', 'label': 'Potassium', 'unit': 'mg/kg', 'placeholder': '150'},
      {'key': 'salinity', 'label': 'Salinity', 'unit': 'mg/kg', 'placeholder': '200'},
    ];

    return Column(
      children: [
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: inputData.map((item) {
            final key = item['key']!;
            final label = item['label']!;
            final unit = item['unit']!;
            final placeholder = item['placeholder']!;

            return SizedBox(
              width: (MediaQuery.of(Get.context!).size.width - 60) / 2,
              child: CustomFormInput(
                label: unit.isNotEmpty ? '$label ($unit)' : label,
                hintText: placeholder,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => controller.updateSensorData(key, value),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStep2Content(FertilizerCalculatorController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        
        // Crop selection section
        _buildCropSelection(controller),
        
        // AI recommended crops section
        _buildAiRecommendations(controller),
        
        const SizedBox(height: 24),
        
        // Calculate your soil feed section
        const Text(
          'Calculate your soil feed',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        const Text(
          'Analyze your soil. Know exactly what your crops need.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Calculation inputs
        Row(
          children: [
            Expanded(
              child: CustomFormInput(
                label: 'Area Size',
                hintText: 'Ex: 10 acres',
                keyboardType: TextInputType.text,
                onChanged: (value) => controller.updateCalculationData('areaSize', value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomFormInput(
                label: 'Number of Trees',
                hintText: 'Ex: 100 trees',
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.updateCalculationData('numberOfTrees', value),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Calculate button
        Obx(() => CustomButton(
          title: 'Calculate with AI',
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          fullWidth: true,
          loading: controller.isLoading.value,
          onPressed: controller.isCalculationDataValid
              ? controller.calculateFertilizerAI
              : null,
        )),
        
        const SizedBox(height: 32),
        
        // Results section
        Obx(() {
          if (controller.showResults.value && controller.recommendation.value != null) {
            return _buildResults(controller);
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildCropSelection(FertilizerCalculatorController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          const Text(
            'See Relevant Information On',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() {
              final hasRecommendations = controller.aiRecommendedCrops.isNotEmpty;
              final selectedCrop = controller.selectedCrop.value;
              
              return GestureDetector(
                onTap: hasRecommendations ? () => controller.showCropModal.value = true : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8EBE8)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasRecommendations && selectedCrop != null
                              ? selectedCrop.name
                              : hasRecommendations
                                  ? 'Select a crop'
                                  : 'No crops available',
                          style: TextStyle(
                            fontSize: 14,
                            color: hasRecommendations
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Icon(
                        hasRecommendations
                            ? Icons.keyboard_arrow_down
                            : Icons.warning,
                        size: 16,
                        color: hasRecommendations
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendations(FertilizerCalculatorController controller) {
    return Obx(() {
      if (controller.showAiRecommendations.value && controller.aiRecommendedCrops.isNotEmpty) {
        final recommendations = controller.aiRecommendedCrops.take(4).map((crop) => crop.name).join(', ');
        final selectedCrop = controller.selectedCrop.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Recommended: $recommendations${selectedCrop != null ? ' (${selectedCrop.name}: ${selectedCrop.suitabilityScore.toInt()}% match)' : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (!controller.showAiRecommendations.value && controller.aiRecommendedCrops.isEmpty) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'No crop recommendations available yet. Complete Step 1 to get AI recommendations.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      
      return const SizedBox.shrink();
    });
  }

  Widget _buildResults(FertilizerCalculatorController controller) {
    final recommendation = controller.recommendation.value!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutrition Quantities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        const Text(
          'Based on your field size and tree quantities, we have selected a nutrition ratio for you',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Non Organic Fertilizer
        const Text(
          'Non Organic Fertilizer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildNutrientGrid(recommendation.nonOrganic),
        
        const SizedBox(height: 16),
        
        // Organic Fertilizer
        const Text(
          'Organic Fertilizer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildNutrientGrid(recommendation.organic),
        
        const SizedBox(height: 32),
        
        // Save button
        CustomButton(
          title: 'Save Data',
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          fullWidth: true,
          onPressed: () => controller.showSaveModal.value = true,
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNutrientGrid(List<FertilizerItemDto> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: items.map((item) => _buildNutrientCard(item)).toList(),
    );
  }

  Widget _buildNutrientCard(FertilizerItemDto item) {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final cardWidth = (screenWidth - 80) / 3; // 3 columns with gaps
    
    return Container(
      width: cardWidth,
      height: 106,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EBE8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _parseColor(item.color),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            item.perTree,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(FertilizerCalculatorController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Obx(() => CustomButton(
        title: 'Get AI Recommendations',
        variant: ButtonVariant.primary,
        size: ButtonSize.large,
        fullWidth: true,
        loading: controller.isCropRecommendationsLoading.value,
        onPressed: controller.isStep1Valid ? controller.goToStep2 : null,
      )),
    );
  }

  Widget _buildModals(FertilizerCalculatorController controller) {
    return Stack(
      children: [
        // Crop Selection Modal
        Obx(() {
          if (controller.showCropModal.value) {
            return _buildCropSelectionModal(controller);
          }
          return const SizedBox.shrink();
        }),
        
        // Save Modal
        Obx(() {
          if (controller.showSaveModal.value) {
            return _buildSaveModal(controller);
          }
          return const SizedBox.shrink();
        }),
        
        // Success Modal
        Obx(() {
          if (controller.showSuccessModal.value) {
            return _buildSuccessModal(controller);
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildCropSelectionModal(FertilizerCalculatorController controller) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(Get.context!).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Your Crop',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.showCropModal.value = false;
                        controller.searchQuery.value = '';
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomFormInput(
                  label: '',
                  hintText: 'Search crops...',
                  leftIcon: Icons.search,
                  onChanged: (value) => controller.searchQuery.value = value,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Crops label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Obx(() {
                    final filteredCrops = controller.aiRecommendedCrops
                        .where((crop) => crop.name
                            .toLowerCase()
                            .contains(controller.searchQuery.value.toLowerCase()))
                        .toList();
                    
                    return Text(
                      controller.searchQuery.value.isNotEmpty
                          ? 'Search Results (${filteredCrops.length})'
                          : 'AI Recommended Crops',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Crops list
              Expanded(
                child: Obx(() {
                  final filteredCrops = controller.aiRecommendedCrops
                      .where((crop) => crop.name
                          .toLowerCase()
                          .contains(controller.searchQuery.value.toLowerCase()))
                      .toList();
                  
                  if (filteredCrops.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No crops found. Try adjusting your search.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredCrops.length,
                    itemBuilder: (context, index) {
                      final crop = filteredCrops[index];
                      final isSelected = controller.selectedCrop.value?.id == crop.id;
                      
                      return GestureDetector(
                        onTap: () {
                          controller.selectedCrop.value = crop;
                          controller.showCropModal.value = false;
                          controller.searchQuery.value = '';
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8EBE8)),
                          ),
                          child: Row(
                            children: [
                              // Crop icon
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    crop.icon,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Crop info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: crop.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: ' (${crop.suitabilityScore.toInt()}% match)',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (crop.reasons.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        crop.reasons.take(2).join(', '),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              // Radio button
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary500
                                        : const Color(0xFFDDDDDD),
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? AppColors.primary500
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveModal(FertilizerCalculatorController controller) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(Get.context!).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Save Your Soil Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // File name input
              CustomFormInput(
                label: 'File Name',
                hintText: 'Ex: My Soil Report',
                leftIcon: Icons.person_outline,
                onChanged: (value) => controller.updateSaveForm('fileName', value),
              ),
              
              const SizedBox(height: 20),
              
              // Date picker
              GestureDetector(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: Get.context!,
                    initialDate: controller.saveForm['date'],
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  
                  if (selectedDate != null) {
                    controller.updateSaveForm('date', selectedDate);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8EBE8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => Text(
                          DateFormat('MMMM d, yyyy').format(controller.saveForm['date']),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        )),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              Obx(() => CustomButton(
                title: 'Save Report',
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                fullWidth: true,
                loading: controller.isSaving.value,
                onPressed: controller.saveReport,
              )),
              
              const SizedBox(height: 16),
              
              // Cancel button
              TextButton(
                onPressed: () => controller.showSaveModal.value = false,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessModal(FertilizerCalculatorController controller) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(Get.context!).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 350),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: AppColors.primary500,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Success title
              const Text(
                'File Save Successfully',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Success subtitle
              const Text(
                'Your file has been saved and is now available for future access.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF83878D),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Confirm button
              CustomButton(
                title: 'Confirm',
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                fullWidth: true,
                onPressed: () {
                  controller.showSuccessModal.value = false;
                  Get.back(); // Go back to previous screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
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
import 'package:smartsoilai/widgets/loader.dart';

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
  final sensorData =
      <String, String>{
        'temperature': '',
        'humidity': '',
        'ec': '',
        'ph': '',
        'nitrogen': '',
        'phosphorus': '',
        'potassium': '',
        'salinity': '',
      }.obs;

  final calculationData =
      <String, String>{'areaSize': '', 'numberOfTrees': ''}.obs;

  final aiRecommendedCrops = <CropRecommendationDto>[].obs;
  final selectedCrop = Rxn<CropRecommendationDto>();
  final recommendation = Rxn<FertilizerRecommendationDto>();
  final searchQuery = ''.obs;

  // Save form data
  final saveForm =
      <String, dynamic>{'fileName': '', 'date': DateTime.now()}.obs;

  // Validation helpers
  bool get isStep1Valid {
    final requiredFields = ['temperature', 'humidity', 'ec', 'ph'];
    return requiredFields.every(
      (field) => sensorData[field]!.trim().isNotEmpty,
    );
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
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
    final missingFields =
        requiredFields
            .where((field) => sensorData[field]!.trim().isEmpty)
            .toList();

    if (missingFields.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please fill in all required sensor data fields'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
          content: const Text(
            'Please fill in both area size and number of trees',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isLargeScreen = screenSize.width > 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Column(
                  children: [
                    // Header
                    _buildHeader(controller, isSmallScreen, isLargeScreen),

                    // Content
                    Expanded(
                      child: _buildContent(
                        controller,
                        constraints,
                        isSmallScreen,
                        isLargeScreen,
                      ),
                    ),

                    // Bottom button for step 1
                    Obx(() {
                      if (controller.currentStep.value == 1) {
                        return _buildBottomButton(controller, isSmallScreen);
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),

                // Modals
                _buildModals(controller, screenSize),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    FertilizerCalculatorController controller,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    final padding =
        isSmallScreen
            ? 16.0
            : isLargeScreen
            ? 24.0
            : 20.0;
    final titleSize =
        isSmallScreen
            ? 18.0
            : isLargeScreen
            ? 24.0
            : 20.0;
    final stepSize =
        isSmallScreen
            ? 35.0
            : isLargeScreen
            ? 45.0
            : 40.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary100, AppColors.primary50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: controller.goBack,
                child: Container(
                  width: stepSize - 2,
                  height: stepSize - 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(stepSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.primary600,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Fertilizer Calculator',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: stepSize - 2),
            ],
          ),
          const SizedBox(height: 16),
          // Step Indicator
          Obx(
            () => _buildStepIndicator(
              controller.currentStep.value,
              isSmallScreen,
              isLargeScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int currentStep,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    final stepSize =
        isSmallScreen
            ? 32.0
            : isLargeScreen
            ? 48.0
            : 40.0;
    final connectorWidth =
        isSmallScreen
            ? 40.0
            : isLargeScreen
            ? 80.0
            : 60.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        final step = index + 1;
        final isActive = step == currentStep;
        final isCompleted = step < currentStep;

        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: stepSize,
              height: stepSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isActive
                        ? AppColors.primary500
                        : isCompleted
                        ? AppColors.primary400
                        : Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color:
                      isActive || isCompleted
                          ? AppColors.primary500
                          : AppColors.primary200,
                  width: 2,
                ),
                boxShadow:
                    isActive
                        ? [
                          BoxShadow(
                            color: AppColors.primary500.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                        : null,
              ),
              child: Center(
                child:
                    isCompleted
                        ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: isSmallScreen ? 16 : 20,
                        )
                        : Text(
                          '$step',
                          style: TextStyle(
                            color:
                                isActive ? Colors.white : AppColors.primary600,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
              ),
            ),
            if (index < 1)
              Container(
                width: connectorWidth,
                height: 2,
                color:
                    currentStep > step
                        ? AppColors.primary500
                        : AppColors.primary200,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildContent(
    FertilizerCalculatorController controller,
    BoxConstraints constraints,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    final horizontalPadding =
        isSmallScreen
            ? 12.0
            : isLargeScreen
            ? 32.0
            : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        80, // Extra bottom padding to avoid button overlap
      ),
      child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              controller.currentStep.value == 1
                  ? _buildStep1Content(
                    controller,
                    constraints,
                    isSmallScreen,
                    isLargeScreen,
                  )
                  : _buildStep2Content(
                    controller,
                    constraints,
                    isSmallScreen,
                    isLargeScreen,
                  ),
        ),
      ),
    );
  }

  Widget _buildStep1Content(
    FertilizerCalculatorController controller,
    BoxConstraints constraints,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    final inputData = [
      {
        'key': 'temperature',
        'label': 'Temperature',
        'unit': '°C',
        'placeholder': '25.0',
        'icon': Icons.thermostat,
      },
      {
        'key': 'humidity',
        'label': 'Humidity',
        'unit': '%',
        'placeholder': '70.0',
        'icon': Icons.water_drop,
      },
      {
        'key': 'ec',
        'label': 'EC',
        'unit': 'µS/cm',
        'placeholder': '1500',
        'icon': Icons.electrical_services,
      },
      {
        'key': 'ph',
        'label': 'pH Level',
        'unit': '',
        'placeholder': '6.5',
        'icon': Icons.science,
      },
      {
        'key': 'nitrogen',
        'label': 'Nitrogen',
        'unit': 'mg/kg',
        'placeholder': '45',
        'icon': Icons.grass,
      },
      {
        'key': 'phosphorus',
        'label': 'Phosphorus',
        'unit': 'mg/kg',
        'placeholder': '25',
        'icon': Icons.local_florist,
      },
      {
        'key': 'potassium',
        'label': 'Potassium',
        'unit': 'mg/kg',
        'placeholder': '150',
        'icon': Icons.eco,
      },
      {
        'key': 'salinity',
        'label': 'Salinity',
        'unit': 'mg/kg',
        'placeholder': '200',
        'icon': Icons.waves,
      },
    ];

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.sensors,
                      color: AppColors.primary600,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Soil Sensor Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your soil sensor readings for accurate analysis',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1.5, // Further reduced for more height
                ),
                itemCount: inputData.length,
                itemBuilder: (context, index) {
                  final item = inputData[index];
                  final key = item['key'] as String;
                  final label = item['label'] as String;
                  final unit = item['unit'] as String;
                  final placeholder = item['placeholder'] as String;
                  final icon = item['icon'] as IconData;

                  return Container(
                    padding: const EdgeInsets.all(5),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary100,
                                    AppColors.primary200,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary200.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                color: AppColors.primary700,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                unit.isNotEmpty ? '$label ($unit)' : label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Flexible(
                          child: CustomFormInput(
                            label: '',
                            hintText: placeholder,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged:
                                (value) =>
                                    controller.updateSensorData(key, value),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Content(
    FertilizerCalculatorController controller,
    BoxConstraints constraints,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Crop selection section
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      color: AppColors.primary600,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Crop Selection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCropSelection(controller),
            ],
          ),
        ),

        // AI recommended crops section
        _buildAiRecommendations(controller),

        const SizedBox(height: 24),

        // Calculate your soil feed section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary50, AppColors.primary100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.calculate,
                      color: AppColors.primary600,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Calculate your soil feed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Analyze your soil. Know exactly what your crops need.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 24),

              // Calculation inputs
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomFormInput(
                        label: 'Area Size',
                        hintText: 'Ex: 10 acres',
                        keyboardType: TextInputType.text,
                        onChanged:
                            (value) => controller.updateCalculationData(
                              'areaSize',
                              value,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomFormInput(
                        label: 'Number of Trees',
                        hintText: 'Ex: 100 trees',
                        keyboardType: TextInputType.number,
                        onChanged:
                            (value) => controller.updateCalculationData(
                              'numberOfTrees',
                              value,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Calculate button
              Obx(
                () => CustomButton(
                  title: 'Calculate with AI',
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  fullWidth: true,
                  loading: controller.isLoading.value,
                  onPressed:
                      controller.isCalculationDataValid
                          ? controller.calculateFertilizerAI
                          : null,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Results section
        Obx(() {
          if (controller.showResults.value &&
              controller.recommendation.value != null) {
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
              final hasRecommendations =
                  controller.aiRecommendedCrops.isNotEmpty;
              final selectedCrop = controller.selectedCrop.value;

              return GestureDetector(
                onTap:
                    hasRecommendations
                        ? () => controller.showCropModal.value = true
                        : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
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
                            color:
                                hasRecommendations
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
                        color:
                            hasRecommendations
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
      if (controller.showAiRecommendations.value &&
          controller.aiRecommendedCrops.isNotEmpty) {
        final recommendations = controller.aiRecommendedCrops
            .take(4)
            .map((crop) => crop.name)
            .join(', ');
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
      } else if (!controller.showAiRecommendations.value &&
          controller.aiRecommendedCrops.isEmpty) {
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
                  style: TextStyle(fontSize: 16, color: AppColors.error),
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

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: AppColors.primary600,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nutrition Quantities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Based on your field size and tree quantities, we have selected a nutrition ratio for you',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 24),

          // Non Organic Fertilizer
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Non Organic Fertilizer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNutrientGrid(recommendation.nonOrganic),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Organic Fertilizer
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Organic Fertilizer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNutrientGrid(recommendation.organic),
              ],
            ),
          ),

          const SizedBox(height: 24),

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
      ),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: cardWidth,
      height: 106,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _parseColor(item.color).withValues(alpha: 0.1),
            ),
            child: Text(
              item.amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _parseColor(item.color),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            item.perTree,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(
    FertilizerCalculatorController controller,
    bool isSmallScreen,
  ) {
    final padding = isSmallScreen ? 16.0 : 20.0;
    final buttonSize = isSmallScreen ? ButtonSize.medium : ButtonSize.large;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: CustomButton(
            title: 'Get AI Recommendations',
            variant: ButtonVariant.primary,
            size: buttonSize,
            fullWidth: true,
            loading: controller.isCropRecommendationsLoading.value,
            onPressed: controller.isStep1Valid ? controller.goToStep2 : null,
          ),
        ),
      ),
    );
  }

  Widget _buildModals(
    FertilizerCalculatorController controller,
    Size screenSize,
  ) {
    final isSmallScreen = screenSize.width < 360;
    final isLargeScreen = screenSize.width > 600;

    return Stack(
      children: [
        // Crop Selection Modal
        Obx(() {
          if (controller.showCropModal.value) {
            return _buildCropSelectionModal(
              controller,
              screenSize,
              isSmallScreen,
              isLargeScreen,
            );
          }
          return const SizedBox.shrink();
        }),

        // Save Modal
        Obx(() {
          if (controller.showSaveModal.value) {
            return _buildSaveModal(controller, screenSize, isSmallScreen);
          }
          return const SizedBox.shrink();
        }),

        // Success Modal
        Obx(() {
          if (controller.showSuccessModal.value) {
            return _buildSuccessModal(controller, screenSize, isSmallScreen);
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildCropSelectionModal(
    FertilizerCalculatorController controller,
    Size screenSize,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    final modalWidth =
        isSmallScreen
            ? screenSize.width * 0.95
            : isLargeScreen
            ? screenSize.width * 0.7
            : screenSize.width * 0.9;
    final modalHeight =
        isSmallScreen ? screenSize.height * 0.8 : screenSize.height * 0.7;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final titleSize = isSmallScreen ? 18.0 : 20.0;
    final iconSize = isSmallScreen ? 28.0 : 32.0;

    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: modalWidth,
                constraints: BoxConstraints(maxHeight: modalHeight),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with enhanced gradient
              Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   colors: [
                  //     AppColors.primary500,
                  //     AppColors.primary400,
                  //     AppColors.primary300,
                  //   ],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: AppColors.primary500.withValues(alpha: 0.3),
                  //     blurRadius: 10,
                  //     offset: const Offset(0, 5),
                  //   ),
                  // ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: AppColors.primary500.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(iconSize / 2),
                          ),
                          child: Icon(
                            Icons.agriculture,
                            color: AppColors.primary500,
                            size: iconSize * 0.6,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Select Your Crop',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.showCropModal.value = false;
                        controller.searchQuery.value = '';
                      },
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(iconSize / 2),
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColors.primary500,
                          size: iconSize * 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search with enhanced styling
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: CustomFormInput(
                    label: '',
                    hintText: 'Search crops...',
                    leftIcon: Icons.search,
                    onChanged: (value) => controller.searchQuery.value = value,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Crops label with responsive text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Obx(() {
                    final filteredCrops =
                        controller.aiRecommendedCrops
                            .where(
                              (crop) => crop.name.toLowerCase().contains(
                                controller.searchQuery.value.toLowerCase(),
                              ),
                            )
                            .toList();

                    return Text(
                      controller.searchQuery.value.isNotEmpty
                          ? 'Search Results (${filteredCrops.length})'
                          : 'AI Recommended Crops',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 12),

              // Crops list with enhanced items
              Expanded(
                child: Obx(() {
                  final filteredCrops =
                      controller.aiRecommendedCrops
                          .where(
                            (crop) => crop.name.toLowerCase().contains(
                              controller.searchQuery.value.toLowerCase(),
                            ),
                          )
                          .toList();

                  if (filteredCrops.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: isSmallScreen ? 48 : 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No crops found. Try adjusting your search.',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    itemCount: filteredCrops.length,
                    itemBuilder: (context, index) {
                      final crop = filteredCrops[index];
                      final isSelected =
                          controller.selectedCrop.value?.id == crop.id;

                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.primary50 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primary400
                                      : Colors.grey.withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: AppColors.primary200.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                    : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              controller.selectedCrop.value = crop;
                              controller.showCropModal.value = false;
                              controller.searchQuery.value = '';
                            },
                            child: Row(
                              children: [
                                // Enhanced crop icon
                                Container(
                                  width: isSmallScreen ? 36 : 44,
                                  height: isSmallScreen ? 36 : 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary100,
                                        AppColors.primary200,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      isSmallScreen ? 18 : 22,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary200.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      crop.icon,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 20,
                                        color: AppColors.primary600,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: isSmallScreen ? 12 : 16),

                                // Crop info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: crop.name,
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 14 : 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  ' (${crop.suitabilityScore.toInt()}% match)',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 11 : 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (crop.reasons.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          crop.reasons.take(2).join(', '),
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 11 : 12,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Enhanced radio button
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: isSmallScreen ? 20 : 24,
                                  height: isSmallScreen ? 20 : 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? AppColors.primary500
                                              : Colors.grey.withValues(
                                                alpha: 0.4,
                                              ),
                                      width: 2,
                                    ),
                                    color:
                                        isSelected
                                            ? AppColors.primary500
                                            : Colors.transparent,
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: AppColors.primary500
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child:
                                      isSelected
                                          ? Icon(
                                            Icons.check,
                                            size: isSmallScreen ? 12 : 14,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                              ],
                            ),
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

  Widget _buildSaveModal(
    FertilizerCalculatorController controller,
    Size screenSize,
    bool isSmallScreen,
  ) {
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
                onChanged:
                    (value) => controller.updateSaveForm('fileName', value),
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
                        child: Obx(
                          () => Text(
                            DateFormat(
                              'MMMM d, yyyy',
                            ).format(controller.saveForm['date']),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
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
              Obx(
                () => CustomButton(
                  title: 'Save Report',
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  fullWidth: true,
                  loading: controller.isSaving.value,
                  onPressed: controller.saveReport,
                ),
              ),

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

  Widget _buildSuccessModal(
    FertilizerCalculatorController controller,
    Size screenSize,
    bool isSmallScreen,
  ) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(Get.context!).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 350),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon with animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary200, AppColors.primary400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary300.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Success title
              const Text(
                'File Save Successfully',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Success subtitle
              const Text(
                'Your file has been saved and is now available for future access.',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
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

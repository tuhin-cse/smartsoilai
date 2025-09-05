import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/soil_meter_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loader.dart';
import 'fertilizer_calculator_screen.dart';

class SoilMeterScreen extends StatelessWidget {
  const SoilMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SoilMeterController());

    // Check connection status when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkConnectionOnScreenOpen();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: Obx(
        () => LoaderStack(
          loading: controller.isLoading.value && controller.isConnected.value,
          child: SafeArea(
            child: Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState(controller);
              }

              return _buildSoilMeterContent(controller);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(SoilMeterController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            title: 'Retry',
            variant: ButtonVariant.primary,
            onPressed: () => controller.refreshSoilData(),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilMeterContent(SoilMeterController controller) {
    return Column(
      children: [
        // Header Section
        _buildHeader(controller),

        // Main Content
        Expanded(
          child:
              controller.isConnected.value
                  ? LoaderStack(
                    loading: controller.isLoading.value,
                    child: _buildConnectedContent(controller),
                  )
                  : _buildDisconnectedContent(controller),
        ),
      ],
    );
  }

  Widget _buildDisconnectedContent(SoilMeterController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 80),

          // Farmer Illustration
          Image.asset(
            'assets/images/farmer.png',
            width: 156,
            height: 220,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 16),

          const Text(
            'Soil Meter is Disconnected',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          const Text(
            'We\'re unable to access real-time soil data. Please reconnect the device to resume accurate monitoring.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedContent(SoilMeterController controller) {
    // Different styles based on currentStyle
    switch (controller.currentStyle.value) {
      case 1:
        return _buildStyle2Content(controller);
      case 2:
        return _buildStyle3Content(controller);
      default:
        return _buildStyle1Content(controller);
    }
  }

  Widget _buildStyle1Content(SoilMeterController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Primary Metrics (pH and Moisture)
          _buildPrimaryMetricsRow(controller),

          const SizedBox(height: 20),

          // Secondary Metrics (Temperature & EC)
          _buildSecondaryMetricsRow(controller),

          const SizedBox(height: 20),

          // Nutrient Grid
          _buildNutrientGrid(controller),

          const SizedBox(height: 30),

          // Fertilizer Calculation Button
          _buildFertilizerButton(controller),
        ],
      ),
    );
  }

  Widget _buildStyle2Content(SoilMeterController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Grid layout for all values
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildStyle2Card(
                'Soil pH',
                controller.ph.value.toStringAsFixed(1),
                '',
                const Color(0xFF3B82F6),
                Icons.science,
              ),
              _buildStyle2Card(
                'Moisture',
                controller.humidity.value.toStringAsFixed(0),
                '%',
                const Color(0xFF10B981),
                Icons.water_drop,
              ),
              _buildStyle2Card(
                'Temp',
                controller.temperature.value.toStringAsFixed(1),
                '°C',
                const Color(0xFFF59E0B),
                Icons.thermostat,
              ),
              _buildStyle2Card(
                'EC',
                controller.ec.value.toStringAsFixed(1),
                '',
                const Color(0xFF8B5CF6),
                Icons.electrical_services,
              ),
              _buildStyle2Card(
                'Nitrogen',
                controller.nitrogen.value.toStringAsFixed(0),
                '',
                const Color(0xFF10B981),
                Icons.grass,
              ),
              _buildStyle2Card(
                'Phosphorus',
                controller.phosphorus.value.toStringAsFixed(2),
                '',
                const Color(0xFF3B82F6),
                Icons.local_florist,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Fertilizer Calculation Button
          _buildFertilizerButton(controller),
        ],
      ),
    );
  }

  Widget _buildStyle3Content(SoilMeterController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Large display cards
          _buildStyle3Card(
            'Soil pH',
            controller.ph.value.toStringAsFixed(1),
            '',
            const Color(0xFF3B82F6),
            Icons.science,
          ),
          const SizedBox(height: 16),
          _buildStyle3Card(
            'Moisture',
            controller.humidity.value.toStringAsFixed(0),
            '%',
            const Color(0xFF10B981),
            Icons.water_drop,
          ),
          const SizedBox(height: 20),

          // Smaller cards in grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildNutrientCard(
                'Salinity',
                controller.salinity.value.toStringAsFixed(0),
                '',
                const Color(0xFF8B5CF6),
                Icons.waves,
              ),
              _buildNutrientCard(
                'Nitrogen',
                controller.nitrogen.value.toStringAsFixed(0),
                '',
                const Color(0xFF10B981),
                Icons.grass,
              ),
              _buildNutrientCard(
                'Phosphorus',
                controller.phosphorus.value.toStringAsFixed(0),
                '',
                const Color(0xFF3B82F6),
                Icons.local_florist,
              ),
              _buildNutrientCard(
                'Potassium',
                controller.potassium.value.toStringAsFixed(0),
                '',
                const Color(0xFF10B981),
                Icons.eco,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Fertilizer Calculation Button
          _buildFertilizerButton(controller),
        ],
      ),
    );
  }

  Widget _buildHeader(SoilMeterController controller) {
    final now = DateTime.now();
    final dateString =
        '${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)} ${now.year}, ${_getFormattedTime(now)}';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary50, Colors.white]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Top Row
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F8CF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF435C5C),
                    size: 20,
                  ),
                ),
              ),

              const Spacer(),
              const Text(
                'Soil AI',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Style Toggle Button
              if (controller.isConnected.value)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary500, width: 1),
                  ),
                  child: GestureDetector(
                    onTap: () => controller.toggleStyle(),
                    child: const Icon(
                      Icons.grid_view,
                      color: AppColors.primary500,
                      size: 20,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        controller.isConnected.value
                            ? AppColors.primary50
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.grid_view,
                    color:
                        controller.isConnected.value
                            ? AppColors.primary500
                            : Colors.grey,
                    size: 20,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Date and Status Row
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateString,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      controller.isConnected.value
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            controller.isConnected.value
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.isConnected.value
                          ? 'Connected'
                          : 'Disconnected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            controller.isConnected.value
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 23),

          // Action Icons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionIcon(
                controller.isLocked.value ? Icons.lock : Icons.lock_open,
                controller.isLocked.value ? 'Unlock' : 'Lock',
                onPressed:
                    controller.isConnected.value
                        ? () => controller.toggleLock()
                        : null,
                isDisabled: !controller.isConnected.value,
                isHighlighted: controller.isLocked.value,
              ),
              _buildActionIcon(Icons.edit_outlined, 'Edit'),
              _buildActionIcon(
                Icons.refresh,
                'Refresh',
                onPressed:
                    controller.isConnected.value
                        ? () => controller.refreshSoilData()
                        : null,
                isDisabled: !controller.isConnected.value,
              ),
              _buildActionIcon(Icons.download_outlined, 'Download'),
              _buildActionIcon(Icons.history, 'History'),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildPrimaryMetricsRow(SoilMeterController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildLargeMeterCard(
            'Soil pH',
            controller.ph.value.toStringAsFixed(1),
            '',
            AppColors.primary500,
            Icons.science,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLargeMeterCard(
            'Soil Moisture',
            controller.humidity.value.toStringAsFixed(0),
            '%',
            const Color(0xFF3B82F6),
            Icons.water_drop,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryMetricsRow(SoilMeterController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallMeterCard(
            'Temp',
            controller.temperature.value.toStringAsFixed(1),
            '°C',
            const Color(0xFFF59E0B),
            Icons.thermostat,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallMeterCard(
            'EC',
            controller.ec.value.toStringAsFixed(1),
            'mS/cm',
            const Color(0xFF8B5CF6),
            Icons.electrical_services,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientGrid(SoilMeterController controller) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildNutrientCard(
          'Salinity',
          controller.salinity.value.toStringAsFixed(1),
          'ppt',
          const Color(0xFF8B5CF6),
          Icons.waves,
        ),
        _buildNutrientCard(
          'Nitrogen',
          controller.nitrogen.value.toStringAsFixed(0),
          'ppm',
          const Color(0xFF10B981),
          Icons.grass,
        ),
        _buildNutrientCard(
          'Phosphorus',
          controller.phosphorus.value.toStringAsFixed(0),
          'ppm',
          const Color(0xFF3B82F6),
          Icons.local_florist,
        ),
        _buildNutrientCard(
          'Potassium',
          controller.potassium.value.toStringAsFixed(0),
          'ppm',
          const Color(0xFF10B981),
          Icons.eco,
        ),
      ],
    );
  }

  Widget _buildLargeMeterCard(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMeterCard(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerButton(SoilMeterController controller) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          controller.toggleLock();
          // Navigate to fertilizer calculation screen with sensor data
          Get.to(
            () => const FertilizerCalculatorScreen(),
            arguments: {
              'temperature': controller.temperature.value,
              'humidity': controller.humidity.value,
              'ec': controller.ec.value,
              'ph': controller.ph.value,
              'nitrogen': controller.nitrogen.value,
              'phosphorus': controller.phosphorus.value,
              'potassium': controller.potassium.value,
              'salinity': controller.salinity.value,
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate, size: 20),
            const SizedBox(width: 8),
            const Text(
              'START Fertilizer Calculation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStyle2Card(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyle3Card(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      if (unit.isNotEmpty)
                        TextSpan(
                          text: unit,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(
    IconData icon,
    String label, {
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDisabled
                      ? Colors.grey.shade100
                      : isHighlighted
                      ? AppColors.primary500
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  isDisabled
                      ? null
                      : isHighlighted
                      ? [
                        BoxShadow(
                          color: AppColors.primary500.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: Icon(
              icon,
              color:
                  isDisabled
                      ? Colors.grey
                      : isHighlighted
                      ? Colors.white
                      : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  isDisabled
                      ? Colors.grey
                      : isHighlighted
                      ? AppColors.primary500
                      : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}

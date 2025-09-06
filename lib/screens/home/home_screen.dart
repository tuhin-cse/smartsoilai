import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../constants/app_colors.dart';
import '../../services/user_service.dart';
import '../../services/weather_service.dart';
import '../../services/farmbrite_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;
  bool _isAnalyzing = false;

  late FarmbriteService _farmbriteService;

  @override
  void initState() {
    super.initState();
    _farmbriteService = Get.put(FarmbriteService());
    // Load mock data for now (replace with real field ID when API is connected)
    _farmbriteService.loadMockData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d, yyyy').format(now);
  }

  Future<void> _handleTakePicture() async {
    // Navigate directly to the disease scanner screen
    Get.toNamed('/disease-scanner');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary700,
      body: Obx(() {
        final userService = UserService.to;
        final weatherService = Get.find<WeatherService>();
        final minMaxTemp = weatherService.getMinMaxTemp();
        final sunTimes = weatherService.getSunTimes();
        return Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  // Top header with greeting and profile
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning, ${userService.name.isNotEmpty ? userService.name.split(' ').first : 'User'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _getCurrentDate(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary400,
                        backgroundImage:
                            userService.profileImage.isNotEmpty
                                ? NetworkImage(userService.profileImage)
                                : null,
                        child:
                            userService.profileImage.isEmpty
                                ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                )
                                : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Slider Cards (Weather + Satellite)
                  SizedBox(
                    height: 240,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentSlide = index;
                        });
                      },
                      children: [
                        // Weather Card
                        weatherService.isLoading.value
                            ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : weatherService.error.value.isNotEmpty
                            ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Weather data unavailable',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    weatherService.error.value,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed:
                                            () =>
                                                weatherService
                                                    .refreshWeatherData(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white
                                              .withOpacity(0.2),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Retry',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      if (weatherService.error.value.contains(
                                        'location',
                                      ))
                                        const SizedBox(width: 8),
                                      if (weatherService.error.value.contains(
                                        'location',
                                      ))
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Request location permission with proper dialog
                                            bool serviceEnabled =
                                                await Geolocator.isLocationServiceEnabled();
                                            if (!serviceEnabled) {
                                              // Show dialog to enable location services
                                              Get.dialog(
                                                AlertDialog(
                                                  title: const Text(
                                                    'Location Services Disabled',
                                                  ),
                                                  content: const Text(
                                                    'Location services are disabled. Please enable location services to get weather data.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Get.back(),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Get.back();
                                                        await Geolocator.openLocationSettings();
                                                      },
                                                      child: const Text(
                                                        'Open Settings',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              return;
                                            }

                                            LocationPermission permission =
                                                await Geolocator.checkPermission();
                                            if (permission ==
                                                LocationPermission.denied) {
                                              permission =
                                                  await Geolocator.requestPermission();
                                            }

                                            if (permission ==
                                                LocationPermission
                                                    .deniedForever) {
                                              // Show dialog to go to app settings
                                              Get.dialog(
                                                AlertDialog(
                                                  title: const Text(
                                                    'Permission Required',
                                                  ),
                                                  content: const Text(
                                                    'Location permission is permanently denied. Please enable it in app settings to get weather data.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Get.back(),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Get.back();
                                                        await Geolocator.openAppSettings();
                                                      },
                                                      child: const Text(
                                                        'Open Settings',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (permission ==
                                                    LocationPermission.always ||
                                                permission ==
                                                    LocationPermission
                                                        .whileInUse) {
                                              // Permission granted, refresh weather data
                                              weatherService
                                                  .refreshWeatherData();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white
                                                .withOpacity(0.2),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Request Permission',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      if (weatherService.error.value.contains(
                                        'location',
                                      ))
                                        const SizedBox(width: 8),
                                      if (weatherService.error.value.contains(
                                        'location',
                                      ))
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Open location settings
                                            await Geolocator.openLocationSettings();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white
                                                .withOpacity(0.2),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Settings',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                            : Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Location
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.white.withOpacity(0.8),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        weatherService.getLocationString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Temperature and weather
                                  Row(
                                    children: [
                                      Text(
                                        weatherService.getTemperatureString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 42,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'H: ${minMaxTemp['max']}°',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                const Icon(
                                                  Icons.wb_sunny,
                                                  color: Colors.yellow,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              'L: ${minMaxTemp['min']}°',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Weather details
                                  Row(
                                    children: [
                                      _buildWeatherDetail(
                                        'Humidity',
                                        weatherService.getHumidityString(),
                                      ),
                                      _buildWeatherDetail(
                                        'Visibility',
                                        weatherService.getVisibilityString(),
                                      ),
                                      _buildWeatherDetail(
                                        'Pressure',
                                        weatherService.getPressureString(),
                                      ),
                                      _buildWeatherDetail(
                                        'Wind',
                                        weatherService.getWindSpeedString(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Time indicators
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        sunTimes['sunrise']!,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 11,
                                        ),
                                      ),
                                      Container(
                                        height: 1,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.yellow,
                                              Colors.orange,
                                              Colors.white.withOpacity(0.3),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        sunTimes['sunset']!,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                        // Satellite Card
                        Obx(() {
                          final farmbriteService = Get.find<FarmbriteService>();
                          return farmbriteService.isLoading.value
                              ? Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.white.withOpacity(0.1),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : farmbriteService.error.value.isNotEmpty
                              ? Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.white.withOpacity(0.1),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Field data unavailable',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Replace 'field_001' with actual field ID
                                              farmbriteService.fetchFieldData(
                                                'field_001',
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.2),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            child: const Text(
                                              'Retry',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    children: [
                                      // Satellite background image
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image:
                                                farmbriteService
                                                        .satelliteImageUrl
                                                        .value
                                                        .isNotEmpty
                                                    ? NetworkImage(
                                                      farmbriteService
                                                          .satelliteImageUrl
                                                          .value,
                                                    )
                                                    : Image.asset(
                                                          'assets/images/field.png',
                                                        )
                                                        as ImageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      // Live indicator with pulse animation
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                            begin: 1.0,
                                            end: 1.3,
                                          ),
                                          duration: const Duration(seconds: 1),
                                          curve: Curves.easeInOut,
                                          builder: (context, scale, child) {
                                            return Transform.scale(
                                              scale: scale,
                                              child: child,
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.red.withOpacity(
                                                    0.5,
                                                  ),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'Live',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Field info overlay
                                      Positioned(
                                        bottom: 16,
                                        left: 16,
                                        right: 16,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Obx(() {
                                            final service =
                                                Get.find<FarmbriteService>();
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Your Field: ${service.fieldSize.value}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Crop: ${service.cropType.value}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Soil: ${service.soilMoisture.value}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'Health: ${service.cropHealth.value}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                      ),

                                      // Refresh button
                                      Positioned(
                                        top: 16,
                                        left: 16,
                                        child: GestureDetector(
                                          onTap: () {
                                            // Replace 'field_001' with actual field ID
                                            farmbriteService.fetchFieldData(
                                              'field_001',
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.refresh,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPageIndicator(0),
                      const SizedBox(width: 8),
                      _buildPageIndicator(1),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAF8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Feature Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildFeatureCard(
                                'Soil Meter',
                                'assets/icons/meter.png',
                                () => Get.toNamed('/soil-meter'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFeatureCard(
                                'Fertiliser Calculator',
                                'assets/icons/fertiliser.png',
                                () => Get.toNamed('/calculator/fertilizer'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFeatureCard(
                                'Satellite Monitoring',
                                'assets/icons/satellite.png',
                                () => Get.toNamed('/satellite-monitoring'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Revive Your Fields & Crops Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Revive Your Fields & Crops',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F1F1F),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionCard(
                                      'Take a photo',
                                      'assets/icons/Scan.png',
                                      _isAnalyzing ? null : _handleTakePicture,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionCard(
                                      'See Symptoms',
                                      'assets/icons/prescription.png',
                                      () => Get.toNamed('/symptoms'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionCard(
                                      'Get Medicine',
                                      'assets/icons/medicine.png',
                                      () => Get.toNamed('/medicine'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String iconPath, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 108, // Fixed height for consistent sizing
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(iconPath, width: 24, height: 24),
            ),
            const SizedBox(height: 8),
            Expanded(
              // Allow text to expand and center properly
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F1F1F),
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Allow up to 2 lines
                overflow: TextOverflow.ellipsis, // Handle overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String iconPath, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        ),
        child: Column(
          children: [
            Image.asset(iconPath, width: 32, height: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF495057),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentSlide;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

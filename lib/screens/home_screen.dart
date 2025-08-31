import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/weather_card.dart';
import '../widgets/satellite_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();
  int _currentSlide = 0;
  bool _isAnalyzing = false;

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
    try {
      final result = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (result != null) {
        await _launchImagePicker(result);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to access camera: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _launchImagePicker(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // TODO: Process image with AI API
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      
      // Navigate to disease analysis screen
      Get.toNamed('/disease-analysis', arguments: {
        'imagePath': imagePath,
        'analysis': {
          'disease': 'Leaf Blight',
          'confidence': 0.89,
          'severity': 'Moderate',
          'treatment': 'Apply fungicide spray',
        },
      });
    } catch (e) {
      Get.snackbar(
        'Analysis Failed',
        'Unable to analyze the image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: themeController.backgroundSecondary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary700,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning, ${authController.firstName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getCurrentDate(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary400,
                      backgroundImage: authController.profileImage != null
                          ? NetworkImage(authController.profileImage!)
                          : null,
                      child: authController.profileImage == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  ],
                ),
              ),

              // Main Slider (Field + Weather)
              Transform.translate(
                offset: const Offset(0, -70),
                child: SizedBox(
                  height: 285,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSlide = index;
                      });
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: SatelliteCard(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: WeatherCard(),
                      ),
                    ],
                  ),
                ),
              ),

              // Page Indicators
              Transform.translate(
                offset: const Offset(0, -58),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPageIndicator(0),
                    const SizedBox(width: 4),
                    _buildPageIndicator(1),
                  ],
                ),
              ),

              // Feature Cards
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(child: _buildFeatureCard('Soil Meter', Icons.speed, null)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildFeatureCard(
                        'Fertilizer Calculator',
                        Icons.calculate,
                        () => Get.toNamed('/calculator/fertilizer'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(child: _buildFeatureCard('Satellite Monitoring', Icons.satellite_alt, null)),
                  ],
                ),
              ),

              // Section Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  'Revive Your Fields & Crops',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: themeController.textColor,
                  ),
                ),
              ),

              // Main Action Section
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                decoration: BoxDecoration(
                  color: themeController.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8EAE7)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Action Steps
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionStep('Take a Picture', Icons.local_florist),
                          _buildConnectingLine(),
                          _buildActionStep('See Diagnosis', Icons.science),
                          _buildConnectingLine(),
                          _buildActionStep('Get Medicine', Icons.medical_services),
                        ],
                      ),
                    ),

                    // Confirm Button
                    const SizedBox(height: 20),
                    CustomButton(
                      title: _isAnalyzing ? "Analyzing..." : "Take A Picture",
                      onPressed: _isAnalyzing ? null : _handleTakePicture,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      fullWidth: true,
                      leftIcon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentSlide;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 13 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary500 : const Color(0xFFEEF0F0),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8EAE7)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionStep(String title, IconData icon) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFE3F8CF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingLine() {
    return Container(
      width: 20,
      height: 1,
      margin: const EdgeInsets.only(bottom: 24),
      color: AppColors.primary500,
    );
  }
}

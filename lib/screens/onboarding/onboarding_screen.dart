import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../services/storage_service.dart';

class OnboardingStep {
  final int id;
  final String image;
  final String title;
  final String description;

  OnboardingStep({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;

  final List<OnboardingStep> onboardingSteps = [
    OnboardingStep(
      id: 1,
      image: 'assets/images/intro/img1.png',
      title: 'Your soil speaks. We help you listen',
      description: 'We decode your soil\'s signals nutrients, moisture, and crop match so you can make smarter decisions and grow healthier, more productive crops.',
    ),
    OnboardingStep(
      id: 2,
      image: 'assets/images/intro/img2.png',
      title: 'We tell you what your soil needs. You grow what you want',
      description: 'Get clear insights on soil health, nutrients, and crop fit so you can grow what you love with confidence, naturally and productively.',
    ),
    OnboardingStep(
      id: 3,
      image: 'assets/images/intro/img3.png',
      title: 'Catch soil problems early before they cost you',
      description: 'Detect soil issues early with smart analysis. Prevent crop damage, reduce costs, and keep your farm healthy from the ground up.',
    ),
  ];

  Future<void> completeOnboarding() async {
    try {
      final storage = await storageService;
      await storage.setOnboardingCompleted(true);
    } catch (error) {
      debugPrint('Error completing onboarding: $error');
    }
  }

  Future<void> handleNext() async {
    if (currentStep < onboardingSteps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      // Complete onboarding and navigate to location access screen
      await completeOnboarding();
      Get.offNamed('/location-access');
    }
  }

  Future<void> handleSkip() async {
    // Complete onboarding and navigate to login
    await completeOnboarding();
    Get.offNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final currentStepData = onboardingSteps[currentStep];

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                currentStepData.image,
                key: ValueKey(currentStepData.id),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content Section
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    currentStepData.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      currentStepData.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Navigation Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button
                      GestureDetector(
                        onTap: handleSkip,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primary600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Step Indicators
                      Row(
                        children: List.generate(
                          onboardingSteps.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == currentStep ? 16 : 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: index == currentStep
                                  ? AppColors.primary700
                                  : const Color(0xFFE8EBF0),
                              borderRadius: BorderRadius.circular(
                                index == currentStep ? 8 : 6,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Next Button
                      GestureDetector(
                        onTap: handleNext,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:get/get.dart';
import '../screens/onboarding/language_select_screen.dart';
import '../screens/onboarding/location_access_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/chat_screen.dart';
import '../screens/home/reports_screen.dart';
import '../screens/home/main_navigation_screen.dart';
import '../screens/placeholder_screens.dart';
import '../screens/inner/fertilizer_calculator_screen.dart';
import '../screens/inner/report_detail_screen.dart';
import '../screens/inner/soil_meter_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String languageSelect = '/language-select';
  static const String locationAccess = '/location-access';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPasswordOtp = '/reset-password-otp';
  static const String newPassword = '/new-password';
  static const String home = '/home';
  static const String mainNavigation = '/main-navigation';
  static const String diseaseAnalysis = '/disease-analysis';
  static const String reportDetail = '/report-detail';
  static const String chat = '/chat';
  static const String reports = '/reports';
  static const String shop = '/shop';
  static const String more = '/more';
  static const String fertilizerCalculator = '/calculator/fertilizer';
  static const String profile = '/more/profile';
  static const String privacyPolicy = '/more/privacy-policy';
  static const String settings = '/settings';
  static const String soilMeter = '/soil-meter';

  // Routes list
  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: languageSelect,
      page: () => const LanguageSelectScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: locationAccess,
      page: () => const LocationAccessScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: otpVerification,
      page: () => const OtpVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: resetPasswordOtp,
      page: () => const ResetPasswordOtpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: newPassword,
      page: () => const NewPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: mainNavigation,
      page: () => const MainNavigationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: soilMeter,
      page: () => const SoilMeterScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: diseaseAnalysis,
      page: () => const DiseaseAnalysisScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: reportDetail,
      page: () => const ReportDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: chat,
      page: () => const ChatScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: reports,
      page: () => const ReportsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: shop,
      page: () => const ShopScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: more,
      page: () => const MoreScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: fertilizerCalculator,
      page: () => const FertilizerCalculatorScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  StorageService._();

  // Keys
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _isFirstLaunchKey = 'is_first_launch';

  // Onboarding methods
  Future<bool> isOnboardingCompleted() async {
    return _preferences!.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _preferences!.setBool(_onboardingCompletedKey, completed);
  }

  // First launch methods
  Future<bool> isFirstLaunch() async {
    return _preferences!.getBool(_isFirstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _preferences!.setBool(_isFirstLaunchKey, isFirstLaunch);
  }

  // Clear all data
  Future<void> clear() async {
    await _preferences!.clear();
  }
}

// Global instance
final storageService = StorageService.getInstance();

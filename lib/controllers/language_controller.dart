import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/language_constants.dart';
import '../models/language.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'selected_language';
  
  final Rx<Language> _selectedLanguage = LanguageConstants.defaultLanguage.obs;
  final RxBool _isLoading = false.obs;
  final RxMap<String, Rx<double>> _animationValues = <String, Rx<double>>{}.obs;

  Language get selectedLanguage => _selectedLanguage.value;
  String get selectedLanguageId => _selectedLanguage.value.id;
  bool get isLoading => _isLoading.value;
  Map<String, Rx<double>> get animationValues => _animationValues;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _loadSavedLanguage();
  }

  void _initializeAnimations() {
    for (final language in LanguageConstants.languages) {
      _animationValues[language.id] = 0.0.obs;
    }
    _animationValues[selectedLanguageId]?.value = 1.0;
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageId = prefs.getString(_languageKey);
      
      if (savedLanguageId != null) {
        final language = LanguageConstants.getLanguageById(savedLanguageId);
        if (language != null) {
          _selectedLanguage.value = language;
          _updateAnimations(savedLanguageId);
        }
      }
    } catch (e) {
      print('Error loading saved language: $e');
    }
  }

  Future<void> setLanguage(String languageId) async {
    if (languageId == selectedLanguageId) return;

    _isLoading.value = true;

    try {
      final language = LanguageConstants.getLanguageById(languageId);
      if (language != null) {
        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageId);
        
        // Update selected language
        _selectedLanguage.value = language;
        
        // Update animations
        _updateAnimations(languageId);
        
        // Update GetX locale if using internationalization
        // Get.updateLocale(Locale(language.languageCode, language.countryCode));
      }
    } catch (e) {
      print('Error setting language: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  void selectLanguageLocally(String languageId) {
    if (languageId == selectedLanguageId) return;

    final language = LanguageConstants.getLanguageById(languageId);
    if (language != null) {
      _selectedLanguage.value = language;
      _updateAnimations(languageId);
    }
  }

  void _updateAnimations(String selectedId) {
    // Reset all animations to 0
    for (final key in _animationValues.keys) {
      _animationValues[key]?.value = 0.0;
    }
    
    // Set selected language animation to 1
    _animationValues[selectedId]?.value = 1.0;
  }

  String translate(String key) {
    final translations = LanguageConstants.translations[selectedLanguageId];
    return translations?[key] ?? key;
  }

  double getAnimationValue(String languageId) {
    return _animationValues[languageId]?.value ?? 0.0;
  }

  void updateAnimationValue(String languageId, double value) {
    _animationValues[languageId]?.value = value;
  }
}

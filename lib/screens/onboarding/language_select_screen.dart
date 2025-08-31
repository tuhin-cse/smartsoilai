import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/language_constants.dart';
import '../../controllers/language_controller.dart';
import '../../models/language.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  final LanguageController _languageController = Get.put(LanguageController());
  String _localSelectedLanguage = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _localSelectedLanguage = _languageController.selectedLanguageId;
  }

  void _handleLanguageSelect(String languageId) {
    if (languageId == _localSelectedLanguage) return;

    setState(() {
      _localSelectedLanguage = languageId;
    });

    _languageController.selectLanguageLocally(languageId);

    // Auto-save and navigate after selection
    _handleContinue();
  }

  Future<void> _handleContinue() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _languageController.setLanguage(_localSelectedLanguage);

      // Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));

      Get.offNamed('/login');
    } catch (error) {
      print('Error saving language: $error');
      Get.snackbar(
        'Error',
        'Failed to save language preference',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildLanguageOption(Language language) {
    final isSelected = _localSelectedLanguage == language.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _handleLanguageSelect(language.id),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary100 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE8EBF0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Language name
              Expanded(
                child: Text(
                  language.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F1F1F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Radio button
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary500 : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary500
                        : const Color(0xFFE8EBF0),
                    width: 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 15,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_languageController.isLoading) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAF8),
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary500),
                  const SizedBox(height: 16),
                  Text(
                    _languageController.translate('loading'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF838896),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24),

                child: Center(
                  child: Text(
                    "Select Language",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.44,
                    ),
                  ),
                ),
              ),

              // Language options
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: LanguageConstants.languages.map((language) {
                      return _buildLanguageOption(language);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

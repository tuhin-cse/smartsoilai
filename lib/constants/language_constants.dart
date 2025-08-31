import '../models/language.dart';

class LanguageConstants {
  // Available languages
  static const List<Language> languages = [
    Language(
      id: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
      languageCode: 'en',
      countryCode: 'US',
    ),
    Language(
      id: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '��',
      languageCode: 'hi',
      countryCode: 'IN',
    ),
    Language(
      id: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      flag: '🇧🇩',
      languageCode: 'bn',
      countryCode: 'BD',
    ),
    Language(
      id: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      flag: '🇵�',
      languageCode: 'ur',
      countryCode: 'PK',
    ),
    Language(
      id: 'pa',
      name: 'Panjabi',
      nativeName: 'ਪੰਜਾਬੀ',
      flag: '��',
      languageCode: 'pa',
      countryCode: 'IN',
    ),
  ];

  // Default language
  static final Language defaultLanguage = languages[0]; // English

  // Get language by ID
  static Language? getLanguageById(String id) {
    try {
      return languages.firstWhere((lang) => lang.id == id);
    } catch (e) {
      return null;
    }
  }

  // Translation keys
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'selectLanguage': 'Select Language',
      'chooseLanguage': 'Choose your preferred language for a better experience',
      'continue': 'Continue',
      'loading': 'Loading...',
    },
    'hi': {
      'selectLanguage': 'भाषा चुनें',
      'chooseLanguage': 'बेहतर अनुभव के लिए अपनी पसंदीदा भाषा चुनें',
      'continue': 'जारी रखें',
      'loading': 'लोड हो रहा है...',
    },
    'bn': {
      'selectLanguage': 'ভাষা নির্বাচন করুন',
      'chooseLanguage': 'একটি ভাল অভিজ্ঞতার জন্য আপনার পছন্দের ভাষা বেছে নিন',
      'continue': 'চালিয়ে যান',
      'loading': 'লোড হচ্ছে...',
    },
    'ur': {
      'selectLanguage': 'زبان منتخب کریں',
      'chooseLanguage': 'بہتر تجربے کے لیے اپنی پسندیدہ زبان منتخب کریں',
      'continue': 'جاری رکھیں',
      'loading': 'لوڈ ہو رہا ہے...',
    },
    'pa': {
      'selectLanguage': 'ਭਾਸ਼ਾ ਚੁਣੋ',
      'chooseLanguage': 'ਬਿਹਤਰ ਅਨੁਭਵ ਲਈ ਆਪਣੀ ਪਸੰਦੀਦਾ ਭਾਸ਼ਾ ਚੁਣੋ',
      'continue': 'ਜਾਰੀ ਰੱਖੋ',
      'loading': 'ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ...',
    },
  };
}

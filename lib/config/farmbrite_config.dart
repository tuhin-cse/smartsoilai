// Farmbrite API Configuration
class FarmbriteConfig {
  // Replace with your actual Farmbrite API key
  static const String apiKey =
      'fn_live_1757006773890_7fCkonuFYeFD4EXohxhFeZDghdhX2NT7';
  // static const String testApiKey =
  //     'fn_test_1757006592123_aYxdMnTgkAEexuCuwIAtuTVousYgSuy1';

  // Replace with your actual field ID from Farmbrite
  static const String defaultFieldId = 'field_001';

  // API endpoints
  static const String baseUrl = 'https://api.farmbrite.com/v1';
  static const String fieldsEndpoint = '$baseUrl/fields';
  static const String satelliteEndpoint = '$baseUrl/satellite';
}

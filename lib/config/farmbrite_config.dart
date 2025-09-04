// Farmbrite API Configuration
class FarmbriteConfig {
  // Replace with your actual Farmbrite API key
  static const String apiKey = 'your_farmbrite_api_key_here';

  // Replace with your actual field ID from Farmbrite
  static const String defaultFieldId = 'your_field_id_here';

  // API endpoints
  static const String baseUrl = 'https://api.farmbrite.com/v1';
  static const String fieldsEndpoint = '$baseUrl/fields';
  static const String satelliteEndpoint = '$baseUrl/satellite';

  // API documentation: https://docs.farmbrite.com/
  // To get API key:
  // 1. Sign up at https://farmbrite.com
  // 2. Go to Settings > API Keys
  // 3. Generate a new API key
  // 4. Replace the apiKey constant above

  // To get field ID:
  // 1. Go to your Farmbrite dashboard
  // 2. Select your field
  // 3. The field ID will be in the URL or field details
  // 4. Replace the defaultFieldId constant above
}

class AppConfig {
  // static const String baseUrl = 'http://192.168.1.111:3000'; // Replace with your actual API URL
  static const String baseUrl =
      'https://backend.smartsoilai.com'; // Replace with your actual API URL
      // 'https://soilai.ezystore.xyz'; // Replace with your actual API URL

  // Timeout settings
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Storage keys
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userKey = 'user';

  // Environment settings
  static const bool isDevelopment = true; // Set to false for production
  static const bool enableLogging = true; // Set to false for production
}

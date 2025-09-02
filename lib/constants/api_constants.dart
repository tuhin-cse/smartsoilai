/// API Keys and configuration constants
class ApiConstants {
  // Weather API Configuration
  // Get your free API key from: https://www.weatherapi.com/
  // Sign up for free and replace this key
  static const String weatherApiKey =
      'b115c3ac0aa04125a5f60738250209'; // Replace with your valid API key
  static const String weatherBaseUrl = 'https://api.weatherapi.com/v1';

  // Alternative: OpenWeatherMap API (free tier available)
  // Get your free API key from: https://openweathermap.org/api
  // static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
  // static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';

  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}

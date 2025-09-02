import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../constants/api_constants.dart';

class WeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String conditionIcon;
  final double humidity;
  final double windSpeed;
  final String windDirection;
  final double pressure;
  final double uvIndex;
  final double visibility;
  final List<HourlyForecast> hourlyForecast;
  final String lastUpdated;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.conditionIcon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.uvIndex,
    required this.visibility,
    required this.hourlyForecast,
    required this.lastUpdated,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final forecast = json['forecast']['forecastday'][0];

    return WeatherData(
      location: '${location['name']}, ${location['region']}',
      temperature: current['temp_c'].toDouble(),
      feelsLike: current['feelslike_c'].toDouble(),
      condition: current['condition']['text'],
      conditionIcon: current['condition']['icon'],
      humidity: current['humidity'].toDouble(),
      windSpeed: current['wind_kph'].toDouble(),
      windDirection: _getWindDirection(current['wind_degree']),
      pressure: current['pressure_mb'].toDouble(),
      uvIndex: current['uv'].toDouble(),
      visibility: current['vis_km'].toDouble(),
      hourlyForecast:
          (forecast['hour'] as List)
              .map((hour) => HourlyForecast.fromJson(hour))
              .toList(),
      lastUpdated: current['last_updated'],
    );
  }

  static String _getWindDirection(int degrees) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    return directions[((degrees / 22.5) + 0.5).toInt() % 16];
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;
  final String conditionIcon;
  final double chanceOfRain;
  final double humidity;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.conditionIcon,
    required this.chanceOfRain,
    required this.humidity,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time']),
      temperature: json['temp_c'].toDouble(),
      condition: json['condition']['text'],
      conditionIcon: json['condition']['icon'],
      chanceOfRain: json['chance_of_rain'].toDouble(),
      humidity: json['humidity'].toDouble(),
    );
  }
}

class WeatherService extends GetxController {
  static const String _apiKey = ApiConstants.weatherApiKey;
  static const String _baseUrl = ApiConstants.weatherBaseUrl;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
    ),
  );

  final Rx<WeatherData?> weatherData = Rx<WeatherData?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData();
  }

  Future<bool> _requestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      error.value =
          'Location services are disabled. Please enable location services.';
      return false;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        error.value =
            'Location permission denied. Please allow location access.';
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      error.value =
          'Location permissions are permanently denied. Please enable them in app settings.';
      return false;
    }

    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      print('🌤️ WeatherService: Starting location request...');

      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        print(
          '🌤️ WeatherService: Location permission denied - ${error.value}',
        );
        return null;
      }

      print(
        '🌤️ WeatherService: Location permission granted, getting position...',
      );

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      print(
        '🌤️ WeatherService: Position obtained: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      print('🌤️ WeatherService: Error getting position: $e');
      error.value =
          'Unable to get your location. Please check GPS settings and try again.';
      return null;
    }
  }

  Future<void> fetchWeatherData() async {
    print('🌤️ WeatherService: Starting weather data fetch...');
    isLoading.value = true;
    error.value = '';

    try {
      final position = await _getCurrentPosition();
      if (position == null) {
        print('🌤️ WeatherService: Position is null, stopping fetch');
        isLoading.value = false;
        return;
      }

      final langCode = Get.locale?.languageCode ?? 'en';
      print(
        '🌤️ WeatherService: Making API request with position: ${position.latitude}, ${position.longitude}',
      );

      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {
          'key': _apiKey,
          'q': '${position.latitude},${position.longitude}',
          'days': 1,
          'alerts': 'no',
          'lang': langCode,
        },
      );

      print('🌤️ WeatherService: API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        weatherData.value = WeatherData.fromJson(response.data);
        print(
          '🌤️ WeatherService: Weather data loaded successfully: ${weatherData.value?.temperature}°C at ${weatherData.value?.location}',
        );
      } else {
        error.value = 'Failed to fetch weather data: ${response.statusCode}';
        print(
          '🌤️ WeatherService: API failed with status: ${response.statusCode}',
        );
        _loadMockData(); // Fallback to mock data
      }
    } catch (e) {
      error.value = 'Weather API error: ${e.toString()}';
      print('🌤️ WeatherService: API error: $e');
      _loadMockData(); // Fallback to mock data
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMockData() {
    print('Loading mock weather data as fallback');
    // Mock weather data for testing when API fails
    final now = DateTime.now();
    final mockHourlyForecast = List.generate(24, (index) {
      final time = now.add(Duration(hours: index));
      return HourlyForecast(
        time: time,
        temperature: 25.0 + (index % 5 - 2), // Vary temperature slightly
        condition: 'Sunny',
        conditionIcon: '//cdn.weatherapi.com/weather/64x64/day/113.png',
        chanceOfRain: 0.0,
        humidity: 60.0,
      );
    });

    weatherData.value = WeatherData(
      location: 'Dhaka, Bangladesh',
      temperature: 27.0,
      feelsLike: 29.0,
      condition: 'Sunny',
      conditionIcon: '//cdn.weatherapi.com/weather/64x64/day/113.png',
      humidity: 65.0,
      windSpeed: 15.0,
      windDirection: 'SW',
      pressure: 1013.0,
      uvIndex: 7.0,
      visibility: 10.0,
      hourlyForecast: mockHourlyForecast,
      lastUpdated: now.toIso8601String(),
    );
  }

  Future<void> refreshWeatherData() async {
    await fetchWeatherData();
  }

  // Helper methods for UI
  String getTemperatureString() {
    if (weatherData.value == null) return '27°C';
    return '${weatherData.value!.temperature.round()}°C';
  }

  String getFeelsLikeString() {
    if (weatherData.value == null) return '27°C';
    return '${weatherData.value!.feelsLike.round()}°C';
  }

  String getHumidityString() {
    if (weatherData.value == null) return '40%';
    return '${weatherData.value!.humidity.round()}%';
  }

  String getWindSpeedString() {
    if (weatherData.value == null) return '23 mph';
    return '${weatherData.value!.windSpeed.round()} km/h';
  }

  String getPressureString() {
    if (weatherData.value == null) return '460 hpa';
    return '${weatherData.value!.pressure.round()} hPa';
  }

  String getVisibilityString() {
    if (weatherData.value == null) return '10 km';
    return '${weatherData.value!.visibility.round()} km';
  }

  String getLocationString() {
    if (weatherData.value == null) return 'Jessore, Khulna';
    return weatherData.value!.location;
  }

  String getConditionString() {
    if (weatherData.value == null) return 'Sunny';
    return weatherData.value!.condition;
  }

  String getConditionIconUrl() {
    if (weatherData.value == null) return '';
    return 'https:${weatherData.value!.conditionIcon}';
  }

  // Get min/max temperature for the day
  Map<String, int> getMinMaxTemp() {
    if (weatherData.value == null ||
        weatherData.value!.hourlyForecast.isEmpty) {
      return {'min': 14, 'max': 23};
    }

    final temps =
        weatherData.value!.hourlyForecast
            .map((hour) => hour.temperature.round())
            .toList();

    return {
      'min': temps.reduce((a, b) => a < b ? a : b),
      'max': temps.reduce((a, b) => a > b ? a : b),
    };
  }

  // Get sunrise/sunset times
  Map<String, String> getSunTimes() {
    // This would require additional API call or calculation
    // For now, return default times
    return {'sunrise': '5:20 am', 'sunset': '7:20 pm'};
  }
}

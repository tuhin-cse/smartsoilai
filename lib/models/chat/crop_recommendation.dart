class CropSensorDataDto {
  final double temperature;
  final double humidity;
  final double ec;
  final double ph;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double salinity;

  CropSensorDataDto({
    required this.temperature,
    required this.humidity,
    required this.ec,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.salinity,
  });

  factory CropSensorDataDto.fromJson(Map<String, dynamic> json) {
    return CropSensorDataDto(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      ec: (json['ec'] as num).toDouble(),
      ph: (json['ph'] as num).toDouble(),
      nitrogen: (json['nitrogen'] as num).toDouble(),
      phosphorus: (json['phosphorus'] as num).toDouble(),
      potassium: (json['potassium'] as num).toDouble(),
      salinity: (json['salinity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'ec': ec,
      'ph': ph,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'salinity': salinity,
    };
  }
}

class CropRecommendationRequestDto {
  final CropSensorDataDto sensorData;

  CropRecommendationRequestDto({
    required this.sensorData,
  });

  factory CropRecommendationRequestDto.fromJson(Map<String, dynamic> json) {
    return CropRecommendationRequestDto(
      sensorData: CropSensorDataDto.fromJson(json['sensorData']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensorData': sensorData.toJson(),
    };
  }
}

class CropRecommendationDto {
  final String id;
  final String name;
  final String icon;
  final double suitabilityScore;
  final List<String> reasons;

  CropRecommendationDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.suitabilityScore,
    required this.reasons,
  });

  factory CropRecommendationDto.fromJson(Map<String, dynamic> json) {
    return CropRecommendationDto(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      suitabilityScore: (json['suitabilityScore'] as num).toDouble(),
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'suitabilityScore': suitabilityScore,
      'reasons': reasons,
    };
  }
}

class CropRecommendationResponseDto {
  final bool success;
  final List<CropRecommendationDto> recommendations;

  CropRecommendationResponseDto({
    required this.success,
    required this.recommendations,
  });

  factory CropRecommendationResponseDto.fromJson(Map<String, dynamic> json) {
    return CropRecommendationResponseDto(
      success: json['success'],
      recommendations: (json['recommendations'] as List)
          .map((e) => CropRecommendationDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
    };
  }
}

class SensorDataDto {
  final double temperature;
  final double humidity;
  final double ec;
  final double ph;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double salinity;

  SensorDataDto({
    required this.temperature,
    required this.humidity,
    required this.ec,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.salinity,
  });

  factory SensorDataDto.fromJson(Map<String, dynamic> json) {
    return SensorDataDto(
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

class SelectedCropDto {
  final String name;
  final String? variety;

  SelectedCropDto({
    required this.name,
    this.variety,
  });

  factory SelectedCropDto.fromJson(Map<String, dynamic> json) {
    return SelectedCropDto(
      name: json['name'],
      variety: json['variety'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'variety': variety,
    };
  }
}

class CalculationDataDto {
  final String areaSize;
  final String numberOfTrees;
  final SelectedCropDto selectedCrop;

  CalculationDataDto({
    required this.areaSize,
    required this.numberOfTrees,
    required this.selectedCrop,
  });

  factory CalculationDataDto.fromJson(Map<String, dynamic> json) {
    return CalculationDataDto(
      areaSize: json['areaSize'],
      numberOfTrees: json['numberOfTrees'],
      selectedCrop: SelectedCropDto.fromJson(json['selectedCrop']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'areaSize': areaSize,
      'numberOfTrees': numberOfTrees,
      'selectedCrop': selectedCrop.toJson(),
    };
  }
}

class FertilizerCalculationDto {
  final SensorDataDto sensorData;
  final CalculationDataDto calculationData;

  FertilizerCalculationDto({
    required this.sensorData,
    required this.calculationData,
  });

  factory FertilizerCalculationDto.fromJson(Map<String, dynamic> json) {
    return FertilizerCalculationDto(
      sensorData: SensorDataDto.fromJson(json['sensorData']),
      calculationData: CalculationDataDto.fromJson(json['calculationData']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensorData': sensorData.toJson(),
      'calculationData': calculationData.toJson(),
    };
  }
}

class FertilizerItemDto {
  final String name;
  final String amount;
  final String perTree;
  final String color;

  FertilizerItemDto({
    required this.name,
    required this.amount,
    required this.perTree,
    required this.color,
  });

  factory FertilizerItemDto.fromJson(Map<String, dynamic> json) {
    return FertilizerItemDto(
      name: json['name'],
      amount: json['amount'],
      perTree: json['perTree'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'perTree': perTree,
      'color': color,
    };
  }
}

class FertilizerRecommendationDto {
  final List<FertilizerItemDto> nonOrganic;
  final List<FertilizerItemDto> organic;

  FertilizerRecommendationDto({
    required this.nonOrganic,
    required this.organic,
  });

  factory FertilizerRecommendationDto.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendationDto(
      nonOrganic: (json['nonOrganic'] as List)
          .map((e) => FertilizerItemDto.fromJson(e))
          .toList(),
      organic: (json['organic'] as List)
          .map((e) => FertilizerItemDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nonOrganic': nonOrganic.map((e) => e.toJson()).toList(),
      'organic': organic.map((e) => e.toJson()).toList(),
    };
  }
}

class FertilizerCalculationResponseDto {
  final bool success;
  final FertilizerRecommendationDto recommendation;

  FertilizerCalculationResponseDto({
    required this.success,
    required this.recommendation,
  });

  factory FertilizerCalculationResponseDto.fromJson(Map<String, dynamic> json) {
    return FertilizerCalculationResponseDto(
      success: json['success'],
      recommendation: FertilizerRecommendationDto.fromJson(json['recommendation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'recommendation': recommendation.toJson(),
    };
  }
}

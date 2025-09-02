import '../chat/fertilizer_calculation.dart';
import '../chat/crop_recommendation.dart';

class CreateReportDto {
  final String name;
  final String date;
  final SensorDataDto sensorData;
  final CalculationDataDto calculationData;
  final SelectedCropDto selectedCrop;
  final List<CropRecommendationDto> cropRecommendations;
  final FertilizerRecommendationDto fertilizerRecommendation;

  CreateReportDto({
    required this.name,
    required this.date,
    required this.sensorData,
    required this.calculationData,
    required this.selectedCrop,
    required this.cropRecommendations,
    required this.fertilizerRecommendation,
  });

  factory CreateReportDto.fromJson(Map<String, dynamic> json) {
    return CreateReportDto(
      name: json['name'],
      date: json['date'],
      sensorData: SensorDataDto.fromJson(json['sensorData']),
      calculationData: CalculationDataDto.fromJson(json['calculationData']),
      selectedCrop: SelectedCropDto.fromJson(json['selectedCrop']),
      cropRecommendations: (json['cropRecommendations'] as List)
          .map((e) => CropRecommendationDto.fromJson(e))
          .toList(),
      fertilizerRecommendation: FertilizerRecommendationDto.fromJson(json['fertilizerRecommendation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date,
      'sensorData': sensorData.toJson(),
      'calculationData': calculationData.toJson(),
      'selectedCrop': selectedCrop.toJson(),
      'cropRecommendations': cropRecommendations.map((e) => e.toJson()).toList(),
      'fertilizerRecommendation': fertilizerRecommendation.toJson(),
    };
  }
}

class ReportResponseDto {
  final String id;
  final String userId;
  final String name;
  final String date;
  final Map<String, dynamic> sensorData;
  final Map<String, dynamic> calculationData;
  final Map<String, dynamic> selectedCrop;
  final List<dynamic> cropRecommendations;
  final Map<String, dynamic> fertilizerRecommendation;
  final String createdAt;
  final String updatedAt;

  ReportResponseDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.sensorData,
    required this.calculationData,
    required this.selectedCrop,
    required this.cropRecommendations,
    required this.fertilizerRecommendation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportResponseDto.fromJson(Map<String, dynamic> json) {
    return ReportResponseDto(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      date: json['date'],
      sensorData: Map<String, dynamic>.from(json['sensorData'] ?? {}),
      calculationData: Map<String, dynamic>.from(json['calculationData'] ?? {}),
      selectedCrop: Map<String, dynamic>.from(json['selectedCrop'] ?? {}),
      cropRecommendations: List<dynamic>.from(json['cropRecommendations'] ?? []),
      fertilizerRecommendation: Map<String, dynamic>.from(json['fertilizerRecommendation'] ?? {}),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'date': date,
      'sensorData': sensorData,
      'calculationData': calculationData,
      'selectedCrop': selectedCrop,
      'cropRecommendations': cropRecommendations,
      'fertilizerRecommendation': fertilizerRecommendation,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ReportListItemDto {
  final String id;
  final String name;
  final String date;
  final String cropName;
  final String cropIcon;
  final String createdAt;
  final String updatedAt;

  ReportListItemDto({
    required this.id,
    required this.name,
    required this.date,
    required this.cropName,
    required this.cropIcon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportListItemDto.fromJson(Map<String, dynamic> json) {
    return ReportListItemDto(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      cropName: json['cropName'],
      cropIcon: json['cropIcon'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'cropName': cropName,
      'cropIcon': cropIcon,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class DeleteReportResponseDto {
  final bool success;
  final String message;

  DeleteReportResponseDto({
    required this.success,
    required this.message,
  });

  factory DeleteReportResponseDto.fromJson(Map<String, dynamic> json) {
    return DeleteReportResponseDto(
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

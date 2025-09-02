class CropDiseaseAnalysisRequestDto {
  final String imageBase64;

  CropDiseaseAnalysisRequestDto({
    required this.imageBase64,
  });

  factory CropDiseaseAnalysisRequestDto.fromJson(Map<String, dynamic> json) {
    return CropDiseaseAnalysisRequestDto(
      imageBase64: json['imageBase64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageBase64': imageBase64,
    };
  }
}

class AnalysisResultDto {
  final String title;
  final String description;

  AnalysisResultDto({
    required this.title,
    required this.description,
  });

  factory AnalysisResultDto.fromJson(Map<String, dynamic> json) {
    return AnalysisResultDto(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}

class AdviceItemDto {
  final String title;
  final String description;

  AdviceItemDto({
    required this.title,
    required this.description,
  });

  factory AdviceItemDto.fromJson(Map<String, dynamic> json) {
    return AdviceItemDto(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}

class AdviceCategoryDto {
  final String key;
  final List<AdviceItemDto> advices;

  AdviceCategoryDto({
    required this.key,
    required this.advices,
  });

  factory AdviceCategoryDto.fromJson(Map<String, dynamic> json) {
    return AdviceCategoryDto(
      key: json['key'],
      advices: (json['advices'] as List)
          .map((e) => AdviceItemDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'advices': advices.map((e) => e.toJson()).toList(),
    };
  }
}

class DiseaseAnalysisDto {
  final List<AnalysisResultDto> results;
  final List<AdviceCategoryDto> advices;

  DiseaseAnalysisDto({
    required this.results,
    required this.advices,
  });

  factory DiseaseAnalysisDto.fromJson(Map<String, dynamic> json) {
    return DiseaseAnalysisDto(
      results: (json['results'] as List)
          .map((e) => AnalysisResultDto.fromJson(e))
          .toList(),
      advices: (json['advices'] as List)
          .map((e) => AdviceCategoryDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'advices': advices.map((e) => e.toJson()).toList(),
    };
  }
}

class CropDiseaseAnalysisResponseDto {
  final DiseaseAnalysisDto diseaseAnalysis;

  CropDiseaseAnalysisResponseDto({
    required this.diseaseAnalysis,
  });

  factory CropDiseaseAnalysisResponseDto.fromJson(Map<String, dynamic> json) {
    return CropDiseaseAnalysisResponseDto(
      diseaseAnalysis: DiseaseAnalysisDto.fromJson(json['diseaseAnalysis']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diseaseAnalysis': diseaseAnalysis.toJson(),
    };
  }
}

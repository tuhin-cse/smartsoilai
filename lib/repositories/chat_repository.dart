import 'package:dio/dio.dart';
import '../models/chat/chat_message.dart';
import '../models/chat/conversation.dart';
import '../models/chat/fertilizer_calculation.dart';
import '../models/chat/crop_recommendation.dart';
import '../models/chat/crop_disease_analysis.dart';
import 'api_client.dart';
import 'exceptions/api_exception.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Send a message to the AI assistant
  Future<ChatResponseDto> sendMessage(ChatMessageDto messageDto) async {
    try {
      final response = await _apiClient.dio.post(
        '/chat/message',
        data: messageDto.toJson(),
      );

      if (response.statusCode == 200) {
        return ChatResponseDto.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to send message',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to send message',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Network error occurred',
          statusCode: null,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        statusCode: null,
      );
    }
  }

  /// Get all conversations for the authenticated user
  Future<List<ConversationListDto>> getConversations({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.dio.get(
        '/chat/conversations',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ConversationListDto.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Failed to fetch conversations',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to fetch conversations',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Network error occurred',
          statusCode: null,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        statusCode: null,
      );
    }
  }

  /// Get conversation details by ID
  Future<ConversationDto> getConversationDetails(String conversationId) async {
    try {
      final response = await _apiClient.dio.get(
        '/chat/conversations/$conversationId',
      );

      if (response.statusCode == 200) {
        return ConversationDto.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to fetch conversation details',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to fetch conversation details',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Network error occurred',
          statusCode: null,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        statusCode: null,
      );
    }
  }

  /// Delete a conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final response = await _apiClient.dio.delete(
        '/chat/conversations/$conversationId',
      );

      if (response.statusCode == 200) {
        return response.data['success'] ?? false;
      } else {
        throw ApiException(
          message: 'Failed to delete conversation',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to delete conversation',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Network error occurred',
          statusCode: null,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        statusCode: null,
      );
    }
  }

  /// Calculate fertilizer recommendations using AI
  Future<FertilizerCalculationResponseDto> calculateFertilizer(
    FertilizerCalculationDto calculationDto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/chat/calculate-fertilizer',
        data: calculationDto.toJson(),
      );

      if (response.statusCode == 200) {
        return FertilizerCalculationResponseDto.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to calculate fertilizer recommendations',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to calculate fertilizer recommendations',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Network error occurred',
          statusCode: null,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        statusCode: null,
      );
    }
  }

  /// Get crop recommendations based on soil sensor data
  Future<CropRecommendationResponseDto> getCropRecommendations(
    CropRecommendationRequestDto requestDto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/chat/crop-recommendations',
        data: requestDto.toJson(),
      );

      if (response.statusCode == 200) {
        return CropRecommendationResponseDto.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to get crop recommendations',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to get crop recommendations',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Network error occurred',
          statusCode: null,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        statusCode: null,
      );
    }
  }

  /// Analyze crop disease from leaf image using AI
  Future<CropDiseaseAnalysisResponseDto> analyzeCropDisease(
    CropDiseaseAnalysisRequestDto requestDto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/chat/analyze-crop-disease',
        data: requestDto.toJson(),
      );


      print(response.data);

      if (response.statusCode == 200) {
        return CropDiseaseAnalysisResponseDto.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to analyze crop disease',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to analyze crop disease',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Network error occurred',
          statusCode: null,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        statusCode: null,
      );
    }
  }
}

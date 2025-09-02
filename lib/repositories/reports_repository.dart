import 'package:dio/dio.dart';
import '../models/reports/report.dart';
import 'api_client.dart';
import 'exceptions/api_exception.dart';

class ReportsRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Create a new agricultural report
  Future<ReportResponseDto> createReport(CreateReportDto reportDto) async {
    try {
      final response = await _apiClient.dio.post(
        '/reports',
        data: reportDto.toJson(),
      );

      if (response.statusCode == 201) {
        return ReportResponseDto.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to create report',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Failed to create report';
        
        // Handle validation errors
        if (e.response?.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] is List) {
            errorMessage = (errorData['message'] as List).join(', ');
          } else if (errorData['message'] is String) {
            errorMessage = errorData['message'];
          }
        }

        throw ApiException(
          message: errorMessage,
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

  /// Get all reports for the authenticated user
  Future<List<ReportListItemDto>> getReports({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.dio.get(
        '/reports',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ReportListItemDto.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Failed to fetch reports',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to fetch reports',
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

  /// Get report details by ID
  Future<ReportResponseDto> getReportById(String reportId) async {
    try {
      final response = await _apiClient.dio.get(
        '/reports/$reportId',
      );

      if (response.statusCode == 200) {
        return ReportResponseDto.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to fetch report details',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to fetch report details',
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

  /// Delete a report
  Future<DeleteReportResponseDto> deleteReport(String reportId) async {
    try {
      final response = await _apiClient.dio.delete(
        '/reports/$reportId',
      );

      if (response.statusCode == 200) {
        return DeleteReportResponseDto.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to delete report',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to delete report',
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

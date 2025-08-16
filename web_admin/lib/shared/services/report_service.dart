import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/report.dart';
import '../../core/services/http_client.dart';
import '../../core/utils/api_exceptions.dart' as api_ex;

class ReportService {
  final HttpClient _httpClient;

  ReportService(this._httpClient);

  // Report Templates Management
  Future<List<ReportTemplate>> getReportTemplates() async {
    try {
      final response = await _httpClient.get<List<dynamic>>('/analytics/templates/');
      
      final templateList = response.data!;
      return templateList
          .map((json) => ReportTemplate.fromJson(json as Map<String, dynamic>))
          .toList();
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch report templates: $e',
        statusCode: 500,
      );
    }
  }

  Future<ReportTemplate> createReportTemplate(CreateReportTemplateRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/analytics/templates/',
        data: request.toJson(),
      );

      return ReportTemplate.fromJson(response.data!);
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'CREATE_ERROR',
        message: 'Failed to create report template: $e',
        statusCode: 500,
      );
    }
  }

  Future<ReportTemplate> updateReportTemplate(int id, CreateReportTemplateRequest request) async {
    try {
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/analytics/templates/$id/',
        data: request.toJson(),
      );

      return ReportTemplate.fromJson(response.data!);
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'UPDATE_ERROR',
        message: 'Failed to update report template: $e',
        statusCode: 500,
      );
    }
  }

  Future<void> deleteReportTemplate(int id) async {
    try {
      await _httpClient.delete('/analytics/templates/$id/');
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'DELETE_ERROR',
        message: 'Failed to delete report template: $e',
        statusCode: 500,
      );
    }
  }

  // Report Generation
  Future<ReportResult> generateReport(GenerateReportRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/analytics/reports/generate/',
        data: request.toJson(),
      );

      return ReportResult.fromJson(response.data!);
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'GENERATE_ERROR',
        message: 'Failed to generate report: $e',
        statusCode: 500,
      );
    }
  }

  Future<ReportResult> getReportStatus(String reportId) async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/analytics/reports/$reportId/status/',
      );

      return ReportResult.fromJson(response.data!);
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'STATUS_ERROR',
        message: 'Failed to get report status: $e',
        statusCode: 500,
      );
    }
  }

  // Export Functions
  Future<String> exportToPdf(GenerateReportRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/analytics/reports/export/pdf/',
        data: request.toJson(),
      );

      return response.data!['download_url'] as String;
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'EXPORT_ERROR',
        message: 'Failed to export to PDF: $e',
        statusCode: 500,
      );
    }
  }

  Future<String> exportToCsv(GenerateReportRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/analytics/reports/export/csv/',
        data: request.toJson(),
      );

      return response.data!['download_url'] as String;
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'EXPORT_ERROR',
        message: 'Failed to export to CSV: $e',
        statusCode: 500,
      );
    }
  }

  // Scheduled Reports
  Future<List<ScheduledReport>> getScheduledReports() async {
    try {
      final response = await _httpClient.get<List<dynamic>>('/analytics/reports/scheduled/');
      
      final reportList = response.data!;
      return reportList
          .map((json) => ScheduledReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch scheduled reports: $e',
        statusCode: 500,
      );
    }
  }

  Future<ScheduledReport> createScheduledReport(CreateScheduledReportRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/analytics/reports/schedule/',
        data: request.toJson(),
      );

      return ScheduledReport.fromJson(response.data!);
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'CREATE_ERROR',
        message: 'Failed to create scheduled report: $e',
        statusCode: 500,
      );
    }
  }

  Future<void> deleteScheduledReport(int id) async {
    try {
      await _httpClient.delete('/analytics/reports/scheduled/$id/');
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'DELETE_ERROR',
        message: 'Failed to delete scheduled report: $e',
        statusCode: 500,
      );
    }
  }

  Future<ScheduledReport> toggleScheduledReport(int id, bool isActive) async {
    try {
      final response = await _httpClient.patch<Map<String, dynamic>>(
        '/analytics/reports/scheduled/$id/',
        data: {'is_active': isActive},
      );

      return ScheduledReport.fromJson(response.data!);
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'UPDATE_ERROR',
        message: 'Failed to toggle scheduled report: $e',
        statusCode: 500,
      );
    }
  }

  // Analytics Data
  Future<Map<String, dynamic>> getAnalyticsOverview() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>('/analytics/');
      return response.data!;
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch analytics overview: $e',
        statusCode: 500,
      );
    }
  }

  Future<Map<String, dynamic>> getPatrolEfficiencyReport({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? siteIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (siteIds != null && siteIds.isNotEmpty) {
        queryParams['site_ids'] = siteIds.join(',');
      }

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/analytics/patrol-efficiency/',
        queryParameters: queryParams,
      );

      return response.data!;
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch patrol efficiency report: $e',
        statusCode: 500,
      );
    }
  }

  Future<Map<String, dynamic>> getIncidentTrends({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? siteIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (siteIds != null && siteIds.isNotEmpty) {
        queryParams['site_ids'] = siteIds.join(',');
      }

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/analytics/incident-trends/',
        queryParameters: queryParams,
      );

      return response.data!;
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch incident trends: $e',
        statusCode: 500,
      );
    }
  }

  Future<Map<String, dynamic>> getGuardPerformance(int guardId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/analytics/guard-performance/$guardId/',
        queryParameters: queryParams,
      );

      return response.data!;
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch guard performance: $e',
        statusCode: 500,
      );
    }
  }

  Future<Map<String, dynamic>> getSiteSecurity(int siteId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/analytics/site-security/$siteId/',
        queryParameters: queryParams,
      );

      return response.data!;
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch site security score: $e',
        statusCode: 500,
      );
    }
  }
}

// Provider for the report service
final reportServiceProvider = Provider<ReportService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  return ReportService(httpClient);
});
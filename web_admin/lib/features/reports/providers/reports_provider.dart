import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/report.dart';
import '../../../shared/services/report_service.dart';

part 'reports_provider.g.dart';

@riverpod
class ReportTemplates extends _$ReportTemplates {
  @override
  Future<List<ReportTemplate>> build() async {
    final service = ref.read(reportServiceProvider);
    return service.getReportTemplates();
  }

  Future<void> createTemplate(CreateReportTemplateRequest request) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(reportServiceProvider);
      await service.createReportTemplate(request);
      state = await AsyncValue.guard(() => service.getReportTemplates());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateTemplate(int id, CreateReportTemplateRequest request) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(reportServiceProvider);
      await service.updateReportTemplate(id, request);
      state = await AsyncValue.guard(() => service.getReportTemplates());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTemplate(int id) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(reportServiceProvider);
      await service.deleteReportTemplate(id);
      state = await AsyncValue.guard(() => service.getReportTemplates());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

@riverpod
class ScheduledReports extends _$ScheduledReports {
  @override
  Future<List<ScheduledReport>> build() async {
    final service = ref.read(reportServiceProvider);
    return service.getScheduledReports();
  }

  Future<void> createScheduledReport(CreateScheduledReportRequest request) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(reportServiceProvider);
      await service.createScheduledReport(request);
      state = await AsyncValue.guard(() => service.getScheduledReports());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteScheduledReport(int id) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(reportServiceProvider);
      await service.deleteScheduledReport(id);
      state = await AsyncValue.guard(() => service.getScheduledReports());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleScheduledReport(int id, bool isActive) async {
    try {
      final service = ref.read(reportServiceProvider);
      await service.toggleScheduledReport(id, isActive);
      state = await AsyncValue.guard(() => service.getScheduledReports());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

@riverpod
class ReportGeneration extends _$ReportGeneration {
  @override
  Future<Map<String, ReportResult>> build() async {
    return {};
  }

  Future<String> generateReport(GenerateReportRequest request) async {
    try {
      final service = ref.read(reportServiceProvider);
      final result = await service.generateReport(request);
      
      // Update state to track the new report
      final currentState = state.value ?? {};
      state = AsyncValue.data({
        ...currentState,
        result.id: result,
      });
      
      return result.id;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateReportStatus(String reportId) async {
    try {
      final service = ref.read(reportServiceProvider);
      final result = await service.getReportStatus(reportId);
      
      final currentState = state.value ?? {};
      state = AsyncValue.data({
        ...currentState,
        reportId: result,
      });
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<String> exportToPdf(GenerateReportRequest request) async {
    try {
      final service = ref.read(reportServiceProvider);
      return await service.exportToPdf(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> exportToCsv(GenerateReportRequest request) async {
    try {
      final service = ref.read(reportServiceProvider);
      return await service.exportToCsv(request);
    } catch (e) {
      rethrow;
    }
  }

  void removeReport(String reportId) {
    final currentState = state.value ?? {};
    final newState = Map<String, ReportResult>.from(currentState);
    newState.remove(reportId);
    state = AsyncValue.data(newState);
  }
}

@riverpod
class AnalyticsData extends _$AnalyticsData {
  @override
  Future<Map<String, dynamic>> build() async {
    final service = ref.read(reportServiceProvider);
    return service.getAnalyticsOverview();
  }

  Future<Map<String, dynamic>> getPatrolEfficiency({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? siteIds,
  }) async {
    final service = ref.read(reportServiceProvider);
    return service.getPatrolEfficiencyReport(
      startDate: startDate,
      endDate: endDate,
      siteIds: siteIds,
    );
  }

  Future<Map<String, dynamic>> getIncidentTrends({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? siteIds,
  }) async {
    final service = ref.read(reportServiceProvider);
    return service.getIncidentTrends(
      startDate: startDate,
      endDate: endDate,
      siteIds: siteIds,
    );
  }

  Future<Map<String, dynamic>> getGuardPerformance(
    int guardId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final service = ref.read(reportServiceProvider);
    return service.getGuardPerformance(
      guardId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<String, dynamic>> getSiteSecurity(
    int siteId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final service = ref.read(reportServiceProvider);
    return service.getSiteSecurity(
      siteId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
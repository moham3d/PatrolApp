import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/patrol.dart';
import '../../core/services/http_client.dart';
import '../../core/utils/api_exceptions.dart';

class PatrolService {
  final HttpClient _httpClient;

  PatrolService(this._httpClient);

  Future<List<Patrol>> getPatrols({
    int? assignedTo,
    String? status,
    String? taskType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (assignedTo != null) {
        queryParams['assigned_to'] = assignedTo;
      }

      if (status != null) {
        queryParams['status'] = status;
      }

      if (taskType != null) {
        queryParams['task_type'] = taskType;
      }

      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom.toIso8601String();
      }

      if (dateTo != null) {
        queryParams['date_to'] = dateTo.toIso8601String();
      }

      final response = await _httpClient.get<List<dynamic>>(
        '/tasks/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return (response.data!)
          .map((json) => Patrol.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw PatrolException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Patrol> getPatrolById(int id) async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>('/tasks/$id');
      return Patrol.fromJson(response.data!);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw PatrolException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Patrol> createPatrol(CreatePatrolRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/tasks/',
        data: request.toJson(),
      );
      return Patrol.fromJson(response.data!);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw PatrolException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Patrol> updatePatrol(int id, UpdatePatrolRequest request) async {
    try {
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/tasks/$id',
        data: request.toJson(),
      );
      return Patrol.fromJson(response.data!);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw PatrolException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }
}

final patrolServiceProvider = Provider<PatrolService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return PatrolService(httpClient);
});
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/checkpoint.dart';
import '../../core/services/http_client.dart';
import '../../core/utils/api_exceptions.dart' as api_ex;

class CheckpointService {
  final HttpClient _httpClient;

  CheckpointService(this._httpClient);

  Future<List<Checkpoint>> getCheckpoints({
    int? siteId,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (siteId != null) {
        queryParams['site_id'] = siteId;
      }

      if (isActive != null) {
        queryParams['active'] = isActive;
      }

      final response = await _httpClient.get<List<dynamic>>(
        '/checkpoints/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return (response.data!)
          .map((json) => Checkpoint.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is api_ex.ApiException) rethrow;
      throw api_ex.CheckpointException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Checkpoint> getCheckpointById(int id) async {
    try {
      final response =
          await _httpClient.get<Map<String, dynamic>>('/checkpoints/$id');
      return Checkpoint.fromJson(response.data!);
    } catch (e) {
      if (e is api_ex.ApiException) rethrow;
      throw api_ex.CheckpointException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Checkpoint> createCheckpoint(CreateCheckpointRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/checkpoints/',
        data: request.toJson(),
      );
      return Checkpoint.fromJson(response.data!);
    } catch (e) {
      if (e is api_ex.ApiException) rethrow;
      throw api_ex.CheckpointException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Checkpoint> updateCheckpoint(
      int id, UpdateCheckpointRequest request) async {
    try {
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/checkpoints/$id',
        data: request.toJson(),
      );
      return Checkpoint.fromJson(response.data!);
    } catch (e) {
      if (e is api_ex.ApiException) rethrow;
      throw api_ex.CheckpointException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }
}

final checkpointServiceProvider = Provider<CheckpointService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return CheckpointService(httpClient);
});

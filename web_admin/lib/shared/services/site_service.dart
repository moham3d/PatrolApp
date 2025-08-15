import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/site.dart';
import '../../core/services/http_client.dart';
import '../../core/utils/api_exceptions.dart' as api_ex;

class SiteService {
  final HttpClient _httpClient;

  SiteService(this._httpClient);

  Future<List<Site>> getSites({
    bool? isActive,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _httpClient.get<List<dynamic>>(
        '/sites/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return (response.data!).map((json) {
        try {
          return Site.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing site JSON: $json');
          print('Parse error: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      if (e is api_ex.ApiException) rethrow;
      throw api_ex.SiteException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Site> getSiteById(int id) async {
    try {
      final response =
          await _httpClient.get<Map<String, dynamic>>('/sites/$id');
      return Site.fromJson(response.data!);
    } catch (e) {
      if (e is api_ex.ApiException) rethrow;
      throw api_ex.SiteException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Site> createSite(CreateSiteRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/sites/',
        data: request.toJson(),
      );
      return Site.fromJson(response.data!);
    } catch (e) {
      if (e is api_ex.ApiException) rethrow;
      throw api_ex.SiteException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Site> updateSite(int id, UpdateSiteRequest request) async {
    try {
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/sites/$id',
        data: request.toJson(),
      );
      return Site.fromJson(response.data!);
    } catch (e) {
      if (e is api_ex.ApiException) rethrow;
      throw api_ex.SiteException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }
}

final siteServiceProvider = Provider<SiteService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return SiteService(httpClient);
});

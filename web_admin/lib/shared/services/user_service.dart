import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/user.dart';
import '../../shared/models/api_response.dart';
import '../../core/services/http_client.dart';
import '../../core/utils/api_exceptions.dart';

class UserService {
  final HttpClient _httpClient;

  UserService(this._httpClient);

  Future<PaginatedResponse<User>> getUsers({
    int page = 1,
    int perPage = 20,
    String? search,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': perPage,
        'offset': (page - 1) * perPage,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (isActive != null) {
        queryParams['active'] = isActive;
      }

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/users/',
        queryParameters: queryParams,
      );

      // Convert API response format to PaginatedResponse format
      final apiData = response.data!;
      final users = (apiData['users'] as List<dynamic>)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final total = apiData['total'] as int;
      final limit = apiData['limit'] as int;
      final offset = apiData['offset'] as int;
      
      // Calculate pagination info
      final currentPage = (offset ~/ limit) + 1;
      final totalPages = (total / limit).ceil();
      
      final paginationInfo = PaginationInfo(
        total: total,
        page: currentPage,
        perPage: limit,
        pages: totalPages,
        hasNext: offset + limit < total,
        hasPrev: offset > 0,
      );

      return PaginatedResponse(
        data: users,
        pagination: paginationInfo,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UserException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>('/users/$id');
      return User.fromJson(response.data!);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UserException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<User> createUser(CreateUserRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/users/',
        data: request.toJson(),
      );
      return User.fromJson(response.data!);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UserException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<User> updateUser(int id, UpdateUserRequest request) async {
    try {
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/users/$id',
        data: request.toJson(),
      );
      return User.fromJson(response.data!);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UserException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _httpClient.delete('/users/$id');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UserException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return UserService(httpClient);
});
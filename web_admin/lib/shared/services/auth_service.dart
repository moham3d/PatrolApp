import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../shared/models/auth.dart';
import '../../core/services/http_client.dart';
import '../../core/utils/api_exceptions.dart';

class AuthService {
  final HttpClient _httpClient;

  AuthService(this._httpClient);

  Future<AuthToken> login(String username, String password) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: FormData.fromMap({
          'username': username,
          'password': password,
        }),
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      final authToken = AuthToken.fromJson(response.data!);
      await _httpClient.storeToken(authToken.accessToken);
      return authToken;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'LOGIN_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<AuthUser> getCurrentUser() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>('/auth/me');
      return AuthUser.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'USER_INFO_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _httpClient.clearStoredToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _httpClient.getStoredToken();
    return token != null;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return AuthService(httpClient);
});
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification.dart';
import '../../core/services/http_client.dart';
import '../../core/utils/api_exceptions.dart' as api_ex;

class NotificationService {
  final HttpClient _httpClient;

  NotificationService(this._httpClient);

  /// Get all notifications for the current user
  Future<List<AppNotification>> getNotifications({
    NotificationFilters? filters,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      // Add filters if provided
      if (filters != null) {
        queryParams.addAll(filters.toQueryParameters());
      }

      // Add pagination if provided
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _httpClient.get<List<dynamic>>(
        '/notifications/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final notificationList = response.data!;
      return notificationList
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch notifications: $e',
        statusCode: 500,
      );
    }
  }

  /// Mark a specific notification as read
  Future<AppNotification> markAsRead(int notificationId) async {
    try {
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/notifications/$notificationId/read/',
      );

      return AppNotification.fromJson(response.data!);
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'UPDATE_ERROR',
        message: 'Failed to mark notification as read: $e',
        statusCode: 500,
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _httpClient.post<void>('/notifications/mark-all-read/');
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'UPDATE_ERROR',
        message: 'Failed to mark all notifications as read: $e',
        statusCode: 500,
      );
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _httpClient.delete('/notifications/$notificationId/');
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'DELETE_ERROR',
        message: 'Failed to delete notification: $e',
        statusCode: 500,
      );
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/notifications/unread-count/',
      );

      return response.data!['count'] as int;
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch unread count: $e',
        statusCode: 500,
      );
    }
  }

  /// Get notification statistics/summary
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/notifications/stats/',
      );

      return response.data!;
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch notification stats: $e',
        statusCode: 500,
      );
    }
  }

  /// Send a test notification (admin only)
  Future<AppNotification> sendTestNotification({
    required String title,
    required String message,
    required String type,
    String priority = 'normal',
    int? userId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final requestData = {
        'title': title,
        'message': message,
        'type': type,
        'priority': priority,
        if (userId != null) 'user_id': userId,
        if (data != null) 'data': data,
      };

      final response = await _httpClient.post<Map<String, dynamic>>(
        '/notifications/send-test/',
        data: requestData,
      );

      return AppNotification.fromJson(response.data!);
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'SEND_ERROR',
        message: 'Failed to send test notification: $e',
        statusCode: 500,
      );
    }
  }
}

// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  return NotificationService(httpClient);
});
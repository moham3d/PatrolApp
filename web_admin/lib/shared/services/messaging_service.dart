import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../../core/services/http_client.dart';
import '../../core/utils/api_exceptions.dart' as api_ex;

class MessagingService {
  final HttpClient _httpClient;

  MessagingService(this._httpClient);

  /// Get chat messages for a conversation
  Future<List<ChatMessage>> getMessages({
    int? recipientId,
    String? channelId,
    int? limit,
    int? offset,
    DateTime? since,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (recipientId != null) queryParams['recipient_id'] = recipientId;
      if (channelId != null) queryParams['channel_id'] = channelId;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (since != null) queryParams['since'] = since.toIso8601String();

      final response = await _httpClient.get<List<dynamic>>(
        '/messages/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final messageList = response.data!;
      return messageList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch messages: $e',
        statusCode: 500,
      );
    }
  }

  /// Send a message
  Future<ChatMessage> sendMessage(SendMessageRequest request) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/messages/',
        data: request.toJson(),
      );

      return ChatMessage.fromJson(response.data!);
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'SEND_ERROR',
        message: 'Failed to send message: $e',
        statusCode: 500,
      );
    }
  }

  /// Get chat channels - TEMPORARY FIX
  Future<List<ChatChannel>> getChannels() async {
    try {
      // Channels feature not implemented in backend yet
      // Return empty list to prevent 404 errors
      return <ChatChannel>[];

      /* TODO: Implement when backend supports channels
      final response = await _httpClient.get<List<dynamic>>(
        '/messages/',
        queryParameters: {'type': 'channels'},
      );
      
      final channelList = response.data!;
      return channelList
          .map((json) => ChatChannel.fromJson(json as Map<String, dynamic>))
          .toList();
      */
    } catch (e) {
      // Return empty list on any error to prevent app crashes
      return <ChatChannel>[];
    }
  }

  /// Create a new channel - TEMPORARY IMPLEMENTATION
  Future<ChatChannel> createChannel(dynamic request) async {
    try {
      // Channels feature not implemented in backend yet
      // Return a temporary channel to prevent errors
      return ChatChannel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Temporary Channel',
        description: 'Channel creation not yet implemented',
        type: 'public',
        createdBy: 1,
        createdByName: 'System',
        members: [1],
        memberNames: ['System'],
        createdAt: DateTime.now(),
      );

      /* TODO: Implement when backend supports channel creation
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/messages/channels/',
        data: request,
      );
      
      return ChatChannel.fromJson(response.data!);
      */
    } catch (e) {
      throw api_ex.ApiException(
        code: 'CREATE_CHANNEL_ERROR',
        message: 'Failed to create channel: $e',
        statusCode: 500,
      );
    }
  }

  /// Join a channel
  Future<void> joinChannel(String channelId) async {
    try {
      await _httpClient.post<void>('/messaging/channels/$channelId/join/');
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'JOIN_ERROR',
        message: 'Failed to join channel: $e',
        statusCode: 500,
      );
    }
  }

  /// Leave a channel
  Future<void> leaveChannel(String channelId) async {
    try {
      await _httpClient.post<void>('/messaging/channels/$channelId/leave/');
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'LEAVE_ERROR',
        message: 'Failed to leave channel: $e',
        statusCode: 500,
      );
    }
  }

  /// Get online users
  Future<List<ChatUser>> getOnlineUsers() async {
    try {
      final response = await _httpClient.get<List<dynamic>>(
        '/messaging/users/online/',
      );

      final userList = response.data!;
      return userList
          .map((json) => ChatUser.fromJson(json as Map<String, dynamic>))
          .toList();
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch online users: $e',
        statusCode: 500,
      );
    }
  }

  /// Get all users available for messaging
  Future<List<ChatUser>> getAllUsers() async {
    try {
      final response = await _httpClient.get<List<dynamic>>(
        '/messaging/users/',
      );

      final userList = response.data!;
      return userList
          .map((json) => ChatUser.fromJson(json as Map<String, dynamic>))
          .toList();
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch users: $e',
        statusCode: 500,
      );
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({int? recipientId, String? channelId}) async {
    try {
      await _httpClient.post<void>(
        '/messaging/messages/mark-read/',
        data: {'recipient_id': recipientId, 'channel_id': channelId},
      );
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'UPDATE_ERROR',
        message: 'Failed to mark messages as read: $e',
        statusCode: 500,
      );
    }
  }

  /// Get conversation history with a user
  Future<List<ChatMessage>> getConversationHistory(
    int userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _httpClient.get<List<dynamic>>(
        '/messaging/conversations/$userId/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final messageList = response.data!;
      return messageList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch conversation history: $e',
        statusCode: 500,
      );
    }
  }

  /// Get channel messages
  Future<List<ChatMessage>> getChannelMessages(
    String channelId, {
    int? limit,
    int? offset,
    DateTime? since,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (since != null) queryParams['since'] = since.toIso8601String();

      final response = await _httpClient.get<List<dynamic>>(
        '/messaging/channels/$channelId/messages/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final messageList = response.data!;
      return messageList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'FETCH_ERROR',
        message: 'Failed to fetch channel messages: $e',
        statusCode: 500,
      );
    }
  }

  /// Delete a message
  Future<void> deleteMessage(int messageId) async {
    try {
      await _httpClient.delete('/messaging/messages/$messageId/');
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'DELETE_ERROR',
        message: 'Failed to delete message: $e',
        statusCode: 500,
      );
    }
  }

  /// Update user's online status
  Future<void> updateUserStatus(bool isOnline) async {
    try {
      await _httpClient.post<void>(
        '/messaging/users/status/',
        data: {'is_online': isOnline},
      );
    } on api_ex.ApiException {
      rethrow;
    } catch (e) {
      throw api_ex.ApiException(
        code: 'UPDATE_ERROR',
        message: 'Failed to update user status: $e',
        statusCode: 500,
      );
    }
  }
}

// Provider for the messaging service
final messagingServiceProvider = Provider<MessagingService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  return MessagingService(httpClient);
});

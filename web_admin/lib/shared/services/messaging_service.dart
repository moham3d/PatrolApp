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

  /// Get chat channels
  /// Note: Channel functionality is not available in the current API
  Future<List<ChatChannel>> getChannels() async {
    try {
      // The current API does not support explicit channel management
      // Channels are handled implicitly through message recipients
      // Return empty list to maintain compatibility
      return <ChatChannel>[];
    } catch (e) {
      // Return empty list on any error to prevent app crashes
      return <ChatChannel>[];
    }
  }

  /// Create a new channel
  /// Note: Channel creation is not available in the current API
  Future<ChatChannel> createChannel(dynamic request) async {
    try {
      // Channel creation is not supported in the current API
      // Channels are handled implicitly through message recipients
      throw api_ex.ApiException(
        code: 'NOT_IMPLEMENTED',
        message: 'Channel creation not supported by current API. Channels are created implicitly through messaging.',
        statusCode: 501,
      );
    } catch (e) {
      throw api_ex.ApiException(
        code: 'CREATE_CHANNEL_ERROR',
        message: 'Failed to create channel: $e',
        statusCode: 500,
      );
    }
  }

  /// Join a channel
  /// Note: Channel management is handled through the messages API
  Future<void> joinChannel(String channelId) async {
    try {
      // Channel joining is not a separate endpoint in the current API
      // Channels are implicit based on message recipients
      throw api_ex.ApiException(
        code: 'NOT_IMPLEMENTED',
        message: 'Channel joining not supported by current API. Channels are created implicitly through messaging.',
        statusCode: 501,
      );
    } catch (e) {
      throw api_ex.ApiException(
        code: 'JOIN_ERROR',
        message: 'Failed to join channel: $e',
        statusCode: 500,
      );
    }
  }

  /// Leave a channel
  /// Note: Channel management is handled through the messages API
  Future<void> leaveChannel(String channelId) async {
    try {
      // Channel leaving is not a separate endpoint in the current API
      // Channels are implicit based on message recipients
      throw api_ex.ApiException(
        code: 'NOT_IMPLEMENTED',
        message: 'Channel leaving not supported by current API. Channels are created implicitly through messaging.',
        statusCode: 501,
      );
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
      // Use the users endpoint and filter for online users
      final response = await _httpClient.get<List<dynamic>>(
        '/users/',
        queryParameters: {'is_online': true},
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
        '/users/',
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
      // Since the API uses PUT /messages/{message_id}/read for individual messages,
      // we need to get the messages first and then mark them individually
      // For now, we'll use a batch approach if supported, or handle individual messages
      
      // Get messages to mark as read
      final messages = await getMessages(
        recipientId: recipientId,
        channelId: channelId,
      );
      
      // Mark each unread message as read
      for (final message in messages) {
        if (!message.isRead) {
          await _httpClient.put<void>('/messages/${message.id}/read');
        }
      }
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
      final queryParams = <String, dynamic>{
        'recipient_id': userId,
      };
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _httpClient.get<List<dynamic>>(
        '/messages/',
        queryParameters: queryParams,
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
      final queryParams = <String, dynamic>{
        'channel_id': channelId,
      };
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (since != null) queryParams['since'] = since.toIso8601String();

      final response = await _httpClient.get<List<dynamic>>(
        '/messages/',
        queryParameters: queryParams,
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
      await _httpClient.delete('/messages/$messageId');
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
  /// Note: This functionality is not available in the current API
  /// User status should be managed through WebSocket connections or other means
  Future<void> updateUserStatus(bool isOnline) async {
    try {
      // This endpoint is not available in the documented API
      // Consider using WebSocket connections for real-time status updates
      throw api_ex.ApiException(
        code: 'NOT_IMPLEMENTED',
        message: 'User status updates not supported by current API',
        statusCode: 501,
      );
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

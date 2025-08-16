import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../shared/models/message.dart';
import '../../../shared/services/messaging_service.dart';
import '../../../shared/services/websocket_service.dart';

// Chat messages notifier
class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final MessagingService _messagingService;
  final WebSocketService _webSocketService;
  final Ref _ref;
  
  String? _currentConversation; // Either 'user:123' or 'channel:abc'

  ChatMessagesNotifier(this._messagingService, this._webSocketService, this._ref) 
      : super(const AsyncValue.loading()) {
    _listenToWebSocketMessages();
  }

  void _listenToWebSocketMessages() {
    _webSocketService.messages.listen((wsMessage) {
      if (wsMessage.type == WebSocketMessageType.message) {
        final chatMessage = ChatMessage.fromJson(wsMessage.data);
        _addIncomingMessage(chatMessage);
      }
    });
  }

  void _addIncomingMessage(ChatMessage message) {
    final currentMessages = state.value;
    if (currentMessages != null) {
      final conversationId = message.isPrivateMessage
          ? 'user:${message.senderId}'
          : 'channel:${message.channelId}';
          
      // Only add if message belongs to current conversation
      if (_currentConversation == conversationId) {
        final updatedMessages = [message, ...currentMessages];
        state = AsyncValue.data(updatedMessages);
      }
    }
  }

  /// Load conversation with a user
  Future<void> loadUserConversation(int userId) async {
    _currentConversation = 'user:$userId';
    state = const AsyncValue.loading();
    
    try {
      final messages = await _messagingService.getConversationHistory(userId);
      state = AsyncValue.data(messages.reversed.toList());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Load messages for a channel
  Future<void> loadChannelMessages(String channelId) async {
    _currentConversation = 'channel:$channelId';
    state = const AsyncValue.loading();
    
    try {
      final messages = await _messagingService.getChannelMessages(channelId);
      state = AsyncValue.data(messages.reversed.toList());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Send a message to user
  Future<void> sendUserMessage({
    required int recipientId,
    required String content,
    String messageType = 'text',
    bool isEmergency = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final request = SendMessageRequest(
        content: content,
        recipientId: recipientId,
        type: 'private',
        messageType: messageType,
        isEmergency: isEmergency,
        metadata: metadata,
      );

      // Send via WebSocket for real-time delivery
      _webSocketService.sendChatMessage(
        content: content,
        recipientId: recipientId,
        type: 'private',
        messageType: messageType,
        isEmergency: isEmergency,
        metadata: metadata,
      );

      // Also send via HTTP for persistence
      final sentMessage = await _messagingService.sendMessage(request);
      
      // Add to local state
      final currentMessages = state.value ?? [];
      state = AsyncValue.data([sentMessage, ...currentMessages]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Send a message to channel
  Future<void> sendChannelMessage({
    required String channelId,
    required String content,
    String messageType = 'text',
    bool isEmergency = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final request = SendMessageRequest(
        content: content,
        channelId: channelId,
        type: 'channel',
        messageType: messageType,
        isEmergency: isEmergency,
        metadata: metadata,
      );

      // Send via WebSocket for real-time delivery
      _webSocketService.sendChatMessage(
        content: content,
        channelId: channelId,
        type: 'channel',
        messageType: messageType,
        isEmergency: isEmergency,
        metadata: metadata,
      );

      // Also send via HTTP for persistence
      final sentMessage = await _messagingService.sendMessage(request);
      
      // Add to local state
      final currentMessages = state.value ?? [];
      state = AsyncValue.data([sentMessage, ...currentMessages]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Clear current conversation
  void clearConversation() {
    _currentConversation = null;
    state = const AsyncValue.data([]);
  }

  /// Send typing indicator
  void sendTypingIndicator({int? recipientId, String? channelId, bool isTyping = true}) {
    _webSocketService.sendTypingIndicator(
      recipientId: recipientId,
      channelId: channelId,
      isTyping: isTyping,
    );
  }
}

// Provider for chat messages notifier
final chatMessagesNotifierProvider = StateNotifierProvider<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>>((ref) {
  final messagingService = ref.read(messagingServiceProvider);
  final webSocketService = ref.read(webSocketServiceProvider);
  return ChatMessagesNotifier(messagingService, webSocketService, ref);
});

// Chat channels notifier
class ChatChannelsNotifier extends StateNotifier<AsyncValue<List<ChatChannel>>> {
  final MessagingService _messagingService;
  final WebSocketService _webSocketService;
  final Ref _ref;

  ChatChannelsNotifier(this._messagingService, this._webSocketService, this._ref) 
      : super(const AsyncValue.loading()) {
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    try {
      final channels = await _messagingService.getChannels();
      state = AsyncValue.data(channels);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh channels
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadChannels();
  }

  /// Create a new channel
  Future<void> createChannel(CreateChannelRequest request) async {
    try {
      final newChannel = await _messagingService.createChannel(request);
      
      final currentChannels = state.value ?? [];
      state = AsyncValue.data([newChannel, ...currentChannels]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Join a channel
  Future<void> joinChannel(String channelId) async {
    try {
      await _messagingService.joinChannel(channelId);
      _webSocketService.joinChannel(channelId);
      
      // Refresh channels to get updated member list
      await refresh();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Leave a channel
  Future<void> leaveChannel(String channelId) async {
    try {
      await _messagingService.leaveChannel(channelId);
      _webSocketService.leaveChannel(channelId);
      
      // Remove from local state
      final currentChannels = state.value ?? [];
      final updatedChannels = currentChannels.where((c) => c.id != channelId).toList();
      state = AsyncValue.data(updatedChannels);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider for chat channels notifier
final chatChannelsNotifierProvider = StateNotifierProvider<ChatChannelsNotifier, AsyncValue<List<ChatChannel>>>((ref) {
  final messagingService = ref.read(messagingServiceProvider);
  final webSocketService = ref.read(webSocketServiceProvider);
  return ChatChannelsNotifier(messagingService, webSocketService, ref);
});

// Online users notifier
class OnlineUsersNotifier extends StateNotifier<AsyncValue<List<ChatUser>>> {
  final MessagingService _messagingService;
  final WebSocketService _webSocketService;
  final Ref _ref;

  OnlineUsersNotifier(this._messagingService, this._webSocketService, this._ref) 
      : super(const AsyncValue.loading()) {
    _loadOnlineUsers();
    _listenToUserStatusUpdates();
  }

  Future<void> _loadOnlineUsers() async {
    try {
      final users = await _messagingService.getOnlineUsers();
      state = AsyncValue.data(users);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void _listenToUserStatusUpdates() {
    _webSocketService.messages.listen((wsMessage) {
      if (wsMessage.type == WebSocketMessageType.userStatus) {
        final userId = wsMessage.data['user_id'] as int;
        final isOnline = wsMessage.data['is_online'] as bool;
        final lastSeen = wsMessage.data['last_seen'] != null
            ? DateTime.parse(wsMessage.data['last_seen'] as String)
            : null;

        _updateUserStatus(userId, isOnline, lastSeen);
      }
    });
  }

  void _updateUserStatus(int userId, bool isOnline, DateTime? lastSeen) {
    final currentUsers = state.value;
    if (currentUsers != null) {
      final updatedUsers = currentUsers.map((user) {
        if (user.id == userId) {
          return user.copyWith(isOnline: isOnline, lastSeen: lastSeen);
        }
        return user;
      }).toList();
      
      state = AsyncValue.data(updatedUsers);
    }
  }

  /// Refresh online users
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadOnlineUsers();
  }

  /// Update current user's status
  Future<void> updateStatus(bool isOnline) async {
    try {
      await _messagingService.updateUserStatus(isOnline);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider for online users notifier
final onlineUsersNotifierProvider = StateNotifierProvider<OnlineUsersNotifier, AsyncValue<List<ChatUser>>>((ref) {
  final messagingService = ref.read(messagingServiceProvider);
  final webSocketService = ref.read(webSocketServiceProvider);
  return OnlineUsersNotifier(messagingService, webSocketService, ref);
});

// All users provider (for selecting conversation recipients)
final allUsersProvider = FutureProvider<List<ChatUser>>((ref) async {
  final messagingService = ref.read(messagingServiceProvider);
  return messagingService.getAllUsers();
});

// Current conversation provider (tracks which conversation is active)
final currentConversationProvider = StateProvider<String?>((ref) => null);

// Typing indicators provider
final typingIndicatorsProvider = StateProvider<Map<String, bool>>((ref) => {});

// WebSocket message listener for typing indicators
final typingIndicatorListener = Provider<void>((ref) {
  final webSocketService = ref.read(webSocketServiceProvider);
  
  webSocketService.messages.listen((wsMessage) {
    if (wsMessage.type == WebSocketMessageType.typing) {
      final userId = wsMessage.data['user_id'] as String;
      final isTyping = wsMessage.data['is_typing'] as bool;
      
      final current = ref.read(typingIndicatorsProvider);
      ref.read(typingIndicatorsProvider.notifier).state = {
        ...current,
        userId: isTyping,
      };
      
      // Clear typing indicator after timeout
      if (isTyping) {
        Future.delayed(const Duration(seconds: 3), () {
          final updated = ref.read(typingIndicatorsProvider);
          if (updated[userId] == true) {
            ref.read(typingIndicatorsProvider.notifier).state = {
              ...updated,
              userId: false,
            };
          }
        });
      }
    }
  });
});
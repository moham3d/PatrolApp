import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/messaging_provider.dart';
import '../widgets/chat_sidebar_widget.dart';
import '../widgets/chat_conversation_widget.dart';
import '../widgets/chat_user_list_widget.dart';
import '../widgets/push_to_talk_widget.dart';
import '../widgets/communication_channels_widget.dart';
import '../../../shared/services/websocket_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/services/auth_service.dart';

/// Main real-time messaging page with sidebar and chat area
class RealTimeMessagingPage extends ConsumerStatefulWidget {
  const RealTimeMessagingPage({super.key});

  @override
  ConsumerState<RealTimeMessagingPage> createState() => _RealTimeMessagingPageState();
}

class _RealTimeMessagingPageState extends ConsumerState<RealTimeMessagingPage> {
  bool _showUserList = true;
  bool _showChannels = false;
  String? _selectedConversation;
  ConversationType _conversationType = ConversationType.none;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  void _initializeWebSocket() async {
    // Connect to WebSocket when page loads
    final authState = ref.read(authProvider);
    if (authState.isLoggedIn && authState.user != null) {
      final authService = ref.read(authServiceProvider);
      final webSocketService = ref.read(webSocketServiceProvider);
      final token = await authService.getCurrentToken();
      if (token != null) {
        webSocketService.connect(authState.user!.id, token);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final webSocketState = ref.watch(webSocketStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Messaging'),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          // WebSocket connection indicator
          webSocketState.when(
            data: (state) => _buildConnectionIndicator(state),
            loading: () => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => Icon(
              Icons.signal_wifi_off,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          
          // Toggle channels button
          IconButton(
            onPressed: () => setState(() => _showChannels = !_showChannels),
            icon: Icon(_showChannels ? Icons.forum : Icons.forum_outlined),
            tooltip: _showChannels ? 'Hide Channels' : 'Show Channels',
          ),
          
          // Toggle user list button
          IconButton(
            onPressed: () => setState(() => _showUserList = !_showUserList),
            icon: Icon(_showUserList ? Icons.people : Icons.people_outline),
            tooltip: _showUserList ? 'Hide User List' : 'Show User List',
          ),
          
          // Refresh button
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar with channels and conversations
          SizedBox(
            width: 280,
            child: ChatSidebarWidget(
              selectedConversation: _selectedConversation,
              onConversationSelected: (conversationId, type) {
                setState(() {
                  _selectedConversation = conversationId;
                  _conversationType = type;
                });
                _loadConversation(conversationId, type);
              },
            ),
          ),
          
          const VerticalDivider(width: 1),
          
          // Main chat area
          Expanded(
            child: _selectedConversation != null
                ? ChatConversationWidget(
                    conversationId: _selectedConversation!,
                    conversationType: _conversationType,
                  )
                : _buildEmptyChatState(),
          ),
          
          // Right sidebar with channels, user list, and push-to-talk
          if (_showChannels || _showUserList) ...[
            const VerticalDivider(width: 1),
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  // Channels section
                  if (_showChannels) ...[
                    Expanded(
                      flex: 2,
                      child: CommunicationChannelsWidget(
                        onChannelSelected: (channelId, channelName) {
                          final conversationId = 'channel:$channelId';
                          setState(() {
                            _selectedConversation = conversationId;
                            _conversationType = ConversationType.channel;
                          });
                          _loadConversation(conversationId, ConversationType.channel);
                        },
                      ),
                    ),
                    if (_showUserList) const Divider(),
                  ],
                  
                  // User list section
                  if (_showUserList) ...[
                    Expanded(
                      flex: _showChannels ? 1 : 2,
                      child: ChatUserListWidget(
                        onUserSelected: (userId) {
                          final conversationId = 'user:$userId';
                          setState(() {
                            _selectedConversation = conversationId;
                            _conversationType = ConversationType.private;
                          });
                          _loadConversation(conversationId, ConversationType.private);
                        },
                      ),
                    ),
                  ],
                  
                  // Push-to-talk section (always show when sidebar is visible)
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: PushToTalkWidget(
                      recipientId: _conversationType == ConversationType.private
                          ? _getRecipientIdFromConversation(_selectedConversation)
                          : null,
                      channelId: _conversationType == ConversationType.channel
                          ? _getChannelIdFromConversation(_selectedConversation)
                          : null,
                      onVoiceMessageSent: () {
                        // Optionally refresh the conversation
                        if (_selectedConversation != null) {
                          _loadConversation(_selectedConversation!, _conversationType);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator(WebSocketState state) {
    IconData icon;
    Color color;
    String tooltip;

    switch (state) {
      case WebSocketState.connected:
        icon = Icons.wifi;
        color = Colors.green;
        tooltip = 'Connected';
        break;
      case WebSocketState.connecting:
        icon = Icons.wifi_1_bar;
        color = Colors.orange;
        tooltip = 'Connecting...';
        break;
      case WebSocketState.reconnecting:
        icon = Icons.wifi_2_bar;
        color = Colors.orange;
        tooltip = 'Reconnecting...';
        break;
      case WebSocketState.disconnected:
        icon = Icons.wifi_off;
        color = Colors.grey;
        tooltip = 'Disconnected';
        break;
      case WebSocketState.error:
        icon = Icons.signal_wifi_off;
        color = Colors.red;
        tooltip = 'Connection Error';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a conversation to start messaging',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a channel or user from the sidebar to begin chatting.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _loadConversation(String conversationId, ConversationType type) {
    final chatMessagesNotifier = ref.read(chatMessagesNotifierProvider.notifier);
    
    if (type == ConversationType.private) {
      final userId = int.parse(conversationId.split(':')[1]);
      chatMessagesNotifier.loadUserConversation(userId);
    } else if (type == ConversationType.channel) {
      final channelId = conversationId.split(':')[1];
      chatMessagesNotifier.loadChannelMessages(channelId);
    }
    
    // Update current conversation provider
    ref.read(currentConversationProvider.notifier).state = conversationId;
  }

  void _refreshData() {
    ref.read(chatChannelsNotifierProvider.notifier).refresh();
    ref.read(onlineUsersNotifierProvider.notifier).refresh();
    ref.invalidate(allUsersProvider);
  }

  int? _getRecipientIdFromConversation(String? conversationId) {
    if (conversationId == null || !conversationId.startsWith('user:')) {
      return null;
    }
    try {
      return int.parse(conversationId.split(':')[1]);
    } catch (e) {
      return null;
    }
  }

  String? _getChannelIdFromConversation(String? conversationId) {
    if (conversationId == null || !conversationId.startsWith('channel:')) {
      return null;
    }
    return conversationId.split(':')[1];
  }
}

enum ConversationType {
  none,
  private,
  channel,
}
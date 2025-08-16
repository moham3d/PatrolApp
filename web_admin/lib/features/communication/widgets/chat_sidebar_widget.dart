import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/messaging_provider.dart';
import '../pages/real_time_messaging_page.dart';
import '../../../shared/models/message.dart';

/// Sidebar widget for chat channels and recent conversations
class ChatSidebarWidget extends ConsumerStatefulWidget {
  final String? selectedConversation;
  final Function(String conversationId, ConversationType type) onConversationSelected;

  const ChatSidebarWidget({
    super.key,
    this.selectedConversation,
    required this.onConversationSelected,
  });

  @override
  ConsumerState<ChatSidebarWidget> createState() => _ChatSidebarWidgetState();
}

class _ChatSidebarWidgetState extends ConsumerState<ChatSidebarWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with tabs
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Conversations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _showCreateChannelDialog,
                      icon: const Icon(Icons.add),
                      tooltip: 'Create Channel',
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Channels'),
                    Tab(text: 'Direct'),
                  ],
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChannelsList(),
                _buildDirectMessagesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelsList() {
    final channelsAsync = ref.watch(chatChannelsNotifierProvider);

    return channelsAsync.when(
      data: (channels) {
        if (channels.isEmpty) {
          return _buildEmptyState(
            icon: Icons.forum_outlined,
            title: 'No Channels',
            subtitle: 'Create a channel to start group conversations.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: channels.length,
          itemBuilder: (context, index) {
            final channel = channels[index];
            return _buildChannelTile(channel);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState('Failed to load channels'),
    );
  }

  Widget _buildDirectMessagesList() {
    final onlineUsersAsync = ref.watch(onlineUsersNotifierProvider);

    return onlineUsersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_outline,
            title: 'No Users Online',
            subtitle: 'No users are currently available for chat.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserTile(user);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState('Failed to load users'),
    );
  }

  Widget _buildChannelTile(ChatChannel channel) {
    final conversationId = 'channel:${channel.id}';
    final isSelected = widget.selectedConversation == conversationId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: channel.isEmergency
            ? Colors.red.shade100
            : channel.isPrivate
                ? Colors.orange.shade100
                : Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: channel.isEmergency
            ? Colors.red.shade800
            : channel.isPrivate
                ? Colors.orange.shade800
                : Theme.of(context).colorScheme.onPrimaryContainer,
        child: Icon(
          channel.isEmergency
              ? Icons.emergency
              : channel.isPrivate
                  ? Icons.lock
                  : Icons.tag,
          size: 20,
        ),
      ),
      title: Text(
        channel.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (channel.lastMessage != null) ...[
            Text(
              channel.lastMessage!.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              channel.lastMessage!.timeAgo,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ] else ...[
            Text(
              '${channel.memberNames.length} members',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
      trailing: channel.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${channel.unreadCount}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      selected: isSelected,
      onTap: () => widget.onConversationSelected(conversationId, ConversationType.channel),
    );
  }

  Widget _buildUserTile(ChatUser user) {
    final conversationId = 'user:${user.id}';
    final isSelected = widget.selectedConversation == conversationId;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            child: user.avatar != null
                ? ClipOval(
                    child: Image.network(
                      user.avatar!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      ),
                    ),
                  )
                : Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  ),
          ),
          if (user.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        user.statusText,
        style: TextStyle(
          fontSize: 12,
          color: user.isOnline
              ? Colors.green
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      selected: isSelected,
      onTap: () => widget.onConversationSelected(conversationId, ConversationType.private),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(chatChannelsNotifierProvider.notifier).refresh();
                ref.read(onlineUsersNotifierProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateChannelDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateChannelDialog(),
    );
  }
}

/// Dialog for creating a new chat channel
class CreateChannelDialog extends ConsumerStatefulWidget {
  const CreateChannelDialog({super.key});

  @override
  ConsumerState<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends ConsumerState<CreateChannelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _channelType = 'public';
  final List<int> _selectedMembers = [];
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);

    return AlertDialog(
      title: const Text('Create Channel'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Channel Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a channel name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _channelType,
                decoration: const InputDecoration(
                  labelText: 'Channel Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                  DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _channelType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Member selection (simplified for now)
              allUsersAsync.when(
                data: (users) => Text('${users.length} users available'),
                loading: () => const Text('Loading users...'),
                error: (_, __) => const Text('Error loading users'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isCreating ? null : _createChannel,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createChannel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final request = CreateChannelRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _channelType,
        members: _selectedMembers,
      );

      await ref.read(chatChannelsNotifierProvider.notifier).createChannel(request);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Channel created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create channel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
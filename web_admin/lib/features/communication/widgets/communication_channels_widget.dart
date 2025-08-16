import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/message.dart';
import '../providers/messaging_provider.dart';
import '../../users/providers/users_provider.dart';

/// Widget for managing communication channels
class CommunicationChannelsWidget extends ConsumerStatefulWidget {
  final Function(String channelId, String channelName)? onChannelSelected;

  const CommunicationChannelsWidget({
    super.key,
    this.onChannelSelected,
  });

  @override
  ConsumerState<CommunicationChannelsWidget> createState() => _CommunicationChannelsWidgetState();
}

class _CommunicationChannelsWidgetState extends ConsumerState<CommunicationChannelsWidget> {
  String? _selectedChannelId;

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(chatChannelsNotifierProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.forum, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Communication Channels',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _showCreateChannelDialog(),
                  tooltip: 'Create New Channel',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: channelsAsync.when(
                data: (channels) => _buildChannelsList(channels),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load channels'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(chatChannelsNotifierProvider),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelsList(List<ChatChannel> channels) {
    if (channels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No channels available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showCreateChannelDialog(),
              icon: Icon(Icons.add),
              label: Text('Create First Channel'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];
        final isSelected = _selectedChannelId == channel.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getChannelColor(channel.type),
              child: Icon(
                _getChannelIcon(channel.type),
                color: Colors.white,
              ),
            ),
            title: Text(
              channel.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channel.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${channel.members.length} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (channel.unreadCount > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${channel.unreadCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleChannelAction(value, channel),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'join',
                  child: Row(
                    children: [
                      Icon(Icons.login),
                      const SizedBox(width: 8),
                      Text('Join'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      const SizedBox(width: 8),
                      Text('Leave'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      const SizedBox(width: 8),
                      Text('Channel Info'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedChannelId = isSelected ? null : channel.id;
              });
              if (!isSelected) {
                widget.onChannelSelected?.call(channel.id, channel.name);
              }
            },
          ),
        );
      },
    );
  }

  Color _getChannelColor(String type) {
    switch (type) {
      case 'public':
        return Colors.blue;
      case 'private':
        return Colors.orange;
      case 'emergency':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getChannelIcon(String type) {
    switch (type) {
      case 'public':
        return Icons.public;
      case 'private':
        return Icons.lock;
      case 'emergency':
        return Icons.emergency;
      default:
        return Icons.forum;
    }
  }

  void _handleChannelAction(String action, ChatChannel channel) {
    final notifier = ref.read(chatChannelsNotifierProvider.notifier);

    switch (action) {
      case 'join':
        _joinChannel(channel.id);
        break;
      case 'leave':
        _showLeaveChannelConfirmation(channel);
        break;
      case 'info':
        _showChannelInfo(channel);
        break;
    }
  }

  void _joinChannel(String channelId) async {
    try {
      await ref.read(chatChannelsNotifierProvider.notifier).joinChannel(channelId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined channel')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join channel: $e')),
      );
    }
  }

  void _showLeaveChannelConfirmation(ChatChannel channel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Channel'),
        content: Text('Are you sure you want to leave "${channel.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _leaveChannel(channel.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _leaveChannel(String channelId) async {
    try {
      await ref.read(chatChannelsNotifierProvider.notifier).leaveChannel(channelId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully left channel')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave channel: $e')),
      );
    }
  }

  void _showChannelInfo(ChatChannel channel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(channel.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${channel.description}'),
            const SizedBox(height: 8),
            Text('Type: ${channel.type}'),
            const SizedBox(height: 8),
            Text('Members: ${channel.members.length}'),
            const SizedBox(height: 8),
            Text('Created: ${channel.createdAt.toString().split(' ')[0]}'),
            if (channel.memberNames.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Members:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...channel.memberNames.map((name) => Text('• $name')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateChannelDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'public';
    List<int> selectedMembers = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Create New Channel'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Channel Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Channel Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'public', child: Text('Public')),
                    DropdownMenuItem(value: 'private', child: Text('Private')),
                    DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: nameController.text.trim().isEmpty
                  ? null
                  : () {
                      _createChannel(
                        nameController.text.trim(),
                        descriptionController.text.trim(),
                        selectedType,
                        selectedMembers,
                      );
                      Navigator.of(context).pop();
                    },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _createChannel(String name, String description, String type, List<int> members) async {
    try {
      final request = CreateChannelRequest(
        name: name,
        description: description,
        type: type,
        members: members,
      );

      await ref.read(chatChannelsNotifierProvider.notifier).createChannel(request);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Channel "$name" created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create channel: $e')),
      );
    }
  }
}
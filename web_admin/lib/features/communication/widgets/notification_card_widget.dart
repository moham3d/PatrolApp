import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/notification.dart';

/// Widget for displaying individual notification cards
class NotificationCardWidget extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    this.onMarkAsRead,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead
          ? null
          : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority and type indicator
              _buildNotificationIcon(context),
              const SizedBox(width: 12),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          notification.getTimeAgo(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Message
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: notification.isRead
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags and actions
                    Row(
                      children: [
                        // Type tag
                        _buildTypeChip(context),
                        const SizedBox(width: 8),

                        // Priority tag
                        _buildPriorityChip(context),

                        const Spacer(),

                        // Action buttons
                        if (!notification.isRead && onMarkAsRead != null) ...[
                          IconButton(
                            onPressed: onMarkAsRead,
                            icon: const Icon(Icons.mark_email_read, size: 20),
                            tooltip: 'Mark as read',
                            iconSize: 20,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                        ],

                        if (onDelete != null) ...[
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Delete',
                            iconSize: 20,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    // Get icon based on type
    switch (notification.type.toLowerCase()) {
      case 'task_assignment':
        iconData = Icons.assignment;
        iconColor = Colors.blue;
        break;
      case 'patrol_update':
        iconData = Icons.route;
        iconColor = Colors.green;
        break;
      case 'incident_alert':
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'security_alert':
        iconData = Icons.security;
        iconColor = Colors.red;
        break;
      case 'system_update':
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Theme.of(context).colorScheme.primary;
    }

    // Adjust color based on priority
    switch (notification.priority.toLowerCase()) {
      case 'urgent':
        iconColor = Colors.red.shade700;
        break;
      case 'high':
        iconColor = Colors.orange.shade700;
        break;
      case 'low':
        iconColor = Colors.grey.shade600;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context) {
    String displayType;
    switch (notification.type.toLowerCase()) {
      case 'task_assignment':
        displayType = 'Task';
        break;
      case 'patrol_update':
        displayType = 'Patrol';
        break;
      case 'incident_alert':
        displayType = 'Incident';
        break;
      case 'security_alert':
        displayType = 'Security';
        break;
      case 'system_update':
        displayType = 'System';
        break;
      default:
        displayType = notification.type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayType,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (notification.priority.toLowerCase()) {
      case 'urgent':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'high':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'normal':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'low':
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        break;
      default:
        backgroundColor = Theme.of(context).colorScheme.surfaceVariant;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        notification.priority.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
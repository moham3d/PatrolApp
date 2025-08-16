import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/notification_provider.dart';
import '../widgets/notification_filters_widget.dart';
import '../widgets/notification_card_widget.dart';
import '../widgets/notification_stats_widget.dart';
import '../../../shared/models/notification.dart';

/// Main page for notification management
class NotificationManagementPage extends ConsumerStatefulWidget {
  const NotificationManagementPage({super.key});

  @override
  ConsumerState<NotificationManagementPage> createState() =>
      _NotificationManagementPageState();
}

class _NotificationManagementPageState
    extends ConsumerState<NotificationManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Management'),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          // Filter toggle button
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
          ),
          // Mark all as read button
          Consumer(
            builder: (context, ref, child) {
              final unreadCountAsync = ref.watch(unreadNotificationCountNotifierProvider);
              return unreadCountAsync.when(
                data: (count) => count > 0
                    ? IconButton(
                        onPressed: () => _markAllAsRead(ref),
                        icon: const Icon(Icons.mark_email_read),
                        tooltip: 'Mark All as Read',
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          // Refresh button
          IconButton(
            onPressed: () => _refreshNotifications(ref),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.notifications_outlined),
              text: 'All Notifications',
              child: Consumer(
                builder: (context, ref, child) {
                  final notificationsAsync = ref.watch(notificationsNotifierProvider);
                  return notificationsAsync.when(
                    data: (notifications) => notifications.isNotEmpty
                        ? Badge(
                            label: Text('${notifications.length}'),
                            child: const Tab(
                              icon: Icon(Icons.notifications_outlined),
                              text: 'All Notifications',
                            ),
                          )
                        : const Tab(
                            icon: Icon(Icons.notifications_outlined),
                            text: 'All Notifications',
                          ),
                    loading: () => const Tab(
                      icon: Icon(Icons.notifications_outlined),
                      text: 'All Notifications',
                    ),
                    error: (_, __) => const Tab(
                      icon: Icon(Icons.notifications_outlined),
                      text: 'All Notifications',
                    ),
                  );
                },
              ),
            ),
            Tab(
              icon: const Icon(Icons.mark_email_unread_outlined),
              text: 'Unread',
              child: Consumer(
                builder: (context, ref, child) {
                  final unreadCountAsync = ref.watch(unreadNotificationCountNotifierProvider);
                  return unreadCountAsync.when(
                    data: (count) => count > 0
                        ? Badge(
                            label: Text('$count'),
                            child: const Tab(
                              icon: Icon(Icons.mark_email_unread_outlined),
                              text: 'Unread',
                            ),
                          )
                        : const Tab(
                            icon: Icon(Icons.mark_email_unread_outlined),
                            text: 'Unread',
                          ),
                    loading: () => const Tab(
                      icon: Icon(Icons.mark_email_unread_outlined),
                      text: 'Unread',
                    ),
                    error: (_, __) => const Tab(
                      icon: Icon(Icons.mark_email_unread_outlined),
                      text: 'Unread',
                    ),
                  );
                },
              ),
            ),
            const Tab(
              icon: Icon(Icons.analytics_outlined),
              text: 'Statistics',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filters section
          if (_showFilters) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: NotificationFiltersWidget(
                onFiltersChanged: (filters) => _applyFilters(ref, filters),
                onClearFilters: () => _clearFilters(ref),
              ),
            ),
          ],

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All notifications tab
                _buildNotificationsList(ref, showAll: true),
                
                // Unread notifications tab
                _buildNotificationsList(ref, showAll: false),
                
                // Statistics tab
                const NotificationStatsWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(WidgetRef ref, {required bool showAll}) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    return notificationsAsync.when(
      data: (notifications) {
        // Filter notifications based on tab
        final filteredNotifications = showAll
            ? notifications
            : notifications.where((n) => !n.isRead).toList();

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState(showAll);
        }

        return RefreshIndicator(
          onRefresh: () => _refreshNotifications(ref),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return NotificationCardWidget(
                notification: notification,
                onMarkAsRead: () => _markAsRead(ref, notification.id),
                onDelete: () => _deleteNotification(ref, notification.id),
                onTap: () => _handleNotificationTap(notification),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(ref, error),
    );
  }

  Widget _buildEmptyState(bool showAll) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showAll ? Icons.notifications_none : Icons.mark_email_read_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            showAll ? 'No Notifications' : 'No Unread Notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            showAll
                ? 'You don\'t have any notifications yet.'
                : 'All notifications have been read.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
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
            'Failed to load notifications',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _refreshNotifications(ref),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshNotifications(WidgetRef ref) async {
    await ref.read(notificationsNotifierProvider.notifier).refresh();
    await ref.read(unreadNotificationCountNotifierProvider.notifier).refresh();
    await ref.read(notificationStatsNotifierProvider.notifier).refresh();
  }

  Future<void> _markAsRead(WidgetRef ref, int notificationId) async {
    try {
      await ref.read(notificationsNotifierProvider.notifier).markAsRead(notificationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification marked as read'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead(WidgetRef ref) async {
    try {
      await ref.read(notificationsNotifierProvider.notifier).markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(WidgetRef ref, int notificationId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(notificationsNotifierProvider.notifier).deleteNotification(notificationId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete notification: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _applyFilters(WidgetRef ref, NotificationFilters filters) async {
    await ref.read(filteredNotificationsNotifierProvider.notifier).applyFilters(filters);
  }

  Future<void> _clearFilters(WidgetRef ref) async {
    await ref.read(filteredNotificationsNotifierProvider.notifier).clearFilters();
  }

  void _handleNotificationTap(AppNotification notification) {
    // Handle notification tap based on type and data
    final data = notification.data;
    if (data != null) {
      // Navigate to relevant page based on notification type
      switch (notification.type.toLowerCase()) {
        case 'task_assignment':
          if (data.containsKey('task_id')) {
            // Navigate to patrol details
            // Navigator.of(context).push(...);
          }
          break;
        case 'patrol_update':
          if (data.containsKey('patrol_id')) {
            // Navigate to patrol page
          }
          break;
        case 'incident_alert':
          if (data.containsKey('incident_id')) {
            // Navigate to incident details
          }
          break;
        default:
          // Show notification details dialog
          _showNotificationDetails(notification);
      }
    } else {
      _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat.yMMMd().add_jm().format(notification.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.label,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  notification.type.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
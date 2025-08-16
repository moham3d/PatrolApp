import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../shared/models/notification.dart';
import '../../../shared/services/notification_service.dart';

// Simple provider without code generation for now
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.getNotifications();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.getUnreadCount();
});

final notificationStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.getNotificationStats();
});

// Filtered notifications state provider
final filteredNotificationsProvider = StateProvider<List<AppNotification>>((ref) => []);

// Notifications notifier class for managing state
class NotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationService _service;
  final Ref _ref;

  NotificationsNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _service.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadNotifications();
  }

  /// Get notifications with filters
  Future<void> getNotificationsWithFilters(NotificationFilters filters) async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _service.getNotifications(filters: filters);
      state = AsyncValue.data(notifications);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _service.markAsRead(notificationId);

      // Update local state
      final currentState = state.value;
      if (currentState != null) {
        final updatedNotifications = currentState.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        state = AsyncValue.data(updatedNotifications);
      }

      // Refresh unread count
      _ref.invalidate(unreadNotificationCountProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();

      // Update local state
      final currentState = state.value;
      if (currentState != null) {
        final updatedNotifications = currentState.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        state = AsyncValue.data(updatedNotifications);
      }

      // Refresh unread count
      _ref.invalidate(unreadNotificationCountProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _service.deleteNotification(notificationId);

      // Update local state
      final currentState = state.value;
      if (currentState != null) {
        final updatedNotifications = currentState
            .where((notification) => notification.id != notificationId)
            .toList();
        state = AsyncValue.data(updatedNotifications);
      }

      // Refresh unread count
      _ref.invalidate(unreadNotificationCountProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add a new notification (for real-time updates)
  void addNotification(AppNotification notification) {
    final currentState = state.value;
    if (currentState != null) {
      final updatedNotifications = [notification, ...currentState];
      state = AsyncValue.data(updatedNotifications);
      
      // Refresh unread count
      _ref.invalidate(unreadNotificationCountProvider);
    }
  }
}

// Provider for the notifications notifier
final notificationsNotifierProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<AppNotification>>>((ref) {
  final service = ref.read(notificationServiceProvider);
  return NotificationsNotifier(service, ref);
});

// Unread count notifier
class UnreadNotificationCountNotifier extends StateNotifier<AsyncValue<int>> {
  final NotificationService _service;

  UnreadNotificationCountNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _service.getUnreadCount();
      state = AsyncValue.data(count);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Increment unread count (for real-time updates)
  void increment() {
    final currentCount = state.value ?? 0;
    state = AsyncValue.data(currentCount + 1);
  }

  /// Decrement unread count
  void decrement() {
    final currentCount = state.value ?? 0;
    if (currentCount > 0) {
      state = AsyncValue.data(currentCount - 1);
    }
  }

  /// Reset unread count
  void reset() {
    state = const AsyncValue.data(0);
  }

  /// Refresh unread count
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadUnreadCount();
  }
}

// Provider for unread count notifier
final unreadNotificationCountNotifierProvider = StateNotifierProvider<UnreadNotificationCountNotifier, AsyncValue<int>>((ref) {
  final service = ref.read(notificationServiceProvider);
  return UnreadNotificationCountNotifier(service);
});

// Notification stats notifier
class NotificationStatsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final NotificationService _service;

  NotificationStatsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _service.getNotificationStats();
      state = AsyncValue.data(stats);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh stats
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadStats();
  }
}

// Provider for notification stats notifier
final notificationStatsNotifierProvider = StateNotifierProvider<NotificationStatsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final service = ref.read(notificationServiceProvider);
  return NotificationStatsNotifier(service);
});

// Filtered notifications notifier
class FilteredNotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationService _service;
  final Ref _ref;
  NotificationFilters? _currentFilters;

  FilteredNotificationsNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    // Start with all notifications
    _loadAllNotifications();
  }

  Future<void> _loadAllNotifications() async {
    try {
      final notifications = await _service.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Apply filters to notifications
  Future<void> applyFilters(NotificationFilters filters) async {
    _currentFilters = filters;
    state = const AsyncValue.loading();
    
    try {
      final notifications = await _service.getNotifications(filters: filters);
      state = AsyncValue.data(notifications);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Clear filters
  Future<void> clearFilters() async {
    _currentFilters = null;
    await _loadAllNotifications();
  }

  /// Get current filters
  NotificationFilters? get currentFilters => _currentFilters;
}

// Provider for filtered notifications
final filteredNotificationsNotifierProvider = StateNotifierProvider<FilteredNotificationsNotifier, AsyncValue<List<AppNotification>>>((ref) {
  final service = ref.read(notificationServiceProvider);
  return FilteredNotificationsNotifier(service, ref);
});
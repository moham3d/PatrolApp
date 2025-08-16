import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final String priority; // 'low', 'normal', 'high', 'urgent'
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  AppNotification copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    String? priority,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  // Helper method to get priority color
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return '#F44336'; // Red
      case 'high':
        return '#FF9800'; // Orange
      case 'normal':
        return '#2196F3'; // Blue
      case 'low':
        return '#4CAF50'; // Green
      default:
        return '#757575'; // Grey
    }
  }

  // Helper method to get type icon
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'task_assignment':
        return 'assignment';
      case 'patrol_update':
        return 'route';
      case 'incident_alert':
        return 'warning';
      case 'system_update':
        return 'info';
      case 'security_alert':
        return 'security';
      default:
        return 'notifications';
    }
  }

  // Helper method to get readable time ago
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// Request models for notifications
@JsonSerializable()
class MarkNotificationReadRequest {
  @JsonKey(name: 'notification_id')
  final int notificationId;

  const MarkNotificationReadRequest({
    required this.notificationId,
  });

  factory MarkNotificationReadRequest.fromJson(Map<String, dynamic> json) =>
      _$MarkNotificationReadRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MarkNotificationReadRequestToJson(this);
}

@JsonSerializable()
class NotificationFilters {
  final String? type;
  final String? priority;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  const NotificationFilters({
    this.type,
    this.priority,
    this.isRead,
    this.startDate,
    this.endDate,
  });

  factory NotificationFilters.fromJson(Map<String, dynamic> json) =>
      _$NotificationFiltersFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationFiltersToJson(this);

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    
    if (type != null) params['type'] = type;
    if (priority != null) params['priority'] = priority;
    if (isRead != null) params['is_read'] = isRead;
    if (startDate != null) params['start_date'] = startDate!.toIso8601String();
    if (endDate != null) params['end_date'] = endDate!.toIso8601String();
    
    return params;
  }
}
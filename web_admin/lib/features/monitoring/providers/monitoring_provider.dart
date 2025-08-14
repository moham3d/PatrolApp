import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/websocket_service.dart';
import '../../../shared/models/user.dart';
import '../../../core/services/http_client.dart';

/// Live patrol location model
class LivePatrolLocation {
  final int patrolId;
  final String patrolName;
  final double latitude;
  final double longitude;
  final DateTime lastUpdate;
  final String status;
  final User? assignedGuard;

  const LivePatrolLocation({
    required this.patrolId,
    required this.patrolName,
    required this.latitude,
    required this.longitude,
    required this.lastUpdate,
    required this.status,
    this.assignedGuard,
  });

  factory LivePatrolLocation.fromJson(Map<String, dynamic> json) {
    return LivePatrolLocation(
      patrolId: json['patrol_id'] ?? 0,
      patrolName: json['patrol_name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      lastUpdate: DateTime.parse(json['last_update'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'unknown',
      assignedGuard: json['assigned_guard'] != null 
          ? User.fromJson(json['assigned_guard'])
          : null,
    );
  }
}

/// Live guard location model
class LiveGuardLocation {
  final int guardId;
  final String guardName;
  final double latitude;
  final double longitude;
  final DateTime lastUpdate;
  final String status;
  final int? currentPatrolId;

  const LiveGuardLocation({
    required this.guardId,
    required this.guardName,
    required this.latitude,
    required this.longitude,
    required this.lastUpdate,
    required this.status,
    this.currentPatrolId,
  });

  factory LiveGuardLocation.fromJson(Map<String, dynamic> json) {
    return LiveGuardLocation(
      guardId: json['guard_id'] ?? 0,
      guardName: json['guard_name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      lastUpdate: DateTime.parse(json['last_update'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'offline',
      currentPatrolId: json['current_patrol_id'],
    );
  }
}

/// System health metrics model
class SystemHealthMetrics {
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int activeConnections;
  final int activePatrols;
  final int onlineGuards;
  final DateTime lastUpdate;

  const SystemHealthMetrics({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.activeConnections,
    required this.activePatrols,
    required this.onlineGuards,
    required this.lastUpdate,
  });

  factory SystemHealthMetrics.fromJson(Map<String, dynamic> json) {
    return SystemHealthMetrics(
      cpuUsage: (json['cpu_usage'] ?? 0.0).toDouble(),
      memoryUsage: (json['memory_usage'] ?? 0.0).toDouble(),
      diskUsage: (json['disk_usage'] ?? 0.0).toDouble(),
      activeConnections: json['active_connections'] ?? 0,
      activePatrols: json['active_patrols'] ?? 0,
      onlineGuards: json['online_guards'] ?? 0,
      lastUpdate: DateTime.parse(json['last_update'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Live alerts model
class LiveAlert {
  final int id;
  final String type;
  final String title;
  final String message;
  final String severity;
  final DateTime timestamp;
  final Map<String, dynamic>? location;
  final String? userId;
  final String? userName;
  final bool acknowledged;

  const LiveAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.location,
    this.userId,
    this.userName,
    this.acknowledged = false,
  });

  factory LiveAlert.fromJson(Map<String, dynamic> json) {
    return LiveAlert(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'notification',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'info',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      location: json['location'],
      userId: json['user_id']?.toString(),
      userName: json['user_name'],
      acknowledged: json['acknowledged'] ?? false,
    );
  }
}

/// Monitoring state notifier
class MonitoringNotifier extends StateNotifier<AsyncValue<void>> {
  MonitoringNotifier(this._httpClient) : super(const AsyncValue.data(null));

  final HttpClient _httpClient;
  List<LivePatrolLocation> _livePatrols = [];
  List<LiveGuardLocation> _guardLocations = [];
  List<LiveAlert> _liveAlerts = [];
  SystemHealthMetrics? _systemHealth;

  List<LivePatrolLocation> get livePatrols => _livePatrols;
  List<LiveGuardLocation> get guardLocations => _guardLocations;
  List<LiveAlert> get liveAlerts => _liveAlerts;
  SystemHealthMetrics? get systemHealth => _systemHealth;

  /// Fetch active patrols with real-time location data
  Future<void> fetchLivePatrols() async {
    try {
      final response = await _httpClient.get('/live/patrols/active');
      if (response.data != null) {
        final List<dynamic> patrolsData = response.data as List<dynamic>;
        _livePatrols = patrolsData
            .map((data) => LivePatrolLocation.fromJson(data))
            .toList();
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Fetch guard locations
  Future<void> fetchGuardLocations() async {
    try {
      final response = await _httpClient.get('/live/guards/locations');
      if (response.data != null) {
        final List<dynamic> locationsData = response.data as List<dynamic>;
        _guardLocations = locationsData
            .map((data) => LiveGuardLocation.fromJson(data))
            .toList();
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Fetch system health metrics
  Future<void> fetchSystemHealth() async {
    try {
      final response = await _httpClient.get('/live/system/health');
      if (response.data != null) {
        _systemHealth = SystemHealthMetrics.fromJson(response.data);
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Handle WebSocket message updates
  void handleWebSocketMessage(WebSocketMessage message) {
    switch (message.type) {
      case WebSocketMessageType.patrolUpdate:
        _updatePatrolLocation(message.data);
        break;
      case WebSocketMessageType.guardLocation:
        _updateGuardLocation(message.data);
        break;
      case WebSocketMessageType.notification:
      case WebSocketMessageType.emergencyAlert:
        _addLiveAlert(message.data, message.type);
        break;
      case WebSocketMessageType.systemHealth:
        _updateSystemHealth(message.data);
        break;
    }
  }

  void _updatePatrolLocation(Map<String, dynamic> data) {
    final updatedPatrol = LivePatrolLocation.fromJson(data);
    final index = _livePatrols.indexWhere((p) => p.patrolId == updatedPatrol.patrolId);
    
    if (index >= 0) {
      _livePatrols[index] = updatedPatrol;
    } else {
      _livePatrols.add(updatedPatrol);
    }
    
    state = const AsyncValue.data(null);
  }

  void _updateGuardLocation(Map<String, dynamic> data) {
    final updatedGuard = LiveGuardLocation.fromJson(data);
    final index = _guardLocations.indexWhere((g) => g.guardId == updatedGuard.guardId);
    
    if (index >= 0) {
      _guardLocations[index] = updatedGuard;
    } else {
      _guardLocations.add(updatedGuard);
    }
    
    state = const AsyncValue.data(null);
  }

  void _addLiveAlert(Map<String, dynamic> data, WebSocketMessageType type) {
    final alert = LiveAlert.fromJson({
      ...data,
      'type': type == WebSocketMessageType.emergencyAlert ? 'emergency' : 'notification',
      'severity': type == WebSocketMessageType.emergencyAlert ? 'critical' : 'info',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _liveAlerts.insert(0, alert); // Add to beginning for latest first
    
    // Keep only the latest 100 alerts
    if (_liveAlerts.length > 100) {
      _liveAlerts = _liveAlerts.take(100).toList();
    }
    
    state = const AsyncValue.data(null);
  }

  void _updateSystemHealth(Map<String, dynamic> data) {
    _systemHealth = SystemHealthMetrics.fromJson(data);
    state = const AsyncValue.data(null);
  }

  /// Acknowledge an alert
  Future<void> acknowledgeAlert(int alertId) async {
    final index = _liveAlerts.indexWhere((alert) => alert.id == alertId);
    if (index >= 0) {
      // Update local state immediately for better UX
      _liveAlerts[index] = LiveAlert(
        id: _liveAlerts[index].id,
        type: _liveAlerts[index].type,
        title: _liveAlerts[index].title,
        message: _liveAlerts[index].message,
        severity: _liveAlerts[index].severity,
        timestamp: _liveAlerts[index].timestamp,
        location: _liveAlerts[index].location,
        userId: _liveAlerts[index].userId,
        userName: _liveAlerts[index].userName,
        acknowledged: true,
      );
      state = const AsyncValue.data(null);
    }
  }
}

/// Providers
final monitoringProvider = StateNotifierProvider<MonitoringNotifier, AsyncValue<void>>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return MonitoringNotifier(httpClient);
});

final livePatrolsProvider = Provider<List<LivePatrolLocation>>((ref) {
  final monitoring = ref.watch(monitoringProvider.notifier);
  return monitoring.livePatrols;
});

final guardLocationsProvider = Provider<List<LiveGuardLocation>>((ref) {
  final monitoring = ref.watch(monitoringProvider.notifier);
  return monitoring.guardLocations;
});

final liveAlertsProvider = Provider<List<LiveAlert>>((ref) {
  final monitoring = ref.watch(monitoringProvider.notifier);
  return monitoring.liveAlerts;
});

final systemHealthProvider = Provider<SystemHealthMetrics?>((ref) {
  final monitoring = ref.watch(monitoringProvider.notifier);
  return monitoring.systemHealth;
});
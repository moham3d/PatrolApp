import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config/app_config.dart';

/// WebSocket message types based on API documentation
enum WebSocketMessageType {
  notification,
  emergencyAlert,
  patrolUpdate,
  guardLocation,
  systemHealth,
}

/// WebSocket message model
class WebSocketMessage {
  final WebSocketMessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const WebSocketMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    WebSocketMessageType messageType;
    
    switch (typeString) {
      case 'notification':
        messageType = WebSocketMessageType.notification;
        break;
      case 'emergency_alert':
        messageType = WebSocketMessageType.emergencyAlert;
        break;
      case 'patrol_update':
        messageType = WebSocketMessageType.patrolUpdate;
        break;
      case 'guard_location':
        messageType = WebSocketMessageType.guardLocation;
        break;
      case 'system_health':
        messageType = WebSocketMessageType.systemHealth;
        break;
      default:
        messageType = WebSocketMessageType.notification;
    }

    return WebSocketMessage(
      type: messageType,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// WebSocket connection states
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket service for real-time communication
class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<WebSocketMessage> _messageController = 
      StreamController<WebSocketMessage>.broadcast();
  final StreamController<WebSocketState> _stateController = 
      StreamController<WebSocketState>.broadcast();
  
  WebSocketState _currentState = WebSocketState.disconnected;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  // Streams
  Stream<WebSocketMessage> get messages => _messageController.stream;
  Stream<WebSocketState> get connectionState => _stateController.stream;
  WebSocketState get currentState => _currentState;

  /// Connect to WebSocket with user authentication
  Future<void> connect(int userId, String token) async {
    if (_currentState == WebSocketState.connected || 
        _currentState == WebSocketState.connecting) {
      return;
    }

    _updateState(WebSocketState.connecting);
    
    try {
      final wsUrl = '${AppConfig.wsBaseUrl}/ws/$userId?token=$token';
      final uri = Uri.parse(wsUrl);
      
      _channel = WebSocketChannel.connect(uri);
      
      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      _updateState(WebSocketState.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
      
    } catch (e) {
      _updateState(WebSocketState.error);
      _scheduleReconnect(userId, token);
    }
  }

  /// Send message to WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (_currentState == WebSocketState.connected && _channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message as String) as Map<String, dynamic>;
      final webSocketMessage = WebSocketMessage.fromJson(data);
      _messageController.add(webSocketMessage);
    } catch (e) {
      // Log error but don't break connection for malformed messages
      print('WebSocket message parsing error: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _updateState(WebSocketState.error);
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    _updateState(WebSocketState.disconnected);
    _stopHeartbeat();
    
    // Auto-reconnect if not manually disconnected
    if (_reconnectAttempts < _maxReconnectAttempts) {
      // Note: Would need to store user credentials for reconnection
      // For now, just update state
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect(int userId, String token) {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _updateState(WebSocketState.error);
      return;
    }

    _reconnectAttempts++;
    _updateState(WebSocketState.reconnecting);
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      connect(userId, token);
    });
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_currentState == WebSocketState.connected) {
        sendMessage({
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Update connection state and notify listeners
  void _updateState(WebSocketState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _channel?.sink.close();
    _updateState(WebSocketState.disconnected);
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _stateController.close();
  }
}

/// WebSocket service provider
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// WebSocket state provider
final webSocketStateProvider = StreamProvider<WebSocketState>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.connectionState;
});

/// WebSocket messages provider
final webSocketMessagesProvider = StreamProvider<WebSocketMessage>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.messages;
});
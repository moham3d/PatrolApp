import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/monitoring_provider.dart';
import '../../../shared/services/websocket_service.dart';

/// Live alerts feed widget with real-time updates
class LiveAlertsFeed extends ConsumerStatefulWidget {
  const LiveAlertsFeed({super.key});

  @override
  ConsumerState<LiveAlertsFeed> createState() => _LiveAlertsFeedState();
}

class _LiveAlertsFeedState extends ConsumerState<LiveAlertsFeed> {
  @override
  void initState() {
    super.initState();
    _setupWebSocketListener();
  }

  /// Set up WebSocket listener for real-time alerts
  void _setupWebSocketListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AsyncValue<WebSocketMessage>>(
        webSocketMessagesProvider,
        (previous, next) {
          next.whenData((message) {
            // Forward WebSocket messages to monitoring provider
            ref.read(monitoringProvider.notifier).handleWebSocketMessage(message);
            
            // Show system notification for critical alerts
            if (message.type == WebSocketMessageType.emergencyAlert) {
              _showCriticalAlertNotification(message);
            }
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(liveAlertsProvider);
    
    if (alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No alerts at this time',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Alerts header with filters
        _buildAlertsHeader(),
        const SizedBox(height: 8),
        
        // Alerts list
        Expanded(
          child: ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertCard(alert);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsHeader() {
    final alerts = ref.watch(liveAlertsProvider);
    final unacknowledgedCount = alerts.where((alert) => !alert.acknowledged).length;
    
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Live Alerts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unacknowledgedCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unacknowledgedCount new',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter Alerts',
          onSelected: _handleFilterSelection,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'all',
              child: Text('All Alerts'),
            ),
            const PopupMenuItem(
              value: 'unacknowledged',
              child: Text('Unacknowledged Only'),
            ),
            const PopupMenuItem(
              value: 'emergency',
              child: Text('Emergency Only'),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Text('Clear All'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertCard(LiveAlert alert) {
    Color cardColor;
    Color iconColor;
    IconData alertIcon;
    
    switch (alert.severity.toLowerCase()) {
      case 'critical':
      case 'emergency':
        cardColor = Colors.red.shade50;
        iconColor = Colors.red;
        alertIcon = Icons.warning;
        break;
      case 'high':
        cardColor = Colors.orange.shade50;
        iconColor = Colors.orange;
        alertIcon = Icons.priority_high;
        break;
      case 'medium':
        cardColor = Colors.yellow.shade50;
        iconColor = Colors.yellow.shade700;
        alertIcon = Icons.info;
        break;
      case 'low':
      case 'info':
      default:
        cardColor = Colors.blue.shade50;
        iconColor = Colors.blue;
        alertIcon = Icons.info_outline;
    }

    return Card(
      color: alert.acknowledged ? Colors.grey.shade100 : cardColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            alertIcon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                alert.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: alert.acknowledged ? Colors.grey : null,
                ),
              ),
            ),
            if (alert.acknowledged)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.message,
              style: TextStyle(
                color: alert.acknowledged ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(alert.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (alert.userName != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.person,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    alert.userName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: alert.acknowledged 
            ? null 
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleAlertAction(value, alert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'acknowledge',
                    child: Row(
                      children: [
                        Icon(Icons.check),
                        SizedBox(width: 8),
                        Text('Acknowledge'),
                      ],
                    ),
                  ),
                  if (alert.type == 'emergency')
                    const PopupMenuItem(
                      value: 'respond',
                      child: Row(
                        children: [
                          Icon(Icons.emergency, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Respond'),
                        ],
                      ),
                    ),
                  if (alert.location != null)
                    const PopupMenuItem(
                      value: 'locate',
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 8),
                          Text('Show Location'),
                        ],
                      ),
                    ),
                ],
              ),
        onTap: () => _showAlertDetails(alert),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  void _handleFilterSelection(String filter) {
    switch (filter) {
      case 'all':
        // Show all alerts (default behavior)
        break;
      case 'unacknowledged':
        // Filter to show only unacknowledged alerts
        // This would require updating the provider to support filtering
        break;
      case 'emergency':
        // Filter to show only emergency alerts
        break;
      case 'clear':
        _showClearAlertsDialog();
        break;
    }
  }

  void _handleAlertAction(String action, LiveAlert alert) {
    switch (action) {
      case 'acknowledge':
        ref.read(monitoringProvider.notifier).acknowledgeAlert(alert.id);
        _showSnackBar('Alert acknowledged');
        break;
      case 'respond':
        _initiateEmergencyResponse(alert);
        break;
      case 'locate':
        _showLocationOnMap(alert);
        break;
    }
  }

  void _showAlertDetails(LiveAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              alert.severity == 'critical' ? Icons.warning : Icons.info,
              color: alert.severity == 'critical' ? Colors.red : Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(alert.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            const SizedBox(height: 16),
            _detailRow('Type', alert.type.toUpperCase()),
            _detailRow('Severity', alert.severity.toUpperCase()),
            _detailRow('Time', alert.timestamp.toString()),
            if (alert.userName != null)
              _detailRow('User', alert.userName!),
            if (alert.location != null)
              _detailRow('Location', 
                '${alert.location!['latitude']}, ${alert.location!['longitude']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!alert.acknowledged)
            ElevatedButton(
              onPressed: () {
                ref.read(monitoringProvider.notifier).acknowledgeAlert(alert.id);
                Navigator.pop(context);
                _showSnackBar('Alert acknowledged');
              },
              child: const Text('Acknowledge'),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showCriticalAlertNotification(WebSocketMessage message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'EMERGENCY ALERT: ${message.data['title'] ?? 'Critical situation detected'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to specific alert or show details
          },
        ),
      ),
    );
  }

  void _showClearAlertsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Alerts'),
        content: const Text('Are you sure you want to clear all alerts? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear all alerts - would need to implement in provider
              Navigator.pop(context);
              _showSnackBar('All alerts cleared');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _initiateEmergencyResponse(LiveAlert alert) {
    // Placeholder for emergency response workflow
    _showSnackBar('Emergency response initiated for ${alert.title}');
  }

  void _showLocationOnMap(LiveAlert alert) {
    // Placeholder for showing location on map
    _showSnackBar('Location shown on map');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
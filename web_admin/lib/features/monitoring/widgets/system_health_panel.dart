import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/monitoring_provider.dart';

/// System health panel widget with real-time metrics
class SystemHealthPanel extends ConsumerStatefulWidget {
  const SystemHealthPanel({super.key});

  @override
  ConsumerState<SystemHealthPanel> createState() => _SystemHealthPanelState();
}

class _SystemHealthPanelState extends ConsumerState<SystemHealthPanel> {
  @override
  void initState() {
    super.initState();
    _fetchSystemHealth();
  }

  void _fetchSystemHealth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(monitoringProvider.notifier).fetchSystemHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final systemHealth = ref.watch(systemHealthProvider);
    
    if (systemHealth == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading system health...'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(monitoringProvider.notifier).fetchSystemHealth();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall health status
            _buildOverallHealthCard(systemHealth),
            const SizedBox(height: 16),
            
            // Resource usage metrics
            _buildResourceMetrics(systemHealth),
            const SizedBox(height: 16),
            
            // System activity metrics
            _buildActivityMetrics(systemHealth),
            const SizedBox(height: 16),
            
            // Quick actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallHealthCard(SystemHealthMetrics health) {
    final overallHealth = _calculateOverallHealth(health);
    Color healthColor;
    IconData healthIcon;
    String healthText;
    
    switch (overallHealth) {
      case HealthStatus.excellent:
        healthColor = Colors.green;
        healthIcon = Icons.check_circle;
        healthText = 'Excellent';
        break;
      case HealthStatus.good:
        healthColor = Colors.lightGreen;
        healthIcon = Icons.check_circle_outline;
        healthText = 'Good';
        break;
      case HealthStatus.warning:
        healthColor = Colors.orange;
        healthIcon = Icons.warning;
        healthText = 'Warning';
        break;
      case HealthStatus.critical:
        healthColor = Colors.red;
        healthIcon = Icons.error;
        healthText = 'Critical';
        break;
    }

    return Card(
      color: healthColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  healthIcon,
                  color: healthColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Health',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        healthText,
                        style: TextStyle(
                          color: healthColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Last updated: ${_formatDateTime(health.lastUpdate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (overallHealth == HealthStatus.warning || 
                overallHealth == HealthStatus.critical) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: healthColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: healthColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getHealthRecommendation(health),
                        style: TextStyle(
                          color: healthColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResourceMetrics(SystemHealthMetrics health) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resource Usage',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressIndicator(
              label: 'CPU Usage',
              value: health.cpuUsage,
              maxValue: 100,
              unit: '%',
              color: _getUsageColor(health.cpuUsage, 70, 90),
            ),
            const SizedBox(height: 12),
            _buildProgressIndicator(
              label: 'Memory Usage',
              value: health.memoryUsage,
              maxValue: 100,
              unit: '%',
              color: _getUsageColor(health.memoryUsage, 80, 95),
            ),
            const SizedBox(height: 12),
            _buildProgressIndicator(
              label: 'Disk Usage',
              value: health.diskUsage,
              maxValue: 100,
              unit: '%',
              color: _getUsageColor(health.diskUsage, 85, 95),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMetrics(SystemHealthMetrics health) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Active Connections',
                    health.activeConnections.toString(),
                    Icons.wifi,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    'Active Patrols',
                    health.activePatrols.toString(),
                    Icons.directions_walk,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    'Online Guards',
                    health.onlineGuards.toString(),
                    Icons.people,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  'Refresh Data',
                  Icons.refresh,
                  () => _fetchSystemHealth(),
                ),
                _buildActionButton(
                  'System Logs',
                  Icons.article,
                  () => _showSystemLogs(),
                ),
                _buildActionButton(
                  'Performance Report',
                  Icons.analytics,
                  () => _generatePerformanceReport(),
                ),
                _buildActionButton(
                  'Alert Settings',
                  Icons.notifications_active,
                  () => _showAlertSettings(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({
    required String label,
    required double value,
    required double maxValue,
    required String unit,
    required Color color,
  }) {
    final percentage = (value / maxValue * 100).clamp(0.0, 100.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Color _getUsageColor(double usage, double warningThreshold, double criticalThreshold) {
    if (usage >= criticalThreshold) {
      return Colors.red;
    } else if (usage >= warningThreshold) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  HealthStatus _calculateOverallHealth(SystemHealthMetrics health) {
    // Calculate overall health based on various metrics
    final cpuScore = health.cpuUsage < 70 ? 4 : (health.cpuUsage < 90 ? 2 : 1);
    final memoryScore = health.memoryUsage < 80 ? 4 : (health.memoryUsage < 95 ? 2 : 1);
    final diskScore = health.diskUsage < 85 ? 4 : (health.diskUsage < 95 ? 2 : 1);
    
    final averageScore = (cpuScore + memoryScore + diskScore) / 3;
    
    if (averageScore >= 3.5) {
      return HealthStatus.excellent;
    } else if (averageScore >= 2.5) {
      return HealthStatus.good;
    } else if (averageScore >= 1.5) {
      return HealthStatus.warning;
    } else {
      return HealthStatus.critical;
    }
  }

  String _getHealthRecommendation(SystemHealthMetrics health) {
    final issues = <String>[];
    
    if (health.cpuUsage > 90) {
      issues.add('High CPU usage detected');
    }
    if (health.memoryUsage > 95) {
      issues.add('Memory usage critical');
    }
    if (health.diskUsage > 95) {
      issues.add('Disk space low');
    }
    
    if (issues.isEmpty) {
      return 'Some metrics need attention. Consider reviewing system performance.';
    }
    
    return issues.join('. ') + '. Please check system resources.';
  }

  void _showSystemLogs() {
    _showSnackBar('Opening system logs...');
  }

  void _generatePerformanceReport() {
    _showSnackBar('Generating performance report...');
  }

  void _showAlertSettings() {
    _showSnackBar('Opening alert settings...');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

enum HealthStatus {
  excellent,
  good,
  warning,
  critical,
}
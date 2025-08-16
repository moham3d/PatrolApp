import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/notification_provider.dart';

/// Widget for displaying notification statistics and analytics
class NotificationStatsWidget extends ConsumerWidget {
  const NotificationStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(notificationStatsNotifierProvider);
    final unreadCountAsync = ref.watch(unreadNotificationCountNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Notification Statistics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => ref.read(notificationStatsNotifierProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Statistics',
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: statsAsync.when(
              data: (stats) => _buildStatsContent(context, stats, unreadCountAsync),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _buildErrorState(context, ref, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    Map<String, dynamic> stats,
    AsyncValue<int> unreadCountAsync,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Notifications',
                  '${stats['total_count'] ?? 0}',
                  Icons.notifications,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: unreadCountAsync.when(
                  data: (count) => _buildStatCard(
                    context,
                    'Unread',
                    '$count',
                    Icons.mark_email_unread,
                    Colors.orange,
                  ),
                  loading: () => _buildStatCard(
                    context,
                    'Unread',
                    '...',
                    Icons.mark_email_unread,
                    Colors.orange,
                  ),
                  error: (_, __) => _buildStatCard(
                    context,
                    'Unread',
                    'Error',
                    Icons.mark_email_unread,
                    Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Read',
                  '${(stats['total_count'] ?? 0) - (stats['unread_count'] ?? 0)}',
                  Icons.mark_email_read,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Today',
                  '${stats['today_count'] ?? 0}',
                  Icons.today,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Charts section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type distribution pie chart
              Expanded(
                flex: 1,
                child: _buildTypeDistributionChart(context, stats),
              ),
              const SizedBox(width: 24),

              // Priority distribution chart
              Expanded(
                flex: 1,
                child: _buildPriorityDistributionChart(context, stats),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent activity timeline
          _buildRecentActivityChart(context, stats),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDistributionChart(BuildContext context, Map<String, dynamic> stats) {
    final typeDistribution = stats['type_distribution'] as Map<String, dynamic>? ?? {};
    
    if (typeDistribution.isEmpty) {
      return _buildEmptyChart(context, 'Notification Types');
    }

    final sections = typeDistribution.entries.map((entry) {
      final type = entry.key as String;
      final count = entry.value as int;
      final color = _getTypeColor(type);

      return PieChartSectionData(
        value: count.toDouble(),
        title: '$count',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Types',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: typeDistribution.entries.map((entry) {
                final type = entry.key as String;
                final count = entry.value as int;
                final color = _getTypeColor(type);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${_formatTypeName(type)} ($count)'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDistributionChart(BuildContext context, Map<String, dynamic> stats) {
    final priorityDistribution = stats['priority_distribution'] as Map<String, dynamic>? ?? {};
    
    if (priorityDistribution.isEmpty) {
      return _buildEmptyChart(context, 'Priority Levels');
    }

    final priorities = ['low', 'normal', 'high', 'urgent'];
    final barGroups = priorities.asMap().entries.map((entry) {
      final index = entry.key;
      final priority = entry.value;
      final count = priorityDistribution[priority] as int? ?? 0;
      final color = _getPriorityColor(priority);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: color,
            width: 40,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority Levels',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < priorities.length) {
                            return Text(
                              priorities[value.toInt()].toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityChart(BuildContext context, Map<String, dynamic> stats) {
    final dailyActivity = stats['daily_activity'] as List<dynamic>? ?? [];
    
    if (dailyActivity.isEmpty) {
      return _buildEmptyChart(context, 'Recent Activity (Last 7 Days)');
    }

    final spots = dailyActivity.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final count = data['count'] as int;

      return FlSpot(index.toDouble(), count.toDouble());
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity (Last 7 Days)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < dailyActivity.length) {
                            final data = dailyActivity[value.toInt()] as Map<String, dynamic>;
                            final date = DateTime.parse(data['date'] as String);
                            return Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, String title) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 200,
              child: Center(
                child: Text('No data available'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
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
            'Failed to load statistics',
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
            onPressed: () => ref.read(notificationStatsNotifierProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'task_assignment':
        return Colors.blue;
      case 'patrol_update':
        return Colors.green;
      case 'incident_alert':
        return Colors.orange;
      case 'security_alert':
        return Colors.red;
      case 'system_update':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'task_assignment':
        return 'Task Assignment';
      case 'patrol_update':
        return 'Patrol Update';
      case 'incident_alert':
        return 'Incident Alert';
      case 'security_alert':
        return 'Security Alert';
      case 'system_update':
        return 'System Update';
      default:
        return type;
    }
  }
}
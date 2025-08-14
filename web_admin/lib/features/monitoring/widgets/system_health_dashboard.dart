import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/monitoring_provider.dart';

/// Enhanced system health dashboard with performance metrics and charts
class SystemHealthDashboard extends ConsumerStatefulWidget {
  const SystemHealthDashboard({super.key});

  @override
  ConsumerState<SystemHealthDashboard> createState() => _SystemHealthDashboardState();
}

class _SystemHealthDashboardState extends ConsumerState<SystemHealthDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _fetchSystemHealth();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
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
      return _buildLoadingState();
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
            // Real-time system overview
            _buildSystemOverviewCards(systemHealth),
            const SizedBox(height: 24),
            
            // Performance metrics charts
            Row(
              children: [
                Expanded(
                  child: _buildResourceUsageChart(systemHealth),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSystemActivityChart(systemHealth),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Service status indicators
            _buildServiceStatusGrid(),
            const SizedBox(height: 24),
            
            // Real-time statistics widgets
            _buildRealTimeStatistics(systemHealth),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _rotationController,
            child: Icon(
              Icons.settings,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading system health metrics...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverviewCards(SystemHealthMetrics health) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'CPU Usage',
            '${health.cpuUsage.toStringAsFixed(1)}%',
            Icons.memory,
            _getUsageColor(health.cpuUsage, 70, 90),
            health.cpuUsage / 100,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Memory Usage',
            '${health.memoryUsage.toStringAsFixed(1)}%',
            Icons.storage,
            _getUsageColor(health.memoryUsage, 80, 95),
            health.memoryUsage / 100,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Disk Usage',
            '${health.diskUsage.toStringAsFixed(1)}%',
            Icons.disc_full,
            _getUsageColor(health.diskUsage, 85, 95),
            health.diskUsage / 100,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Active Users',
            '${health.activeConnections}',
            Icons.people,
            Colors.blue,
            health.activeConnections / 100, // Normalize for animation
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceUsageChart(SystemHealthMetrics health) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resource Usage',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      color: _getUsageColor(health.cpuUsage, 70, 90),
                      value: health.cpuUsage,
                      title: 'CPU\n${health.cpuUsage.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: _getUsageColor(health.memoryUsage, 80, 95),
                      value: health.memoryUsage,
                      title: 'RAM\n${health.memoryUsage.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: _getUsageColor(health.diskUsage, 85, 95),
                      value: health.diskUsage,
                      title: 'Disk\n${health.diskUsage.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildSystemActivityChart(SystemHealthMetrics health) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Connections');
                            case 1:
                              return const Text('Patrols');
                            case 2:
                              return const Text('Guards');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: health.activeConnections.toDouble(),
                          color: Colors.blue,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: health.activePatrols.toDouble(),
                          color: Colors.green,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: health.onlineGuards.toDouble(),
                          color: Colors.orange,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
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

  Widget _buildServiceStatusGrid() {
    final services = [
      ServiceStatus('Database', true, 'PostgreSQL'),
      ServiceStatus('Authentication', true, 'JWT Service'),
      ServiceStatus('WebSocket', true, 'Real-time'),
      ServiceStatus('File Storage', true, 'Cloud Storage'),
      ServiceStatus('API Gateway', true, 'Load Balancer'),
      ServiceStatus('Cache', true, 'Redis'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceStatusItem(service);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatusItem(ServiceStatus service) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: service.isOnline 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: service.isOnline 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: service.isOnline 
                    ? 1.0 + (_pulseController.value * 0.1)
                    : 1.0,
                child: Icon(
                  service.isOnline ? Icons.check_circle : Icons.error,
                  color: service.isOnline ? Colors.green : Colors.red,
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeStatistics(SystemHealthMetrics health) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Real-time Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.5 + (_pulseController.value * 0.5),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Live',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatisticTile(
                    'Uptime',
                    '99.9%',
                    '30 days',
                    Icons.timer,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatisticTile(
                    'Response Time',
                    '124ms',
                    'Avg last hour',
                    Icons.speed,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatisticTile(
                    'Requests/min',
                    '2,847',
                    'Current rate',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatisticTile(
                    'Errors',
                    '0.1%',
                    'Error rate',
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticTile(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
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
}

class ServiceStatus {
  final String name;
  final bool isOnline;
  final String description;

  ServiceStatus(this.name, this.isOnline, this.description);
}
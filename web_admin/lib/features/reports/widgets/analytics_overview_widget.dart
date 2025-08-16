import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/reports_provider.dart';

/// Analytics overview widget with charts and metrics
class AnalyticsOverviewWidget extends ConsumerStatefulWidget {
  const AnalyticsOverviewWidget({super.key});

  @override
  ConsumerState<AnalyticsOverviewWidget> createState() => _AnalyticsOverviewWidgetState();
}

class _AnalyticsOverviewWidgetState extends ConsumerState<AnalyticsOverviewWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  final List<int> _selectedSiteIds = [];

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsDataProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      '${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: analyticsAsync.when(
              data: (data) => _buildAnalyticsContent(context, data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
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
                      'Failed to load analytics',
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
                      onPressed: () => ref.invalidate(analyticsDataProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, Map<String, dynamic> data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // KPI Cards Row
          _buildKpiCardsRow(context, data),
          const SizedBox(height: 24),

          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patrol Efficiency Chart
              Expanded(
                child: _buildPatrolEfficiencyChart(context),
              ),
              const SizedBox(width: 24),
              // Incident Trends Chart
              Expanded(
                child: _buildIncidentTrendsChart(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Additional Analytics Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Site Security Scores
              Expanded(
                child: _buildSiteSecurityCard(context),
              ),
              const SizedBox(width: 24),
              // Guard Performance
              Expanded(
                child: _buildGuardPerformanceCard(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCardsRow(BuildContext context, Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            context,
            'Total Patrols',
            '${data['total_patrols'] ?? 0}',
            Icons.security,
            Colors.blue,
            '${data['patrols_change'] ?? 0}% vs last period',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            context,
            'Completed Patrols',
            '${data['completed_patrols'] ?? 0}',
            Icons.check_circle,
            Colors.green,
            '${((data['completed_patrols'] ?? 0) / (data['total_patrols'] ?? 1) * 100).toStringAsFixed(1)}% completion rate',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            context,
            'Active Guards',
            '${data['active_guards'] ?? 0}',
            Icons.people,
            Colors.orange,
            '${data['guards_change'] ?? 0}% vs last period',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            context,
            'Incidents',
            '${data['total_incidents'] ?? 0}',
            Icons.warning,
            Colors.red,
            '${data['incidents_change'] ?? 0}% vs last period',
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const Spacer(),
                Icon(
                  subtitle.contains('+') || subtitle.contains('% vs') && !subtitle.contains('-')
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: subtitle.contains('-') ? Colors.red : Colors.green,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatrolEfficiencyChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Patrol Efficiency',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _showDetailedReport('patrol-efficiency'),
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'View Detailed Report',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: FutureBuilder<Map<String, dynamic>>(
                future: ref.read(analyticsDataProvider.notifier).getPatrolEfficiency(
                  startDate: _startDate,
                  endDate: _endDate,
                  siteIds: _selectedSiteIds.isNotEmpty ? _selectedSiteIds : null,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading patrol efficiency data'),
                    );
                  }

                  final data = snapshot.data ?? {};
                  final chartData = _preparePatrolEfficiencyData(data);

                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < chartData.length) {
                                return Text(
                                  DateFormat.Md().format(
                                    DateTime.now().subtract(Duration(days: chartData.length - value.toInt())),
                                  ),
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentTrendsChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Incident Trends',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _showDetailedReport('incident-trends'),
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'View Detailed Report',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: FutureBuilder<Map<String, dynamic>>(
                future: ref.read(analyticsDataProvider.notifier).getIncidentTrends(
                  startDate: _startDate,
                  endDate: _endDate,
                  siteIds: _selectedSiteIds.isNotEmpty ? _selectedSiteIds : null,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading incident trends data'),
                    );
                  }

                  final data = snapshot.data ?? {};
                  final chartData = _prepareIncidentTrendsData(data);

                  return BarChart(
                    BarChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final categories = ['Security', 'Safety', 'Maintenance', 'Other'];
                              if (value.toInt() < categories.length) {
                                return Text(
                                  categories[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      barGroups: chartData,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteSecurityCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Site Security Scores',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Mock site security scores
            ..._buildMockSiteScores(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardPerformanceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Guard Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Mock guard performance data
            ..._buildMockGuardPerformance(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMockSiteScores(BuildContext context) {
    final sites = [
      {'name': 'Main Campus', 'score': 95},
      {'name': 'East Wing', 'score': 88},
      {'name': 'Parking Garage', 'score': 76},
      {'name': 'North Building', 'score': 82},
    ];

    return sites.map((site) {
      final score = site['score'] as int;
      final color = score >= 90 ? Colors.green : score >= 75 ? Colors.orange : Colors.red;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                site['name'] as String,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color),
              ),
              child: Text(
                '$score%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildMockGuardPerformance(BuildContext context) {
    final guards = [
      {'name': 'John Smith', 'score': 98, 'patrols': 45},
      {'name': 'Sarah Johnson', 'score': 94, 'patrols': 42},
      {'name': 'Mike Davis', 'score': 89, 'patrols': 38},
      {'name': 'Lisa Brown', 'score': 87, 'patrols': 35},
    ];

    return guards.map((guard) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            (guard['name'] as String).split(' ').map((n) => n[0]).join(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(guard['name'] as String),
        subtitle: Text('${guard['patrols']} patrols completed'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Text(
            '${guard['score']}%',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<FlSpot> _preparePatrolEfficiencyData(Map<String, dynamic> data) {
    // Mock data for demonstration
    return List.generate(7, (index) {
      return FlSpot(index.toDouble(), 75 + (index * 3) + (index % 3) * 5);
    });
  }

  List<BarChartGroupData> _prepareIncidentTrendsData(Map<String, dynamic> data) {
    // Mock data for demonstration
    return [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: Colors.red)]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: Colors.orange)]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 15, color: Colors.blue)]),
      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 5, color: Colors.grey)]),
    ];
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate!, end: _endDate!),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _refreshData();
    }
  }

  void _refreshData() {
    ref.invalidate(analyticsDataProvider);
  }

  void _showDetailedReport(String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detailed $reportType report coming soon')),
    );
  }
}
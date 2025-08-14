import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// Performance metrics widget with historical data visualization
class PerformanceMetricsWidget extends ConsumerStatefulWidget {
  const PerformanceMetricsWidget({super.key});

  @override
  ConsumerState<PerformanceMetricsWidget> createState() => _PerformanceMetricsWidgetState();
}

class _PerformanceMetricsWidgetState extends ConsumerState<PerformanceMetricsWidget> {
  String _selectedMetric = 'cpu';
  String _selectedTimeframe = '1h';
  
  // Mock historical data - in real implementation, this would come from the monitoring provider
  final Map<String, List<FlSpot>> _historicalData = {
    'cpu': [
      const FlSpot(0, 45),
      const FlSpot(1, 52),
      const FlSpot(2, 48),
      const FlSpot(3, 61),
      const FlSpot(4, 58),
      const FlSpot(5, 55),
      const FlSpot(6, 62),
      const FlSpot(7, 59),
      const FlSpot(8, 67),
      const FlSpot(9, 64),
      const FlSpot(10, 70),
      const FlSpot(11, 68),
    ],
    'memory': [
      const FlSpot(0, 68),
      const FlSpot(1, 72),
      const FlSpot(2, 70),
      const FlSpot(3, 75),
      const FlSpot(4, 78),
      const FlSpot(5, 76),
      const FlSpot(6, 82),
      const FlSpot(7, 79),
      const FlSpot(8, 84),
      const FlSpot(9, 81),
      const FlSpot(10, 85),
      const FlSpot(11, 83),
    ],
    'network': [
      const FlSpot(0, 125),
      const FlSpot(1, 142),
      const FlSpot(2, 138),
      const FlSpot(3, 156),
      const FlSpot(4, 149),
      const FlSpot(5, 162),
      const FlSpot(6, 175),
      const FlSpot(7, 168),
      const FlSpot(8, 184),
      const FlSpot(9, 192),
      const FlSpot(10, 187),
      const FlSpot(11, 195),
    ],
    'requests': [
      const FlSpot(0, 2450),
      const FlSpot(1, 2680),
      const FlSpot(2, 2520),
      const FlSpot(3, 2890),
      const FlSpot(4, 3120),
      const FlSpot(5, 2980),
      const FlSpot(6, 3250),
      const FlSpot(7, 3080),
      const FlSpot(8, 3420),
      const FlSpot(9, 3650),
      const FlSpot(10, 3380),
      const FlSpot(11, 3720),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with metric and timeframe selectors
            _buildHeader(),
            const SizedBox(height: 20),
            
            // Performance chart
            SizedBox(
              height: 300,
              child: _buildPerformanceChart(),
            ),
            const SizedBox(height: 20),
            
            // Performance summary statistics
            _buildSummaryStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Performance Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        
        // Metric selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedMetric,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMetric = value;
                });
              }
            },
            items: [
              DropdownMenuItem(
                value: 'cpu',
                child: Row(
                  children: [
                    Icon(Icons.memory, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('CPU Usage'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'memory',
                child: Row(
                  children: [
                    Icon(Icons.storage, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('Memory Usage'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'network',
                child: Row(
                  children: [
                    Icon(Icons.network_check, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('Network I/O'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'requests',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 16, color: Colors.purple),
                    const SizedBox(width: 8),
                    const Text('Requests/min'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Timeframe selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedTimeframe,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTimeframe = value;
                });
              }
            },
            items: const [
              DropdownMenuItem(value: '1h', child: Text('Last Hour')),
              DropdownMenuItem(value: '6h', child: Text('Last 6 Hours')),
              DropdownMenuItem(value: '24h', child: Text('Last 24 Hours')),
              DropdownMenuItem(value: '7d', child: Text('Last 7 Days')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    final data = _historicalData[_selectedMetric] ?? [];
    final color = _getMetricColor(_selectedMetric);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getHorizontalInterval(_selectedMetric),
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatTimeLabel(value.toInt()),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: _getVerticalInterval(_selectedMetric),
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatValueLabel(value, _selectedMetric),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
        minX: 0,
        maxX: 11,
        minY: _getMinY(_selectedMetric),
        maxY: _getMaxY(_selectedMetric),
      ),
    );
  }

  Widget _buildSummaryStatistics() {
    final data = _historicalData[_selectedMetric] ?? [];
    if (data.isEmpty) return const SizedBox.shrink();
    
    final values = data.map((spot) => spot.y).toList();
    final current = values.last;
    final previous = values.length > 1 ? values[values.length - 2] : current;
    final average = values.reduce((a, b) => a + b) / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final change = current - previous;
    final changePercent = previous != 0 ? (change / previous) * 100 : 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current',
            _formatValue(current, _selectedMetric),
            change >= 0 ? Icons.trending_up : Icons.trending_down,
            change >= 0 ? Colors.green : Colors.red,
            '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Average',
            _formatValue(average, _selectedMetric),
            Icons.timeline,
            Colors.blue,
            _selectedTimeframe,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Maximum',
            _formatValue(max, _selectedMetric),
            Icons.keyboard_arrow_up,
            Colors.orange,
            'Peak value',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Minimum',
            _formatValue(min, _selectedMetric),
            Icons.keyboard_arrow_down,
            Colors.teal,
            'Lowest value',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
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
                  fontSize: 16,
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

  Color _getMetricColor(String metric) {
    switch (metric) {
      case 'cpu':
        return Colors.blue;
      case 'memory':
        return Colors.green;
      case 'network':
        return Colors.orange;
      case 'requests':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  double _getHorizontalInterval(String metric) {
    switch (metric) {
      case 'cpu':
      case 'memory':
        return 20;
      case 'network':
        return 50;
      case 'requests':
        return 1000;
      default:
        return 20;
    }
  }

  double _getVerticalInterval(String metric) {
    switch (metric) {
      case 'cpu':
      case 'memory':
        return 20;
      case 'network':
        return 50;
      case 'requests':
        return 1000;
      default:
        return 20;
    }
  }

  double _getMinY(String metric) {
    switch (metric) {
      case 'cpu':
      case 'memory':
        return 0;
      case 'network':
        return 100;
      case 'requests':
        return 2000;
      default:
        return 0;
    }
  }

  double _getMaxY(String metric) {
    switch (metric) {
      case 'cpu':
      case 'memory':
        return 100;
      case 'network':
        return 200;
      case 'requests':
        return 4000;
      default:
        return 100;
    }
  }

  String _formatTimeLabel(int value) {
    final now = DateTime.now();
    final time = now.subtract(Duration(minutes: (11 - value) * 5));
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatValueLabel(double value, String metric) {
    switch (metric) {
      case 'cpu':
      case 'memory':
        return '${value.toInt()}%';
      case 'network':
        return '${value.toInt()}MB/s';
      case 'requests':
        return '${(value / 1000).toStringAsFixed(1)}K';
      default:
        return value.toInt().toString();
    }
  }

  String _formatValue(double value, String metric) {
    switch (metric) {
      case 'cpu':
      case 'memory':
        return '${value.toStringAsFixed(1)}%';
      case 'network':
        return '${value.toStringAsFixed(1)} MB/s';
      case 'requests':
        return '${value.toStringAsFixed(0)}/min';
      default:
        return value.toStringAsFixed(1);
    }
  }
}
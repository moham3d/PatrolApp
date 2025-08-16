import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard_stats_grid.dart';
import '../widgets/recent_activities_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/live_status_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh dashboard data
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(recentActivitiesProvider);
            },
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(context),
            const SizedBox(height: 24),

            // Stats grid
            const DashboardStatsGrid(),
            const SizedBox(height: 24),

            // Live status and quick actions row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live status (left side)
                const Expanded(flex: 2, child: LiveStatusWidget()),
                const SizedBox(width: 16),

                // Quick actions (right side)
                const Expanded(flex: 1, child: QuickActionsWidget()),
              ],
            ),
            const SizedBox(height: 24),

            // Recent activities
            const RecentActivitiesWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, Admin!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome to PatrolShield Admin Dashboard',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today is ${_formatDate(now)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.dashboard, size: 64, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, $monthName ${date.day}, ${date.year}';
  }
}

// Providers for dashboard data
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(seconds: 1));
  return DashboardStats(
    totalUsers: 156,
    activeSites: 24,
    activePatrols: 12,
    totalCheckpoints: 89,
    onlineGuards: 18,
    alertsToday: 3,
  );
});

final recentActivitiesProvider = FutureProvider<List<RecentActivity>>((
  ref,
) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    RecentActivity(
      title: 'New patrol assigned',
      description: 'Downtown Security patrol assigned to Guard John Smith',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: ActivityType.patrol,
    ),
    RecentActivity(
      title: 'Checkpoint completed',
      description: 'Checkpoint #12 at Main Building completed successfully',
      timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
      type: ActivityType.checkpoint,
    ),
    RecentActivity(
      title: 'New user created',
      description: 'Security Guard Sarah Johnson added to the system',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      type: ActivityType.user,
    ),
    RecentActivity(
      title: 'Site alarm triggered',
      description: 'Motion sensor activated at Warehouse B',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
      type: ActivityType.alert,
    ),
  ];
});

// Data models
class DashboardStats {
  final int totalUsers;
  final int activeSites;
  final int activePatrols;
  final int totalCheckpoints;
  final int onlineGuards;
  final int alertsToday;

  const DashboardStats({
    required this.totalUsers,
    required this.activeSites,
    required this.activePatrols,
    required this.totalCheckpoints,
    required this.onlineGuards,
    required this.alertsToday,
  });
}

class RecentActivity {
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;

  const RecentActivity({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });
}

enum ActivityType { patrol, checkpoint, user, site, alert, message }

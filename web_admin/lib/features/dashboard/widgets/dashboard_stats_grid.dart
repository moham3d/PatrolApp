import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/dashboard_page.dart';

class DashboardStatsGrid extends ConsumerWidget {
  const DashboardStatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const _StatsGridSkeleton(),
      error: (error, stack) => _StatsGridError(error: error.toString()),
      data: (stats) => _StatsGridContent(stats: stats),
    );
  }
}

class _StatsGridContent extends StatelessWidget {
  final DashboardStats stats;

  const _StatsGridContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _getCrossAxisCount(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Total Users',
          value: stats.totalUsers.toString(),
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => context.go('/users'),
        ),
        _StatCard(
          title: 'Active Sites',
          value: stats.activeSites.toString(),
          icon: Icons.location_on,
          color: Colors.green,
          onTap: () => context.go('/sites'),
        ),
        _StatCard(
          title: 'Active Patrols',
          value: stats.activePatrols.toString(),
          icon: Icons.route,
          color: Colors.orange,
          onTap: () => context.go('/patrols'),
        ),
        _StatCard(
          title: 'Checkpoints',
          value: stats.totalCheckpoints.toString(),
          icon: Icons.check_circle,
          color: Colors.purple,
          onTap: () => context.go('/checkpoints'),
        ),
        _StatCard(
          title: 'Online Guards',
          value: stats.onlineGuards.toString(),
          icon: Icons.person_pin,
          color: Colors.teal,
          onTap: () => context.go('/monitoring'),
        ),
        _StatCard(
          title: 'Alerts Today',
          value: stats.alertsToday.toString(),
          icon: Icons.warning,
          color: stats.alertsToday > 0 ? Colors.red : Colors.grey,
          onTap: () => context.go('/communication'),
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _getCrossAxisCount(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(6, (index) => _SkeletonCard()),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGridError extends StatelessWidget {
  final String error;

  const _StatsGridError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'Failed to load statistics',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

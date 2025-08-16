import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveStatusWidget extends ConsumerWidget {
  const LiveStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemStatusAsync = ref.watch(systemStatusProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                systemStatusAsync.when(
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) =>
                      Icon(Icons.error, color: Colors.red, size: 16),
                  data: (_) =>
                      Icon(Icons.refresh, color: Colors.green, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            systemStatusAsync.when(
              loading: () => const _StatusLoading(),
              error: (error, stack) => _StatusError(error: error.toString()),
              data: (status) => _StatusContent(status: status),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusContent extends StatelessWidget {
  final SystemStatus status;

  const _StatusContent({required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatusItem(
          icon: Icons.cloud,
          label: 'API Server',
          status: status.apiServerStatus,
          isOnline: status.isApiOnline,
        ),
        const SizedBox(height: 12),
        _StatusItem(
          icon: Icons.wifi,
          label: 'WebSocket',
          status: status.websocketStatus,
          isOnline: status.isWebSocketConnected,
        ),
        const SizedBox(height: 12),
        _StatusItem(
          icon: Icons.storage,
          label: 'Database',
          status: status.databaseStatus,
          isOnline: status.isDatabaseOnline,
        ),
        const SizedBox(height: 12),
        _StatusItem(
          icon: Icons.people,
          label: 'Active Guards',
          status: '${status.activeGuards} online',
          isOnline: status.activeGuards > 0,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        _SystemHealthIndicator(overallHealth: status.overallHealth),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final bool isOnline;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.status,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _SystemHealthIndicator extends StatelessWidget {
  final double overallHealth;

  const _SystemHealthIndicator({required this.overallHealth});

  @override
  Widget build(BuildContext context) {
    Color healthColor;
    String healthLabel;

    if (overallHealth >= 0.8) {
      healthColor = Colors.green;
      healthLabel = 'Excellent';
    } else if (overallHealth >= 0.6) {
      healthColor = Colors.orange;
      healthLabel = 'Good';
    } else if (overallHealth >= 0.4) {
      healthColor = Colors.red;
      healthLabel = 'Poor';
    } else {
      healthColor = Colors.red;
      healthLabel = 'Critical';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'System Health',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              healthLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: healthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: overallHealth,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(healthColor),
        ),
        const SizedBox(height: 4),
        Text(
          '${(overallHealth * 100).toInt()}% operational',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatusLoading extends StatelessWidget {
  const _StatusLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusError extends StatelessWidget {
  final String error;

  const _StatusError({required this.error});

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
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'Failed to load status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

// Provider for system status
final systemStatusProvider = FutureProvider<SystemStatus>((ref) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(seconds: 1));
  return SystemStatus(
    apiServerStatus: 'Online',
    websocketStatus: 'Connected',
    databaseStatus: 'Operational',
    isApiOnline: true,
    isWebSocketConnected: true,
    isDatabaseOnline: true,
    activeGuards: 18,
    overallHealth: 0.85,
  );
});

// Data model
class SystemStatus {
  final String apiServerStatus;
  final String websocketStatus;
  final String databaseStatus;
  final bool isApiOnline;
  final bool isWebSocketConnected;
  final bool isDatabaseOnline;
  final int activeGuards;
  final double overallHealth;

  const SystemStatus({
    required this.apiServerStatus,
    required this.websocketStatus,
    required this.databaseStatus,
    required this.isApiOnline,
    required this.isWebSocketConnected,
    required this.isDatabaseOnline,
    required this.activeGuards,
    required this.overallHealth,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/websocket_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../widgets/live_patrol_map.dart';
import '../widgets/live_alerts_feed.dart';
import '../widgets/guard_locations_panel.dart';
import '../widgets/system_health_panel.dart';
import '../widgets/system_health_dashboard.dart';
import '../widgets/performance_metrics_widget.dart';

/// Live monitoring dashboard page with real-time updates
class LiveMonitoringPage extends ConsumerStatefulWidget {
  const LiveMonitoringPage({super.key});

  @override
  ConsumerState<LiveMonitoringPage> createState() => _LiveMonitoringPageState();
}

class _LiveMonitoringPageState extends ConsumerState<LiveMonitoringPage> {
  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  /// Initialize WebSocket connection for real-time updates
  void _initializeWebSocket() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.isLoggedIn && authState.user != null) {
        final webSocketService = ref.read(webSocketServiceProvider);
        const token = ''; // TODO: Implement proper token handling
        webSocketService.connect(authState.user!.id, token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final webSocketState = ref.watch(webSocketStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Monitoring Dashboard'),
        actions: [
          // WebSocket connection indicator
          webSocketState.when(
            data: (state) => _buildConnectionIndicator(state),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Icon(Icons.error, color: Colors.red),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildDashboardLayout(),
    );
  }

  Widget _buildConnectionIndicator(WebSocketState state) {
    Color color;
    IconData icon;
    String tooltip;

    switch (state) {
      case WebSocketState.connected:
        color = Colors.green;
        icon = Icons.wifi;
        tooltip = 'Connected';
        break;
      case WebSocketState.connecting:
      case WebSocketState.reconnecting:
        color = Colors.orange;
        icon = Icons.wifi_tethering;
        tooltip = 'Connecting...';
        break;
      case WebSocketState.disconnected:
        color = Colors.grey;
        icon = Icons.wifi_off;
        tooltip = 'Disconnected';
        break;
      case WebSocketState.error:
        color = Colors.red;
        icon = Icons.error;
        tooltip = 'Connection Error';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: color),
    );
  }

  Widget _buildDashboardLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 1200;

        if (isWideScreen) {
          // Wide screen: side-by-side layout
          return Row(
            children: [
              // Left panel: Map and alerts
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Live patrol map
                    Expanded(
                      flex: 3,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Live Patrol Tracking',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: LivePatrolMap()),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Live alerts feed
                    Expanded(
                      flex: 2,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Live Alerts',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: LiveAlertsFeed()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right panel: Guard locations and system health
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Guard locations
                    Expanded(
                      flex: 3,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guard Locations',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: GuardLocationsPanel()),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // System health dashboard
                    Expanded(
                      flex: 2,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'System Health Dashboard',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: SystemHealthDashboard()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          // Narrow screen: tabbed layout
          return DefaultTabController(
            length: 6,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(icon: Icon(Icons.map), text: 'Map'),
                    Tab(icon: Icon(Icons.notifications), text: 'Alerts'),
                    Tab(icon: Icon(Icons.people), text: 'Guards'),
                    Tab(icon: Icon(Icons.health_and_safety), text: 'Health'),
                    Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                    Tab(icon: Icon(Icons.analytics), text: 'Metrics'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Live Patrol Tracking',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: LivePatrolMap()),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Live Alerts',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: LiveAlertsFeed()),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guard Locations',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: GuardLocationsPanel()),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'System Health',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: SystemHealthPanel()),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'System Dashboard',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: SystemHealthDashboard()),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Performance Metrics',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              const Expanded(child: PerformanceMetricsWidget()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

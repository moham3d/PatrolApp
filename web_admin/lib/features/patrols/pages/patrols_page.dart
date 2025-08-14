import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/patrols_provider.dart';
import '../widgets/patrol_calendar_widget.dart';
import '../widgets/patrol_list_widget.dart';
import '../widgets/patrol_form_dialog.dart';
import '../widgets/patrol_status_widget.dart';
import '../widgets/patrol_route_planner.dart';

class PatrolsPage extends ConsumerStatefulWidget {
  const PatrolsPage({super.key});

  @override
  ConsumerState<PatrolsPage> createState() => _PatrolsPageState();
}

class _PatrolsPageState extends ConsumerState<PatrolsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patrolsProvider.notifier).loadPatrols();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with title and actions
          _buildHeader(context),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.calendar_month), text: 'Schedule'),
              Tab(icon: Icon(Icons.list), text: 'All Patrols'),
              Tab(icon: Icon(Icons.dashboard), text: 'Status'),
              Tab(icon: Icon(Icons.map), text: 'Route Planner'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Calendar view
                PatrolCalendarWidget(
                  selectedDay: _selectedDay,
                  focusedDay: _focusedDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),

                // List view
                PatrolListWidget(selectedDay: _selectedDay),

                // Status dashboard
                const PatrolStatusWidget(),

                // Route planner
                const PatrolRoutePlanner(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePatrolDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Schedule Patrol'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patrol Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Schedule, monitor, and manage security patrols',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: () =>
                    ref.read(patrolsProvider.notifier).loadPatrols(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _showCreatePatrolDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Schedule Patrol'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreatePatrolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PatrolFormDialog(),
    );
  }
}

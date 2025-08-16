import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/report_builder_widget.dart';
import '../widgets/report_templates_widget.dart';
import '../widgets/scheduled_reports_widget.dart';
import '../widgets/analytics_overview_widget.dart';

/// Main reports page with tabs for different report functionalities
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_outlined),
              text: 'Analytics',
            ),
            Tab(
              icon: Icon(Icons.build_outlined),
              text: 'Report Builder',
            ),
            Tab(
              icon: Icon(Icons.bookmark_outline),
              text: 'Templates',
            ),
            Tab(
              icon: Icon(Icons.schedule_outlined),
              text: 'Scheduled',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AnalyticsOverviewWidget(),
          ReportBuilderWidget(),
          ReportTemplatesWidget(),
          ScheduledReportsWidget(),
        ],
      ),
    );
  }
}
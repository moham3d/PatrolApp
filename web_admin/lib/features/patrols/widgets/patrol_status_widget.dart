import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/patrol.dart';
import '../../../shared/services/websocket_service.dart';
import '../providers/patrols_provider.dart';

/// Patrol status monitoring widget with live tiles
class PatrolStatusWidget extends ConsumerStatefulWidget {
  const PatrolStatusWidget({super.key});

  @override
  ConsumerState<PatrolStatusWidget> createState() => _PatrolStatusWidgetState();
}

class _PatrolStatusWidgetState extends ConsumerState<PatrolStatusWidget> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Load patrols on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patrolsProvider.notifier).loadPatrols();
      _setupWebSocketListener();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _setupWebSocketListener() {
    // Listen for patrol updates via WebSocket
    ref.listen<AsyncValue<WebSocketMessage>>(
      webSocketMessagesProvider,
      (previous, next) {
        next.whenData((message) {
          if (message.type == WebSocketMessageType.patrolUpdate) {
            // Refresh patrol data when updates are received
            ref.read(patrolsProvider.notifier).loadPatrols();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final patrolsAsync = ref.watch(patrolsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          _buildHeader(context),
          const SizedBox(height: 24),
          
          // Status overview cards
          patrolsAsync.when(
            data: (patrols) => Expanded(
              child: Column(
                children: [
                  _buildStatusOverview(context, patrols),
                  const SizedBox(height: 24),
                  Expanded(child: _buildStatusTiles(context, patrols)),
                ],
              ),
            ),
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading patrol status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(error.toString()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(patrolsProvider.notifier).loadPatrols(),
                      child: const Text('Retry'),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Patrol Status Monitor',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        
        // Status filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedStatus,
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Status')),
              DropdownMenuItem(value: 'assigned', child: Text('Assigned')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Refresh button
        IconButton(
          onPressed: () => ref.read(patrolsProvider.notifier).loadPatrols(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh Status',
        ),
      ],
    );
  }

  Widget _buildStatusOverview(BuildContext context, List<Patrol> patrols) {
    final statusCounts = _calculateStatusCounts(patrols);
    
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            context,
            'Assigned',
            statusCounts['assigned'] ?? 0,
            Colors.orange,
            Icons.assignment,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            context,
            'Active',
            statusCounts['active'] ?? 0,
            Colors.blue,
            Icons.play_circle,
            isAnimated: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            context,
            'Completed',
            statusCounts['completed'] ?? 0,
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            context,
            'Cancelled',
            statusCounts['cancelled'] ?? 0,
            Colors.red,
            Icons.cancel,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    int count,
    Color color,
    IconData icon, {
    bool isAnimated = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isAnimated 
                            ? color.withOpacity(0.7 + 0.3 * _pulseController.value)
                            : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTiles(BuildContext context, List<Patrol> patrols) {
    final filteredPatrols = _selectedStatus == 'all' 
        ? patrols 
        : patrols.where((p) => p.status == _selectedStatus).toList();

    if (filteredPatrols.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No patrols found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later or adjust your filter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredPatrols.length,
      itemBuilder: (context, index) {
        final patrol = filteredPatrols[index];
        return _buildPatrolTile(context, patrol);
      },
    );
  }

  Widget _buildPatrolTile(BuildContext context, Patrol patrol) {
    final isActive = patrol.status == 'active';
    final isOverdue = patrol.status == 'assigned' && 
                     DateTime.now().isAfter(patrol.scheduledStart);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Card(
          elevation: isActive ? 4 : 2,
          color: isOverdue ? Colors.red[50] : null,
          child: InkWell(
            onTap: () => _showPatrolDetails(context, patrol),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          patrol.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(patrol.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isActive)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                    0.7 + 0.3 * _pulseController.value,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (isActive) const SizedBox(width: 4),
                            Text(
                              patrol.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Details
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          patrol.siteName ?? 'No site assigned',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          patrol.assignedToName ?? 'Unassigned',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('HH:mm').format(patrol.scheduledStart)} - ${DateFormat('HH:mm').format(patrol.scheduledEnd)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  
                  // Progress indicator
                  if (patrol.checkpointsTotal > 0)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${patrol.checkpointsCompleted}/${patrol.checkpointsTotal}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: patrol.checkpointsTotal > 0 
                              ? patrol.checkpointsCompleted / patrol.checkpointsTotal 
                              : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(patrol.status),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, int> _calculateStatusCounts(List<Patrol> patrols) {
    final counts = <String, int>{};
    for (final patrol in patrols) {
      counts[patrol.status] = (counts[patrol.status] ?? 0) + 1;
    }
    return counts;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.orange;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showPatrolDetails(BuildContext context, Patrol patrol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patrol: ${patrol.title}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', patrol.status.toUpperCase()),
              _buildDetailRow('Site', patrol.siteName ?? 'N/A'),
              _buildDetailRow('Assigned To', patrol.assignedToName ?? 'Unassigned'),
              _buildDetailRow('Scheduled', 
                '${DateFormat('MMM dd, HH:mm').format(patrol.scheduledStart)} - ${DateFormat('HH:mm').format(patrol.scheduledEnd)}'),
              _buildDetailRow('Progress', '${patrol.checkpointsCompleted}/${patrol.checkpointsTotal} checkpoints'),
              if (patrol.actualStart != null)
                _buildDetailRow('Started', DateFormat('MMM dd, HH:mm').format(patrol.actualStart!)),
              if (patrol.actualEnd != null)
                _buildDetailRow('Completed', DateFormat('MMM dd, HH:mm').format(patrol.actualEnd!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (patrol.status == 'assigned')
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startPatrol(patrol);
              },
              child: const Text('Start Patrol'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _startPatrol(Patrol patrol) {
    ref.read(patrolsProvider.notifier).startPatrol(patrol.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting patrol: ${patrol.title}')),
    );
  }
}
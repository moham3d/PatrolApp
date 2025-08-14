import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/patrol.dart';
import '../../../shared/widgets/rbac/rbac.dart';
import '../providers/patrols_provider.dart';

/// Patrol list widget with data tables and filtering
class PatrolListWidget extends ConsumerStatefulWidget {
  final DateTime selectedDay;

  const PatrolListWidget({
    super.key,
    required this.selectedDay,
  });

  @override
  ConsumerState<PatrolListWidget> createState() => _PatrolListWidgetState();
}

class _PatrolListWidgetState extends ConsumerState<PatrolListWidget> {
  String? _statusFilter;
  String? _assigneeFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          const SizedBox(height: 16),
          
          // Data table
          Expanded(
            child: patrolsAsync.when(
              data: (patrols) => _buildPatrolTable(context, patrols),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
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
                      'Error loading patrols',
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
          'Patrol Reports',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        
        // Search field
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search patrols',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _filterPatrols(),
          ),
        ),
        const SizedBox(width: 16),
        
        // Status filter
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String?>(
            value: _statusFilter,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Status')),
              DropdownMenuItem(value: 'assigned', child: Text('Assigned')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              setState(() {
                _statusFilter = value;
              });
              _filterPatrols();
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Export button
        PermissionGuard(
          requiredRoles: Permissions.patrolView,
          child: OutlinedButton.icon(
            onPressed: _exportPatrols,
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ),
      ],
    );
  }

  Widget _buildPatrolTable(BuildContext context, List<Patrol> patrols) {
    final filteredPatrols = _getFilteredPatrols(patrols);

    if (filteredPatrols.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No patrols found'),
            Text('Try adjusting your filters'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Site')),
            DataColumn(label: Text('Assigned To')),
            DataColumn(label: Text('Scheduled')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Progress')),
            DataColumn(label: Text('Actions')),
          ],
          rows: filteredPatrols.map((patrol) => _buildPatrolRow(context, patrol)).toList(),
        ),
      ),
    );
  }

  DataRow _buildPatrolRow(BuildContext context, Patrol patrol) {
    return DataRow(
      cells: [
        DataCell(Text('#${patrol.id}')),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                patrol.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (patrol.description?.isNotEmpty == true)
                Text(
                  patrol.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        DataCell(Text(patrol.siteName ?? 'N/A')),
        DataCell(Text(patrol.assignedToName ?? 'Unassigned')),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat('MMM dd, yyyy').format(patrol.scheduledStart)),
              Text(
                '${DateFormat('HH:mm').format(patrol.scheduledStart)} - ${DateFormat('HH:mm').format(patrol.scheduledEnd)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        DataCell(_buildStatusChip(patrol.status)),
        DataCell(_buildProgressIndicator(patrol)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _viewPatrolDetails(context, patrol),
                icon: const Icon(Icons.visibility),
                tooltip: 'View Details',
              ),
              PermissionGuard(
                requiredRoles: Permissions.patrolEdit,
                child: IconButton(
                  onPressed: () => _editPatrol(context, patrol),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                ),
              ),
              if (patrol.status == 'assigned')
                PermissionGuard(
                  requiredRoles: Permissions.patrolEdit,
                  child: IconButton(
                    onPressed: () => _startPatrol(patrol),
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Start Patrol',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'assigned':
        color = Colors.orange;
        icon = Icons.assignment;
        break;
      case 'active':
        color = Colors.blue;
        icon = Icons.play_circle;
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildProgressIndicator(Patrol patrol) {
    if (patrol.checkpointsTotal == 0) {
      return const Text('No checkpoints');
    }

    final progress = patrol.checkpointsCompleted / patrol.checkpointsTotal;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress == 1.0 ? Colors.green : Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${patrol.checkpointsCompleted}/${patrol.checkpointsTotal}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  List<Patrol> _getFilteredPatrols(List<Patrol> patrols) {
    return patrols.where((patrol) {
      // Status filter
      if (_statusFilter != null && patrol.status != _statusFilter) {
        return false;
      }
      
      // Search filter
      final searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isNotEmpty) {
        return patrol.title.toLowerCase().contains(searchTerm) ||
               (patrol.description?.toLowerCase().contains(searchTerm) ?? false) ||
               (patrol.siteName?.toLowerCase().contains(searchTerm) ?? false) ||
               (patrol.assignedToName?.toLowerCase().contains(searchTerm) ?? false);
      }
      
      return true;
    }).toList();
  }

  void _filterPatrols() {
    ref.read(patrolsProvider.notifier).loadPatrols(
      status: _statusFilter,
    );
  }

  void _viewPatrolDetails(BuildContext context, Patrol patrol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patrol Details: ${patrol.title}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', '#${patrol.id}'),
              _buildDetailRow('Site', patrol.siteName ?? 'N/A'),
              _buildDetailRow('Assigned To', patrol.assignedToName ?? 'Unassigned'),
              _buildDetailRow('Status', patrol.status.toUpperCase()),
              _buildDetailRow('Scheduled Start', DateFormat('MMM dd, yyyy HH:mm').format(patrol.scheduledStart)),
              _buildDetailRow('Scheduled End', DateFormat('MMM dd, yyyy HH:mm').format(patrol.scheduledEnd)),
              _buildDetailRow('Checkpoints', '${patrol.checkpointsCompleted}/${patrol.checkpointsTotal}'),
              if (patrol.description?.isNotEmpty == true)
                _buildDetailRow('Description', patrol.description!),
              if (patrol.actualStart != null)
                _buildDetailRow('Actual Start', DateFormat('MMM dd, yyyy HH:mm').format(patrol.actualStart!)),
              if (patrol.actualEnd != null)
                _buildDetailRow('Actual End', DateFormat('MMM dd, yyyy HH:mm').format(patrol.actualEnd!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
            width: 120,
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

  void _editPatrol(BuildContext context, Patrol patrol) {
    // TODO: Implement edit patrol dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit patrol functionality coming soon')),
    );
  }

  void _startPatrol(Patrol patrol) {
    // TODO: Implement start patrol functionality
    ref.read(patrolsProvider.notifier).startPatrol(patrol.id);
  }

  void _exportPatrols() {
    // TODO: Implement patrol export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }
}
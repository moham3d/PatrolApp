import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/checkpoint.dart';
import '../../../shared/models/user.dart';
import '../../../shared/models/patrol.dart';
import '../../../shared/services/checkpoint_service.dart';
import '../../../core/services/http_client.dart';
import '../../../core/utils/api_exceptions.dart';

/// Widget for tracking and validating checkpoint visits
class CheckpointVisitTracker extends ConsumerStatefulWidget {
  final Checkpoint checkpoint;
  
  const CheckpointVisitTracker({
    super.key,
    required this.checkpoint,
  });

  @override
  ConsumerState<CheckpointVisitTracker> createState() => _CheckpointVisitTrackerState();
}

class _CheckpointVisitTrackerState extends ConsumerState<CheckpointVisitTracker> {
  List<CheckpointVisit> _visits = [];
  bool _isLoading = false;
  String? _error;
  String _selectedPeriod = '7days';

  @override
  void initState() {
    super.initState();
    _loadCheckpointVisits();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visit History',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.checkpoint.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Filters and stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  // Period filter
                  SizedBox(
                    width: 150,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      decoration: const InputDecoration(
                        labelText: 'Period',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: '1day', child: Text('Last 24 hours')),
                        DropdownMenuItem(value: '7days', child: Text('Last 7 days')),
                        DropdownMenuItem(value: '30days', child: Text('Last 30 days')),
                        DropdownMenuItem(value: '90days', child: Text('Last 90 days')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value!;
                        });
                        _loadCheckpointVisits();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Refresh button
                  IconButton(
                    onPressed: _loadCheckpointVisits,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                  
                  const Spacer(),
                  
                  // Visit statistics
                  if (_visits.isNotEmpty) _buildVisitStats(),
                ],
              ),
            ),
            
            // Visit list
            Expanded(
              child: _buildVisitList(),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _exportVisitHistory,
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitStats() {
    final totalVisits = _visits.length;
    final uniqueGuards = _visits.map((v) => v.guardId).toSet().length;
    final averageVisitTime = _calculateAverageVisitTime();
    
    return Row(
      children: [
        _buildStatChip('Total Visits', totalVisits.toString(), Colors.blue),
        const SizedBox(width: 8),
        _buildStatChip('Guards', uniqueGuards.toString(), Colors.green),
        const SizedBox(width: 8),
        _buildStatChip('Avg Time', '${averageVisitTime.toStringAsFixed(1)}min', Colors.orange),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildVisitList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
              'Error loading visit history',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCheckpointVisits,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_visits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No visits recorded'),
            Text('Visits will appear here once guards start patrolling'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visits.length,
      itemBuilder: (context, index) {
        final visit = _visits[index];
        return _buildVisitCard(visit);
      },
    );
  }

  Widget _buildVisitCard(CheckpointVisit visit) {
    final isValidated = visit.isValidated;
    final hasPhoto = visit.photoUrl != null;
    final hasNotes = visit.notes?.isNotEmpty == true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isValidated ? Colors.green : Colors.orange,
                  child: Icon(
                    isValidated ? Icons.check : Icons.pending,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.guardName ?? 'Unknown Guard',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm:ss').format(visit.visitTime),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                // Status badges
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasPhoto)
                      const Icon(Icons.photo_camera, size: 16, color: Colors.blue),
                    if (hasPhoto) const SizedBox(width: 4),
                    if (hasNotes)
                      const Icon(Icons.note, size: 16, color: Colors.green),
                    if (hasNotes) const SizedBox(width: 4),
                    Chip(
                      label: Text(
                        isValidated ? 'VERIFIED' : 'PENDING',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: isValidated ? Colors.green : Colors.orange,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Visit details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.schedule,
                    'Duration',
                    '${visit.duration.toStringAsFixed(1)} minutes',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.assignment,
                    'Patrol',
                    visit.patrolTitle ?? 'N/A',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.qr_code,
                    'Method',
                    visit.visitMethod ?? 'Manual',
                  ),
                ),
              ],
            ),
            
            // Notes
            if (hasNotes) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(visit.notes!),
                  ],
                ),
              ),
            ],
            
            // Actions
            const SizedBox(height: 12),
            Row(
              children: [
                if (hasPhoto)
                  TextButton.icon(
                    onPressed: () => _showPhoto(visit),
                    icon: const Icon(Icons.photo),
                    label: const Text('View Photo'),
                  ),
                const Spacer(),
                if (!isValidated)
                  FilledButton.icon(
                    onPressed: () => _validateVisit(visit),
                    icon: const Icon(Icons.check),
                    label: const Text('Validate'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadCheckpointVisits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final httpClient = ref.read(httpClientProvider);
      final endDate = DateTime.now();
      final startDate = _getStartDateForPeriod(endDate);
      
      final response = await httpClient.get<List<dynamic>>(
        '/checkpoints/${widget.checkpoint.id}/visits',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      if (response.data != null) {
        final visits = (response.data as List<dynamic>)
            .map((json) => CheckpointVisit.fromJson(json as Map<String, dynamic>))
            .toList();
        
        setState(() {
          _visits = visits;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  DateTime _getStartDateForPeriod(DateTime endDate) {
    switch (_selectedPeriod) {
      case '1day':
        return endDate.subtract(const Duration(days: 1));
      case '7days':
        return endDate.subtract(const Duration(days: 7));
      case '30days':
        return endDate.subtract(const Duration(days: 30));
      case '90days':
        return endDate.subtract(const Duration(days: 90));
      default:
        return endDate.subtract(const Duration(days: 7));
    }
  }

  double _calculateAverageVisitTime() {
    if (_visits.isEmpty) return 0.0;
    final totalTime = _visits.fold<double>(0.0, (sum, visit) => sum + visit.duration);
    return totalTime / _visits.length;
  }

  void _showPhoto(CheckpointVisit visit) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Visit Photo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Photo would be displayed here'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Taken: ${DateFormat('MMM dd, yyyy HH:mm').format(visit.visitTime)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateVisit(CheckpointVisit visit) {
    // TODO: Implement visit validation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visit validation functionality coming soon')),
    );
  }

  void _exportVisitHistory() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }
}

/// Model for checkpoint visits
class CheckpointVisit {
  final int id;
  final int checkpointId;
  final int guardId;
  final String? guardName;
  final int? patrolId;
  final String? patrolTitle;
  final DateTime visitTime;
  final double duration;
  final bool isValidated;
  final String? notes;
  final String? photoUrl;
  final String? visitMethod; // 'manual', 'qr_code', 'nfc'

  const CheckpointVisit({
    required this.id,
    required this.checkpointId,
    required this.guardId,
    this.guardName,
    this.patrolId,
    this.patrolTitle,
    required this.visitTime,
    required this.duration,
    this.isValidated = false,
    this.notes,
    this.photoUrl,
    this.visitMethod,
  });

  factory CheckpointVisit.fromJson(Map<String, dynamic> json) {
    return CheckpointVisit(
      id: json['id'] ?? 0,
      checkpointId: json['checkpoint_id'] ?? 0,
      guardId: json['guard_id'] ?? 0,
      guardName: json['guard_name'],
      patrolId: json['patrol_id'],
      patrolTitle: json['patrol_title'],
      visitTime: DateTime.parse(json['visit_time'] ?? DateTime.now().toIso8601String()),
      duration: (json['duration'] ?? 0.0).toDouble(),
      isValidated: json['is_validated'] ?? false,
      notes: json['notes'],
      photoUrl: json['photo_url'],
      visitMethod: json['visit_method'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'checkpoint_id': checkpointId,
    'guard_id': guardId,
    'guard_name': guardName,
    'patrol_id': patrolId,
    'patrol_title': patrolTitle,
    'visit_time': visitTime.toIso8601String(),
    'duration': duration,
    'is_validated': isValidated,
    'notes': notes,
    'photo_url': photoUrl,
    'visit_method': visitMethod,
  };
}
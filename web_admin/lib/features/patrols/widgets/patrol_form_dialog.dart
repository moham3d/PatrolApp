import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/patrol.dart';
import '../../../shared/models/site.dart';
import '../../../shared/models/user.dart';
import '../../../shared/models/checkpoint.dart';
import '../../../features/sites/providers/sites_provider.dart';
import '../../../features/users/providers/users_provider.dart';
import '../../../features/checkpoints/providers/checkpoints_provider.dart';
import '../providers/patrols_provider.dart';

/// Dialog for creating and editing patrols
class PatrolFormDialog extends ConsumerStatefulWidget {
  final Patrol? patrol; // null for create, non-null for edit

  const PatrolFormDialog({super.key, this.patrol});

  @override
  ConsumerState<PatrolFormDialog> createState() => _PatrolFormDialogState();
}

class _PatrolFormDialogState extends ConsumerState<PatrolFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Site? _selectedSite;
  User? _selectedAssignee;
  DateTime? _scheduledStart;
  DateTime? _scheduledEnd;
  List<Checkpoint> _selectedCheckpoints = [];
  String _priority = 'normal';
  String _taskType = 'patrol';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sitesProvider.notifier).loadSites();
      ref.read(usersProvider.notifier).loadUsers();
    });
  }

  void _initializeForm() {
    if (widget.patrol != null) {
      final patrol = widget.patrol!;
      _titleController.text = patrol.title;
      _descriptionController.text = patrol.description ?? '';
      _scheduledStart = patrol.scheduledStart;
      _scheduledEnd = patrol.scheduledEnd;
      _priority = patrol.priority;
      _taskType = patrol.taskType;

      // Note: Site, assignee, and checkpoints would need to be loaded separately
      // in a real implementation based on the patrol data
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sitesState = ref.watch(sitesProvider);
    final usersState = ref.watch(usersProvider);
    final checkpointsState = ref.watch(checkpointsProvider);

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  Icon(
                    widget.patrol == null ? Icons.add_task : Icons.edit,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.patrol == null
                          ? 'Schedule New Patrol'
                          : 'Edit Patrol',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic information
                        _buildBasicInfoSection(),
                        const SizedBox(height: 24),

                        // Scheduling
                        _buildSchedulingSection(),
                        const SizedBox(height: 24),

                        // Assignment
                        _buildAssignmentSection(sitesState, usersState),
                        const SizedBox(height: 24),

                        // Checkpoints
                        if (_selectedSite != null)
                          _buildCheckpointsSection(checkpointsState),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _isLoading ? null : _savePatrol,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.patrol == null
                                ? 'Create Patrol'
                                : 'Update Patrol',
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Title
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Patrol Title *',
            hintText: 'Enter a descriptive title for the patrol',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a patrol title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Description
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Optional description or special instructions',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
        ),
        const SizedBox(height: 16),

        // Priority and Type
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                  DropdownMenuItem(
                    value: 'normal',
                    child: Text('Normal Priority'),
                  ),
                  DropdownMenuItem(value: 'high', child: Text('High Priority')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _taskType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'patrol',
                    child: Text('Regular Patrol'),
                  ),
                  DropdownMenuItem(
                    value: 'inspection',
                    child: Text('Inspection'),
                  ),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text('Maintenance Check'),
                  ),
                  DropdownMenuItem(
                    value: 'emergency',
                    child: Text('Emergency Response'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _taskType = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSchedulingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduling',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeField(
                label: 'Start Date & Time *',
                value: _scheduledStart,
                onChanged: (dateTime) {
                  setState(() {
                    _scheduledStart = dateTime;
                    // Auto-set end time to 2 hours later if not set
                    if (_scheduledEnd == null && dateTime != null) {
                      _scheduledEnd = dateTime.add(const Duration(hours: 2));
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateTimeField(
                label: 'End Date & Time *',
                value: _scheduledEnd,
                onChanged: (dateTime) {
                  setState(() {
                    _scheduledEnd = dateTime;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
  }) {
    return InkWell(
      onTap: () => _selectDateTime(context, value, onChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.schedule),
        ),
        child: Text(
          value != null
              ? DateFormat('MMM dd, yyyy HH:mm').format(value)
              : 'Select date and time',
          style: TextStyle(
            color: value != null
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentSection(SitesState sitesState, UsersState usersState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assignment',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Site>(
                value: _selectedSite,
                decoration: const InputDecoration(
                  labelText: 'Site *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: sitesState.sites.map((site) {
                  return DropdownMenuItem<Site>(
                    value: site,
                    child: Text(site.name),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a site';
                  }
                  return null;
                },
                onChanged: (site) {
                  setState(() {
                    _selectedSite = site;
                    _selectedCheckpoints = [];
                  });

                  if (site != null) {
                    ref
                        .read(checkpointsProvider.notifier)
                        .setFilters(siteId: site.id);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<User>(
                value: _selectedAssignee,
                decoration: const InputDecoration(
                  labelText: 'Assigned To',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: usersState.users
                    .where(
                  (user) => [
                    'guard',
                    'supervisor',
                    'site_manager',
                  ].any((role) => user.roles.contains(role)),
                )
                    .map((user) {
                  return DropdownMenuItem<User>(
                    value: user,
                    child: Text('${user.firstName} ${user.lastName}'),
                  );
                }).toList(),
                onChanged: (user) {
                  setState(() {
                    _selectedAssignee = user;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckpointsSection(CheckpointsState checkpointsState) {
    final availableCheckpoints = checkpointsState.checkpoints
        .where((checkpoint) => checkpoint.siteId == _selectedSite!.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Checkpoints',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (availableCheckpoints.isNotEmpty) ...[
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCheckpoints = List.from(availableCheckpoints);
                  });
                },
                child: const Text('Select All'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCheckpoints = [];
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (availableCheckpoints.isEmpty)
          Card(
            color: Colors.orange[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No checkpoints available for this site. The patrol will be a general patrol without specific checkpoints.',
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: availableCheckpoints.length,
              itemBuilder: (context, index) {
                final checkpoint = availableCheckpoints[index];
                final isSelected = _selectedCheckpoints.contains(checkpoint);

                return CheckboxListTile(
                  title: Text(checkpoint.name),
                  subtitle: Text(checkpoint.description ?? 'No description'),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedCheckpoints.add(checkpoint);
                      } else {
                        _selectedCheckpoints.remove(checkpoint);
                      }
                    });
                  },
                  secondary: const Icon(Icons.location_on),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    DateTime? currentValue,
    Function(DateTime?) onChanged,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onChanged(dateTime);
      }
    }
  }

  Future<void> _savePatrol() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_scheduledStart == null || _scheduledEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return;
    }

    if (_scheduledEnd!.isBefore(_scheduledStart!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreatePatrolRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        siteId: _selectedSite!.id,
        assignedToId: _selectedAssignee?.id,
        scheduledStart: _scheduledStart!,
        scheduledEnd: _scheduledEnd!,
        priority: _priority,
        taskType: _taskType,
      );

      bool success;
      if (widget.patrol == null) {
        success =
            await ref.read(patrolsProvider.notifier).createPatrol(request);
      } else {
        // Implement update patrol
        final updateRequest = UpdatePatrolRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          siteId: _selectedSite!.id,
          assignedToId: _selectedAssignee?.id,
          scheduledStart: _scheduledStart!,
          scheduledEnd: _scheduledEnd!,
          priority: _priority,
          taskType: _taskType,
        );
        success = await ref.read(patrolsProvider.notifier).updatePatrol(
          widget.patrol!.id,
          updateRequest,
        );
      }

      if (success && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.patrol == null
                  ? 'Patrol created successfully'
                  : 'Patrol updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

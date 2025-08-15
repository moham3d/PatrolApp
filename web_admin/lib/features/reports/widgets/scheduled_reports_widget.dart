import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/report.dart';
import '../providers/reports_provider.dart';

/// Widget for managing scheduled reports
class ScheduledReportsWidget extends ConsumerWidget {
  const ScheduledReportsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledReportsAsync = ref.watch(scheduledReportsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scheduled Reports',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateScheduledReportDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Schedule Report'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: scheduledReportsAsync.when(
              data: (scheduledReports) {
                if (scheduledReports.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  itemCount: scheduledReports.length,
                  itemBuilder: (context, index) {
                    final scheduledReport = scheduledReports[index];
                    return _buildScheduledReportCard(context, ref, scheduledReport);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load scheduled reports',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(scheduledReportsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Scheduled Reports',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule reports to be automatically generated and delivered via email.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledReportCard(
    BuildContext context,
    WidgetRef ref,
    ScheduledReport scheduledReport,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            scheduledReport.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            scheduledReport.isActive ? Icons.play_circle : Icons.pause_circle,
                            color: scheduledReport.isActive ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Template ID: ${scheduledReport.templateId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        leading: Icon(
                          scheduledReport.isActive ? Icons.pause : Icons.play_arrow,
                        ),
                        title: Text(scheduledReport.isActive ? 'Disable' : 'Enable'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Schedule'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'run_now',
                      child: ListTile(
                        leading: Icon(Icons.play_arrow),
                        title: Text('Run Now'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleScheduledReportAction(
                    context,
                    ref,
                    scheduledReport,
                    value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Schedule details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.repeat,
                    'Frequency',
                    scheduledReport.frequency.toUpperCase(),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.schedule,
                    'Next Run',
                    DateFormat.yMMMd().add_jm().format(scheduledReport.nextRun),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email recipients
            _buildDetailItem(
              context,
              Icons.email,
              'Recipients',
              scheduledReport.emailRecipients.join(', '),
            ),

            if (scheduledReport.createdAt != null) ...[
              const SizedBox(height: 12),
              _buildDetailItem(
                context,
                Icons.calendar_today,
                'Created',
                DateFormat.yMMMd().format(scheduledReport.createdAt!),
              ),
            ],

            const SizedBox(height: 16),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: scheduledReport.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheduledReport.isActive ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    scheduledReport.isActive ? Icons.check_circle : Icons.pause_circle,
                    size: 16,
                    color: scheduledReport.isActive ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    scheduledReport.isActive ? 'Active' : 'Paused',
                    style: TextStyle(
                      color: scheduledReport.isActive ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
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

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  void _handleScheduledReportAction(
    BuildContext context,
    WidgetRef ref,
    ScheduledReport scheduledReport,
    String action,
  ) {
    switch (action) {
      case 'toggle':
        _toggleScheduledReport(ref, scheduledReport);
        break;
      case 'edit':
        _editScheduledReport(context, ref, scheduledReport);
        break;
      case 'run_now':
        _runNow(context, ref, scheduledReport);
        break;
      case 'delete':
        _deleteScheduledReport(context, ref, scheduledReport);
        break;
    }
  }

  void _toggleScheduledReport(WidgetRef ref, ScheduledReport scheduledReport) {
    if (scheduledReport.id != null) {
      ref.read(scheduledReportsProvider.notifier).toggleScheduledReport(
        scheduledReport.id!,
        !scheduledReport.isActive,
      );
    }
  }

  void _editScheduledReport(BuildContext context, WidgetRef ref, ScheduledReport scheduledReport) {
    // TODO: Implement edit scheduled report dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit scheduled report functionality coming soon')),
    );
  }

  void _runNow(BuildContext context, WidgetRef ref, ScheduledReport scheduledReport) {
    // TODO: Implement run now functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Run now functionality coming soon')),
    );
  }

  Future<void> _deleteScheduledReport(
    BuildContext context,
    WidgetRef ref,
    ScheduledReport scheduledReport,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scheduled Report'),
        content: Text('Are you sure you want to delete "${scheduledReport.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && scheduledReport.id != null) {
      await ref.read(scheduledReportsProvider.notifier).deleteScheduledReport(
        scheduledReport.id!,
      );
    }
  }

  void _showCreateScheduledReportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreateScheduledReportDialog(),
    );
  }
}

/// Dialog for creating a new scheduled report
class CreateScheduledReportDialog extends ConsumerStatefulWidget {
  const CreateScheduledReportDialog({super.key});

  @override
  ConsumerState<CreateScheduledReportDialog> createState() =>
      _CreateScheduledReportDialogState();
}

class _CreateScheduledReportDialogState extends ConsumerState<CreateScheduledReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  int? _selectedTemplateId;
  String _frequency = 'weekly';
  final List<String> _emailRecipients = [];
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(reportTemplatesProvider);

    return AlertDialog(
      title: const Text('Schedule Report'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Schedule Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a schedule name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              templatesAsync.when(
                data: (templates) => DropdownButtonFormField<int>(
                  value: _selectedTemplateId,
                  decoration: const InputDecoration(
                    labelText: 'Report Template',
                    border: OutlineInputBorder(),
                  ),
                  items: templates.map((template) {
                    return DropdownMenuItem(
                      value: template.id,
                      child: Text(template.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTemplateId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a template';
                    }
                    return null;
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading templates'),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _frequency = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Recipient',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Invalid email format';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addEmailRecipient,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_emailRecipients.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _emailRecipients.map((email) {
                    return Chip(
                      label: Text(email),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _emailRecipients.remove(email);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],

              if (_emailRecipients.isEmpty)
                Text(
                  'Add at least one email recipient',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isCreating ? null : _createScheduledReport,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Schedule'),
        ),
      ],
    );
  }

  void _addEmailRecipient() {
    if (_emailController.text.isNotEmpty) {
      final email = _emailController.text.trim();
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      
      if (emailRegex.hasMatch(email) && !_emailRecipients.contains(email)) {
        setState(() {
          _emailRecipients.add(email);
          _emailController.clear();
        });
      }
    }
  }

  Future<void> _createScheduledReport() async {
    if (!_formKey.currentState!.validate() || _emailRecipients.isEmpty) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final request = CreateScheduledReportRequest(
        name: _nameController.text.trim(),
        templateId: _selectedTemplateId!,
        frequency: _frequency,
        emailRecipients: _emailRecipients,
      );

      await ref.read(scheduledReportsProvider.notifier).createScheduledReport(request);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scheduled report created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create scheduled report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
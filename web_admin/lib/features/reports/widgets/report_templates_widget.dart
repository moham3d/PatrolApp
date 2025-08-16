import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/report.dart';
import '../providers/reports_provider.dart';

/// Widget for managing report templates
class ReportTemplatesWidget extends ConsumerWidget {
  const ReportTemplatesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(reportTemplatesProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report Templates',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateTemplateDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Create Template'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: templatesAsync.when(
              data: (templates) {
                if (templates.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return _buildTemplateCard(context, ref, template);
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
                      'Failed to load templates',
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
                      onPressed: () => ref.invalidate(reportTemplatesProvider),
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
            Icons.bookmark_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Report Templates',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first report template to save time generating reports with the same configuration.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WidgetRef ref, ReportTemplate template) {
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
                      Text(
                        template.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (template.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          template.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'use',
                      child: ListTile(
                        leading: Icon(Icons.play_arrow),
                        title: Text('Use Template'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Template'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: ListTile(
                        leading: Icon(Icons.copy),
                        title: Text('Duplicate'),
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
                  onSelected: (value) => _handleTemplateAction(context, ref, template, value),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Template details
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildDetailChip(
                  context,
                  Icons.storage,
                  'Data Source',
                  template.dataSource.toUpperCase(),
                ),
                _buildDetailChip(
                  context,
                  Icons.view_column,
                  'Columns',
                  '${template.columns.length} selected',
                ),
                _buildDetailChip(
                  context,
                  Icons.file_download,
                  'Format',
                  template.exportFormat.toUpperCase(),
                ),
                if (template.createdAt != null)
                  _buildDetailChip(
                    context,
                    Icons.schedule,
                    'Created',
                    DateFormat.yMd().format(template.createdAt!),
                  ),
              ],
            ),

            if (template.filters.dateRange != null ||
                template.filters.siteIds != null ||
                template.filters.userIds != null ||
                template.filters.status != null ||
                template.filters.priority != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Filters'),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (template.filters.dateRange != null)
                    ListTile(
                      leading: const Icon(Icons.date_range),
                      title: const Text('Date Range'),
                      subtitle: Text(
                        '${DateFormat.yMd().format(template.filters.dateRange!.startDate)} - '
                        '${DateFormat.yMd().format(template.filters.dateRange!.endDate)}',
                      ),
                      dense: true,
                    ),
                  if (template.filters.siteIds != null)
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Sites'),
                      subtitle: Text('${template.filters.siteIds!.length} sites selected'),
                      dense: true,
                    ),
                  if (template.filters.userIds != null)
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Users'),
                      subtitle: Text('${template.filters.userIds!.length} users selected'),
                      dense: true,
                    ),
                  if (template.filters.status != null)
                    ListTile(
                      leading: const Icon(Icons.flag),
                      title: const Text('Status'),
                      subtitle: Text(template.filters.status!),
                      dense: true,
                    ),
                  if (template.filters.priority != null)
                    ListTile(
                      leading: const Icon(Icons.priority_high),
                      title: const Text('Priority'),
                      subtitle: Text(template.filters.priority!),
                      dense: true,
                    ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _useTemplate(context, ref, template),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Generate Report'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _scheduleTemplate(context, ref, template),
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(BuildContext context, IconData icon, String label, String value) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text('$label: $value'),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }

  void _handleTemplateAction(
    BuildContext context,
    WidgetRef ref,
    ReportTemplate template,
    String action,
  ) {
    switch (action) {
      case 'use':
        _useTemplate(context, ref, template);
        break;
      case 'edit':
        _editTemplate(context, ref, template);
        break;
      case 'duplicate':
        _duplicateTemplate(context, ref, template);
        break;
      case 'delete':
        _deleteTemplate(context, ref, template);
        break;
    }
  }

  Future<void> _useTemplate(BuildContext context, WidgetRef ref, ReportTemplate template) async {
    try {
      final request = GenerateReportRequest(
        templateId: template.id,
        dataSource: template.dataSource,
        columns: template.columns,
        filters: template.filters,
        exportFormat: template.exportFormat,
      );

      String downloadUrl;
      if (template.exportFormat == 'pdf') {
        downloadUrl = await ref.read(reportGenerationProvider.notifier).exportToPdf(request);
      } else {
        downloadUrl = await ref.read(reportGenerationProvider.notifier).exportToCsv(request);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report generated successfully! Download: $downloadUrl'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Download',
              onPressed: () {
                // Implement download functionality
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editTemplate(BuildContext context, WidgetRef ref, ReportTemplate template) {
    // TODO: Implement edit template dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit template functionality coming soon')),
    );
  }

  void _duplicateTemplate(BuildContext context, WidgetRef ref, ReportTemplate template) {
    final request = CreateReportTemplateRequest(
      name: '${template.name} (Copy)',
      description: template.description,
      dataSource: template.dataSource,
      columns: template.columns,
      filters: template.filters,
      exportFormat: template.exportFormat,
    );

    ref.read(reportTemplatesProvider.notifier).createTemplate(request);
  }

  Future<void> _deleteTemplate(BuildContext context, WidgetRef ref, ReportTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
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

    if (confirmed == true && template.id != null) {
      await ref.read(reportTemplatesProvider.notifier).deleteTemplate(template.id!);
    }
  }

  void _scheduleTemplate(BuildContext context, WidgetRef ref, ReportTemplate template) {
    // TODO: Implement schedule template dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule template functionality coming soon')),
    );
  }

  void _showCreateTemplateDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement create template dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create template dialog coming soon - use Report Builder')),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/report.dart';
import '../../../shared/models/site.dart';
import '../../../shared/models/user.dart';
import '../../sites/providers/sites_provider.dart';
import '../../users/providers/users_provider.dart';
import '../providers/reports_provider.dart';

/// Comprehensive report builder widget for creating custom reports
class ReportBuilderWidget extends ConsumerStatefulWidget {
  const ReportBuilderWidget({super.key});

  @override
  ConsumerState<ReportBuilderWidget> createState() => _ReportBuilderWidgetState();
}

class _ReportBuilderWidgetState extends ConsumerState<ReportBuilderWidget> {
  final _formKey = GlobalKey<FormState>();
  final _reportNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedDataSource = 'patrols';
  String _exportFormat = 'pdf';
  List<ReportColumn> _selectedColumns = [];
  DateTime? _startDate;
  DateTime? _endDate;
  List<int> _selectedSiteIds = [];
  List<int> _selectedUserIds = [];
  String? _statusFilter;
  String? _priorityFilter;

  bool _isGenerating = false;
  bool _saveAsTemplate = false;

  // Available data sources and their columns
  final Map<String, List<Map<String, String>>> _dataSourceColumns = {
    'users': [
      {'field': 'id', 'label': 'ID', 'type': 'number'},
      {'field': 'username', 'label': 'Username', 'type': 'text'},
      {'field': 'email', 'label': 'Email', 'type': 'text'},
      {'field': 'full_name', 'label': 'Full Name', 'type': 'text'},
      {'field': 'phone', 'label': 'Phone', 'type': 'text'},
      {'field': 'roles', 'label': 'Roles', 'type': 'text'},
      {'field': 'is_active', 'label': 'Active', 'type': 'boolean'},
      {'field': 'created_at', 'label': 'Created Date', 'type': 'date'},
    ],
    'sites': [
      {'field': 'id', 'label': 'ID', 'type': 'number'},
      {'field': 'name', 'label': 'Site Name', 'type': 'text'},
      {'field': 'address', 'label': 'Address', 'type': 'text'},
      {'field': 'type', 'label': 'Site Type', 'type': 'text'},
      {'field': 'is_active', 'label': 'Active', 'type': 'boolean'},
      {'field': 'created_at', 'label': 'Created Date', 'type': 'date'},
    ],
    'patrols': [
      {'field': 'id', 'label': 'ID', 'type': 'number'},
      {'field': 'title', 'label': 'Title', 'type': 'text'},
      {'field': 'status', 'label': 'Status', 'type': 'text'},
      {'field': 'priority', 'label': 'Priority', 'type': 'text'},
      {'field': 'assigned_to', 'label': 'Assigned To', 'type': 'text'},
      {'field': 'site', 'label': 'Site', 'type': 'text'},
      {'field': 'scheduled_start', 'label': 'Scheduled Start', 'type': 'date'},
      {'field': 'scheduled_end', 'label': 'Scheduled End', 'type': 'date'},
      {'field': 'actual_start', 'label': 'Actual Start', 'type': 'date'},
      {'field': 'actual_end', 'label': 'Actual End', 'type': 'date'},
    ],
    'checkpoints': [
      {'field': 'id', 'label': 'ID', 'type': 'number'},
      {'field': 'name', 'label': 'Name', 'type': 'text'},
      {'field': 'site_id', 'label': 'Site ID', 'type': 'number'},
      {'field': 'is_active', 'label': 'Active', 'type': 'boolean'},
      {'field': 'visit_duration', 'label': 'Visit Duration', 'type': 'number'},
      {'field': 'qr_code', 'label': 'QR Code', 'type': 'text'},
      {'field': 'nfc_tag', 'label': 'NFC Tag', 'type': 'text'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeDefaultColumns();
  }

  @override
  void dispose() {
    _reportNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeDefaultColumns() {
    final columns = _dataSourceColumns[_selectedDataSource] ?? [];
    _selectedColumns = columns.take(5).map((col) => ReportColumn(
      field: col['field']!,
      label: col['label']!,
      type: col['type']!,
      visible: true,
      order: columns.indexOf(col),
    )).toList();
  }

  void _onDataSourceChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedDataSource = value;
        _initializeDefaultColumns();
      });
    }
  }

  void _toggleColumn(Map<String, String> columnData, bool selected) {
    setState(() {
      if (selected) {
        _selectedColumns.add(ReportColumn(
          field: columnData['field']!,
          label: columnData['label']!,
          type: columnData['type']!,
          visible: true,
          order: _selectedColumns.length,
        ));
      } else {
        _selectedColumns.removeWhere(
          (col) => col.field == columnData['field'],
        );
      }
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _generateReport() async {
    if (!_formKey.currentState!.validate() || _selectedColumns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and select at least one column'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final filters = ReportFilters(
        dateRange: _startDate != null && _endDate != null
            ? DateRange(startDate: _startDate!, endDate: _endDate!)
            : null,
        siteIds: _selectedSiteIds.isNotEmpty ? _selectedSiteIds : null,
        userIds: _selectedUserIds.isNotEmpty ? _selectedUserIds : null,
        status: _statusFilter,
        priority: _priorityFilter,
      );

      final request = GenerateReportRequest(
        dataSource: _selectedDataSource,
        columns: _selectedColumns,
        filters: filters,
        exportFormat: _exportFormat,
      );

      // Save as template if requested
      if (_saveAsTemplate && _reportNameController.text.isNotEmpty) {
        final templateRequest = CreateReportTemplateRequest(
          name: _reportNameController.text,
          description: _descriptionController.text,
          dataSource: _selectedDataSource,
          columns: _selectedColumns,
          filters: filters,
          exportFormat: _exportFormat,
        );
        
        await ref.read(reportTemplatesProvider.notifier).createTemplate(templateRequest);
      }

      // Generate the report
      String downloadUrl;
      if (_exportFormat == 'pdf') {
        downloadUrl = await ref.read(reportGenerationProvider.notifier).exportToPdf(request);
      } else {
        downloadUrl = await ref.read(reportGenerationProvider.notifier).exportToCsv(request);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report generated successfully! Download: $downloadUrl'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Download',
              onPressed: () {
                // Here you would implement actual download functionality
                // For web, you could use url_launcher or html package
                // For now, just show the URL
              },
            ),
          ),
        );

        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _resetForm() {
    _reportNameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDataSource = 'patrols';
      _exportFormat = 'pdf';
      _startDate = null;
      _endDate = null;
      _selectedSiteIds.clear();
      _selectedUserIds.clear();
      _statusFilter = null;
      _priorityFilter = null;
      _saveAsTemplate = false;
      _initializeDefaultColumns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(sitesProvider);
    final usersAsync = ref.watch(usersProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left panel - Configuration
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Configuration',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Report Name (for templates)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _reportNameController,
                              decoration: const InputDecoration(
                                labelText: 'Report Name',
                                hintText: 'Enter name to save as template',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          FilterChip(
                            label: const Text('Save as Template'),
                            selected: _saveAsTemplate,
                            onSelected: (selected) {
                              setState(() {
                                _saveAsTemplate = selected;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      if (_saveAsTemplate) ...[
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Data Source Selection
                      DropdownButtonFormField<String>(
                        value: _selectedDataSource,
                        decoration: const InputDecoration(
                          labelText: 'Data Source',
                          border: OutlineInputBorder(),
                        ),
                        items: _dataSourceColumns.keys.map((source) {
                          return DropdownMenuItem(
                            value: source,
                            child: Text(source.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: _onDataSourceChanged,
                      ),
                      const SizedBox(height: 16),

                      // Export Format
                      DropdownButtonFormField<String>(
                        value: _exportFormat,
                        decoration: const InputDecoration(
                          labelText: 'Export Format',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                          DropdownMenuItem(value: 'csv', child: Text('CSV')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _exportFormat = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Date Range
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDateRange,
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                _startDate != null && _endDate != null
                                    ? '${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}'
                                    : 'Select Date Range',
                              ),
                            ),
                          ),
                          if (_startDate != null && _endDate != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear Date Range',
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Site Filter
                      sitesAsync.when(
                        data: (sites) => MultiSelectChip<Site>(
                          title: 'Filter by Sites',
                          items: sites,
                          selectedIds: _selectedSiteIds,
                          onChanged: (selectedIds) {
                            setState(() {
                              _selectedSiteIds = selectedIds;
                            });
                          },
                          getItemId: (site) => site.id,
                          getItemLabel: (site) => site.name,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading sites'),
                      ),
                      const SizedBox(height: 16),

                      // User Filter (for applicable data sources)
                      if (_selectedDataSource == 'patrols') ...[
                        usersAsync.when(
                          data: (usersResponse) => MultiSelectChip<User>(
                            title: 'Filter by Users',
                            items: usersResponse.items,
                            selectedIds: _selectedUserIds,
                            onChanged: (selectedIds) {
                              setState(() {
                                _selectedUserIds = selectedIds;
                              });
                            },
                            getItemId: (user) => user.id,
                            getItemLabel: (user) => user.fullName,
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Error loading users'),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Status and Priority filters for patrols
                      if (_selectedDataSource == 'patrols') ...[
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _statusFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Status Filter',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('All')),
                                  DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _statusFilter = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _priorityFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Priority Filter',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('All')),
                                  DropdownMenuItem(value: 'low', child: Text('Low')),
                                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                  DropdownMenuItem(value: 'high', child: Text('High')),
                                  DropdownMenuItem(value: 'critical', child: Text('Critical')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _priorityFilter = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateReport,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.file_download),
                          label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 24),

            // Right panel - Column Selection
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Column Selection',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select columns to include in your report:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: ListView(
                          children: _dataSourceColumns[_selectedDataSource]!
                              .map((columnData) {
                            final isSelected = _selectedColumns
                                .any((col) => col.field == columnData['field']);
                            
                            return CheckboxListTile(
                              title: Text(columnData['label']!),
                              subtitle: Text(
                                '${columnData['field']} (${columnData['type']})',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              value: isSelected,
                              onChanged: (selected) {
                                _toggleColumn(columnData, selected ?? false);
                              },
                              dense: true,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multi-select chip widget for filtering
class MultiSelectChip<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final List<int> selectedIds;
  final Function(List<int>) onChanged;
  final int Function(T) getItemId;
  final String Function(T) getItemLabel;

  const MultiSelectChip({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
    required this.getItemId,
    required this.getItemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.take(10).map((item) {
            final id = getItemId(item);
            final label = getItemLabel(item);
            final isSelected = selectedIds.contains(id);
            
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                final newSelectedIds = List<int>.from(selectedIds);
                if (selected) {
                  newSelectedIds.add(id);
                } else {
                  newSelectedIds.remove(id);
                }
                onChanged(newSelectedIds);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
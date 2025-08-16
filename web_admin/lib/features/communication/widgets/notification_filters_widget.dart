import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/notification.dart';

/// Widget for filtering notifications
class NotificationFiltersWidget extends StatefulWidget {
  final Function(NotificationFilters) onFiltersChanged;
  final VoidCallback onClearFilters;

  const NotificationFiltersWidget({
    super.key,
    required this.onFiltersChanged,
    required this.onClearFilters,
  });

  @override
  State<NotificationFiltersWidget> createState() =>
      _NotificationFiltersWidgetState();
}

class _NotificationFiltersWidgetState extends State<NotificationFiltersWidget> {
  String? _selectedType;
  String? _selectedPriority;
  bool? _selectedReadStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _types = [
    'task_assignment',
    'patrol_update',
    'incident_alert',
    'security_alert',
    'system_update',
  ];

  final List<String> _priorities = [
    'low',
    'normal',
    'high',
    'urgent',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filters row
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Type filter
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Types'),
                      ),
                      ..._types.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(_getTypeDisplayName(type)),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),

                // Priority filter
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Priorities'),
                      ),
                      ..._priorities.map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority.toUpperCase()),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),

                // Read status filter
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<bool>(
                    value: _selectedReadStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem<bool>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('Unread'),
                      ),
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Read'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedReadStatus = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),

                // Start date filter
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        onPressed: () => _selectStartDate(context),
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _startDate != null
                          ? DateFormat.yMMMd().format(_startDate!)
                          : '',
                    ),
                    onTap: () => _selectStartDate(context),
                  ),
                ),

                // End date filter
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        onPressed: () => _selectEndDate(context),
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _endDate != null
                          ? DateFormat.yMMMd().format(_endDate!)
                          : '',
                    ),
                    onTap: () => _selectEndDate(context),
                  ),
                ),
              ],
            ),

            // Active filters summary
            if (_hasActiveFilters()) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildActiveFilterChips(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'task_assignment':
        return 'Task Assignment';
      case 'patrol_update':
        return 'Patrol Update';
      case 'incident_alert':
        return 'Incident Alert';
      case 'security_alert':
        return 'Security Alert';
      case 'system_update':
        return 'System Update';
      default:
        return type;
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
      });
      _applyFilters();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    final filters = NotificationFilters(
      type: _selectedType,
      priority: _selectedPriority,
      isRead: _selectedReadStatus,
      startDate: _startDate,
      endDate: _endDate,
    );

    widget.onFiltersChanged(filters);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _selectedPriority = null;
      _selectedReadStatus = null;
      _startDate = null;
      _endDate = null;
    });

    widget.onClearFilters();
  }

  bool _hasActiveFilters() {
    return _selectedType != null ||
        _selectedPriority != null ||
        _selectedReadStatus != null ||
        _startDate != null ||
        _endDate != null;
  }

  List<Widget> _buildActiveFilterChips() {
    final chips = <Widget>[];

    if (_selectedType != null) {
      chips.add(
        Chip(
          label: Text('Type: ${_getTypeDisplayName(_selectedType!)}'),
          onDeleted: () {
            setState(() {
              _selectedType = null;
            });
            _applyFilters();
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    if (_selectedPriority != null) {
      chips.add(
        Chip(
          label: Text('Priority: ${_selectedPriority!.toUpperCase()}'),
          onDeleted: () {
            setState(() {
              _selectedPriority = null;
            });
            _applyFilters();
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    if (_selectedReadStatus != null) {
      chips.add(
        Chip(
          label: Text('Status: ${_selectedReadStatus! ? 'Read' : 'Unread'}'),
          onDeleted: () {
            setState(() {
              _selectedReadStatus = null;
            });
            _applyFilters();
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    if (_startDate != null) {
      chips.add(
        Chip(
          label: Text('From: ${DateFormat.yMMMd().format(_startDate!)}'),
          onDeleted: () {
            setState(() {
              _startDate = null;
            });
            _applyFilters();
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    if (_endDate != null) {
      chips.add(
        Chip(
          label: Text('To: ${DateFormat.yMMMd().format(_endDate!)}'),
          onDeleted: () {
            setState(() {
              _endDate = null;
            });
            _applyFilters();
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    return chips;
  }
}
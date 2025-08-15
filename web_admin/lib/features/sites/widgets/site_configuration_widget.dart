import 'package:flutter/material.dart';
import '../../../shared/models/site.dart';

class SiteConfigurationWidget extends StatefulWidget {
  final SiteConfiguration? initialConfiguration;
  final ValueChanged<SiteConfiguration?> onConfigurationChanged;

  const SiteConfigurationWidget({
    super.key,
    this.initialConfiguration,
    required this.onConfigurationChanged,
  });

  @override
  State<SiteConfigurationWidget> createState() => _SiteConfigurationWidgetState();
}

class _SiteConfigurationWidgetState extends State<SiteConfigurationWidget> {
  late bool _is24_7;
  late String _securityLevel;
  late int _patrolFrequencyMinutes;
  late double _geofenceRadiusMeters;
  late String _timezone;
  
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _emergencyContacts = <EmergencyContact>[];
  final _equipmentRequired = <String>[];

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    final config = widget.initialConfiguration;
    _is24_7 = config?.operatingHours?.is24_7 ?? true;
    _securityLevel = config?.securityLevel ?? 'medium';
    _patrolFrequencyMinutes = config?.patrolFrequencyMinutes ?? 120;
    _geofenceRadiusMeters = config?.geofenceRadiusMeters ?? 100.0;
    _timezone = config?.timezone ?? 'UTC';
    
    _startTimeController.text = config?.operatingHours?.startTime ?? '09:00';
    _endTimeController.text = config?.operatingHours?.endTime ?? '17:00';
    _specialInstructionsController.text = config?.specialInstructions ?? '';
    
    if (config?.emergencyContacts != null) {
      _emergencyContacts.addAll(config!.emergencyContacts!);
    }
    
    if (config?.equipmentRequired != null) {
      _equipmentRequired.addAll(config!.equipmentRequired!);
    }
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  void _updateConfiguration() {
    final operatingHours = OperatingHours(
      is24_7: _is24_7,
      startTime: _is24_7 ? null : _startTimeController.text,
      endTime: _is24_7 ? null : _endTimeController.text,
      daysOfWeek: _is24_7 ? null : [1, 2, 3, 4, 5, 6, 7], // All days by default
    );

    final configuration = SiteConfiguration(
      operatingHours: operatingHours,
      securityLevel: _securityLevel,
      patrolFrequencyMinutes: _patrolFrequencyMinutes,
      emergencyContacts: _emergencyContacts.isEmpty ? null : _emergencyContacts,
      specialInstructions: _specialInstructionsController.text.isEmpty 
          ? null 
          : _specialInstructionsController.text,
      equipmentRequired: _equipmentRequired.isEmpty ? null : _equipmentRequired,
      geofenceRadiusMeters: _geofenceRadiusMeters,
      timezone: _timezone,
    );

    widget.onConfigurationChanged(configuration);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Site Configuration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Operating Hours
            _buildOperatingHoursSection(),
            const SizedBox(height: 16),

            // Security Level
            _buildSecurityLevelSection(),
            const SizedBox(height: 16),

            // Patrol Frequency
            _buildPatrolFrequencySection(),
            const SizedBox(height: 16),

            // Geofence Radius
            _buildGeofenceSection(),
            const SizedBox(height: 16),

            // Special Instructions
            _buildSpecialInstructionsSection(),
            const SizedBox(height: 16),

            // Emergency Contacts
            _buildEmergencyContactsSection(),
            const SizedBox(height: 16),

            // Equipment Required
            _buildEquipmentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operating Hours',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('24/7 Operation'),
          value: _is24_7,
          onChanged: (value) {
            setState(() {
              _is24_7 = value;
            });
            _updateConfiguration();
          },
        ),
        if (!_is24_7) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                    hintText: 'HH:MM',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _updateConfiguration(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                    hintText: 'HH:MM',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _updateConfiguration(),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSecurityLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Level',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _securityLevel,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'low', child: Text('Low')),
            DropdownMenuItem(value: 'medium', child: Text('Medium')),
            DropdownMenuItem(value: 'high', child: Text('High')),
            DropdownMenuItem(value: 'critical', child: Text('Critical')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _securityLevel = value;
              });
              _updateConfiguration();
            }
          },
        ),
      ],
    );
  }

  Widget _buildPatrolFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patrol Frequency',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _patrolFrequencyMinutes.toDouble(),
                min: 30,
                max: 480,
                divisions: 15,
                label: '${_patrolFrequencyMinutes ~/ 60}h ${_patrolFrequencyMinutes % 60}m',
                onChanged: (value) {
                  setState(() {
                    _patrolFrequencyMinutes = value.round();
                  });
                },
                onChangeEnd: (_) => _updateConfiguration(),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: Text(
                'Every ${_patrolFrequencyMinutes ~/ 60}h ${_patrolFrequencyMinutes % 60}m',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeofenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Geofence Radius',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _geofenceRadiusMeters,
                min: 10,
                max: 1000,
                divisions: 99,
                label: '${_geofenceRadiusMeters.round()}m',
                onChanged: (value) {
                  setState(() {
                    _geofenceRadiusMeters = value;
                  });
                },
                onChangeEnd: (_) => _updateConfiguration(),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: Text(
                '${_geofenceRadiusMeters.round()} meters',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Instructions',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _specialInstructionsController,
          decoration: const InputDecoration(
            hintText: 'Enter any special instructions for this site...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (_) => _updateConfiguration(),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Emergency Contacts',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addEmergencyContact,
              icon: const Icon(Icons.add),
              label: const Text('Add Contact'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_emergencyContacts.isEmpty)
          const Text('No emergency contacts added')
        else
          ..._emergencyContacts.asMap().entries.map((entry) {
            final index = entry.key;
            final contact = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(contact.name),
                subtitle: Text('${contact.phone}${contact.role != null ? ' - ${contact.role}' : ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeEmergencyContact(index),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Required Equipment',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addEquipment,
              icon: const Icon(Icons.add),
              label: const Text('Add Equipment'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_equipmentRequired.isEmpty)
          const Text('No required equipment specified')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _equipmentRequired.asMap().entries.map((entry) {
              final index = entry.key;
              final equipment = entry.value;
              return Chip(
                label: Text(equipment),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () => _removeEquipment(index),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addEmergencyContact() {
    showDialog(
      context: context,
      builder: (context) => _EmergencyContactDialog(
        onContactAdded: (contact) {
          setState(() {
            _emergencyContacts.add(contact);
          });
          _updateConfiguration();
        },
      ),
    );
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
    });
    _updateConfiguration();
  }

  void _addEquipment() {
    showDialog(
      context: context,
      builder: (context) => _EquipmentDialog(
        onEquipmentAdded: (equipment) {
          setState(() {
            _equipmentRequired.add(equipment);
          });
          _updateConfiguration();
        },
      ),
    );
  }

  void _removeEquipment(int index) {
    setState(() {
      _equipmentRequired.removeAt(index);
    });
    _updateConfiguration();
  }
}

class _EmergencyContactDialog extends StatefulWidget {
  final ValueChanged<EmergencyContact> onContactAdded;

  const _EmergencyContactDialog({required this.onContactAdded});

  @override
  State<_EmergencyContactDialog> createState() => __EmergencyContactDialogState();
}

class __EmergencyContactDialogState extends State<_EmergencyContactDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Emergency Contact'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true ? 'Phone is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: 'Role/Position',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final contact = EmergencyContact(
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                role: _roleController.text.trim().isEmpty ? null : _roleController.text.trim(),
              );
              widget.onContactAdded(contact);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _EquipmentDialog extends StatefulWidget {
  final ValueChanged<String> onEquipmentAdded;

  const _EquipmentDialog({required this.onEquipmentAdded});

  @override
  State<_EquipmentDialog> createState() => __EquipmentDialogState();
}

class __EquipmentDialogState extends State<_EquipmentDialog> {
  final _equipmentController = TextEditingController();
  String? _selectedEquipment;

  final _commonEquipment = [
    'Radio',
    'Flashlight',
    'Keys',
    'Security Badge',
    'First Aid Kit',
    'Camera',
    'Tablet/Phone',
    'Uniform',
    'Body Camera',
    'Emergency Beacon',
  ];

  @override
  void dispose() {
    _equipmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Required Equipment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedEquipment,
            decoration: const InputDecoration(
              labelText: 'Select Common Equipment',
              border: OutlineInputBorder(),
            ),
            items: _commonEquipment.map((equipment) {
              return DropdownMenuItem(
                value: equipment,
                child: Text(equipment),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEquipment = value;
                _equipmentController.text = value ?? '';
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('OR'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _equipmentController,
            decoration: const InputDecoration(
              labelText: 'Custom Equipment',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final equipment = _equipmentController.text.trim();
            if (equipment.isNotEmpty) {
              widget.onEquipmentAdded(equipment);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
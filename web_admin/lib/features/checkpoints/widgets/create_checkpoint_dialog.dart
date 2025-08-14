import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/checkpoint.dart';
import '../providers/checkpoints_provider.dart';
import '../../../features/sites/providers/sites_provider.dart';

class CreateCheckpointDialog extends ConsumerStatefulWidget {
  const CreateCheckpointDialog({super.key});

  @override
  ConsumerState<CreateCheckpointDialog> createState() => _CreateCheckpointDialogState();
}

class _CreateCheckpointDialogState extends ConsumerState<CreateCheckpointDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _qrCodeController = TextEditingController();
  final _nfcTagController = TextEditingController();
  final _visitDurationController = TextEditingController(text: '5');

  int? _selectedSiteId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _qrCodeController.dispose();
    _nfcTagController.dispose();
    _visitDurationController.dispose();
    super.dispose();
  }

  Future<void> _createCheckpoint() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a site'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final location = Location(
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
      );

      final request = CreateCheckpointRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        siteId: _selectedSiteId!,
        location: location,
        qrCode: _qrCodeController.text.trim().isNotEmpty 
            ? _qrCodeController.text.trim() 
            : null,
        nfcTag: _nfcTagController.text.trim().isNotEmpty 
            ? _nfcTagController.text.trim() 
            : null,
        visitDuration: int.parse(_visitDurationController.text),
      );

      final success = await ref.read(checkpointsProvider.notifier).createCheckpoint(request);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checkpoint created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create checkpoint: $e'),
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

  void _generateQrCode() {
    final checkpointName = _nameController.text.trim();
    if (checkpointName.isNotEmpty) {
      final qrCode = 'CHECKPOINT_${checkpointName.toUpperCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      _qrCodeController.text = qrCode;
    }
  }

  void _generateNfcTag() {
    final checkpointName = _nameController.text.trim();
    if (checkpointName.isNotEmpty) {
      final nfcTag = 'NFC_${checkpointName.toUpperCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      _nfcTagController.text = nfcTag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sitesState = ref.watch(sitesProvider);

    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Create Checkpoint',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Checkpoint name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Checkpoint Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Checkpoint name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Site selection
              DropdownButtonFormField<int>(
                value: _selectedSiteId,
                decoration: const InputDecoration(
                  labelText: 'Site *',
                  border: OutlineInputBorder(),
                ),
                items: sitesState.sites.map((site) => DropdownMenuItem<int>(
                  value: site.id,
                  child: Text(site.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSiteId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a site';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location coordinates
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Latitude is required';
                        }
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) {
                          return 'Invalid latitude (-90 to 90)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Longitude is required';
                        }
                        final lng = double.tryParse(value);
                        if (lng == null || lng < -180 || lng > 180) {
                          return 'Invalid longitude (-180 to 180)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Visit duration
              TextFormField(
                controller: _visitDurationController,
                decoration: const InputDecoration(
                  labelText: 'Visit Duration (minutes) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Visit duration is required';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Duration must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // QR Code and NFC
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qrCodeController,
                      decoration: InputDecoration(
                        labelText: 'QR Code',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: _generateQrCode,
                          icon: const Icon(Icons.qr_code),
                          tooltip: 'Generate QR Code',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nfcTagController,
                      decoration: InputDecoration(
                        labelText: 'NFC Tag',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: _generateNfcTag,
                          icon: const Icon(Icons.nfc),
                          tooltip: 'Generate NFC Tag',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isLoading ? null : _createCheckpoint,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Checkpoint'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
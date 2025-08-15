import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html;

import '../../../shared/models/checkpoint.dart';
import '../../../shared/models/site.dart';

class CheckpointDetailsDialog extends ConsumerWidget {
  final Checkpoint checkpoint;
  final Site site;

  const CheckpointDetailsDialog({
    super.key,
    required this.checkpoint,
    required this.site,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Checkpoint Details',
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

            // Checkpoint information
            _buildInfoSection(
              context,
              title: 'Basic Information',
              children: [
                _buildInfoRow('Name', checkpoint.name),
                if (checkpoint.description != null)
                  _buildInfoRow('Description', checkpoint.description!),
                _buildInfoRow('Site', site.name),
                _buildInfoRow(
                  'Status',
                  checkpoint.isActive ? 'Active' : 'Inactive',
                  valueColor: checkpoint.isActive ? Colors.green : Colors.red,
                ),
                _buildInfoRow('Visit Duration', '${checkpoint.visitDuration} minutes'),
              ],
            ),

            const SizedBox(height: 24),

            // Location information
            _buildInfoSection(
              context,
              title: 'Location',
              children: [
                _buildInfoRow(
                  'Coordinates',
                  '${checkpoint.location.latitude.toStringAsFixed(6)}, ${checkpoint.location.longitude.toStringAsFixed(6)}',
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.place,
                          size: 32,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Checkpoint Location',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Map integration coming soon',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Verification methods
            _buildInfoSection(
              context,
              title: 'Verification Methods',
              children: [
                if (checkpoint.qrCode != null) ...[
                  _buildVerificationMethod(
                    context,
                    icon: Icons.qr_code,
                    label: 'QR Code',
                    value: checkpoint.qrCode!,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                ],
                if (checkpoint.nfcTag != null) ...[
                  _buildVerificationMethod(
                    context,
                    icon: Icons.nfc,
                    label: 'NFC Tag',
                    value: checkpoint.nfcTag!,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                ],
                if (checkpoint.qrCode == null && checkpoint.nfcTag == null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No verification methods configured',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    final lat = checkpoint.location.latitude;
                    final lng = checkpoint.location.longitude;
                    final url = 'https://www.google.com/maps?q=$lat,$lng';
                    html.window.open(url, '_blank');
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in Maps'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationMethod(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied "$label" to clipboard')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            tooltip: 'Copy to clipboard',
          ),
        ],
      ),
    );
  }
}
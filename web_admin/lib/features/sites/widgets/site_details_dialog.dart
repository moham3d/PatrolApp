import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html;

import '../../../shared/models/site.dart';

class SiteDetailsDialog extends ConsumerWidget {
  final Site site;

  const SiteDetailsDialog({
    super.key,
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
                  'Site Details',
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

            // Site information
            _buildInfoSection(
              context,
              title: 'Basic Information',
              children: [
                _buildInfoRow('Name', site.name),
                _buildInfoRow('Address', site.address),
                _buildInfoRow(
                  'Status',
                  (site.isActive ?? false) ? 'Active' : 'Inactive',
                  valueColor:
                      (site.isActive ?? false) ? Colors.green : Colors.red,
                ),
                _buildInfoRow('Checkpoints', '${site.checkpointsCount}'),
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
                  '${site.latitude.toStringAsFixed(6)}, ${site.longitude.toStringAsFixed(6)}',
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Site Location',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Flutter Map integration coming soon',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Contact information
            if (site.contactInfo != null) ...[
              const SizedBox(height: 24),
              _buildInfoSection(
                context,
                title: 'Contact Information',
                children: [
                  if (site.contactInfo!.phone != null)
                    _buildInfoRow('Phone', site.contactInfo!.phone!),
                  if (site.contactInfo!.email != null)
                    _buildInfoRow('Email', site.contactInfo!.email!),
                ],
              ),
            ],

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
                    final lat = site.coordinates.latitude;
                    final lng = site.coordinates.longitude;
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/checkpoint.dart';
import '../../../shared/models/site.dart';
import '../../../shared/widgets/rbac/rbac.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../widgets/checkpoint_details_dialog.dart';
import '../widgets/edit_checkpoint_dialog.dart';

class CheckpointListView extends ConsumerWidget {
  final List<Checkpoint> checkpoints;
  final List<Site> sites;

  const CheckpointListView({
    super.key,
    required this.checkpoints,
    required this.sites,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 24,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Site')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Duration')),
            DataColumn(label: Text('QR/NFC')),
            DataColumn(label: Text('Actions')),
          ],
          rows: checkpoints.map((checkpoint) {
            final site = sites.firstWhere(
              (s) => s.id == checkpoint.siteId,
              orElse: () => const Site(
                id: 0,
                name: 'Unknown Site',
                address: '',
                coordinates: Coordinates(latitude: 0, longitude: 0),
                isActive: false,
                checkpointsCount: 0,
              ),
            );

            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        checkpoint.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (checkpoint.description != null)
                        Text(
                          checkpoint.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    site.name,
                    style: TextStyle(
                      color: site.id == 0 
                          ? Colors.red 
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: checkpoint.isActive 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      checkpoint.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: checkpoint.isActive ? Colors.green.shade700 : Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${checkpoint.location.latitude.toStringAsFixed(4)}, ${checkpoint.location.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text('${checkpoint.visitDuration}min'),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (checkpoint.qrCode != null)
                        Tooltip(
                          message: 'QR Code: ${checkpoint.qrCode}',
                          child: Icon(
                            Icons.qr_code,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ),
                      if (checkpoint.qrCode != null && checkpoint.nfcTag != null)
                        const SizedBox(width: 4),
                      if (checkpoint.nfcTag != null)
                        Tooltip(
                          message: 'NFC Tag: ${checkpoint.nfcTag}',
                          child: Icon(
                            Icons.nfc,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ),
                      if (checkpoint.qrCode == null && checkpoint.nfcTag == null)
                        Text(
                          'None',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View details button
                      IconButton(
                        onPressed: () => _showCheckpointDetails(context, checkpoint, site),
                        icon: const Icon(Icons.visibility),
                        tooltip: 'View Details',
                      ),
                      
                      // Edit button - permission-based
                      PermissionGuard(
                        requiredRoles: _getEditPermissions(user, checkpoint),
                        child: IconButton(
                          onPressed: () => _showEditDialog(context, checkpoint),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Checkpoint',
                        ),
                      ),
                      
                      // QR Code generation button
                      PermissionGuard(
                        requiredRoles: Permissions.checkpointEdit,
                        child: IconButton(
                          onPressed: () => _generateQrCode(context, checkpoint),
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: 'Generate QR Code',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCheckpointDetails(BuildContext context, Checkpoint checkpoint, Site site) {
    showDialog(
      context: context,
      builder: (context) => CheckpointDetailsDialog(
        checkpoint: checkpoint,
        site: site,
      ),
    );
  }

  void _showEditDialog(BuildContext context, Checkpoint checkpoint) {
    showDialog(
      context: context,
      builder: (context) => EditCheckpointDialog(checkpoint: checkpoint),
    );
  }

  void _generateQrCode(BuildContext context, Checkpoint checkpoint) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Generate QR Code',
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
              
              // QR Code placeholder
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'QR Code',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkpoint.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'QR Code generation and printing features coming soon',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
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
                      // TODO: Generate and download QR code
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Determine edit permissions based on access matrix
  List<String> _getEditPermissions(user, Checkpoint checkpoint) {
    // For minimal scope, assume all users who can view can potentially edit
    // In real implementation, this would check site assignments
    return Permissions.checkpointEdit;
  }
}
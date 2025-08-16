import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/checkpoint.dart';
import '../../../shared/models/site.dart';
import '../../../shared/widgets/rbac/rbac.dart';
import '../widgets/checkpoint_details_dialog.dart';
import '../widgets/edit_checkpoint_dialog.dart';
import '../widgets/qr_nfc_management_widget.dart';
import '../widgets/checkpoint_visit_tracker.dart';

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
                latitude: 0,
                longitude: 0,
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
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: checkpoint.isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      checkpoint.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: checkpoint.isActive
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${checkpoint.latitude.toStringAsFixed(4)}, ${checkpoint.longitude.toStringAsFixed(4)}',
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
                      if (checkpoint.qrCode != null &&
                          checkpoint.nfcTag != null)
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
                      if (checkpoint.qrCode == null &&
                          checkpoint.nfcTag == null)
                        Text(
                          'None',
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
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Visit history button
                      IconButton(
                        onPressed: () {
                          _showVisitHistory(context, checkpoint);
                        },
                        icon: const Icon(Icons.history),
                        tooltip: 'Visit History',
                      ),

                      // View details button
                      IconButton(
                        onPressed: () =>
                            _showCheckpointDetails(context, checkpoint, site),
                        icon: const Icon(Icons.visibility),
                        tooltip: 'View Details',
                      ),

                      // Edit button - permission-based
                      PermissionGuard(
                        requiredRoles: const [
                          'admin',
                          'operations_manager'
                        ], // TODO: Implement proper permissions
                        child: IconButton(
                          onPressed: () => _showEditDialog(context, checkpoint),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Checkpoint',
                        ),
                      ),

                      // QR/NFC management button
                      PermissionGuard(
                        requiredRoles: Permissions.checkpointEdit,
                        child: IconButton(
                          onPressed: () {
                            _showQrNfcManagement(context, checkpoint);
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: 'QR/NFC Management',
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

  void _showCheckpointDetails(
      BuildContext context, Checkpoint checkpoint, Site site) {
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

  void _showVisitHistory(BuildContext context, Checkpoint checkpoint) {
    showDialog(
      context: context,
      builder: (context) => CheckpointVisitTracker(checkpoint: checkpoint),
    );
  }

  void _showQrNfcManagement(BuildContext context, Checkpoint checkpoint) {
    showDialog(
      context: context,
      builder: (context) => QrNfcManagementWidget(checkpoint: checkpoint),
    );
  }
}

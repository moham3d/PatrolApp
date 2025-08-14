import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/site.dart';
import '../../../shared/widgets/rbac/rbac.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../widgets/site_details_dialog.dart';
import '../widgets/edit_site_dialog.dart';

class SiteListView extends ConsumerWidget {
  final List<Site> sites;

  const SiteListView({
    super.key,
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
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Checkpoints')),
            DataColumn(label: Text('Coordinates')),
            DataColumn(label: Text('Actions')),
          ],
          rows: sites.map((site) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        site.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (site.contactInfo?.email != null)
                        Text(
                          site.contactInfo!.email!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Tooltip(
                    message: site.address,
                    child: Text(
                      site.address,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: site.isActive 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      site.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: site.isActive ? Colors.green.shade700 : Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.place,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text('${site.checkpointsCount}'),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    '${site.coordinates.latitude.toStringAsFixed(4)}, ${site.coordinates.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View details button
                      IconButton(
                        onPressed: () => _showSiteDetails(context, site),
                        icon: const Icon(Icons.visibility),
                        tooltip: 'View Details',
                      ),
                      
                      // Edit button - permission-based
                      PermissionGuard(
                        requiredRoles: _getEditPermissions(user, site),
                        child: IconButton(
                          onPressed: () => _showEditDialog(context, site),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Site',
                        ),
                      ),
                      
                      // Map button
                      IconButton(
                        onPressed: () => _showSiteOnMap(context, site),
                        icon: const Icon(Icons.map),
                        tooltip: 'View on Map',
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

  void _showSiteDetails(BuildContext context, Site site) {
    showDialog(
      context: context,
      builder: (context) => SiteDetailsDialog(site: site),
    );
  }

  void _showEditDialog(BuildContext context, Site site) {
    showDialog(
      context: context,
      builder: (context) => EditSiteDialog(site: site),
    );
  }

  void _showSiteOnMap(BuildContext context, Site site) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    site.name,
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
              const SizedBox(height: 16),
              Expanded(
                child: Container(
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
                          'Map View',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lat: ${site.coordinates.latitude.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Lng: ${site.coordinates.longitude.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Flutter Map integration coming soon',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      ),
    );
  }

  // Determine edit permissions based on access matrix
  List<String> _getEditPermissions(user, Site site) {
    // For minimal scope, assume all users who can view can potentially edit
    // In real implementation, this would check site assignments
    return Permissions.siteEdit;
  }
}
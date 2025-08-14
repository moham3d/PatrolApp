import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/checkpoints_provider.dart';
import '../widgets/checkpoint_list_view.dart';
import '../widgets/create_checkpoint_dialog.dart';
import '../../../shared/widgets/rbac/rbac.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/sites/providers/sites_provider.dart';
import '../../../shared/models/site.dart';

class CheckpointsPage extends ConsumerStatefulWidget {
  const CheckpointsPage({super.key});

  @override
  ConsumerState<CheckpointsPage> createState() => _CheckpointsPageState();
}

class _CheckpointsPageState extends ConsumerState<CheckpointsPage> {
  int? _selectedSiteId;
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();
    // Load sites for filtering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sitesProvider.notifier).loadSites();
    });
  }

  void _onSiteFilterChanged(int? siteId) {
    setState(() {
      _selectedSiteId = siteId;
    });
    ref.read(checkpointsProvider.notifier).setFilters(
      siteId: siteId,
      isActive: _activeFilter,
    );
  }

  void _onActiveFilterChanged(bool? isActive) {
    setState(() {
      _activeFilter = isActive;
    });
    ref.read(checkpointsProvider.notifier).setFilters(
      siteId: _selectedSiteId,
      isActive: isActive,
    );
  }

  void _showCreateCheckpointDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateCheckpointDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkpointsState = ref.watch(checkpointsProvider);
    final sitesState = ref.watch(sitesProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with role-based actions
            Row(
              children: [
                Text(
                  _getPageTitle(user),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                
                // Create checkpoint button - permission-based
                PermissionGuard(
                  requiredRoles: Permissions.checkpointCreate,
                  child: FilledButton.icon(
                    onPressed: _showCreateCheckpointDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Checkpoint'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filters
            Row(
              children: [
                // Site filter
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int?>(
                    value: _selectedSiteId,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Site',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Sites'),
                      ),
                      ...sitesState.sites.map((site) => DropdownMenuItem<int?>(
                        value: site.id,
                        child: Text(site.name),
                      )),
                    ],
                    onChanged: _onSiteFilterChanged,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Active filter
                DropdownButton<bool?>(
                  value: _activeFilter,
                  hint: const Text('All Checkpoints'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Checkpoints')),
                    DropdownMenuItem(value: true, child: Text('Active Only')),
                    DropdownMenuItem(value: false, child: Text('Inactive Only')),
                  ],
                  onChanged: _onActiveFilterChanged,
                ),
                
                const SizedBox(width: 16),
                
                // Refresh button
                IconButton(
                  onPressed: () => ref.read(checkpointsProvider.notifier).setFilters(
                    siteId: _selectedSiteId,
                    isActive: _activeFilter,
                  ),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Error handling
            if (checkpointsState.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        checkpointsState.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref.read(checkpointsProvider.notifier).clearError(),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),

            // Checkpoints list
            Expanded(
              child: checkpointsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : checkpointsState.checkpoints.isEmpty
                      ? _buildEmptyState()
                      : CheckpointListView(
                          checkpoints: checkpointsState.checkpoints,
                          sites: sitesState.sites,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.place_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No checkpoints found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedSiteId != null
                ? 'No checkpoints found for the selected site'
                : 'Get started by creating your first checkpoint',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          PermissionGuard(
            requiredRoles: Permissions.checkpointCreate,
            child: FilledButton.icon(
              onPressed: _showCreateCheckpointDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Checkpoint'),
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(user) {
    if (user?.isAdmin == true || user?.isOperationsManager == true) {
      return 'Checkpoint Management';
    } else if (user?.isSiteManager == true) {
      return 'Site Checkpoints';
    } else if (user?.isSupervisor == true) {
      return 'Checkpoint Management';
    } else {
      return 'Patrol Checkpoints';
    }
  }
}
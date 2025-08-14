import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sites_provider.dart';
import '../widgets/site_list_view.dart';
import '../widgets/create_site_dialog.dart';
import '../../../shared/widgets/rbac/rbac.dart';
import '../../../features/auth/providers/auth_provider.dart';

class SitesPage extends ConsumerStatefulWidget {
  const SitesPage({super.key});

  @override
  ConsumerState<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends ConsumerState<SitesPage> {
  final _searchController = TextEditingController();
  bool? _activeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    ref.read(sitesProvider.notifier).loadSites(
      search: value.isEmpty ? null : value,
      isActive: _activeFilter,
    );
  }

  void _onFilterChanged(bool? isActive) {
    setState(() {
      _activeFilter = isActive;
    });
    ref.read(sitesProvider.notifier).loadSites(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      isActive: isActive,
    );
  }

  void _showCreateSiteDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateSiteDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                
                // Create site button - only for admin, operations manager
                PermissionGuard(
                  requiredRoles: Permissions.siteCreate,
                  child: FilledButton.icon(
                    onPressed: _showCreateSiteDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Site'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and filters
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search sites...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onSearch,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Active filter
                DropdownButton<bool?>(
                  value: _activeFilter,
                  hint: const Text('All Sites'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Sites')),
                    DropdownMenuItem(value: true, child: Text('Active Only')),
                    DropdownMenuItem(value: false, child: Text('Inactive Only')),
                  ],
                  onChanged: _onFilterChanged,
                ),
                
                const SizedBox(width: 16),
                
                // Refresh button
                IconButton(
                  onPressed: () => ref.read(sitesProvider.notifier).loadSites(
                    search: _searchController.text.isEmpty ? null : _searchController.text,
                    isActive: _activeFilter,
                  ),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Error handling
            if (sitesState.error != null)
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
                        sitesState.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref.read(sitesProvider.notifier).clearError(),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),

            // Sites list
            Expanded(
              child: sitesState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : sitesState.sites.isEmpty
                      ? _buildEmptyState()
                      : SiteListView(sites: sitesState.sites),
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
            Icons.location_on_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No sites found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search criteria'
                : 'Get started by creating your first site',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          PermissionGuard(
            requiredRoles: Permissions.siteCreate,
            child: FilledButton.icon(
              onPressed: _showCreateSiteDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Site'),
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(user) {
    if (user?.isAdmin == true || user?.isOperationsManager == true) {
      return 'Site Management';
    } else if (user?.isSiteManager == true) {
      return 'My Sites';
    } else if (user?.isSupervisor == true) {
      return 'Assigned Sites';
    } else {
      return 'Sites';
    }
  }
}
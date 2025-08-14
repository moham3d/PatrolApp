import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import 'rbac/role_interfaces.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final roleInterface = RoleInterface.getForUser(authState.user);
    
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: roleInterface.getSelectedIndex(currentLocation),
            onDestinationSelected: (index) {
              _navigateToPage(context, index, roleInterface);
            },
            extended: MediaQuery.of(context).size.width >= 1200,
            destinations: roleInterface.destinations,
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Info
                      if (authState.user != null) ...[
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            authState.user!.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (MediaQuery.of(context).size.width >= 1200) ...[
                          Text(
                            authState.user!.fullName,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            authState.user!.roles.join(', '),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                      
                      // Logout Button
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () => _handleLogout(context, ref),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const VerticalDivider(thickness: 1, width: 1),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _navigateToDashboard(context),
                          child: Text(
                            roleInterface.getTitle(currentLocation),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        
                        // Status Indicators
                        const RoleBasedStatusIndicators(),
                      ],
                    ),
                  ),
                ),
                
                // Page Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index, RoleInterface roleInterface) {
    final route = roleInterface.getRoute(index);
    if (route != null) {
      context.go(route);
    }
  }

  // Handle dashboard navigation
  void _navigateToDashboard(BuildContext context) {
    context.go('/');
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
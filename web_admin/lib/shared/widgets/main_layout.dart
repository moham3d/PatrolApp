import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';

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
    
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _getSelectedIndex(currentLocation),
            onDestinationSelected: (index) {
              _navigateToPage(context, index);
            },
            extended: MediaQuery.of(context).size.width >= 1200,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: Text('Sites'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.route_outlined),
                selectedIcon: Icon(Icons.route),
                label: Text('Patrols'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.place_outlined),
                selectedIcon: Icon(Icons.place),
                label: Text('Checkpoints'),
              ),
            ],
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
                        Text(
                          _getPageTitle(currentLocation),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        
                        // Status Indicators
                        Row(
                          children: [
                            // Connection Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Online',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/users':
        return 0;
      case '/sites':
        return 1;
      case '/patrols':
        return 2;
      case '/checkpoints':
        return 3;
      default:
        return 0;
    }
  }

  String _getPageTitle(String location) {
    switch (location) {
      case '/users':
        return 'User Management';
      case '/sites':
        return 'Site Management';
      case '/patrols':
        return 'Patrol Management';
      case '/checkpoints':
        return 'Checkpoint Management';
      default:
        return 'PatrolShield Admin';
    }
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/users');
        break;
      case 1:
        context.go('/sites');
        break;
      case 2:
        context.go('/patrols');
        break;
      case 3:
        context.go('/checkpoints');
        break;
    }
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
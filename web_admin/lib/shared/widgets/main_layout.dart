import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';

final sidebarExpandedProvider = StateProvider<bool>((ref) => true);

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isExpanded = ref.watch(sidebarExpandedProvider);

    // Determine selected index based on current route
    int selectedIndex = 0;
    switch (currentLocation) {
      case '/dashboard':
        selectedIndex = 0;
        break;
      case '/users':
        selectedIndex = 1;
        break;
      case '/sites':
        selectedIndex = 2;
        break;
      case '/patrols':
        selectedIndex = 3;
        break;
      case '/checkpoints':
        selectedIndex = 4;
        break;
      case '/reports':
        selectedIndex = 5;
        break;
      case '/monitoring':
        selectedIndex = 6;
        break;
      case '/communication':
        selectedIndex = 7;
        break;
      case '/messaging':
        selectedIndex = 8;
        break;
    }

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail with all destinations
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/dashboard');
                  break;
                case 1:
                  context.go('/users');
                  break;
                case 2:
                  context.go('/sites');
                  break;
                case 3:
                  context.go('/patrols');
                  break;
                case 4:
                  context.go('/checkpoints');
                  break;
                case 5:
                  context.go('/reports');
                  break;
                case 6:
                  context.go('/monitoring');
                  break;
                case 7:
                  context.go('/communication');
                  break;
                case 8:
                  context.go('/messaging');
                  break;
              }
            },
            extended: isExpanded && MediaQuery.of(context).size.width >= 800,
            leading: IconButton(
              icon: Icon(isExpanded ? Icons.menu_open : Icons.menu),
              onPressed: () =>
                  ref.read(sidebarExpandedProvider.notifier).state =
                      !isExpanded,
              tooltip: isExpanded ? 'Collapse sidebar' : 'Expand sidebar',
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.location_city),
                label: Text('Sites'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.route),
                label: Text('Patrols'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.place),
                label: Text('Checkpoints'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.monitor),
                label: Text('Monitoring'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat),
                label: Text('Messaging'),
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
                            authState.user!.fullName.isNotEmpty
                                ? authState.user!.fullName
                                      .split(' ')
                                      .first[0]
                                      .toUpperCase()
                                : authState.user!.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          authState.user!.fullName.isNotEmpty
                              ? authState.user!.fullName.split(' ').first
                              : authState.user!.username,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          authState.user!.primaryRole,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Logout Button
                      IconButton(
                        onPressed: () => _handleLogout(context, ref),
                        icon: const Icon(Icons.logout),
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
          Expanded(child: child),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

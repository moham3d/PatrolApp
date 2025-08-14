import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../shared/models/auth.dart';
import 'permission_widgets.dart';

/// Admin-specific navigation destinations and features
class AdminNavigation {
  static const List<NavigationRailDestination> destinations = [
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
  ];

  static const List<String> routes = [
    '/users',
    '/sites',
    '/patrols',
    '/checkpoints',
  ];

  static const List<String> titles = [
    'User Management',
    'Site Management',
    'Patrol Management',
    'Checkpoint Management',
  ];
}

/// Operations Manager navigation - similar to admin but focused on operations
class OperationsManagerNavigation {
  static const List<NavigationRailDestination> destinations = [
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
  ];

  static const List<String> routes = [
    '/users',
    '/sites',
    '/patrols',
    '/checkpoints',
  ];

  static const List<String> titles = [
    'User Management',
    'Site Management',
    'Patrol Management',
    'Checkpoint Management',
  ];
}

/// Site Manager navigation - manages assigned sites
class SiteManagerNavigation {
  static const List<NavigationRailDestination> destinations = [
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
  ];

  static const List<String> routes = [
    '/users',
    '/sites',
    '/patrols',
    '/checkpoints',
  ];

  static const List<String> titles = [
    'Team Management',
    'My Sites',
    'Site Patrols',
    'Site Checkpoints',
  ];
}

/// Supervisor-specific navigation destinations and features
class SupervisorNavigation {
  static const List<NavigationRailDestination> destinations = [
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
  ];

  static const List<String> routes = [
    '/sites',
    '/patrols',
    '/checkpoints',
  ];

  static const List<String> titles = [
    'Assigned Sites',
    'Patrol Supervision',
    'Checkpoint Management',
  ];
}

/// Guard-specific navigation destinations and features  
class GuardNavigation {
  static const List<NavigationRailDestination> destinations = [
    NavigationRailDestination(
      icon: Icon(Icons.location_on_outlined),
      selectedIcon: Icon(Icons.location_on),
      label: Text('Sites'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.route_outlined),
      selectedIcon: Icon(Icons.route),
      label: Text('My Patrols'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.place_outlined),
      selectedIcon: Icon(Icons.place),
      label: Text('Checkpoints'),
    ),
  ];

  static const List<String> routes = [
    '/sites',
    '/patrols',
    '/checkpoints',
  ];

  static const List<String> titles = [
    'Assigned Sites',
    'My Patrols',
    'Patrol Checkpoints',
  ];
}

/// Role-based interface provider that returns appropriate interface based on user role
class RoleInterface {
  final List<NavigationRailDestination> destinations;
  final List<String> routes;
  final List<String> titles;

  const RoleInterface({
    required this.destinations,
    required this.routes,
    required this.titles,
  });

  static RoleInterface getForUser(AuthUser? user) {
    if (user == null) {
      return const RoleInterface(
        destinations: [],
        routes: [],
        titles: [],
      );
    }

    // Admin has highest priority
    if (user.isAdmin) {
      return const RoleInterface(
        destinations: AdminNavigation.destinations,
        routes: AdminNavigation.routes,
        titles: AdminNavigation.titles,
      );
    }
    
    // Operations Manager has second highest priority
    if (user.isOperationsManager) {
      return const RoleInterface(
        destinations: OperationsManagerNavigation.destinations,
        routes: OperationsManagerNavigation.routes,
        titles: OperationsManagerNavigation.titles,
      );
    }
    
    // Site Manager has specialized interface
    if (user.isSiteManager) {
      return const RoleInterface(
        destinations: SiteManagerNavigation.destinations,
        routes: SiteManagerNavigation.routes,
        titles: SiteManagerNavigation.titles,
      );
    }
    
    // Supervisor interface
    if (user.isSupervisor) {
      return const RoleInterface(
        destinations: SupervisorNavigation.destinations,
        routes: SupervisorNavigation.routes,
        titles: SupervisorNavigation.titles,
      );
    }
    
    // Guard interface (handles both guard and mobile_guard)
    if (user.isGuard || user.isMobileGuard) {
      return const RoleInterface(
        destinations: GuardNavigation.destinations,
        routes: GuardNavigation.routes,
        titles: GuardNavigation.titles,
      );
    }

    // Default empty interface for visitors or unknown roles
    return const RoleInterface(
      destinations: [],
      routes: [],
      titles: [],
    );
  }

  int getSelectedIndex(String location) {
    return routes.indexOf(location);
  }

  String getTitle(String location) {
    final index = routes.indexOf(location);
    if (index >= 0 && index < titles.length) {
      return titles[index];
    }
    return 'PatrolShield Admin';
  }

  String? getRoute(int index) {
    if (index >= 0 && index < routes.length) {
      return routes[index];
    }
    return null;
  }
}

/// Widget that provides role-based quick actions
class RoleBasedQuickActions extends ConsumerWidget {
  const RoleBasedQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Admin quick actions
              if (user.isAdmin) ...[
                _buildQuickActionChip(
                  context,
                  icon: Icons.person_add,
                  label: 'Add User',
                  onPressed: () {
                    // TODO: Navigate to add user
                  },
                ),
                _buildQuickActionChip(
                  context,
                  icon: Icons.add_location,
                  label: 'Add Site',
                  onPressed: () {
                    // TODO: Navigate to add site
                  },
                ),
              ],
              
              // Operations Manager quick actions
              if (user.isOperationsManager) ...[
                _buildQuickActionChip(
                  context,
                  icon: Icons.person_add,
                  label: 'Add User',
                  onPressed: () {
                    // TODO: Navigate to add user
                  },
                ),
                _buildQuickActionChip(
                  context,
                  icon: Icons.add_location,
                  label: 'Add Site',
                  onPressed: () {
                    // TODO: Navigate to add site
                  },
                ),
              ],
              
              // Site Manager quick actions
              if (user.isSiteManager) ...[
                _buildQuickActionChip(
                  context,
                  icon: Icons.person_add,
                  label: 'Add Team Member',
                  onPressed: () {
                    // TODO: Navigate to add user to site
                  },
                ),
                _buildQuickActionChip(
                  context,
                  icon: Icons.route,
                  label: 'Schedule Patrol',
                  onPressed: () {
                    // TODO: Navigate to schedule patrol
                  },
                ),
              ],
              
              // Supervisor quick actions
              if (user.isSupervisor) ...[
                _buildQuickActionChip(
                  context,
                  icon: Icons.route,
                  label: 'Schedule Patrol',
                  onPressed: () {
                    // TODO: Navigate to schedule patrol
                  },
                ),
                _buildQuickActionChip(
                  context,
                  icon: Icons.place,
                  label: 'Manage Checkpoints',
                  onPressed: () {
                    // TODO: Navigate to checkpoints
                  },
                ),
              ],
              
              // Guard quick actions
              if (user.isGuard || user.isMobileGuard) ...[
                _buildQuickActionChip(
                  context,
                  icon: Icons.my_location,
                  label: 'Check In',
                  onPressed: () {
                    // TODO: Implement check-in
                  },
                ),
                _buildQuickActionChip(
                  context,
                  icon: Icons.route,
                  label: 'My Patrols',
                  onPressed: () {
                    // TODO: Navigate to my patrols
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}

/// Role-based status indicators
class RoleBasedStatusIndicators extends ConsumerWidget {
  const RoleBasedStatusIndicators({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) return const SizedBox.shrink();

    return Row(
      children: [
        // Role indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getRoleColor(user).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(user),
                size: 12,
                color: _getRoleColor(user),
              ),
              const SizedBox(width: 4),
              Text(
                _getRoleDisplayName(user),
                style: TextStyle(
                  color: _getRoleColor(user),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // Connection status (kept from original)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Color _getRoleColor(AuthUser user) {
    if (user.isAdmin) return Colors.red;
    if (user.isOperationsManager) return Colors.deepOrange;
    if (user.isSiteManager) return Colors.purple;
    if (user.isSupervisor) return Colors.orange;
    if (user.isGuard || user.isMobileGuard) return Colors.blue;
    return Colors.grey;
  }

  IconData _getRoleIcon(AuthUser user) {
    if (user.isAdmin) return Icons.admin_panel_settings;
    if (user.isOperationsManager) return Icons.business_center;
    if (user.isSiteManager) return Icons.domain;
    if (user.isSupervisor) return Icons.supervisor_account;
    if (user.isGuard || user.isMobileGuard) return Icons.security;
    return Icons.person;
  }

  String _getRoleDisplayName(AuthUser user) {
    return user.primaryRole;
  }
}
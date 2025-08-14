import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../shared/models/auth.dart';
import 'permission_widgets.dart';

/// A route guard that checks user permissions before allowing access to routes
class RouteGuard {
  static bool canAccess(String route, AuthUser? user) {
    if (user == null) return false;

    switch (route) {
      // Live monitoring - Admin and Operations Manager only
      case '/monitoring':
        return user.isAdmin || user.isOperationsManager;
        
      // User management - Admin, Operations Manager, Site Manager (site only), Supervisor (site only)
      // Guards should NOT have access to user management per access matrix
      case '/users':
        return user.isAdmin || user.isOperationsManager || user.isSiteManager || user.isSupervisor;
      
      // Site management - all roles can view (with restrictions), create limited to higher roles
      case '/sites':
        return user.isAdmin || user.isOperationsManager || user.isSiteManager || 
               user.isSupervisor || user.isGuard || user.isMobileGuard;
      
      // Patrol management - Admin, Operations Manager, Site Manager, Supervisor can manage; Guards can view assigned
      case '/patrols':
        return user.isAdmin || user.isOperationsManager || user.isSiteManager || 
               user.isSupervisor || user.isGuard || user.isMobileGuard;
      
      // Checkpoint management - similar to patrols
      case '/checkpoints':
        return user.isAdmin || user.isOperationsManager || user.isSiteManager || 
               user.isSupervisor || user.isGuard || user.isMobileGuard;
      
      // System settings - Admin only
      case '/settings':
        return user.isAdmin;
      
      // Default: allow if user is logged in
      default:
        return true;
    }
  }

  /// Get default route for user role
  static String getDefaultRoute(AuthUser? user) {
    if (user == null) return '/login';
    
    // Admin and Operations Manager start with live monitoring
    if (user.isAdmin || user.isOperationsManager) return '/monitoring';
    
    // Site Manager starts with their sites
    if (user.isSiteManager) return '/sites';
    
    // Supervisor starts with sites they supervise
    if (user.isSupervisor) return '/sites';
    
    // Guards start with their assigned sites
    if (user.isGuard || user.isMobileGuard) return '/sites';
    
    return '/';
  }

  /// Check if user can access current route, redirect if not
  static String? redirect(BuildContext context, GoRouterState state) {
    // This will be implemented in the router configuration
    return null;
  }
}

/// Page wrapper that provides permission-based access
class PermissionPage extends ConsumerWidget {
  final Widget child;
  final List<String> requiredRoles;
  final String? redirectRoute;

  const PermissionPage({
    super.key,
    required this.child,
    required this.requiredRoles,
    this.redirectRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      // Not logged in - should be handled by router
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final hasPermission = requiredRoles.isEmpty || 
        requiredRoles.any((role) => user.hasRole(role));

    if (!hasPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'You don\'t have permission to access this page.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  final defaultRoute = RouteGuard.getDefaultRoute(user);
                  context.go(defaultRoute);
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}

/// Role-based dashboard that shows different content based on user role
class RoleDashboard extends ConsumerWidget {
  const RoleDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user.firstName}!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getRoleWelcomeMessage(user),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildRoleBadge(context, user),
              ],
            ),
            const SizedBox(height: 32),
            
            // Role-specific content
            Expanded(
              child: RoleBasedWidget(
                adminChild: _buildAdminDashboard(context),
                operationsManagerChild: _buildOperationsManagerDashboard(context),
                siteManagerChild: _buildSiteManagerDashboard(context),
                supervisorChild: _buildSupervisorDashboard(context),
                guardChild: _buildGuardDashboard(context),
                defaultChild: _buildDefaultDashboard(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleWelcomeMessage(AuthUser user) {
    if (user.isAdmin) {
      return 'System Administrator - Full access to all features';
    } else if (user.isOperationsManager) {
      return 'Operations Manager - Oversee all operational activities';
    } else if (user.isSiteManager) {
      return 'Site Manager - Manage your assigned sites and teams';
    } else if (user.isSupervisor) {
      return 'Supervisor - Supervise patrols and manage site operations';
    } else if (user.isGuard || user.isMobileGuard) {
      return 'Security Guard - View assigned patrols and checkpoints';
    }
    return 'Welcome to PatrolShield';
  }

  Widget _buildRoleBadge(BuildContext context, AuthUser user) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    if (user.isAdmin) {
      badgeColor = Colors.red;
      badgeIcon = Icons.admin_panel_settings;
      badgeText = 'Administrator';
    } else if (user.isOperationsManager) {
      badgeColor = Colors.deepOrange;
      badgeIcon = Icons.business_center;
      badgeText = 'Operations Manager';
    } else if (user.isSiteManager) {
      badgeColor = Colors.purple;
      badgeIcon = Icons.domain;
      badgeText = 'Site Manager';
    } else if (user.isSupervisor) {
      badgeColor = Colors.orange;
      badgeIcon = Icons.supervisor_account;
      badgeText = 'Supervisor';
    } else if (user.isGuard || user.isMobileGuard) {
      badgeColor = Colors.blue;
      badgeIcon = Icons.security;
      badgeText = user.isMobileGuard ? 'Mobile Guard' : 'Guard';
    } else {
      badgeColor = Colors.grey;
      badgeIcon = Icons.person;
      badgeText = 'User';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: badgeColor, size: 20),
          const SizedBox(width: 8),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                context,
                icon: Icons.monitor,
                title: 'Live Monitoring',
                subtitle: 'Real-time system monitoring',
                onTap: () => context.go('/monitoring'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.people,
                title: 'User Management',
                subtitle: 'Manage users and permissions',
                onTap: () => context.go('/users'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.location_on,
                title: 'Site Management',
                subtitle: 'Configure all sites and locations',
                onTap: () => context.go('/sites'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.route,
                title: 'Patrol Management',
                subtitle: 'Manage all patrol operations',
                onTap: () => context.go('/patrols'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.place,
                title: 'Checkpoint Management',
                subtitle: 'Configure system checkpoints',
                onTap: () => context.go('/checkpoints'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperationsManagerDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operations Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                context,
                icon: Icons.monitor,
                title: 'Live Monitoring',
                subtitle: 'Real-time operations monitoring',
                onTap: () => context.go('/monitoring'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.people,
                title: 'User Management',
                subtitle: 'Manage operational staff',
                onTap: () => context.go('/users'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.location_on,
                title: 'Site Operations',
                subtitle: 'Oversee all site operations',
                onTap: () => context.go('/sites'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.route,
                title: 'Patrol Operations',
                subtitle: 'Coordinate patrol activities',
                onTap: () => context.go('/patrols'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.place,
                title: 'Checkpoint Operations',
                subtitle: 'Monitor checkpoint activities',
                onTap: () => context.go('/checkpoints'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSiteManagerDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Site Management Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                context,
                icon: Icons.people,
                title: 'Site Team',
                subtitle: 'Manage your site staff',
                onTap: () => context.go('/users'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.location_on,
                title: 'My Sites',
                subtitle: 'Manage assigned sites',
                onTap: () => context.go('/sites'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.route,
                title: 'Site Patrols',
                subtitle: 'Schedule site patrols',
                onTap: () => context.go('/patrols'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.place,
                title: 'Site Checkpoints',
                subtitle: 'Manage site checkpoints',
                onTap: () => context.go('/checkpoints'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupervisorDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supervisor Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                context,
                icon: Icons.location_on,
                title: 'Assigned Sites',
                subtitle: 'View your assigned sites',
                onTap: () => context.go('/sites'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.route,
                title: 'Patrol Supervision',
                subtitle: 'Supervise patrol activities',
                onTap: () => context.go('/patrols'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.place,
                title: 'Checkpoint Management',
                subtitle: 'Manage site checkpoints',
                onTap: () => context.go('/checkpoints'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuardDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guard Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                context,
                icon: Icons.location_on,
                title: 'Assigned Sites',
                subtitle: 'View your assigned sites',
                onTap: () => context.go('/sites'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.route,
                title: 'My Patrols',
                subtitle: 'View assigned patrol routes',
                onTap: () => context.go('/patrols'),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.place,
                title: 'Checkpoints',
                subtitle: 'View patrol checkpoints',
                onTap: () => context.go('/checkpoints'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultDashboard(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'PatrolShield Dashboard',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome to the security management system',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
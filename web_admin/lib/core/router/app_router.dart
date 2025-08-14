import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/pages/login_page.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/rbac/route_guards.dart';
import '../../features/users/pages/users_page.dart';
import '../../features/sites/pages/sites_page.dart';
import '../../features/patrols/pages/patrols_page.dart';
import '../../features/checkpoints/pages/checkpoints_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: authState.isLoggedIn 
        ? RouteGuard.getDefaultRoute(authState.user)
        : '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';
      final user = authState.user;

      // If not logged in and not on login page, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in and on login page, redirect to appropriate dashboard
      if (isLoggedIn && isLoggingIn) {
        return RouteGuard.getDefaultRoute(user);
      }

      // Check if user has permission to access the current route
      if (isLoggedIn && user != null) {
        final canAccess = RouteGuard.canAccess(state.matchedLocation, user);
        if (!canAccess) {
          return RouteGuard.getDefaultRoute(user);
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const RoleDashboard(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/users',
            builder: (context, state) => const PermissionPage(
              requiredRoles: ['admin', 'operations_manager', 'site_manager', 'supervisor'],
              child: UsersPage(),
            ),
          ),
          GoRoute(
            path: '/sites',
            builder: (context, state) => const PermissionPage(
              requiredRoles: ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard'],
              child: SitesPage(),
            ),
          ),
          GoRoute(
            path: '/patrols',
            builder: (context, state) => const PermissionPage(
              requiredRoles: ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard'],
              child: PatrolsPage(),
            ),
          ),
          GoRoute(
            path: '/checkpoints',
            builder: (context, state) => const PermissionPage(
              requiredRoles: ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard'],
              child: CheckpointsPage(),
            ),
          ),
          // Additional admin-only routes (minimal scope - keeping for future expansion)
          GoRoute(
            path: '/settings',
            builder: (context, state) => const PermissionPage(
              requiredRoles: ['admin'],
              child: Scaffold(
                body: Center(
                  child: Text('System Settings - Coming Soon'),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
});
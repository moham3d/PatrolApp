import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/pages/login_page.dart';
import '../../shared/widgets/main_layout.dart';
import '../../features/users/pages/users_page.dart';
import '../../features/sites/pages/sites_page.dart';
import '../../features/patrols/pages/patrols_page.dart';
import '../../features/checkpoints/pages/checkpoints_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: authState.isLoggedIn ? '/users' : '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';

      // If not logged in and not on login page, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in and on login page, redirect to dashboard
      if (isLoggedIn && isLoggingIn) {
        return '/users';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/sites',
            builder: (context, state) => const SitesPage(),
          ),
          GoRoute(
            path: '/patrols',
            builder: (context, state) => const PatrolsPage(),
          ),
          GoRoute(
            path: '/checkpoints',
            builder: (context, state) => const CheckpointsPage(),
          ),
        ],
      ),
    ],
  );
});
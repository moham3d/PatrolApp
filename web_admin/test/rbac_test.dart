import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patrol_shield_admin/shared/models/auth.dart';
import 'package:patrol_shield_admin/shared/widgets/rbac/rbac.dart';
import 'package:patrol_shield_admin/features/auth/providers/auth_provider.dart';

void main() {
  group('RBAC Permission System Tests', () {
    testWidgets('PermissionGuard shows child when user has required role', (WidgetTester tester) async {
      // Create a mock user with admin role
      const user = AuthUser(
        id: 1,
        username: 'admin',
        email: 'admin@test.com',
        firstName: 'Admin',
        lastName: 'User',
        isActive: true,
        roles: ['admin'],
      );

      // Create a mock auth state
      const authState = AuthState(user: user);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier(authState)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PermissionGuard(
                requiredRoles: const ['admin'],
                child: const Text('Admin Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Admin Content'), findsOneWidget);
    });

    testWidgets('PermissionGuard hides child when user lacks required role', (WidgetTester tester) async {
      // Create a mock user with guard role
      const user = AuthUser(
        id: 1,
        username: 'guard',
        email: 'guard@test.com',
        firstName: 'Guard',
        lastName: 'User',
        isActive: true,
        roles: ['guard'],
      );

      const authState = AuthState(user: user);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier(authState)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PermissionGuard(
                requiredRoles: const ['admin'],
                child: const Text('Admin Content'),
                fallback: const Text('Access Denied'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Admin Content'), findsNothing);
      expect(find.text('Access Denied'), findsOneWidget);
    });

    testWidgets('RoleBasedWidget shows correct content for admin', (WidgetTester tester) async {
      const user = AuthUser(
        id: 1,
        username: 'admin',
        email: 'admin@test.com',
        firstName: 'Admin',
        lastName: 'User',
        isActive: true,
        roles: ['admin'],
      );

      const authState = AuthState(user: user);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier(authState)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: RoleBasedWidget(
                adminChild: const Text('Admin Interface'),
                supervisorChild: const Text('Supervisor Interface'),
                guardChild: const Text('Guard Interface'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Admin Interface'), findsOneWidget);
      expect(find.text('Supervisor Interface'), findsNothing);
      expect(find.text('Guard Interface'), findsNothing);
    });

    test('RouteGuard.canAccess works correctly for different roles', () {
      const adminUser = AuthUser(
        id: 1,
        username: 'admin',
        email: 'admin@test.com',
        firstName: 'Admin',
        lastName: 'User',
        isActive: true,
        roles: ['admin'],
      );

      const supervisorUser = AuthUser(
        id: 2,
        username: 'supervisor',
        email: 'supervisor@test.com',
        firstName: 'Supervisor',
        lastName: 'User',
        isActive: true,
        roles: ['supervisor'],
      );

      const guardUser = AuthUser(
        id: 3,
        username: 'guard',
        email: 'guard@test.com',
        firstName: 'Guard',
        lastName: 'User',
        isActive: true,
        roles: ['guard'],
      );

      // Test admin access
      expect(RouteGuard.canAccess('/users', adminUser), true);
      expect(RouteGuard.canAccess('/sites', adminUser), true);
      expect(RouteGuard.canAccess('/settings', adminUser), true);

      // Test supervisor access
      expect(RouteGuard.canAccess('/users', supervisorUser), false);
      expect(RouteGuard.canAccess('/sites', supervisorUser), true);
      expect(RouteGuard.canAccess('/patrols', supervisorUser), true);
      expect(RouteGuard.canAccess('/settings', supervisorUser), false);

      // Test guard access
      expect(RouteGuard.canAccess('/users', guardUser), false);
      expect(RouteGuard.canAccess('/sites', guardUser), true);
      expect(RouteGuard.canAccess('/my-patrols', guardUser), true);
      expect(RouteGuard.canAccess('/settings', guardUser), false);
    });

    test('Permissions constants are correctly defined', () {
      expect(Permissions.userManagement, ['admin']);
      expect(Permissions.userCreate, ['admin']);
      expect(Permissions.siteView, ['admin', 'supervisor', 'guard']);
      expect(Permissions.patrolManagement, ['admin', 'supervisor']);
    });
  });
}

// Mock AuthNotifier for testing
class MockAuthNotifier extends AuthNotifier {
  final AuthState _state;

  MockAuthNotifier(this._state) : super(MockAuthService());

  @override
  AuthState get state => _state;
}

// Mock AuthService for testing
class MockAuthService {
  // Minimal implementation for testing
}
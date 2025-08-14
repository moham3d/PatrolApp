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

      const operationsManagerUser = AuthUser(
        id: 2,
        username: 'ops_manager',
        email: 'ops@test.com',
        firstName: 'Operations',
        lastName: 'Manager',
        isActive: true,
        roles: ['operations_manager'],
      );

      const siteManagerUser = AuthUser(
        id: 3,
        username: 'site_manager',
        email: 'site@test.com',
        firstName: 'Site',
        lastName: 'Manager',
        isActive: true,
        roles: ['site_manager'],
      );

      const supervisorUser = AuthUser(
        id: 4,
        username: 'supervisor',
        email: 'supervisor@test.com',
        firstName: 'Supervisor',
        lastName: 'User',
        isActive: true,
        roles: ['supervisor'],
      );

      const guardUser = AuthUser(
        id: 5,
        username: 'guard',
        email: 'guard@test.com',
        firstName: 'Guard',
        lastName: 'User',
        isActive: true,
        roles: ['guard'],
      );

      // Test admin access (should have access to everything)
      expect(RouteGuard.canAccess('/users', adminUser), true);
      expect(RouteGuard.canAccess('/sites', adminUser), true);
      expect(RouteGuard.canAccess('/patrols', adminUser), true);
      expect(RouteGuard.canAccess('/checkpoints', adminUser), true);
      expect(RouteGuard.canAccess('/settings', adminUser), true);

      // Test operations manager access
      expect(RouteGuard.canAccess('/users', operationsManagerUser), true);
      expect(RouteGuard.canAccess('/sites', operationsManagerUser), true);
      expect(RouteGuard.canAccess('/patrols', operationsManagerUser), true);
      expect(RouteGuard.canAccess('/checkpoints', operationsManagerUser), true);
      expect(RouteGuard.canAccess('/settings', operationsManagerUser), false); // Only admin

      // Test site manager access
      expect(RouteGuard.canAccess('/users', siteManagerUser), true); // Can manage site users
      expect(RouteGuard.canAccess('/sites', siteManagerUser), true);
      expect(RouteGuard.canAccess('/patrols', siteManagerUser), true);
      expect(RouteGuard.canAccess('/checkpoints', siteManagerUser), true);
      expect(RouteGuard.canAccess('/settings', siteManagerUser), false);

      // Test supervisor access
      expect(RouteGuard.canAccess('/users', supervisorUser), true); // Can view site users
      expect(RouteGuard.canAccess('/sites', supervisorUser), true);
      expect(RouteGuard.canAccess('/patrols', supervisorUser), true);
      expect(RouteGuard.canAccess('/checkpoints', supervisorUser), true);
      expect(RouteGuard.canAccess('/settings', supervisorUser), false);

      // Test guard access
      expect(RouteGuard.canAccess('/users', guardUser), false); // Updated: guards can't access user management
      expect(RouteGuard.canAccess('/sites', guardUser), true); // Can view assigned sites
      expect(RouteGuard.canAccess('/patrols', guardUser), true); // Can view assigned patrols
      expect(RouteGuard.canAccess('/checkpoints', guardUser), true); // Can view checkpoints
      expect(RouteGuard.canAccess('/settings', guardUser), false);
    });

    test('Permissions constants are correctly defined for minimal scope', () {
      expect(Permissions.userList, ['admin', 'operations_manager', 'site_manager', 'supervisor']);
      expect(Permissions.userCreate, ['admin', 'operations_manager', 'site_manager']);
      expect(Permissions.siteList, ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']);
      expect(Permissions.siteCreate, ['admin', 'operations_manager']);
      expect(Permissions.patrolList, ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']);
      expect(Permissions.checkpointList, ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']);
      expect(Permissions.systemSettings, ['admin']);
    });

    test('User role checking methods work correctly', () {
      const adminUser = AuthUser(
        id: 1,
        username: 'admin',
        email: 'admin@test.com',
        firstName: 'Admin',
        lastName: 'User',
        isActive: true,
        roles: ['admin'],
      );

      const multiRoleUser = AuthUser(
        id: 2,
        username: 'multi',
        email: 'multi@test.com',
        firstName: 'Multi',
        lastName: 'Role',
        isActive: true,
        roles: ['site_manager', 'supervisor'],
      );

      // Test individual role checks
      expect(adminUser.isAdmin, true);
      expect(adminUser.isOperationsManager, false);
      expect(adminUser.isSiteManager, false);
      expect(adminUser.primaryRole, 'Admin');

      expect(multiRoleUser.isSiteManager, true);
      expect(multiRoleUser.isSupervisor, true);
      expect(multiRoleUser.isAdmin, false);
      expect(multiRoleUser.primaryRole, 'Site Manager'); // Should return highest priority role

      // Test permission helper methods
      expect(adminUser.canManageUsers, true);
      expect(adminUser.canManageAllSites, true);
      expect(multiRoleUser.canManageUsers, false); // Operations Manager required
      expect(multiRoleUser.canManageAssignedSites, true);
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
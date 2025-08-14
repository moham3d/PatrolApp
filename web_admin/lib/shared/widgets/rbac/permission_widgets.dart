import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../shared/models/auth.dart';

/// A widget that conditionally renders its child based on user permissions
class PermissionGuard extends ConsumerWidget {
  final Widget child;
  final List<String> requiredRoles;
  final bool requireAll;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.child,
    required this.requiredRoles,
    this.requireAll = false,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return fallback ?? const SizedBox.shrink();
    }

    final hasPermission = _checkPermission(user, requiredRoles, requireAll);

    if (hasPermission) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }

  bool _checkPermission(AuthUser user, List<String> roles, bool requireAll) {
    if (roles.isEmpty) return true;

    if (requireAll) {
      return roles.every((role) => user.hasRole(role));
    } else {
      return roles.any((role) => user.hasRole(role));
    }
  }
}

/// A button that only shows for users with the required permissions
class PermissionButton extends ConsumerWidget {
  final Widget child;
  final List<String> requiredRoles;
  final VoidCallback? onPressed;

  const PermissionButton({
    super.key,
    required this.child,
    required this.requiredRoles,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null || !_hasPermission(user)) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: child,
    );
  }

  bool _hasPermission(AuthUser user) {
    return requiredRoles.isEmpty || requiredRoles.any((role) => user.hasRole(role));
  }
}

/// A widget that shows different content based on specific access patterns
class AccessPatternWidget extends ConsumerWidget {
  final Widget? fullAccessChild;
  final Widget? siteOnlyChild;
  final Widget? assignedOnlyChild;
  final Widget? selfOnlyChild;
  final Widget? noAccessChild;

  const AccessPatternWidget({
    super.key,
    this.fullAccessChild,
    this.siteOnlyChild,
    this.assignedOnlyChild,
    this.selfOnlyChild,
    this.noAccessChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return noAccessChild ?? const SizedBox.shrink();
    }

    // Full access: Admin, Operations Manager
    if (user.isAdmin || user.isOperationsManager) {
      return fullAccessChild ?? const SizedBox.shrink();
    }

    // Site-only access: Site Manager, Supervisor (for some operations)
    if (user.isSiteManager || user.isSupervisor) {
      return siteOnlyChild ?? const SizedBox.shrink();
    }

    // Assigned-only access: Guards
    if (user.isGuard || user.isMobileGuard) {
      return assignedOnlyChild ?? const SizedBox.shrink();
    }

    return noAccessChild ?? const SizedBox.shrink();
  }
}

/// A widget that renders different content based on user role
class RoleBasedWidget extends ConsumerWidget {
  final Widget? adminChild;
  final Widget? operationsManagerChild;
  final Widget? siteManagerChild;
  final Widget? supervisorChild;
  final Widget? guardChild;
  final Widget? defaultChild;

  const RoleBasedWidget({
    super.key,
    this.adminChild,
    this.operationsManagerChild,
    this.siteManagerChild,
    this.supervisorChild,
    this.guardChild,
    this.defaultChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return defaultChild ?? const SizedBox.shrink();
    }

    // Admin has highest priority
    if (user.isAdmin && adminChild != null) {
      return adminChild!;
    }

    // Operations Manager
    if (user.isOperationsManager && operationsManagerChild != null) {
      return operationsManagerChild!;
    }

    // Site Manager
    if (user.isSiteManager && siteManagerChild != null) {
      return siteManagerChild!;
    }

    // Supervisor
    if (user.isSupervisor && supervisorChild != null) {
      return supervisorChild!;
    }

    // Guard or Mobile Guard
    if ((user.isGuard || user.isMobileGuard) && guardChild != null) {
      return guardChild!;
    }

    return defaultChild ?? const SizedBox.shrink();
  }
}

/// A mixin for widgets that need to check permissions
mixin PermissionCheckMixin {
  bool hasPermission(AuthUser? user, List<String> requiredRoles, {bool requireAll = false}) {
    if (user == null) return false;
    if (requiredRoles.isEmpty) return true;

    if (requireAll) {
      return requiredRoles.every((role) => user.hasRole(role));
    } else {
      return requiredRoles.any((role) => user.hasRole(role));
    }
  }

  bool isAdmin(AuthUser? user) => user?.isAdmin ?? false;
  bool isSupervisor(AuthUser? user) => user?.isSupervisor ?? false;
  bool isGuard(AuthUser? user) => user?.isGuard ?? false;
}

/// Permission constants for the application based on access matrix
class Permissions {
  // User management permissions (based on access matrix)
  static const List<String> userList = ['admin', 'operations_manager', 'site_manager', 'supervisor']; // with site restrictions for site_manager/supervisor
  static const List<String> userCreate = ['admin', 'operations_manager', 'site_manager'];
  static const List<String> userView = ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']; // with restrictions
  static const List<String> userEdit = ['admin', 'operations_manager', 'site_manager', 'guard', 'mobile_guard']; // with restrictions  
  static const List<String> userDelete = ['admin', 'operations_manager'];
  static const List<String> userStatusUpdate = ['admin', 'operations_manager', 'site_manager'];

  // Site management permissions
  static const List<String> siteList = ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']; // with assignment restrictions
  static const List<String> siteCreate = ['admin', 'operations_manager'];
  static const List<String> siteView = ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']; // with assignment restrictions
  static const List<String> siteEdit = ['admin', 'operations_manager', 'site_manager']; // with management restrictions for site_manager
  static const List<String> siteDelete = ['admin']; // only admin can delete sites

  // Patrol/Task management permissions  
  static const List<String> patrolList = ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']; // with assignment restrictions
  static const List<String> patrolCreate = ['admin', 'operations_manager', 'site_manager', 'supervisor'];
  static const List<String> patrolView = ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']; // with assignment restrictions
  static const List<String> patrolEdit = ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']; // with assignment restrictions
  static const List<String> patrolDelete = ['admin', 'operations_manager'];
  static const List<String> patrolAssign = ['admin', 'operations_manager', 'site_manager', 'supervisor'];

  // Checkpoint management permissions
  static const List<String> checkpointList = ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']; // with site restrictions
  static const List<String> checkpointCreate = ['admin', 'operations_manager', 'site_manager'];
  static const List<String> checkpointView = ['admin', 'operations_manager', 'site_manager', 'supervisor', 'guard', 'mobile_guard']; // with site restrictions
  static const List<String> checkpointEdit = ['admin', 'operations_manager', 'site_manager'];
  static const List<String> checkpointDelete = ['admin', 'operations_manager'];

  // System-wide permissions (minimal scope - only what's needed)
  static const List<String> systemSettings = ['admin'];
  static const List<String> fullSystemAccess = ['admin', 'operations_manager'];
}
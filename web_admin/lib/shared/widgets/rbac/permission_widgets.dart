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

/// A widget that renders different content based on user role
class RoleBasedWidget extends ConsumerWidget {
  final Widget? adminChild;
  final Widget? supervisorChild;
  final Widget? guardChild;
  final Widget? defaultChild;

  const RoleBasedWidget({
    super.key,
    this.adminChild,
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

    // Supervisor is second priority
    if (user.isSupervisor && supervisorChild != null) {
      return supervisorChild!;
    }

    // Guard is third priority
    if (user.isGuard && guardChild != null) {
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

/// Permission constants for the application
class Permissions {
  // User management permissions
  static const List<String> userManagement = ['admin'];
  static const List<String> userView = ['admin', 'supervisor'];
  static const List<String> userCreate = ['admin'];
  static const List<String> userEdit = ['admin'];
  static const List<String> userDelete = ['admin'];

  // Site management permissions
  static const List<String> siteManagement = ['admin', 'supervisor'];
  static const List<String> siteView = ['admin', 'supervisor', 'guard'];
  static const List<String> siteCreate = ['admin', 'supervisor'];
  static const List<String> siteEdit = ['admin', 'supervisor'];

  // Patrol management permissions
  static const List<String> patrolManagement = ['admin', 'supervisor'];
  static const List<String> patrolView = ['admin', 'supervisor', 'guard'];
  static const List<String> patrolCreate = ['admin', 'supervisor'];
  static const List<String> patrolEdit = ['admin', 'supervisor'];
  static const List<String> patrolAssign = ['admin', 'supervisor'];

  // Checkpoint management permissions
  static const List<String> checkpointManagement = ['admin', 'supervisor'];
  static const List<String> checkpointView = ['admin', 'supervisor', 'guard'];
  static const List<String> checkpointCreate = ['admin', 'supervisor'];
  static const List<String> checkpointEdit = ['admin', 'supervisor'];

  // System-wide permissions
  static const List<String> systemSettings = ['admin'];
  static const List<String> reporting = ['admin', 'supervisor'];
  static const List<String> analytics = ['admin', 'supervisor'];
}
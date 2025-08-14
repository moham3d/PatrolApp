import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

@JsonSerializable()
class AuthToken {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    required this.tokenType,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) => 
      _$AuthTokenFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokenToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => 
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class AuthUser {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<String> roles;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.roles,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => 
      _$AuthUserFromJson(json);
  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  String get fullName => '$firstName $lastName';
  
  bool hasRole(String role) => roles.contains(role);
  
  // Core role checks based on access matrix
  bool get isAdmin => roles.contains('admin');
  bool get isOperationsManager => roles.contains('operations_manager');
  bool get isSiteManager => roles.contains('site_manager');
  bool get isSupervisor => roles.contains('supervisor');
  bool get isGuard => roles.contains('guard');
  bool get isMobileGuard => roles.contains('mobile_guard');
  bool get isVisitor => roles.contains('visitor');
  
  // Helper methods for permission checking
  bool get canManageUsers => isAdmin || isOperationsManager;
  bool get canManageAllSites => isAdmin || isOperationsManager;
  bool get canManageAssignedSites => isSiteManager || isSupervisor;
  bool get canViewAssignedSites => isSiteManager || isSupervisor || isGuard || isMobileGuard;
  bool get canManagePatrols => isAdmin || isOperationsManager || isSiteManager || isSupervisor;
  bool get canViewAssignedPatrols => isGuard || isMobileGuard;
  bool get canManageCheckpoints => isAdmin || isOperationsManager || isSiteManager || isSupervisor;
  
  // Get highest role for UI display
  String get primaryRole {
    if (isAdmin) return 'Admin';
    if (isOperationsManager) return 'Operations Manager';
    if (isSiteManager) return 'Site Manager';
    if (isSupervisor) return 'Supervisor';
    if (isGuard) return 'Guard';
    if (isMobileGuard) return 'Mobile Guard';
    if (isVisitor) return 'Visitor';
    return 'User';
  }
}
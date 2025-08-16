import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? phone;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final String status;
  @JsonKey(name: 'employment_date')
  final String? employmentDate;
  @JsonKey(name: 'job_title')
  final String? jobTitle;
  final String? department;
  final List<String> roles;
  final List<String> permissions;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phone,
    required this.isActive,
    required this.status,
    this.employmentDate,
    this.jobTitle,
    this.department,
    required this.roles,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    bool? isActive,
    String? status,
    String? employmentDate,
    String? jobTitle,
    String? department,
    List<String>? roles,
    List<String>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      employmentDate: employmentDate ?? this.employmentDate,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Role checking methods to match access matrix
  bool hasRole(String role) => roles.contains(role);
  bool get isAdmin => roles.contains('admin');
  bool get isOperationsManager => roles.contains('operations_manager');
  bool get isSiteManager => roles.contains('site_manager');
  bool get isSupervisor => roles.contains('supervisor');
  bool get isGuard => roles.contains('guard');
  bool get isMobileGuard => roles.contains('mobile_guard');
  bool get isVisitor => roles.contains('visitor');

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

@JsonSerializable()
class CreateUserRequest {
  final String username;
  final String email;
  final String password;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? phone;
  @JsonKey(name: 'role_ids')
  final List<int> roleIds;

  const CreateUserRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    required this.roleIds,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UpdateUserRequest {
  final String? username;
  final String? email;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? phone;
  @JsonKey(name: 'role_ids')
  final List<int>? roleIds;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  const UpdateUserRequest({
    this.username,
    this.email,
    this.fullName,
    this.phone,
    this.roleIds,
    this.isActive,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}

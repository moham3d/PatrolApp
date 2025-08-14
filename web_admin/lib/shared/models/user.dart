import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String? phone;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<String> roles;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.isActive,
    required this.roles,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    bool? isActive,
    List<String>? roles,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get fullName => '$firstName $lastName';
  
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
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String? phone;
  @JsonKey(name: 'role_ids')
  final List<int> roleIds;

  const CreateUserRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.roleIds,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

@JsonSerializable()
class UpdateUserRequest {
  final String? username;
  final String? email;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? phone;
  @JsonKey(name: 'role_ids')
  final List<int>? roleIds;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  const UpdateUserRequest({
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.roleIds,
    this.isActive,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}
import 'package:json_annotation/json_annotation.dart';

part 'patrol.g.dart';

@JsonSerializable()
class AssignedUser {
  final int id;
  final String name;

  const AssignedUser({
    required this.id,
    required this.name,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) => 
      _$AssignedUserFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedUserToJson(this);
}

@JsonSerializable()
class AssignedSite {
  final int id;
  final String name;

  const AssignedSite({
    required this.id,
    required this.name,
  });

  factory AssignedSite.fromJson(Map<String, dynamic> json) => 
      _$AssignedSiteFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedSiteToJson(this);
}

@JsonSerializable()
class Patrol {
  final int id;
  final String title;
  final String? description;
  @JsonKey(name: 'task_type')
  final String taskType;
  final String status;
  final String priority;
  @JsonKey(name: 'assigned_to')
  final AssignedUser? assignedTo;
  final AssignedSite? site;
  @JsonKey(name: 'scheduled_start')
  final DateTime scheduledStart;
  @JsonKey(name: 'scheduled_end')
  final DateTime scheduledEnd;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Patrol({
    required this.id,
    required this.title,
    this.description,
    required this.taskType,
    required this.status,
    required this.priority,
    this.assignedTo,
    this.site,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.createdAt,
  });

  factory Patrol.fromJson(Map<String, dynamic> json) => _$PatrolFromJson(json);
  Map<String, dynamic> toJson() => _$PatrolToJson(this);

  Patrol copyWith({
    int? id,
    String? title,
    String? description,
    String? taskType,
    String? status,
    String? priority,
    AssignedUser? assignedTo,
    AssignedSite? site,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    DateTime? createdAt,
  }) {
    return Patrol(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      site: site ?? this.site,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@JsonSerializable()
class CreatePatrolRequest {
  final String title;
  final String? description;
  @JsonKey(name: 'task_type')
  final String taskType;
  final String priority;
  @JsonKey(name: 'assigned_to_id')
  final int? assignedToId;
  @JsonKey(name: 'site_id')
  final int? siteId;
  @JsonKey(name: 'scheduled_start')
  final DateTime scheduledStart;
  @JsonKey(name: 'scheduled_end')
  final DateTime scheduledEnd;

  const CreatePatrolRequest({
    required this.title,
    this.description,
    required this.taskType,
    required this.priority,
    this.assignedToId,
    this.siteId,
    required this.scheduledStart,
    required this.scheduledEnd,
  });

  factory CreatePatrolRequest.fromJson(Map<String, dynamic> json) => 
      _$CreatePatrolRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePatrolRequestToJson(this);
}

@JsonSerializable()
class UpdatePatrolRequest {
  final String? title;
  final String? description;
  @JsonKey(name: 'task_type')
  final String? taskType;
  final String? status;
  final String? priority;
  @JsonKey(name: 'assigned_to_id')
  final int? assignedToId;
  @JsonKey(name: 'site_id')
  final int? siteId;
  @JsonKey(name: 'scheduled_start')
  final DateTime? scheduledStart;
  @JsonKey(name: 'scheduled_end')
  final DateTime? scheduledEnd;

  const UpdatePatrolRequest({
    this.title,
    this.description,
    this.taskType,
    this.status,
    this.priority,
    this.assignedToId,
    this.siteId,
    this.scheduledStart,
    this.scheduledEnd,
  });

  factory UpdatePatrolRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdatePatrolRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePatrolRequestToJson(this);
}
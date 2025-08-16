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
  @JsonKey(name: 'assigned_to')
  final int? assignedTo;
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  final String status;
  final String priority;
  @JsonKey(name: 'created_by')
  final int createdBy;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'task_type')
  final String taskType;
  @JsonKey(name: 'site_id')
  final int? siteId;
  @JsonKey(name: 'estimated_duration')
  final int? estimatedDuration;
  @JsonKey(name: 'start_time')
  final DateTime? startTime;
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  @JsonKey(name: 'completion_percentage')
  final int completionPercentage;
  @JsonKey(name: 'is_recurring')
  final bool isRecurring;
  @JsonKey(name: 'recurrence_pattern')
  final String? recurrencePattern;
  @JsonKey(name: 'next_due_date')
  final DateTime? nextDueDate;
  final List<dynamic> checkpoints;
  @JsonKey(name: 'checkpoint_visits')
  final List<dynamic> checkpointVisits;

  const Patrol({
    required this.id,
    required this.title,
    this.description,
    this.assignedTo,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.taskType,
    this.siteId,
    this.estimatedDuration,
    this.startTime,
    this.endTime,
    required this.completionPercentage,
    required this.isRecurring,
    this.recurrencePattern,
    this.nextDueDate,
    required this.checkpoints,
    required this.checkpointVisits,
  });

  factory Patrol.fromJson(Map<String, dynamic> json) => _$PatrolFromJson(json);
  Map<String, dynamic> toJson() => _$PatrolToJson(this);

  Patrol copyWith({
    int? id,
    String? title,
    String? description,
    int? assignedTo,
    DateTime? dueDate,
    String? status,
    String? priority,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? taskType,
    int? siteId,
    int? estimatedDuration,
    DateTime? startTime,
    DateTime? endTime,
    int? completionPercentage,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? nextDueDate,
    List<dynamic>? checkpoints,
    List<dynamic>? checkpointVisits,
  }) {
    return Patrol(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskType: taskType ?? this.taskType,
      siteId: siteId ?? this.siteId,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      checkpoints: checkpoints ?? this.checkpoints,
      checkpointVisits: checkpointVisits ?? this.checkpointVisits,
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

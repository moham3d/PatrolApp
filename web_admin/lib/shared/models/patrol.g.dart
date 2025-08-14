// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patrol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedUser _$AssignedUserFromJson(Map<String, dynamic> json) => AssignedUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$AssignedUserToJson(AssignedUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

AssignedSite _$AssignedSiteFromJson(Map<String, dynamic> json) => AssignedSite(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$AssignedSiteToJson(AssignedSite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Patrol _$PatrolFromJson(Map<String, dynamic> json) => Patrol(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      taskType: json['task_type'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      assignedTo: json['assigned_to'] == null
          ? null
          : AssignedUser.fromJson(json['assigned_to'] as Map<String, dynamic>),
      site: json['site'] == null
          ? null
          : AssignedSite.fromJson(json['site'] as Map<String, dynamic>),
      scheduledStart: DateTime.parse(json['scheduled_start'] as String),
      scheduledEnd: DateTime.parse(json['scheduled_end'] as String),
      actualStart: json['actual_start'] == null
          ? null
          : DateTime.parse(json['actual_start'] as String),
      actualEnd: json['actual_end'] == null
          ? null
          : DateTime.parse(json['actual_end'] as String),
      checkpointsCompleted: (json['checkpoints_completed'] as num?)?.toInt() ?? 0,
      checkpointsTotal: (json['checkpoints_total'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PatrolToJson(Patrol instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'task_type': instance.taskType,
      'status': instance.status,
      'priority': instance.priority,
      'assigned_to': instance.assignedTo?.toJson(),
      'site': instance.site?.toJson(),
      'scheduled_start': instance.scheduledStart.toIso8601String(),
      'scheduled_end': instance.scheduledEnd.toIso8601String(),
      'actual_start': instance.actualStart?.toIso8601String(),
      'actual_end': instance.actualEnd?.toIso8601String(),
      'checkpoints_completed': instance.checkpointsCompleted,
      'checkpoints_total': instance.checkpointsTotal,
      'created_at': instance.createdAt.toIso8601String(),
    };

CreatePatrolRequest _$CreatePatrolRequestFromJson(Map<String, dynamic> json) =>
    CreatePatrolRequest(
      title: json['title'] as String,
      description: json['description'] as String?,
      taskType: json['task_type'] as String,
      priority: json['priority'] as String,
      assignedToId: (json['assigned_to_id'] as num?)?.toInt(),
      siteId: (json['site_id'] as num?)?.toInt(),
      scheduledStart: DateTime.parse(json['scheduled_start'] as String),
      scheduledEnd: DateTime.parse(json['scheduled_end'] as String),
    );

Map<String, dynamic> _$CreatePatrolRequestToJson(CreatePatrolRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'task_type': instance.taskType,
      'priority': instance.priority,
      'assigned_to_id': instance.assignedToId,
      'site_id': instance.siteId,
      'scheduled_start': instance.scheduledStart.toIso8601String(),
      'scheduled_end': instance.scheduledEnd.toIso8601String(),
    };

UpdatePatrolRequest _$UpdatePatrolRequestFromJson(Map<String, dynamic> json) =>
    UpdatePatrolRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      taskType: json['task_type'] as String?,
      status: json['status'] as String?,
      priority: json['priority'] as String?,
      assignedToId: (json['assigned_to_id'] as num?)?.toInt(),
      siteId: (json['site_id'] as num?)?.toInt(),
      scheduledStart: json['scheduled_start'] == null
          ? null
          : DateTime.parse(json['scheduled_start'] as String),
      scheduledEnd: json['scheduled_end'] == null
          ? null
          : DateTime.parse(json['scheduled_end'] as String),
    );

Map<String, dynamic> _$UpdatePatrolRequestToJson(UpdatePatrolRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'task_type': instance.taskType,
      'status': instance.status,
      'priority': instance.priority,
      'assigned_to_id': instance.assignedToId,
      'site_id': instance.siteId,
      'scheduled_start': instance.scheduledStart?.toIso8601String(),
      'scheduled_end': instance.scheduledEnd?.toIso8601String(),
    };

// Custom exception for patrol operations
class PatrolException implements Exception {
  final String code;
  final String message;

  const PatrolException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'PatrolException: $message (code: $code)';
}
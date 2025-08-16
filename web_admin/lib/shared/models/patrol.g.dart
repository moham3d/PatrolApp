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
      assignedTo: (json['assigned_to'] as num?)?.toInt(),
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String,
      priority: json['priority'] as String,
      createdBy: (json['created_by'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      taskType: json['task_type'] as String,
      siteId: (json['site_id'] as num?)?.toInt(),
      estimatedDuration: (json['estimated_duration'] as num?)?.toInt(),
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      completionPercentage: (json['completion_percentage'] as num).toInt(),
      isRecurring: json['is_recurring'] as bool,
      recurrencePattern: json['recurrence_pattern'] as String?,
      nextDueDate: json['next_due_date'] == null
          ? null
          : DateTime.parse(json['next_due_date'] as String),
      checkpoints: json['checkpoints'] as List<dynamic>,
      checkpointVisits: json['checkpoint_visits'] as List<dynamic>,
    );

Map<String, dynamic> _$PatrolToJson(Patrol instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'assigned_to': instance.assignedTo,
      'due_date': instance.dueDate.toIso8601String(),
      'status': instance.status,
      'priority': instance.priority,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'task_type': instance.taskType,
      'site_id': instance.siteId,
      'estimated_duration': instance.estimatedDuration,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'completion_percentage': instance.completionPercentage,
      'is_recurring': instance.isRecurring,
      'recurrence_pattern': instance.recurrencePattern,
      'next_due_date': instance.nextDueDate?.toIso8601String(),
      'checkpoints': instance.checkpoints,
      'checkpoint_visits': instance.checkpointVisits,
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

Map<String, dynamic> _$CreatePatrolRequestToJson(
        CreatePatrolRequest instance) =>
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

Map<String, dynamic> _$UpdatePatrolRequestToJson(
        UpdatePatrolRequest instance) =>
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Checkpoint _$CheckpointFromJson(Map<String, dynamic> json) => Checkpoint(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  siteId: (json['site_id'] as num).toInt(),
  locationId: (json['location_id'] as num?)?.toInt(),
  areaId: (json['area_id'] as num?)?.toInt(),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  qrCode: json['qr_code'] as String?,
  nfcTagId: json['nfc_tag_id'] as String?,
  orderSequence: (json['order_sequence'] as num).toInt(),
  isMandatory: json['is_mandatory'] as bool,
  timeLimitMinutes: (json['time_limit_minutes'] as num?)?.toInt(),
  isActive: json['is_active'] as bool,
  checkpointType: json['checkpoint_type'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CheckpointToJson(Checkpoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'site_id': instance.siteId,
      'location_id': instance.locationId,
      'area_id': instance.areaId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'qr_code': instance.qrCode,
      'nfc_tag_id': instance.nfcTagId,
      'order_sequence': instance.orderSequence,
      'is_mandatory': instance.isMandatory,
      'time_limit_minutes': instance.timeLimitMinutes,
      'is_active': instance.isActive,
      'checkpoint_type': instance.checkpointType,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

CreateCheckpointRequest _$CreateCheckpointRequestFromJson(
  Map<String, dynamic> json,
) => CreateCheckpointRequest(
  name: json['name'] as String,
  description: json['description'] as String?,
  siteId: (json['site_id'] as num).toInt(),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  qrCode: json['qr_code'] as String?,
  nfcTagId: json['nfc_tag_id'] as String?,
);

Map<String, dynamic> _$CreateCheckpointRequestToJson(
  CreateCheckpointRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'site_id': instance.siteId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'qr_code': instance.qrCode,
  'nfc_tag_id': instance.nfcTagId,
};

UpdateCheckpointRequest _$UpdateCheckpointRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCheckpointRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
  siteId: (json['site_id'] as num?)?.toInt(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  qrCode: json['qr_code'] as String?,
  nfcTagId: json['nfc_tag_id'] as String?,
  isActive: json['is_active'] as bool?,
  visitDuration: (json['time_limit_minutes'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateCheckpointRequestToJson(
  UpdateCheckpointRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'site_id': instance.siteId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'qr_code': instance.qrCode,
  'nfc_tag_id': instance.nfcTagId,
  'is_active': instance.isActive,
  'time_limit_minutes': instance.visitDuration,
};

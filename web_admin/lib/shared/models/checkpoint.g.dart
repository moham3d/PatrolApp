// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

Checkpoint _$CheckpointFromJson(Map<String, dynamic> json) => Checkpoint(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      siteId: (json['site_id'] as num).toInt(),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      qrCode: json['qr_code'] as String?,
      nfcTag: json['nfc_tag'] as String?,
      isActive: json['is_active'] as bool,
      visitDuration: (json['visit_duration'] as num).toInt(),
    );

Map<String, dynamic> _$CheckpointToJson(Checkpoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'site_id': instance.siteId,
      'location': instance.location.toJson(),
      'qr_code': instance.qrCode,
      'nfc_tag': instance.nfcTag,
      'is_active': instance.isActive,
      'visit_duration': instance.visitDuration,
    };

CreateCheckpointRequest _$CreateCheckpointRequestFromJson(
        Map<String, dynamic> json) =>
    CreateCheckpointRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      siteId: (json['site_id'] as num).toInt(),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      qrCode: json['qr_code'] as String?,
      nfcTag: json['nfc_tag'] as String?,
      visitDuration: (json['visit_duration'] as num).toInt(),
    );

Map<String, dynamic> _$CreateCheckpointRequestToJson(
        CreateCheckpointRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'site_id': instance.siteId,
      'location': instance.location.toJson(),
      'qr_code': instance.qrCode,
      'nfc_tag': instance.nfcTag,
      'visit_duration': instance.visitDuration,
    };

UpdateCheckpointRequest _$UpdateCheckpointRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateCheckpointRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      siteId: (json['site_id'] as num?)?.toInt(),
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      qrCode: json['qr_code'] as String?,
      nfcTag: json['nfc_tag'] as String?,
      isActive: json['is_active'] as bool?,
      visitDuration: (json['visit_duration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateCheckpointRequestToJson(
        UpdateCheckpointRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'site_id': instance.siteId,
      'location': instance.location?.toJson(),
      'qr_code': instance.qrCode,
      'nfc_tag': instance.nfcTag,
      'is_active': instance.isActive,
      'visit_duration': instance.visitDuration,
    };

// Custom exception for checkpoint operations
class CheckpointException implements Exception {
  final String code;
  final String message;

  const CheckpointException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'CheckpointException: $message (code: $code)';
}
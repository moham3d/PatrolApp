// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) => Coordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordinatesToJson(Coordinates instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

ContactInfo _$ContactInfoFromJson(Map<String, dynamic> json) => ContactInfo(
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$ContactInfoToJson(ContactInfo instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'email': instance.email,
    };

Site _$SiteFromJson(Map<String, dynamic> json) => Site(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      coordinates: Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      contactInfo: json['contact_info'] == null
          ? null
          : ContactInfo.fromJson(json['contact_info'] as Map<String, dynamic>),
      isActive: json['is_active'] as bool,
      checkpointsCount: (json['checkpoints_count'] as num).toInt(),
    );

Map<String, dynamic> _$SiteToJson(Site instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'coordinates': instance.coordinates.toJson(),
      'contact_info': instance.contactInfo?.toJson(),
      'is_active': instance.isActive,
      'checkpoints_count': instance.checkpointsCount,
    };

CreateSiteRequest _$CreateSiteRequestFromJson(Map<String, dynamic> json) =>
    CreateSiteRequest(
      name: json['name'] as String,
      address: json['address'] as String,
      coordinates: Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      contactInfo: json['contact_info'] == null
          ? null
          : ContactInfo.fromJson(json['contact_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateSiteRequestToJson(CreateSiteRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'coordinates': instance.coordinates.toJson(),
      'contact_info': instance.contactInfo?.toJson(),
    };

UpdateSiteRequest _$UpdateSiteRequestFromJson(Map<String, dynamic> json) =>
    UpdateSiteRequest(
      name: json['name'] as String?,
      address: json['address'] as String?,
      coordinates: json['coordinates'] == null
          ? null
          : Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      contactInfo: json['contact_info'] == null
          ? null
          : ContactInfo.fromJson(json['contact_info'] as Map<String, dynamic>),
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$UpdateSiteRequestToJson(UpdateSiteRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'coordinates': instance.coordinates?.toJson(),
      'contact_info': instance.contactInfo?.toJson(),
      'is_active': instance.isActive,
    };

// Custom exception for site operations
class SiteException implements Exception {
  final String code;
  final String message;

  const SiteException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'SiteException: $message (code: $code)';
}
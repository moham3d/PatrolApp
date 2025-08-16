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

SiteConfiguration _$SiteConfigurationFromJson(Map<String, dynamic> json) =>
    SiteConfiguration(
      operatingHours: json['operating_hours'] == null
          ? null
          : OperatingHours.fromJson(
              json['operating_hours'] as Map<String, dynamic>),
      securityLevel: json['security_level'] as String?,
      patrolFrequencyMinutes:
          (json['patrol_frequency_minutes'] as num?)?.toInt(),
      emergencyContacts: (json['emergency_contacts'] as List<dynamic>?)
          ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      specialInstructions: json['special_instructions'] as String?,
      equipmentRequired: (json['equipment_required'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      geofenceRadiusMeters:
          (json['geofence_radius_meters'] as num?)?.toDouble(),
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$SiteConfigurationToJson(SiteConfiguration instance) =>
    <String, dynamic>{
      'operating_hours': instance.operatingHours,
      'security_level': instance.securityLevel,
      'patrol_frequency_minutes': instance.patrolFrequencyMinutes,
      'emergency_contacts': instance.emergencyContacts,
      'special_instructions': instance.specialInstructions,
      'equipment_required': instance.equipmentRequired,
      'geofence_radius_meters': instance.geofenceRadiusMeters,
      'timezone': instance.timezone,
    };

OperatingHours _$OperatingHoursFromJson(Map<String, dynamic> json) =>
    OperatingHours(
      is24_7: json['is_24_7'] as bool,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      daysOfWeek: (json['days_of_week'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$OperatingHoursToJson(OperatingHours instance) =>
    <String, dynamic>{
      'is_24_7': instance.is24_7,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'days_of_week': instance.daysOfWeek,
    };

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    EmergencyContact(
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$EmergencyContactToJson(EmergencyContact instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'role': instance.role,
    };

Site _$SiteFromJson(Map<String, dynamic> json) => Site(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      contactInfo: json['contact_info'] == null
          ? null
          : ContactInfo.fromJson(json['contact_info'] as Map<String, dynamic>),
      isActive: json['is_active'] as bool?,
      checkpointsCount: (json['checkpoints_count'] as num?)?.toInt(),
      configuration: json['configuration'] == null
          ? null
          : SiteConfiguration.fromJson(
              json['configuration'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SiteToJson(Site instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'contact_info': instance.contactInfo,
      'is_active': instance.isActive,
      'checkpoints_count': instance.checkpointsCount,
      'configuration': instance.configuration,
    };

CreateSiteRequest _$CreateSiteRequestFromJson(Map<String, dynamic> json) =>
    CreateSiteRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      contactInfo: json['contact_info'] == null
          ? null
          : ContactInfo.fromJson(json['contact_info'] as Map<String, dynamic>),
      configuration: json['configuration'] == null
          ? null
          : SiteConfiguration.fromJson(
              json['configuration'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateSiteRequestToJson(CreateSiteRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'contact_info': instance.contactInfo,
      'configuration': instance.configuration,
    };

UpdateSiteRequest _$UpdateSiteRequestFromJson(Map<String, dynamic> json) =>
    UpdateSiteRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactInfo: json['contact_info'] == null
          ? null
          : ContactInfo.fromJson(json['contact_info'] as Map<String, dynamic>),
      isActive: json['is_active'] as bool?,
      configuration: json['configuration'] == null
          ? null
          : SiteConfiguration.fromJson(
              json['configuration'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateSiteRequestToJson(UpdateSiteRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'contact_info': instance.contactInfo,
      'is_active': instance.isActive,
      'configuration': instance.configuration,
    };

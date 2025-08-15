import 'package:json_annotation/json_annotation.dart';

part 'site.g.dart';

@JsonSerializable()
class Coordinates {
  final double latitude;
  final double longitude;

  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);
  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);
}

@JsonSerializable()
class ContactInfo {
  final String? phone;
  final String? email;

  const ContactInfo({
    this.phone,
    this.email,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) =>
      _$ContactInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ContactInfoToJson(this);
}

@JsonSerializable()
class SiteConfiguration {
  @JsonKey(name: 'operating_hours')
  final OperatingHours? operatingHours;
  @JsonKey(name: 'security_level')
  final String? securityLevel; // low, medium, high, critical
  @JsonKey(name: 'patrol_frequency_minutes')
  final int? patrolFrequencyMinutes;
  @JsonKey(name: 'emergency_contacts')
  final List<EmergencyContact>? emergencyContacts;
  @JsonKey(name: 'special_instructions')
  final String? specialInstructions;
  @JsonKey(name: 'equipment_required')
  final List<String>? equipmentRequired;
  @JsonKey(name: 'geofence_radius_meters')
  final double? geofenceRadiusMeters;
  @JsonKey(name: 'timezone')
  final String? timezone;

  const SiteConfiguration({
    this.operatingHours,
    this.securityLevel,
    this.patrolFrequencyMinutes,
    this.emergencyContacts,
    this.specialInstructions,
    this.equipmentRequired,
    this.geofenceRadiusMeters,
    this.timezone,
  });

  factory SiteConfiguration.fromJson(Map<String, dynamic> json) =>
      _$SiteConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$SiteConfigurationToJson(this);
}

@JsonSerializable()
class OperatingHours {
  @JsonKey(name: 'is_24_7')
  final bool is24_7;
  @JsonKey(name: 'start_time')
  final String? startTime; // HH:MM format
  @JsonKey(name: 'end_time')
  final String? endTime; // HH:MM format
  @JsonKey(name: 'days_of_week')
  final List<int>? daysOfWeek; // 1-7, Monday=1

  const OperatingHours({
    required this.is24_7,
    this.startTime,
    this.endTime,
    this.daysOfWeek,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) =>
      _$OperatingHoursFromJson(json);
  Map<String, dynamic> toJson() => _$OperatingHoursToJson(this);
}

@JsonSerializable()
class EmergencyContact {
  final String name;
  final String phone;
  final String? role;

  const EmergencyContact({
    required this.name,
    required this.phone,
    this.role,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);
}

@JsonSerializable()
class Site {
  final int id;
  final String name;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'contact_info')
  final ContactInfo? contactInfo;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'checkpoints_count')
  final int? checkpointsCount;
  @JsonKey(name: 'configuration')
  final SiteConfiguration? configuration;

  const Site({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.contactInfo,
    this.isActive,
    this.checkpointsCount,
    this.configuration,
  });

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);
  Map<String, dynamic> toJson() => _$SiteToJson(this);

  Site copyWith({
    int? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    ContactInfo? contactInfo,
    bool? isActive,
    int? checkpointsCount,
    SiteConfiguration? configuration,
  }) {
    return Site(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactInfo: contactInfo ?? this.contactInfo,
      isActive: isActive ?? this.isActive,
      checkpointsCount: checkpointsCount ?? this.checkpointsCount,
      configuration: configuration ?? this.configuration,
    );
  }

  // Helper getter to maintain compatibility with existing code that expects coordinates
  Coordinates get coordinates =>
      Coordinates(latitude: latitude, longitude: longitude);
}

@JsonSerializable()
class CreateSiteRequest {
  final String name;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'contact_info')
  final ContactInfo? contactInfo;
  @JsonKey(name: 'configuration')
  final SiteConfiguration? configuration;

  const CreateSiteRequest({
    required this.name,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.contactInfo,
    this.configuration,
  });

  factory CreateSiteRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSiteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSiteRequestToJson(this);
}

@JsonSerializable()
class UpdateSiteRequest {
  final String? name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'contact_info')
  final ContactInfo? contactInfo;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'configuration')
  final SiteConfiguration? configuration;

  const UpdateSiteRequest({
    this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.contactInfo,
    this.isActive,
    this.configuration,
  });

  factory UpdateSiteRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSiteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateSiteRequestToJson(this);
}

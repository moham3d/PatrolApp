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
class Site {
  final int id;
  final String name;
  final String address;
  final Coordinates coordinates;
  @JsonKey(name: 'contact_info')
  final ContactInfo? contactInfo;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'checkpoints_count')
  final int checkpointsCount;

  const Site({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    this.contactInfo,
    required this.isActive,
    required this.checkpointsCount,
  });

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);
  Map<String, dynamic> toJson() => _$SiteToJson(this);

  Site copyWith({
    int? id,
    String? name,
    String? address,
    Coordinates? coordinates,
    ContactInfo? contactInfo,
    bool? isActive,
    int? checkpointsCount,
  }) {
    return Site(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      coordinates: coordinates ?? this.coordinates,
      contactInfo: contactInfo ?? this.contactInfo,
      isActive: isActive ?? this.isActive,
      checkpointsCount: checkpointsCount ?? this.checkpointsCount,
    );
  }
}

@JsonSerializable()
class CreateSiteRequest {
  final String name;
  final String address;
  final Coordinates coordinates;
  @JsonKey(name: 'contact_info')
  final ContactInfo? contactInfo;

  const CreateSiteRequest({
    required this.name,
    required this.address,
    required this.coordinates,
    this.contactInfo,
  });

  factory CreateSiteRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateSiteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSiteRequestToJson(this);
}

@JsonSerializable()
class UpdateSiteRequest {
  final String? name;
  final String? address;
  final Coordinates? coordinates;
  @JsonKey(name: 'contact_info')
  final ContactInfo? contactInfo;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  const UpdateSiteRequest({
    this.name,
    this.address,
    this.coordinates,
    this.contactInfo,
    this.isActive,
  });

  factory UpdateSiteRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateSiteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateSiteRequestToJson(this);
}
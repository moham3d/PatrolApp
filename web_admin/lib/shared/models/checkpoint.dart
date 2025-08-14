import 'package:json_annotation/json_annotation.dart';
import 'site.dart';

part 'checkpoint.g.dart';

@JsonSerializable()
class Location {
  final double latitude;
  final double longitude;

  const Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => 
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class Checkpoint {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'site_id')
  final int siteId;
  final Location location;
  @JsonKey(name: 'qr_code')
  final String? qrCode;
  @JsonKey(name: 'nfc_tag')
  final String? nfcTag;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'visit_duration')
  final int visitDuration; // in minutes

  const Checkpoint({
    required this.id,
    required this.name,
    this.description,
    required this.siteId,
    required this.location,
    this.qrCode,
    this.nfcTag,
    required this.isActive,
    required this.visitDuration,
  });

  factory Checkpoint.fromJson(Map<String, dynamic> json) => 
      _$CheckpointFromJson(json);
  Map<String, dynamic> toJson() => _$CheckpointToJson(this);

  Checkpoint copyWith({
    int? id,
    String? name,
    String? description,
    int? siteId,
    Location? location,
    String? qrCode,
    String? nfcTag,
    bool? isActive,
    int? visitDuration,
  }) {
    return Checkpoint(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      siteId: siteId ?? this.siteId,
      location: location ?? this.location,
      qrCode: qrCode ?? this.qrCode,
      nfcTag: nfcTag ?? this.nfcTag,
      isActive: isActive ?? this.isActive,
      visitDuration: visitDuration ?? this.visitDuration,
    );
  }
}

@JsonSerializable()
class CreateCheckpointRequest {
  final String name;
  final String? description;
  @JsonKey(name: 'site_id')
  final int siteId;
  final Location location;
  @JsonKey(name: 'qr_code')
  final String? qrCode;
  @JsonKey(name: 'nfc_tag')
  final String? nfcTag;
  @JsonKey(name: 'visit_duration')
  final int visitDuration;

  const CreateCheckpointRequest({
    required this.name,
    this.description,
    required this.siteId,
    required this.location,
    this.qrCode,
    this.nfcTag,
    required this.visitDuration,
  });

  factory CreateCheckpointRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateCheckpointRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCheckpointRequestToJson(this);
}

@JsonSerializable()
class UpdateCheckpointRequest {
  final String? name;
  final String? description;
  @JsonKey(name: 'site_id')
  final int? siteId;
  final Location? location;
  @JsonKey(name: 'qr_code')
  final String? qrCode;
  @JsonKey(name: 'nfc_tag')
  final String? nfcTag;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'visit_duration')
  final int? visitDuration;

  const UpdateCheckpointRequest({
    this.name,
    this.description,
    this.siteId,
    this.location,
    this.qrCode,
    this.nfcTag,
    this.isActive,
    this.visitDuration,
  });

  factory UpdateCheckpointRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateCheckpointRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCheckpointRequestToJson(this);
}
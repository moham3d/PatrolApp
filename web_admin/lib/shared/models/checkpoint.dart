import 'package:json_annotation/json_annotation.dart';

part 'checkpoint.g.dart';

@JsonSerializable()
class Checkpoint {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'site_id')
  final int siteId;
  @JsonKey(name: 'location_id')
  final int? locationId;
  @JsonKey(name: 'area_id')
  final int? areaId;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'qr_code')
  final String? qrCode;
  @JsonKey(name: 'nfc_tag_id')
  final String? nfcTagId;
  @JsonKey(name: 'order_sequence')
  final int orderSequence;
  @JsonKey(name: 'is_mandatory')
  final bool isMandatory;
  @JsonKey(name: 'time_limit_minutes')
  final int? timeLimitMinutes;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'checkpoint_type')
  final String checkpointType;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Checkpoint({
    required this.id,
    required this.name,
    this.description,
    required this.siteId,
    this.locationId,
    this.areaId,
    required this.latitude,
    required this.longitude,
    this.qrCode,
    this.nfcTagId,
    required this.orderSequence,
    required this.isMandatory,
    this.timeLimitMinutes,
    required this.isActive,
    required this.checkpointType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Checkpoint.fromJson(Map<String, dynamic> json) => 
      _$CheckpointFromJson(json);
  Map<String, dynamic> toJson() => _$CheckpointToJson(this);

  Checkpoint copyWith({
    int? id,
    String? name,
    String? description,
    int? siteId,
    int? locationId,
    int? areaId,
    double? latitude,
    double? longitude,
    String? qrCode,
    String? nfcTagId,
    int? orderSequence,
    bool? isMandatory,
    int? timeLimitMinutes,
    bool? isActive,
    String? checkpointType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Checkpoint(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      siteId: siteId ?? this.siteId,
      locationId: locationId ?? this.locationId,
      areaId: areaId ?? this.areaId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qrCode: qrCode ?? this.qrCode,
      nfcTagId: nfcTagId ?? this.nfcTagId,
      orderSequence: orderSequence ?? this.orderSequence,
      isMandatory: isMandatory ?? this.isMandatory,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      isActive: isActive ?? this.isActive,
      checkpointType: checkpointType ?? this.checkpointType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class CreateCheckpointRequest {
  final String name;
  final String? description;
  @JsonKey(name: 'site_id')
  final int siteId;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'qr_code')
  final String? qrCode;
  @JsonKey(name: 'nfc_tag_id')
  final String? nfcTagId;

  const CreateCheckpointRequest({
    required this.name,
    this.description,
    required this.siteId,
    required this.latitude,
    required this.longitude,
    this.qrCode,
    this.nfcTagId,
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
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'qr_code')
  final String? qrCode;
  @JsonKey(name: 'nfc_tag_id')
  final String? nfcTagId;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  const UpdateCheckpointRequest({
    this.name,
    this.description,
    this.siteId,
    this.latitude,
    this.longitude,
    this.qrCode,
    this.nfcTagId,
    this.isActive,
  });

  factory UpdateCheckpointRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateCheckpointRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCheckpointRequestToJson(this);
}
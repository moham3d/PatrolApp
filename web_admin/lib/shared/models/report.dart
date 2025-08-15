import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

@JsonSerializable()
class ReportTemplate {
  final int? id;
  final String name;
  final String description;
  @JsonKey(name: 'data_source')
  final String dataSource; // 'users', 'sites', 'patrols', 'checkpoints', 'incidents'
  final List<ReportColumn> columns;
  final ReportFilters filters;
  @JsonKey(name: 'export_format')
  final String exportFormat; // 'pdf', 'csv', 'excel'
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ReportTemplate({
    this.id,
    required this.name,
    required this.description,
    required this.dataSource,
    required this.columns,
    required this.filters,
    required this.exportFormat,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportTemplate.fromJson(Map<String, dynamic> json) =>
      _$ReportTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$ReportTemplateToJson(this);

  ReportTemplate copyWith({
    int? id,
    String? name,
    String? description,
    String? dataSource,
    List<ReportColumn>? columns,
    ReportFilters? filters,
    String? exportFormat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dataSource: dataSource ?? this.dataSource,
      columns: columns ?? this.columns,
      filters: filters ?? this.filters,
      exportFormat: exportFormat ?? this.exportFormat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class ReportColumn {
  final String field;
  final String label;
  final String type; // 'text', 'number', 'date', 'boolean'
  final bool visible;
  final int order;
  final String? format;

  const ReportColumn({
    required this.field,
    required this.label,
    required this.type,
    required this.visible,
    required this.order,
    this.format,
  });

  factory ReportColumn.fromJson(Map<String, dynamic> json) =>
      _$ReportColumnFromJson(json);
  Map<String, dynamic> toJson() => _$ReportColumnToJson(this);

  ReportColumn copyWith({
    String? field,
    String? label,
    String? type,
    bool? visible,
    int? order,
    String? format,
  }) {
    return ReportColumn(
      field: field ?? this.field,
      label: label ?? this.label,
      type: type ?? this.type,
      visible: visible ?? this.visible,
      order: order ?? this.order,
      format: format ?? this.format,
    );
  }
}

@JsonSerializable()
class ReportFilters {
  @JsonKey(name: 'date_range')
  final DateRange? dateRange;
  @JsonKey(name: 'site_ids')
  final List<int>? siteIds;
  @JsonKey(name: 'user_ids')
  final List<int>? userIds;
  final String? status;
  final String? priority;
  final Map<String, dynamic>? customFilters;

  const ReportFilters({
    this.dateRange,
    this.siteIds,
    this.userIds,
    this.status,
    this.priority,
    this.customFilters,
  });

  factory ReportFilters.fromJson(Map<String, dynamic> json) =>
      _$ReportFiltersFromJson(json);
  Map<String, dynamic> toJson() => _$ReportFiltersToJson(this);

  ReportFilters copyWith({
    DateRange? dateRange,
    List<int>? siteIds,
    List<int>? userIds,
    String? status,
    String? priority,
    Map<String, dynamic>? customFilters,
  }) {
    return ReportFilters(
      dateRange: dateRange ?? this.dateRange,
      siteIds: siteIds ?? this.siteIds,
      userIds: userIds ?? this.userIds,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      customFilters: customFilters ?? this.customFilters,
    );
  }
}

@JsonSerializable()
class DateRange {
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);
  Map<String, dynamic> toJson() => _$DateRangeToJson(this);
}

@JsonSerializable()
class ReportResult {
  final String id;
  final String status; // 'generating', 'completed', 'failed'
  @JsonKey(name: 'download_url')
  final String? downloadUrl;
  @JsonKey(name: 'file_name')
  final String? fileName;
  @JsonKey(name: 'generated_at')
  final DateTime? generatedAt;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @JsonKey(name: 'error_message')
  final String? errorMessage;

  const ReportResult({
    required this.id,
    required this.status,
    this.downloadUrl,
    this.fileName,
    this.generatedAt,
    this.expiresAt,
    this.errorMessage,
  });

  factory ReportResult.fromJson(Map<String, dynamic> json) =>
      _$ReportResultFromJson(json);
  Map<String, dynamic> toJson() => _$ReportResultToJson(this);
}

@JsonSerializable()
class ScheduledReport {
  final int? id;
  final String name;
  @JsonKey(name: 'template_id')
  final int templateId;
  final String frequency; // 'daily', 'weekly', 'monthly'
  @JsonKey(name: 'next_run')
  final DateTime nextRun;
  @JsonKey(name: 'email_recipients')
  final List<String> emailRecipients;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const ScheduledReport({
    this.id,
    required this.name,
    required this.templateId,
    required this.frequency,
    required this.nextRun,
    required this.emailRecipients,
    required this.isActive,
    this.createdAt,
  });

  factory ScheduledReport.fromJson(Map<String, dynamic> json) =>
      _$ScheduledReportFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduledReportToJson(this);
}

// Request models for API calls
@JsonSerializable()
class CreateReportTemplateRequest {
  final String name;
  final String description;
  @JsonKey(name: 'data_source')
  final String dataSource;
  final List<ReportColumn> columns;
  final ReportFilters filters;
  @JsonKey(name: 'export_format')
  final String exportFormat;

  const CreateReportTemplateRequest({
    required this.name,
    required this.description,
    required this.dataSource,
    required this.columns,
    required this.filters,
    required this.exportFormat,
  });

  factory CreateReportTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReportTemplateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReportTemplateRequestToJson(this);
}

@JsonSerializable()
class GenerateReportRequest {
  @JsonKey(name: 'template_id')
  final int? templateId;
  @JsonKey(name: 'data_source')
  final String dataSource;
  final List<ReportColumn> columns;
  final ReportFilters filters;
  @JsonKey(name: 'export_format')
  final String exportFormat;

  const GenerateReportRequest({
    this.templateId,
    required this.dataSource,
    required this.columns,
    required this.filters,
    required this.exportFormat,
  });

  factory GenerateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateReportRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GenerateReportRequestToJson(this);
}

@JsonSerializable()
class CreateScheduledReportRequest {
  final String name;
  @JsonKey(name: 'template_id')
  final int templateId;
  final String frequency;
  @JsonKey(name: 'email_recipients')
  final List<String> emailRecipients;

  const CreateScheduledReportRequest({
    required this.name,
    required this.templateId,
    required this.frequency,
    required this.emailRecipients,
  });

  factory CreateScheduledReportRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateScheduledReportRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateScheduledReportRequestToJson(this);
}
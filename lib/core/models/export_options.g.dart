// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportColumn _$ExportColumnFromJson(Map<String, dynamic> json) => ExportColumn(
      key: json['key'] as String,
      label: json['label'] as String,
      selected: json['selected'] as bool? ?? true,
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      format: json['format'] as String?,
    );

Map<String, dynamic> _$ExportColumnToJson(ExportColumn instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'selected': instance.selected,
      'width': instance.width,
      'format': instance.format,
    };

ExportFilter _$ExportFilterFromJson(Map<String, dynamic> json) => ExportFilter(
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      customers: (json['customers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      minAmount: (json['minAmount'] as num?)?.toDouble(),
      maxAmount: (json['maxAmount'] as num?)?.toDouble(),
      searchQuery: json['searchQuery'] as String?,
    );

Map<String, dynamic> _$ExportFilterToJson(ExportFilter instance) =>
    <String, dynamic>{
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'statuses': instance.statuses,
      'customers': instance.customers,
      'minAmount': instance.minAmount,
      'maxAmount': instance.maxAmount,
      'searchQuery': instance.searchQuery,
    };

ExportOptions _$ExportOptionsFromJson(Map<String, dynamic> json) =>
    ExportOptions(
      format: $enumDecode(_$ExportFormatEnumMap, json['format']),
      template: $enumDecode(_$ExportTemplateEnumMap, json['template']),
      columns: (json['columns'] as List<dynamic>)
          .map((e) => ExportColumn.fromJson(e as Map<String, dynamic>))
          .toList(),
      filter: ExportFilter.fromJson(json['filter'] as Map<String, dynamic>),
      includeHeaders: json['includeHeaders'] as bool? ?? true,
      includeTotals: json['includeTotals'] as bool? ?? true,
      includeCharts: json['includeCharts'] as bool? ?? false,
      customFileName: json['customFileName'] as String?,
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ExportOptionsToJson(ExportOptions instance) =>
    <String, dynamic>{
      'format': _$ExportFormatEnumMap[instance.format]!,
      'template': _$ExportTemplateEnumMap[instance.template]!,
      'columns': instance.columns,
      'filter': instance.filter,
      'includeHeaders': instance.includeHeaders,
      'includeTotals': instance.includeTotals,
      'includeCharts': instance.includeCharts,
      'customFileName': instance.customFileName,
      'customSettings': instance.customSettings,
    };

const _$ExportFormatEnumMap = {
  ExportFormat.pdf: 'pdf',
  ExportFormat.excel: 'excel',
  ExportFormat.csv: 'csv',
  ExportFormat.json: 'json',
};

const _$ExportTemplateEnumMap = {
  ExportTemplate.standard: 'standard',
  ExportTemplate.detailed: 'detailed',
  ExportTemplate.summary: 'summary',
  ExportTemplate.custom: 'custom',
};

ExportHistory _$ExportHistoryFromJson(Map<String, dynamic> json) => ExportHistory(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      format: $enumDecode(_$ExportFormatEnumMap, json['format']),
      template: $enumDecode(_$ExportTemplateEnumMap, json['template']),
      recordCount: json['recordCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      filePath: json['filePath'] as String?,
      fileSize: (json['fileSize'] as num?)?.toDouble() ?? 0.0,
      filter: ExportFilter.fromJson(json['filter'] as Map<String, dynamic>),
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$ExportHistoryToJson(ExportHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'format': _$ExportFormatEnumMap[instance.format]!,
      'template': _$ExportTemplateEnumMap[instance.template]!,
      'recordCount': instance.recordCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'filePath': instance.filePath,
      'fileSize': instance.fileSize,
      'filter': instance.filter,
      'createdBy': instance.createdBy,
    };

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'export_options.g.dart';

enum ExportFormat {
 pdf('PDF', 'pdf'),
 excel('Excel', 'xlsx'),
 csv('CSV', 'csv'),
 json('JSON', 'json');

 const ExportFormat(this.displayName, this.extension);
 final String displayName;
 final String extension;
}

enum ExportTemplate {
 standard('Standard'),
 detailed('Détaillé'),
 summary('Résumé'),
 custom('Personnalisé');

 const ExportTemplate(this.displayName);
 final String displayName;
}

@JsonSerializable()
class ExportColumn extends Equatable {
 final String key;
 final String label;
 final bool selected;
 final double width;
 final String? format;

 const ExportColumn({
 required this.key,
 required this.label,
 this.selected = true,
 this.width = 100.0,
 this.format,
 });

 factory ExportColumn.fromJson(Map<String, dynamic> json) =>
 _$ExportColumnFromJson(json);

 Map<String, dynamic> toJson() => _$ExportColumnToJson(this);

 ExportColumn copyWith({
 String? key,
 String? label,
 bool? selected,
 double? width,
 String? format,
 }) {
 return ExportColumn(
 key: key ?? this.key,
 label: label ?? this.label,
 selected: selected ?? this.selected,
 width: width ?? this.width,
 format: format ?? this.format,
 );
 }

 @override
 List<Object?> get props => [key, label, selected, width, format];
}

@JsonSerializable()
class ExportFilter extends Equatable {
 final DateTime? startDate;
 final DateTime? endDate;
 final List<String>? statuses;
 final List<String>? customers;
 final double? minAmount;
 final double? maxAmount;
 final String? searchQuery;

 const ExportFilter({
 this.startDate,
 this.endDate,
 this.statuses,
 this.customers,
 this.minAmount,
 this.maxAmount,
 this.searchQuery,
 });

 factory ExportFilter.fromJson(Map<String, dynamic> json) =>
 _$ExportFilterFromJson(json);

 Map<String, dynamic> toJson() => _$ExportFilterToJson(this);

 ExportFilter copyWith({
 DateTime? startDate,
 DateTime? endDate,
 List<String>? statuses,
 List<String>? customers,
 double? minAmount,
 double? maxAmount,
 String? searchQuery,
 }) {
 return ExportFilter(
 startDate: startDate ?? this.startDate,
 endDate: endDate ?? this.endDate,
 statuses: statuses ?? this.statuses,
 customers: customers ?? this.customers,
 minAmount: minAmount ?? this.minAmount,
 maxAmount: maxAmount ?? this.maxAmount,
 searchQuery: searchQuery ?? this.searchQuery,
 );
 }

 @override
 List<Object?> get props => [
 startDate,
 endDate,
 statuses,
 customers,
 minAmount,
 maxAmount,
 searchQuery,
 ];
}

@JsonSerializable()
class ExportOptions extends Equatable {
 final ExportFormat format;
 final ExportTemplate template;
 final List<ExportColumn> columns;
 final ExportFilter filter;
 final bool includeHeaders;
 final bool includeTotals;
 final bool includeCharts;
 final String? customFileName;
 final Map<String, dynamic>? customSettings;

 const ExportOptions({
 required this.format,
 required this.template,
 required this.columns,
 required this.filter,
 this.includeHeaders = true,
 this.includeTotals = true,
 this.includeCharts = false,
 this.customFileName,
 this.customSettings,
 });

 factory ExportOptions.fromJson(Map<String, dynamic> json) =>
 _$ExportOptionsFromJson(json);

 Map<String, dynamic> toJson() => _$ExportOptionsToJson(this);

 ExportOptions copyWith({
 ExportFormat? format,
 ExportTemplate? template,
 List<ExportColumn>? columns,
 ExportFilter? filter,
 bool? includeHeaders,
 bool? includeTotals,
 bool? includeCharts,
 String? customFileName,
 Map<String, dynamic>? customSettings,
 }) {
 return ExportOptions(
 format: format ?? this.format,
 template: template ?? this.template,
 columns: columns ?? this.columns,
 filter: filter ?? this.filter,
 includeHeaders: includeHeaders ?? this.includeHeaders,
 includeTotals: includeTotals ?? this.includeTotals,
 includeCharts: includeCharts ?? this.includeCharts,
 customFileName: customFileName ?? this.customFileName,
 customSettings: customSettings ?? this.customSettings,
 );
 }

 String get fileName {
 if (customFileName != null && customFileName!.isNotEmpty) {
 return '$customFileName.${format.extension}';
 }
 final timestamp = DateTime.now().millisecondsSinceEpoch;
 return 'export_orders_$timestamp.${format.extension}';
 }

 @override
 List<Object?> get props => [
 format,
 template,
 columns,
 filter,
 includeHeaders,
 includeTotals,
 includeCharts,
 customFileName,
 customSettings,
 ];
}

@JsonSerializable()
class ExportHistory extends Equatable {
 final String id;
 final String fileName;
 final ExportFormat format;
 final ExportTemplate template;
 final int recordCount;
 final DateTime createdAt;
 final DateTime? expiresAt;
 final String? filePath;
 final double fileSize;
 final ExportFilter filter;
 final String? createdBy;

 const ExportHistory({
 required this.id,
 required this.fileName,
 required this.format,
 required this.template,
 required this.recordCount,
 required this.createdAt,
 this.expiresAt,
 this.filePath,
 required this.fileSize,
 required this.filter,
 this.createdBy,
 });

 factory ExportHistory.fromJson(Map<String, dynamic> json) =>
 _$ExportHistoryFromJson(json);

 Map<String, dynamic> toJson() => _$ExportHistoryToJson(this);

 bool get isExpired {
 if (expiresAt == null) return false;
 return DateTime.now().isAfter(expiresAt!);
 }

 String get formattedFileSize {
 if (fileSize < 1024) return '${fileSize.toStringAsFixed(0)} B';
 if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
 return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
 }

 @override
 List<Object?> get props => [
 id,
 fileName,
 format,
 template,
 recordCount,
 createdAt,
 expiresAt,
 filePath,
 fileSize,
 filter,
 createdBy,
 ];
}

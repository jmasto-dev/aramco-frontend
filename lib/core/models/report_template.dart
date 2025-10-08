import 'package:json_annotation/json_annotation.dart';

part 'report_template.g.dart';

@JsonSerializable()
class ReportTemplate {
 final String id;
 final String name;
 final String description;
 final String category;
 final ReportType type;
 final List<ReportField> fields;
 final List<ReportFilter> filters;
 final List<ReportChart> charts;
 final Map<String, dynamic> configuration;
 final String? createdBy;
 final bool isPublic;
 final bool isActive;
 final DateTime createdAt;
 final DateTime updatedAt;

 const ReportTemplate({
 required this.id,
 required this.name,
 required this.description,
 required this.category,
 required this.type,
 required this.fields,
 required this.filters,
 required this.charts,
 required this.configuration,
 this.createdBy,
 required this.isPublic,
 required this.isActive,
 required this.createdAt,
 required this.updatedAt,
 });

 factory ReportTemplate.fromJson(Map<String, dynamic> json) =>
 _$ReportTemplateFromJson(json);

 Map<String, dynamic> toJson() => _$ReportTemplateToJson(this);

 String get typeText {
 switch (type) {
 case ReportType.tabular:
 return 'Tabulaire';
 case ReportType.summary:
 return 'Résumé';
 case ReportType.chart:
 return 'Graphique';
 case ReportType.dashboard:
 return 'Tableau de bord';
 case ReportType.crossTab:
 return 'Tableau croisé';
}
 }
}

enum ReportType {
 @JsonValue('tabular')
 tabular,
 @JsonValue('summary')
 summary,
 @JsonValue('chart')
 chart,
 @JsonValue('dashboard')
 dashboard,
 @JsonValue('cross_tab')
 crossTab,
}

@JsonSerializable()
class ReportField {
 final String id;
 final String name;
 final String field;
 final FieldType type;
 final String? aggregation;
 final String? format;
 final bool isVisible;
 final int? order;
 final Map<String, dynamic>? properties;

 const ReportField({
 required this.id,
 required this.name,
 required this.field,
 required this.type,
 this.aggregation,
 this.format,
 required this.isVisible,
 this.order,
 this.properties,
 });

 factory ReportField.fromJson(Map<String, dynamic> json) =>
 _$ReportFieldFromJson(json);

 Map<String, dynamic> toJson() => _$ReportFieldToJson(this);

 String get typeText {
 switch (type) {
 case FieldType.string:
 return 'Texte';
 case FieldType.number:
 return 'Nombre';
 case FieldType.date:
 return 'Date';
 case FieldType.datetime:
 return 'Date/Heure';
 case FieldType.boolean:
 return 'Booléen';
 case FieldType.currency:
 return 'Devise';
 case FieldType.percentage:
 return 'Pourcentage';
}
 }
}

enum FieldType {
 @JsonValue('string')
 string,
 @JsonValue('number')
 number,
 @JsonValue('date')
 date,
 @JsonValue('datetime')
 datetime,
 @JsonValue('boolean')
 boolean,
 @JsonValue('currency')
 currency,
 @JsonValue('percentage')
 percentage,
}

@JsonSerializable()
class ReportFilter {
 final String id;
 final String name;
 final String field;
 final FilterType type;
 final dynamic defaultValue;
 final List<String>? options;
 final bool isRequired;
 final bool isVisible;
 final int? order;

 const ReportFilter({
 required this.id,
 required this.name,
 required this.field,
 required this.type,
 this.defaultValue,
 this.options,
 required this.isRequired,
 required this.isVisible,
 this.order,
 });

 factory ReportFilter.fromJson(Map<String, dynamic> json) =>
 _$ReportFilterFromJson(json);

 Map<String, dynamic> toJson() => _$ReportFilterToJson(this);

 String get typeText {
 switch (type) {
 case FilterType.text:
 return 'Texte';
 case FilterType.number:
 return 'Nombre';
 case FilterType.date:
 return 'Date';
 case FilterType.select:
 return 'Sélection';
 case FilterType.multiSelect:
 return 'Sélection multiple';
 case FilterType.dateRange:
 return 'Plage de dates';
}
 }
}

enum FilterType {
 @JsonValue('text')
 text,
 @JsonValue('number')
 number,
 @JsonValue('date')
 date,
 @JsonValue('select')
 select,
 @JsonValue('multi_select')
 multiSelect,
 @JsonValue('date_range')
 dateRange,
}

@JsonSerializable()
class ReportChart {
 final String id;
 final String title;
 final ChartType type;
 final String xAxisField;
 final String? yAxisField;
 final List<String>? seriesFields;
 final Map<String, dynamic> configuration;
 final int? order;

 const ReportChart({
 required this.id,
 required this.title,
 required this.type,
 required this.xAxisField,
 this.yAxisField,
 this.seriesFields,
 required this.configuration,
 this.order,
 });

 factory ReportChart.fromJson(Map<String, dynamic> json) =>
 _$ReportChartFromJson(json);

 Map<String, dynamic> toJson() => _$ReportChartToJson(this);

 String get typeText {
 switch (type) {
 case ChartType.line:
 return 'Ligne';
 case ChartType.bar:
 return 'Barre';
 case ChartType.pie:
 return 'Camembert';
 case ChartType.area:
 return 'Aire';
 case ChartType.scatter:
 return 'Nuage de points';
 case ChartType.doughnut:
 return 'Beignet';
 case ChartType.radar:
 return 'Radar';
 case ChartType.polarArea:
 return 'Aire polaire';
}
 }
}

enum ChartType {
 @JsonValue('line')
 line,
 @JsonValue('bar')
 bar,
 @JsonValue('pie')
 pie,
 @JsonValue('area')
 area,
 @JsonValue('scatter')
 scatter,
 @JsonValue('doughnut')
 doughnut,
 @JsonValue('radar')
 radar,
 @JsonValue('polar_area')
 polarArea,
}

@JsonSerializable()
class ScheduledReport {
 final String id;
 final String name;
 final String templateId;
 final ReportTemplate? template;
 final ScheduleType scheduleType;
 final String? cronExpression;
 final Map<String, dynamic> parameters;
 final List<String> recipients;
 final ExportFormat exportFormat;
 final bool isActive;
 final DateTime? lastRunAt;
 final DateTime? nextRunAt;
 final String? createdBy;
 final DateTime createdAt;
 final DateTime updatedAt;

 const ScheduledReport({
 required this.id,
 required this.name,
 required this.templateId,
 this.template,
 required this.scheduleType,
 this.cronExpression,
 required this.parameters,
 required this.recipients,
 required this.exportFormat,
 required this.isActive,
 this.lastRunAt,
 this.nextRunAt,
 this.createdBy,
 required this.createdAt,
 required this.updatedAt,
 });

 factory ScheduledReport.fromJson(Map<String, dynamic> json) =>
 _$ScheduledReportFromJson(json);

 Map<String, dynamic> toJson() => _$ScheduledReportToJson(this);

 String get scheduleTypeText {
 switch (scheduleType) {
 case ScheduleType.daily:
 return 'Quotidien';
 case ScheduleType.weekly:
 return 'Hebdomadaire';
 case ScheduleType.monthly:
 return 'Mensuel';
 case ScheduleType.quarterly:
 return 'Trimestriel';
 case ScheduleType.yearly:
 return 'Annuel';
 case ScheduleType.custom:
 return 'Personnalisé';
}
 }

 String get exportFormatText {
 switch (exportFormat) {
 case ExportFormat.pdf:
 return 'PDF';
 case ExportFormat.excel:
 return 'Excel';
 case ExportFormat.csv:
 return 'CSV';
 case ExportFormat.json:
 return 'JSON';
}
 }
}

enum ScheduleType {
 @JsonValue('daily')
 daily,
 @JsonValue('weekly')
 weekly,
 @JsonValue('monthly')
 monthly,
 @JsonValue('quarterly')
 quarterly,
 @JsonValue('yearly')
 yearly,
 @JsonValue('custom')
 custom,
}

enum ExportFormat {
 @JsonValue('pdf')
 pdf,
 @JsonValue('excel')
 excel,
 @JsonValue('csv')
 csv,
 @JsonValue('json')
 json,
}

@JsonSerializable()
class ReportExecution {
 final String id;
 final String templateId;
 final String? scheduledReportId;
 final Map<String, dynamic> parameters;
 final ExecutionStatus status;
 final DateTime startedAt;
 final DateTime? completedAt;
 final String? executedBy;
 final String? filePath;
 final int? recordCount;
 final String? errorMessage;
 final Map<String, dynamic>? metadata;

 const ReportExecution({
 required this.id,
 required this.templateId,
 this.scheduledReportId,
 required this.parameters,
 required this.status,
 required this.startedAt,
 this.completedAt,
 this.executedBy,
 this.filePath,
 this.recordCount,
 this.errorMessage,
 this.metadata,
 });

 factory ReportExecution.fromJson(Map<String, dynamic> json) =>
 _$ReportExecutionFromJson(json);

 Map<String, dynamic> toJson() => _$ReportExecutionToJson(this);

 String get statusText {
 switch (status) {
 case ExecutionStatus.pending:
 return 'En attente';
 case ExecutionStatus.running:
 return 'En cours';
 case ExecutionStatus.completed:
 return 'Terminé';
 case ExecutionStatus.failed:
 return 'Échoué';
 case ExecutionStatus.cancelled:
 return 'Annulé';
}
 }

 Duration? get duration {
 if (completedAt == null) r{eturn null;
 return completedAt!.difference(startedAt);
 }
}

enum ExecutionStatus {
 @JsonValue('pending')
 pending,
 @JsonValue('running')
 running,
 @JsonValue('completed')
 completed,
 @JsonValue('failed')
 failed,
 @JsonValue('cancelled')
 cancelled,
}

@JsonSerializable()
class ReportDataSource {
 final String id;
 final String name;
 final String description;
 final DataSourceType type;
 final String connectionString;
 final Map<String, dynamic> configuration;
 final bool isActive;
 final DateTime createdAt;
 final DateTime updatedAt;

 const ReportDataSource({
 required this.id,
 required this.name,
 required this.description,
 required this.type,
 required this.connectionString,
 required this.configuration,
 required this.isActive,
 required this.createdAt,
 required this.updatedAt,
 });

 factory ReportDataSource.fromJson(Map<String, dynamic> json) =>
 _$ReportDataSourceFromJson(json);

 Map<String, dynamic> toJson() => _$ReportDataSourceToJson(this);

 String get typeText {
 switch (type) {
 case DataSourceType.database:
 return 'Base de données';
 case DataSourceType.api:
 return 'API';
 case DataSourceType.file:
 return 'Fichier';
 case DataSourceType.webService:
 return 'Service web';
}
 }
}

enum DataSourceType {
 @JsonValue('database')
 database,
 @JsonValue('api')
 api,
 @JsonValue('file')
 file,
 @JsonValue('web_service')
 webService,
}

@JsonSerializable()
class ReportSubscription {
 final String id;
 final String userId;
 final String reportId;
 final SubscriptionType type;
 final Map<String, dynamic> preferences;
 final bool isActive;
 final DateTime createdAt;
 final DateTime updatedAt;

 const ReportSubscription({
 required this.id,
 required this.userId,
 required this.reportId,
 required this.type,
 required this.preferences,
 required this.isActive,
 required this.createdAt,
 required this.updatedAt,
 });

 factory ReportSubscription.fromJson(Map<String, dynamic> json) =>
 _$ReportSubscriptionFromJson(json);

 Map<String, dynamic> toJson() => _$ReportSubscriptionToJson(this);

 String get typeText {
 switch (type) {
 case SubscriptionType.email:
 return 'Email';
 case SubscriptionType.dashboard:
 return 'Tableau de bord';
 case SubscriptionType.mobile:
 return 'Mobile';
 case SubscriptionType.webhook:
 return 'Webhook';
}
 }
}

enum SubscriptionType {
 @JsonValue('email')
 email,
 @JsonValue('dashboard')
 dashboard,
 @JsonValue('mobile')
 mobile,
 @JsonValue('webhook')
 webhook,
}

import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

@JsonSerializable()
class Report {
 final String id;
 final String name;
 final String description;
 final ReportType type;
 final ReportCategory category;
 final ReportStatus status;
 final String? createdBy;
 final String? createdByName;
 final DateTime createdAt;
 final DateTime? lastRunAt;
 final DateTime? nextRunAt;
 final ReportSchedule schedule;
 final ReportConfiguration configuration;
 final List<ReportParameter> parameters;
 final List<ReportDataSource> dataSources;
 final List<ReportChart> charts;
 final List<ReportFilter> filters;
 final Map<String, dynamic> metadata;
 final bool isPublic;
 final List<String> sharedWith;
 final int runCount;
 final Duration? averageRunTime;
 final String? lastError;
 final bool isActive;

 const Report({
 required this.id,
 required this.name,
 required this.description,
 required this.type,
 required this.category,
 required this.status,
 this.createdBy,
 this.createdByName,
 required this.createdAt,
 this.lastRunAt,
 this.nextRunAt,
 required this.schedule,
 required this.configuration,
 required this.parameters,
 required this.dataSources,
 required this.charts,
 required this.filters,
 required this.metadata,
 required this.isPublic,
 required this.sharedWith,
 required this.runCount,
 this.averageRunTime,
 this.lastError,
 required this.isActive,
 });

 factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
 Map<String, dynamic> toJson() => _$ReportToJson(this);

 Report copyWith({
 String? id,
 String? name,
 String? description,
 ReportType? type,
 ReportCategory? category,
 ReportStatus? status,
 String? createdBy,
 String? createdByName,
 DateTime? createdAt,
 DateTime? lastRunAt,
 DateTime? nextRunAt,
 ReportSchedule? schedule,
 ReportConfiguration? configuration,
 List<ReportParameter>? parameters,
 List<ReportDataSource>? dataSources,
 List<ReportChart>? charts,
 List<ReportFilter>? filters,
 Map<String, dynamic>? metadata,
 bool? isPublic,
 List<String>? sharedWith,
 int? runCount,
 Duration? averageRunTime,
 String? lastError,
 bool? isActive,
 }) {
 return Report(
 id: id ?? this.id,
 name: name ?? this.name,
 description: description ?? this.description,
 type: type ?? this.type,
 category: category ?? this.category,
 status: status ?? this.status,
 createdBy: createdBy ?? this.createdBy,
 createdByName: createdByName ?? this.createdByName,
 createdAt: createdAt ?? this.createdAt,
 lastRunAt: lastRunAt ?? this.lastRunAt,
 nextRunAt: nextRunAt ?? this.nextRunAt,
 schedule: schedule ?? this.schedule,
 configuration: configuration ?? this.configuration,
 parameters: parameters ?? this.parameters,
 dataSources: dataSources ?? this.dataSources,
 charts: charts ?? this.charts,
 filters: filters ?? this.filters,
 metadata: metadata ?? this.metadata,
 isPublic: isPublic ?? this.isPublic,
 sharedWith: sharedWith ?? this.sharedWith,
 runCount: runCount ?? this.runCount,
 averageRunTime: averageRunTime ?? this.averageRunTime,
 lastError: lastError ?? this.lastError,
 isActive: isActive ?? this.isActive,
 );
 }

 @override
 bool operator ==(Object other) =>
 identical(this, other) ||
 other is Report &&
 runtimeType == other.runtimeType &&
 id == other.id;

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'Report{id: $id, name: $name, type: $type, status: $status}';
 }

 // Getters utilitaires
 bool get isScheduled => schedule.type != ReportScheduleType.manual;
 bool get isRunning => status == ReportStatus.running;
 bool get hasError => lastError != null;
 bool get canRun => isActive && !isRunning;
 bool get canEdit => !isRunning;
 bool get canDelete => !isRunning;
 bool get canShare => !isPublic;
}

@JsonSerializable()
class ReportSchedule {
 final ReportScheduleType type;
 final String? cronExpression;
 final DateTime? startDate;
 final DateTime? endDate;
 final List<int> daysOfWeek; // 0-6 (Dimanche-Samedi)
 final int? dayOfMonth; // 1-31
 final TimeOfDay? timeOfDay;
 final String? timeZone;
 final bool isActive;

 const ReportSchedule({
 required this.type,
 this.cronExpression,
 this.startDate,
 this.endDate,
 required this.daysOfWeek,
 this.dayOfMonth,
 this.timeOfDay,
 this.timeZone,
 required this.isActive,
 });

 factory ReportSchedule.fromJson(Map<String, dynamic> json) =>
 _$ReportScheduleFromJson(json);
 Map<String, dynamic> toJson() => _$ReportScheduleToJson(this);
}

@JsonSerializable()
class ReportConfiguration {
 final String title;
 final String? subtitle;
 final ReportLayout layout;
 final ReportTheme theme;
 final List<String> columns;
 final Map<String, ReportColumnConfig> columnConfigs;
 final ReportExportOptions exportOptions;
 final ReportPagination? pagination;
 final ReportSorting? sorting;
 final ReportGrouping? grouping;
 final Map<String, dynamic> customSettings;

 const ReportConfiguration({
 required this.title,
 this.subtitle,
 required this.layout,
 required this.theme,
 required this.columns,
 required this.columnConfigs,
 required this.exportOptions,
 this.pagination,
 this.sorting,
 this.grouping,
 required this.customSettings,
 });

 factory ReportConfiguration.fromJson(Map<String, dynamic> json) =>
 _$ReportConfigurationFromJson(json);
 Map<String, dynamic> toJson() => _$ReportConfigurationToJson(this);
}

@JsonSerializable()
class ReportParameter {
 final String id;
 final String name;
 final String label;
 final ReportParameterType type;
 final dynamic defaultValue;
 final bool isRequired;
 final List<String>? options;
 final Map<String, dynamic>? validation;
 final String? description;
 final int order;

 const ReportParameter({
 required this.id,
 required this.name,
 required this.label,
 required this.type,
 this.defaultValue,
 required this.isRequired,
 this.options,
 this.validation,
 this.description,
 required this.order,
 });

 factory ReportParameter.fromJson(Map<String, dynamic> json) =>
 _$ReportParameterFromJson(json);
 Map<String, dynamic> toJson() => _$ReportParameterToJson(json);
}

@JsonSerializable()
class ReportDataSource {
 final String id;
 final String name;
 final ReportDataSourceType type;
 final String connectionId;
 final String query;
 final Map<String, dynamic> parameters;
 final List<String> columns;
 final Map<String, String> columnMappings;
 final bool isActive;

 const ReportDataSource({
 required this.id,
 required this.name,
 required this.type,
 required this.connectionId,
 required this.query,
 required this.parameters,
 required this.columns,
 required this.columnMappings,
 required this.isActive,
 });

 factory ReportDataSource.fromJson(Map<String, dynamic> json) =>
 _$ReportDataSourceFromJson(json);
 Map<String, dynamic> toJson() => _$ReportDataSourceToJson(json);
}

@JsonSerializable()
class ReportChart {
 final String id;
 final String title;
 final ChartType type;
 final ChartPosition position;
 final List<String> dataColumns;
 final String? xAxisColumn;
 final String? yAxisColumn;
 final ChartConfiguration configuration;
 final Map<String, dynamic> customSettings;

 const ReportChart({
 required this.id,
 required this.title,
 required this.type,
 required this.position,
 required this.dataColumns,
 this.xAxisColumn,
 this.yAxisColumn,
 required this.configuration,
 required this.customSettings,
 });

 factory ReportChart.fromJson(Map<String, dynamic> json) =>
 _$ReportChartFromJson(json);
 Map<String, dynamic> toJson() => _$ReportChartToJson(json);
}

@JsonSerializable()
class ReportFilter {
 final String id;
 final String name;
 final String column;
 final ReportFilterOperator operator;
 final dynamic value;
 final dynamic value2; // Pour les opérateurs comme BETWEEN
 final bool isActive;

 const ReportFilter({
 required this.id,
 required this.name,
 required this.column,
 required this.operator,
 this.value,
 this.value2,
 required this.isActive,
 });

 factory ReportFilter.fromJson(Map<String, dynamic> json) =>
 _$ReportFilterFromJson(json);
 Map<String, dynamic> toJson() => _$ReportFilterToJson(json);
}

@JsonSerializable()
class ReportColumnConfig {
 final String label;
 final ReportColumnType type;
 final bool isVisible;
 final bool isSortable;
 final bool isFilterable;
 final String? format;
 final Map<String, dynamic>? customSettings;

 const ReportColumnConfig({
 required this.label,
 required this.type,
 required this.isVisible,
 required this.isSortable,
 required this.isFilterable,
 this.format,
 this.customSettings,
 });

 factory ReportColumnConfig.fromJson(Map<String, dynamic> json) =>
 _$ReportColumnConfigFromJson(json);
 Map<String, dynamic> toJson() => _$ReportColumnConfigToJson(json);
}

@JsonSerializable()
class ReportExportOptions {
 final List<ReportExportFormat> availableFormats;
 final ReportExportFormat defaultFormat;
 final bool includeHeaders;
 final bool includeCharts;
 final Map<String, dynamic> formatSettings;

 const ReportExportOptions({
 required this.availableFormats,
 required this.defaultFormat,
 required this.includeHeaders,
 required this.includeCharts,
 required this.formatSettings,
 });

 factory ReportExportOptions.fromJson(Map<String, dynamic> json) =>
 _$ReportExportOptionsFromJson(json);
 Map<String, dynamic> toJson() => _$ReportExportOptionsToJson(json);
}

@JsonSerializable()
class ReportPagination {
 final int pageSize;
 final int currentPage;
 final int totalItems;
 final bool enabled;

 const ReportPagination({
 required this.pageSize,
 required this.currentPage,
 required this.totalItems,
 required this.enabled,
 });

 factory ReportPagination.fromJson(Map<String, dynamic> json) =>
 _$ReportPaginationFromJson(json);
 Map<String, dynamic> toJson() => _$ReportPaginationToJson(json);
}

@JsonSerializable()
class ReportSorting {
 final String column;
 final bool ascending;

 const ReportSorting({
 required this.column,
 required this.ascending,
 });

 factory ReportSorting.fromJson(Map<String, dynamic> json) =>
 _$ReportSortingFromJson(json);
 Map<String, dynamic> toJson() => _$ReportSortingToJson(json);
}

@JsonSerializable()
class ReportGrouping {
 final String column;
 final List<String> aggregations;

 const ReportGrouping({
 required this.column,
 required this.aggregations,
 });

 factory ReportGrouping.fromJson(Map<String, dynamic> json) =>
 _$ReportGroupingFromJson(json);
 Map<String, dynamic> toJson() => _$ReportGroupingToJson(json);
}

@JsonSerializable()
class ChartConfiguration {
 final ChartColorScheme colorScheme;
 final ChartLegend legend;
 final ChartAxis xAxis;
 final ChartAxis yAxis;
 final ChartGrid grid;
 final ChartAnimation animation;

 const ChartConfiguration({
 required this.colorScheme,
 required this.legend,
 required this.xAxis,
 required this.yAxis,
 required this.grid,
 required this.animation,
 });

 factory ChartConfiguration.fromJson(Map<String, dynamic> json) =>
 _$ChartConfigurationFromJson(json);
 Map<String, dynamic> toJson() => _$ChartConfigurationToJson(json);
}

@JsonSerializable()
class ChartLegend {
 final bool isVisible;
 final ChartPosition position;
 final ChartLegendStyle style;

 const ChartLegend({
 required this.isVisible,
 required this.position,
 required this.style,
 });

 factory ChartLegend.fromJson(Map<String, dynamic> json) =>
 _$ChartLegendFromJson(json);
 Map<String, dynamic> toJson() => _$ChartLegendToJson(json);
}

@JsonSerializable()
class ChartAxis {
 final bool isVisible;
 final String title;
 final ChartAxisType type;
 final ChartAxisScale scale;

 const ChartAxis({
 required this.isVisible,
 required this.title,
 required this.type,
 required this.scale,
 });

 factory ChartAxis.fromJson(Map<String, dynamic> json) =>
 _$ChartAxisFromJson(json);
 Map<String, dynamic> toJson() => _$ChartAxisToJson(json);
}

@JsonSerializable()
class ChartGrid {
 final bool isVisible;
 final ChartGridStyle style;
 final Color color;

 const ChartGrid({
 required this.isVisible,
 required this.style,
 required this.color,
 });

 factory ChartGrid.fromJson(Map<String, dynamic> json) =>
 _$ChartGridFromJson(json);
 Map<String, dynamic> toJson() => _$ChartGridToJson(json);
}

@JsonSerializable()
class ChartAnimation {
 final bool isEnabled;
 final Duration duration;
 final ChartAnimationType type;

 const ChartAnimation({
 required this.isEnabled,
 required this.duration,
 required this.type,
 });

 factory ChartAnimation.fromJson(Map<String, dynamic> json) =>
 _$ChartAnimationFromJson(json);
 Map<String, dynamic> toJson() => _$ChartAnimationToJson(json);
}

// Enums
enum ReportType {
 @JsonValue('TABULAR')
 tabular,
 @JsonValue('SUMMARY')
 summary,
 @JsonValue('CHART')
 chart,
 @JsonValue('DASHBOARD')
 dashboard,
 @JsonValue('CROSSTAB')
 crosstab,
}

enum ReportCategory {
 @JsonValue('FINANCIAL')
 financial,
 @JsonValue('OPERATIONAL')
 operational,
 @JsonValue('HR')
 hr,
 @JsonValue('SALES')
 sales,
 @JsonValue('PURCHASING')
 purchasing,
 @JsonValue('INVENTORY')
 inventory,
 @JsonValue('CUSTOM')
 custom,
}

enum ReportStatus {
 @JsonValue('DRAFT')
 draft,
 @JsonValue('READY')
 ready,
 @JsonValue('RUNNING')
 running,
 @JsonValue('COMPLETED')
 completed,
 @JsonValue('FAILED')
 failed,
 @JsonValue('CANCELLED')
 cancelled,
}

enum ReportScheduleType {
 @JsonValue('MANUAL')
 manual,
 @JsonValue('DAILY')
 daily,
 @JsonValue('WEEKLY')
 weekly,
 @JsonValue('MONTHLY')
 monthly,
 @JsonValue('QUARTERLY')
 quarterly,
 @JsonValue('YEARLY')
 yearly,
 @JsonValue('CUSTOM')
 custom,
}

enum ReportLayout {
 @JsonValue('PORTRAIT')
 portrait,
 @JsonValue('LANDSCAPE')
 landscape,
 @JsonValue('SQUARE')
 square,
}

enum ReportTheme {
 @JsonValue('DEFAULT')
 default,
 @JsonValue('DARK')
 dark,
 @JsonValue('LIGHT')
 light,
 @JsonValue('COLORFUL')
 colorful,
 @JsonValue('MINIMAL')
 minimal,
}

enum ReportParameterType {
 @JsonValue('TEXT')
 text,
 @JsonValue('NUMBER')
 number,
 @JsonValue('DATE')
 date,
 @JsonValue('DATETIME')
 datetime,
 @JsonValue('BOOLEAN')
 boolean,
 @JsonValue('SELECT')
 select,
 @JsonValue('MULTI_SELECT')
 multiSelect,
}

enum ReportDataSourceType {
 @JsonValue('DATABASE')
 database,
 @JsonValue('API')
 api,
 @JsonValue('FILE')
 file,
 @JsonValue('CSV')
 csv,
 @JsonValue('EXCEL')
 excel,
}

enum ChartType {
 @JsonValue('LINE')
 line,
 @JsonValue('BAR')
 bar,
 @JsonValue('PIE')
 pie,
 @JsonValue('AREA')
 area,
 @JsonValue('SCATTER')
 scatter,
 @JsonValue('DONUT')
 donut,
 @JsonValue('GAUGE')
 gauge,
 @JsonValue('HEATMAP')
 heatmap,
}

enum ChartPosition {
 @JsonValue('TOP')
 top,
 @JsonValue('BOTTOM')
 bottom,
 @JsonValue('LEFT')
 left,
 @JsonValue('RIGHT')
 right,
 @JsonValue('CENTER')
 center,
}

enum ReportFilterOperator {
 @JsonValue('EQUALS')
 equals,
 @JsonValue('NOT_EQUALS')
 notEquals,
 @JsonValue('GREATER_THAN')
 greaterThan,
 @JsonValue('LESS_THAN')
 lessThan,
 @JsonValue('GREATER_EQUAL')
 greaterEqual,
 @JsonValue('LESS_EQUAL')
 lessEqual,
 @JsonValue('CONTAINS')
 contains,
 @JsonValue('STARTS_WITH')
 startsWith,
 @JsonValue('ENDS_WITH')
 endsWith,
 @JsonValue('IN')
 in,
 @JsonValue('NOT_IN')
 notIn,
 @JsonValue('BETWEEN')
 between,
 @JsonValue('IS_NULL')
 isNull,
 @JsonValue('IS_NOT_NULL')
 isNotNull,
}

enum ReportColumnType {
 @JsonValue('TEXT')
 text,
 @JsonValue('NUMBER')
 number,
 @JsonValue('DATE')
 date,
 @JsonValue('DATETIME')
 datetime,
 @JsonValue('BOOLEAN')
 boolean,
 @JsonValue('CURRENCY')
 currency,
 @JsonValue('PERCENTAGE')
 percentage,
}

enum ReportExportFormat {
 @JsonValue('PDF')
 pdf,
 @JsonValue('EXCEL')
 excel,
 @JsonValue('CSV')
 csv,
 @JsonValue('JSON')
 json,
 @JsonValue('XML')
 xml,
 @JsonValue('HTML')
 html,
}

enum ChartColorScheme {
 @JsonValue('DEFAULT')
 default,
 @JsonValue('RAINBOW')
 rainbow,
 @JsonValue('PASTEL')
 pastel,
 @JsonValue('MONOCHROME')
 monochrome,
 @JsonValue('CUSTOM')
 custom,
}

enum ChartLegendStyle {
 @JsonValue('DEFAULT')
 default,
 @JsonValue('COMPACT')
 compact,
 @JsonValue('DETAILED')
 detailed,
}

enum ChartAxisType {
 @JsonValue('CATEGORY')
 category,
 @JsonValue('VALUE')
 value,
 @JsonValue('TIME')
 time,
 @JsonValue('LOGARITHMIC')
 logarithmic,
}

enum ChartAxisScale {
 @JsonValue('LINEAR')
 linear,
 @JsonValue('LOGARITHMIC')
 logarithmic,
 @JsonValue('TIME')
 time,
}

enum ChartGridStyle {
 @JsonValue('SOLID')
 solid,
 @JsonValue('DASHED')
 dashed,
 @JsonValue('DOTTED')
 dotted,
}

enum ChartAnimationType {
 @JsonValue('FADE_IN')
 fadeIn,
 @JsonValue('SLIDE_IN')
 slideIn,
 @JsonValue('GROW')
 grow,
 @JsonValue('BOUNCE')
 bounce,
}

// Classes utilitaires
class TimeOfDay {
 final int hour;
 final int minute;

 const TimeOfDay({required this.hour, required this.minute});

 factory TimeOfDay.fromJson(Map<String, dynamic> json) {
 return TimeOfDay(
 hour: json['hour'] as int,
 minute: json['minute'] as int,
 );
 }

 Map<String, dynamic> toJson() {
 return {
 'hour': hour,
 'minute': minute,
};
 }
}

class Color {
 final int value;

 const Color(this.value);

 factory const Color.fromJson(Map<String, dynamic> json) {
 return Color(json['value'] as int);
 }

 Map<String, dynamic> toJson() {
 return {'value': value};
 }
}

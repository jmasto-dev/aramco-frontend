import 'package:json_annotation/json_annotation.dart';

/// Modèles pour les widgets du tableau de bord

enum WidgetType {
  kpi,
  chart,
  alert,
  table,
  calendar,
  news,
}

enum ChartType {
  line,
  bar,
  pie,
  gauge,
  area,
}

@JsonSerializable()
class DashboardWidget {
  final String id;
  final String title;
  final WidgetType type;
  final ChartType? chartType;
  final int row;
  final int column;
  final int rowSpan;
  final int columnSpan;
  final Map<String, dynamic> config;
  final bool isVisible;
  final String? dataSource;
  final DateTime lastUpdated;
  final List<String> permissions;

  const DashboardWidget({
    required this.id,
    required this.title,
    required this.type,
    this.chartType,
    required this.row,
    required this.column,
    this.rowSpan = 1,
    this.columnSpan = 1,
    this.config = const {},
    this.isVisible = true,
    this.dataSource,
    required this.lastUpdated,
    this.permissions = const [],
  });

  factory DashboardWidget.fromJson(Map<String, dynamic> json) {
    return DashboardWidget(
      id: json['id'] as String,
      title: json['title'] as String,
      type: WidgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WidgetType.kpi,
      ),
      chartType: json['chartType'] != null
          ? ChartType.values.firstWhere(
              (e) => e.name == json['chartType'],
              orElse: () => ChartType.line,
            )
          : null,
      row: json['row'] as int? ?? 0,
      column: json['column'] as int? ?? 0,
      rowSpan: json['rowSpan'] as int? ?? 1,
      columnSpan: json['columnSpan'] as int? ?? 1,
      config: Map<String, dynamic>.from(json['config'] ?? {}),
      isVisible: json['isVisible'] as bool? ?? true,
      dataSource: json['dataSource'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'chartType': chartType?.name,
      'row': row,
      'column': column,
      'rowSpan': rowSpan,
      'columnSpan': columnSpan,
      'config': config,
      'isVisible': isVisible,
      'dataSource': dataSource,
      'lastUpdated': lastUpdated.toIso8601String(),
      'permissions': permissions,
    };
  }

  DashboardWidget copyWith({
    String? id,
    String? title,
    WidgetType? type,
    ChartType? chartType,
    int? row,
    int? column,
    int? rowSpan,
    int? columnSpan,
    Map<String, dynamic>? config,
    bool? isVisible,
    String? dataSource,
    DateTime? lastUpdated,
    List<String>? permissions,
  }) {
    return DashboardWidget(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      chartType: chartType ?? this.chartType,
      row: row ?? this.row,
      column: column ?? this.column,
      rowSpan: rowSpan ?? this.rowSpan,
      columnSpan: columnSpan ?? this.columnSpan,
      config: config ?? this.config,
      isVisible: isVisible ?? this.isVisible,
      dataSource: dataSource ?? this.dataSource,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardWidget &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DashboardWidget{id: $id, title: $title, type: $type}';
  }
}

@JsonSerializable()
class KpiData {
  final String label;
  final double value;
  final double? target;
  final String? unit;
  final String? trend;
  final double? trendValue;
  final String? color;
  final Map<String, dynamic> metadata;

  const KpiData({
    required this.label,
    required this.value,
    this.target,
    this.unit,
    this.trend,
    this.trendValue,
    this.color,
    this.metadata = const {},
  });

  factory KpiData.fromJson(Map<String, dynamic> json) {
    return KpiData(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      target: json['target'] != null ? (json['target'] as num).toDouble() : null,
      unit: json['unit'] as String?,
      trend: json['trend'] as String?,
      trendValue: json['trendValue'] != null ? (json['trendValue'] as num).toDouble() : null,
      color: json['color'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'target': target,
      'unit': unit,
      'trend': trend,
      'trendValue': trendValue,
      'color': color,
      'metadata': metadata,
    };
  }

  double get progress {
    if (target == null || target == 0) return 0.0;
    return (value / target!).clamp(0.0, 1.0);
  }

  bool get isPositive => trend == 'up';
  bool get isNegative => trend == 'down';
  bool get isNeutral => trend == 'stable';
}

@JsonSerializable()
class ChartData {
  final List<String> labels;
  final List<List<double>> datasets;
  final List<String> datasetLabels;
  final List<String> colors;
  final Map<String, dynamic> options;

  const ChartData({
    required this.labels,
    required this.datasets,
    required this.datasetLabels,
    required this.colors,
    this.options = const {},
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      labels: List<String>.from(json['labels'] ?? []),
      datasets: (json['datasets'] as List<dynamic>?)
              ?.map((dataset) => List<double>.from(dataset))
              .toList() ??
          [],
      datasetLabels: List<String>.from(json['datasetLabels'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      options: Map<String, dynamic>.from(json['options'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labels': labels,
      'datasets': datasets,
      'datasetLabels': datasetLabels,
      'colors': colors,
      'options': options,
    };
  }
}

@JsonSerializable()
class AlertData {
  final String id;
  final String title;
  final String message;
  final AlertLevel level;
  final String category;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic> metadata;

  const AlertData({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.category,
    required this.createdAt,
    this.expiresAt,
    this.isRead = false,
    this.actionUrl,
    this.metadata = const {},
  });

  factory AlertData.fromJson(Map<String, dynamic> json) {
    return AlertData(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      level: AlertLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => AlertLevel.info,
      ),
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'level': level.name,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
      'metadata': metadata,
    };
  }

  AlertData copyWith({
    String? id,
    String? title,
    String? message,
    AlertLevel? level,
    String? category,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return AlertData(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      level: level ?? this.level,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isActive => !isRead && !isExpired;
}

enum AlertLevel {
  info,
  warning,
  error,
  critical,
}

extension AlertLevelExtension on AlertLevel {
  String get displayName {
    switch (this) {
      case AlertLevel.info:
        return 'Information';
      case AlertLevel.warning:
        return 'Avertissement';
      case AlertLevel.error:
        return 'Erreur';
      case AlertLevel.critical:
        return 'Critique';
    }
  }

  String get color {
    switch (this) {
      case AlertLevel.info:
        return '#2196F3';
      case AlertLevel.warning:
        return '#FF9800';
      case AlertLevel.error:
        return '#F44336';
      case AlertLevel.critical:
        return '#9C27B0';
    }
  }
}

/// Utilitaires pour les widgets de tableau de bord
class DashboardWidgetUtils {
  /// Créer un widget KPI par défaut
  static DashboardWidget createKpiWidget({
    required String id,
    required String title,
    required String dataSource,
  }) {
    return DashboardWidget(
      id: id,
      title: title,
      type: WidgetType.kpi,
      row: 0,
      column: 0,
      dataSource: dataSource,
      lastUpdated: DateTime.now(),
    );
  }

  /// Créer un widget de graphique par défaut
  static DashboardWidget createChartWidget({
    required String id,
    required String title,
    required ChartType chartType,
    required String dataSource,
  }) {
    return DashboardWidget(
      id: id,
      title: title,
      type: WidgetType.chart,
      chartType: chartType,
      row: 0,
      column: 0,
      dataSource: dataSource,
      lastUpdated: DateTime.now(),
    );
  }

  /// Créer un widget d'alerte par défaut
  static DashboardWidget createAlertWidget({
    required String id,
    required String title,
  }) {
    return DashboardWidget(
      id: id,
      title: title,
      type: WidgetType.alert,
      row: 0,
      column: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculer la position d'un widget dans une grille
  static (int row, int column) calculatePosition(int index, int columns) {
    return (index ~/ columns, index % columns);
  }

  /// Vérifier si un widget est visible pour un utilisateur
  static bool isWidgetVisible(DashboardWidget widget, List<String> userPermissions) {
    if (widget.permissions.isEmpty) return true;
    return widget.permissions.any((permission) => userPermissions.contains(permission));
  }
}

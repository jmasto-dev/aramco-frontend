import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/dashboard_widget.dart';
import '../models/user.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService;
  static const String _baseUrl = '/dashboard';

  DashboardService(this._apiService);

  /// Récupère la configuration du tableau de bord pour un utilisateur
  Future<ApiResponse<List<DashboardWidget>>> getDashboardConfig(String userId) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/config/$userId');
      
      if (response.isSuccess && response.data != null) {
        final List<dynamic> widgetsJson = response.data['widgets'];
        final widgets = widgetsJson
            .map((json) => DashboardWidget.fromJson(json))
            .toList();
        
        return ApiResponse.success(data: widgets, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Sauvegarde la configuration du tableau de bord
  Future<ApiResponse<bool>> saveDashboardConfig(String userId, List<DashboardWidget> widgets) async {
    try {
      final widgetsJson = widgets.map((widget) => widget.toJson()).toList();
      
      final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/config/$userId', {
        'widgets': widgetsJson,
      });
      
      if (response.isSuccess) {
        return ApiResponse.success(data: true, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Récupère les données KPI pour un widget spécifique
  Future<ApiResponse<KpiData>> getKpiData(String widgetId, Map<String, dynamic> config) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/kpi/$widgetId', {
        'config': config,
      });
      
      if (response.isSuccess && response.data != null) {
        final kpiData = KpiData.fromJson(response.data);
        return ApiResponse.success(data: kpiData, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Récupère les données de graphique pour un widget spécifique
  Future<ApiResponse<ChartData>> getChartData(String widgetId, Map<String, dynamic> config) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/chart/$widgetId', {
        'config': config,
      });
      
      if (response.isSuccess && response.data != null) {
        final chartData = ChartData.fromJson(response.data);
        return ApiResponse.success(data: chartData, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Récupère les alertes actives pour l'utilisateur
  Future<ApiResponse<List<AlertData>>> getActiveAlerts(String userId) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/alerts/$userId');
      
      if (response.isSuccess && response.data != null) {
        final List<dynamic> alertsJson = response.data;
        final alerts = alertsJson
            .map((json) => AlertData.fromJson(json))
            .toList();
        
        return ApiResponse.success(data: alerts, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Marque une alerte comme lue
  Future<ApiResponse<bool>> markAlertAsRead(String alertId) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.put('$_baseUrl/alerts/$alertId/read', {});
      
      if (response.isSuccess) {
        return ApiResponse.success(data: true, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Récupère les widgets prédéfinis par rôle
  Future<ApiResponse<List<DashboardWidget>>> getPresetWidgets(String role) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/presets/$role');
      
      if (response.isSuccess && response.data != null) {
        final List<dynamic> widgetsJson = response.data;
        final widgets = widgetsJson
            .map((json) => DashboardWidget.fromJson(json))
            .toList();
        
        return ApiResponse.success(data: widgets, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Récupère les statistiques générales pour le tableau de bord
  Future<ApiResponse<Map<String, dynamic>>> getDashboardStats(String userId) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/stats/$userId');
      
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(data: response.data, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Exporte les données du tableau de bord
  Future<ApiResponse<String>> exportDashboardData(String userId, Map<String, dynamic> options) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/export/$userId', {
        'options': options,
      });
      
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(data: response.data['downloadUrl'], message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Rafraîchit les données d'un widget spécifique
  Future<ApiResponse<Map<String, dynamic>>> refreshWidgetData(String widgetId) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/refresh/$widgetId', {});
      
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(data: response.data, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Récupère l'historique des activités pour le tableau de bord
  Future<ApiResponse<List<Map<String, dynamic>>>> getActivityHistory(String userId, {int limit = 10}) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/activity/$userId?limit=$limit');
      
      if (response.isSuccess && response.data != null) {
        final List<dynamic> activitiesJson = response.data;
        final activities = activitiesJson
            .map((json) => json as Map<String, dynamic>)
            .toList();
        
        return ApiResponse.success(data: activities, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Crée un widget personnalisé
  Future<ApiResponse<DashboardWidget>> createCustomWidget(DashboardWidget widget) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/widgets', widget.toJson());
      
      if (response.isSuccess && response.data != null) {
        final createdWidget = DashboardWidget.fromJson(response.data);
        return ApiResponse.success(data: createdWidget, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Supprime un widget personnalisé
  Future<ApiResponse<bool>> deleteWidget(String widgetId) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.delete('$_baseUrl/widgets/$widgetId');
      
      if (response.isSuccess) {
        return ApiResponse.success(data: true, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }

  /// Récupère les données pour le mode plein écran
  Future<ApiResponse<Map<String, dynamic>>> getFullscreenData(String widgetId) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/fullscreen/$widgetId');
      
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(data: response.data, message: response.message ?? '');
      } else {
        return ApiResponse.error(message: response.errorMessage);
      }
    } catch (e) {
      return ApiResponse.error(message: 'Erreur réseau: $e');
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/dashboard_widget.dart';
import '../../core/models/api_response.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_service.dart';

// Provider Riverpod pour le DashboardProvider
final dashboardProvider = ChangeNotifierProvider<DashboardProvider>((ref) {
 // TODO: Injecter les dépendances réelles via des providers séparés
 final apiService = ApiService();
 final dashboardService = DashboardService(apiService);
 final storageService = StorageService();
 return DashboardProvider(dashboardService, storageService);
});

class DashboardProvider extends ChangeNotifier {
 final DashboardService _dashboardService;
 final StorageService _storageService;

 DashboardProvider(this._dashboardService, this._storageService);

 // État principal
 List<DashboardWidget> _widgets = [];
 List<AlertData> _alerts = [];
 Map<String, dynamic> _stats = {};
 bool _isLoading = false;
 String? _error;
 bool _isFullscreen = false;
 String? _selectedWidgetId;

 // Données des widgets
 final Map<String, KpiData> _kpiData = {};
 final Map<String, ChartData> _chartData = {};
 final Map<String, dynamic> _widgetData = {};

 // Getters
 List<DashboardWidget> get widgets => _widgets;
 List<AlertData> get alerts => _alerts;
 Map<String, dynamic> get stats => _stats;
 bool get isLoading => _isLoading;
 String? get error => _error;
 bool get isFullscreen => _isFullscreen;
 String? get selectedWidgetId => _selectedWidgetId;

 // Getters pour les données des widgets
 KpiData? getKpiData(String widgetId) => _kpiData[widgetId];
 ChartData? getChartData(String widgetId) => _chartData[widgetId];
 dynamic getWidgetData(String widgetId) => _widgetData[widgetId];

 // Getters calculés
 List<AlertData> get activeAlerts => _alerts.where((alert) => alert.isActive).toList();
 int get unreadAlertsCount => _alerts.where((alert) => !alert.isRead && !alert.isExpired).length;
 List<DashboardWidget> get visibleWidgets => _widgets.where((widget) => widget.isVisible).toList();

 /// Initialise le tableau de bord
 Future<void> initializeDashboard(String userId) {async {
 await _loadDashboardConfig(userId);
 await _loadActiveAlerts(userId);
 await _loadDashboardStats(userId);
 }

 /// Charge la configuration du tableau de bord
 Future<void> _loadDashboardConfig(String userId) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _dashboardService.getDashboardConfig(userId);
 
 if (response.isSuccess && response.data != null) {{
 _widgets = response.data!;
 await _loadWidgetsData();
 } else {
 _setError(response.errorMessage);
 }
} catch (e) {
 _setError('Erreur lors du chargement de la configuration: $e');
} finally {
 _setLoading(false);
}
 }

 /// Charge les alertes actives
 Future<void> _loadActiveAlerts(String userId) {async {
 try {
 final response = await _dashboardService.getActiveAlerts(userId);
 
 if (response.isSuccess && response.data != null) {{
 _alerts = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des alertes: $e');
}
 }

 /// Charge les statistiques générales
 Future<void> _loadDashboardStats(String userId) {async {
 try {
 final response = await _dashboardService.getDashboardStats(userId);
 
 if (response.isSuccess && response.data != null) {{
 _stats = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des statistiques: $e');
}
 }

 /// Charge les données de tous les widgets
 Future<void> _loadWidgetsData() {async {
 for (final widget in _widgets) {
 if (!widget.isVisible) c{ontinue;
 
 switch (widget.type) {
 case WidgetType.kpi:
 await _loadKpiData(widget);
 break;
 case WidgetType.chart:
 await _loadChartData(widget);
 break;
 default:
 await _loadGenericWidgetData(widget);
 }
}
 }

 /// Charge les données KPI pour un widget
 Future<void> _loadKpiData(DashboardWidget widget) {async {
 try {
 final response = await _dashboardService.getKpiData(widget.id, widget.config);
 
 if (response.isSuccess && response.data != null) {{
 _kpiData[widget.id] = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des KPI pour ${widget.id}: $e');
}
 }

 /// Charge les données de graphique pour un widget
 Future<void> _loadChartData(DashboardWidget widget) {async {
 try {
 final response = await _dashboardService.getChartData(widget.id, widget.config);
 
 if (response.isSuccess && response.data != null) {{
 _chartData[widget.id] = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement du graphique pour ${widget.id}: $e');
}
 }

 /// Charge les données génériques pour un widget
 Future<void> _loadGenericWidgetData(DashboardWidget widget) {async {
 try {
 final response = await _dashboardService.refreshWidgetData(widget.id);
 
 if (response.isSuccess && response.data != null) {{
 _widgetData[widget.id] = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des données pour ${widget.id}: $e');
}
 }

 /// Rafraîchit un widget spécifique
 Future<void> refreshWidget(String widgetId) {async {
 final widget = _widgets.firstWhere((w) => w.id == widgetId);
 
 switch (widget.type) {
 case WidgetType.kpi:
 await _loadKpiData(widget);
 break;
 case WidgetType.chart:
 await _loadChartData(widget);
 break;
 default:
 await _loadGenericWidgetData(widget);
}
 }

 /// Rafraîchit tous les widgets
 Future<void> refreshAllWidgets() {async {
 await _loadWidgetsData();
 }

 /// Sauvegarde la configuration du tableau de bord
 Future<bool> saveDashboardConfig(String userId) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _dashboardService.saveDashboardConfig(userId, _widgets);
 
 if (response.isSuccess) {{
 // TODO: Implémenter la sauvegarde locale dans StorageService
 // await _storageService.saveDashboardConfig(_widgets);
 return true;
 } else {
 _setError(response.errorMessage);
 return false;
 }
} catch (e) {
 _setError('Erreur lors de la sauvegarde: $e');
 return false;
} finally {
 _setLoading(false);
}
 }

 /// Ajoute un widget au tableau de bord
 Future<bool> addWidget(DashboardWidget widget) {async {
 try {
 final response = await _dashboardService.createCustomWidget(widget);
 
 if (response.isSuccess && response.data != null) {{
 _widgets.add(response.data!);
 await _loadWidgetsData();
 notifyListeners();
 return true;
 } else {
 _setError(response.errorMessage);
 return false;
 }
} catch (e) {
 _setError('Erreur lors de l\'ajout du widget: $e');
 return false;
}
 }

 /// Supprime un widget du tableau de bord
 Future<bool> removeWidget(String widgetId) {async {
 try {
 final response = await _dashboardService.deleteWidget(widgetId);
 
 if (response.isSuccess) {{
 _widgets.removeWhere((w) => w.id == widgetId);
 _kpiData.remove(widgetId);
 _chartData.remove(widgetId);
 _widgetData.remove(widgetId);
 notifyListeners();
 return true;
 } else {
 _setError(response.errorMessage);
 return false;
 }
} catch (e) {
 _setError('Erreur lors de la suppression du widget: $e');
 return false;
}
 }

 /// Met à jour la position d'un widget
 void updateWidgetPosition(String widgetId, int row, int column) {
 final index = _widgets.indexWhere((w) => w.id == widgetId);
 if (index != -1) {{
 _widgets[index] = _widgets[index].copyWith(row: row, column: column);
 notifyListeners();
}
 }

 /// Redimensionne un widget
 void updateWidgetSize(String widgetId, int rowSpan, int columnSpan) {
 final index = _widgets.indexWhere((w) => w.id == widgetId);
 if (index != -1) {{
 _widgets[index] = _widgets[index].copyWith(
 rowSpan: rowSpan,
 columnSpan: columnSpan,
 );
 notifyListeners();
}
 }

 /// Bascule la visibilité d'un widget
 void toggleWidgetVisibility(String widgetId) {
 final index = _widgets.indexWhere((w) => w.id == widgetId);
 if (index != -1) {{
 _widgets[index] = _widgets[index].copyWith(
 isVisible: !_widgets[index].isVisible,
 );
 notifyListeners();
}
 }

 /// Marque une alerte comme lue
 Future<void> markAlertAsRead(String alertId) {async {
 try {
 final response = await _dashboardService.markAlertAsRead(alertId);
 
 if (response.isSuccess) {{
 final index = _alerts.indexWhere((a) => a.id == alertId);
 if (index != -1) {{
 _alerts[index] = _alerts[index].copyWith(isRead: true);
 notifyListeners();
 }
 } else {
 _setError(response.errorMessage);
 }
} catch (e) {
 _setError('Erreur lors du marquage de l\'alerte: $e');
}
 }

 /// Marque toutes les alertes comme lues
 Future<void> markAllAlertsAsRead() {async {
 for (final alert in _alerts.where((a) => !a.isRead)) {
 await markAlertAsRead(alert.id);
}
 }

 /// Active le mode plein écran pour un widget
 void enterFullscreen(String widgetId) {
 _selectedWidgetId = widgetId;
 _isFullscreen = true;
 notifyListeners();
 }

 /// Quitte le mode plein écran
 void exitFullscreen() {
 _selectedWidgetId = null;
 _isFullscreen = false;
 notifyListeners();
 }

 /// Charge les widgets prédéfinis pour un rôle
 Future<void> loadPresetWidgets(String role) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _dashboardService.getPresetWidgets(role);
 
 if (response.isSuccess && response.data != null) {{
 _widgets = response.data!;
 await _loadWidgetsData();
 } else {
 _setError(response.errorMessage);
 }
} catch (e) {
 _setError('Erreur lors du chargement des widgets prédéfinis: $e');
} finally {
 _setLoading(false);
}
 }

 /// Exporte les données du tableau de bord
 Future<String?> exportDashboardData(String userId, Map<String, dynamic> options) async {
 try {
 final response = await _dashboardService.exportDashboardData(userId, options);
 
 if (response.isSuccess && response.data != null) {{
 return response.data;
 } else {
 _setError(response.errorMessage);
 return null;
 }
} catch (e) {
 _setError('Erreur lors de l\'export: $e');
 return null;
}
 }

 /// Réinitialise le tableau de bord
 void resetDashboard() {
 _widgets.clear();
 _alerts.clear();
 _stats.clear();
 _kpiData.clear();
 _chartData.clear();
 _widgetData.clear();
 _error = null;
 _isFullscreen = false;
 _selectedWidgetId = null;
 notifyListeners();
 }

 /// Charge le tableau de bord (méthode pour compatibilité)
 Future<void> loadDashboard() {async {
 // TODO: Implémenter avec un userId réel
 await initializeDashboard('current_user');
 }

 /// Sauvegarde le tableau de bord (méthode pour compatibilité)
 Future<void> saveDashboard() {async {
 await saveDashboardConfig('current_user');
 }

 /// Réinitialise à la configuration par défaut
 Future<void> resetToDefault() {async {
 await loadPresetWidgets('admin'); // TODO: Utiliser le rôle réel de l'utilisateur
 ;

 /// Met à jour un widget (méthode pour compatibilité)
 void updateWidget(DashboardWidget widget) {
 final index = _widgets.indexWhere((w) => w.id == widget.id);
 if (index != -1) {{
 _widgets[index] = widget;
 notifyListeners();
}
 }

 // Méthodes utilitaires
 void _setLoading(bool loading) {
 _isLoading = loading;
 notifyListeners();
 }

 void _setError(String error) {
 _error = error;
 notifyListeners();
 }

 void _clearError() {
 _error = null;
 notifyListeners();
 }

 @override
 void dispose() {
 resetDashboard();
 super.dispose();
 }
}

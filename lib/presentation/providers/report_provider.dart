import 'package:flutter/foundation.dart';
import '../../core/models/report.dart';
import '../../core/models/api_response.dart';
import '../../core/services/report_service.dart';
import '../../core/services/api_service.dart';

class ReportProvider with ChangeNotifier {
 final ReportService _reportService;
 final ApiService _apiService;

 ReportProvider(this._reportService, this._apiService);

 // État
 List<Report> _reports = [];
 Report? _selectedReport;
 bool _isLoading = false;
 String? _error;
 Map<String, dynamic>? _stats;
 List<Map<String, dynamic>> _templates = [];
 List<Map<String, dynamic>> _dataSources = [];
 List<Map<String, dynamic>> _executionHistory = [];
 List<Report> _sharedReports = [];
 Map<String, dynamic>? _currentReportData;

 // Filtres
 ReportCategory? _categoryFilter;
 ReportType? _typeFilter;
 ReportStatus? _statusFilter;
 String? _searchQuery;
 bool? _isPublicFilter;
 bool? _isActiveFilter;

 // Pagination
 int _currentPage = 1;
 int _totalPages = 1;
 int _totalItems = 0;
 int _itemsPerPage = 20;

 // Tri
 String _sortBy = 'createdAt';
 bool _sortAscending = false;

 // Getters
 List<Report> get reports => _reports;
 Report? get selectedReport => _selectedReport;
 bool get isLoading => _isLoading;
 String? get error => _error;
 Map<String, dynamic>? get stats => _stats;
 List<Map<String, dynamic>> get templates => _templates;
 List<Map<String, dynamic>> get dataSources => _dataSources;
 List<Map<String, dynamic>> get executionHistory => _executionHistory;
 List<Report> get sharedReports => _sharedReports;
 Map<String, dynamic>? get currentReportData => _currentReportData;

 // Filtres getters
 ReportCategory? get categoryFilter => _categoryFilter;
 ReportType? get typeFilter => _typeFilter;
 ReportStatus? get statusFilter => _statusFilter;
 String? get searchQuery => _searchQuery;
 bool? get isPublicFilter => _isPublicFilter;
 bool? get isActiveFilter => _isActiveFilter;

 // Pagination getters
 int get currentPage => _currentPage;
 int get totalPages => _totalPages;
 int get totalItems => _totalItems;
 int get itemsPerPage => _itemsPerPage;

 // Tri getters
 String get sortBy => _sortBy;
 bool get sortAscending => _sortAscending;

 // Getters calculés
 List<Report> get filteredReports {
 var reports = List<Report>.from(_reports);
 
 if (_categoryFilter != null) {{
 reports = reports.where((r) => r.category == _categoryFilter).toList();
}
 if (_typeFilter != null) {{
 reports = reports.where((r) => r.type == _typeFilter).toList();
}
 if (_statusFilter != null) {{
 reports = reports.where((r) => r.status == _statusFilter).toList();
}
 if (_isPublicFilter != null) {{
 reports = reports.where((r) => r.isPublic == _isPublicFilter).toList();
}
 if (_isActiveFilter != null) {{
 reports = reports.where((r) => r.isActive == _isActiveFilter).toList();
}
 if (_searchQuery != null && _searchQuery!.isNotEmpty) {{
 reports = reports.where((r) =>
 r.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
 r.description.toLowerCase().contains(_searchQuery!.toLowerCase())
 ).toList();
}
 
 return reports;
 }

 bool get hasError => _error != null;
 bool get hasData => _reports.isNotEmpty;
 bool get hasStats => _stats != null;
 bool get hasTemplates => _templates.isNotEmpty;
 bool get hasDataSources => _dataSources.isNotEmpty;
 bool get hasExecutionHistory => _executionHistory.isNotEmpty;
 bool get hasSharedReports => _sharedReports.isNotEmpty;
 bool get hasCurrentReportData => _currentReportData != null;

 // Actions
 Future<void> loadReports({bool refresh = false}) {async {
 if (refresh) {{
 _currentPage = 1;
 _reports.clear();
}

 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.getReports(
 category: _categoryFilter,
 type: _typeFilter,
 status: _statusFilter,
 search: _searchQuery,
 isPublic: _isPublicFilter,
 isActive: _isActiveFilter,
 page: _currentPage,
 limit: _itemsPerPage,
 sortBy: _sortBy,
 sortAscending: _sortAscending,
 );

 if (response.success && response.data != null) {{
 if (refresh) {{
 _reports = response.data!;
 } else {
 _reports.addAll(response.data!);
 }
 
 // Mettre à jour la pagination
 if (response.pagination != null) {{
 _totalPages = response.pagination!['totalPages'] ?? 1;
 _totalItems = response.pagination!['totalItems'] ?? 0;
 }
 
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des rapports');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> loadReportById(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.getReportById(id);

 if (response.success && response.data != null) {{
 _selectedReport = response.data;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Rapport non trouvé');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> createReport(Map<String, dynamic> reportData) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.createReport(reportData);

 if (response.success && response.data != null) {{
 _reports.insert(0, response.data!);
 _selectedReport = response.data;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la création du rapport');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> updateReport(String id, Map<String, dynamic> reportData) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.updateReport(id, reportData);

 if (response.success && response.data != null) {{
 final index = _reports.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _reports[index] = response.data!;
 }
 if (_selectedReport?.id == id) {{
 _selectedReport = response.data;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la mise à jour du rapport');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> deleteReport(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.deleteReport(id);

 if (response.success) {{
 _reports.removeWhere((r) => r.id == id);
 if (_selectedReport?.id == id) {{
 _selectedReport = null;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la suppression du rapport');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> runReport(String id, Map<String, dynamic>? parameters) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.runReport(id, parameters);

 if (response.success && response.data != null) {{
 _currentReportData = response.data;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de l\'exécution du rapport');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> scheduleReport(String id, Map<String, dynamic> scheduleData) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.scheduleReport(id, scheduleData);

 if (response.success && response.data != null) {{
 final index = _reports.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _reports[index] = response.data!;
 }
 if (_selectedReport?.id == id) {{
 _selectedReport = response.data;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la planification du rapport');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> unscheduleReport(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.unscheduleReport(id);

 if (response.success && response.data != null) {{
 final index = _reports.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _reports[index] = response.data!;
 }
 if (_selectedReport?.id == id) {{
 _selectedReport = response.data;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de l\'annulation de la planification');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> duplicateReport(String id, String newName) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.duplicateReport(id, newName);

 if (response.success && response.data != null) {{
 _reports.insert(0, response.data!);
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la duplication du rapport');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> shareReport(String id, List<String> userIds) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.shareReport(id, userIds);

 if (response.success && response.data != null) {{
 final index = _reports.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _reports[index] = response.data!;
 }
 if (_selectedReport?.id == id) {{
 _selectedReport = response.data;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du partage du rapport');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<String> exportReport(String id, ReportExportFormat format, Map<String, dynamic>? parameters) {async {
 _clearError();

 try {
 final response = await _reportService.exportReport(id, format, parameters);

 if (response.success && response.data != null) {{
 return response.data!;
 } else {
 _setError(response.message ?? 'Erreur lors de l\'export du rapport');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
}
 }

 Future<void> loadReportExecutionHistory(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.getReportExecutionHistory(id);

 if (response.success && response.data != null) {{
 _executionHistory = response.data!;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement de l\'historique');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> loadTemplates() {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.getReportTemplates();

 if (response.success && response.data != null) {{
 _templates = response.data!;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des modèles');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> createReportFromTemplate(String templateId, Map<String, dynamic> reportData) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.createReportFromTemplate(templateId, reportData);

 if (response.success && response.data != null) {{
 _reports.insert(0, response.data!);
 _selectedReport = response.data;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la création du rapport à partir du modèle');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> loadDataSources() {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.getDataSources();

 if (response.success && response.data != null) {{
 _dataSources = response.data!;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des sources de données');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<Map<String, dynamic>> testDataSource(Map<String, dynamic> dataSourceConfig) async {
 _clearError();

 try {
 final response = await _reportService.testDataSource(dataSourceConfig);

 if (response.success && response.data != null) {{
 return response.data!;
 } else {
 _setError(response.message ?? 'Erreur lors du test de la source de données');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
}
 }

 Future<void> loadStats({String? userId, ReportCategory? category, DateTime? startDate, DateTime? endDate}) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.getReportStats(
 userId: userId,
 category: category,
 startDate: startDate,
 endDate: endDate,
 );

 if (response.success && response.data != null) {{
 _stats = response.data;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des statistiques');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> loadSharedReports({bool refresh = false}) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.getSharedReports(
 page: refresh ? 1 : _currentPage,
 limit: _itemsPerPage,
 );

 if (response.success && response.data != null) {{
 if (refresh) {{
 _sharedReports = response.data!;
 } else {
 _sharedReports.addAll(response.data!);
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des rapports partagés');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> toggleReport(String id, bool isActive) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _reportService.toggleReport(id, isActive);

 if (response.success && response.data != null) {{
 final index = _reports.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _reports[index] = response.data!;
 }
 if (_selectedReport?.id == id) {{
 _selectedReport = response.data;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la mise à jour du rapport');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 // Actions de filtrage
 void setCategoryFilter(ReportCategory? category) {
 _categoryFilter = category;
 notifyListeners();
 }

 void setTypeFilter(ReportType? type) {
 _typeFilter = type;
 notifyListeners();
 }

 void setStatusFilter(ReportStatus? status) {
 _statusFilter = status;
 notifyListeners();
 }

 void setSearchQuery(String? query) {
 _searchQuery = query;
 notifyListeners();
 }

 void setPublicFilter(bool? isPublic) {
 _isPublicFilter = isPublic;
 notifyListeners();
 }

 void setActiveFilter(bool? isActive) {
 _isActiveFilter = isActive;
 notifyListeners();
 }

 void setSortBy(String sortBy, bool ascending) {
 _sortBy = sortBy;
 _sortAscending = ascending;
 notifyListeners();
 }

 void clearFilters() {
 _categoryFilter = null;
 _typeFilter = null;
 _statusFilter = null;
 _searchQuery = null;
 _isPublicFilter = null;
 _isActiveFilter = null;
 _sortBy = 'createdAt';
 _sortAscending = false;
 notifyListeners();
 }

 // Actions de pagination
 void loadNextPage() {
 if (_currentPage < _totalPages) {{
 _currentPage++;
 loadReports();
}
 }

 void loadPreviousPage() {
 if (_currentPage > 1) {{
 _currentPage--;
 loadReports();
}
 }

 void goToPage(int page) {
 if (page >= 1 && page <= _totalPages) {{
 _currentPage = page;
 loadReports();
}
 }

 void refresh() {
 loadReports(refresh: true);
 }

 // Actions de sélection
 void selectReport(Report? report) {
 _selectedReport = report;
 notifyListeners();
 }

 void clearSelectedReport() {
 _selectedReport = null;
 notifyListeners();
 }

 void clearCurrentReportData() {
 _currentReportData = null;
 notifyListeners();
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

 // Réinitialisation
 void reset() {
 _reports.clear();
 _selectedReport = null;
 _isLoading = false;
 _error = null;
 _stats = null;
 _templates.clear();
 _dataSources.clear();
 _executionHistory.clear();
 _sharedReports.clear();
 _currentReportData = null;
 
 // Réinitialiser les filtres
 _categoryFilter = null;
 _typeFilter = null;
 _statusFilter = null;
 _searchQuery = null;
 _isPublicFilter = null;
 _isActiveFilter = null;
 _sortBy = 'createdAt';
 _sortAscending = false;
 
 // Réinitialiser la pagination
 _currentPage = 1;
 _totalPages = 1;
 _totalItems = 0;
 
 notifyListeners();
 }
}

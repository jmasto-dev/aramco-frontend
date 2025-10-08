import 'package:flutter/foundation.dart';
import '../../core/models/purchase_request.dart';
import '../../core/models/api_response.dart';
import '../../core/services/purchase_service.dart';
import '../../core/services/api_service.dart';

class PurchaseProvider with ChangeNotifier {
 final PurchaseService _purchaseService;
 final ApiService _apiService;

 PurchaseProvider(this._purchaseService, this._apiService);

 // État
 List<PurchaseRequest> _purchaseRequests = [];
 PurchaseRequest? _selectedPurchaseRequest;
 bool _isLoading = false;
 String? _error;
 Map<String, dynamic>? _stats;
 List<Map<String, dynamic>> _workflows = [];
 List<Map<String, dynamic>> _productSuggestions = [];
 List<Map<String, dynamic>> _supplierSuggestions = [];

 // Filtres
 PurchaseRequestStatus? _statusFilter;
 PurchaseRequestType? _typeFilter;
 PurchaseRequestPriority? _priorityFilter;
 String? _searchQuery;
 DateTime? _startDate;
 DateTime? _endDate;
 double? _minAmount;
 double? _maxAmount;
 String _sortBy = 'requestDate';
 bool _sortAscending = false;

 // Pagination
 int _currentPage = 1;
 int _totalPages = 1;
 int _totalItems = 0;
 int _itemsPerPage = 20;

 // Getters
 List<PurchaseRequest> get purchaseRequests => _purchaseRequests;
 PurchaseRequest? get selectedPurchaseRequest => _selectedPurchaseRequest;
 bool get isLoading => _isLoading;
 String? get error => _error;
 Map<String, dynamic>? get stats => _stats;
 List<Map<String, dynamic>> get workflows => _workflows;
 List<Map<String, dynamic>> get productSuggestions => _productSuggestions;
 List<Map<String, dynamic>> get supplierSuggestions => _supplierSuggestions;

 // Filtres getters
 PurchaseRequestStatus? get statusFilter => _statusFilter;
 PurchaseRequestType? get typeFilter => _typeFilter;
 PurchaseRequestPriority? get priorityFilter => _priorityFilter;
 String? get searchQuery => _searchQuery;
 DateTime? get startDate => _startDate;
 DateTime? get endDate => _endDate;
 double? get minAmount => _minAmount;
 double? get maxAmount => _maxAmount;
 String get sortBy => _sortBy;
 bool get sortAscending => _sortAscending;

 // Pagination getters
 int get currentPage => _currentPage;
 int get totalPages => _totalPages;
 int get totalItems => _totalItems;
 int get itemsPerPage => _itemsPerPage;

 // Getters calculés
 List<PurchaseRequest> get filteredRequests {
 var requests = List<PurchaseRequest>.from(_purchaseRequests);
 
 if (_statusFilter != null) {{
 requests = requests.where((r) => r.status == _statusFilter).toList();
}
 if (_typeFilter != null) {{
 requests = requests.where((r) => r.type == _typeFilter).toList();
}
 if (_priorityFilter != null) {{
 requests = requests.where((r) => r.priority == _priorityFilter).toList();
}
 if (_searchQuery != null && _searchQuery!.isNotEmpty) {{
 requests = requests.where((r) =>
 r.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
 r.description.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
 r.requestNumber.toLowerCase().contains(_searchQuery!.toLowerCase())
 ).toList();
}
 
 return requests;
 }

 bool get hasError => _error != null;
 bool get hasData => _purchaseRequests.isNotEmpty;
 bool get hasStats => _stats != null;
 bool get hasWorkflows => _workflows.isNotEmpty;

 // Actions
 Future<void> loadPurchaseRequests({bool refresh = false}) {async {
 if (refresh) {{
 _currentPage = 1;
 _purchaseRequests.clear();
}

 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.getPurchaseRequests(
 status: _statusFilter,
 type: _typeFilter,
 priority: _priorityFilter,
 search: _searchQuery,
 startDate: _startDate,
 endDate: _endDate,
 minAmount: _minAmount,
 maxAmount: _maxAmount,
 page: _currentPage,
 limit: _itemsPerPage,
 sortBy: _sortBy,
 sortAscending: _sortAscending,
 );

 if (response.success && response.data != null) {{
 if (refresh) {{
 _purchaseRequests = response.data!;
 } else {
 _purchaseRequests.addAll(response.data!);
 }
 
 // Mettre à jour la pagination
 if (response.pagination != null) {{
 _totalPages = response.pagination!['totalPages'] ?? 1;
 _totalItems = response.pagination!['totalItems'] ?? 0;
 }
 
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des demandes d\'achat');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> loadPurchaseRequestById(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.getPurchaseRequestById(id);

 if (response.success && response.data != null) {{
 _selectedPurchaseRequest = response.data;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Demande d\'achat non trouvée');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> createPurchaseRequest(Map<String, dynamic> requestData) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.createPurchaseRequest(requestData);

 if (response.success && response.data != null) {{
 _purchaseRequests.insert(0, response.data!);
 _selectedPurchaseRequest = response.data;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la création de la demande d\'achat');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> updatePurchaseRequest(String id, Map<String, dynamic> requestData) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.updatePurchaseRequest(id, requestData);

 if (response.success && response.data != null) {{
 final index = _purchaseRequests.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _purchaseRequests[index] = response.data!;
 }
 if (_selectedPurchaseRequest?.id == id) {{
 _selectedPurchaseRequest = response.data;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la mise à jour de la demande d\'achat');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> deletePurchaseRequest(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.deletePurchaseRequest(id);

 if (response.success) {{
 _purchaseRequests.removeWhere((r) => r.id == id);
 if (_selectedPurchaseRequest?.id == id) {{
 _selectedPurchaseRequest = null;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la suppression de la demande d\'achat');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> submitPurchaseRequest(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.submitPurchaseRequest(id);

 if (response.success && response.data != null) {{
 final index = _purchaseRequests.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _purchaseRequests[index] = response.data!;
 }
 if (_selectedPurchaseRequest?.id == id) {{
 _selectedPurchaseRequest = response.data!;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la soumission de la demande d\'achat');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> approvePurchaseRequest(String id, String comments) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.approvePurchaseRequest(id, comments);

 if (response.success && response.data != null) {{
 final index = _purchaseRequests.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _purchaseRequests[index] = response.data!;
 }
 if (_selectedPurchaseRequest?.id == id) {{
 _selectedPurchaseRequest = response.data!;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de l\'approbation de la demande d\'achat');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> rejectPurchaseRequest(String id, String reason) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.rejectPurchaseRequest(id, reason);

 if (response.success && response.data != null) {{
 final index = _purchaseRequests.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _purchaseRequests[index] = response.data!;
 }
 if (_selectedPurchaseRequest?.id == id) {{
 _selectedPurchaseRequest = response.data!;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du rejet de la demande d\'achat');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> cancelPurchaseRequest(String id, String reason) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.cancelPurchaseRequest(id, reason);

 if (response.success && response.data != null) {{
 final index = _purchaseRequests.indexWhere((r) => r.id == id);
 if (index != -1) {{
 _purchaseRequests[index] = response.data!;
 }
 if (_selectedPurchaseRequest?.id == id) {{
 _selectedPurchaseRequest = response.data!;
 }
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de l\'annulation de la demande d\'achat');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
} finally {
 _setLoading(false);
}
 }

 Future<void> loadStats({String? department, DateTime? startDate, DateTime? endDate}) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.getPurchaseRequestStats(
 department: department,
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

 Future<void> loadWorkflows() {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.getApprovalWorkflows();

 if (response.success && response.data != null) {{
 _workflows = response.data!;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des workflows');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> loadProductSuggestions({String? category, String? search}) {async {
 _clearError();

 try {
 final response = await _purchaseService.getProductSuggestions(
 category: category,
 search: search,
 );

 if (response.success && response.data != null) {{
 _productSuggestions = response.data!;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des suggestions de produits');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
}
 }

 Future<void> loadSupplierSuggestions(String productId) {async {
 _clearError();

 try {
 final response = await _purchaseService.getSupplierSuggestions(productId);

 if (response.success && response.data != null) {{
 _supplierSuggestions = response.data!;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des suggestions de fournisseurs');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
}
 }

 Future<String> exportPurchaseRequests({
 PurchaseRequestStatus? status,
 PurchaseRequestType? type,
 DateTime? startDate,
 DateTime? endDate,
 String format = 'excel',
 }) {async {
 _clearError();

 try {
 final response = await _purchaseService.exportPurchaseRequests(
 status: status,
 type: type,
 startDate: startDate,
 endDate: endDate,
 format: format,
 );

 if (response.success && response.data != null) {{
 return response.data!;
 } else {
 _setError(response.message ?? 'Erreur lors de l\'export des demandes d\'achat');
 throw Exception(response.message);
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 rethrow;
}
 }

 Future<void> duplicatePurchaseRequest(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _purchaseService.duplicatePurchaseRequest(id);

 if (response.success && response.data != null) {{
 _purchaseRequests.insert(0, response.data!);
 _selectedPurchaseRequest = response.data;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors de la duplication de la demande d\'achat');
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
 void setStatusFilter(PurchaseRequestStatus? status) {
 _statusFilter = status;
 notifyListeners();
 }

 void setTypeFilter(PurchaseRequestType? type) {
 _typeFilter = type;
 notifyListeners();
 }

 void setPriorityFilter(PurchaseRequestPriority? priority) {
 _priorityFilter = priority;
 notifyListeners();
 }

 void setSearchQuery(String? query) {
 _searchQuery = query;
 notifyListeners();
 }

 void setDateRange(DateTime? start, DateTime? end) {
 _startDate = start;
 _endDate = end;
 notifyListeners();
 }

 void setAmountRange(double? min, double? max) {
 _minAmount = min;
 _maxAmount = max;
 notifyListeners();
 }

 void setSortBy(String sortBy, bool ascending) {
 _sortBy = sortBy;
 _sortAscending = ascending;
 notifyListeners();
 }

 void clearFilters() {
 _statusFilter = null;
 _typeFilter = null;
 _priorityFilter = null;
 _searchQuery = null;
 _startDate = null;
 _endDate = null;
 _minAmount = null;
 _maxAmount = null;
 _sortBy = 'requestDate';
 _sortAscending = false;
 notifyListeners();
 }

 // Actions de pagination
 void loadNextPage() {
 if (_currentPage < _totalPages) {{
 _currentPage++;
 loadPurchaseRequests();
}
 }

 void loadPreviousPage() {
 if (_currentPage > 1) {{
 _currentPage--;
 loadPurchaseRequests();
}
 }

 void goToPage(int page) {
 if (page >= 1 && page <= _totalPages) {{
 _currentPage = page;
 loadPurchaseRequests();
}
 }

 void refresh() {
 loadPurchaseRequests(refresh: true);
 }

 // Actions de sélection
 void selectPurchaseRequest(PurchaseRequest? request) {
 _selectedPurchaseRequest = request;
 notifyListeners();
 }

 void clearSelectedPurchaseRequest() {
 _selectedPurchaseRequest = null;
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
 _purchaseRequests.clear();
 _selectedPurchaseRequest = null;
 _isLoading = false;
 _error = null;
 _stats = null;
 _workflows.clear();
 _productSuggestions.clear();
 _supplierSuggestions.clear();
 
 // Réinitialiser les filtres
 _statusFilter = null;
 _typeFilter = null;
 _priorityFilter = null;
 _searchQuery = null;
 _startDate = null;
 _endDate = null;
 _minAmount = null;
 _maxAmount = null;
 _sortBy = 'requestDate';
 _sortAscending = false;
 
 // Réinitialiser la pagination
 _currentPage = 1;
 _totalPages = 1;
 _totalItems = 0;
 
 notifyListeners();
 }
}

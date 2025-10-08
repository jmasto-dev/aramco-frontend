import 'package:flutter/foundation.dart';
import '../../core/models/supplier.dart';
import '../../core/services/supplier_service.dart';
import '../../core/models/api_response.dart';

class SupplierProvider with ChangeNotifier {
 final SupplierService _supplierService;

 SupplierProvider(this._supplierService);

 // États
 List<Supplier> _suppliers = [];
 Supplier? _selectedSupplier;
 bool _isLoading = false;
 String? _error;
 int _currentPage = 1;
 int _totalPages = 1;
 int _totalCount = 0;
 bool _hasMore = true;

 // Filtres
 String _searchQuery = '';
 SupplierCategory? _selectedCategory;
 SupplierStatus? _selectedStatus;
 String _sortBy = 'name';
 bool _sortAscending = true;

 // Getters
 List<Supplier> get suppliers => List.unmodifiable(_suppliers);
 Supplier? get selectedSupplier => _selectedSupplier;
 bool get isLoading => _isLoading;
 String? get error => _error;
 int get currentPage => _currentPage;
 int get totalPages => _totalPages;
 int get totalCount => _totalCount;
 bool get hasMore => _hasMore;
 String get searchQuery => _searchQuery;
 SupplierCategory? get selectedCategory => _selectedCategory;
 SupplierStatus? get selectedStatus => _selectedStatus;
 String get sortBy => _sortBy;
 bool get sortAscending => _sortAscending;

 // Getters filtrés
 List<Supplier> get activeSuppliers => 
 _suppliers.where((s) => s.status == SupplierStatus.active).toList();
 
 List<Supplier> get pendingSuppliers => 
 _suppliers.where((s) => s.status == SupplierStatus.pendingVerification).toList();
 
 List<Supplier> get suspendedSuppliers => 
 _suppliers.where((s) => s.status == SupplierStatus.suspended).toList();

 // Actions de chargement
 Future<void> loadSuppliers({bool refresh = false}) {async {
 if (refresh) {{
 _currentPage = 1;
 _suppliers.clear();
 _hasMore = true;
}

 if (!_hasMore || _isLoading) r{eturn;

 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.getSuppliers(
 page: _currentPage,
 search: _searchQuery.isNotEmpty ? _searchQuery : null,
 category: _selectedCategory,
 status: _selectedStatus,
 sortBy: _sortBy,
 ascending: _sortAscending,
 );

 if (response.success && response.data != null) {{
 if (refresh) {{
 _suppliers = response.data!;
 } else {
 _suppliers.addAll(response.data!);
 }

 _currentPage++;
 _hasMore = response.data!.length == 20; // Assume 20 items per page
 _totalCount = _suppliers.length;
 _totalPages = (_totalCount / 20).ceil();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des fournisseurs');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 Future<void> refreshSuppliers() {async {
 await loadSuppliers(refresh: true);
 }

 Future<void> loadSupplierById(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.getSupplierById(id);

 if (response.success && response.data != null) {{
 _selectedSupplier = response.data;
 notifyListeners();
 } else {
 _setError(response.message ?? 'Fournisseur non trouvé');
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
} finally {
 _setLoading(false);
}
 }

 // Actions CRUD
 Future<bool> createSupplier(Supplier supplier) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.createSupplier(supplier);

 if (response.success && response.data != null) {{
 _suppliers.insert(0, response.data!);
 _totalCount++;
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la création du fournisseur');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 Future<bool> updateSupplier(String id, Supplier supplier) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.updateSupplier(id, supplier);

 if (response.success && response.data != null) {{
 final index = _suppliers.indexWhere((s) => s.id == id);
 if (index != -1) {{
 _suppliers[index] = response.data!;
 }
 if (_selectedSupplier?.id == id) {{
 _selectedSupplier = response.data!;
 }
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la mise à jour du fournisseur');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 Future<bool> deleteSupplier(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.deleteSupplier(id);

 if (response.success) {{
 _suppliers.removeWhere((s) => s.id == id);
 _totalCount--;
 if (_selectedSupplier?.id == id) {{
 _selectedSupplier = null;
 }
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la suppression du fournisseur');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 // Actions de statut
 Future<bool> updateSupplierStatus(String id, SupplierStatus status) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.updateSupplierStatus(id, status);

 if (response.success && response.data != null) {{
 final index = _suppliers.indexWhere((s) => s.id == id);
 if (index != -1) {{
 _suppliers[index] = response.data!;
 }
 if (_selectedSupplier?.id == id) {{
 _selectedSupplier = response.data!;
 }
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la mise à jour du statut');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 Future<bool> validateSupplier(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.validateSupplier(id);

 if (response.success && response.data != null) {{
 final index = _suppliers.indexWhere((s) => s.id == id);
 if (index != -1) {{
 _suppliers[index] = response.data!;
 }
 if (_selectedSupplier?.id == id) {{
 _selectedSupplier = response.data!;
 }
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la validation');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 Future<bool> suspendSupplier(String id, String? reason) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.suspendSupplier(id, reason);

 if (response.success && response.data != null) {{
 final index = _suppliers.indexWhere((s) => s.id == id);
 if (index != -1) {{
 _suppliers[index] = response.data!;
 }
 if (_selectedSupplier?.id == id) {{
 _selectedSupplier = response.data!;
 }
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la suspension');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 Future<bool> reactivateSupplier(String id) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.reactivateSupplier(id);

 if (response.success && response.data != null) {{
 final index = _suppliers.indexWhere((s) => s.id == id);
 if (index != -1) {{
 _suppliers[index] = response.data!;
 }
 if (_selectedSupplier?.id == id) {{
 _selectedSupplier = response.data!;
 }
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la réactivation');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 // Actions sur les documents
 Future<bool> addDocument(String supplierId, SupplierDocument document) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.addDocument(supplierId, document);

 if (response.success && response.data != null) {{
 // Mettre à jour le fournisseur local
 final index = _suppliers.indexWhere((s) => s.id == supplierId);
 if (index != -1) {{
 final updatedSupplier = _suppliers[index].copyWith(
 documents: [..._suppliers[index].documents, response.data!],
 );
 _suppliers[index] = updatedSupplier;
 
 if (_selectedSupplier?.id == supplierId) {{
 _selectedSupplier = updatedSupplier;
}
 }
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de l\'ajout du document');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 Future<bool> deleteDocument(String supplierId, String documentId) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.deleteDocument(supplierId, documentId);

 if (response.success) {{
 // Mettre à jour le fournisseur local
 final index = _suppliers.indexWhere((s) => s.id == supplierId);
 if (index != -1) {{
 final updatedDocuments = _suppliers[index].documents
 .where((d) => d.id != documentId)
 .toList();
 final updatedSupplier = _suppliers[index].copyWith(
 documents: updatedDocuments,
 );
 _suppliers[index] = updatedSupplier;
 
 if (_selectedSupplier?.id == supplierId) {{
 _selectedSupplier = updatedSupplier;
}
 }
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la suppression du document');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 // Actions sur les contacts
 Future<bool> addContact(String supplierId, SupplierContact contact) {async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.addContact(supplierId, contact);

 if (response.success && response.data != null) {{
 // Mettre à jour le fournisseur local
 final index = _suppliers.indexWhere((s) => s.id == supplierId);
 if (index != -1) {{
 final updatedSupplier = _suppliers[index].copyWith(
 contacts: [..._suppliers[index].contacts, response.data!],
 );
 _suppliers[index] = updatedSupplier;
 
 if (_selectedSupplier?.id == supplierId) {{
 _selectedSupplier = updatedSupplier;
}
 }
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de l\'ajout du contact');
 return false;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return false;
} finally {
 _setLoading(false);
}
 }

 // Actions de recherche et filtrage
 void setSearchQuery(String query) {
 _searchQuery = query;
 notifyListeners();
 }

 void setCategoryFilter(SupplierCategory? category) {
 _selectedCategory = category;
 notifyListeners();
 }

 void setStatusFilter(SupplierStatus? status) {
 _selectedStatus = status;
 notifyListeners();
 }

 void setSorting(String sortBy, bool ascending) {
 _sortBy = sortBy;
 _sortAscending = ascending;
 notifyListeners();
 }

 void clearFilters() {
 _searchQuery = '';
 _selectedCategory = null;
 _selectedStatus = null;
 _sortBy = 'name';
 _sortAscending = true;
 notifyListeners();
 }

 Future<void> applyFilters() {async {
 await refreshSuppliers();
 }

 // Recherche avancée
 Future<List<Supplier>> searchSuppliers({
 String? query,
 List<SupplierCategory>? categories,
 List<SupplierStatus>? statuses,
 List<String>? productCategories,
 double? minRating,
 double? maxRating,
 String? city,
 String? country,
 }) async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.searchSuppliers(
 query: query,
 categories: categories,
 statuses: statuses,
 productCategories: productCategories,
 minRating: minRating,
 maxRating: maxRating,
 city: city,
 country: country,
 );

 if (response.success && response.data != null) {{
 return response.data!;
 } else {
 _setError(response.message ?? 'Erreur lors de la recherche');
 return [];
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return [];
} finally {
 _setLoading(false);
}
 }

 // Export
 Future<String?> exportSuppliers({
 List<String>? supplierIds,
 SupplierCategory? category,
 SupplierStatus? status,
 String format = 'csv',
 }) async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.exportSuppliers(
 supplierIds: supplierIds,
 category: category,
 status: status,
 format: format,
 );

 if (response.success && response.data != null) {{
 return response.data;
 } else {
 _setError(response.message ?? 'Erreur lors de l\'export');
 return null;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return null;
} finally {
 _setLoading(false);
}
 }

 // Statistiques
 Future<Map<String, dynamic>?> getSupplierStatistics() async {
 _setLoading(true);
 _clearError();

 try {
 final response = await _supplierService.getSupplierStatistics();

 if (response.success && response.data != null) {{
 return response.data;
 } else {
 _setError(response.message ?? 'Erreur lors de la récupération des statistiques');
 return null;
 }
} catch (e) {
 _setError('Erreur réseau: ${e.toString()}');
 return null;
} finally {
 _setLoading(false);
}
 }

 // Utilitaires
 void selectSupplier(Supplier? supplier) {
 _selectedSupplier = supplier;
 notifyListeners();
 }

 void clearSelectedSupplier() {
 _selectedSupplier = null;
 notifyListeners();
 }

 void clearError() {
 _error = null;
 notifyListeners();
 }

 // Méthodes privées
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
 }
}

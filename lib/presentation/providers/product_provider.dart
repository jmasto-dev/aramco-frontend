import 'package:flutter/foundation.dart';
import '../../core/models/product.dart';
import '../../core/models/api_response.dart';
import '../../core/services/product_service.dart';
import '../../core/services/api_service.dart';

class ProductProvider extends ChangeNotifier {
 final ProductService _productService;
 
 // État des produits
 List<Product> _products = [];
 List<ProductCategory> _categories = [];
 Map<String, List<ProductVariant>> _productVariants = {};
 Map<String, Map<String, dynamic>> _stockInfo = {};
 
 // État de chargement
 bool _isLoading = false;
 bool _isLoadingCategories = false;
 bool _isLoadingVariants = false;
 bool _isSearching = false;
 
 // Filtres et pagination
 String _searchQuery = '';
 String? _selectedCategory;
 String? _sortBy = 'name';
 String? _sortOrder = 'asc';
 int _currentPage = 1;
 int _pageSize = 20;
 int _totalItems = 0;
 int _totalPages = 0;
 
 // Messages d'erreur
 String? _errorMessage;
 String? _searchErrorMessage;
 
 // Produits sélectionnés pour la commande
 Map<String, int> _selectedProducts = {};
 
 ProductProvider() : _productService = ProductService(ApiService()) {
 loadInitialData();
 }

 // Getters
 List<Product> get products => List.unmodifiable(_products);
 List<ProductCategory> get categories => List.unmodifiable(_categories);
 Map<String, List<ProductVariant>> get productVariants => Map.unmodifiable(_productVariants);
 Map<String, Map<String, dynamic>> get stockInfo => Map.unmodifiable(_stockInfo);
 
 bool get isLoading => _isLoading;
 bool get isLoadingCategories => _isLoadingCategories;
 bool get isLoadingVariants => _isLoadingVariants;
 bool get isSearching => _isSearching;
 
 String get searchQuery => _searchQuery;
 String? get selectedCategory => _selectedCategory;
 String? get sortBy => _sortBy;
 String? get sortOrder => _sortOrder;
 int get currentPage => _currentPage;
 int get pageSize => _pageSize;
 int get totalItems => _totalItems;
 int get totalPages => _totalPages;
 
 String? get errorMessage => _errorMessage;
 String? get searchErrorMessage => _searchErrorMessage;
 
 Map<String, int> get selectedProducts => Map.unmodifiable(_selectedProducts);
 
 bool get hasMorePages => _currentPage < _totalPages;
 bool get hasNextPage => _currentPage < _totalPages;
 bool get hasPreviousPage => _currentPage > 1;
 
 // Produits filtrés
 List<Product> get filteredProducts {
 var filtered = _products;
 
 if (_searchQuery.isNotEmpty) {{
 filtered = filtered.where((product) => product.matchesQuery(_searchQuery)).toList();
}
 
 if (_selectedCategory != null) {{
 filtered = filtered.where((product) => product.category == _selectedCategory).toList();
}
 
 // Tri
 if (_sortBy != null) {{
 filtered.sort((a, b) {
 int comparison = 0;
 switch (_sortBy) {
 case 'name':
 comparison = a.name.compareTo(b.name);
 break;
 case 'price':
 comparison = a.price.compareTo(b.price);
 break;
 case 'stock':
 comparison = a.stock.compareTo(b.stock);
 break;
 case 'createdAt':
 comparison = a.createdAt.compareTo(b.createdAt);
 break;
 }
 return _sortOrder == 'desc' ? -comparison : comparison;
 });
}
 
 return filtered;
 }
 
 // Résumé des produits sélectionnés
 double get selectedProductsTotal {
 double total = 0.0;
 for (final entry in _selectedProducts.entries) {
 final product = _products.firstWhere((p) => p.id == entry.key);
 total += product.effectivePrice * entry.value;
}
 return total;
 }
 
 int get selectedProductsCount => _selectedProducts.values.fold(0, (sum, qty) => sum + qty);

 // Charger les données initiales
 Future<void> loadInitialData() {async {
 await Future.wait([
 loadProducts(),
 loadCategories(),
 ]);
 }

 // Charger les produits
 Future<void> loadProducts({bool refresh = false}) {async {
 if (refresh) {{
 _currentPage = 1;
 _products.clear();
}
 
 if (_isLoading) r{eturn;
 
 _isLoading = true;
 _errorMessage = null;
 notifyListeners();
 
 try {
 final response = await _productService.getProducts(
 search: _searchQuery.isNotEmpty ? _searchQuery : null,
 category: _selectedCategory,
 sortBy: _sortBy,
 sortOrder: _sortOrder,
 page: _currentPage,
 limit: _pageSize,
 );
 
 if (response.isSuccess && response.data != null) {{
 if (refresh || _currentPage == 1) {{
 _products = response.data!;
 } else {
 _products.addAll(response.data!);
 }
 _errorMessage = null;
 } else {
 _errorMessage = response.errorMessage;
 }
} catch (e) {
 _errorMessage = 'Erreur lors du chargement des produits: $e';
} finally {
 _isLoading = false;
 notifyListeners();
}
 }

 // Charger plus de produits (pagination)
 Future<void> loadMoreProducts() {async {
 if (!hasMorePages || _isLoading) r{eturn;
 
 _currentPage++;
 await loadProducts();
 }

 // Charger les catégories
 Future<void> loadCategories() {async {
 if (_isLoadingCategories) r{eturn;
 
 _isLoadingCategories = true;
 notifyListeners();
 
 try {
 final response = await _productService.getCategories();
 
 if (response.isSuccess && response.data != null) {{
 _categories = response.data!;
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des catégories: $e');
} finally {
 _isLoadingCategories = false;
 notifyListeners();
}
 }

 // Charger les variants d'un produit
 Future<void> loadProductVariants(String productId) {async {
 if (_productVariants.containsKey(productId) |{| _isLoadingVariants) return;
 
 _isLoadingVariants = true;
 notifyListeners();
 
 try {
 final response = await _productService.getProductVariants(productId);
 
 if (response.isSuccess && response.data != null) {{
 _productVariants[productId] = response.data!;
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des variants: $e');
} finally {
 _isLoadingVariants = false;
 notifyListeners();
}
 }

 // Vérifier le stock d'un produit
 Future<void> checkStock(String productId) {async {
 try {
 final response = await _productService.checkStock(productId);
 
 if (response.isSuccess && response.data != null) {{
 _stockInfo[productId] = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors de la vérification du stock: $e');
}
 }

 // Rechercher des produits
 Future<void> searchProducts(String query) {async {
 if (_isSearching) r{eturn;
 
 _searchQuery = query;
 _isSearching = true;
 _searchErrorMessage = null;
 notifyListeners();
 
 try {
 if (query.isEmpty) {{
 await loadProducts(refresh: true);
 return;
 }
 
 final response = await _productService.searchProducts(query, limit: 50);
 
 if (response.isSuccess && response.data != null) {{
 _products = response.data!;
 _searchErrorMessage = null;
 } else {
 _searchErrorMessage = response.errorMessage;
 _products.clear();
 }
} catch (e) {
 _searchErrorMessage = 'Erreur lors de la recherche: $e';
 _products.clear();
} finally {
 _isSearching = false;
 notifyListeners();
}
 }

 // Appliquer des filtres
 void applyFilters({
 String? category,
 String? sortBy,
 String? sortOrder,
 }) {
 _selectedCategory = category;
 _sortBy = sortBy;
 _sortOrder = sortOrder;
 _currentPage = 1;
 loadProducts(refresh: true);
 }

 // Réinitialiser les filtres
 void resetFilters() {
 _searchQuery = '';
 _selectedCategory = null;
 _sortBy = 'name';
 _sortOrder = 'asc';
 _currentPage = 1;
 loadProducts(refresh: true);
 }

 // Gestion des produits sélectionnés pour la commande
 void toggleProductSelection(String productId, int quantity) {
 if (quantity <= 0) {{
 _selectedProducts.remove(productId);
} else {
 final product = _products.firstWhere((p) => p.id == productId);
 if (product.canOrderQuantity(quantity)){ {
 _selectedProducts[productId] = quantity;
 } else {
 throw Exception('Quantité invalide pour ce produit');
 }
}
 notifyListeners();
 }

 void updateProductQuantity(String productId, int quantity) {
 if (quantity <= 0) {{
 _selectedProducts.remove(productId);
} else {
 final product = _products.firstWhere((p) => p.id == productId);
 if (product.canOrderQuantity(quantity)){ {
 _selectedProducts[productId] = quantity;
 } else {
 throw Exception('Quantité invalide pour ce produit');
 }
}
 notifyListeners();
 }

 void clearSelectedProducts() {
 _selectedProducts.clear();
 notifyListeners();
 }

 // Obtenir un produit par son ID
 Product? getProductById(String productId) {
 try {
 return _products.firstWhere((product) => product.id == productId);
} catch (e) {
 return null;
}
 }

 // Obtenir les variants d'un produit
 List<ProductVariant>? getProductVariants(String productId) {
 return _productVariants[productId];
 }

 // Obtenir les informations de stock d'un produit
 Map<String, dynamic>? getStockInfo(String productId) {
 return _stockInfo[productId];
 }

 // Rafraîchir les données
 Future<void> refresh() {async {
 await Future.wait([
 loadProducts(refresh: true),
 loadCategories(),
 ]);
 }

 // Vider les erreurs
 void clearErrors() {
 _errorMessage = null;
 _searchErrorMessage = null;
 notifyListeners();
 }

 // Obtenir les produits populaires
 Future<void> loadPopularProducts() {async {
 try {
 final response = await _productService.getPopularProducts();
 
 if (response.isSuccess && response.data != null) {{
 _products = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des produits populaires: $e');
}
 }

 // Obtenir les produits en promotion
 Future<void> loadDiscountedProducts() {async {
 try {
 final response = await _productService.getDiscountedProducts();
 
 if (response.isSuccess && response.data != null) {{
 _products = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des produits en promotion: $e');
}
 }

 // Obtenir les produits par catégorie
 Future<void> loadProductsByCategory(String categoryId) {async {
 _selectedCategory = categoryId;
 _currentPage = 1;
 await loadProducts(refresh: true);
 }

 // Calculer les prix pour une commande
 Future<Map<String, dynamic>?> calculatePricing(String productId, int quantity) async {
 try {
 final response = await _productService.calculatePricing(
 productId: productId,
 quantity: quantity,
 );
 
 if (response.isSuccess && response.data != null) {{
 return response.data!;
 }
} catch (e) {
 debugPrint('Erreur lors du calcul des prix: $e');
}
 return null;
 }

 // Obtenir des recommandations
 Future<void> loadRecommendations({String? productId, String? categoryId}) {async {
 try {
 final response = await _productService.getRecommendations(
 productId: productId,
 categoryId: categoryId,
 );
 
 if (response.isSuccess && response.data != null) {{
 _products = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des recommandations: $e');
}
 }
}

import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
 final ApiService _apiService;
 static const String _baseUrl = '/api/products';

 ProductService(this._apiService);

 // Obtenir tous les produits avec filtres
 Future<ApiResponse<List<Product>>> getProducts({
 String? search,
 String? category,
 bool? isActive,
 int? minStock,
 int? maxStock,
 double? minPrice,
 double? maxPrice,
 String? sortBy,
 String? sortOrder,
 int? page,
 int? limit,
 }) async {
 try {
 final queryParams = <String, dynamic>{};
 
 if (search != null) q{ueryParams['search'] = search;
 if (category != null) q{ueryParams['category'] = category;
 if (isActive != null) q{ueryParams['is_active'] = isActive.toString();
 if (minStock != null) q{ueryParams['min_stock'] = minStock.toString();
 if (maxStock != null) q{ueryParams['max_stock'] = maxStock.toString();
 if (minPrice != null) q{ueryParams['min_price'] = minPrice.toString();
 if (maxPrice != null) q{ueryParams['max_price'] = maxPrice.toString();
 if (sortBy != null) q{ueryParams['sort_by'] = sortBy;
 if (sortOrder != null) q{ueryParams['sort_order'] = sortOrder;
 if (page != null) q{ueryParams['page'] = page.toString();
 if (limit != null) q{ueryParams['limit'] = limit.toString();

 final ApiResponse<dynamic> response = await _apiService.get<List<String>>(
 '$_baseUrl',
 queryParameters: queryParams,
 );
 
 if (response.isSuccess && response.data != null) {
 final products = response.data!.map((json) => Product.fromJson(json)).toList();
 return ApiResponse<List<Product>>.success(
 data: products,
 message: response.message ?? 'Products retrieved successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<List<Product>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<List<Product>>.error(
 message: 'Network error: $e',
 );
}
 }

 // Obtenir un produit par son ID
 Future<ApiResponse<Product>> getProductById(String productId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/$productId',
 );
 
 if (response.isSuccess && response.data != null) {
 final product = Product.fromJson(response.data!);
 return ApiResponse<Product>.success(
 data: product,
 message: response.message ?? 'Product retrieved successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<Product>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<Product>.error(
 message: 'Network error: $e',
 );
}
 }

 // Obtenir les catégories de produits
 Future<ApiResponse<List<ProductCategory>>> getCategories() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<List<String>>(
 '$_baseUrl/categories',
 );
 
 if (response.isSuccess && response.data != null) {
 final categories = response.data!.map((json) => ProductCategory.fromJson(json)).toList();
 return ApiResponse<List<ProductCategory>>.success(
 data: categories,
 message: response.message ?? 'Categories retrieved successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<List<ProductCategory>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<List<ProductCategory>>.error(
 message: 'Network error: $e',
 );
}
 }

 // Obtenir les variants d'un produit
 Future<ApiResponse<List<ProductVariant>>> getProductVariants(String productId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<List<String>>(
 '$_baseUrl/$productId/variants',
 );
 
 if (response.isSuccess && response.data != null) {
 final variants = response.data!.map((json) => ProductVariant.fromJson(json)).toList();
 return ApiResponse<List<ProductVariant>>.success(
 data: variants,
 message: response.message ?? 'Product variants retrieved successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<List<ProductVariant>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<List<ProductVariant>>.error(
 message: 'Network error: $e',
 );
}
 }

 // Vérifier le stock d'un produit
 Future<ApiResponse<Map<String, dynamic>>> checkStock(String productId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/$productId/stock',
 );
 
 if (response.isSuccess && response.data != null) {
 return ApiResponse<Map<String, dynamic>>.success(
 data: response.data!,
 message: response.message ?? 'Stock information retrieved successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<Map<String, dynamic>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<Map<String, dynamic>>.error(
 message: 'Network error: $e',
 );
}
 }

 // Rechercher des produits (pour l'autocomplétion)
 Future<ApiResponse<List<Product>>> searchProducts(String query, {int limit = 10}) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<List<String>>(
 '$_baseUrl/search',
 queryParameters: {
 'q': query,
 'limit': limit.toString(),
 },
 );
 
 if (response.isSuccess && response.data != null) {
 final products = response.data!.map((json) => Product.fromJson(json)).toList();
 return ApiResponse<List<Product>>.success(
 data: products,
 message: response.message ?? 'Products searched successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<List<Product>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<List<Product>>.error(
 message: 'Network error: $e',
 );
}
 }

 // Obtenir les produits populaires
 Future<ApiResponse<List<Product>>> getPopularProducts({int limit = 20}) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<List<String>>(
 '$_baseUrl/popular',
 queryParameters: {
 'limit': limit.toString(),
 },
 );
 
 if (response.isSuccess && response.data != null) {
 final products = response.data!.map((json) => Product.fromJson(json)).toList();
 return ApiResponse<List<Product>>.success(
 data: products,
 message: response.message ?? 'Popular products retrieved successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<List<Product>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<List<Product>>.error(
 message: 'Network error: $e',
 );
}
 }

 // Obtenir les produits en promotion
 Future<ApiResponse<List<Product>>> getDiscountedProducts({int limit = 20}) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<List<String>>(
 '$_baseUrl/discounted',
 queryParameters: {
 'limit': limit.toString(),
 },
 );
 
 if (response.isSuccess && response.data != null) {
 final products = response.data!.map((json) => Product.fromJson(json)).toList();
 return ApiResponse<List<Product>>.success(
 data: products,
 message: response.message ?? 'Discounted products retrieved successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<List<Product>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<List<Product>>.error(
 message: 'Network error: $e',
 );
}
 }

 // Obtenir les produits par catégorie
 Future<ApiResponse<List<Product>>> getProductsByCategory(
 String categoryId, {
 int? page,
 int? limit,
 String? sortBy,
 String? sortOrder,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'category_id': categoryId,
 };
 
 if (page != null) q{ueryParams['page'] = page.toString();
 if (limit != null) q{ueryParams['limit'] = limit.toString();
 if (sortBy != null) q{ueryParams['sort_by'] = sortBy;
 if (sortOrder != null) q{ueryParams['sort_order'] = sortOrder;

 final ApiResponse<dynamic> response = await _apiService.get<List<String>>(
 '$_baseUrl/by-category',
 queryParameters: queryParams,
 );
 
 if (response.isSuccess && response.data != null) {
 final products = response.data!.map((json) => Product.fromJson(json)).toList();
 return ApiResponse<List<Product>>.success(
 data: products,
 message: response.message ?? 'Products by category retrieved successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<List<Product>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<List<Product>>.error(
 message: 'Network error: $e',
 );
}
 }

 // Calculer les prix avec taxes et remises
 Future<ApiResponse<Map<String, dynamic>>> calculatePricing({
 required String productId,
 required int quantity,
 String? variantId,
 String? customerGroupId,
 String? countryCode,
 }) async {
 try {
 final requestData = {
 'product_id': productId,
 'quantity': quantity,
 if (variantId != null) '{variant_id': variantId,
 if (customerGroupId != null) '{customer_group_id': customerGroupId,
 if (countryCode != null) '{country_code': countryCode,
 };

 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/calculate-pricing',
 data: requestData,
 );
 
 if (response.isSuccess && response.data != null) {
 return ApiResponse<Map<String, dynamic>>.success(
 data: response.data!,
 message: response.message ?? 'Pricing calculated successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<Map<String, dynamic>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<Map<String, dynamic>>.error(
 message: 'Network error: $e',
 );
}
 }

 // Obtenir les recommandations de produits
 Future<ApiResponse<List<Product>>> getRecommendations({
 String? productId,
 String? categoryId,
 int limit = 10,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'limit': limit.toString(),
 };
 
 if (productId != null) q{ueryParams['product_id'] = productId;
 if (categoryId != null) q{ueryParams['category_id'] = categoryId;

 final ApiResponse<dynamic> response = await _apiService.get<List<String>>(
 '$_baseUrl/recommendations',
 queryParameters: queryParams,
 );
 
 if (response.isSuccess && response.data != null) {
 final products = response.data!.map((json) => Product.fromJson(json)).toList();
 return ApiResponse<List<Product>>.success(
 data: products,
 message: response.message ?? 'Recommendations retrieved successfully',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<List<Product>>.error(
 message: response.errorMessage,
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<List<Product>>.error(
 message: 'Network error: $e',
 );
}
 }
}

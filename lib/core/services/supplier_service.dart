import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/supplier.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class SupplierService {
 final ApiService _apiService;
 final String _baseUrl = '${AppConstants.apiBaseUrl}/suppliers';

 SupplierService(this._apiService);

 // Récupérer tous les fournisseurs
 Future<ApiResponse<List<Supplier>>> getSuppliers({
 int page = 1,
 int limit = 20,
 String? search,
 SupplierCategory? category,
 SupplierStatus? status,
 String? sortBy,
 bool ascending = true,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 if (search != null && search.isNotEmpty) '{search': search,
 if (category != null) '{category': category.name.toUpperCase(),
 if (status != null) '{status': status.name.toUpperCase(),
 if (sortBy != null) '{sortBy': sortBy,
 'order': ascending ? 'asc' : 'desc',
 };

 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl', queryParams: queryParams);
 
 if (response.success) {
 final suppliersData = response.data['suppliers'] as List;
 final suppliers = suppliersData
 .map((json) => Supplier.fromJson(json))
 .toList();
 
 return ApiResponse<List<Supplier>>.success(
 data: suppliers,
 message: response.message ?? 'Fournisseurs récupérés avec succès',
 );
 } else {
 return ApiResponse<List<Supplier>>.error(
 message: response.message ?? 'Erreur lors de la récupération des fournisseurs',
 );
 }
} catch (e) {
 return ApiResponse<List<Supplier>>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer un fournisseur par son ID
 Future<ApiResponse<Supplier>> getSupplierById(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/$id');
 
 if (response.success) {
 final supplier = Supplier.fromJson(response.data);
 return ApiResponse<Supplier>.success(
 data: supplier,
 message: response.message ?? 'Fournisseur récupéré avec succès',
 );
 } else {
 return ApiResponse<Supplier>.error(
 message: response.message ?? 'Fournisseur non trouvé',
 );
 }
} catch (e) {
 return ApiResponse<Supplier>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Créer un nouveau fournisseur
 Future<ApiResponse<Supplier>> createSupplier(Supplier supplier) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 _baseUrl,
 data: supplier.toJson(),
 );
 
 if (response.success) {
 final createdSupplier = Supplier.fromJson(response.data);
 return ApiResponse<Supplier>.success(
 data: createdSupplier,
 message: response.message ?? 'Fournisseur créé avec succès',
 );
 } else {
 return ApiResponse<Supplier>.error(
 message: response.message ?? 'Erreur lors de la création du fournisseur',
 );
 }
} catch (e) {
 return ApiResponse<Supplier>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Mettre à jour un fournisseur
 Future<ApiResponse<Supplier>> updateSupplier(String id, Supplier supplier) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put(
 '$_baseUrl/$id',
 data: supplier.toJson(),
 );
 
 if (response.success) {
 final updatedSupplier = Supplier.fromJson(response.data);
 return ApiResponse<Supplier>.success(
 data: updatedSupplier,
 message: response.message ?? 'Fournisseur mis à jour avec succès',
 );
 } else {
 return ApiResponse<Supplier>.error(
 message: response.message ?? 'Erreur lors de la mise à jour du fournisseur',
 );
 }
} catch (e) {
 return ApiResponse<Supplier>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Supprimer un fournisseur
 Future<ApiResponse<void>> deleteSupplier(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('$_baseUrl/$id');
 
 if (response.success) {
 return ApiResponse<void>.success(
 message: response.message ?? 'Fournisseur supprimé avec succès',
 );
 } else {
 return ApiResponse<void>.error(
 message: response.message ?? 'Erreur lors de la suppression du fournisseur',
 );
 }
} catch (e) {
 return ApiResponse<void>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Mettre à jour le statut d'un fournisseur
 Future<ApiResponse<Supplier>> updateSupplierStatus(
 String id,
 SupplierStatus status,
 ) async {
 try {
 final response = await _apiService.patch(
 '$_baseUrl/$id/status',
 data: {'status': status.name.toUpperCase()},
 );
 
 if (response.success) {
 final updatedSupplier = Supplier.fromJson(response.data);
 return ApiResponse<Supplier>.success(
 data: updatedSupplier,
 message: response.message ?? 'Statut du fournisseur mis à jour avec succès',
 );
 } else {
 return ApiResponse<Supplier>.error(
 message: response.message ?? 'Erreur lors de la mise à jour du statut',
 );
 }
} catch (e) {
 return ApiResponse<Supplier>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Ajouter un document à un fournisseur
 Future<ApiResponse<SupplierDocument>> addDocument(
 String supplierId,
 SupplierDocument document,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '$_baseUrl/$supplierId/documents',
 data: document.toJson(),
 );
 
 if (response.success) {
 final addedDocument = SupplierDocument.fromJson(response.data);
 return ApiResponse<SupplierDocument>.success(
 data: addedDocument,
 message: response.message ?? 'Document ajouté avec succès',
 );
 } else {
 return ApiResponse<SupplierDocument>.error(
 message: response.message ?? 'Erreur lors de l\'ajout du document',
 );
 }
} catch (e) {
 return ApiResponse<SupplierDocument>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Supprimer un document
 Future<ApiResponse<void>> deleteDocument(String supplierId, String documentId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('$_baseUrl/$supplierId/documents/$documentId');
 
 if (response.success) {
 return ApiResponse<void>.success(
 message: response.message ?? 'Document supprimé avec succès',
 );
 } else {
 return ApiResponse<void>.error(
 message: response.message ?? 'Erreur lors de la suppression du document',
 );
 }
} catch (e) {
 return ApiResponse<void>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Vérifier un document
 Future<ApiResponse<SupplierDocument>> verifyDocument(
 String supplierId,
 String documentId,
 bool isVerified,
 ) async {
 try {
 final response = await _apiService.patch(
 '$_baseUrl/$supplierId/documents/$documentId/verify',
 data: {'isVerified': isVerified},
 );
 
 if (response.success) {
 final verifiedDocument = SupplierDocument.fromJson(response.data);
 return ApiResponse<SupplierDocument>.success(
 data: verifiedDocument,
 message: response.message ?? 'Document vérifié avec succès',
 );
 } else {
 return ApiResponse<SupplierDocument>.error(
 message: response.message ?? 'Erreur lors de la vérification du document',
 );
 }
} catch (e) {
 return ApiResponse<SupplierDocument>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Ajouter un contact à un fournisseur
 Future<ApiResponse<SupplierContact>> addContact(
 String supplierId,
 SupplierContact contact,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '$_baseUrl/$supplierId/contacts',
 data: contact.toJson(),
 );
 
 if (response.success) {
 final addedContact = SupplierContact.fromJson(response.data);
 return ApiResponse<SupplierContact>.success(
 data: addedContact,
 message: response.message ?? 'Contact ajouté avec succès',
 );
 } else {
 return ApiResponse<SupplierContact>.error(
 message: response.message ?? 'Erreur lors de l\'ajout du contact',
 );
 }
} catch (e) {
 return ApiResponse<SupplierContact>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Mettre à jour un contact
 Future<ApiResponse<SupplierContact>> updateContact(
 String supplierId,
 String contactId,
 SupplierContact contact,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put(
 '$_baseUrl/$supplierId/contacts/$contactId',
 data: contact.toJson(),
 );
 
 if (response.success) {
 final updatedContact = SupplierContact.fromJson(response.data);
 return ApiResponse<SupplierContact>.success(
 data: updatedContact,
 message: response.message ?? 'Contact mis à jour avec succès',
 );
 } else {
 return ApiResponse<SupplierContact>.error(
 message: response.message ?? 'Erreur lors de la mise à jour du contact',
 );
 }
} catch (e) {
 return ApiResponse<SupplierContact>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Supprimer un contact
 Future<ApiResponse<void>> deleteContact(String supplierId, String contactId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('$_baseUrl/$supplierId/contacts/$contactId');
 
 if (response.success) {
 return ApiResponse<void>.success(
 message: response.message ?? 'Contact supprimé avec succès',
 );
 } else {
 return ApiResponse<void>.error(
 message: response.message ?? 'Erreur lors de la suppression du contact',
 );
 }
} catch (e) {
 return ApiResponse<void>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Ajouter une évaluation à un fournisseur
 Future<ApiResponse<SupplierRating>> addRating(
 String supplierId,
 SupplierRating rating,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '$_baseUrl/$supplierId/ratings',
 data: rating.toJson(),
 );
 
 if (response.success) {
 final addedRating = SupplierRating.fromJson(response.data);
 return ApiResponse<SupplierRating>.success(
 data: addedRating,
 message: response.message ?? 'Évaluation ajoutée avec succès',
 );
 } else {
 return ApiResponse<SupplierRating>.error(
 message: response.message ?? 'Erreur lors de l\'ajout de l\'évaluation',
 );
 }
} catch (e) {
 return ApiResponse<SupplierRating>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les évaluations d'un fournisseur
 Future<ApiResponse<List<SupplierRating>>> getSupplierRatings(
 String supplierId, {
 int page = 1,
 int limit = 10,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 final ApiResponse<dynamic> response = await _apiService.get(
 '$_baseUrl/$supplierId/ratings',
 queryParams: queryParams,
 );
 
 if (response.success) {
 final ratingsData = response.data['ratings'] as List;
 final ratings = ratingsData
 .map((json) => SupplierRating.fromJson(json))
 .toList();
 
 return ApiResponse<List<SupplierRating>>.success(
 data: ratings,
 message: response.message ?? 'Évaluations récupérées avec succès',
 );
 } else {
 return ApiResponse<List<SupplierRating>>.error(
 message: response.message ?? 'Erreur lors de la récupération des évaluations',
 );
 }
} catch (e) {
 return ApiResponse<List<SupplierRating>>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Rechercher des fournisseurs par critères
 Future<ApiResponse<List<Supplier>>> searchSuppliers({
 String? query,
 List<SupplierCategory>? categories,
 List<SupplierStatus>? statuses,
 List<String>? productCategories,
 double? minRating,
 double? maxRating,
 String? city,
 String? country,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 if (query != null && query.isNotEmpty) '{query': query,
 if (categories != null && categories.isNotEmpty)
 '{categories': categories.map((c) => c.name.toUpperCase()).join(','),
 if (statuses != null && statuses.isNotEmpty)
 '{statuses': statuses.map((s) => s.name.toUpperCase()).join(','),
 if (productCategories != null && productCategories.isNotEmpty)
 '{productCategories': productCategories.join(','),
 if (minRating != null) '{minRating': minRating.toString(),
 if (maxRating != null) '{maxRating': maxRating.toString(),
 if (city != null && city.isNotEmpty) '{city': city,
 if (country != null && country.isNotEmpty) '{country': country,
 };

 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/search', queryParams: queryParams);
 
 if (response.success) {
 final suppliersData = response.data['suppliers'] as List;
 final suppliers = suppliersData
 .map((json) => Supplier.fromJson(json))
 .toList();
 
 return ApiResponse<List<Supplier>>.success(
 data: suppliers,
 message: response.message ?? 'Recherche effectuée avec succès',
 );
 } else {
 return ApiResponse<List<Supplier>>.error(
 message: response.message ?? 'Erreur lors de la recherche',
 );
 }
} catch (e) {
 return ApiResponse<List<Supplier>>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Exporter les fournisseurs
 Future<ApiResponse<String>> exportSuppliers({
 List<String>? supplierIds,
 SupplierCategory? category,
 SupplierStatus? status,
 String format = 'csv',
 }) async {
 try {
 final queryParams = <String, String>{
 'format': format,
 if (supplierIds != null && supplierIds.isNotEmpty)
 '{ids': supplierIds.join(','),
 if (category != null) '{category': category.name.toUpperCase(),
 if (status != null) '{status': status.name.toUpperCase(),
 };

 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/export', queryParams: queryParams);
 
 if (response.success) {
 return ApiResponse<String>.success(
 data: response.data['downloadUrl'],
 message: response.message ?? 'Export généré avec succès',
 );
 } else {
 return ApiResponse<String>.error(
 message: response.message ?? 'Erreur lors de l\'export',
 );
 }
} catch (e) {
 return ApiResponse<String>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les statistiques des fournisseurs
 Future<ApiResponse<Map<String, dynamic>>> getSupplierStatistics() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/statistics');
 
 if (response.success) {
 return ApiResponse<Map<String, dynamic>>.success(
 data: response.data,
 message: response.message ?? 'Statistiques récupérées avec succès',
 );
 } else {
 return ApiResponse<Map<String, dynamic>>.error(
 message: response.message ?? 'Erreur lors de la récupération des statistiques',
 );
 }
} catch (e) {
 return ApiResponse<Map<String, dynamic>>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Valider un fournisseur
 Future<ApiResponse<Supplier>> validateSupplier(String supplierId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$supplierId/validate');
 
 if (response.success) {
 final validatedSupplier = Supplier.fromJson(response.data);
 return ApiResponse<Supplier>.success(
 data: validatedSupplier,
 message: response.message ?? 'Fournisseur validé avec succès',
 );
 } else {
 return ApiResponse<Supplier>.error(
 message: response.message ?? 'Erreur lors de la validation du fournisseur',
 );
 }
} catch (e) {
 return ApiResponse<Supplier>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Suspendre un fournisseur
 Future<ApiResponse<Supplier>> suspendSupplier(String supplierId, String? reason) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '$_baseUrl/$supplierId/suspend',
 data: {'reason': reason},
 );
 
 if (response.success) {
 final suspendedSupplier = Supplier.fromJson(response.data);
 return ApiResponse<Supplier>.success(
 data: suspendedSupplier,
 message: response.message ?? 'Fournisseur suspendu avec succès',
 );
 } else {
 return ApiResponse<Supplier>.error(
 message: response.message ?? 'Erreur lors de la suspension du fournisseur',
 );
 }
} catch (e) {
 return ApiResponse<Supplier>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Réactiver un fournisseur
 Future<ApiResponse<Supplier>> reactivateSupplier(String supplierId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$supplierId/reactivate');
 
 if (response.success) {
 final reactivatedSupplier = Supplier.fromJson(response.data);
 return ApiResponse<Supplier>.success(
 data: reactivatedSupplier,
 message: response.message ?? 'Fournisseur réactivé avec succès',
 );
 } else {
 return ApiResponse<Supplier>.error(
 message: response.message ?? 'Erreur lors de la réactivation du fournisseur',
 );
 }
} catch (e) {
 return ApiResponse<Supplier>.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }
}

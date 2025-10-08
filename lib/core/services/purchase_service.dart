import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/purchase_request.dart';
import 'api_service.dart';

class PurchaseService {
 final ApiService _apiService;
 static const String _baseUrl = '/purchase-requests';

 PurchaseService(this._apiService);

 // Récupérer toutes les demandes d'achat
 Future<ApiResponse<List<PurchaseRequest>>> getPurchaseRequests({
 PurchaseRequestStatus? status,
 PurchaseRequestType? type,
 PurchaseRequestPriority? priority,
 String? requesterId,
 String? department,
 DateTime? startDate,
 DateTime? endDate,
 double? minAmount,
 double? maxAmount,
 String? search,
 int page = 1,
 int limit = 20,
 String sortBy = 'requestDate',
 bool sortAscending = false,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 'sortBy': sortBy,
 'sortAscending': sortAscending.toString(),
 };

 if (status != null) {
 queryParams['status'] = status.name.toUpperCase();
 }
 if (type != null) {
 queryParams['type'] = type.name.toUpperCase();
 }
 if (priority != null) {
 queryParams['priority'] = priority.name.toUpperCase();
 }
 if (requesterId != null) {
 queryParams['requesterId'] = requesterId;
 }
 if (department != null) {
 queryParams['department'] = department;
 }
 if (startDate != null) {
 queryParams['startDate'] = startDate.toIso8601String();
 }
 if (endDate != null) {
 queryParams['endDate'] = endDate.toIso8601String();
 }
 if (minAmount != null) {
 queryParams['minAmount'] = minAmount.toString();
 }
 if (maxAmount != null) {
 queryParams['maxAmount'] = maxAmount.toString();
 }
 if (search != null && search.isNotEmpty) {
 queryParams['search'] = search;
 }

 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl', queryParams: queryParams);
 
 if (response.data['success'] == true) {
 final List<String> data = response.data['data']['requests'];
 final requests = data.map((json) => PurchaseRequest.fromJson(json)).toList();
 
 return ApiResponse.success(
 data: requests,
 message: response.data['message'] ?? 'Demandes d\'achat récupérées avec succès',
 pagination: response.data['data']['pagination'],
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des demandes d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer une demande d'achat par son ID
 Future<ApiResponse<PurchaseRequest>> getPurchaseRequestById(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/$id');
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Demande d\'achat récupérée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Demande d\'achat non trouvée',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Créer une nouvelle demande d'achat
 Future<ApiResponse<PurchaseRequest>> createPurchaseRequest(
 Map<String, dynamic> requestData,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl', requestData);
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Demande d\'achat créée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la création de la demande d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Mettre à jour une demande d'achat
 Future<ApiResponse<PurchaseRequest>> updatePurchaseRequest(
 String id,
 Map<String, dynamic> requestData,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put('$_baseUrl/$id', requestData);
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Demande d\'achat mise à jour avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la mise à jour de la demande d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Supprimer une demande d'achat
 Future<ApiResponse<bool>> deletePurchaseRequest(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('$_baseUrl/$id');
 
 if (response.data['success'] == true) {
 return ApiResponse.success(
 data: true,
 message: response.data['message'] ?? 'Demande d\'achat supprimée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la suppression de la demande d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Soumettre une demande d'achat pour approbation
 Future<ApiResponse<PurchaseRequest>> submitPurchaseRequest(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/submit', {});
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Demande d\'achat soumise avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la soumission de la demande d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Approuver une demande d'achat
 Future<ApiResponse<PurchaseRequest>> approvePurchaseRequest(
 String id,
 String comments,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/approve', {
 'comments': comments,
 });
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Demande d\'achat approuvée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de l\'approbation de la demande d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Rejeter une demande d'achat
 Future<ApiResponse<PurchaseRequest>> rejectPurchaseRequest(
 String id,
 String reason,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/reject', {
 'rejectionReason': reason,
 });
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Demande d\'achat rejetée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors du rejet de la demande d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Annuler une demande d'achat
 Future<ApiResponse<PurchaseRequest>> cancelPurchaseRequest(
 String id,
 String reason,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/cancel', {
 'cancellationReason': reason,
 });
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Demande d\'achat annulée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de l\'annulation de la demande d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Mettre en attente une demande d'achat
 Future<ApiResponse<PurchaseRequest>> putOnHoldPurchaseRequest(
 String id,
 String reason,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/hold', {
 'holdReason': reason,
 });
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Demande d\'achat mise en attente avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la mise en attente de la demande d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Ajouter un élément à une demande d'achat
 Future<ApiResponse<PurchaseRequest>> addItemToPurchaseRequest(
 String id,
 Map<String, dynamic> itemData,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/items', itemData);
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Élément ajouté avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de l\'ajout de l\'élément',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Supprimer un élément d'une demande d'achat
 Future<ApiResponse<PurchaseRequest>> removeItemFromPurchaseRequest(
 String id,
 String itemId,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('$_baseUrl/$id/items/$itemId');
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Élément supprimé avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la suppression de l\'élément',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Ajouter une pièce jointe à une demande d'achat
 Future<ApiResponse<PurchaseRequest>> addAttachmentToPurchaseRequest(
 String id,
 Map<String, dynamic> attachmentData,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/attachments', attachmentData);
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Pièce jointe ajoutée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de l\'ajout de la pièce jointe',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Supprimer une pièce jointe d'une demande d'achat
 Future<ApiResponse<PurchaseRequest>> removeAttachmentFromPurchaseRequest(
 String id,
 String attachmentId,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('$_baseUrl/$id/attachments/$attachmentId');
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Pièce jointe supprimée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la suppression de la pièce jointe',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les statistiques des demandes d'achat
 Future<ApiResponse<Map<String, dynamic>>> getPurchaseRequestStats({
 String? department,
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 try {
 final queryParams = <String, String>{};
 
 if (department != null) {
 queryParams['department'] = department;
 }
 if (startDate != null) {
 queryParams['startDate'] = startDate.toIso8601String();
 }
 if (endDate != null) {
 queryParams['endDate'] = endDate.toIso8601String();
 }

 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/stats', queryParams: queryParams);
 
 if (response.data['success'] == true) {
 return ApiResponse.success(
 data: response.data['data'],
 message: response.data['message'] ?? 'Statistiques récupérées avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des statistiques',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les workflows d'approbation disponibles
 Future<ApiResponse<List<Map<String, dynamic>>>> getApprovalWorkflows() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/workflows');
 
 if (response.data['success'] == true) {
 final List<String> data = response.data['data'];
 final workflows = data.cast<Map<String, dynamic>>();
 
 return ApiResponse.success(
 data: workflows,
 message: response.data['message'] ?? 'Workflows récupérés avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des workflows',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Exporter les demandes d'achat
 Future<ApiResponse<String>> exportPurchaseRequests({
 PurchaseRequestStatus? status,
 PurchaseRequestType? type,
 DateTime? startDate,
 DateTime? endDate,
 String format = 'excel',
 }) async {
 try {
 final queryParams = <String, String>{
 'format': format,
 };

 if (status != null) {
 queryParams['status'] = status.name.toUpperCase();
 }
 if (type != null) {
 queryParams['type'] = type.name.toUpperCase();
 }
 if (startDate != null) {
 queryParams['startDate'] = startDate.toIso8601String();
 }
 if (endDate != null) {
 queryParams['endDate'] = endDate.toIso8601String();
 }

 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/export', queryParams: queryParams);
 
 if (response.data['success'] == true) {
 return ApiResponse.success(
 data: response.data['data']['downloadUrl'],
 message: response.data['message'] ?? 'Export généré avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de l\'export des demandes d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Dupliquer une demande d'achat
 Future<ApiResponse<PurchaseRequest>> duplicatePurchaseRequest(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/duplicate', {});
 
 if (response.data['success'] == true) {
 final request = PurchaseRequest.fromJson(response.data['data']);
 return ApiResponse.success(
 data: request,
 message: response.data['message'] ?? 'Demande d\'achat dupliquée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la duplication de la demande d\'achat',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les suggestions de produits basées sur l'historique
 Future<ApiResponse<List<Map<String, dynamic>>>> getProductSuggestions({
 String? category,
 String? search,
 int limit = 10,
 }) async {
 try {
 final queryParams = <String, String>{
 'limit': limit.toString(),
 };

 if (category != null) {
 queryParams['category'] = category;
 }
 if (search != null && search.isNotEmpty) {
 queryParams['search'] = search;
 }

 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/suggestions/products', queryParams: queryParams);
 
 if (response.data['success'] == true) {
 final List<String> data = response.data['data'];
 final suggestions = data.cast<Map<String, dynamic>>();
 
 return ApiResponse.success(
 data: suggestions,
 message: response.data['message'] ?? 'Suggestions récupérées avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des suggestions',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les suggestions de fournisseurs pour un produit
 Future<ApiResponse<List<Map<String, dynamic>>>> getSupplierSuggestions(
 String productId,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/suggestions/suppliers/$productId');
 
 if (response.data['success'] == true) {
 final List<String> data = response.data['data'];
 final suggestions = data.cast<Map<String, dynamic>>();
 
 return ApiResponse.success(
 data: suggestions,
 message: response.data['message'] ?? 'Suggestions de fournisseurs récupérées avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des suggestions de fournisseurs',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }
}

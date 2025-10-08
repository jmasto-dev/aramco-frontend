import 'dart:io';
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/tax_declaration.dart';
import 'api_service.dart';

class TaxService {
 final ApiService _apiService = ApiService();
 static const String _baseUrl = '/tax';

 // Récupérer toutes les déclarations fiscales
 Future<ApiResponse<List<TaxDeclaration>>> getTaxDeclarations({
 TaxDeclarationType? type,
 TaxDeclarationStatus? status,
 DateTime? startDate,
 DateTime? endDate,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'page': page,
 'limit': limit,
 };

 if (type != null) {
 queryParams['type'] = type.name;
 }
 if (status != null) {
 queryParams['status'] = status.name;
 }
 if (startDate != null) {
 queryParams['start_date'] = startDate.toIso8601String();
 }
 if (endDate != null) {
 queryParams['end_date'] = endDate.toIso8601String();
 }

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/declarations',
 queryParameters: queryParams,
 );
 
 if (response.success && response.data != null) {
 final List<String> data = response.data!['declarations'] ?? [];
 final declarations = data.map((json) => TaxDeclaration.fromJson(json)).toList();
 
 return ApiResponse.success(
 data: declarations,
 message: response.message ?? 'Déclarations récupérées avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la récupération des déclarations',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer une déclaration fiscale par ID
 Future<ApiResponse<TaxDeclaration>> getTaxDeclarationById(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/declarations/$id',
 );
 
 if (response.success && response.data != null) {
 final declaration = TaxDeclaration.fromJson(response.data!);
 return ApiResponse.success(
 data: declaration,
 message: response.message ?? 'Déclaration récupérée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Déclaration non trouvée',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Créer une nouvelle déclaration fiscale
 Future<ApiResponse<TaxDeclaration>> createTaxDeclaration(Map<String, dynamic> declarationData) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/declarations',
 data: declarationData,
 );
 
 if (response.success && response.data != null) {
 final declaration = TaxDeclaration.fromJson(response.data!);
 return ApiResponse.success(
 data: declaration,
 message: response.message ?? 'Déclaration créée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la création de la déclaration',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Mettre à jour une déclaration fiscale
 Future<ApiResponse<TaxDeclaration>> updateTaxDeclaration(String id, Map<String, dynamic> declarationData) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put<Map<String, dynamic>>(
 '$_baseUrl/declarations/$id',
 data: declarationData,
 );
 
 if (response.success && response.data != null) {
 final declaration = TaxDeclaration.fromJson(response.data!);
 return ApiResponse.success(
 data: declaration,
 message: response.message ?? 'Déclaration mise à jour avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la mise à jour de la déclaration',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Supprimer une déclaration fiscale
 Future<ApiResponse<bool>> deleteTaxDeclaration(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete<Map<String, dynamic>>(
 '$_baseUrl/declarations/$id',
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: true,
 message: response.message ?? 'Déclaration supprimée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la suppression de la déclaration',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Soumettre une déclaration fiscale
 Future<ApiResponse<TaxDeclaration>> submitTaxDeclaration(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/declarations/$id/submit',
 data: {},
 );
 
 if (response.success && response.data != null) {
 final declaration = TaxDeclaration.fromJson(response.data!);
 return ApiResponse.success(
 data: declaration,
 message: response.message ?? 'Déclaration soumise avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la soumission de la déclaration',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Approuver une déclaration fiscale
 Future<ApiResponse<TaxDeclaration>> approveTaxDeclaration(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/declarations/$id/approve',
 data: {},
 );
 
 if (response.success && response.data != null) {
 final declaration = TaxDeclaration.fromJson(response.data!);
 return ApiResponse.success(
 data: declaration,
 message: response.message ?? 'Déclaration approuvée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de l\'approbation de la déclaration',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Rejeter une déclaration fiscale
 Future<ApiResponse<TaxDeclaration>> rejectTaxDeclaration(String id, String reason) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/declarations/$id/reject',
 data: {'reason': reason},
 );
 
 if (response.success && response.data != null) {
 final declaration = TaxDeclaration.fromJson(response.data!);
 return ApiResponse.success(
 data: declaration,
 message: response.message ?? 'Déclaration rejetée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors du rejet de la déclaration',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Marquer une déclaration comme payée
 Future<ApiResponse<TaxDeclaration>> markAsPaid(String id, Map<String, dynamic> paymentData) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/declarations/$id/pay',
 data: paymentData,
 );
 
 if (response.success && response.data != null) {
 final declaration = TaxDeclaration.fromJson(response.data!);
 return ApiResponse.success(
 data: declaration,
 message: response.message ?? 'Paiement enregistré avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de l\'enregistrement du paiement',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les taux d'imposition
 Future<ApiResponse<List<TaxRate>>> getTaxRates() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/rates',
 );
 
 if (response.success && response.data != null) {
 final List<String> data = response.data!['rates'] ?? [];
 final rates = data.map((json) => TaxRate.fromJson(json)).toList();
 
 return ApiResponse.success(
 data: rates,
 message: response.message ?? 'Taux récupérés avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la récupération des taux',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Calculer le montant d'une taxe
 Future<ApiResponse<Map<String, dynamic>>> calculateTax({
 required TaxDeclarationType type,
 required double baseAmount,
 required TaxPeriod period,
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 try {
 final requestData = {
 'type': type.name,
 'base_amount': baseAmount,
 'period': period.name,
 };

 if (startDate != null) {
 requestData['start_date'] = startDate.toIso8601String();
 }
 if (endDate != null) {
 requestData['end_date'] = endDate.toIso8601String();
 }

 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/calculate',
 data: requestData,
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: response.data!,
 message: response.message ?? 'Calcul effectué avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors du calcul',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Générer un rapport fiscal
 Future<ApiResponse<Map<String, dynamic>>> generateTaxReport({
 TaxDeclarationType? type,
 DateTime? startDate,
 DateTime? endDate,
 String format = 'pdf',
 }) async {
 try {
 final requestData = {
 'format': format,
 };

 if (type != null) {
 requestData['type'] = type.name;
 }
 if (startDate != null) {
 requestData['start_date'] = startDate.toIso8601String();
 }
 if (endDate != null) {
 requestData['end_date'] = endDate.toIso8601String();
 }

 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/reports/generate',
 data: requestData,
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: response.data!,
 message: response.message ?? 'Rapport généré avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la génération du rapport',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les échéances à venir
 Future<ApiResponse<List<TaxDeclaration>>> getUpcomingDeadlines({int days = 30}) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/deadlines',
 queryParameters: {'days': days},
 );
 
 if (response.success && response.data != null) {
 final List<String> data = response.data!['deadlines'] ?? [];
 final declarations = data.map((json) => TaxDeclaration.fromJson(json)).toList();
 
 return ApiResponse.success(
 data: declarations,
 message: response.message ?? 'Échéances récupérées avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la récupération des échéances',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Télécharger un document fiscal
 Future<ApiResponse<String>> downloadTaxDocument(String declarationId, String documentId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/declarations/$declarationId/documents/$documentId/download',
 );
 
 if (response.success && response.data != null) {
 return ApiResponse.success(
 data: response.data!['url'] ?? '',
 message: response.message ?? 'URL de téléchargement générée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la génération de l\'URL de téléchargement',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Uploader un document fiscal
 Future<ApiResponse<TaxDocument>> uploadTaxDocument(String declarationId, String filePath) async {
 try {
 final file = File(filePath);
 final response = await _apiService.uploadFile<Map<String, dynamic>>(
 '$_baseUrl/declarations/$declarationId/documents',
 file,
 );
 
 if (response.success && response.data != null) {
 final document = TaxDocument.fromJson(response.data!);
 return ApiResponse.success(
 data: document,
 message: response.message ?? 'Document uploadé avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de l\'upload du document',
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }
}

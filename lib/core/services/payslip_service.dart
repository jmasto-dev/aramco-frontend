import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aramco_frontend/core/models/api_response.dart';
import 'package:aramco_frontend/core/models/payslip.dart';
import 'package:aramco_frontend/core/services/api_service.dart';
import 'package:aramco_frontend/core/utils/constants.dart';

class PayslipService {
 final ApiService _apiService;
 final String _baseUrl;

 PayslipService({ApiService? apiService})
 : _apiService = apiService ?? ApiService(),
 _baseUrl = AppConstants.apiBaseUrl;

 /// Récupère la liste des fiches de paie
 Future<ApiResponse<List<Payslip>>> getPayslips({
 int page = 1,
 int limit = 20,
 String? employeeId,
 String? department,
 String? status,
 int? year,
 int? month,
 String? search,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'page': page,
 'limit': limit,
 };

 if (employeeId != null) q{ueryParams['employeeId'] = employeeId;
 if (department != null) q{ueryParams['department'] = department;
 if (status != null) q{ueryParams['status'] = status;
 if (year != null) q{ueryParams['year'] = year;
 if (month != null) q{ueryParams['month'] = month;
 if (search != null && search.isNotEmpty) q{ueryParams['search'] = search;

 final ApiResponse<dynamic> response = await _apiService.get('/payslips', queryParameters: queryParams);

 if (response.data['success'] == true) {
 final List<String> data = response.data['data']['payslips'] ?? [];
 final payslips = data.map((json) => Payslip.fromJson(json)).toList();
 
 return ApiResponse<List<Payslip>>.success(
 data: payslips,
 message: response.data['message'] ?? 'Fiches de paie récupérées avec succès',
 pagination: response.data['data']['pagination'],
 );
 } else {
 return ApiResponse<List<Payslip>>.failure(
 message: response.data['message'] ?? 'Échec de la récupération des fiches de paie',
 );
 }
} catch (e) {
 return ApiResponse<List<Payslip>>.failure(
 message: 'Erreur lors de la récupération des fiches de paie: $e',
 );
}
 }

 /// Récupère une fiche de paie par son ID
 Future<ApiResponse<Payslip>> getPayslipById(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('/payslips/$id');

 if (response.data['success'] == true) {
 final payslip = Payslip.fromJson(response.data['data']);
 
 return ApiResponse<Payslip>.success(
 data: payslip,
 message: response.data['message'] ?? 'Fiche de paie récupérée avec succès',
 );
 } else {
 return ApiResponse<Payslip>.failure(
 message: response.data['message'] ?? 'Fiche de paie non trouvée',
 );
 }
} catch (e) {
 return ApiResponse<Payslip>.failure(
 message: 'Erreur lors de la récupération de la fiche de paie: $e',
 );
}
 }

 /// Récupère les fiches de paie d'un employé
 Future<ApiResponse<List<Payslip>>> getEmployeePayslips(
 String employeeId, {
 int? year,
 int? month,
 }) async {
 try {
 final queryParams = <String, dynamic>{};
 if (year != null) q{ueryParams['year'] = year;
 if (month != null) q{ueryParams['month'] = month;

 final ApiResponse<dynamic> response = await _apiService.get(
 '/employees/$employeeId/payslips',
 queryParameters: queryParams,
 );

 if (response.data['success'] == true) {
 final List<String> data = response.data['data'] ?? [];
 final payslips = data.map((json) => Payslip.fromJson(json)).toList();
 
 return ApiResponse<List<Payslip>>.success(
 data: payslips,
 message: response.data['message'] ?? 'Fiches de paie de l\'employé récupérées avec succès',
 );
 } else {
 return ApiResponse<List<Payslip>>.failure(
 message: response.data['message'] ?? 'Échec de la récupération des fiches de paie',
 );
 }
} catch (e) {
 return ApiResponse<List<Payslip>>.failure(
 message: 'Erreur lors de la récupération des fiches de paie: $e',
 );
}
 }

 /// Crée une nouvelle fiche de paie
 Future<ApiResponse<Payslip>> createPayslip(Payslip payslip) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '/payslips',
 data: payslip.toJson(),
 );

 if (response.data['success'] == true) {
 final createdPayslip = Payslip.fromJson(response.data['data']);
 
 return ApiResponse<Payslip>.success(
 data: createdPayslip,
 message: response.data['message'] ?? 'Fiche de paie créée avec succès',
 );
 } else {
 return ApiResponse<Payslip>.failure(
 message: response.data['message'] ?? 'Échec de la création de la fiche de paie',
 );
 }
} catch (e) {
 return ApiResponse<Payslip>.failure(
 message: 'Erreur lors de la création de la fiche de paie: $e',
 );
}
 }

 /// Met à jour une fiche de paie existante
 Future<ApiResponse<Payslip>> updatePayslip(Payslip payslip) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put(
 '/payslips/${payslip.id}',
 data: payslip.toJson(),
 );

 if (response.data['success'] == true) {
 final updatedPayslip = Payslip.fromJson(response.data['data']);
 
 return ApiResponse<Payslip>.success(
 data: updatedPayslip,
 message: response.data['message'] ?? 'Fiche de paie mise à jour avec succès',
 );
 } else {
 return ApiResponse<Payslip>.failure(
 message: response.data['message'] ?? 'Échec de la mise à jour de la fiche de paie',
 );
 }
} catch (e) {
 return ApiResponse<Payslip>.failure(
 message: 'Erreur lors de la mise à jour de la fiche de paie: $e',
 );
}
 }

 /// Supprime une fiche de paie
 Future<ApiResponse<void>> deletePayslip(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('/payslips/$id');

 if (response.data['success'] == true) {
 return ApiResponse<void>.success(
 message: response.data['message'] ?? 'Fiche de paie supprimée avec succès',
 );
 } else {
 return ApiResponse<void>.failure(
 message: response.data['message'] ?? 'Échec de la suppression de la fiche de paie',
 );
 }
} catch (e) {
 return ApiResponse<void>.failure(
 message: 'Erreur lors de la suppression de la fiche de paie: $e',
 );
}
 }

 /// Approuve une fiche de paie
 Future<ApiResponse<Payslip>> approvePayslip(String id) async {
 try {
 final response = await _apiService.patch('/payslips/$id/approve');

 if (response.data['success'] == true) {
 final approvedPayslip = Payslip.fromJson(response.data['data']);
 
 return ApiResponse<Payslip>.success(
 data: approvedPayslip,
 message: response.data['message'] ?? 'Fiche de paie approuvée avec succès',
 );
 } else {
 return ApiResponse<Payslip>.failure(
 message: response.data['message'] ?? 'Échec de l\'approbation de la fiche de paie',
 );
 }
} catch (e) {
 return ApiResponse<Payslip>.failure(
 message: 'Erreur lors de l\'approbation de la fiche de paie: $e',
 );
}
 }

 /// Marque une fiche de paie comme payée
 Future<ApiResponse<Payslip>> markAsPaid(String id, {DateTime? paymentDate}) async {
 try {
 final data = <String, dynamic>{};
 if (paymentDate != null) {
 data['paymentDate'] = paymentDate.toIso8601String();
 }

 final response = await _apiService.patch(
 '/payslips/$id/mark-paid',
 data: data,
 );

 if (response.data['success'] == true) {
 final paidPayslip = Payslip.fromJson(response.data['data']);
 
 return ApiResponse<Payslip>.success(
 data: paidPayslip,
 message: response.data['message'] ?? 'Fiche de paie marquée comme payée',
 );
 } else {
 return ApiResponse<Payslip>.failure(
 message: response.data['message'] ?? 'Échec du marquage comme payée',
 );
 }
} catch (e) {
 return ApiResponse<Payslip>.failure(
 message: 'Erreur lors du marquage comme payée: $e',
 );
}
 }

 /// Annule une fiche de paie
 Future<ApiResponse<Payslip>> cancelPayslip(String id, String reason) async {
 try {
 final response = await _apiService.patch(
 '/payslips/$id/cancel',
 data: {'reason': reason},
 );

 if (response.data['success'] == true) {
 final cancelledPayslip = Payslip.fromJson(response.data['data']);
 
 return ApiResponse<Payslip>.success(
 data: cancelledPayslip,
 message: response.data['message'] ?? 'Fiche de paie annulée avec succès',
 );
 } else {
 return ApiResponse<Payslip>.failure(
 message: response.data['message'] ?? 'Échec de l\'annulation de la fiche de paie',
 );
 }
} catch (e) {
 return ApiResponse<Payslip>.failure(
 message: 'Erreur lors de l\'annulation de la fiche de paie: $e',
 );
}
 }

 /// Génère le PDF d'une fiche de paie
 Future<ApiResponse<String>> generatePayslipPdf(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('/payslips/$id/generate-pdf');

 if (response.data['success'] == true) {
 final pdfUrl = response.data['data']['pdfUrl'] as String;
 
 return ApiResponse<String>.success(
 data: pdfUrl,
 message: response.data['message'] ?? 'PDF généré avec succès',
 );
 } else {
 return ApiResponse<String>.failure(
 message: response.data['message'] ?? 'Échec de la génération du PDF',
 );
 }
} catch (e) {
 return ApiResponse<String>.failure(
 message: 'Erreur lors de la génération du PDF: $e',
 );
}
 }

 /// Envoie une fiche de paie par email
 Future<ApiResponse<void>> sendPayslipByEmail(String id, String email) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '/payslips/$id/send-email',
 data: {'email': email},
 );

 if (response.data['success'] == true) {
 return ApiResponse<void>.success(
 message: response.data['message'] ?? 'Fiche de paie envoyée par email',
 );
 } else {
 return ApiResponse<void>.failure(
 message: response.data['message'] ?? 'Échec de l\'envoi par email',
 );
 }
} catch (e) {
 return ApiResponse<void>.failure(
 message: 'Erreur lors de l\'envoi par email: $e',
 );
}
 }

 /// Récupère les statistiques des fiches de paie
 Future<ApiResponse<Map<String, dynamic>>> getPayslipStats({
 int? year,
 int? month,
 String? department,
 }) async {
 try {
 final queryParams = <String, dynamic>{};
 if (year != null) q{ueryParams['year'] = year;
 if (month != null) q{ueryParams['month'] = month;
 if (department != null) q{ueryParams['department'] = department;

 final ApiResponse<dynamic> response = await _apiService.get(
 '/payslips/stats',
 queryParameters: queryParams,
 );

 if (response.data['success'] == true) {
 return ApiResponse<Map<String, dynamic>>.success(
 data: response.data['data'],
 message: response.data['message'] ?? 'Statistiques récupérées avec succès',
 );
 } else {
 return ApiResponse<Map<String, dynamic>>.failure(
 message: response.data['message'] ?? 'Échec de la récupération des statistiques',
 );
 }
} catch (e) {
 return ApiResponse<Map<String, dynamic>>.failure(
 message: 'Erreur lors de la récupération des statistiques: $e',
 );
}
 }

 /// Recherche des fiches de paie
 Future<ApiResponse<List<Payslip>>> searchPayslips(String query) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get(
 '/payslips/search',
 queryParameters: {'q': query},
 );

 if (response.data['success'] == true) {
 final List<String> data = response.data['data'] ?? [];
 final payslips = data.map((json) => Payslip.fromJson(json)).toList();
 
 return ApiResponse<List<Payslip>>.success(
 data: payslips,
 message: response.data['message'] ?? 'Recherche effectuée avec succès',
 );
 } else {
 return ApiResponse<List<Payslip>>.failure(
 message: response.data['message'] ?? 'Échec de la recherche',
 );
 }
} catch (e) {
 return ApiResponse<List<Payslip>>.failure(
 message: 'Erreur lors de la recherche: $e',
 );
}
 }

 /// Télécharge une fiche de paie en PDF
 Future<ApiResponse<String>> downloadPayslipPdf(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('/payslips/$id/download-pdf');

 if (response.data['success'] == true) {
 final downloadUrl = response.data['data']['downloadUrl'] as String;
 
 return ApiResponse<String>.success(
 data: downloadUrl,
 message: response.data['message'] ?? 'URL de téléchargement générée',
 );
 } else {
 return ApiResponse<String>.failure(
 message: response.data['message'] ?? 'Échec de la génération de l\'URL de téléchargement',
 );
 }
} catch (e) {
 return ApiResponse<String>.failure(
 message: 'Erreur lors de la génération de l\'URL de téléchargement: $e',
 );
}
 }

 /// Valide une fiche de paie avant sauvegarde
 Future<ApiResponse<Map<String, dynamic>>> validatePayslip(Payslip payslip) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '/payslips/validate',
 data: payslip.toJson(),
 );

 if (response.data['success'] == true) {
 return ApiResponse<Map<String, dynamic>>.success(
 data: response.data['data'],
 message: response.data['message'] ?? 'Fiche de paie valide',
 );
 } else {
 return ApiResponse<Map<String, dynamic>>.failure(
 message: response.data['message'] ?? 'Fiche de paie invalide',
 );
 }
} catch (e) {
 return ApiResponse<Map<String, dynamic>>.failure(
 message: 'Erreur lors de la validation: $e',
 );
}
 }
}

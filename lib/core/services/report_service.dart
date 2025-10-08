import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/report.dart';
import 'api_service.dart';

class ReportService {
 final ApiService _apiService;
 static const String _baseUrl = '/reports';

 ReportService(this._apiService);

 // Récupérer tous les rapports
 Future<ApiResponse<List<Report>>> getReports({
 ReportCategory? category,
 ReportType? type,
 ReportStatus? status,
 String? createdBy,
 String? search,
 bool? isPublic,
 bool? isActive,
 int page = 1,
 int limit = 20,
 String sortBy = 'createdAt',
 bool sortAscending = false,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 'sortBy': sortBy,
 'sortAscending': sortAscending.toString(),
 };

 if (category != null) {
 queryParams['category'] = category.name.toUpperCase();
 }
 if (type != null) {
 queryParams['type'] = type.name.toUpperCase();
 }
 if (status != null) {
 queryParams['status'] = status.name.toUpperCase();
 }
 if (createdBy != null) {
 queryParams['createdBy'] = createdBy;
 }
 if (search != null && search.isNotEmpty) {
 queryParams['search'] = search;
 }
 if (isPublic != null) {
 queryParams['isPublic'] = isPublic.toString();
 }
 if (isActive != null) {
 queryParams['isActive'] = isActive.toString();
 }

 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl', queryParams: queryParams);
 
 if (response.data['success'] == true) {
 final List<String> data = response.data['data']['reports'];
 final reports = data.map((json) => Report.fromJson(json)).toList();
 
 return ApiResponse.success(
 data: reports,
 message: response.data['message'] ?? 'Rapports récupérés avec succès',
 pagination: response.data['data']['pagination'],
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des rapports',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer un rapport par son ID
 Future<ApiResponse<Report>> getReportById(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/$id');
 
 if (response.data['success'] == true) {
 final report = Report.fromJson(response.data['data']);
 return ApiResponse.success(
 data: report,
 message: response.data['message'] ?? 'Rapport récupéré avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Rapport non trouvé',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Créer un nouveau rapport
 Future<ApiResponse<Report>> createReport(Map<String, dynamic> reportData) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl', reportData);
 
 if (response.data['success'] == true) {
 final report = Report.fromJson(response.data['data']);
 return ApiResponse.success(
 data: report,
 message: response.data['message'] ?? 'Rapport créé avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la création du rapport',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Mettre à jour un rapport
 Future<ApiResponse<Report>> updateReport(String id, Map<String, dynamic> reportData) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put('$_baseUrl/$id', reportData);
 
 if (response.data['success'] == true) {
 final report = Report.fromJson(response.data['data']);
 return ApiResponse.success(
 data: report,
 message: response.data['message'] ?? 'Rapport mis à jour avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la mise à jour du rapport',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Supprimer un rapport
 Future<ApiResponse<bool>> deleteReport(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('$_baseUrl/$id');
 
 if (response.data['success'] == true) {
 return ApiResponse.success(
 data: true,
 message: response.data['message'] ?? 'Rapport supprimé avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la suppression du rapport',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Exécuter un rapport
 Future<ApiResponse<Map<String, dynamic>>> runReport(
 String id,
 Map<String, dynamic>? parameters,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/run', {
 'parameters': parameters ?? {},
 });
 
 if (response.data['success'] == true) {
 return ApiResponse.success(
 data: response.data['data'],
 message: response.data['message'] ?? 'Rapport exécuté avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de l\'exécution du rapport',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Planifier l'exécution d'un rapport
 Future<ApiResponse<Report>> scheduleReport(
 String id,
 Map<String, dynamic> scheduleData,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/schedule', scheduleData);
 
 if (response.data['success'] == true) {
 final report = Report.fromJson(response.data['data']);
 return ApiResponse.success(
 data: report,
 message: response.data['message'] ?? 'Rapport planifié avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la planification du rapport',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Annuler la planification d'un rapport
 Future<ApiResponse<Report>> unscheduleReport(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/unschedule', {});
 
 if (response.data['success'] == true) {
 final report = Report.fromJson(response.data['data']);
 return ApiResponse.success(
 data: report,
 message: response.data['message'] ?? 'Planification annulée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de l\'annulation de la planification',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Dupliquer un rapport
 Future<ApiResponse<Report>> duplicateReport(String id, String newName) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/duplicate', {
 'name': newName,
 });
 
 if (response.data['success'] == true) {
 final report = Report.fromJson(response.data['data']);
 return ApiResponse.success(
 data: report,
 message: response.data['message'] ?? 'Rapport dupliqué avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la duplication du rapport',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Partager un rapport
 Future<ApiResponse<Report>> shareReport(String id, List<String> userIds) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/share', {
 'userIds': userIds,
 });
 
 if (response.data['success'] == true) {
 final report = Report.fromJson(response.data['data']);
 return ApiResponse.success(
 data: report,
 message: response.data['message'] ?? 'Rapport partagé avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors du partage du rapport',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Exporter un rapport
 Future<ApiResponse<String>> exportReport(
 String id,
 ReportExportFormat format,
 Map<String, dynamic>? parameters,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/$id/export', {
 'format': format.name.toUpperCase(),
 'parameters': parameters ?? {},
 });
 
 if (response.data['success'] == true) {
 return ApiResponse.success(
 data: response.data['data']['downloadUrl'],
 message: response.data['message'] ?? 'Export généré avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de l\'export du rapport',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer l'historique d'exécution d'un rapport
 Future<ApiResponse<List<Map<String, dynamic>>>> getReportExecutionHistory(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/$id/history');
 
 if (response.data['success'] == true) {
 final List<String> data = response.data['data'];
 final history = data.cast<Map<String, dynamic>>();
 
 return ApiResponse.success(
 data: history,
 message: response.data['message'] ?? 'Historique récupéré avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération de l\'historique',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les modèles de rapports
 Future<ApiResponse<List<Map<String, dynamic>>>> getReportTemplates() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/templates');
 
 if (response.data['success'] == true) {
 final List<String> data = response.data['data'];
 final templates = data.cast<Map<String, dynamic>>();
 
 return ApiResponse.success(
 data: templates,
 message: response.data['message'] ?? 'Modèles récupérés avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des modèles',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Créer un rapport à partir d'un modèle
 Future<ApiResponse<Report>> createReportFromTemplate(
 String templateId,
 Map<String, dynamic> reportData,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/templates/$templateId/create', reportData);
 
 if (response.data['success'] == true) {
 final report = Report.fromJson(response.data['data']);
 return ApiResponse.success(
 data: report,
 message: response.data['message'] ?? 'Rapport créé à partir du modèle avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la création du rapport à partir du modèle',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les sources de données disponibles
 Future<ApiResponse<List<Map<String, dynamic>>>> getDataSources() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/data-sources');
 
 if (response.data['success'] == true) {
 final List<String> data = response.data['data'];
 final dataSources = data.cast<Map<String, dynamic>>();
 
 return ApiResponse.success(
 data: dataSources,
 message: response.data['message'] ?? 'Sources de données récupérées avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des sources de données',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Tester une source de données
 Future<ApiResponse<Map<String, dynamic>>> testDataSource(Map<String, dynamic> dataSourceConfig) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post('$_baseUrl/data-sources/test', dataSourceConfig);
 
 if (response.data['success'] == true) {
 return ApiResponse.success(
 data: response.data['data'],
 message: response.data['message'] ?? 'Source de données testée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors du test de la source de données',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Récupérer les statistiques des rapports
 Future<ApiResponse<Map<String, dynamic>>> getReportStats({
 String? userId,
 ReportCategory? category,
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 try {
 final queryParams = <String, String>{};
 
 if (userId != null) {
 queryParams['userId'] = userId;
 }
 if (category != null) {
 queryParams['category'] = category.name.toUpperCase();
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

 // Récupérer les rapports partagés avec l'utilisateur
 Future<ApiResponse<List<Report>>> getSharedReports({
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 final ApiResponse<dynamic> response = await _apiService.get('$_baseUrl/shared', queryParams: queryParams);
 
 if (response.data['success'] == true) {
 final List<String> data = response.data['data']['reports'];
 final reports = data.map((json) => Report.fromJson(json)).toList();
 
 return ApiResponse.success(
 data: reports,
 message: response.data['message'] ?? 'Rapports partagés récupérés avec succès',
 pagination: response.data['data']['pagination'],
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des rapports partagés',
 errors: response['errors'],
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Activer/Désactiver un rapport
 Future<ApiResponse<Report>> toggleReport(String id, bool isActive) async {
 try {
 final response = await _apiService.patch('$_baseUrl/$id/toggle', {
 'isActive': isActive,
 });
 
 if (response.data['success'] == true) {
 final report = Report.fromJson(response.data['data']);
 return ApiResponse.success(
 data: report,
 message: response.data['message'] ?? 'Rapport mis à jour avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.data['message'] ?? 'Erreur lors de la mise à jour du rapport',
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

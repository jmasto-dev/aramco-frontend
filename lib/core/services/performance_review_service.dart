import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:aramco_frontend/core/models/performance_review.dart';
import 'package:aramco_frontend/core/models/api_response.dart';
import 'package:aramco_frontend/core/services/api_service.dart';
import 'package:aramco_frontend/core/services/storage_service.dart';
import 'package:aramco_frontend/core/utils/constants.dart';

/// Service pour la gestion des évaluations de performance
class PerformanceReviewService {
 final ApiService _apiService;
 final StorageService _storageService;
 
 PerformanceReviewService({
 required ApiService apiService,
 required StorageService storageService,
 }) : _apiService = apiService,
 _storageService = storageService;

 /// Récupérer toutes les évaluations
 Future<ApiResponse<List<PerformanceReview>>> getReviews({
 String? employeeId,
 String? reviewerId,
 ReviewStatus? status,
 ReviewType? type,
 String? period,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };
 
 if (employeeId != null) q{ueryParams['employeeId'] = employeeId;
 if (reviewerId != null) q{ueryParams['reviewerId'] = reviewerId;
 if (status != null) q{ueryParams['status'] = status.name;
 if (type != null) q{ueryParams['type'] = type.name;
 if (period != null) q{ueryParams['period'] = period;

 final ApiResponse<dynamic> response = await _apiService.get(
 AppConstants.performanceReviewsEndpoint,
 queryParameters: queryParams,
 );

 if (response.isSuccess) {
 final data = response.data as Map<String, dynamic>;
 final reviewsJson = data['reviews'] as List;
 final reviews = reviewsJson
 .map((json) => PerformanceReview.fromJson(json))
 .toList();

 return ApiResponse.success(
 data: reviews,
 message: 'Évaluations récupérées avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la récupération des évaluations',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Récupérer une évaluation par son ID
 Future<ApiResponse<PerformanceReview>> getReviewById(String reviewId) async {
 try {
 // Vérifier d'abord le cache local
 final cachedReview = await _getCachedReview(reviewId);
 if (cachedReview != null) {
 return ApiResponse.success(
 data: cachedReview,
 message: 'Évaluation récupérée depuis le cache',
 );
 }

 final ApiResponse<dynamic> response = await _apiService.get(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId',
 );

 if (response.isSuccess) {
 final review = PerformanceReview.fromJson(response.data);
 
 // Mettre en cache
 await _cacheReview(review);
 
 return ApiResponse.success(
 data: review,
 message: 'Évaluation récupérée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Évaluation non trouvée',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Créer une nouvelle évaluation
 Future<ApiResponse<PerformanceReview>> createReview({
 required String employeeId,
 required String reviewerId,
 required String reviewPeriod,
 required ReviewType reviewType,
 List<Competency>? competencies,
 List<SmartGoal>? goals,
 }) async {
 try {
 final reviewData = {
 'employeeId': employeeId,
 'reviewerId': reviewerId,
 'reviewPeriod': reviewPeriod,
 'reviewType': reviewType.name,
 'status': ReviewStatus.draft.name,
 'competencies': competencies?.map((c) => c.toJson()).toList() ?? [],
 'goals': goals?.map((g) => g.toJson()).toList() ?? [],
 };

 final ApiResponse<dynamic> response = await _apiService.post(
 AppConstants.performanceReviewsEndpoint,
 data: reviewData,
 );

 if (response.isSuccess) {
 final review = PerformanceReview.fromJson(response.data);
 
 // Mettre en cache
 await _cacheReview(review);
 
 return ApiResponse.success(
 data: review,
 message: 'Évaluation créée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la création de l\'évaluation',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Mettre à jour une évaluation
 Future<ApiResponse<PerformanceReview>> updateReview(
 String reviewId,
 PerformanceReview review,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId',
 data: review.toJson(),
 );

 if (response.isSuccess) {
 final updatedReview = PerformanceReview.fromJson(response.data);
 
 // Mettre à jour le cache
 await _cacheReview(updatedReview);
 
 return ApiResponse.success(
 data: updatedReview,
 message: 'Évaluation mise à jour avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la mise à jour de l\'évaluation',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Mettre à jour les compétences d'une évaluation
 Future<ApiResponse<PerformanceReview>> updateCompetencies(
 String reviewId,
 List<Competency> competencies,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId/competencies',
 data: {'competencies': competencies.map((c) => c.toJson()).toList()},
 );

 if (response.isSuccess) {
 final updatedReview = PerformanceReview.fromJson(response.data);
 await _cacheReview(updatedReview);
 
 return ApiResponse.success(
 data: updatedReview,
 message: 'Compétences mises à jour avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la mise à jour des compétences',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Mettre à jour les objectifs d'une évaluation
 Future<ApiResponse<PerformanceReview>> updateGoals(
 String reviewId,
 List<SmartGoal> goals,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId/goals',
 data: {'goals': goals.map((g) => g.toJson()).toList()},
 );

 if (response.isSuccess) {
 final updatedReview = PerformanceReview.fromJson(response.data);
 await _cacheReview(updatedReview);
 
 return ApiResponse.success(
 data: updatedReview,
 message: 'Objectifs mis à jour avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la mise à jour des objectifs',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Soumettre une évaluation
 Future<ApiResponse<PerformanceReview>> submitReview(String reviewId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId/submit',
 data: {'submittedAt': DateTime.now().toIso8601String()},
 );

 if (response.isSuccess) {
 final submittedReview = PerformanceReview.fromJson(response.data);
 await _cacheReview(submittedReview);
 
 return ApiResponse.success(
 data: submittedReview,
 message: 'Évaluation soumise avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la soumission de l\'évaluation',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Approuver une évaluation
 Future<ApiResponse<PerformanceReview>> approveReview(
 String reviewId, {
 String? comments,
 }) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId/approve',
 data: {
 'approvedAt': DateTime.now().toIso8601String(),
 'comments': comments,
 },
 );

 if (response.isSuccess) {
 final approvedReview = PerformanceReview.fromJson(response.data);
 await _cacheReview(approvedReview);
 
 return ApiResponse.success(
 data: approvedReview,
 message: 'Évaluation approuvée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de l\'approbation de l\'évaluation',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Rejeter une évaluation
 Future<ApiResponse<PerformanceReview>> rejectReview(
 String reviewId, {
 required String reason,
 }) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId/reject',
 data: {
 'rejectedAt': DateTime.now().toIso8601String(),
 'rejectionReason': reason,
 },
 );

 if (response.isSuccess) {
 final rejectedReview = PerformanceReview.fromJson(response.data);
 await _cacheReview(rejectedReview);
 
 return ApiResponse.success(
 data: rejectedReview,
 message: 'Évaluation rejetée',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors du rejet de l\'évaluation',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Ajouter une signature à une évaluation
 Future<ApiResponse<PerformanceReview>> addSignature(
 String reviewId, {
 required String signerName,
 required String signerRole,
 String? comments,
 }) async {
 try {
 final signatureData = {
 'signerName': signerName,
 'signerRole': signerRole,
 'signedAt': DateTime.now().toIso8601String(),
 'comments': comments,
 };

 final ApiResponse<dynamic> response = await _apiService.post(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId/signatures',
 data: signatureData,
 );

 if (response.isSuccess) {
 final updatedReview = PerformanceReview.fromJson(response.data);
 await _cacheReview(updatedReview);
 
 return ApiResponse.success(
 data: updatedReview,
 message: 'Signature ajoutée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de l\'ajout de la signature',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Supprimer une évaluation
 Future<ApiResponse<void>> deleteReview(String reviewId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId',
 );

 if (response.isSuccess) {
 // Supprimer du cache
 await _removeCachedReview(reviewId);
 
 return ApiResponse.success(
 message: 'Évaluation supprimée avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la suppression de l\'évaluation',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Exporter une évaluation en PDF
 Future<ApiResponse<String>> exportToPDF(String reviewId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get(
 '${AppConstants.performanceReviewsEndpoint}/$reviewId/export/pdf',
 );

 if (response.isSuccess) {
 return ApiResponse.success(
 data: response.data['downloadUrl'],
 message: 'PDF généré avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la génération du PDF',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Récupérer les statistiques des évaluations
 Future<ApiResponse<Map<String, dynamic>>> getReviewStatistics({
 String? departmentId,
 String? period,
 ReviewType? type,
 }) async {
 try {
 final queryParams = <String, String>{};
 if (departmentId != null) q{ueryParams['departmentId'] = departmentId;
 if (period != null) q{ueryParams['period'] = period;
 if (type != null) q{ueryParams['type'] = type.name;

 final ApiResponse<dynamic> response = await _apiService.get(
 '${AppConstants.performanceReviewsEndpoint}/statistics',
 queryParameters: queryParams,
 );

 if (response.isSuccess) {
 return ApiResponse.success(
 data: response.data,
 message: 'Statistiques récupérées avec succès',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Erreur lors de la récupération des statistiques',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Synchroniser les évaluations locales avec le serveur
 Future<ApiResponse<List<PerformanceReview>>> syncReviews() async {
 try {
 final cachedReviews = await _getAllCachedReviews();
 final syncedReviews = <PerformanceReview>[];
 
 for (final review in cachedReviews) {
 if (review.status == ReviewStatus.draft) {
 // Synchroniser les brouillons
 final response = await updateReview(review.id, review);
 if (response.isSuccess) {
 syncedReviews.add(response.data!);
}
 }
 }

 return ApiResponse.success(
 data: syncedReviews,
 message: '${syncedReviews.length} évaluation(s) synchronisée(s)',
 );
} catch (e) {
 return ApiResponse.error(
 message: 'Erreur lors de la synchronisation: ${e.toString()}',
 statusCode: 500,
 );
}
 }

 /// Mettre en cache une évaluation
 Future<void> _cacheReview(PerformanceReview review) {async {
 try {
 await _storageService.setString(
 'performance_review_${review.id}',
 jsonEncode(review.toJson()),
 );
} catch (e) {
 // Ignorer les erreurs de cache
;
 }

 /// Récupérer une évaluation depuis le cache
 Future<PerformanceReview?> _getCachedReview(String reviewId) async {
 try {
 final cachedData = await _storageService.getString('performance_review_$reviewId');
 if (cachedData != null) {
 return PerformanceReview.fromJson(jsonDecode(cachedData));
 }
 return null;
} catch (e) {
 return null;
}
 }

 /// Récupérer toutes les évaluations en cache
 Future<List<PerformanceReview>> _getAllCachedReviews() async {
 try {
 // Pour l'instant, retourne une liste vide car getAllKeys n'existe pas
 // TODO: Implémenter une méthode pour récupérer les clés de List<cache
> return;
} catch (e) {
 return [];
}
 }

 /// Supprimer une évaluation du cache
 Future<void> _removeCachedReview(String reviewId) {async {
 try {
 await _storageService.remove('performance_review_$reviewId');
} catch (e) {
 // Ignorer les erreurs de cache
;
 }

 /// Vider le cache des évaluations
 Future<void> clearCache() {async {
 try {
 // Pour l'instant, ne fait rien car getAllKeys n'existe pas
 // TODO: Implémenter une méthode pour vider le cache des évaluations
; catch (e) {
 // Ignorer les erreurs de cache
;
 }
}

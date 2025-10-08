import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:aramco_frontend/core/models/performance_review.dart';
import 'package:aramco_frontend/core/models/api_response.dart';
import 'package:aramco_frontend/core/services/performance_review_service.dart';
import 'package:aramco_frontend/core/services/api_service.dart';
import 'package:aramco_frontend/core/services/storage_service.dart';

/// État du provider d'évaluations de performance
class \1 extends ChangeNotifier {
 final List<PerformanceReview> reviews;
 final PerformanceReview? currentReview;
 final bool isLoading;
 final bool isCreating;
 final bool isUpdating;
 final bool isDeleting;
 final bool isSubmitting;
 final bool isApproving;
 final bool isRejecting;
 final String? error;
 final String? successMessage;
 final int currentPage;
 final int totalPages;
 final int totalCount;
 final ReviewStatus? statusFilter;
 final ReviewType? typeFilter;
 final String? periodFilter;
 final String? employeeIdFilter;
 final String? reviewerIdFilter;
 final Map<String, dynamic>? statistics;

 const PerformanceReviewState({
 this.reviews = const [],
 this.currentReview,
 this.isLoading = false,
 this.isCreating = false,
 this.isUpdating = false,
 this.isDeleting = false,
 this.isSubmitting = false,
 this.isApproving = false,
 this.isRejecting = false,
 this.error,
 this.successMessage,
 this.currentPage = 1,
 this.totalPages = 1,
 this.totalCount = 0,
 this.statusFilter,
 this.typeFilter,
 this.periodFilter,
 this.employeeIdFilter,
 this.reviewerIdFilter,
 this.statistics,
 });

 PerformanceReviewState copyWith({
 List<PerformanceReview>? reviews,
 PerformanceReview? currentReview,
 bool? isLoading,
 bool? isCreating,
 bool? isUpdating,
 bool? isDeleting,
 bool? isSubmitting,
 bool? isApproving,
 bool? isRejecting,
 String? error,
 String? successMessage,
 int? currentPage,
 int? totalPages,
 int? totalCount,
 ReviewStatus? statusFilter,
 ReviewType? typeFilter,
 String? periodFilter,
 String? employeeIdFilter,
 String? reviewerIdFilter,
 Map<String, dynamic>? statistics,
 bool clearError = false,
 bool clearSuccessMessage = false,
 }) {
 return PerformanceReviewState(
 reviews: reviews ?? this.reviews,
 currentReview: currentReview ?? this.currentReview,
 isLoading: isLoading ?? this.isLoading,
 isCreating: isCreating ?? this.isCreating,
 isUpdating: isUpdating ?? this.isUpdating,
 isDeleting: isDeleting ?? this.isDeleting,
 isSubmitting: isSubmitting ?? this.isSubmitting,
 isApproving: isApproving ?? this.isApproving,
 isRejecting: isRejecting ?? this.isRejecting,
 error: clearError ? null : (error ?? this.error),
 successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
 currentPage: currentPage ?? this.currentPage,
 totalPages: totalPages ?? this.totalPages,
 totalCount: totalCount ?? this.totalCount,
 statusFilter: statusFilter ?? this.statusFilter,
 typeFilter: typeFilter ?? this.typeFilter,
 periodFilter: periodFilter ?? this.periodFilter,
 employeeIdFilter: employeeIdFilter ?? this.employeeIdFilter,
 reviewerIdFilter: reviewerIdFilter ?? this.reviewerIdFilter,
 statistics: statistics ?? this.statistics,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is PerformanceReviewState &&
 listEquals(other.reviews, reviews) &&
 other.currentReview == currentReview &&
 other.isLoading == isLoading &&
 other.isCreating == isCreating &&
 other.isUpdating == isUpdating &&
 other.isDeleting == isDeleting &&
 other.isSubmitting == isSubmitting &&
 other.isApproving == isApproving &&
 other.isRejecting == isRejecting &&
 other.error == error &&
 other.successMessage == successMessage &&
 other.currentPage == currentPage &&
 other.totalPages == totalPages &&
 other.totalCount == totalCount &&
 other.statusFilter == statusFilter &&
 other.typeFilter == typeFilter &&
 other.periodFilter == periodFilter &&
 other.employeeIdFilter == employeeIdFilter &&
 other.reviewerIdFilter == reviewerIdFilter &&
 mapEquals(other.statistics, statistics);
 }

 @override
 int get hashCode {
 return Object.hash(
 reviews,
 currentReview,
 isLoading,
 isCreating,
 isUpdating,
 isDeleting,
 isSubmitting,
 isApproving,
 isRejecting,
 error,
 successMessage,
 currentPage,
 totalPages,
 totalCount,
 statusFilter,
 typeFilter,
 periodFilter,
 employeeIdFilter,
 reviewerIdFilter,
 statistics,
 );
 }
}

/// Notifier pour la gestion des évaluations de performance
class PerformanceReviewNotifier extends StateNotifier<PerformanceReviewState> {
 final PerformanceReviewService _service;

 PerformanceReviewNotifier(this._service) : super(const PerformanceReviewState());

 /// Récupérer toutes les évaluations
 Future<void> loadReviews({
 int page = 1,
 ReviewStatus? status,
 ReviewType? type,
 String? period,
 String? employeeId,
 String? reviewerId,
 bool refresh = false,
 }) {async {
 if (refresh) {{
 state = state.copyWith(
 isLoading: true,
 clearError: true,
 clearSuccessMessage: true,
 );
} else {
 state = state.copyWith(isLoading: true, clearError: true);
}

 try {
 final response = await _service.getReviews(
 page: page,
 status: status,
 type: type,
 period: period,
 employeeId: employeeId,
 reviewerId: reviewerId,
 );

 if (response.isSuccess && response.data != null) {{
 final reviews = response.data!;
 state = state.copyWith(
 reviews: page == 1 ? reviews : [...state.reviews, ...reviews],
 isLoading: false,
 currentPage: page,
 statusFilter: status,
 typeFilter: type,
 periodFilter: period,
 employeeIdFilter: employeeId,
 reviewerIdFilter: reviewerId,
 successMessage: response.message,
 );
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.message ?? 'Erreur lors du chargement des évaluations',
 );
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 /// Récupérer une évaluation par son ID
 Future<void> loadReviewById(String reviewId) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.getReviewById(reviewId);

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 currentReview: response.data,
 isLoading: false,
 successMessage: response.message,
 );
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.message ?? 'Évaluation non trouvée',
 );
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 /// Créer une nouvelle évaluation
 Future<bool> createReview({
 required String employeeId,
 required String reviewerId,
 required String reviewPeriod,
 required ReviewType reviewType,
 List<Competency>? competencies,
 List<SmartGoal>? goals,
 }) {async {
 state = state.copyWith(isCreating: true, clearError: true, clearSuccessMessage: true);

 try {
 final response = await _service.createReview(
 employeeId: employeeId,
 reviewerId: reviewerId,
 reviewPeriod: reviewPeriod,
 reviewType: reviewType,
 competencies: competencies,
 goals: goals,
 );

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 isCreating: false,
 currentReview: response.data,
 reviews: [response.data!, ...state.reviews],
 successMessage: response.message,
 );
 return true;
 } else {
 state = state.copyWith(
 isCreating: false,
 error: response.message ?? 'Erreur lors de la création de l\'évaluation',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isCreating: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 /// Mettre à jour une évaluation
 Future<bool> updateReview(String reviewId, PerformanceReview review) {async {
 state = state.copyWith(isUpdating: true, clearError: true, clearSuccessMessage: true);

 try {
 final response = await _service.updateReview(reviewId, review);

 if (response.isSuccess && response.data != null) {{
 final updatedReview = response.data!;
 final updatedReviews = state.reviews.map((r) => r.id == reviewId ? updatedReview : r).toList();
 
 state = state.copyWith(
 isUpdating: false,
 currentReview: updatedReview,
 reviews: updatedReviews,
 successMessage: response.message,
 );
 return true;
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message ?? 'Erreur lors de la mise à jour de l\'évaluation',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 /// Mettre à jour les compétences d'une évaluation
 Future<bool> updateCompetencies(String reviewId, List<Competency> competencies) {async {
 state = state.copyWith(isUpdating: true, clearError: true, clearSuccessMessage: true);

 try {
 final response = await _service.updateCompetencies(reviewId, competencies);

 if (response.isSuccess && response.data != null) {{
 final updatedReview = response.data!;
 final updatedReviews = state.reviews.map((r) => r.id == reviewId ? updatedReview : r).toList();
 
 state = state.copyWith(
 isUpdating: false,
 currentReview: updatedReview,
 reviews: updatedReviews,
 successMessage: response.message,
 );
 return true;
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message ?? 'Erreur lors de la mise à jour des compétences',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 /// Mettre à jour les objectifs d'une évaluation
 Future<bool> updateGoals(String reviewId, List<SmartGoal> goals) {async {
 state = state.copyWith(isUpdating: true, clearError: true, clearSuccessMessage: true);

 try {
 final response = await _service.updateGoals(reviewId, goals);

 if (response.isSuccess && response.data != null) {{
 final updatedReview = response.data!;
 final updatedReviews = state.reviews.map((r) => r.id == reviewId ? updatedReview : r).toList();
 
 state = state.copyWith(
 isUpdating: false,
 currentReview: updatedReview,
 reviews: updatedReviews,
 successMessage: response.message,
 );
 return true;
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message ?? 'Erreur lors de la mise à jour des objectifs',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 /// Soumettre une évaluation
 Future<bool> submitReview(String reviewId) {async {
 state = state.copyWith(isSubmitting: true, clearError: true, clearSuccessMessage: true);

 try {
 final response = await _service.submitReview(reviewId);

 if (response.isSuccess && response.data != null) {{
 final submittedReview = response.data!;
 final updatedReviews = state.reviews.map((r) => r.id == reviewId ? submittedReview : r).toList();
 
 state = state.copyWith(
 isSubmitting: false,
 currentReview: submittedReview,
 reviews: updatedReviews,
 successMessage: response.message,
 );
 return true;
 } else {
 state = state.copyWith(
 isSubmitting: false,
 error: response.message ?? 'Erreur lors de la soumission de l\'évaluation',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isSubmitting: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 /// Approuver une évaluation
 Future<bool> approveReview(String reviewId, {String? comments}) {async {
 state = state.copyWith(isApproving: true, clearError: true, clearSuccessMessage: true);

 try {
 final response = await _service.approveReview(reviewId, comments: comments);

 if (response.isSuccess && response.data != null) {{
 final approvedReview = response.data!;
 final updatedReviews = state.reviews.map((r) => r.id == reviewId ? approvedReview : r).toList();
 
 state = state.copyWith(
 isApproving: false,
 currentReview: approvedReview,
 reviews: updatedReviews,
 successMessage: response.message,
 );
 return true;
 } else {
 state = state.copyWith(
 isApproving: false,
 error: response.message ?? 'Erreur lors de l\'approbation de l\'évaluation',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isApproving: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 /// Rejeter une évaluation
 Future<bool> rejectReview(String reviewId, {required String reason}) {async {
 state = state.copyWith(isRejecting: true, clearError: true, clearSuccessMessage: true);

 try {
 final response = await _service.rejectReview(reviewId, reason: reason);

 if (response.isSuccess && response.data != null) {{
 final rejectedReview = response.data!;
 final updatedReviews = state.reviews.map((r) => r.id == reviewId ? rejectedReview : r).toList();
 
 state = state.copyWith(
 isRejecting: false,
 currentReview: rejectedReview,
 reviews: updatedReviews,
 successMessage: response.message,
 );
 return true;
 } else {
 state = state.copyWith(
 isRejecting: false,
 error: response.message ?? 'Erreur lors du rejet de l\'évaluation',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isRejecting: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 /// Ajouter une signature à une évaluation
 Future<bool> addSignature(
 String reviewId, {
 required String signerName,
 required String signerRole,
 String? comments,
 }) {async {
 state = state.copyWith(isUpdating: true, clearError: true, clearSuccessMessage: true);

 try {
 final response = await _service.addSignature(
 reviewId,
 signerName: signerName,
 signerRole: signerRole,
 comments: comments,
 );

 if (response.isSuccess && response.data != null) {{
 final updatedReview = response.data!;
 final updatedReviews = state.reviews.map((r) => r.id == reviewId ? updatedReview : r).toList();
 
 state = state.copyWith(
 isUpdating: false,
 currentReview: updatedReview,
 reviews: updatedReviews,
 successMessage: response.message,
 );
 return true;
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message ?? 'Erreur lors de l\'ajout de la signature',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 /// Supprimer une évaluation
 Future<bool> deleteReview(String reviewId) {async {
 state = state.copyWith(isDeleting: true, clearError: true, clearSuccessMessage: true);

 try {
 final response = await _service.deleteReview(reviewId);

 if (response.isSuccess) {{
 final updatedReviews = state.reviews.where((r) => r.id != reviewId).toList();
 
 state = state.copyWith(
 isDeleting: false,
 reviews: updatedReviews,
 currentReview: state.currentReview?.id == reviewId ? null : state.currentReview,
 successMessage: response.message,
 );
 return true;
 } else {
 state = state.copyWith(
 isDeleting: false,
 error: response.message ?? 'Erreur lors de la suppression de l\'évaluation',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isDeleting: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 /// Exporter une évaluation en PDF
 Future<String?> exportToPDF(String reviewId) async {
 try {
 final response = await _service.exportToPDF(reviewId);

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(successMessage: response.message);
 return response.data;
 } else {
 state = state.copyWith(error: response.message ?? 'Erreur lors de l\'export PDF');
 return null;
 }
} catch (e) {
 state = state.copyWith(error: 'Erreur réseau: ${e.toString()}');
 return null;
}
 }

 /// Récupérer les statistiques des évaluations
 Future<void> loadStatistics({
 String? departmentId,
 String? period,
 ReviewType? type,
 }) {async {
 try {
 final response = await _service.getReviewStatistics(
 departmentId: departmentId,
 period: period,
 type: type,
 );

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 statistics: response.data,
 successMessage: response.message,
 );
 } else {
 state = state.copyWith(error: response.message ?? 'Erreur lors du chargement des statistiques');
 }
} catch (e) {
 state = state.copyWith(error: 'Erreur réseau: ${e.toString()}');
}
 }

 /// Synchroniser les évaluations locales
 Future<void> syncReviews() {async {
 try {
 final response = await _service.syncReviews();

 if (response.isSuccess) {{
 state = state.copyWith(successMessage: response.message);
 // Recharger les évaluations après synchronisation
 await loadReviews(refresh: true);
 } else {
 state = state.copyWith(error: response.message ?? 'Erreur lors de la synchronisation');
 }
} catch (e) {
 state = state.copyWith(error: 'Erreur réseau: ${e.toString()}');
}
 }

 /// Vider le cache
 Future<void> clearCache() {async {
 try {
 await _service.clearCache();
 state = state.copyWith(successMessage: 'Cache vidé avec succès');
} catch (e) {
 state = state.copyWith(error: 'Erreur lors du vidage du cache: ${e.toString()}');
}
 }

 /// Appliquer des filtres
 void applyFilters({
 ReviewStatus? status,
 ReviewType? type,
 String? period,
 String? employeeId,
 String? reviewerId,
 }) {
 state = state.copyWith(
 statusFilter: status,
 typeFilter: type,
 periodFilter: period,
 employeeIdFilter: employeeId,
 reviewerIdFilter: reviewerId,
 );
 loadReviews(
 status: status,
 type: type,
 period: period,
 employeeId: employeeId,
 reviewerId: reviewerId,
 refresh: true,
 );
 }

 /// Effacer les filtres
 void clearFilters() {
 state = state.copyWith(
 statusFilter: null,
 typeFilter: null,
 periodFilter: null,
 employeeIdFilter: null,
 reviewerIdFilter: null,
 );
 loadReviews(refresh: true);
 }

 /// Réinitialiser l'évaluation courante
 void clearCurrentReview() {
 state = state.copyWith(currentReview: null);
 }

 /// Effacer les messages
 void clearMessages() {
 state = state.copyWith(
 clearError: true,
 clearSuccessMessage: true,
 );
 }

 /// Réinitialiser l'état
 void reset() {
 state = const PerformanceReviewState();
 }
}

/// Providers Riverpod
final performanceReviewServiceProvider = Provider<PerformanceReviewService>((ref) {
 return PerformanceReviewService(
 apiService: ApiService(),
 storageService: StorageService(),
 );
});

final performanceReviewProvider = StateNotifierProvider<PerformanceReviewNotifier, PerformanceReviewState>((ref) {
 final service = ref.watch(performanceReviewServiceProvider);
 return PerformanceReviewNotifier(service);
});

/// Provider pour les évaluations filtrées
final filteredReviewsProvider = Provider<List<PerformanceReview>>((ref) {
 final state = ref.watch(performanceReviewProvider);
 return state.reviews;
});

/// Provider pour l'évaluation courante
final currentReviewProvider = Provider<PerformanceReview?>((ref) {
 final state = ref.watch(performanceReviewProvider);
 return state.currentReview;
});

/// Provider pour les statistiques
final reviewStatisticsProvider = Provider<Map<String, dynamic>?>(ref) {
 final state = ref.watch(performanceReviewProvider);
 return state.statistics;
});

/// Provider pour le nombre d'évaluations par statut
final reviewsByStatusProvider = Provider<Map<ReviewStatus, int>>((ref) {
 final reviews = ref.watch(filteredReviewsProvider);
 final statusCount = <ReviewStatus, int>{};
 
 for (final review in reviews) {
 statusCount[review.status] = (statusCount[review.status] ?? 0) + 1;
 }
 
 return statusCount;
});

/// Provider pour les évaluations en cours
final pendingReviewsProvider = Provider<List<PerformanceReview>>((ref) {
 final reviews = ref.watch(filteredReviewsProvider);
 return reviews.where((r) => r.status == ReviewStatus.inProgress).toList();
});

/// Provider pour les brouillons
final draftReviewsProvider = Provider<List<PerformanceReview>>((ref) {
 final reviews = ref.watch(filteredReviewsProvider);
 return reviews.where((r) => r.status == ReviewStatus.draft).toList();
});

/// Provider pour les évaluations complétées
final completedReviewsProvider = Provider<List<PerformanceReview>>((ref) {
 final reviews = ref.watch(filteredReviewsProvider);
 return reviews.where((r) => r.status == ReviewStatus.completed).toList();
});

/// Provider pour les évaluations approuvées
final approvedReviewsProvider = Provider<List<PerformanceReview>>((ref) {
 final reviews = ref.watch(filteredReviewsProvider);
 return reviews.where((r) => r.status == ReviewStatus.approved).toList();
});

/// Provider pour les évaluations rejetées
final rejectedReviewsProvider = Provider<List<PerformanceReview>>((ref) {
 final reviews = ref.watch(filteredReviewsProvider);
 return reviews.where((r) => r.status == ReviewStatus.rejected).toList();
});

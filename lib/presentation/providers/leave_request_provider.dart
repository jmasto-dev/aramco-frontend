import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/leave_request.dart';
import '../../core/services/leave_request_service.dart';
import '../../core/services/api_service.dart';
import '../../core/models/api_response.dart';
import 'auth_provider.dart';

// État du provider de demandes de congé
class \1 extends ChangeNotifier {
 final List<LeaveRequest> leaveRequests;
 final LeaveRequest? currentLeaveRequest;
 final bool isLoading;
 final String? error;
 final LeaveRequestFilters? filters;
 final int currentPage;
 final int totalPages;
 final bool hasMore;
 final Map<String, dynamic>? availabilityInfo;
 final List<String> attachments;

 const LeaveRequestState({
 this.leaveRequests = const [],
 this.currentLeaveRequest,
 this.isLoading = false,
 this.error,
 this.filters,
 this.currentPage = 1,
 this.totalPages = 1,
 this.hasMore = false,
 this.availabilityInfo,
 this.attachments = const [],
 });

 LeaveRequestState copyWith({
 List<LeaveRequest>? leaveRequests,
 LeaveRequest? currentLeaveRequest,
 bool? isLoading,
 String? error,
 LeaveRequestFilters? filters,
 int? currentPage,
 int? totalPages,
 bool? hasMore,
 Map<String, dynamic>? availabilityInfo,
 List<String>? attachments,
 bool clearError = false,
 }) {
 return LeaveRequestState(
 leaveRequests: leaveRequests ?? this.leaveRequests,
 currentLeaveRequest: currentLeaveRequest ?? this.currentLeaveRequest,
 isLoading: isLoading ?? this.isLoading,
 error: clearError ? null : (error ?? this.error),
 filters: filters ?? this.filters,
 currentPage: currentPage ?? this.currentPage,
 totalPages: totalPages ?? this.totalPages,
 hasMore: hasMore ?? this.hasMore,
 availabilityInfo: availabilityInfo ?? this.availabilityInfo,
 attachments: attachments ?? this.attachments,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is LeaveRequestState &&
 other.leaveRequests == leaveRequests &&
 other.currentLeaveRequest == currentLeaveRequest &&
 other.isLoading == isLoading &&
 other.error == error &&
 other.filters == filters &&
 other.currentPage == currentPage &&
 other.totalPages == totalPages &&
 other.hasMore == hasMore &&
 other.availabilityInfo == availabilityInfo &&
 other.attachments == attachments;
 }

 @override
 int get hashCode {
 return Object.hash(
 leaveRequests,
 currentLeaveRequest,
 isLoading,
 error,
 filters,
 currentPage,
 totalPages,
 hasMore,
 availabilityInfo,
 attachments,
 );
 }
}

// Provider pour le service de demandes de congé
final leaveRequestServiceProvider = Provider<LeaveRequestService>((ref) {
 final apiService = ref.watch(apiServiceProvider);
 return LeaveRequestService(apiService);
});

// Provider pour l'ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
 return ApiService();
});

// Provider principal pour la gestion des demandes de congé
final leaveRequestProvider = StateNotifierProvider<LeaveRequestNotifier, LeaveRequestState>((ref) {
 final service = ref.watch(leaveRequestServiceProvider);
 return LeaveRequestNotifier(service);
});

// Notifier pour la gestion des demandes de congé
class LeaveRequestNotifier extends StateNotifier<LeaveRequestState> {
 final LeaveRequestService _service;

 LeaveRequestNotifier(this._service) : super(const LeaveRequestState());

 // Récupérer toutes les demandes de congé
 Future<void> fetchLeaveRequests({
 LeaveRequestFilters? filters,
 int page = 1,
 bool refresh = false,
 }) {async {
 if (refresh) {{
 state = state.copyWith(
 isLoading: true,
 clearError: true,
 currentPage: 1,
 leaveRequests: [],
 );
} else {
 state = state.copyWith(isLoading: true, clearError: true);
}

 try {
 final response = await _service.getLeaveRequests(
 filters: filters ?? state.filters,
 page: page,
 );

 if (response.isSuccess && response.data != null) {{
 final newLeaveRequests = response.data!;
 
 state = state.copyWith(
 leaveRequests: refresh 
 ? newLeaveRequests 
 : [...state.leaveRequests, ...newLeaveRequests],
 currentPage: page,
 totalPages: 1, // TODO: Récupérer depuis la réponse paginée
 hasMore: newLeaveRequests.length == 20, // Suppose 20 items par page
 isLoading: false,
 filters: filters ?? state.filters,
 );
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de la récupération des demandes de congé: ${e.toString()}',
 );
}
 }

 // Récupérer une demande de congé par ID
 Future<void> fetchLeaveRequestById(String id) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.getLeaveRequestById(id);

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 currentLeaveRequest: response.data,
 isLoading: false,
 );
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de la récupération de la demande de congé: ${e.toString()}',
 );
}
 }

 // Créer une nouvelle demande de congé
 Future<bool> createLeaveRequest(LeaveRequest leaveRequest) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.createLeaveRequest(leaveRequest);

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 currentLeaveRequest: response.data,
 isLoading: false,
 );
 
 // Rafraîchir la liste
 await fetchLeaveRequests(refresh: true);
 
 return true;
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de la création de la demande de congé: ${e.toString()}',
 );
 return false;
}
 }

 // Mettre à jour une demande de congé
 Future<bool> updateLeaveRequest(String id, LeaveRequest leaveRequest) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.updateLeaveRequest(id, leaveRequest);

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 currentLeaveRequest: response.data,
 isLoading: false,
 );
 
 // Mettre à jour la demande dans la liste
 final updatedList = state.leaveRequests.map((lr) {
 return lr.id == id ? response.data! : lr;
 }).toList();
 
 state = state.copyWith(leaveRequests: updatedList);
 
 return true;
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de la mise à jour de la demande de congé: ${e.toString()}',
 );
 return false;
}
 }

 // Supprimer une demande de congé
 Future<bool> deleteLeaveRequest(String id) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.deleteLeaveRequest(id);

 if (response.isSuccess) {{
 // Retirer la demande de la liste
 final updatedList = state.leaveRequests.where((lr) => lr.id != id).toList();
 
 state = state.copyWith(
 leaveRequests: updatedList,
 currentLeaveRequest: state.currentLeaveRequest?.id == id ? null : state.currentLeaveRequest,
 isLoading: false,
 );
 
 return true;
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de la suppression de la demande de congé: ${e.toString()}',
 );
 return false;
}
 }

 // Approuver une demande de congé
 Future<bool> approveLeaveRequest(String id, {String? approverComments}) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.approveLeaveRequest(
 id,
 approverComments: approverComments,
 );

 if (response.isSuccess && response.data != null) {{
 // Mettre à jour la demande dans la liste
 final updatedList = state.leaveRequests.map((lr) {
 return lr.id == id ? response.data! : lr;
 }).toList();
 
 state = state.copyWith(
 leaveRequests: updatedList,
 currentLeaveRequest: state.currentLeaveRequest?.id == id ? response.data : state.currentLeaveRequest,
 isLoading: false,
 );
 
 return true;
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de l\'approbation de la demande de congé: ${e.toString()}',
 );
 return false;
}
 }

 // Rejeter une demande de congé
 Future<bool> rejectLeaveRequest(String id, String rejectionReason) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.rejectLeaveRequest(id, rejectionReason: rejectionReason);

 if (response.isSuccess && response.data != null) {{
 // Mettre à jour la demande dans la liste
 final updatedList = state.leaveRequests.map((lr) {
 return lr.id == id ? response.data! : lr;
 }).toList();
 
 state = state.copyWith(
 leaveRequests: updatedList,
 currentLeaveRequest: state.currentLeaveRequest?.id == id ? response.data : state.currentLeaveRequest,
 isLoading: false,
 );
 
 return true;
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors du rejet de la demande de congé: ${e.toString()}',
 );
 return false;
}
 }

 // Annuler une demande de congé
 Future<bool> cancelLeaveRequest(String id) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.cancelLeaveRequest(id);

 if (response.isSuccess && response.data != null) {{
 // Mettre à jour la demande dans la liste
 final updatedList = state.leaveRequests.map((lr) {
 return lr.id == id ? response.data! : lr;
 }).toList();
 
 state = state.copyWith(
 leaveRequests: updatedList,
 currentLeaveRequest: state.currentLeaveRequest?.id == id ? response.data : state.currentLeaveRequest,
 isLoading: false,
 );
 
 return true;
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de l\'annulation de la demande de congé: ${e.toString()}',
 );
 return false;
}
 }

 // Récupérer les demandes de congé d'un employé
 Future<void> fetchEmployeeLeaveRequests(String employeeId, {LeaveRequestFilters? filters}) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.getEmployeeLeaveRequests(
 employeeId,
 filters: filters,
 );

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 leaveRequests: response.data!,
 isLoading: false,
 );
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de la récupération des demandes de congé de l\'employé: ${e.toString()}',
 );
}
 }

 // Vérifier les disponibilités de congé
 Future<bool> checkLeaveAvailability({
 required String employeeId,
 required LeaveType leaveType,
 required DateTime startDate,
 required DateTime endDate,
 }) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _service.checkLeaveAvailability(
 employeeId: employeeId,
 leaveType: leaveType,
 startDate: startDate,
 endDate: endDate,
 );

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 availabilityInfo: response.data,
 isLoading: false,
 );
 return true;
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de la vérification des disponibilités: ${e.toString()}',
 );
 return false;
}
 }

 // Télécharger un document
 Future<bool> uploadAttachment(String leaveRequestId, String filePath) {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 // TODO: Implémenter avec le fichier réel
 // final response = await _service.uploadAttachment(leaveRequestId, file);
 
 // Pour l'instant, simuler le succès
 final newAttachments = [...state.attachments, filePath];
 state = state.copyWith(
 attachments: newAttachments,
 isLoading: false,
 );
 
 return true;
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors du téléchargement du document: ${e.toString()}',
 );
 return false;
}
 }

 // Appliquer des filtres
 void applyFilters(LeaveRequestFilters filters) {
 state = state.copyWith(filters: filters);
 fetchLeaveRequests(filters: filters, refresh: true);
 }

 // Effacer les filtres
 void clearFilters() {
 state = state.copyWith(filters: null);
 fetchLeaveRequests(refresh: true);
 }

 // Charger plus de demandes (pagination)
 Future<void> loadMore() {async {
 if (!state.hasMore || state.isLoading) r{eturn;
 
 await fetchLeaveRequests(
 filters: state.filters,
 page: state.currentPage + 1,
 );
 }

 // Réinitialiser l'état
 void reset() {
 state = const LeaveRequestState();
 }

 // Effacer les erreurs
 void clearError() {
 state = state.copyWith(clearError: true);
 }

 // Mettre à jour la demande actuelle
 void updateCurrentLeaveRequest(LeaveRequest leaveRequest) {
 state = state.copyWith(currentLeaveRequest: leaveRequest);
 }
}

// Providers spécialisés pour différentes fonctionnalités

// Provider pour les demandes de congé de l'utilisateur connecté
final myLeaveRequestsProvider = Provider.autoDispose<List<LeaveRequest>>((ref) {
 final leaveRequestState = ref.watch(leaveRequestProvider);
 final authState = ref.watch(authProvider);
 
 if (authState.user?.id == null) r{eturn [];
 
 return leaveRequestState.leaveRequests
 .where((lr) => lr.employeeId == authState.user!.id)
 .toList();
});

// Provider pour les statistiques des demandes de congé
final leaveRequestStatisticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
 final service = ref.watch(leaveRequestServiceProvider);
 final authState = ref.watch(authProvider);
 
 final response = await service.getLeaveStatistics(
 employeeId: authState.user?.id,
 year: DateTime.now().year,
 );
 
 if (response.isSuccess && response.data != null) {{
 return response.data!;
 } else {
 throw Exception(response.errorMessage);
 }
});

// Provider pour les types de congé disponibles
final availableLeaveTypesProvider = Provider.autoDispose<List<LeaveType>>((ref) {
 return LeaveType.values;
});

// Provider pour les priorités de congé
final leavePrioritiesProvider = Provider.autoDispose<List<LeavePriority>>((ref) {
 return LeavePriority.values;
});

// Provider pour les statuts de congé
final leaveStatusesProvider = Provider.autoDispose<List<LeaveStatus>>((ref) {
 return LeaveStatus.values;
});

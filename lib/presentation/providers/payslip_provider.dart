import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/payslip.dart';
import '../../core/services/payslip_service.dart';

// Provider pour le service des fiches de paie
final payslipServiceProvider = Provider<PayslipService>((ref) {
 return PayslipService();
});

// État des fiches de paie
class \1 extends ChangeNotifier {
 final List<Payslip> payslips;
 final bool isLoading;
 final bool isCreating;
 final bool isUpdating;
 final bool isDeleting;
 final String? error;
 final bool hasMore;
 final int currentPage;
 final Map<String, dynamic>? statistics;

 const PayslipState({
 this.payslips = const [],
 this.isLoading = false,
 this.isCreating = false,
 this.isUpdating = false,
 this.isDeleting = false,
 this.error,
 this.hasMore = true,
 this.currentPage = 1,
 this.statistics,
 });

 PayslipState copyWith({
 List<Payslip>? payslips,
 bool? isLoading,
 bool? isCreating,
 bool? isUpdating,
 bool? isDeleting,
 String? error,
 bool? hasMore,
 int? currentPage,
 Map<String, dynamic>? statistics,
 }) {
 return PayslipState(
 payslips: payslips ?? this.payslips,
 isLoading: isLoading ?? this.isLoading,
 isCreating: isCreating ?? this.isCreating,
 isUpdating: isUpdating ?? this.isUpdating,
 isDeleting: isDeleting ?? this.isDeleting,
 error: error ?? this.error,
 hasMore: hasMore ?? this.hasMore,
 currentPage: currentPage ?? this.currentPage,
 statistics: statistics ?? this.statistics,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is PayslipState &&
 other.payslips == payslips &&
 other.isLoading == isLoading &&
 other.isCreating == isCreating &&
 other.isUpdating == isUpdating &&
 other.isDeleting == isDeleting &&
 other.error == error &&
 other.hasMore == hasMore &&
 other.currentPage == currentPage &&
 other.statistics == statistics;
 }

 @override
 int get hashCode {
 return payslips.hashCode ^
 isLoading.hashCode ^
 isCreating.hashCode ^
 isUpdating.hashCode ^
 isDeleting.hashCode ^
 error.hashCode ^
 hasMore.hashCode ^
 currentPage.hashCode ^
 statistics.hashCode;
 }
}

// Notifier pour les fiches de paie
class PayslipNotifier extends StateNotifier<PayslipState> {
 final PayslipService _service;

 PayslipNotifier(this._service) : super(const PayslipState());

 // Charger les fiches de paie
 Future<void> loadPayslips({
 int page = 1,
 int limit = 20,
 String? employeeId,
 String? department,
 String? status,
 int? year,
 int? month,
 String? search,
 bool refresh = false,
 }) {async {
 if (refresh) {{
 state = state.copyWith(
 payslips: [],
 currentPage: 1,
 hasMore: true,
 error: null,
 );
}

 state = state.copyWith(isLoading: true, error: null);

 try {
 final response = await _service.getPayslips(
 page: page,
 limit: limit,
 employeeId: employeeId,
 department: department,
 status: status,
 year: year,
 month: month,
 search: search,
 );

 if (response.isSuccess && response.data != null) {{
 final newPayslips = response.data!;
 final allPayslips = refresh ? newPayslips : [...state.payslips, ...newPayslips];
 
 state = state.copyWith(
 payslips: allPayslips,
 isLoading: false,
 hasMore: newPayslips.length == limit,
 currentPage: page,
 );
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.message,
 );
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors du chargement des fiches de paie: $e',
 );
}
 }

 // Charger plus de fiches de paie (pagination)
 Future<void> loadMorePayslips({
 String? employeeId,
 String? department,
 String? status,
 int? year,
 int? month,
 String? search,
 }) {async {
 if (state.isLoading || !state.hasMore) r{eturn;

 await loadPayslips(
 page: state.currentPage + 1,
 employeeId: employeeId,
 department: department,
 status: status,
 year: year,
 month: month,
 search: search,
 );
 }

 // Créer une fiche de paie
 Future<void> createPayslip(Payslip payslip) {async {
 state = state.copyWith(isCreating: true, error: null);

 try {
 final response = await _service.createPayslip(payslip);

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 isCreating: false,
 payslips: [response.data!, ...state.payslips],
 );
 } else {
 state = state.copyWith(
 isCreating: false,
 error: response.message,
 );
 }
} catch (e) {
 state = state.copyWith(
 isCreating: false,
 error: 'Erreur lors de la création de la fiche de paie: $e',
 );
}
 }

 // Mettre à jour une fiche de paie
 Future<void> updatePayslip(Payslip payslip) {async {
 state = state.copyWith(isUpdating: true, error: null);

 try {
 final response = await _service.updatePayslip(payslip);

 if (response.isSuccess && response.data != null) {{
 final updatedPayslips = state.payslips.map((p) {
 return p.id == payslip.id ? response.data! : p;
 }).toList();

 state = state.copyWith(
 isUpdating: false,
 payslips: updatedPayslips,
 );
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message,
 );
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur lors de la mise à jour de la fiche de paie: $e',
 );
}
 }

 // Supprimer une fiche de paie
 Future<void> deletePayslip(String id) {async {
 state = state.copyWith(isDeleting: true, error: null);

 try {
 final response = await _service.deletePayslip(id);

 if (response.isSuccess) {{
 final updatedPayslips = state.payslips.where((p) => p.id != id).toList();
 state = state.copyWith(
 isDeleting: false,
 payslips: updatedPayslips,
 );
 } else {
 state = state.copyWith(
 isDeleting: false,
 error: response.message,
 );
 }
} catch (e) {
 state = state.copyWith(
 isDeleting: false,
 error: 'Erreur lors de la suppression de la fiche de paie: $e',
 );
}
 }

 // Approuver une fiche de paie
 Future<void> approvePayslip(String id) {async {
 state = state.copyWith(isUpdating: true, error: null);

 try {
 final response = await _service.approvePayslip(id);

 if (response.isSuccess && response.data != null) {{
 final updatedPayslips = state.payslips.map((p) {
 return p.id == id ? response.data! : p;
 }).toList();

 state = state.copyWith(
 isUpdating: false,
 payslips: updatedPayslips,
 );
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message,
 );
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur lors de l\'approbation de la fiche de paie: $e',
 );
}
 }

 // Marquer comme payée
 Future<void> markAsPaid(String id, {DateTime? paymentDate}) {async {
 state = state.copyWith(isUpdating: true, error: null);

 try {
 final response = await _service.markAsPaid(id, paymentDate: paymentDate);

 if (response.isSuccess && response.data != null) {{
 final updatedPayslips = state.payslips.map((p) {
 return p.id == id ? response.data! : p;
 }).toList();

 state = state.copyWith(
 isUpdating: false,
 payslips: updatedPayslips,
 );
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message,
 );
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur lors du marquage comme payée: $e',
 );
}
 }

 // Annuler une fiche de paie
 Future<void> cancelPayslip(String id, String reason) {async {
 state = state.copyWith(isUpdating: true, error: null);

 try {
 final response = await _service.cancelPayslip(id, reason);

 if (response.isSuccess && response.data != null) {{
 final updatedPayslips = state.payslips.map((p) {
 return p.id == id ? response.data! : p;
 }).toList();

 state = state.copyWith(
 isUpdating: false,
 payslips: updatedPayslips,
 );
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message,
 );
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur lors de l\'annulation de la fiche de paie: $e',
 );
}
 }

 // Charger les statistiques
 Future<Map<String, dynamic>?> loadStatistics({
 int? year,
 int? month,
 String? department,
 }) async {
 try {
 final response = await _service.getPayslipStats(
 year: year,
 month: month,
 department: department,
 );

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(statistics: response.data);
 return response.data;
 } else {
 state = state.copyWith(error: response.message);
 return null;
 }
} catch (e) {
 state = state.copyWith(error: 'Erreur lors du chargement des statistiques: $e');
 return null;
}
 }

 // Rechercher des fiches de paie
 Future<void> searchPayslips(String query) {async {
 state = state.copyWith(isLoading: true, error: null);

 try {
 final response = await _service.searchPayslips(query);

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 isLoading: false,
 payslips: response.data!,
 );
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.message,
 );
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de la recherche: $e',
 );
}
 }

 // Rafraîchir les données
 Future<void> refresh() {async {
 await loadPayslips(refresh: true);
 }

 // Effacer l'erreur
 void clearError() {
 state = state.copyWith(error: null);
 }

 // Réinitialiser l'état
 void reset() {
 state = const PayslipState();
 }
}

// Provider pour le notifier des fiches de paie
final payslipProvider = StateNotifierProvider<PayslipNotifier, PayslipState>((ref) {
 final service = ref.watch(payslipServiceProvider);
 return PayslipNotifier(service);
});

// Provider pour une fiche de paie spécifique
final payslipByIdProvider = Provider.family<Payslip?, String>((ref, id) {
 final payslips = ref.watch(payslipProvider).payslips;
 try {
 return payslips.firstWhere((payslip) => payslip.id == id);
 } catch (e) {
 return null;
 }
});

// Provider pour les fiches de paie d'un employé
final employeePayslipsProvider = Provider.family<List<Payslip>, String>((ref, employeeId) {
 final payslips = ref.watch(payslipProvider).payslips;
 return payslips.where((payslip) => payslip.employeeId == employeeId).toList();
});

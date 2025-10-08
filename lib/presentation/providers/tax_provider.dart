import 'package:flutter/foundation.dart';
import '../../core/models/tax_declaration.dart';
import '../../core/services/tax_service.dart';
import '../../core/models/api_response.dart';

class TaxProvider with ChangeNotifier {
 final TaxService _taxService = TaxService();

 // États
 List<TaxDeclaration> _declarations = [];
 List<TaxRate> _taxRates = [];
 List<TaxDeclaration> _upcomingDeadlines = [];
 TaxDeclaration? _selectedDeclaration;
 bool _isLoading = false;
 String _errorMessage = '';
 
 // Filtres
 TaxDeclarationType? _selectedType;
 TaxDeclarationStatus? _selectedStatus;
 DateTime? _startDate;
 DateTime? _endDate;
 int _currentPage = 1;
 int _totalPages = 1;
 bool _hasMore = true;

 // Getters
 List<TaxDeclaration> get declarations => _declarations;
 List<TaxRate> get taxRates => _taxRates;
 List<TaxDeclaration> get upcomingDeadlines => _upcomingDeadlines;
 TaxDeclaration? get selectedDeclaration => _selectedDeclaration;
 bool get isLoading => _isLoading;
 String get errorMessage => _errorMessage;
 TaxDeclarationType? get selectedType => _selectedType;
 TaxDeclarationStatus? get selectedStatus => _selectedStatus;
 DateTime? get startDate => _startDate;
 DateTime? get endDate => _endDate;
 int get currentPage => _currentPage;
 int get totalPages => _totalPages;
 bool get hasMore => _hasMore;

 // Getters calculés
 List<TaxDeclaration> get pendingDeclarations => 
 _declarations.where((d) => d.status == TaxDeclarationStatus.submitted || 
 d.status == TaxDeclarationStatus.underReview).toList();
 
 List<TaxDeclaration> get overdueDeclarations => 
 _declarations.where((d) => d.isOverdue).toList();
 
 List<TaxDeclaration> get paidDeclarations => 
 _declarations.where((d) => d.status == TaxDeclarationStatus.paid).toList();

 double get totalTaxAmount => _declarations.fold(0.0, (sum, d) => sum + d.taxAmount);
 double get totalPendingAmount => pendingDeclarations.fold(0.0, (sum, d) => sum + d.taxAmount);

 // Réinitialiser les erreurs
 void clearError() {
 _errorMessage = '';
 notifyListeners();
 }

 // Réinitialiser les filtres
 void resetFilters() {
 _selectedType = null;
 _selectedStatus = null;
 _startDate = null;
 _endDate = null;
 _currentPage = 1;
 notifyListeners();
 }

 // Appliquer les filtres
 void applyFilters({
 TaxDeclarationType? type,
 TaxDeclarationStatus? status,
 DateTime? startDate,
 DateTime? endDate,
 }) {
 _selectedType = type;
 _selectedStatus = status;
 _startDate = startDate;
 _endDate = endDate;
 _currentPage = 1;
 _declarations.clear();
 notifyListeners();
 loadDeclarations();
 }

 // Charger les déclarations fiscales
 Future<void> loadDeclarations({bool refresh = false}) {async {
 if (refresh) {{
 _currentPage = 1;
 _declarations.clear();
 _hasMore = true;
}

 if (!_hasMore || _isLoading) r{eturn;

 _setLoading(true);

 try {
 final response = await _taxService.getTaxDeclarations(
 type: _selectedType,
 status: _selectedStatus,
 startDate: _startDate,
 endDate: _endDate,
 page: _currentPage,
 limit: 20,
 );

 if (response.success) {{
 if (refresh) {{
 _declarations = response.data ?? [];
 } else {
 _declarations.addAll(response.data ?? []);
 }
 
 _currentPage++;
 _hasMore = (response.data?.length ?? 0) >= 20;
 _errorMessage = '';
 } else {
 _errorMessage = response.message ?? 'Erreur lors du chargement des déclarations';
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
} finally {
 _setLoading(false);
}
 }

 // Charger une déclaration spécifique
 Future<void> loadDeclarationById(String id) {async {
 _setLoading(true);
 try {
 final response = await _taxService.getTaxDeclarationById(id);
 
 if (response.success) {{
 _selectedDeclaration = response.data;
 _errorMessage = '';
 } else {
 _errorMessage = response.message ?? 'Déclaration non trouvée';
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
} finally {
 _setLoading(false);
}
 }

 // Créer une nouvelle déclaration
 Future<bool> createDeclaration(Map<String, dynamic> declarationData) {async {
 _setLoading(true);
 try {
 final response = await _taxService.createTaxDeclaration(declarationData);
 
 if (response.success) {{
 _declarations.insert(0, response.data!);
 _selectedDeclaration = response.data;
 _errorMessage = '';
 notifyListeners();
 return true;
 } else {
 _errorMessage = response.message ?? 'Erreur lors de la création';
 return false;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return false;
} finally {
 _setLoading(false);
}
 }

 // Mettre à jour une déclaration
 Future<bool> updateDeclaration(String id, Map<String, dynamic> declarationData) {async {
 _setLoading(true);
 try {
 final response = await _taxService.updateTaxDeclaration(id, declarationData);
 
 if (response.success) {{
 final index = _declarations.indexWhere((d) => d.id == id);
 if (index != -1) {{
 _declarations[index] = response.data!;
 }
 if (_selectedDeclaration?.id == id) {{
 _selectedDeclaration = response.data;
 }
 _errorMessage = '';
 notifyListeners();
 return true;
 } else {
 _errorMessage = response.message ?? 'Erreur lors de la mise à jour';
 return false;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return false;
} finally {
 _setLoading(false);
}
 }

 // Supprimer une déclaration
 Future<bool> deleteDeclaration(String id) {async {
 _setLoading(true);
 try {
 final response = await _taxService.deleteTaxDeclaration(id);
 
 if (response.success) {{
 _declarations.removeWhere((d) => d.id == id);
 if (_selectedDeclaration?.id == id) {{
 _selectedDeclaration = null;
 }
 _errorMessage = '';
 notifyListeners();
 return true;
 } else {
 _errorMessage = response.message ?? 'Erreur lors de la suppression';
 return false;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return false;
} finally {
 _setLoading(false);
}
 }

 // Soumettre une déclaration
 Future<bool> submitDeclaration(String id) {async {
 _setLoading(true);
 try {
 final response = await _taxService.submitTaxDeclaration(id);
 
 if (response.success) {{
 final index = _declarations.indexWhere((d) => d.id == id);
 if (index != -1) {{
 _declarations[index] = response.data!;
 }
 if (_selectedDeclaration?.id == id) {{
 _selectedDeclaration = response.data;
 }
 _errorMessage = '';
 notifyListeners();
 return true;
 } else {
 _errorMessage = response.message ?? 'Erreur lors de la soumission';
 return false;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return false;
} finally {
 _setLoading(false);
}
 }

 // Approuver une déclaration
 Future<bool> approveDeclaration(String id) {async {
 _setLoading(true);
 try {
 final response = await _taxService.approveTaxDeclaration(id);
 
 if (response.success) {{
 final index = _declarations.indexWhere((d) => d.id == id);
 if (index != -1) {{
 _declarations[index] = response.data!;
 }
 if (_selectedDeclaration?.id == id) {{
 _selectedDeclaration = response.data;
 }
 _errorMessage = '';
 notifyListeners();
 return true;
 } else {
 _errorMessage = response.message ?? 'Erreur lors de l\'approbation';
 return false;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return false;
} finally {
 _setLoading(false);
}
 }

 // Rejeter une déclaration
 Future<bool> rejectDeclaration(String id, String reason) {async {
 _setLoading(true);
 try {
 final response = await _taxService.rejectTaxDeclaration(id, reason);
 
 if (response.success) {{
 final index = _declarations.indexWhere((d) => d.id == id);
 if (index != -1) {{
 _declarations[index] = response.data!;
 }
 if (_selectedDeclaration?.id == id) {{
 _selectedDeclaration = response.data;
 }
 _errorMessage = '';
 notifyListeners();
 return true;
 } else {
 _errorMessage = response.message ?? 'Erreur lors du rejet';
 return false;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return false;
} finally {
 _setLoading(false);
}
 }

 // Marquer comme payée
 Future<bool> markAsPaid(String id, Map<String, dynamic> paymentData) {async {
 _setLoading(true);
 try {
 final response = await _taxService.markAsPaid(id, paymentData);
 
 if (response.success) {{
 final index = _declarations.indexWhere((d) => d.id == id);
 if (index != -1) {{
 _declarations[index] = response.data!;
 }
 if (_selectedDeclaration?.id == id) {{
 _selectedDeclaration = response.data;
 }
 _errorMessage = '';
 notifyListeners();
 return true;
 } else {
 _errorMessage = response.message ?? 'Erreur lors de l\'enregistrement du paiement';
 return false;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return false;
} finally {
 _setLoading(false);
}
 }

 // Charger les taux d'imposition
 Future<void> loadTaxRates() {async {
 _setLoading(true);
 try {
 final response = await _taxService.getTaxRates();
 
 if (response.success) {{
 _taxRates = response.data ?? [];
 _errorMessage = '';
 } else {
 _errorMessage = response.message ?? 'Erreur lors du chargement des taux';
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
} finally {
 _setLoading(false);
}
 }

 // Calculer une taxe
 Future<Map<String, dynamic>?> calculateTax({
 required TaxDeclarationType type,
 required double baseAmount,
 required TaxPeriod period,
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 _setLoading(true);
 try {
 final response = await _taxService.calculateTax(
 type: type,
 baseAmount: baseAmount,
 period: period,
 startDate: startDate,
 endDate: endDate,
 );
 
 if (response.success) {{
 _errorMessage = '';
 return response.data;
 } else {
 _errorMessage = response.message ?? 'Erreur lors du calcul';
 return null;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return null;
} finally {
 _setLoading(false);
}
 }

 // Générer un rapport fiscal
 Future<Map<String, dynamic>?> generateTaxReport({
 TaxDeclarationType? type,
 DateTime? startDate,
 DateTime? endDate,
 String format = 'pdf',
 }) async {
 _setLoading(true);
 try {
 final response = await _taxService.generateTaxReport(
 type: type,
 startDate: startDate,
 endDate: endDate,
 format: format,
 );
 
 if (response.success) {{
 _errorMessage = '';
 return response.data;
 } else {
 _errorMessage = response.message ?? 'Erreur lors de la génération du rapport';
 return null;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return null;
} finally {
 _setLoading(false);
}
 }

 // Charger les échéances à venir
 Future<void> loadUpcomingDeadlines({int days = 30}) {async {
 _setLoading(true);
 try {
 final response = await _taxService.getUpcomingDeadlines(days: days);
 
 if (response.success) {{
 _upcomingDeadlines = response.data ?? [];
 _errorMessage = '';
 } else {
 _errorMessage = response.message ?? 'Erreur lors du chargement des échéances';
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
} finally {
 _setLoading(false);
}
 }

 // Télécharger un document
 Future<String?> downloadDocument(String declarationId, String documentId) async {
 _setLoading(true);
 try {
 final response = await _taxService.downloadTaxDocument(declarationId, documentId);
 
 if (response.success) {{
 _errorMessage = '';
 return response.data;
 } else {
 _errorMessage = response.message ?? 'Erreur lors du téléchargement';
 return null;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return null;
} finally {
 _setLoading(false);
}
 }

 // Uploader un document
 Future<bool> uploadDocument(String declarationId, String filePath) {async {
 _setLoading(true);
 try {
 final response = await _taxService.uploadTaxDocument(declarationId, filePath);
 
 if (response.success) {{
 // Recharger la déclaration pour mettre à jour les documents
 await loadDeclarationById(declarationId);
 _errorMessage = '';
 return true;
 } else {
 _errorMessage = response.message ?? 'Erreur lors de l\'upload';
 return false;
 }
} catch (e) {
 _errorMessage = 'Erreur réseau: ${e.toString()}';
 return false;
} finally {
 _setLoading(false);
}
 }

 // Sélectionner une déclaration
 void selectDeclaration(TaxDeclaration? declaration) {
 _selectedDeclaration = declaration;
 notifyListeners();
 }

 // Méthode privée pour gérer le chargement
 void _setLoading(bool loading) {
 _isLoading = loading;
 notifyListeners();
 }

 // Initialiser le provider
 Future<void> initialize() {async {
 await Future.wait([
 loadDeclarations(),
 loadTaxRates(),
 loadUpcomingDeadlines(),
 ]);
 }

 // Rafraîchir toutes les données
 Future<void> refresh() {async {
 await Future.wait([
 loadDeclarations(refresh: true),
 loadTaxRates(),
 loadUpcomingDeadlines(),
 ]);
 }
}

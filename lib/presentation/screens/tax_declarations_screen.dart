import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../widgets/tax_declaration_card.dart';
import '../widgets/tax_filter.dart';
import '../widgets/loading_overlay.dart';
import '../../core/models/tax_declaration.dart';

class TaxDeclarationsScreen extends StatefulWidget {
 const TaxDeclarationsScreen({Key? key}) : super(key: key);

 @override
 State<TaxDeclarationsScreen> createState() => _TaxDeclarationsScreenState();
}

class _TaxDeclarationsScreenState extends State<TaxDeclarationsScreen> {
 final ScrollController _scrollController = ScrollController();
 bool _isFilterExpanded = false;
 bool _isLoading = false;
 String _errorMessage = '';
 List<TaxDeclaration> _declarations = [];

 @override
 void initState() {
 super.initState();
 _scrollController.addListener(_onScroll);
 _loadDeclarations();
 }

 @override
 void dispose() {
 _scrollController.dispose();
 super.dispose();
 }

 void _onScroll() {
 if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {{
 _loadDeclarations();
}
 }

 Future<void> _loadDeclarations() {async {
 if (_isLoading) r{eturn;
 
 setState(() {
 _isLoading = true;
 _errorMessage = '';
});

 try {
 // Simuler un chargement de données
 await Future.delayed(const Duration(seconds: 1));
 
 // Pour l'instant, utilisons des données factices
 setState(() {
 _declarations = _getMockDeclarations();
 _isLoading = false;
 });
} catch (e) {
 setState(() {
 _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
 _isLoading = false;
 });
}
 }

 List<TaxDeclaration> _getMockDeclarations() {
 return [
 TaxDeclaration(
 id: '1',
 declarationNumber: 'TVA-2024-001',
 type: TaxDeclarationType.vat,
 status: TaxDeclarationStatus.submitted,
 period: TaxPeriod.quarterly,
 startDate: DateTime(2024, 1, 1),
 endDate: DateTime(2024, 3, 31),
 submissionDate: DateTime(2024, 4, 15),
 dueDate: DateTime(2024, 4, 30),
 totalAmount: 12500.0,
 taxAmount: 2500.0,
 baseAmount: 10000.0,
 description: 'Déclaration TVA premier trimestre 2024',
 createdAt: DateTime(2024, 4, 1),
 updatedAt: DateTime(2024, 4, 15),
 ),
 TaxDeclaration(
 id: '2',
 declarationNumber: 'IS-2024-001',
 type: TaxDeclarationType.corporateTax,
 status: TaxDeclarationStatus.draft,
 period: TaxPeriod.annual,
 startDate: DateTime(2024, 1, 1),
 endDate: DateTime(2024, 12, 31),
 submissionDate: DateTime(2024, 4, 20),
 dueDate: DateTime(2024, 5, 15),
 totalAmount: 50000.0,
 taxAmount: 15000.0,
 baseAmount: 100000.0,
 description: 'Impôt sur les sociétés 2024',
 createdAt: DateTime(2024, 4, 10),
 updatedAt: DateTime(2024, 4, 20),
 ),
 ];
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Déclarations Fiscales'),
 actions: [
 IconButton(
 onPressed: () => _showStatistics(context),
 icon: const Icon(Icons.analytics),
 tooltip: 'Statistiques',
 ),
 IconButton(
 onPressed: () => _generateReport(context),
 icon: const Icon(Icons.file_download),
 tooltip: 'Générer un rapport',
 ),
 IconButton(
 onPressed: _isLoading ? null : _loadDeclarations,
 icon: _isLoading 
 ? const SizedBox(
 width: 20,
 height: 20,
 child: CircularProgressIndicator(strokeWidth: 2),
 )
 : const Icon(Icons.refresh),
 tooltip: 'Actualiser',
 ),
 ],
 ),
 body: LoadingOverlay(
 isLoading: _isLoading && _declarations.isEmpty,
 child: RefreshIndicator(
 onRefresh: _loadDeclarations,
 child: Column(
 children: [
 // Summary cards
 _buildSummaryCards(),
 
 // Filter
 TaxFilter(
 selectedType: null,
 selectedStatus: null,
 startDate: null,
 endDate: null,
 onFilterChanged: (type, status, startDate, endDate) {
 // TODO: Apply filters
 ;,
 ),
 
 // Error message
 if (_errorMessage.isNotEmpty)
 C{ontainer(
 margin: const EdgeInsets.symmetric(1),
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.red[50],
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(color: Colors.red[200]!),
 ),
 child: Row(
 children: [
 Icon(Icons.error, color: Colors.red[600], size: 20),
 const SizedBox(width: 8),
 Expanded(
 child: Text(
 _errorMessage,
 style: const TextStyle(color: Colors.red[600]),
 ),
 ),
 IconButton(
 onPressed: () => setState(() => _errorMessage = ''),
 icon: const Icon(Icons.close, size: 18),
 color: Colors.red[600],
 ),
 ],
 ),
 ),
 
 // Declarations list
 Expanded(
 child: _declarations.isEmpty
 ? _buildEmptyState()
 : _buildDeclarationsList(),
 ),
 ],
 ),
 ),
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: () => _createDeclaration(context),
 child: const Icon(Icons.add),
 tooltip: 'Nouvelle déclaration',
 ),
 );
 }

 Widget _buildSummaryCards() {
 return Container(
 margin: const EdgeInsets.all(1),
 child: Column(
 children: [
 Row(
 children: [
 Expanded(
 child: _buildSummaryCard(
 'Total déclarations',
 '${_declarations.length}',
 Icons.description,
 Colors.blue,
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: _buildSummaryCard(
 'En attente',
 '${_declarations.where((d) => d.status == TaxDeclarationStatus.submitted).length}',
 Icons.pending,
 Colors.orange,
 ),
 ),
 ],
 ),
 const SizedBox(height: 8),
 Row(
 children: [
 Expanded(
 child: _buildSummaryCard(
 'En retard',
 '${_declarations.where((d) => d.isOverdue).length}',
 Icons.warning,
 Colors.red,
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: _buildSummaryCard(
 'Montant total',
 '${_declarations.fold(0.0, (sum, d) => sum + d.taxAmount).toStringAsFixed(2)} €',
 Icons.euro,
 Colors.green,
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(icon, color: color, size: 20),
 const Spacer(),
 Text(
 value,
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 color: color,
 ),
 ),
 ],
 ),
 const SizedBox(height: 8),
 Text(
 title,
 style: Theme.of(context).textTheme.bodySmall,
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildEmptyState() {
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.receipt_long,
 size: 64,
 color: Colors.grey[400],
 ),
 const SizedBox(height: 16),
 Text(
 'Aucune déclaration fiscale',
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(height: 8),
 Text(
 'Commencez par créer votre première déclaration fiscale',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Colors.grey[600],
 ),
 textAlign: TextAlign.center,
 ),
 ],
 ),
 );
 }

 Widget _buildDeclarationsList() {
 return ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.only(bottom: 80),
 itemCount: _declarations.length,
 itemBuilder: (context, index) {
 final declaration = _declarations[index];
 return TaxDeclarationCard(
 declaration: declaration,
 onTap: () => _viewDeclaration(context, declaration),
 onEdit: _canEdit(declaration) ? () => _editDeclaration(context, declaration) : null,
 onDelete: _canDelete(declaration) ? () => _deleteDeclaration(context, declaration) : null,
 onSubmit: _canSubmit(declaration) ? () => _submitDeclaration(context, declaration) : null,
 onApprove: _canApprove(declaration) ? () => _approveDeclaration(context, declaration) : null,
 onReject: _canReject(declaration) ? () => _rejectDeclaration(context, declaration) : null,
 onMarkAsPaid: _canMarkAsPaid(declaration) ? () => _markAsPaid(context, declaration) : null,
 );
 },
 );
 }

 bool _canEdit(TaxDeclaration declaration) {
 return declaration.status == TaxDeclarationStatus.draft;
 }

 bool _canDelete(TaxDeclaration declaration) {
 return declaration.status == TaxDeclarationStatus.draft;
 }

 bool _canSubmit(TaxDeclaration declaration) {
 return declaration.status == TaxDeclarationStatus.draft;
 }

 bool _canApprove(TaxDeclaration declaration) {
 return declaration.status == TaxDeclarationStatus.submitted || 
 declaration.status == TaxDeclarationStatus.underReview;
 }

 bool _canReject(TaxDeclaration declaration) {
 return declaration.status == TaxDeclarationStatus.submitted || 
 declaration.status == TaxDeclarationStatus.underReview;
 }

 bool _canMarkAsPaid(TaxDeclaration declaration) {
 return declaration.status == TaxDeclarationStatus.approved;
 }

 void _createDeclaration(BuildContext context) {
 // TODO: Navigate to declaration form
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Formulaire de création en cours de développement')),
 );
 }

 void _viewDeclaration(BuildContext context, TaxDeclaration declaration) {
 // TODO: Navigate to declaration details
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Voir la déclaration ${declaration.declarationNumber}')),
 );
 }

 void _editDeclaration(BuildContext context, TaxDeclaration declaration) {
 // TODO: Navigate to edit form
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Modifier la déclaration ${declaration.declarationNumber}')),
 );
 }

 void _deleteDeclaration(BuildContext context, TaxDeclaration declaration) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Supprimer la déclaration'),
 content: Text(
 'Êtes-vous sûr de vouloir supprimer la déclaration ${declaration.declarationNumber} ?\n'
 'Cette action est irréversible.',
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () async {
 Navigator.pop(context);
 setState(() {
 _declarations.removeWhere((d) => d.id == declaration.id);
 });
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Déclaration supprimée avec succès')),
 );
},
 child: const Text('Supprimer', style: const TextStyle(color: Colors.red)),
 ),
 ],
 ),
 );
 }

 void _submitDeclaration(BuildContext context, TaxDeclaration declaration) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Soumettre la déclaration'),
 content: Text(
 'Êtes-vous sûr de vouloir soumettre la déclaration ${declaration.declarationNumber} ?\n'
 'Vous ne pourrez plus la modifier après soumission.',
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () async {
 Navigator.pop(context);
 setState(() {
 final index = _declarations.indexWhere((d) => d.id == declaration.id);
 if (index != -1) {{
 _declarations[index] = declaration.copyWith(
 status: TaxDeclarationStatus.submitted,
 );
 }
 });
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Déclaration soumise avec succès')),
 );
},
 child: const Text('Soumettre'),
 ),
 ],
 ),
 );
 }

 void _approveDeclaration(BuildContext context, TaxDeclaration declaration) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Approuver la déclaration'),
 content: Text(
 'Êtes-vous sûr de vouloir approuver la déclaration ${declaration.declarationNumber} ?',
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () async {
 Navigator.pop(context);
 setState(() {
 final index = _declarations.indexWhere((d) => d.id == declaration.id);
 if (index != -1) {{
 _declarations[index] = declaration.copyWith(
 status: TaxDeclarationStatus.approved,
 );
 }
 });
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Déclaration approuvée avec succès')),
 );
},
 child: const Text('Approuver'),
 ),
 ],
 ),
 );
 }

 void _rejectDeclaration(BuildContext context, TaxDeclaration declaration) {
 final TextEditingController reasonController = TextEditingController();
 
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Rejeter la déclaration'),
 content: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 Text('Veuillez indiquer la raison du rejet de la déclaration ${declaration.declarationNumber} :'),
 const SizedBox(height: 16),
 TextField(
 controller: reasonController,
 decoration: const InputDecoration(
 labelText: 'Raison du rejet',
 border: OutlineInputBorder(),
 ),
 maxLines: 3,
 ),
 ],
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () async {
 if (reasonController.text.trim().{isEmpty) {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Veuillez indiquer une raison')),
 );
 return;
 }
 
 Navigator.pop(context);
 setState(() {
 final index = _declarations.indexWhere((d) => d.id == declaration.id);
 if (index != -1) {{
 _declarations[index] = declaration.copyWith(
 status: TaxDeclarationStatus.rejected,
 );
 }
 });
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Déclaration rejetée avec succès')),
 );
},
 child: const Text('Rejeter', style: const TextStyle(color: Colors.red)),
 ),
 ],
 ),
 );
 }

 void _markAsPaid(BuildContext context, TaxDeclaration declaration) {
 // TODO: Show payment dialog
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Marquer comme payé ${declaration.declarationNumber}')),
 );
 }

 void _showStatistics(BuildContext context) {
 // TODO: Show statistics dialog
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Statistiques en cours de développement')),
 );
 }

 void _generateReport(BuildContext context) {
 // TODO: Show report generation dialog
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Génération de rapport en cours de développement')),
 );
 }
}

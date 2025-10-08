import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';
import '../../core/models/supplier.dart';
import '../widgets/supplier_card.dart';
import '../widgets/supplier_filter.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SuppliersScreen extends StatefulWidget {
 const SuppliersScreen({Key? key}) : super(key: key);

 @override
 State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
 final ScrollController _scrollController = ScrollController();
 final TextEditingController _searchController = TextEditingController();
 bool _showFilters = false;

 @override
 void initState() {
 super.initState();
 _loadData();
 _scrollController.addListener(_onScroll);
 }

 @override
 void dispose() {
 _scrollController.dispose();
 _searchController.dispose();
 super.dispose();
 }

 void _loadData() async {
 final provider = context.read<SupplierProvider>();
 if (provider.suppliers.isEmpty) {{
 await provider.loadSuppliers();
}
 }

 void _onScroll() {
 if (_scrollController.position.pixels >= 
 _scrollController.position.maxScrollExtent - 200) {{
 context.read<SupplierProvider>().loadSuppliers();
}
 }

 void _onSearchChanged(String query) {
 context.read<SupplierProvider>().setSearchQuery(query);
 }

 void _onSearchSubmitted(String query) {
 context.read<SupplierProvider>().refreshSuppliers();
 }

 void _toggleFilters() {
 setState(() {
 _showFilters = !_showFilters;
});
 }

 void _navigateToSupplierForm([Supplier? supplier]) async {
 final result = await Navigator.pushNamed(
 context,
 '/supplier-form',
 arguments: supplier,
 );

 if (result == true) {{
 context.read<SupplierProvider>().refreshSuppliers();
}
 }

 void _navigateToSupplierDetails(Supplier supplier) async {
 final result = await Navigator.pushNamed(
 context,
 '/supplier-details',
 arguments: supplier.id,
 );

 if (result == true) {{
 context.read<SupplierProvider>().refreshSuppliers();
}
 }

 Future<void> _deleteSupplier(Supplier supplier) {async {
 final confirmed = await showDialog<bool>(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Confirmer la suppression'),
 content: Text(
 'Êtes-vous sûr de vouloir supprimer le fournisseur "${supplier.name}" ?\n'
 'Cette action est irréversible.',
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context, false),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () => Navigator.pop(context, true),
 style: TextButton.styleFrom(foregroundColor: Colors.red),
 child: const Text('Supprimer'),
 ),
 ],
 ),
 );

 if (confirmed == true) {{
 final success = await context.read<SupplierProvider>().deleteSupplier(supplier.id);
 
 if (success) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Fournisseur supprimé avec succès'),
 backgroundColor: Colors.green,
 ),
 );
 } else {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(context.read<SupplierProvider>().error ?? 
 'Erreur lors de la suppression'),
 backgroundColor: Colors.red,
 ),
 );
 }
}
 }

 Future<void> _updateSupplierStatus(Supplier supplier, SupplierStatus status) {async {
 final success = await context.read<SupplierProvider>()
 .updateSupplierStatus(supplier.id, status);
 
 if (success) {{
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('Statut mis à jour: ${_getStatusText(status)}'),
 backgroundColor: Colors.green,
 ),
 );
} else {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(context.read<SupplierProvider>().error ?? 
 'Erreur lors de la mise à jour du statut'),
 backgroundColor: Colors.red,
 ),
 );
}
 }

 Future<void> _exportSuppliers() {async {
 final downloadUrl = await context.read<SupplierProvider>()
 .exportSuppliers(format: 'csv');
 
 if (downloadUrl != null) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Export généré avec succès'),
 backgroundColor: Colors.green,
 ),
 );
} else {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(context.read<SupplierProvider>().error ?? 
 'Erreur lors de l\'export'),
 backgroundColor: Colors.red,
 ),
 );
}
 }

 String _getStatusText(SupplierStatus status) {
 switch (status) {
 case SupplierStatus.active:
 return 'Actif';
 case SupplierStatus.inactive:
 return 'Inactif';
 case SupplierStatus.pendingVerification:
 return 'En attente de vérification';
 case SupplierStatus.suspended:
 return 'Suspendu';
 case SupplierStatus.blacklisted:
 return 'Liste noire';
}
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Gestion des Fournisseurs'),
 actions: [
 IconButton(
 onPressed: _exportSuppliers,
 icon: const Icon(Icons.download),
 tooltip: 'Exporter',
 ),
 IconButton(
 onPressed: _toggleFilters,
 icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
 tooltip: 'Filtres',
 ),
 ],
 ),
 body: Consumer<SupplierProvider>(
 builder: (context, provider, child) {
 return LoadingOverlay(
 isLoading: provider.isLoading && provider.suppliers.isEmpty,
 child: Column(
 children: [
 // Barre de recherche
 Padding(
 padding: const EdgeInsets.all(1),
 child: CustomTextField(
 controller: _searchController,
 labelText: 'Rechercher un fournisseur...',
 prefixIcon: Icons.search,
 onChanged: _onSearchChanged,
 onSubmitted: _onSearchSubmitted,
 ),
 ),

 // Filtres
 if (_showFilters)
 S{upplierFilter(
 selectedCategory: provider.selectedCategory,
 selectedStatus: provider.selectedStatus,
 sortBy: provider.sortBy,
 sortAscending: provider.sortAscending,
 onCategoryChanged: (category) {
 provider.setCategoryFilter(category);
 provider.refreshSuppliers();
 },
 onStatusChanged: (status) {
 provider.setStatusFilter(status);
 provider.refreshSuppliers();
 },
 onSortChanged: (sortBy, ascending) {
 provider.setSorting(sortBy, ascending);
 provider.refreshSuppliers();
 },
 onClearFilters: () {
 provider.clearFilters();
 provider.refreshSuppliers();
 },
 ),

 // Statistiques
 if (provider.suppliers.isNotEmpty)
 C{ontainer(
 margin: const EdgeInsets.symmetric(1),
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
 ),
 ),
 child: Row(
 mainAxisAlignment: MainAxisAlignment.spaceAround,
 children: [
 _buildStatItem('Total', provider.suppliers.length.toString()),
 _buildStatItem('Actifs', provider.activeSuppliers.length.toString()),
 _buildStatItem('En attente', provider.pendingSuppliers.length.toString()),
 _buildStatItem('Suspendus', provider.suspendedSuppliers.length.toString()),
 ],
 ),
 ),

 const SizedBox(height: 16.0),

 // Liste des fournisseurs
 Expanded(
 child: provider.suppliers.isEmpty && !provider.isLoading
 ? _buildEmptyState()
 : _buildSuppliersList(provider),
 ),

 // Bouton flottant
 Positioned(
 bottom: 16.0,
 right: 16.0,
 child: FloatingActionButton(
 onPressed: () => _navigateToSupplierForm(),
 child: const Icon(Icons.add),
 tooltip: 'Ajouter un fournisseur',
 ),
 ),
 ],
 ),
 );
 },
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: () => _navigateToSupplierForm(),
 child: const Icon(Icons.add),
 tooltip: 'Ajouter un fournisseur',
 ),
 );
 }

 Widget _buildStatItem(String label, String value) {
 return Column(
 children: [
 Text(
 value,
 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
 fontWeight: FontWeight.bold,
 color: Theme.of(context).colorScheme.primary,
 ),
 ),
 const SizedBox(height: 4.0),
 Text(
 label,
 style: Theme.of(context).textTheme.bodySmall,
 ),
 ],
 );
 }

 Widget _buildEmptyState() {
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.business,
 size: 64.0,
 color: Theme.of(context).colorScheme.outline,
 ),
 const SizedBox(height: 16.0),
 Text(
 'Aucun fournisseur trouvé',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 8.0),
 Text(
 'Commencez par ajouter votre premier fournisseur',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Theme.of(context).colorScheme.outline,
 ),
 ),
 const SizedBox(height: 24.0),
 CustomButton(
 text: 'Ajouter un fournisseur',
 onPressed: () => _navigateToSupplierForm(),
 ),
 ],
 ),
 );
 }

 Widget _buildSuppliersList(SupplierProvider provider) {
 return RefreshIndicator(
 onRefresh: () async {
 await provider.refreshSuppliers();
 },
 child: ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.symmetric(1),
 itemCount: provider.suppliers.length + (provider.hasMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == provider.suppliers.length) {{
 return const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
}

 final supplier = provider.suppliers[index];
 return SupplierCard(
 supplier: supplier,
 onTap: () => _navigateToSupplierDetails(supplier),
 onEdit: () => _navigateToSupplierForm(supplier),
 onDelete: () => _deleteSupplier(supplier),
 onStatusUpdate: (status) => _updateSupplierStatus(supplier, status),
 );
 },
 ),
 );
 }
}

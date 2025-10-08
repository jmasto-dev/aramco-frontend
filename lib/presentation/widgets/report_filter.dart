import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/report.dart';

class ReportFilter extends StatefulWidget {
 final ReportCategory? selectedCategory;
 final ReportType? selectedType;
 final ReportStatus? selectedStatus;
 final String? searchQuery;
 final bool? isPublicFilter;
 final bool? isActiveFilter;
 final String sortBy;
 final bool sortAscending;
 final Function(ReportCategory?) onCategoryChanged;
 final Function(ReportType?) onTypeChanged;
 final Function(ReportStatus?) onStatusChanged;
 final Function(String?) onSearchChanged;
 final Function(bool?) onPublicFilterChanged;
 final Function(bool?) onActiveFilterChanged;
 final Function(String, bool) onSortChanged;
 final VoidCallback onClearFilters;

 const ReportFilter({
 Key? key,
 this.selectedCategory,
 this.selectedType,
 this.selectedStatus,
 this.searchQuery,
 this.isPublicFilter,
 this.isActiveFilter,
 this.sortBy = 'createdAt',
 this.sortAscending = false,
 required this.onCategoryChanged,
 required this.onTypeChanged,
 required this.onStatusChanged,
 required this.onSearchChanged,
 required this.onPublicFilterChanged,
 required this.onActiveFilterChanged,
 required this.onSortChanged,
 required this.onClearFilters,
 }) : super(key: key);

 @override
 State<ReportFilter> createState() => _ReportFilterState();
}

class _ReportFilterState extends State<ReportFilter> {
 late TextEditingController _searchController;
 bool _isExpanded = false;

 @override
 void initState() {
 super.initState();
 _searchController = TextEditingController(text: widget.searchQuery);
 _searchController.addListener(_onSearchChanged);
 }

 @override
 void dispose() {
 _searchController.removeListener(_onSearchChanged);
 _searchController.dispose();
 super.dispose();
 }

 void _onSearchChanged() {
 widget.onSearchChanged(_searchController.text.isEmpty ? null : _searchController.text);
 }

 @override
 Widget build(BuildContext context) {
 return Container(
 margin: const EdgeInsets.all(1),
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surfaceVariant,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête avec recherche et bouton d'expansion
 Row(
 children: [
 Expanded(
 child: TextField(
 controller: _searchController,
 decoration: InputDecoration(
 hintText: 'Rechercher des rapports...',
 prefixIcon: const Icon(Icons.search),
 suffixIcon: _searchController.text.isNotEmpty
 ? IconButton(
 onPressed: () => _searchController.clear(),
 icon: const Icon(Icons.clear),
 )
 : null,
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 ),
 ),
 const SizedBox(width: 12.0),
 IconButton(
 onPressed: () {
 setState(() {
 _isExpanded = !_isExpanded;
 });
 },
 icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
 tooltip: 'Filtres avancés',
 ),
 IconButton(
 onPressed: widget.onClearFilters,
 icon: const Icon(Icons.filter_list_off),
 tooltip: 'Effacer tous les filtres',
 ),
 ],
 ),
 
 // Filtres avancés
 if (_isExpanded) .{..[
 const SizedBox(height: 16.0),
 
 // Première ligne de filtres
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<ReportCategory?>(
 value: widget.selectedCategory,
 decoration: const InputDecoration(
 labelText: 'Catégorie',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem<ReportCategory?>(
 value: null,
 child: Text('Toutes les catégories'),
 ),
 ...ReportCategory.values.map((category) {
 return DropdownMenuItem<ReportCategory?>(
 value: category,
 child: Row(
 children: [
 Icon(_getCategoryIcon(category), size: 16.0),
 const SizedBox(width: 8.0),
 Text(_getCategoryText(category)),
 ],
 ),
 );
}),
 ],
 onChanged: widget.onCategoryChanged,
 ),
 ),
 const SizedBox(width: 12.0),
 Expanded(
 child: DropdownButtonFormField<ReportType?>(
 value: widget.selectedType,
 decoration: const InputDecoration(
 labelText: 'Type',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem<ReportType?>(
 value: null,
 child: Text('Tous les types'),
 ),
 ...ReportType.values.map((type) {
 return DropdownMenuItem<ReportType?>(
 value: type,
 child: Row(
 children: [
 Icon(_getTypeIcon(type), size: 16.0),
 const SizedBox(width: 8.0),
 Text(_getTypeText(type)),
 ],
 ),
 );
}),
 ],
 onChanged: widget.onTypeChanged,
 ),
 ),
 ],
 ),
 
 const SizedBox(height: 12.0),
 
 // Deuxième ligne de filtres
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<ReportStatus?>(
 value: widget.selectedStatus,
 decoration: const InputDecoration(
 labelText: 'Statut',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem<ReportStatus?>(
 value: null,
 child: Text('Tous les statuts'),
 ),
 ...ReportStatus.values.map((status) {
 return DropdownMenuItem<ReportStatus?>(
 value: status,
 child: Row(
 children: [
 const SizedBox(
 width: 12.0,
 height: 12.0,
 decoration: BoxDecoration(
 color: _getStatusColor(status),
 shape: BoxShape.circle,
 ),
 ),
 const SizedBox(width: 8.0),
 Text(_getStatusText(status)),
 ],
 ),
 );
}),
 ],
 onChanged: widget.onStatusChanged,
 ),
 ),
 const SizedBox(width: 12.0),
 Expanded(
 child: DropdownButtonFormField<bool?>(
 value: widget.isPublicFilter,
 decoration: const InputDecoration(
 labelText: 'Visibilité',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: const [
 DropdownMenuItem<bool?>(
 value: null,
 child: Text('Tous'),
 ),
 DropdownMenuItem<bool?>(
 value: true,
 child: Text('Public'),
 ),
 DropdownMenuItem<bool?>(
 value: false,
 child: Text('Privé'),
 ),
 ],
 onChanged: widget.onPublicFilterChanged,
 ),
 ),
 ],
 ),
 
 const SizedBox(height: 12.0),
 
 // Troisième ligne de filtres
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<bool?>(
 value: widget.isActiveFilter,
 decoration: const InputDecoration(
 labelText: 'État',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: const [
 DropdownMenuItem<bool?>(
 value: null,
 child: Text('Tous'),
 ),
 DropdownMenuItem<bool?>(
 value: true,
 child: Text('Actifs'),
 ),
 DropdownMenuItem<bool?>(
 value: false,
 child: Text('Inactifs'),
 ),
 ],
 onChanged: widget.onActiveFilterChanged,
 ),
 ),
 const SizedBox(width: 12.0),
 Expanded(
 child: DropdownButtonFormField<String>(
 value: widget.sortBy,
 decoration: const InputDecoration(
 labelText: 'Trier par',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: const [
 DropdownMenuItem<String>(
 value: 'name',
 child: Text('Nom'),
 ),
 DropdownMenuItem<String>(
 value: 'createdAt',
 child: Text('Date de création'),
 ),
 DropdownMenuItem<String>(
 value: 'updatedAt',
 child: Text('Date de modification'),
 ),
 DropdownMenuItem<String>(
 value: 'runCount',
 child: Text('Nombre d\'exécutions'),
 ),
 DropdownMenuItem<String>(
 value: 'lastRunAt',
 child: Text('Dernière exécution'),
 ),
 ],
 onChanged: (value) {
 if (value != null) {{
 widget.onSortChanged(value, widget.sortAscending);
}
 },
 ),
 ),
 ],
 ),
 
 const SizedBox(height: 12.0),
 
 // Ordre de tri
 Row(
 children: [
 Text(
 'Ordre de tri:',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(width: 16.0),
 ChoiceChip(
 label: const Text('Croissant'),
 selected: widget.sortAscending,
 onSelected: (selected) {
 widget.onSortChanged(widget.sortBy, true);
 },
 ),
 const SizedBox(width: 8.0),
 ChoiceChip(
 label: const Text('Décroissant'),
 selected: !widget.sortAscending,
 onSelected: (selected) {
 widget.onSortChanged(widget.sortBy, false);
 },
 ),
 ],
 ),
 
 const SizedBox(height: 16.0),
 
 // Résumé des filtres actifs
 _buildActiveFiltersSummary(context),
 ],
 ],
 ),
 );
 }

 Widget _buildActiveFiltersSummary(BuildContext context) {
 final activeFilters = <String>[];
 
 if (widget.selectedCategory != null) {{
 activeFilters.add('Catégorie: ${_getCategoryText(widget.selectedCategory!)}');
}
 if (widget.selectedType != null) {{
 activeFilters.add('Type: ${_getTypeText(widget.selectedType!)}');
}
 if (widget.selectedStatus != null) {{
 activeFilters.add('Statut: ${_getStatusText(widget.selectedStatus!)}');
}
 if (widget.isPublicFilter != null) {{
 activeFilters.add(widget.isPublicFilter! ? 'Public' : 'Privé');
}
 if (widget.isActiveFilter != null) {{
 activeFilters.add(widget.isActiveFilter! ? 'Actifs' : 'Inactifs');
}
 if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {{
 activeFilters.add('Recherche: "${widget.searchQuery}"');
}
 
 if (activeFilters.isEmpty) {{
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
 ),
 ),
 child: Text(
 'Aucun filtre actif',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Theme.of(context).colorScheme.outline,
 ),
 ),
 );
}
 
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.primaryContainer,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Filtres actifs (${activeFilters.length}):',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 fontWeight: FontWeight.bold,
 color: Theme.of(context).colorScheme.onPrimaryContainer,
 ),
 ),
 const SizedBox(height: 4.0),
 Wrap(
 spacing: 8.0,
 runSpacing: 4.0,
 children: activeFilters.map((filter) {
 return Chip(
 label: Text(
 filter,
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Theme.of(context).colorScheme.onPrimaryContainer,
 ),
 ),
 backgroundColor: Theme.of(context).colorScheme.primaryContainer,
 visualDensity: VisualDensity.compact,
 );
}).toList(),
 ),
 ],
 ),
 );
 }

 IconData _getCategoryIcon(ReportCategory category) {
 switch (category) {
 case ReportCategory.financial:
 return Icons.attach_money;
 case ReportCategory.operational:
 return Icons.settings;
 case ReportCategory.hr:
 return Icons.people;
 case ReportCategory.sales:
 return Icons.trending_up;
 case ReportCategory.purchasing:
 return Icons.shopping_cart;
 case ReportCategory.inventory:
 return Icons.inventory;
 case ReportCategory.custom:
 return Icons.category;
}
 }

 String _getCategoryText(ReportCategory category) {
 switch (category) {
 case ReportCategory.financial:
 return 'Financier';
 case ReportCategory.operational:
 return 'Opérationnel';
 case ReportCategory.hr:
 return 'RH';
 case ReportCategory.sales:
 return 'Ventes';
 case ReportCategory.purchasing:
 return 'Achats';
 case ReportCategory.inventory:
 return 'Inventaire';
 case ReportCategory.custom:
 return 'Personnalisé';
}
 }

 IconData _getTypeIcon(ReportType type) {
 switch (type) {
 case ReportType.tabular:
 return Icons.table_chart;
 case ReportType.summary:
 return Icons.summarize;
 case ReportType.chart:
 return Icons.bar_chart;
 case ReportType.dashboard:
 return Icons.dashboard;
 case ReportType.crosstab:
 return Icons.grid_on;
}
 }

 String _getTypeText(ReportType type) {
 switch (type) {
 case ReportType.tabular:
 return 'Tabulaire';
 case ReportType.summary:
 return 'Résumé';
 case ReportType.chart:
 return 'Graphique';
 case ReportType.dashboard:
 return 'Tableau de bord';
 case ReportType.crosstab:
 return 'Tableau croisé';
}
 }

 Color _getStatusColor(ReportStatus status) {
 switch (status) {
 case ReportStatus.draft:
 return Colors.grey;
 case ReportStatus.ready:
 return Colors.blue;
 case ReportStatus.running:
 return Colors.orange;
 case ReportStatus.completed:
 return Colors.green;
 case ReportStatus.failed:
 return Colors.red;
 case ReportStatus.cancelled:
 return Colors.black;
}
 }

 String _getStatusText(ReportStatus status) {
 switch (status) {
 case ReportStatus.draft:
 return 'Brouillon';
 case ReportStatus.ready:
 return 'Prêt';
 case ReportStatus.running:
 return 'En cours';
 case ReportStatus.completed:
 return 'Terminé';
 case ReportStatus.failed:
 return 'Échoué';
 case ReportStatus.cancelled:
 return 'Annulé';
}
 }
}

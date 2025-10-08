import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/supplier.dart';

class SupplierFilter extends StatelessWidget {
 final SupplierCategory? selectedCategory;
 final SupplierStatus? selectedStatus;
 final String sortBy;
 final bool sortAscending;
 final Function(SupplierCategory?) onCategoryChanged;
 final Function(SupplierStatus?) onStatusChanged;
 final Function(String, bool) onSortChanged;
 final VoidCallback onClearFilters;

 const SupplierFilter({
 Key? key,
 this.selectedCategory,
 this.selectedStatus,
 required this.sortBy,
 required this.sortAscending,
 required this.onCategoryChanged,
 required this.onStatusChanged,
 required this.onSortChanged,
 required this.onClearFilters,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 return Container(
 margin: const EdgeInsets.symmetric(1),
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête des filtres
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Filtres',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 TextButton(
 onPressed: onClearFilters,
 child: const Text('Effacer'),
 ),
 ],
 ),
 
 const SizedBox(height: 16.0),
 
 // Filtre par catégorie
 Text(
 'Catégorie',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8.0),
 Wrap(
 spacing: 8.0,
 runSpacing: 8.0,
 children: [
 FilterChip(
 label: const Text('Toutes'),
 selected: selectedCategory == null,
 onSelected: (selected) {
 onCategoryChanged(selected ? null : selectedCategory);
 },
 ),
 ...SupplierCategory.values.map((category) {
 return FilterChip(
 label: Text(_getCategoryText(category)),
 selected: selectedCategory == category,
 onSelected: (selected) {
 onCategoryChanged(selected ? category : null);
 },
 );
 }).toList(),
 ],
 ),
 
 const SizedBox(height: 16.0),
 
 // Filtre par statut
 Text(
 'Statut',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8.0),
 Wrap(
 spacing: 8.0,
 runSpacing: 8.0,
 children: [
 FilterChip(
 label: const Text('Tous'),
 selected: selectedStatus == null,
 onSelected: (selected) {
 onStatusChanged(selected ? null : selectedStatus);
 },
 ),
 ...SupplierStatus.values.map((status) {
 return FilterChip(
 label: Text(_getStatusText(status)),
 selected: selectedStatus == status,
 onSelected: (selected) {
 onStatusChanged(selected ? status : null);
 },
 );
 }).toList(),
 ],
 ),
 
 const SizedBox(height: 16.0),
 
 // Tri
 Text(
 'Tri par',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8.0),
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<String>(
 value: sortBy,
 decoration: const InputDecoration(
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: const [
 DropdownMenuItem(value: 'name', child: Text('Nom')),
 DropdownMenuItem(value: 'createdAt', child: Text('Date de création')),
 DropdownMenuItem(value: 'averageRating', child: Text('Évaluation')),
 DropdownMenuItem(value: 'city', child: Text('Ville')),
 ],
 onChanged: (value) {
 if (value != null) {{
 onSortChanged(value, sortAscending);
 }
 },
 ),
 ),
 const SizedBox(width: 8.0),
 IconButton(
 onPressed: () {
 onSortChanged(sortBy, !sortAscending);
 },
 icon: Icon(
 sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
 ),
 tooltip: sortAscending ? 'Croissant' : 'Décroissant',
 ),
 ],
 ),
 ],
 ),
 );
 }

 String _getCategoryText(SupplierCategory category) {
 switch (category) {
 case SupplierCategory.rawMaterials:
 return 'Matières premières';
 case SupplierCategory.equipment:
 return 'Équipements';
 case SupplierCategory.services:
 return 'Services';
 case SupplierCategory.consumables:
 return 'Consommables';
 case SupplierCategory.technology:
 return 'Technologie';
 case SupplierCategory.logistics:
 return 'Logistique';
 case SupplierCategory.consulting:
 return 'Consulting';
 case SupplierCategory.other:
 return 'Autre';
}
 }

 String _getStatusText(SupplierStatus status) {
 switch (status) {
 case SupplierStatus.active:
 return 'Actif';
 case SupplierStatus.inactive:
 return 'Inactif';
 case SupplierStatus.pendingVerification:
 return 'En attente';
 case SupplierStatus.suspended:
 return 'Suspendu';
 case SupplierStatus.blacklisted:
 return 'Liste noire';
 case SupplierStatus.underReview:
 return 'En révision';
}
 }
}

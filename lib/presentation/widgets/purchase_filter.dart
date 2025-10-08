import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/purchase_request.dart';

class PurchaseFilter extends StatelessWidget {
 final PurchaseRequestStatus? selectedStatus;
 final PurchaseRequestType? selectedType;
 final PurchaseRequestPriority? selectedPriority;
 final String? searchQuery;
 final DateTime? startDate;
 final DateTime? endDate;
 final double? minAmount;
 final double? maxAmount;
 final String sortBy;
 final bool sortAscending;
 final Function(PurchaseRequestStatus?) onStatusChanged;
 final Function(PurchaseRequestType?) onTypeChanged;
 final Function(PurchaseRequestPriority?) onPriorityChanged;
 final Function(String?) onSearchChanged;
 final Function(DateTime?, DateTime?) onDateRangeChanged;
 final Function(double?, double?) onAmountRangeChanged;
 final Function(String, bool) onSortChanged;
 final VoidCallback onClearFilters;

 const PurchaseFilter({
 Key? key,
 this.selectedStatus,
 this.selectedType,
 this.selectedPriority,
 this.searchQuery,
 this.startDate,
 this.endDate,
 this.minAmount,
 this.maxAmount,
 required this.sortBy,
 required this.sortAscending,
 required this.onStatusChanged,
 required this.onTypeChanged,
 required this.onPriorityChanged,
 required this.onSearchChanged,
 required this.onDateRangeChanged,
 required this.onAmountRangeChanged,
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
 
 // Recherche
 TextField(
 decoration: const InputDecoration(
 labelText: 'Recherche',
 hintText: 'Numéro, titre ou description...',
 prefixIcon: Icon(Icons.search),
 border: OutlineInputBorder(),
 ),
 onChanged: onSearchChanged,
 controller: TextEditingController(text: searchQuery),
 ),
 
 const SizedBox(height: 16.0),
 
 // Filtres par statut, type et priorité
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<PurchaseRequestStatus>(
 value: selectedStatus,
 decoration: const InputDecoration(
 labelText: 'Statut',
 border: OutlineInputBorder(),
 ),
 items: [
 const DropdownMenuItem(
 value: null,
 child: Text('Tous'),
 ),
 ...PurchaseRequestStatus.values.map((status) {
 return DropdownMenuItem(
 value: status,
 child: Text(_getStatusText(status)),
 );
 }).toList(),
 ],
 onChanged: onStatusChanged,
 ),
 ),
 const SizedBox(width: 8.0),
 Expanded(
 child: DropdownButtonFormField<PurchaseRequestType>(
 value: selectedType,
 decoration: const InputDecoration(
 labelText: 'Type',
 border: OutlineInputBorder(),
 ),
 items: [
 const DropdownMenuItem(
 value: null,
 child: Text('Tous'),
 ),
 ...PurchaseRequestType.values.map((type) {
 return DropdownMenuItem(
 value: type,
 child: Text(_getTypeText(type)),
 );
 }).toList(),
 ],
 onChanged: onTypeChanged,
 ),
 ),
 ],
 ),
 
 const SizedBox(height: 16.0),
 
 // Priorité
 DropdownButtonFormField<PurchaseRequestPriority>(
 value: selectedPriority,
 decoration: const InputDecoration(
 labelText: 'Priorité',
 border: OutlineInputBorder(),
 ),
 items: [
 const DropdownMenuItem(
 value: null,
 child: Text('Toutes'),
 ),
 ...PurchaseRequestPriority.values.map((priority) {
 return DropdownMenuItem(
 value: priority,
 child: Text(_getPriorityText(priority)),
 );
 }).toList(),
 ],
 onChanged: onPriorityChanged,
 ),
 
 const SizedBox(height: 16.0),
 
 // Plage de dates
 Text(
 'Plage de dates',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8.0),
 Row(
 children: [
 Expanded(
 child: InkWell(
 onTap: () => _selectStartDate(context),
 child: InputDecorator(
 decoration: const InputDecoration(
 labelText: 'Date de début',
 border: OutlineInputBorder(),
 suffixIcon: Icon(Icons.calendar_today),
 ),
 child: Text(
 startDate != null 
 ? _formatDate(startDate!)
 : 'Sélectionner',
 ),
 ),
 ),
 ),
 const SizedBox(width: 8.0),
 Expanded(
 child: InkWell(
 onTap: () => _selectEndDate(context),
 child: InputDecorator(
 decoration: const InputDecoration(
 labelText: 'Date de fin',
 border: OutlineInputBorder(),
 suffixIcon: Icon(Icons.calendar_today),
 ),
 child: Text(
 endDate != null 
 ? _formatDate(endDate!)
 : 'Sélectionner',
 ),
 ),
 ),
 ),
 ],
 ),
 
 const SizedBox(height: 16.0),
 
 // Plage de montants
 Text(
 'Plage de montants',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8.0),
 Row(
 children: [
 Expanded(
 child: TextField(
 decoration: const InputDecoration(
 labelText: 'Montant minimum',
 border: OutlineInputBorder(),
 prefixText: '€',
 ),
 keyboardType: TextInputType.number,
 onChanged: (value) {
 final amount = double.tryParse(value);
 onAmountRangeChanged(amount, maxAmount);
 },
 controller: TextEditingController(
 text: minAmount?.toStringAsFixed(2),
 ),
 ),
 ),
 const SizedBox(width: 8.0),
 Expanded(
 child: TextField(
 decoration: const InputDecoration(
 labelText: 'Montant maximum',
 border: OutlineInputBorder(),
 prefixText: '€',
 ),
 keyboardType: TextInputType.number,
 onChanged: (value) {
 final amount = double.tryParse(value);
 onAmountRangeChanged(minAmount, amount);
 },
 controller: TextEditingController(
 text: maxAmount?.toStringAsFixed(2),
 ),
 ),
 ),
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
 DropdownMenuItem(value: 'requestDate', child: Text('Date de demande')),
 DropdownMenuItem(value: 'title', child: Text('Titre')),
 DropdownMenuItem(value: 'totalAmount', child: Text('Montant')),
 DropdownMenuItem(value: 'requesterName', child: Text('Demandeur')),
 DropdownMenuItem(value: 'priority', child: Text('Priorité')),
 DropdownMenuItem(value: 'requiredDate', child: Text('Date requise')),
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

 Future<void> _selectStartDate(BuildContext context) {async {
 final DateTime? picked = await showDatePicker(
 context: context,
 initialDate: startDate ?? DateTime.now(),
 firstDate: DateTime(2020),
 lastDate: DateTime.now().add(const Duration(days: 365)),
 );
 if (picked != null) {{
 onDateRangeChanged(picked, endDate);
}
 }

 Future<void> _selectEndDate(BuildContext context) {async {
 final DateTime? picked = await showDatePicker(
 context: context,
 initialDate: endDate ?? DateTime.now(),
 firstDate: startDate ?? DateTime(2020),
 lastDate: DateTime.now().add(const Duration(days: 365)),
 );
 if (picked != null) {{
 onDateRangeChanged(startDate, picked);
}
 }

 String _getStatusText(PurchaseRequestStatus status) {
 switch (status) {
 case PurchaseRequestStatus.draft:
 return 'Brouillon';
 case PurchaseRequestStatus.pendingApproval:
 return 'En attente';
 case PurchaseRequestStatus.approved:
 return 'Approuvée';
 case PurchaseRequestStatus.rejected:
 return 'Rejetée';
 case PurchaseRequestStatus.completed:
 return 'Terminée';
 case PurchaseRequestStatus.cancelled:
 return 'Annulée';
 case PurchaseRequestStatus.onHold:
 return 'En pause';
}
 }

 String _getTypeText(PurchaseRequestType type) {
 switch (type) {
 case PurchaseRequestType.standard:
 return 'Standard';
 case PurchaseRequestType.urgent:
 return 'Urgent';
 case PurchaseRequestType.contract:
 return 'Contrat';
 case PurchaseRequestType.service:
 return 'Service';
 case PurchaseRequestType.asset:
 return 'Actif';
}
 }

 String _getPriorityText(PurchaseRequestPriority priority) {
 switch (priority) {
 case PurchaseRequestPriority.low:
 return 'Basse';
 case PurchaseRequestPriority.medium:
 return 'Moyenne';
 case PurchaseRequestPriority.high:
 return 'Haute';
 case PurchaseRequestPriority.critical:
 return 'Critique';
}
 }

 String _formatDate(DateTime date) {
 return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
 }
}

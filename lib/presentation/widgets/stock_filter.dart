import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/warehouse.dart';
import '../../core/models/stock_item.dart';

class StockFilter extends StatelessWidget {
 final List<Warehouse> warehouses;
 final String? selectedWarehouseId;
 final StockStatus? selectedStatus;
 final Function(String?) onWarehouseChanged;
 final Function(StockStatus?) onStatusChanged;
 final VoidCallback onClearFilters;

 const StockFilter({
 Key? key,
 required this.warehouses,
 this.selectedWarehouseId,
 this.selectedStatus,
 required this.onWarehouseChanged,
 required this.onStatusChanged,
 required this.onClearFilters,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 const Icon(Icons.filter_list, size: 20),
 const SizedBox(width: 8),
 const Text(
 'Filtres',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.bold,
 ),
 ),
 const Spacer(),
 if (selectedWarehouseId != null || selectedStatus != null)
 T{extButton.icon(
 onPressed: onClearFilters,
 icon: const Icon(Icons.clear, size: 16),
 label: const Text('Effacer'),
 style: TextButton.styleFrom(
 padding: const EdgeInsets.symmetric(1),
 minimumSize: Size.zero,
 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 Row(
 children: [
 Expanded(
 child: _buildWarehouseDropdown(),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: _buildStatusDropdown(),
 ),
 ],
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildWarehouseDropdown() {
 return DropdownButtonFormField<String>(
 value: selectedWarehouseId,
 decoration: const InputDecoration(
 labelText: 'Entrepôt',
 hintText: 'Tous les entrepôts',
 prefixIcon: Icon(Icons.warehouse),
 border: OutlineInputBorder(),
 isDense: true,
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem<String>(
 value: null,
 child: Text('Tous les entrepôts'),
 ),
 ...warehouses.map((warehouse) => DropdownMenuItem<String>(
 value: warehouse.id,
 child: Text(warehouse.name),
 )),
 ],
 onChanged: onWarehouseChanged,
 );
 }

 Widget _buildStatusDropdown() {
 return DropdownButtonFormField<StockStatus>(
 value: selectedStatus,
 decoration: const InputDecoration(
 labelText: 'Statut',
 hintText: 'Tous les statuts',
 prefixIcon: Icon(Icons.info_outline),
 border: OutlineInputBorder(),
 isDense: true,
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem<StockStatus>(
 value: null,
 child: Text('Tous les statuts'),
 ),
 ...StockStatus.values.map((status) => DropdownMenuItem<StockStatus>(
 value: status,
 child: Text(_getStatusText(status)),
 )),
 ],
 onChanged: onStatusChanged,
 );
 }

 String _getStatusText(StockStatus status) {
 switch (status) {
 case StockStatus.inStock:
 return 'En stock';
 case StockStatus.lowStock:
 return 'Stock faible';
 case StockStatus.outOfStock:
 return 'Rupture de stock';
 case StockStatus.expired:
 return 'Expiré';
 case StockStatus.reserved:
 return 'Réservé';
 case StockStatus.inTransit:
 return 'En transit';
}
 }
}

class StockSearchFilter extends StatefulWidget {
 final String? searchQuery;
 final Function(String?) onSearchChanged;
 final VoidCallback onSearch;
 final VoidCallback onClear;

 const StockSearchFilter({
 Key? key,
 this.searchQuery,
 required this.onSearchChanged,
 required this.onSearch,
 required this.onClear,
 }) : super(key: key);

 @override
 State<StockSearchFilter> createState() => _StockSearchFilterState();
}

class _StockSearchFilterState extends State<StockSearchFilter> {
 late TextEditingController _searchController;
 bool _isSearchFocused = false;

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
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Row(
 children: [
 Expanded(
 child: Focus(
 onFocusChange: (hasFocus) {
 setState(() {
 _isSearchFocused = hasFocus;
 });
 },
 child: TextField(
 controller: _searchController,
 decoration: InputDecoration(
 labelText: 'Rechercher un article',
 hintText: 'Nom, SKU, emplacement...',
 prefixIcon: const Icon(Icons.search),
 suffixIcon: _searchController.text.isNotEmpty
 ? IconButton(
 icon: const Icon(Icons.clear),
 onPressed: () {
 _searchController.clear();
 widget.onClear();
},
 )
 : null,
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 focusedBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(
 color: Theme.of(context).colorScheme.primary,
 width: 2,
 ),
 ),
 filled: true,
 fillColor: _isSearchFocused ? Colors.transparent : Colors.grey.shade50,
 ),
 onSubmitted: (_) => widget.onSearch(),
 ),
 ),
 ),
 const SizedBox(width: 12),
 ElevatedButton.icon(
 onPressed: widget.onSearch,
 icon: const Icon(Icons.search),
 label: const Text('Rechercher'),
 style: ElevatedButton.styleFrom(
 padding: const EdgeInsets.symmetric(1),
 ),
 ),
 ],
 ),
 ),
 );
 }
}

class StockAdvancedFilter extends StatefulWidget {
 final List<Warehouse> warehouses;
 final String? selectedWarehouseId;
 final StockStatus? selectedStatus;
 final bool? onlyLowStock;
 final bool? onlyExpiring;
 final bool? onlyExpired;
 final Function(String?) onWarehouseChanged;
 final Function(StockStatus?) onStatusChanged;
 final Function(bool?) onLowStockChanged;
 final Function(bool?) onExpiringChanged;
 final Function(bool?) onExpiredChanged;
 final VoidCallback onClearFilters;
 final VoidCallback onApplyFilters;

 const StockAdvancedFilter({
 Key? key,
 required this.warehouses,
 this.selectedWarehouseId,
 this.selectedStatus,
 this.onlyLowStock,
 this.onlyExpiring,
 this.onlyExpired,
 required this.onWarehouseChanged,
 required this.onStatusChanged,
 required this.onLowStockChanged,
 required this.onExpiringChanged,
 required this.onExpiredChanged,
 required this.onClearFilters,
 required this.onApplyFilters,
 }) : super(key: key);

 @override
 State<StockAdvancedFilter> createState() => _StockAdvancedFilterState();
}

class _StockAdvancedFilterState extends State<StockAdvancedFilter> {
 @override
 Widget build(BuildContext context) {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 const Icon(Icons.tune, size: 20),
 const SizedBox(width: 8),
 const Text(
 'Filtres avancés',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.bold,
 ),
 ),
 const Spacer(),
 TextButton(
 onPressed: widget.onClearFilters,
 child: const Text('Réinitialiser'),
 ),
 ],
 ),
 const SizedBox(height: 16),
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<String>(
 value: widget.selectedWarehouseId,
 decoration: const InputDecoration(
 labelText: 'Entrepôt',
 prefixIcon: Icon(Icons.warehouse),
 border: OutlineInputBorder(),
 isDense: true,
 ),
 items: [
 const DropdownMenuItem<String>(
 value: null,
 child: Text('Tous les entrepôts'),
 ),
 ...widget.warehouses.map((warehouse) => DropdownMenuItem<String>(
 value: warehouse.id,
 child: Text(warehouse.name),
 )),
 ],
 onChanged: widget.onWarehouseChanged,
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: DropdownButtonFormField<StockStatus>(
 value: widget.selectedStatus,
 decoration: const InputDecoration(
 labelText: 'Statut',
 prefixIcon: Icon(Icons.info_outline),
 border: OutlineInputBorder(),
 isDense: true,
 ),
 items: [
 const DropdownMenuItem<StockStatus>(
 value: null,
 child: Text('Tous les statuts'),
 ),
 ...StockStatus.values.map((status) => DropdownMenuItem<StockStatus>(
 value: status,
 child: Text(_getStatusText(status)),
 )),
 ],
 onChanged: widget.onStatusChanged,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 const Text(
 'Alertes',
 style: const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 Row(
 children: [
 Expanded(
 child: CheckboxListTile(
 title: const Text('Stock faible'),
 value: widget.onlyLowStock ?? false,
 onChanged: widget.onLowStockChanged,
 dense: true,
 contentPadding: const EdgeInsets.zero,
 ),
 ),
 Expanded(
 child: CheckboxListTile(
 title: const Text('Expire bientôt'),
 value: widget.onlyExpiring ?? false,
 onChanged: widget.onExpiringChanged,
 dense: true,
 contentPadding: const EdgeInsets.zero,
 ),
 ),
 Expanded(
 child: CheckboxListTile(
 title: const Text('Expiré'),
 value: widget.onlyExpired ?? false,
 onChanged: widget.onExpiredChanged,
 dense: true,
 contentPadding: const EdgeInsets.zero,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 const SizedBox(
 width: double.infinity,
 child: ElevatedButton.icon(
 onPressed: widget.onApplyFilters,
 icon: const Icon(Icons.filter_list),
 label: const Text('Appliquer les filtres'),
 style: ElevatedButton.styleFrom(
 padding: const EdgeInsets.symmetric(1),
 ),
 ),
 ),
 ],
 ),
 ),
 );
 }

 String _getStatusText(StockStatus status) {
 switch (status) {
 case StockStatus.inStock:
 return 'En stock';
 case StockStatus.lowStock:
 return 'Stock faible';
 case StockStatus.outOfStock:
 return 'Rupture de stock';
 case StockStatus.expired:
 return 'Expiré';
 case StockStatus.reserved:
 return 'Réservé';
 case StockStatus.inTransit:
 return 'En transit';
}
 }
}

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/services/search_service.dart';

class SearchFiltersWidget extends StatefulWidget {
 final SearchFilters? filters;
 final Function(SearchFilters) onFiltersChanged;

 const SearchFiltersWidget({
 Key? key,
 this.filters,
 required this.onFiltersChanged,
 }) : super(key: key);

 @override
 State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget> {
 late List<String> _selectedTypes;
 String? _selectedDateRange;
 DateTime? _startDate;
 DateTime? _endDate;

 final List<String> _availableTypes = [
 'employee',
 'order',
 'product',
 'supplier',
 'leave_request',
 'payslip',
 'performance_review',
 'purchase_request',
 'report',
 'notification',
 ];

 final List<Map<String, String?>> _dateRanges = [
 {'value': null, 'label': 'Toutes les dates'},
 {'value': 'today', 'label': "Aujourd'hui"},
 {'value': 'yesterday', 'label': 'Hier'},
 {'value': 'week', 'label': 'Cette semaine'},
 {'value': 'month', 'label': 'Ce mois'},
 {'value': 'quarter', 'label': 'Ce trimestre'},
 {'value': 'year', 'label': 'Cette année'},
 {'value': 'custom', 'label': 'Personnalisée'},
 ];

 @override
 void initState() {
 super.initState();
 _initializeFilters();
 }

 void _initializeFilters() {
 if (widget.filters != null) {{
 _selectedTypes = List.from(widget.filters!.types);
 _selectedDateRange = widget.filters!.dateRange;
 _startDate = widget.filters!.startDate;
 _endDate = widget.filters!.endDate;
} else {
 _selectedTypes = [];
 _selectedDateRange = null;
 _startDate = null;
 _endDate = null;
}
 }

 void _applyFilters() {
 final filters = SearchFilters(
 types: _selectedTypes,
 dateRange: _selectedDateRange,
 startDate: _startDate,
 endDate: _endDate,
 );
 widget.onFiltersChanged(filters);
 Navigator.of(context).pop();
 }

 void _clearFilters() {
 setState(() {
 _selectedTypes.clear();
 _selectedDateRange = null;
 _startDate = null;
 _endDate = null;
});
 _applyFilters();
 }

 @override
 Widget build(BuildContext context) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Filtres de recherche',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 TextButton(
 onPressed: _clearFilters,
 child: const Text('Effacer tout'),
 ),
 ],
 ),
 const SizedBox(height: 16),

 // Types de contenu
 Expanded(
 child: SingleChildScrollView(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildSectionTitle('Types de contenu'),
 const SizedBox(height: 8),
 _buildTypeFilters(),
 const SizedBox(height: 24),

 // Plage de dates
 _buildSectionTitle('Plage de dates'),
 const SizedBox(height: 8),
 _buildDateRangeFilters(),
 if (_selectedDateRange == 'custom') .{..[
 const SizedBox(height: 16),
 _buildCustomDateRange(),
 ],
 const SizedBox(height: 24),

 // Boutons d'action
 _buildActionButtons(),
 ],
 ),
 ),
 ),
 ],
 );
 }

 Widget _buildSectionTitle(String title) {
 return Text(
 title,
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w600,
 color: Colors.grey[800],
 ),
 );
 }

 Widget _buildTypeFilters() {
 return Wrap(
 spacing: 8,
 runSpacing: 8,
 children: _availableTypes.map((type) {
 final isSelected = _selectedTypes.contains(type);
 return FilterChip(
 label: Text(_getTypeLabel(type)),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 if (selected) {{
 _selectedTypes.add(type);
 } else {
 _selectedTypes.remove(type);
 }
});
},
 backgroundColor: Colors.white,
 selectedColor: Theme.of(context).colorScheme.primary,
 checkmarkColor: Colors.white,
 side: BorderSide(
 color: Colors.grey[300]!,
 ),
 );
 }).toList(),
 );
 }

 Widget _buildDateRangeFilters() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Chips de plage de dates prédéfinies
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: _dateRanges.map((dateRange) {
 final isSelected = _selectedDateRange == dateRange['value'];
 return FilterChip(
 label: Text(dateRange['label']!),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 if (selected) {{
 _selectedDateRange = dateRange['value'];
 if (dateRange['value'] != 'custom') {{
 _startDate = null;
 _endDate = null;
 }
 } else {
 _selectedDateRange = null;
 _startDate = null;
 _endDate = null;
 }
 });
 },
 backgroundColor: Colors.white,
 selectedColor: Theme.of(context).colorScheme.primary,
 checkmarkColor: Colors.white,
 side: BorderSide(
 color: Colors.grey[300]!,
 ),
 );
}).toList(),
 ),
 ],
 );
 }

 Widget _buildCustomDateRange() {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.grey[50],
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: Colors.grey[300]!,
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Plage de dates personnalisée',
 style: const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.w600,
 color: Colors.grey[700],
 ),
 ),
 const SizedBox(height: 12),
 Row(
 children: [
 Expanded(
 child: _buildDateField(
 'Date de début',
 _startDate,
 (date) => setState(() => _startDate = date),
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: _buildDateField(
 'Date de fin',
 _endDate,
 (date) => setState(() => _endDate = date),
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildDateField(
 String label,
 DateTime? date,
 Function(DateTime?) onChanged,
 ) {
 return InkWell(
 onTap: () async {
 final selectedDate = await showDatePicker(
 context: context,
 initialDate: date ?? DateTime.now(),
 firstDate: DateTime(2020),
 lastDate: DateTime.now().add(const Duration(days: 365)),
 );
 if (selectedDate != null) {{
 onChanged(selectedDate);
 }
 },
 child: Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 border: Border.all(color: Colors.grey[300]!),
 borderRadius: const Borderconst Radius.circular(1),
 color: Colors.white,
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 label,
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(height: 4),
 Row(
 children: [
 Icon(
 Icons.calendar_today,
 size: 16,
 color: Colors.grey[600],
 ),
 const SizedBox(width: 8),
 Expanded(
 child: Text(
 date != null
 ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
 : 'Sélectionner une date',
 style: const TextStyle(
 fontSize: 14,
 color: date != null ? Colors.black87 : Colors.grey[500],
 ),
 ),
 ),
 ],
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildActionButtons() {
 return Row(
 children: [
 Expanded(
 child: OutlinedButton(
 onPressed: () => Navigator.of(context).pop(),
 child: const Text('Annuler'),
 style: OutlinedButton.styleFrom(
 padding: const EdgeInsets.symmetric(1),
 ),
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: ElevatedButton(
 onPressed: _applyFilters,
 child: const Text('Appliquer les filtres'),
 style: ElevatedButton.styleFrom(
 backgroundColor: Theme.of(context).colorScheme.primary,
 foregroundColor: Colors.white,
 padding: const EdgeInsets.symmetric(1),
 ),
 ),
 ),
 ],
 );
 }

 String _getTypeLabel(String type) {
 switch (type.toLowerCase()) {
 case 'employee':
 return 'Employés';
 case 'order':
 return 'Commandes';
 case 'product':
 return 'Produits';
 case 'supplier':
 return 'Fournisseurs';
 case 'leave_request':
 return 'Congés';
 case 'payslip':
 return 'Paies';
 case 'performance_review':
 return 'Évaluations';
 case 'purchase_request':
 return 'Achats';
 case 'report':
 return 'Rapports';
 case 'notification':
 return 'Notifications';
 default:
 return type;
}
 }
}

// Widget compact pour les filtres rapides
class QuickSearchFilters extends StatelessWidget {
 final List<String> selectedTypes;
 final Function(String) onTypeSelected;

 const QuickSearchFilters({
 Key? key,
 required this.selectedTypes,
 required this.onTypeSelected,
 }) : super(key: key);

 final List<Map<String, dynamic>> _filterOptions = const [
 {'value': 'all', 'label': 'Tous', 'icon': Icons.apps},
 {'value': 'employee', 'label': 'Employés', 'icon': Icons.person},
 {'value': 'order', 'label': 'Commandes', 'icon': Icons.shopping_cart},
 {'value': 'product', 'label': 'Produits', 'icon': Icons.inventory_2},
 {'value': 'supplier', 'label': 'Fournisseurs', 'icon': Icons.business},
 {'value': 'leave_request', 'label': 'Congés', 'icon': Icons.event},
 {'value': 'payslip', 'label': 'Paies', 'icon': Icons.attach_money},
 ];

 @override
 Widget build(BuildContext context) {
 return Container(
 height: 50,
 padding: const EdgeInsets.symmetric(1),
 child: ListView.builder(
 scrollDirection: Axis.horizontal,
 itemCount: _filterOptions.length,
 itemBuilder: (context, index) {
 final option = _filterOptions[index];
 final isSelected = option['value'] == 'all'
 ? selectedTypes.isEmpty
 : selectedTypes.contains(option['value']);

 return Container(
 margin: const EdgeInsets.only(right: 8),
 child: FilterChip(
 label: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 option['icon'] as IconData,
 size: 16,
 color: isSelected ? Colors.white : Colors.grey[600],
 ),
 const SizedBox(width: 6),
 Text(option['label'] as String),
 ],
 ),
 selected: isSelected,
 onSelected: (selected) {
 onTypeSelected(option['value'] as String);
 },
 backgroundColor: Colors.white,
 selectedColor: Theme.of(context).colorScheme.primary,
 checkmarkColor: Colors.white,
 side: BorderSide(
 color: Colors.grey[300]!,
 ),
 pressElevation: 2,
 ),
 );
 },
 ),
 );
 }
}

// Badge de filtres actifs
class ActiveFiltersBadge extends StatelessWidget {
 final SearchFilters? filters;
 final VoidCallback? onClearFilters;

 const ActiveFiltersBadge({
 Key? key,
 this.filters,
 this.onClearFilters,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 if (filters == null) r{eturn const SizedBox.shrink();

 final int activeFiltersCount = _getActiveFiltersCount();
 if (activeFiltersCount == 0) r{eturn const SizedBox.shrink();

 return Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.primary,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 const Icon(
 Icons.filter_list,
 size: 14,
 color: Colors.white,
 ),
 const SizedBox(width: 4),
 Text(
 '$activeFiltersCount filtre${activeFiltersCount > 1 ? 's' : ''}',
 style: const TextStyle(
 fontSize: 12,
 color: Colors.white,
 fontWeight: FontWeight.w500,
 ),
 ),
 if (onClearFilters != null) .{..[
 const SizedBox(width: 4),
 GestureDetector(
 onTap: onClearFilters,
 child: const Icon(
 Icons.close,
 size: 14,
 color: Colors.white,
 ),
 ),
 ],
 ],
 ),
 );
 }

 int _getActiveFiltersCount() {
 int count = 0;
 if (filters!.types.isNotEmpty) c{ount++;
 if (filters!.dateRange != null) c{ount++;
 if (filters!.startDate != null) c{ount++;
 if (filters!.endDate != null) c{ount++;
 return count;
 }
}

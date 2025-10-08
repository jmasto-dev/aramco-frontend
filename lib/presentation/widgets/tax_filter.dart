import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/tax_declaration.dart';

class TaxFilter extends StatefulWidget {
 final TaxDeclarationType? selectedType;
 final TaxDeclarationStatus? selectedStatus;
 final DateTime? startDate;
 final DateTime? endDate;
 final Function(TaxDeclarationType?, TaxDeclarationStatus?, DateTime?, DateTime?) onFilterChanged;

 const TaxFilter({
 Key? key,
 this.selectedType,
 this.selectedStatus,
 this.startDate,
 this.endDate,
 required this.onFilterChanged,
 }) : super(key: key);

 @override
 State<TaxFilter> createState() => _TaxFilterState();
}

class _TaxFilterState extends State<TaxFilter> {
 late TaxDeclarationType? _selectedType;
 late TaxDeclarationStatus? _selectedStatus;
 late DateTime? _startDate;
 late DateTime? _endDate;
 bool _isExpanded = false;

 @override
 void initState() {
 super.initState();
 _selectedType = widget.selectedType;
 _selectedStatus = widget.selectedStatus;
 _startDate = widget.startDate;
 _endDate = widget.endDate;
 }

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.all(1),
 child: Column(
 children: [
 // Header
 ListTile(
 leading: const Icon(Icons.filter_list),
 title: const Text('Filtres'),
 trailing: IconButton(
 icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
 onPressed: () {
 setState(() {
 _isExpanded = !_isExpanded;
 });
 },
 ),
 onTap: () {
 setState(() {
 _isExpanded = !_isExpanded;
 });
},
 ),
 
 // Filters content
 if (_isExpanded) .{..[
 const Divider(height: 1),
 Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Type filter
 Text(
 'Type de déclaration',
 style: Theme.of(context).textTheme.titleSmall,
 ),
 const SizedBox(height: 8),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: TaxDeclarationType.values.map((type) {
 final isSelected = _selectedType == type;
 return FilterChip(
 label: Text(_getTypeText(type)),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 _selectedType = selected ? type : null;
});
 _notifyFilterChanged();
},
 backgroundColor: Colors.grey[100],
 selectedColor: Theme.of(context).primaryconst Color.withOpacity(0.2),
 checkmarkColor: Theme.of(context).primaryColor,
 );
 }).toList(),
 ),
 
 const SizedBox(height: 16),
 
 // Status filter
 Text(
 'Statut',
 style: Theme.of(context).textTheme.titleSmall,
 ),
 const SizedBox(height: 8),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: TaxDeclarationStatus.values.map((status) {
 final isSelected = _selectedStatus == status;
 return FilterChip(
 label: Text(_getStatusText(status)),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 _selectedStatus = selected ? status : null;
});
 _notifyFilterChanged();
},
 backgroundColor: Colors.grey[100],
 selectedColor: Theme.of(context).primaryconst Color.withOpacity(0.2),
 checkmarkColor: Theme.of(context).primaryColor,
 );
 }).toList(),
 ),
 
 const SizedBox(height: 16),
 
 // Date range filter
 Text(
 'Période',
 style: Theme.of(context).textTheme.titleSmall,
 ),
 const SizedBox(height: 8),
 Row(
 children: [
 Expanded(
 child: OutlinedButton.icon(
 onPressed: () => _selectDate(context, true),
 icon: const Icon(Icons.calendar_today, size: 16),
 label: Text(
 _startDate != null 
 ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
 : 'Date début',
 ),
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: OutlinedButton.icon(
 onPressed: () => _selectDate(context, false),
 icon: const Icon(Icons.calendar_today, size: 16),
 label: Text(
 _endDate != null 
 ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
 : 'Date fin',
 ),
 ),
 ),
 ],
 ),
 
 const SizedBox(height: 16),
 
 // Action buttons
 Row(
 children: [
 Expanded(
 child: OutlinedButton.icon(
 onPressed: _clearFilters,
 icon: const Icon(Icons.clear, size: 16),
 label: const Text('Effacer'),
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: ElevatedButton.icon(
 onPressed: _notifyFilterChanged,
 icon: const Icon(Icons.search, size: 16),
 label: const Text('Appliquer'),
 ),
 ),
 ],
 ),
 ],
 ),
 ),
 ],
 ],
 ),
 );
 }

 Future<void> _selectDate(BuildContext context, bool isStartDate) {async {
 final DateTime? picked = await showDatePicker(
 context: context,
 initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
 firstDate: DateTime(2020),
 lastDate: DateTime(2030),
 );

 if (picked != null) {{
 setState(() {
 if (isStartDate) {{
 _startDate = picked;
 // Ensure end date is after start date
 if (_endDate != null && _endDate!.isBefore(_startDate!)){ {
 _endDate = _startDate;
}
 } else {
 _endDate = picked;
 // Ensure start date is before end date
 if (_startDate != null && _startDate!.isAfter(_endDate!)){ {
 _startDate = _endDate;
}
 }
 });
 _notifyFilterChanged();
}
 }

 void _clearFilters() {
 setState(() {
 _selectedType = null;
 _selectedStatus = null;
 _startDate = null;
 _endDate = null;
});
 _notifyFilterChanged();
 }

 void _notifyFilterChanged() {
 widget.onFilterChanged(_selectedType, _selectedStatus, _startDate, _endDate);
 }

 String _getTypeText(TaxDeclarationType type) {
 switch (type) {
 case TaxDeclarationType.vat:
 return 'TVA';
 case TaxDeclarationType.incomeTax:
 return 'Impôt revenu';
 case TaxDeclarationType.corporateTax:
 return 'Impôt société';
 case TaxDeclarationType.propertyTax:
 return 'Taxe foncière';
 case TaxDeclarationType.other:
 return 'Autre';
}
 }

 String _getStatusText(TaxDeclarationStatus status) {
 switch (status) {
 case TaxDeclarationStatus.draft:
 return 'Brouillon';
 case TaxDeclarationStatus.submitted:
 return 'Soumis';
 case TaxDeclarationStatus.underReview:
 return 'En révision';
 case TaxDeclarationStatus.approved:
 return 'Approuvé';
 case TaxDeclarationStatus.rejected:
 return 'Rejeté';
 case TaxDeclarationStatus.paid:
 return 'Payé';
}
 }
}

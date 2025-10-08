import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aramco_frontend/core/models/employee.dart';
import 'package:aramco_frontend/core/app_theme.dart';

class DepartmentFilter extends ConsumerStatefulWidget {
 final EmployeeFilters currentFilters;
 final Function(EmployeeFilters) onFiltersChanged;
 final bool showPositionFilter;
 final bool showStatusFilter;
 final bool showSalaryFilter;
 final bool showDateFilter;

 const DepartmentFilter({
 super.key,
 required this.currentFilters,
 required this.onFiltersChanged,
 this.showPositionFilter = true,
 this.showStatusFilter = true,
 this.showSalaryFilter = false,
 this.showDateFilter = false,
 });

 @override
 ConsumerState<DepartmentFilter> createState() => _DepartmentFilterState();
}

class _DepartmentFilterState extends ConsumerState<DepartmentFilter> {
 late Department _selectedDepartment;
 late Position _selectedPosition;
 late bool? _selectedStatus;
 late double _salaryMin;
 late double _salaryMax;
 late DateTime? _hireDateFrom;
 late DateTime? _hireDateTo;
 final TextEditingController _salaryMinController = TextEditingController();
 final TextEditingController _salaryMaxController = TextEditingController();

 @override
 void initState() {
 super.initState();
 _selectedDepartment = widget.currentFilters.department;
 _selectedPosition = widget.currentFilters.position;
 _selectedStatus = widget.currentFilters.isActive;
 _salaryMin = widget.currentFilters.salaryMin ?? 0;
 _salaryMax = widget.currentFilters.salaryMax ?? 200000;
 _hireDateFrom = widget.currentFilters.hireDateFrom;
 _hireDateTo = widget.currentFilters.hireDateTo;
 
 _salaryMinController.text = _salaryMin.toStringAsFixed(0);
 _salaryMaxController.text = _salaryMax.toStringAsFixed(0);
 }

 @override
 void dispose() {
 _salaryMinController.dispose();
 _salaryMaxController.dispose();
 super.dispose();
 }

 void _applyFilters() {
 final newFilters = EmployeeFilters(
 department: _selectedDepartment,
 position: _selectedPosition,
 isActive: _selectedStatus,
 salaryMin: _salaryMin > 0 ? _salaryMin : null,
 salaryMax: _salaryMax < 200000 ? _salaryMax : null,
 hireDateFrom: _hireDateFrom,
 hireDateTo: _hireDateTo,
 );
 
 widget.onFiltersChanged(newFilters);
 Navigator.pop(context);
 }

 void _clearFilters() {
 setState(() {
 _selectedDepartment = Department.all;
 _selectedPosition = Position.all;
 _selectedStatus = null;
 _salaryMin = 0;
 _salaryMax = 200000;
 _hireDateFrom = null;
 _hireDateTo = null;
 _salaryMinController.clear();
 _salaryMaxController.text = '200000';
});
 }

 @override
 Widget build(BuildContext context) {
 return Dialog(
 shape: RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Container(
 constraints: const BoxConstraints(maxHeight: 600),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisSize: MainAxisSize.min,
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Header
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Filtrer les employés',
 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 IconButton(
 onPressed: () => Navigator.pop(context),
 icon: const Icon(Icons.close),
 ),
 ],
 ),
 const SizedBox(height: 20),

 // Filtres
 Expanded(
 child: SingleChildScrollView(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Filtre par département
 _buildDepartmentFilter(),
 const SizedBox(height: 20),

 // Filtre par poste
 if (widget.showPositionFilter) .{..[
 _buildPositionFilter(),
 const SizedBox(height: 20),
 ],

 // Filtre par statut
 if (widget.showStatusFilter) .{..[
 _buildStatusFilter(),
 const SizedBox(height: 20),
 ],

 // Filtre par salaire
 if (widget.showSalaryFilter) .{..[
 _buildSalaryFilter(),
 const SizedBox(height: 20),
 ],

 // Filtre par date d'embauche
 if (widget.showDateFilter) .{..[
 _buildDateFilter(),
 const SizedBox(height: 20),
 ],
 ],
 ),
 ),
 ),

 // Actions
 Row(
 children: [
 Expanded(
 child: OutlinedButton(
 onPressed: _clearFilters,
 style: OutlinedButton.styleFrom(
 padding: const EdgeInsets.symmetric(1),
 shape: RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 ),
 child: const Text('Effacer'),
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 flex: 2,
 child: ElevatedButton(
 onPressed: _applyFilters,
 style: ElevatedButton.styleFrom(
 backgroundColor: AppTheme.primaryColor,
 foregroundColor: Colors.white,
 padding: const EdgeInsets.symmetric(1),
 shape: RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 ),
 child: const Text('Appliquer les filtres'),
 ),
 ),
 ],
 ),
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildDepartmentFilter() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Département',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: Department.values.map((department) {
 final isSelected = _selectedDepartment == department;
 return FilterChip(
 label: Text(department.displayName),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 _selectedDepartment = selected ? department : Department.all;
 });
 },
 backgroundColor: Colors.grey[100],
 selectedColor: AppTheme.primaryconst Color.withOpacity(0.2),
 checkmarkColor: AppTheme.primaryColor,
 labelStyle: const TextStyle(
 color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
 ),
 );
}).toList(),
 ),
 ],
 );
 }

 Widget _buildPositionFilter() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Poste',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: Position.values.map((position) {
 final isSelected = _selectedPosition == position;
 return FilterChip(
 label: Text(position.displayName),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 _selectedPosition = selected ? position : Position.all;
 });
 },
 backgroundColor: Colors.grey[100],
 selectedColor: AppTheme.primaryconst Color.withOpacity(0.2),
 checkmarkColor: AppTheme.primaryColor,
 labelStyle: const TextStyle(
 color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
 ),
 );
}).toList(),
 ),
 ],
 );
 }

 Widget _buildStatusFilter() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Statut',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 Row(
 children: [
 Expanded(
 child: FilterChip(
 label: const Text('Actifs'),
 selected: _selectedStatus == true,
 onSelected: (selected) {
 setState(() {
 _selectedStatus = selected ? true : null;
 });
 },
 backgroundColor: Colors.grey[100],
 selectedColor: Colors.green.withOpacity(0.2),
 checkmarkColor: Colors.green,
 labelStyle: const TextStyle(
 color: _selectedStatus == true ? Colors.green : Colors.grey[700],
 fontWeight: _selectedStatus == true ? FontWeight.bold : FontWeight.normal,
 ),
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: FilterChip(
 label: const Text('Inactifs'),
 selected: _selectedStatus == false,
 onSelected: (selected) {
 setState(() {
 _selectedStatus = selected ? false : null;
 });
 },
 backgroundColor: Colors.grey[100],
 selectedColor: Colors.orange.withOpacity(0.2),
 checkmarkColor: Colors.orange,
 labelStyle: const TextStyle(
 color: _selectedStatus == false ? Colors.orange : Colors.grey[700],
 fontWeight: _selectedStatus == false ? FontWeight.bold : FontWeight.normal,
 ),
 ),
 ),
 ],
 ),
 ],
 );
 }

 Widget _buildSalaryFilter() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Salaire annuel (€)',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 Row(
 children: [
 Expanded(
 child: TextField(
 controller: _salaryMinController,
 keyboardType: TextInputType.number,
 decoration: InputDecoration(
 labelText: 'Min',
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 prefixText: '€',
 ),
 onChanged: (value) {
 final salary = double.tryParse(value);
 if (salary != null) {{
 setState(() {
 _salaryMin = salary;
 });
 }
 },
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: TextField(
 controller: _salaryMaxController,
 keyboardType: TextInputType.number,
 decoration: InputDecoration(
 labelText: 'Max',
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 prefixText: '€',
 ),
 onChanged: (value) {
 final salary = double.tryParse(value);
 if (salary != null) {{
 setState(() {
 _salaryMax = salary;
 });
 }
 },
 ),
 ),
 ],
 ),
 const SizedBox(height: 8),
 RangeSlider(
 values: RangeValues(_salaryMin, _salaryMax),
 min: 0,
 max: 200000,
 divisions: 40,
 labels: RangeLabels(
 '${_salaryMin.toInt()}€',
 '${_salaryMax.toInt()}€',
 ),
 onChanged: (values) {
 setState(() {
 _salaryMin = values.start;
 _salaryMax = values.end;
 _salaryMinController.text = _salaryMin.toStringAsFixed(0);
 _salaryMaxController.text = _salaryMax.toStringAsFixed(0);
});
},
 ),
 ],
 );
 }

 Widget _buildDateFilter() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Date d\'embauche',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 Row(
 children: [
 Expanded(
 child: InkWell(
 onTap: () async {
 final date = await showDatePicker(
 context: context,
 initialDate: _hireDateFrom ?? DateTime.now(),
 firstDate: DateTime(2000),
 lastDate: DateTime.now(),
 );
 if (date != null) {{
 setState(() {
 _hireDateFrom = date;
 });
 }
 },
 child: InputDecorator(
 decoration: InputDecoration(
 labelText: 'Du',
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 suffixIcon: const Icon(Icons.calendar_today),
 ),
 child: Text(
 _hireDateFrom != null
 ? _hireDateFrom.toString().split(' ')[0]
 : 'Sélectionner une date',
 ),
 ),
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: InkWell(
 onTap: () async {
 final date = await showDatePicker(
 context: context,
 initialDate: _hireDateTo ?? DateTime.now(),
 firstDate: DateTime(2000),
 lastDate: DateTime.now(),
 );
 if (date != null) {{
 setState(() {
 _hireDateTo = date;
 });
 }
 },
 child: InputDecorator(
 decoration: InputDecoration(
 labelText: 'Au',
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 suffixIcon: const Icon(Icons.calendar_today),
 ),
 child: Text(
 _hireDateTo != null
 ? _hireDateTo.toString().split(' ')[0]
 : 'Sélectionner une date',
 ),
 ),
 ),
 ),
 ],
 ),
 ],
 );
 }
}

// Widget de filtre rapide pour la barre latérale
class QuickDepartmentFilter extends ConsumerWidget {
 final EmployeeFilters currentFilters;
 final Function(EmployeeFilters) onFiltersChanged;

 const QuickDepartmentFilter({
 super.key,
 required this.currentFilters,
 required this.onFiltersChanged,
 });

 @override
 Widget build(BuildContext context, WidgetRef ref) {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Filtres rapides',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 12),
 
 // Filtre par département
 Text(
 'Département',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 Wrap(
 spacing: 4,
 runSpacing: 4,
 children: Department.values.map((department) {
 final isSelected = currentFilters.department == department;
 return ActionChip(
 label: Text(department.displayName),
 onPressed: () {
 final newFilters = currentFilters.copyWith(
 department: isSelected ? Department.all : department,
 );
 onFiltersChanged(newFilters);
 },
 backgroundColor: isSelected 
 ? AppTheme.primaryconst Color.withOpacity(0.2)
 : Colors.grey[100],
 labelStyle: const TextStyle(
 color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
 fontSize: 12,
 ),
 );
 }).toList(),
 ),
 
 const SizedBox(height: 16),
 
 // Filtre par statut
 Text(
 'Statut',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 Row(
 children: [
 Expanded(
 child: ActionChip(
 label: const Text('Actifs'),
 onPressed: () {
 final newFilters = currentFilters.copyWith(
 isActive: currentFilters.isActive == true ? null : true,
 );
 onFiltersChanged(newFilters);
 },
 backgroundColor: currentFilters.isActive == true
 ? Colors.green.withOpacity(0.2)
 : Colors.grey[100],
 labelStyle: const TextStyle(
 color: currentFilters.isActive == true 
 ? Colors.green 
 : Colors.grey[700],
 fontSize: 12,
 ),
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: ActionChip(
 label: const Text('Inactifs'),
 onPressed: () {
 final newFilters = currentFilters.copyWith(
 isActive: currentFilters.isActive == false ? null : false,
 );
 onFiltersChanged(newFilters);
 },
 backgroundColor: currentFilters.isActive == false
 ? Colors.orange.withOpacity(0.2)
 : Colors.grey[100],
 labelStyle: const TextStyle(
 color: currentFilters.isActive == false 
 ? Colors.orange 
 : Colors.grey[700],
 fontSize: 12,
 ),
 ),
 ),
 ],
 ),
 
 // Bouton pour effacer les filtres
 if (currentFilters.hasFilters) .{..[
 const SizedBox(height: 16),
 const SizedBox(
 width: double.infinity,
 child: OutlinedButton(
 onPressed: () {
 onFiltersChanged(const EmployeeFilters());
 },
 style: OutlinedButton.styleFrom(
 padding: const EdgeInsets.symmetric(1),
 ),
 child: const Text('Effacer les filtres'),
 ),
 ),
 ],
 ],
 ),
 ),
 );
 }
}

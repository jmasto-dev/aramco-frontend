import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/message.dart';

class MessageFilter extends StatefulWidget {
 final Function(
 MessageStatus? status,
 MessageType? type,
 MessagePriority? priority,
 DateTime? startDate,
 DateTime? endDate,
 ) onFiltersChanged;

 const MessageFilter({
 Key? key,
 required this.onFiltersChanged,
 }) : super(key: key);

 @override
 State<MessageFilter> createState() => _MessageFilterState();
}

class _MessageFilterState extends State<MessageFilter> {
 MessageStatus? _selectedStatus;
 MessageType? _selectedType;
 MessagePriority? _selectedPriority;
 DateTime? _startDate;
 DateTime? _endDate;

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.only(bottom: 16),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 const Icon(Icons.filter_list),
 const SizedBox(width: 8),
 const Text(
 'Filtres',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.bold,
 ),
 ),
 const Spacer(),
 TextButton(
 onPressed: _clearFilters,
 child: const Text('Effacer'),
 ),
 ],
 ),
 const SizedBox(height: 16),

 // Filtre par statut
 _buildFilterSection(
 'Statut',
 MessageStatus.values.map((status) {
 return FilterChip(
 label: Text(_getStatusLabel(status)),
 selected: _selectedStatus == status,
 onSelected: (selected) {
 setState(() {
 _selectedStatus = selected ? status : null;
 });
 _applyFilters();
 },
 backgroundColor: Colors.grey[200],
 selectedColor: Colors.blue.withOpacity(0.2),
 checkmarkColor: Colors.blue,
 );
 }).toList(),
 ),
 const SizedBox(height: 16),

 // Filtre par type
 _buildFilterSection(
 'Type',
 MessageType.values.map((type) {
 return FilterChip(
 label: Text(_getTypeLabel(type)),
 selected: _selectedType == type,
 onSelected: (selected) {
 setState(() {
 _selectedType = selected ? type : null;
 });
 _applyFilters();
 },
 backgroundColor: Colors.grey[200],
 selectedColor: Colors.green.withOpacity(0.2),
 checkmarkColor: Colors.green,
 );
 }).toList(),
 ),
 const SizedBox(height: 16),

 // Filtre par priorité
 _buildFilterSection(
 'Priorité',
 MessagePriority.values.map((priority) {
 return FilterChip(
 label: Text(_getPriorityLabel(priority)),
 selected: _selectedPriority == priority,
 onSelected: (selected) {
 setState(() {
 _selectedPriority = selected ? priority : null;
 });
 _applyFilters();
 },
 backgroundColor: Colors.grey[200],
 selectedColor: _getPriorityColor(priority).withOpacity(0.2),
 checkmarkColor: _getPriorityColor(priority),
 );
 }).toList(),
 ),
 const SizedBox(height: 16),

 // Filtre par date
 _buildDateFilter(),
 ],
 ),
 ),
 );
 }

 Widget _buildFilterSection(String title, List<Widget> chips) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 title,
 style: const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: chips,
 ),
 ],
 );
 }

 Widget _buildDateFilter() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text(
 'Période',
 style: const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 Row(
 children: [
 Expanded(
 child: OutlinedButton.icon(
 onPressed: _selectStartDate,
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
 onPressed: _selectEndDate,
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
 ],
 );
 }

 Future<void> _selectStartDate() {async {
 final date = await showDatePicker(
 context: context,
 initialDate: _startDate ?? DateTime.now(),
 firstDate: DateTime(2020),
 lastDate: DateTime.now(),
 );

 if (date != null) {{
 setState(() {
 _startDate = date;
 });
 _applyFilters();
}
 }

 Future<void> _selectEndDate() {async {
 final date = await showDatePicker(
 context: context,
 initialDate: _endDate ?? DateTime.now(),
 firstDate: _startDate ?? DateTime(2020),
 lastDate: DateTime.now(),
 );

 if (date != null) {{
 setState(() {
 _endDate = date;
 });
 _applyFilters();
}
 }

 void _applyFilters() {
 widget.onFiltersChanged(
 _selectedStatus,
 _selectedType,
 _selectedPriority,
 _startDate,
 _endDate,
 );
 }

 void _clearFilters() {
 setState(() {
 _selectedStatus = null;
 _selectedType = null;
 _selectedPriority = null;
 _startDate = null;
 _endDate = null;
});
 _applyFilters();
 }

 String _getStatusLabel(MessageStatus status) {
 switch (status) {
 case MessageStatus.draft:
 return 'Brouillon';
 case MessageStatus.sent:
 return 'Envoyé';
 case MessageStatus.delivered:
 return 'Livré';
 case MessageStatus.read:
 return 'Lu';
 case MessageStatus.failed:
 return 'Échoué';
}
 }

 String _getTypeLabel(MessageType type) {
 switch (type) {
 case MessageType.text:
 return 'Texte';
 case MessageType.html:
 return 'HTML';
 case MessageType.system:
 return 'Système';
 case MessageType.file:
 return 'Fichier';
 case MessageType.image:
 return 'Image';
 case MessageType.video:
 return 'Vidéo';
 case MessageType.audio:
 return 'Audio';
}
 }

 String _getPriorityLabel(MessagePriority priority) {
 switch (priority) {
 case MessagePriority.low:
 return 'Basse';
 case MessagePriority.normal:
 return 'Normale';
 case MessagePriority.high:
 return 'Haute';
 case MessagePriority.urgent:
 return 'Urgente';
}
 }

 Color _getPriorityColor(MessagePriority priority) {
 switch (priority) {
 case MessagePriority.low:
 return Colors.grey;
 case MessagePriority.normal:
 return Colors.blue;
 case MessagePriority.high:
 return Colors.orange;
 case MessagePriority.urgent:
 return Colors.red;
}
 }
}

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/task.dart';

class TaskFilter extends StatefulWidget {
 final TaskFilterOptions currentFilters;
 final Function(TaskFilterOptions) onFiltersChanged;

 const TaskFilter({
 Key? key,
 required this.currentFilters,
 required this.onFiltersChanged,
 }) : super(key: key);

 @override
 State<TaskFilter> createState() => _TaskFilterState();
}

class _TaskFilterState extends State<TaskFilter> {
 late TaskFilterOptions _filters;
 bool _isExpanded = false;

 @override
 void initState() {
 super.initState();
 _filters = widget.currentFilters;
 }

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.all(1),
 child: Column(
 children: [
 // En-tête du filtre
 ListTile(
 leading: const Icon(Icons.filter_list),
 title: const Text('Filtres'),
 trailing: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 if (_hasActiveFilters()){
 Chip(
 label: Text('${_getActiveFiltersCount()}'),
 backgroundColor: Theme.of(context).colorScheme.primary,
 labelStyle: const TextStyle(color: Colors.white),
 ),
 IconButton(
 icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
 onPressed: () {
 setState(() {
 _isExpanded = !_isExpanded;
 });
 },
 ),
 ],
 ),
 onTap: () {
 setState(() {
 _isExpanded = !_isExpanded;
 });
},
 ),

 // Contenu du filtre
 if (_isExpanded) _{buildFilterContent(),
 ],
 ),
 );
 }

 Widget _buildFilterContent() {
 return Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Filtre par statut
 _buildSectionTitle('Statut'),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: TaskStatus.values.map((status) {
 final isSelected = _filters.status == status;
 return FilterChip(
 label: Text(_getStatusDisplayName(status)),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 _filters = _filters.copyWith(
 status: selected ? status : null,
 );
 widget.onFiltersChanged(_filters);
 });
 },
 backgroundColor: Colors.grey[100],
 selectedColor: _getStatusColor(status).withOpacity(0.2),
 checkmarkColor: _getStatusColor(status),
 );
}).toList(),
 ),
 const SizedBox(height: 16),

 // Filtre par priorité
 _buildSectionTitle('Priorité'),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: TaskPriority.values.map((priority) {
 final isSelected = _filters.priority == priority;
 return FilterChip(
 label: Text(_getPriorityDisplayName(priority)),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 _filters = _filters.copyWith(
 priority: selected ? priority : null,
 );
 widget.onFiltersChanged(_filters);
 });
 },
 backgroundColor: Colors.grey[100],
 selectedColor: _getPriorityColor(priority).withOpacity(0.2),
 checkmarkColor: _getPriorityColor(priority),
 );
}).toList(),
 ),
 const SizedBox(height: 16),

 // Filtre par type
 _buildSectionTitle('Type'),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: TaskType.values.map((type) {
 final isSelected = _filters.type == type;
 return FilterChip(
 label: Text(_getTypeDisplayName(type)),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 _filters = _filters.copyWith(
 type: selected ? type : null,
 );
 widget.onFiltersChanged(_filters);
 });
 },
 backgroundColor: Colors.grey[100],
 selectedColor: _getTypeColor(type).withOpacity(0.2),
 checkmarkColor: _getTypeColor(type),
 );
}).toList(),
 ),
 const SizedBox(height: 16),

 // Filtre par assigné
 _buildSectionTitle('Assigné à'),
 TextField(
 decoration: const InputDecoration(
 labelText: 'ID de l\'utilisateur',
 hintText: 'Entrez l\'ID de l\'utilisateur',
 border: OutlineInputBorder(),
 prefixIcon: Icon(Icons.person),
 ),
 controller: TextEditingController(text: _filters.assigneeId ?? ''),
 onChanged: (value) {
 setState(() {
 _filters = _filters.copyWith(
 assigneeId: value.isEmpty ? null : value,
 );
 widget.onFiltersChanged(_filters);
 });
},
 ),
 const SizedBox(height: 16),

 // Filtre par projet
 _buildSectionTitle('Projet'),
 TextField(
 decoration: const InputDecoration(
 labelText: 'ID du projet',
 hintText: 'Entrez l\'ID du projet',
 border: OutlineInputBorder(),
 prefixIcon: Icon(Icons.folder),
 ),
 controller: TextEditingController(text: _filters.projectId ?? ''),
 onChanged: (value) {
 setState(() {
 _filters = _filters.copyWith(
 projectId: value.isEmpty ? null : value,
 );
 widget.onFiltersChanged(_filters);
 });
},
 ),
 const SizedBox(height: 16),

 // Filtre par dates
 _buildSectionTitle('Dates'),
 Row(
 children: [
 Expanded(
 child: _buildDateField(
 'Date de début',
 _filters.startDate,
 (date) {
 setState(() {
 _filters = _filters.copyWith(startDate: date);
 widget.onFiltersChanged(_filters);
 });
 },
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: _buildDateField(
 'Date de fin',
 _filters.endDate,
 (date) {
 setState(() {
 _filters = _filters.copyWith(endDate: date);
 widget.onFiltersChanged(_filters);
 });
 },
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),

 // Filtre par tags
 _buildSectionTitle('Tags'),
 TextField(
 decoration: const InputDecoration(
 labelText: 'Tags',
 hintText: 'Entrez les tags séparés par des virgules',
 border: OutlineInputBorder(),
 prefixIcon: Icon(Icons.tag),
 ),
 controller: TextEditingController(text: _filters.tags?.join(', ') ?? ''),
 onChanged: (value) {
 final tags = value
 .split(',')
 .map((tag) => tag.trim())
 .where((tag) => tag.isNotEmpty)
 .toList();
 setState(() {
 _filters = _filters.copyWith(
 tags: tags.isEmpty ? null : tags,
 );
 widget.onFiltersChanged(_filters);
 });
},
 ),
 const SizedBox(height: 16),

 // Actions
 Row(
 children: [
 Expanded(
 child: OutlinedButton(
 onPressed: _hasActiveFilters() ? _clearFilters : null,
 child: const Text('Réinitialiser'),
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: ElevatedButton(
 onPressed: () {
 Navigator.of(context).pop();
 },
 child: const Text('Appliquer'),
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildSectionTitle(String title) {
 return Padding(
 padding: const EdgeInsets.only(bottom: 8),
 child: Text(
 title,
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.bold,
 ),
 ),
 );
 }

 Widget _buildDateField(
 String label,
 DateTime? selectedDate,
 Function(DateTime?) onDateSelected,
 ) {
 return InkWell(
 onTap: () async {
 final date = await showDatePicker(
 context: context,
 initialDate: selectedDate ?? DateTime.now(),
 firstDate: DateTime(2020),
 lastDate: DateTime(2030),
 );
 if (date != null) {{
 onDateSelected(date);
 }
 },
 child: InputDecorator(
 decoration: InputDecoration(
 labelText: label,
 border: const OutlineInputBorder(),
 prefixIcon: const Icon(Icons.calendar_today),
 ),
 child: Text(
 selectedDate != null
 ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
 : 'Sélectionner une date',
 ),
 ),
 );
 }

 bool _hasActiveFilters() {
 return _filters.status != null ||
 _filters.priority != null ||
 _filters.type != null ||
 _filters.assigneeId != null ||
 _filters.projectId != null ||
 _filters.startDate != null ||
 _filters.endDate != null ||
 (_filters.tags != null && _filters.tags!.isNotEmpty);
 }

 int _getActiveFiltersCount() {
 int count = 0;
 if (_filters.status != null) c{ount++;
 if (_filters.priority != null) c{ount++;
 if (_filters.type != null) c{ount++;
 if (_filters.assigneeId != null) c{ount++;
 if (_filters.projectId != null) c{ount++;
 if (_filters.startDate != null) c{ount++;
 if (_filters.endDate != null) c{ount++;
 if (_filters.tags != null && _filters.tags!.isNotEmpty) c{ount++;
 return count;
 }

 void _clearFilters() {
 setState(() {
 _filters = const TaskFilterOptions();
 widget.onFiltersChanged(_filters);
});
 }

 // Méthodes utilitaires pour les noms et couleurs
 String _getStatusDisplayName(TaskStatus status) {
 switch (status) {
 case TaskStatus.todo:
 return 'À faire';
 case TaskStatus.inProgress:
 return 'En cours';
 case TaskStatus.inReview:
 return 'En révision';
 case TaskStatus.completed:
 return 'Terminée';
 case TaskStatus.cancelled:
 return 'Annulée';
 case TaskStatus.onHold:
 return 'En pause';
}
 }

 Color _getStatusColor(TaskStatus status) {
 switch (status) {
 case TaskStatus.todo:
 return Colors.grey;
 case TaskStatus.inProgress:
 return Colors.blue;
 case TaskStatus.inReview:
 return Colors.purple;
 case TaskStatus.completed:
 return Colors.green;
 case TaskStatus.cancelled:
 return Colors.red;
 case TaskStatus.onHold:
 return Colors.orange;
}
 }

 String _getPriorityDisplayName(TaskPriority priority) {
 switch (priority) {
 case TaskPriority.urgent:
 return 'Urgente';
 case TaskPriority.high:
 return 'Haute';
 case TaskPriority.normal:
 return 'Normale';
 case TaskPriority.low:
 return 'Basse';
}
 }

 Color _getPriorityColor(TaskPriority priority) {
 switch (priority) {
 case TaskPriority.urgent:
 return Colors.red;
 case TaskPriority.high:
 return Colors.orange;
 case TaskPriority.normal:
 return Colors.blue;
 case TaskPriority.low:
 return Colors.grey;
}
 }

 String _getTypeDisplayName(TaskType type) {
 switch (type) {
 case TaskType.task:
 return 'Tâche';
 case TaskType.bug:
 return 'Bogue';
 case TaskType.feature:
 return 'Fonctionnalité';
 case TaskType.improvement:
 return 'Amélioration';
 case TaskType.documentation:
 return 'Documentation';
 case TaskType.meeting:
 return 'Réunion';
 case TaskType.review:
 return 'Révision';
}
 }

 Color _getTypeColor(TaskType type) {
 switch (type) {
 case TaskType.task:
 return Colors.blue;
 case TaskType.bug:
 return Colors.red;
 case TaskType.feature:
 return Colors.green;
 case TaskType.improvement:
 return Colors.purple;
 case TaskType.documentation:
 return Colors.orange;
 case TaskType.meeting:
 return Colors.teal;
 case TaskType.review:
 return Colors.indigo;
}
 }
}

// Classe pour les options de filtre
class TaskFilterOptions {
 final TaskStatus? status;
 final TaskPriority? priority;
 final TaskType? type;
 final String? assigneeId;
 final String? projectId;
 final DateTime? startDate;
 final DateTime? endDate;
 final List<String>? tags;

 const TaskFilterOptions({
 this.status,
 this.priority,
 this.type,
 this.assigneeId,
 this.projectId,
 this.startDate,
 this.endDate,
 this.tags,
 });

 TaskFilterOptions copyWith({
 TaskStatus? status,
 TaskPriority? priority,
 TaskType? type,
 String? assigneeId,
 String? projectId,
 DateTime? startDate,
 DateTime? endDate,
 List<String>? tags,
 }) {
 return TaskFilterOptions(
 status: status ?? this.status,
 priority: priority ?? this.priority,
 type: type ?? this.type,
 assigneeId: assigneeId ?? this.assigneeId,
 projectId: projectId ?? this.projectId,
 startDate: startDate ?? this.startDate,
 endDate: endDate ?? this.endDate,
 tags: tags ?? this.tags,
 );
 }

 Map<String, dynamic> toMap() {
 return {
 'status': status?.name,
 'priority': priority?.name,
 'type': type?.name,
 'assigneeId': assigneeId,
 'projectId': projectId,
 'startDate': startDate?.toIso8601String(),
 'endDate': endDate?.toIso8601String(),
 'tags': tags,
};
 }

 factory TaskFilterOptions.fromMap(Map<String, dynamic> map) {
 return TaskFilterOptions(
 status: map['status'] != null ? TaskStatus.values.firstWhere(
 (status) => status.name == map['status'],
 ) : null,
 priority: map['priority'] != null ? TaskPriority.values.firstWhere(
 (priority) => priority.name == map['priority'],
 ) : null,
 type: map['type'] != null ? TaskType.values.firstWhere(
 (type) => type.name == map['type'],
 ) : null,
 assigneeId: map['assigneeId'],
 projectId: map['projectId'],
 startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
 endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
 tags: List<String>.from(map['tags'] ?? []),
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is TaskFilterOptions &&
 other.status == status &&
 other.priority == priority &&
 other.type == type &&
 other.assigneeId == assigneeId &&
 other.projectId == projectId &&
 other.startDate == startDate &&
 other.endDate == endDate &&
 listEquals(other.tags, tags);
 }

 @override
 int get hashCode {
 return status.hashCode ^
 priority.hashCode ^
 type.hashCode ^
 assigneeId.hashCode ^
 projectId.hashCode ^
 startDate.hashCode ^
 endDate.hashCode ^
 tags.hashCode;
 }
}

// Extension pour listEquals
bool listEquals<T>(List<T>? a, List<T>? b) {
 if (a == null) r{eturn b == null;
 if (b == null || a.length != b.length) r{eturn false;
 for (int i = 0; i < a.length; i++) {
 if (a[i] != b[i]) r{eturn false;
 }
 return true;
}

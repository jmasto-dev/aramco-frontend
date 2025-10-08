import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/task.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class TaskForm extends StatefulWidget {
 final Task? task;
 final Function(Map<String, dynamic>) onSubmit;
 final bool isLoading;

 const TaskForm({
 Key? key,
 this.task,
 required this.onSubmit,
 this.isLoading = false,
 }) : super(key: key);

 @override
 State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
 final _formKey = GlobalKey<FormState>();
 final _titleController = TextEditingController();
 final _descriptionController = TextEditingController();
 final _estimatedHoursController = TextEditingController();
 final _actualHoursController = TextEditingController();
 final _progressController = TextEditingController();

 TaskType _selectedType = TaskType.task;
 TaskPriority _selectedPriority = TaskPriority.normal;
 TaskStatus? _selectedStatus;
 String? _selectedAssigneeId;
 String? _selectedProjectId;
 DateTime? _dueDate;
 DateTime? _startDate;
 DateTime? _completedAt;
 List<String> _selectedTagIds = [];

 @override
 void initState() {
 super.initState();
 _initializeForm();
 }

 @override
 void dispose() {
 _titleController.dispose();
 _descriptionController.dispose();
 _estimatedHoursController.dispose();
 _actualHoursController.dispose();
 _progressController.dispose();
 super.dispose();
 }

 void _initializeForm() {
 if (widget.task != null) {{
 final task = widget.task!;
 _titleController.text = task.title;
 _descriptionController.text = task.description;
 _selectedType = task.type;
 _selectedPriority = task.priority;
 _selectedStatus = task.status;
 _selectedAssigneeId = task.assigneeId;
 _selectedProjectId = task.projectId;
 _dueDate = task.dueDate;
 _startDate = task.startDate;
 _completedAt = task.completedAt;
 _estimatedHoursController.text = task.estimatedHours.toString();
 _actualHoursController.text = task.actualHours.toString();
 _progressController.text = task.progress?.toString() ?? '';
 _selectedTagIds = List.from(task.tagIds);
}
 }

 @override
 Widget build(BuildContext context) {
 return Dialog(
 child: Container(
 width: MediaQuery.of(context).size.width * 0.8,
 constraints: BoxConstraints(
 maxHeight: MediaQuery.of(context).size.height * 0.9,
 ),
 child: Form(
 key: _formKey,
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 // En-tête
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.primary,
 borderRadius: const Borderconst Radius.only(
 topLeft: const Radius.circular(12),
 topRight: const Radius.circular(12),
 ),
 ),
 child: Row(
 children: [
 Icon(
 widget.task == null ? Icons.add_task : Icons.edit,
 color: Colors.white,
 ),
 const SizedBox(width: 12),
 Expanded(
 child: Text(
 widget.task == null ? 'Nouvelle Tâche' : 'Modifier la Tâche',
 style: const TextStyle(
 color: Colors.white,
 fontSize: 18,
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 IconButton(
 onPressed: () => Navigator.of(context).pop(),
 icon: const Icon(Icons.close, color: Colors.white),
 ),
 ],
 ),
 ),

 // Contenu du formulaire
 Expanded(
 child: SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Informations de base
 _buildSectionTitle('Informations de base'),
 const SizedBox(height: 12),
 
 CustomTextField(
 controller: _titleController,
 label: 'Titre *',
 validator: (value) {
 if (value == null || value.isEmpty) {{
 return 'Le titre est obligatoire';
}
 return null;
},
 ),
 const SizedBox(height: 12),
 
 CustomTextField(
 controller: _descriptionController,
 label: 'Description',
 maxLines: 3,
 validator: (value) {
 if (value != null && value.length > 1000) {{
 return 'La description ne peut pas dépasser 1000 caractères';
}
 return null;
},
 ),
 const SizedBox(height: 16),

 // Type et priorité
 Row(
 children: [
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text(
 'Type',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 DropdownButtonFormField<TaskType>(
 value: _selectedType,
 decoration: InputDecoration(
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: TaskType.values.map((type) {
 return DropdownMenuItem(
 value: type,
 child: Row(
 children: [
 Icon(_getTypeIcon(type), size: 16),
 const SizedBox(width: 8),
 Text(_getTypeDisplayName(type)),
 ],
 ),
 );
 }).toList(),
 onChanged: (value) {
 setState(() {
 _selectedType = value!;
 });
 },
 ),
 ],
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text(
 'Priorité',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 DropdownButtonFormField<TaskPriority>(
 value: _selectedPriority,
 decoration: InputDecoration(
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: TaskPriority.values.map((priority) {
 return DropdownMenuItem(
 value: priority,
 child: Row(
 children: [
 Icon(
 _getPriorityIcon(priority),
 size: 16,
 color: _getPriorityColor(priority),
 ),
 const SizedBox(width: 8),
 Text(_getPriorityDisplayName(priority)),
 ],
 ),
 );
 }).toList(),
 onChanged: (value) {
 setState(() {
 _selectedPriority = value!;
 });
 },
 ),
 ],
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),

 // Statut (uniquement pour la modification)
 if (widget.task != null) .{..[
 const Text(
 'Statut',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 DropdownButtonFormField<TaskStatus>(
 value: _selectedStatus,
 decoration: InputDecoration(
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: TaskStatus.values.map((status) {
 return DropdownMenuItem(
 value: status,
 child: Row(
 children: [
 Icon(
 _getStatusIcon(status),
 size: 16,
 color: _getStatusColor(status),
 ),
 const SizedBox(width: 8),
 Text(_getStatusDisplayName(status)),
 ],
 ),
 );
}).toList(),
 onChanged: (value) {
 setState(() {
 _selectedStatus = value;
});
},
 ),
 const SizedBox(height: 16),
 ],

 // Dates
 _buildSectionTitle('Dates'),
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
 'Date d\'échéance',
 _dueDate,
 (date) => setState(() => _dueDate = date),
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),

 // Temps
 _buildSectionTitle('Temps'),
 const SizedBox(height: 12),
 
 Row(
 children: [
 Expanded(
 child: CustomTextField(
 controller: _estimatedHoursController,
 label: 'Temps estimé (heures)',
 keyboardType: TextInputType.number,
 inputFormatters: [
 FilteringTextInputFormatter.digitsOnly,
 ],
 validator: (value) {
 if (value != null && value.isNotEmpty) {{
 final hours = int.tryParse(value);
 if (hours == null || hours < 0) {{
 return 'Veuillez entrer un nombre valide';
 }
 if (hours > 1000) {{
 return 'Le temps ne peut pas dépasser 1000 heures';
 }
 }
 return null;
 },
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: CustomTextField(
 controller: _actualHoursController,
 label: 'Temps réel (heures)',
 keyboardType: TextInputType.number,
 inputFormatters: [
 FilteringTextInputFormatter.digitsOnly,
 ],
 validator: (value) {
 if (value != null && value.isNotEmpty) {{
 final hours = int.tryParse(value);
 if (hours == null || hours < 0) {{
 return 'Veuillez entrer un nombre valide';
 }
 }
 return null;
 },
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 
 CustomTextField(
 controller: _progressController,
 label: 'Progression (%)',
 keyboardType: TextInputType.number,
 inputFormatters: [
 FilteringTextInputFormatter.digitsOnly,
 ],
 validator: (value) {
 if (value != null && value.isNotEmpty) {{
 final progress = int.tryParse(value);
 if (progress == null || progress < 0 || progress > 100) {{
 return 'La progression doit être entre 0 et 100';
}
}
 return null;
},
 ),
 const SizedBox(height: 16),

 // Assignation et projet
 _buildSectionTitle('Assignation'),
 const SizedBox(height: 12),
 
 TextField(
 decoration: const InputDecoration(
 labelText: 'Assigné à',
 hintText: 'ID de l\'utilisateur assigné',
 border: OutlineInputBorder(),
 ),
 controller: TextEditingController(text: _selectedAssigneeId ?? ''),
 onChanged: (value) {
 setState(() {
 _selectedAssigneeId = value.isEmpty ? null : value;
});
},
 ),
 const SizedBox(height: 12),
 
 TextField(
 decoration: const InputDecoration(
 labelText: 'Projet',
 hintText: 'ID du projet',
 border: OutlineInputBorder(),
 ),
 controller: TextEditingController(text: _selectedProjectId ?? ''),
 onChanged: (value) {
 setState(() {
 _selectedProjectId = value.isEmpty ? null : value;
});
},
 ),
 const SizedBox(height: 16),

 // Tags
 _buildSectionTitle('Tags'),
 const SizedBox(height: 8),
 
 Text(
 'Séparez les tags par des virgules',
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(height: 8),
 
 TextField(
 decoration: const InputDecoration(
 labelText: 'Tags',
 hintText: 'tag1, tag2, tag3',
 border: OutlineInputBorder(),
 ),
 controller: TextEditingController(text: _selectedTagIds.join(', ')),
 onChanged: (value) {
 final tags = value
 .split(',')
 .map((tag) => tag.trim())
 .where((tag) => tag.isNotEmpty)
 .toList();
 setState(() {
 _selectedTagIds = tags;
});
},
 ),
 ],
 ),
 ),
 ),

 // Actions
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.grey[50],
 borderRadius: const Borderconst Radius.only(
 bottomLeft: const Radius.circular(12),
 bottomRight: const Radius.circular(12),
 ),
 ),
 child: Row(
 mainAxisAlignment: MainAxisAlignment.end,
 children: [
 TextButton(
 onPressed: widget.isLoading ? null : () {
 Navigator.of(context).pop();
},
 child: const Text('Annuler'),
 ),
 const SizedBox(width: 12),
 CustomButton(
 text: widget.task == null ? 'Créer' : 'Mettre à jour',
 onPressed: widget.isLoading ? null : _submitForm,
 isLoading: widget.isLoading,
 ),
 ],
 ),
 ),
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildSectionTitle(String title) {
 return Text(
 title,
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 color: Colors.black87,
 ),
 );
 }

 Widget _buildDateField(
 String label,
 DateTime? selectedDate,
 Function(DateTime?) onDateSelected,
 ) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 label,
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 InkWell(
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
 child: Container(
 width: double.infinity,
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 border: Border.all(color: Colors.grey[300]!),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Row(
 children: [
 Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
 const SizedBox(width: 8),
 Text(
 selectedDate != null
 ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
 : 'Sélectionner une date',
 style: const TextStyle(
 color: selectedDate != null ? Colors.black87 : Colors.grey[600],
 ),
 ),
 const Spacer(),
 Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
 ],
 ),
 ),
 ),
 ],
 );
 }

 void _submitForm() {
 if (!_formKey.currentState!.validate()){ {
 return;
}

 final taskData = <String, dynamic>{
 'title': _titleController.text.trim(),
 'description': _descriptionController.text.trim(),
 'type': _selectedType,
 'priority': _selectedPriority,
 'assigneeId': _selectedAssigneeId,
 'projectId': _selectedProjectId,
 'dueDate': _dueDate,
 'startDate': _startDate,
 'estimatedHours': _estimatedHoursController.text.isNotEmpty
 ? int.parse(_estimatedHoursController.text)
 : 0,
 'actualHours': _actualHoursController.text.isNotEmpty
 ? int.parse(_actualHoursController.text)
 : 0,
 'progress': _progressController.text.isNotEmpty
 ? int.parse(_progressController.text)
 : null,
 'tagIds': _selectedTagIds,
};

 if (widget.task != null) {{
 taskData['status'] = _selectedStatus;
 taskData['completedAt'] = _completedAt;
}

 widget.onSubmit(taskData);
 }

 // Méthodes utilitaires pour les icônes et couleurs
 IconData _getTypeIcon(TaskType type) {
 switch (type) {
 case TaskType.task:
 return Icons.task;
 case TaskType.bug:
 return Icons.bug_report;
 case TaskType.feature:
 return Icons.new_releases;
 case TaskType.improvement:
 return Icons.trending_up;
 case TaskType.documentation:
 return Icons.description;
 case TaskType.meeting:
 return Icons.groups;
 case TaskType.review:
 return Icons.rate_review;
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

 IconData _getPriorityIcon(TaskPriority priority) {
 switch (priority) {
 case TaskPriority.urgent:
 return Icons.priority_high;
 case TaskPriority.high:
 return Icons.keyboard_arrow_up;
 case TaskPriority.normal:
 return Icons.remove;
 case TaskPriority.low:
 return Icons.keyboard_arrow_down;
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

 IconData _getStatusIcon(TaskStatus status) {
 switch (status) {
 case TaskStatus.todo:
 return Icons.circle_outlined;
 case TaskStatus.inProgress:
 return Icons.play_circle_outline;
 case TaskStatus.inReview:
 return Icons.rate_review;
 case TaskStatus.completed:
 return Icons.check_circle;
 case TaskStatus.cancelled:
 return Icons.cancel;
 case TaskStatus.onHold:
 return Icons.pause_circle;
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
}

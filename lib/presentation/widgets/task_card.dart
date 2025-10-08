import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/task.dart';

class TaskCard extends StatelessWidget {
 final Task task;
 final bool compact;
 final VoidCallback? onTap;
 final Function(TaskStatus)? onStatusChanged;
 final VoidCallback? onEdit;
 final VoidCallback? onDelete;

 const TaskCard({
 Key? key,
 required this.task,
 this.compact = false,
 this.onTap,
 this.onStatusChanged,
 this.onEdit,
 this.onDelete,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.only(bottom: compact ? 4 : 8),
 elevation: compact ? 1 : 2,
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: _getPriorityColor().withOpacity(0.3),
 width: task.isUrgent ? 2 : 1,
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête avec titre et actions
 Row(
 children: [
 // Indicateur de priorité
 const SizedBox(
 width: 4,
 height: compact ? 20 : 24,
 decoration: BoxDecoration(
 color: _getPriorityColor(),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 ),
 const SizedBox(width: 12),
 
 // Titre et type
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 task.title,
 style: const TextStyle(
 fontSize: compact ? 14 : 16,
 fontWeight: FontWeight.bold,
 decoration: task.isCompleted 
 ? TextDecoration.lineThrough 
 : null,
 color: task.isCompleted 
 ? Colors.grey 
 : Colors.black87,
 ),
 maxLines: compact ? 1 : 2,
 overflow: TextOverflow.ellipsis,
 ),
 if (!compact) .{..[
 const SizedBox(height: 4),
 Row(
 children: [
 _buildTypeChip(),
 const SizedBox(width: 8),
 if (task.projectId != null)
 _{buildProjectChip(),
 ],
 ),
 ],
 ],
 ),
 ),
 
 // Actions
 if (!compact) .{..[
 PopupMenuButton<String>(
 onSelected: _handleMenuAction,
 icon: const Icon(Icons.more_vert, size: 20),
 itemBuilder: (context) => [
 const PopupMenuItem(
 value: 'edit',
 child: Row(
 children: [
 Icon(Icons.edit, size: 16),
 const SizedBox(width: 8),
 Text('Modifier'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'delete',
 child: Row(
 children: [
 Icon(Icons.delete, size: 16, color: Colors.red),
 const SizedBox(width: 8),
 Text('Supprimer', style: const TextStyle(color: Colors.red)),
 ],
 ),
 ),
 ],
 ),
 ],
 ],
 ),
 
 if (!compact) .{..[
 const SizedBox(height: 12),
 
 // Description
 if (task.description.isNotEmpty) .{..[
 Text(
 task.description,
 style: const TextStyle(
 fontSize: 14,
 color: Colors.grey[600],
 ),
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 const SizedBox(height: 8),
 ],
 
 // Informations supplémentaires
 Row(
 children: [
 // Assigné à
 if (task.assigneeId != null) .{..[
 Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 4),
 Text(
 task.assigneeId!,
 style: const TextStyle(fontSize: 12, color: Colors.grey[600]),
 ),
 const SizedBox(width: 16),
 ],
 
 // Date d'échéance
 if (task.dueDate != null) .{..[
 Icon(
 Icons.schedule,
 size: 16,
 color: task.isOverdue ? Colors.red : Colors.grey[600],
 ),
 const SizedBox(width: 4),
 Text(
 _formatDate(task.dueDate!),
 style: const TextStyle(
 fontSize: 12,
 color: task.isOverdue ? Colors.red : Colors.grey[600],
 fontWeight: task.isOverdue ? FontWeight.bold : null,
 ),
 ),
 const SizedBox(width: 16),
 ],
 
 // Temps estimé
 if (task.estimatedHours > 0) .{..[
 Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 4),
 Text(
 '${task.estimatedHours}h',
 style: const TextStyle(fontSize: 12, color: Colors.grey[600]),
 ),
 ],
 ],
 ),
 
 const SizedBox(height: 12),
 
 // Barre de progression et statut
 Row(
 children: [
 // Statut
 _buildStatusSelector(),
 const Spacer(),
 
 // Progression
 if (task.progress != null && task.progress! > 0) .{..[
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.end,
 children: [
 Text(
 '${task.progress!.toInt()}%',
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey[600],
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 4),
 LinearProgressIndicator(
 value: task.progress! / 100,
 backgroundColor: Colors.grey[300],
 valueColor: AlwaysStoppedAnimation<Color>(
 _getProgressColor(),
 ),
 ),
 ],
 ),
 ),
 ],
 ],
 ],
 
 // Tags et pièces jointes
 if (task.tagIds.isNotEmpty || task.attachmentIds.isNotEmpty) .{..[
 const SizedBox(height: 8),
 Row(
 children: [
 if (task.tagIds.isNotEmpty) .{..[
 Icon(Icons.tag, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 4),
 Text(
 '${task.tagIds.length} tag${task.tagIds.length > 1 ? 's' : ''}',
 style: const TextStyle(fontSize: 12, color: Colors.grey[600]),
 ),
 const SizedBox(width: 16),
 ],
 if (task.attachmentIds.isNotEmpty) .{..[
 Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 4),
 Text(
 '${task.attachmentIds.length} pièce${task.attachmentIds.length > 1 ? 's' : ''}',
 style: const TextStyle(fontSize: 12, color: Colors.grey[600]),
 ),
 ],
 ],
 ),
 ],
 ] else ...[
 // Vue compacte - informations essentielles
 const SizedBox(height: 8),
 Row(
 children: [
 _buildCompactStatus(),
 const Spacer(),
 if (task.dueDate != null)
 T{ext(
 _formatDate(task.dueDate!),
 style: const TextStyle(
 fontSize: 12,
 color: task.isOverdue ? Colors.red : Colors.grey[600],
 fontWeight: task.isOverdue ? FontWeight.bold : null,
 ),
 ),
 ],
 ),
 ],
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildTypeChip() {
 return Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: _getTypeColor().withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 _getTypeDisplayName(),
 style: const TextStyle(
 fontSize: 10,
 color: _getTypeColor(),
 fontWeight: FontWeight.w500,
 ),
 ),
 );
 }

 Widget _buildProjectChip() {
 return Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: Colors.blue.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 'Projet',
 style: const TextStyle(
 fontSize: 10,
 color: Colors.blue,
 fontWeight: FontWeight.w500,
 ),
 ),
 );
 }

 Widget _buildStatusSelector() {
 return Container(
 decoration: BoxDecoration(
 color: _getStatusColor().withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(color: _getStatusColor().withOpacity(0.3)),
 ),
 child: PopupMenuButton<TaskStatus>(
 initialValue: task.status,
 onSelected: (newStatus) {
 onStatusChanged?.call(newStatus);
 },
 child: Padding(
 padding: const EdgeInsets.symmetric(1),
 child: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 _getStatusIcon(),
 size: 16,
 color: _getStatusColor(),
 ),
 const SizedBox(width: 6),
 Text(
 _getStatusDisplayName(),
 style: const TextStyle(
 fontSize: 12,
 color: _getStatusColor(),
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(width: 4),
 Icon(
 Icons.arrow_drop_down,
 size: 16,
 color: _getStatusColor(),
 ),
 ],
 ),
 ),
 itemBuilder: (context) => TaskStatus.values.map((status) {
 return PopupMenuItem(
 value: status,
 child: Row(
 children: [
 Icon(
 _getStatusIconForStatus(status),
 size: 16,
 color: _getStatusColorForStatus(status),
 ),
 const SizedBox(width: 8),
 Text(_getStatusDisplayNameForStatus(status)),
 ],
 ),
 );
 }).toList(),
 ),
 );
 }

 Widget _buildCompactStatus() {
 return Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: _getStatusColor().withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 _getStatusIcon(),
 size: 12,
 color: _getStatusColor(),
 ),
 const SizedBox(width: 4),
 Text(
 _getStatusDisplayName(),
 style: const TextStyle(
 fontSize: 10,
 color: _getStatusColor(),
 fontWeight: FontWeight.w500,
 ),
 ),
 ],
 ),
 );
 }

 Color _getPriorityColor() {
 switch (task.priority) {
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

 Color _getStatusColor() {
 return _getStatusColorForStatus(task.status);
 }

 Color _getStatusColorForStatus(TaskStatus status) {
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

 IconData _getStatusIcon() {
 return _getStatusIconForStatus(task.status);
 }

 IconData _getStatusIconForStatus(TaskStatus status) {
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

 String _getStatusDisplayName() {
 return _getStatusDisplayNameForStatus(task.status);
 }

 String _getStatusDisplayNameForStatus(TaskStatus status) {
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

 Color _getTypeColor() {
 switch (task.type) {
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

 String _getTypeDisplayName() {
 switch (task.type) {
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

 Color _getProgressColor() {
 if (task.progress == null) r{eturn Colors.grey;
 if (task.progress! >= 80) r{eturn Colors.green;
 if (task.progress! >= 50) r{eturn Colors.blue;
 if (task.progress! >= 25) r{eturn Colors.orange;
 return Colors.red;
 }

 String _formatDate(DateTime date) {
 final now = DateTime.now();
 final difference = date.difference(now);

 if (difference.isNegative) {{
 final days = difference.inDays.abs();
 if (days == 0) {{
 return 'Aujourd\'hui';
 } else if (days == 1) {{
 return 'Hier';
 } else if (days < 7) {{
 return 'Il y a $days jours';
 } else {
 return '${date.day}/${date.month}/${date.year}';
 }
} else {
 final days = difference.inDays;
 if (days == 0) {{
 return 'Aujourd\'hui';
 } else if (days == 1) {{
 return 'Demain';
 } else if (days < 7) {{
 return 'Dans $days jours';
 } else {
 return '${date.day}/${date.month}/${date.year}';
 }
}
 }

 void _handleMenuAction(String action) {
 switch (action) {
 case 'edit':
 onEdit?.call();
 break;
 case 'delete':
 onDelete?.call();
 break;
}
 }
}

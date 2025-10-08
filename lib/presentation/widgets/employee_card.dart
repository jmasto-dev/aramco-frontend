import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:aramco_frontend/core/models/employee.dart';
import 'package:aramco_frontend/core/app_theme.dart';

class EmployeeCard extends StatelessWidget {
 final Employee employee;
 final VoidCallback? onTap;
 final VoidCallback? onEdit;
 final VoidCallback? onDelete;
 final VoidCallback? onToggleStatus;
 final bool showActions;

 const EmployeeCard({
 super.key,
 required this.employee,
 this.onTap,
 this.onEdit,
 this.onDelete,
 this.onToggleStatus,
 this.showActions = true,
 });

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.only(bottom: 12),
 elevation: 2,
 shape: RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 // Avatar
 _buildAvatar(),
 const SizedBox(width: 16),
 
 // Informations principales
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Expanded(
 child: Text(
 employee.fullName,
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 _buildStatusBadge(),
 ],
 ),
 const SizedBox(height: 4),
 Text(
 employee.position,
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(height: 2),
 Text(
 employee.formattedDepartment,
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[500],
 ),
 ),
 ],
 ),
 ),
 
 // Actions
 if (showActions) _{buildActions(context),
 ],
 ),
 
 const SizedBox(height: 12),
 
 // Informations supplémentaires
 _buildAdditionalInfo(context),
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildAvatar() {
 return CircleAvatar(
 radius: 28,
 backgroundColor: employee.isActive ? AppTheme.primaryColor : Colors.grey,
 child: Text(
 (employee.user?.firstName[0] ?? 'E') + (employee.user?.lastName[0] ?? '?'),
 style: const TextStyle(
 color: Colors.white,
 fontWeight: FontWeight.bold,
 fontSize: 16,
 ),
 ),
 );
 }

 Widget _buildStatusBadge() {
 return Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: employee.isActive ? Colors.green : Colors.orange,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 employee.isActive ? 'Actif' : 'Inactif',
 style: const TextStyle(
 color: Colors.white,
 fontSize: 10,
 fontWeight: FontWeight.bold,
 ),
 ),
 );
 }

 Widget _buildActions(BuildContext context) {
 return PopupMenuButton<String>(
 icon: Icon(Icons.more_vert, color: Colors.grey[600]),
 onSelected: (value) {
 switch (value) {
 case 'view':
 onTap?.call();
 break;
 case 'edit':
 onEdit?.call();
 break;
 case 'toggle':
 onToggleStatus?.call();
 break;
 case 'delete':
 _showDeleteConfirmation(context);
 break;
 }
 },
 itemBuilder: (context) => [
 const PopupMenuItem(
 value: 'view',
 child: Row(
 children: [
 Icon(Icons.visibility, size: 18),
 const SizedBox(width: 8),
 Text('Voir les détails'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'edit',
 child: Row(
 children: [
 Icon(Icons.edit, size: 18),
 const SizedBox(width: 8),
 Text('Modifier'),
 ],
 ),
 ),
 PopupMenuItem(
 value: 'toggle',
 child: Row(
 children: [
 Icon(
 employee.isActive ? Icons.block : Icons.check_circle,
 size: 18,
 ),
 const SizedBox(width: 8),
 Text(employee.isActive ? 'Désactiver' : 'Activer'),
 ],
 ),
 ),
 if (onDelete != null)
 c{onst PopupMenuItem(
 value: 'delete',
 child: Row(
 children: [
 Icon(Icons.delete, size: 18, color: Colors.red),
 const SizedBox(width: 8),
 Text('Supprimer', style: const TextStyle(color: Colors.red)),
 ],
 ),
 ),
 ],
 );
 }

 Widget _buildAdditionalInfo(BuildContext context) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.grey[50],
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Column(
 children: [
 Row(
 children: [
 Icon(Icons.email, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 8),
 Expanded(
 child: Text(
 employee.email,
 style: Theme.of(context).textTheme.bodySmall,
 ),
 ),
 ],
 ),
 if (employee.phone != null && employee.phone!.isNotEmpty) .{..[
 const SizedBox(height: 4),
 Row(
 children: [
 Icon(Icons.phone, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 8),
 Text(
 employee.phone!,
 style: Theme.of(context).textTheme.bodySmall,
 ),
 ],
 ),
 ],
 const SizedBox(height: 4),
 Row(
 children: [
 Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 8),
 Text(
 'Embauché le ${employee.hireDate.toString().split(' ')[0]}',
 style: Theme.of(context).textTheme.bodySmall,
 ),
 const Spacer(),
 if (employee.salary != null)
 T{ext(
 '${employee.salary!.toStringAsFixed(0)} €/an',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 fontWeight: FontWeight.bold,
 color: AppTheme.primaryColor,
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 void _showDeleteConfirmation(BuildContext context) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Supprimer l\'employé'),
 content: Text(
 'Êtes-vous sûr de vouloir supprimer ${employee.fullName} ?\nCette action est irréversible.',
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () {
 Navigator.pop(context);
 onDelete?.call();
},
 style: TextButton.styleFrom(foregroundColor: Colors.red),
 child: const Text('Supprimer'),
 ),
 ],
 ),
 );
 }
}

// Version compacte pour les listes
class EmployeeCardCompact extends StatelessWidget {
 final Employee employee;
 final VoidCallback? onTap;
 final VoidCallback? onEdit;
 final VoidCallback? onToggleStatus;

 const EmployeeCardCompact({
 super.key,
 required this.employee,
 this.onTap,
 this.onEdit,
 this.onToggleStatus,
 });

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.only(bottom: 8),
 child: ListTile(
 leading: CircleAvatar(
 backgroundColor: employee.isActive ? AppTheme.primaryColor : Colors.grey,
 child: Text(
 (employee.user?.firstName[0] ?? 'E') + (employee.user?.lastName[0] ?? '?'),
 style: const TextStyle(
 color: Colors.white,
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 title: Text(employee.fullName),
 subtitle: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(employee.position),
 Text(employee.formattedDepartment),
 ],
 ),
 trailing: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 // Badge de statut
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: employee.isActive ? Colors.green : Colors.orange,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 employee.isActive ? 'Actif' : 'Inactif',
 style: const TextStyle(
 color: Colors.white,
 fontSize: 8,
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 const SizedBox(width: 8),
 // Menu d'actions
 PopupMenuButton<String>(
 icon: const Icon(Icons.more_vert),
 onSelected: (value) {
 switch (value) {
 case 'edit':
 onEdit?.call();
 break;
 case 'toggle':
 onToggleStatus?.call();
 break;
 }
 },
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
 PopupMenuItem(
 value: 'toggle',
 child: Row(
 children: [
 Icon(
 employee.isActive ? Icons.block : Icons.check_circle,
 size: 16,
 ),
 const SizedBox(width: 8),
 Text(employee.isActive ? 'Désactiver' : 'Activer'),
 ],
 ),
 ),
 ],
 ),
 ],
 ),
 onTap: onTap,
 ),
 );
 }
}

// Version grille pour les vues en grille
class EmployeeCardGrid extends StatelessWidget {
 final Employee employee;
 final VoidCallback? onTap;
 final VoidCallback? onEdit;
 final VoidCallback? onToggleStatus;

 const EmployeeCardGrid({
 super.key,
 required this.employee,
 this.onTap,
 this.onEdit,
 this.onToggleStatus,
 });

 @override
 Widget build(BuildContext context) {
 return Card(
 elevation: 2,
 shape: RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.center,
 children: [
 // Avatar
 CircleAvatar(
 radius: 32,
 backgroundColor: employee.isActive ? AppTheme.primaryColor : Colors.grey,
 child: Text(
 (employee.user?.firstName[0] ?? 'E') + (employee.user?.lastName[0] ?? '?'),
 style: const TextStyle(
 color: Colors.white,
 fontWeight: FontWeight.bold,
 fontSize: 20,
 ),
 ),
 ),
 const SizedBox(height: 12),
 
 // Nom
 Text(
 employee.fullName,
 style: Theme.of(context).textTheme.titleSmall?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 textAlign: TextAlign.center,
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 const SizedBox(height: 4),
 
 // Poste
 Text(
 employee.position,
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[600],
 ),
 textAlign: TextAlign.center,
 maxLines: 1,
 overflow: TextOverflow.ellipsis,
 ),
 const SizedBox(height: 4),
 
 // Département
 Text(
 employee.formattedDepartment,
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[500],
 ),
 textAlign: TextAlign.center,
 maxLines: 1,
 overflow: TextOverflow.ellipsis,
 ),
 
 const Spacer(),
 
 // Statut
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: employee.isActive ? Colors.green : Colors.orange,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 employee.isActive ? 'Actif' : 'Inactif',
 style: const TextStyle(
 color: Colors.white,
 fontSize: 10,
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 ],
 ),
 ),
 ),
 );
 }
}

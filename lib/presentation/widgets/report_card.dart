import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/report.dart';

class ReportCard extends StatelessWidget {
 final Report report;
 final VoidCallback? onTap;
 final VoidCallback? onEdit;
 final VoidCallback? onDelete;
 final VoidCallback? onRun;
 final VoidCallback? onSchedule;
 final VoidCallback? onExport;
 final VoidCallback? onDuplicate;
 final VoidCallback? onShare;
 final VoidCallback? onToggle;

 const ReportCard({
 Key? key,
 required this.report,
 this.onTap,
 this.onEdit,
 this.onDelete,
 this.onRun,
 this.onSchedule,
 this.onExport,
 this.onDuplicate,
 this.onShare,
 this.onToggle,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.only(bottom: 12.0),
 elevation: 2.0,
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête avec nom, type et statut
 Row(
 children: [
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 report.name,
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 2.0),
 Text(
 report.description,
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Theme.of(context).colorScheme.outline,
 ),
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 ],
 ),
 ),
 _buildStatusChip(context),
 ],
 ),
 
 const SizedBox(height: 12.0),
 
 // Informations principales
 Row(
 children: [
 Icon(
 _getTypeIcon(report.type),
 size: 16.0,
 color: Theme.of(context).colorScheme.primary,
 ),
 const SizedBox(width: 4.0),
 Text(
 _getTypeText(report.type),
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Theme.of(context).colorScheme.primary,
 ),
 ),
 const Spacer(),
 Icon(
 _getCategoryIcon(report.category),
 size: 16.0,
 color: Theme.of(context).colorScheme.secondary,
 ),
 const SizedBox(width: 4.0),
 Text(
 _getCategoryText(report.category),
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Theme.of(context).colorScheme.secondary,
 ),
 ),
 ],
 ),
 
 const SizedBox(height: 8.0),
 
 // Métadonnées
 Row(
 children: [
 Icon(
 Icons.person,
 size: 16.0,
 color: Theme.of(context).colorScheme.outline,
 ),
 const SizedBox(width: 4.0),
 Expanded(
 child: Text(
 report.createdByName ?? 'Inconnu',
 style: Theme.of(context).textTheme.bodySmall,
 overflow: TextOverflow.ellipsis,
 ),
 ),
 Icon(
 Icons.calendar_today,
 size: 16.0,
 color: Theme.of(context).colorScheme.outline,
 ),
 const SizedBox(width: 4.0),
 Text(
 _formatDate(report.createdAt),
 style: Theme.of(context).textTheme.bodySmall,
 ),
 ],
 ),
 
 const SizedBox(height: 8.0),
 
 // Informations d'exécution
 Row(
 children: [
 if (report.isScheduled) .{..[
 Icon(
 Icons.schedule,
 size: 16.0,
 color: Colors.orange,
 ),
 const SizedBox(width: 4.0),
 Text(
 'Planifié',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.orange,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(width: 16.0),
 ],
 Icon(
 Icons.play_arrow,
 size: 16.0,
 color: Theme.of(context).colorScheme.outline,
 ),
 const SizedBox(width: 4.0),
 Text(
 '${report.runCount} exécutions',
 style: Theme.of(context).textTheme.bodySmall,
 ),
 if (report.averageRunTime != null) .{..[
 const SizedBox(width: 16.0),
 Icon(
 Icons.timer,
 size: 16.0,
 color: Theme.of(context).colorScheme.outline,
 ),
 const SizedBox(width: 4.0),
 Text(
 _formatDuration(report.averageRunTime!),
 style: Theme.of(context).textTheme.bodySmall,
 ),
 ],
 ],
 ),
 
 // Prochaine exécution si planifié
 if (report.nextRunAt != null) .{..[
 const SizedBox(height: 8.0),
 Row(
 children: [
 Icon(
 Icons.next_plan,
 size: 16.0,
 color: Colors.blue,
 ),
 const SizedBox(width: 4.0),
 Text(
 'Prochaine exécution: ${_formatDateTime(report.nextRunAt!)}',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.blue,
 fontWeight: FontWeight.w500,
 ),
 ),
 ],
 ),
 ],
 
 // Message d'erreur si présent
 if (report.hasError) .{..[
 const SizedBox(height: 8.0),
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.red.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(color: Colors.red.withOpacity(0.3)),
 ),
 child: Row(
 children: [
 Icon(
 Icons.error_outline,
 size: 16.0,
 color: Colors.red,
 ),
 const SizedBox(width: 4.0),
 Expanded(
 child: Text(
 report.lastError!,
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.red,
 ),
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 ),
 ],
 ),
 ),
 ],
 
 const SizedBox(height: 12.0),
 
 // Actions
 _buildActionButtons(context),
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildStatusChip(BuildContext context) {
 Color color;
 String text;
 
 switch (report.status) {
 case ReportStatus.draft:
 color = Colors.grey;
 text = 'Brouillon';
 break;
 case ReportStatus.ready:
 color = Colors.blue;
 text = 'Prêt';
 break;
 case ReportStatus.running:
 color = Colors.orange;
 text = 'En cours';
 break;
 case ReportStatus.completed:
 color = Colors.green;
 text = 'Terminé';
 break;
 case ReportStatus.failed:
 color = Colors.red;
 text = 'Échoué';
 break;
 case ReportStatus.cancelled:
 color = Colors.black;
 text = 'Annulé';
 break;
}
 
 return Chip(
 label: Text(
 text,
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.white,
 fontWeight: FontWeight.bold,
 ),
 ),
 backgroundColor: color,
 visualDensity: VisualDensity.compact,
 );
 }

 Widget _buildActionButtons(BuildContext context) {
 return Row(
 mainAxisAlignment: MainAxisAlignment.end,
 children: [
 if (onRun != null && report.canRun)
 I{conButton(
 onPressed: onRun,
 icon: const Icon(Icons.play_arrow, size: 20.0),
 tooltip: 'Exécuter',
 color: Colors.green,
 ),
 if (onSchedule != null && report.canEdit)
 I{conButton(
 onPressed: onSchedule,
 icon: const Icon(Icons.schedule, size: 20.0),
 tooltip: 'Planifier',
 color: Colors.orange,
 ),
 if (onExport != null)
 I{conButton(
 onPressed: onExport,
 icon: const Icon(Icons.download, size: 20.0),
 tooltip: 'Exporter',
 color: Colors.blue,
 ),
 if (onDuplicate != null)
 I{conButton(
 onPressed: onDuplicate,
 icon: const Icon(Icons.copy, size: 20.0),
 tooltip: 'Dupliquer',
 color: Colors.purple,
 ),
 if (onShare != null && report.canShare)
 I{conButton(
 onPressed: onShare,
 icon: const Icon(Icons.share, size: 20.0),
 tooltip: 'Partager',
 color: Colors.teal,
 ),
 if (onToggle != null)
 I{conButton(
 onPressed: onToggle,
 icon: Icon(
 report.isActive ? Icons.toggle_on : Icons.toggle_off,
 size: 20.0,
 color: report.isActive ? Colors.green : Colors.grey,
 ),
 tooltip: report.isActive ? 'Désactiver' : 'Activer',
 ),
 if (onEdit != null && report.canEdit)
 I{conButton(
 onPressed: onEdit,
 icon: const Icon(Icons.edit, size: 20.0),
 tooltip: 'Modifier',
 color: Colors.blue,
 ),
 if (onDelete != null && report.canDelete)
 I{conButton(
 onPressed: onDelete,
 icon: const Icon(Icons.delete, size: 20.0),
 tooltip: 'Supprimer',
 color: Colors.red,
 ),
 ],
 );
 }

 IconData _getTypeIcon(ReportType type) {
 switch (type) {
 case ReportType.tabular:
 return Icons.table_chart;
 case ReportType.summary:
 return Icons.summarize;
 case ReportType.chart:
 return Icons.bar_chart;
 case ReportType.dashboard:
 return Icons.dashboard;
 case ReportType.crosstab:
 return Icons.grid_on;
}
 }

 String _getTypeText(ReportType type) {
 switch (type) {
 case ReportType.tabular:
 return 'Tabulaire';
 case ReportType.summary:
 return 'Résumé';
 case ReportType.chart:
 return 'Graphique';
 case ReportType.dashboard:
 return 'Tableau de bord';
 case ReportType.crosstab:
 return 'Tableau croisé';
}
 }

 IconData _getCategoryIcon(ReportCategory category) {
 switch (category) {
 case ReportCategory.financial:
 return Icons.attach_money;
 case ReportCategory.operational:
 return Icons.settings;
 case ReportCategory.hr:
 return Icons.people;
 case ReportCategory.sales:
 return Icons.trending_up;
 case ReportCategory.purchasing:
 return Icons.shopping_cart;
 case ReportCategory.inventory:
 return Icons.inventory;
 case ReportCategory.custom:
 return Icons.category;
}
 }

 String _getCategoryText(ReportCategory category) {
 switch (category) {
 case ReportCategory.financial:
 return 'Financier';
 case ReportCategory.operational:
 return 'Opérationnel';
 case ReportCategory.hr:
 return 'RH';
 case ReportCategory.sales:
 return 'Ventes';
 case ReportCategory.purchasing:
 return 'Achats';
 case ReportCategory.inventory:
 return 'Inventaire';
 case ReportCategory.custom:
 return 'Personnalisé';
}
 }

 String _formatDate(DateTime date) {
 return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
 }

 String _formatDateTime(DateTime dateTime) {
 return '${_formatDate(dateTime)} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
 }

 String _formatDuration(Duration duration) {
 final minutes = duration.inMinutes;
 final seconds = duration.inSeconds % 60;
 return '${minutes}m ${seconds}s';
 }
}

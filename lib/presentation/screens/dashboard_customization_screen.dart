import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/dashboard_widget.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_grid.dart';

class DashboardCustomizationScreen extends ConsumerStatefulWidget {
 const DashboardCustomizationScreen({Key? key}) : super(key: key);

 @override
 ConsumerState<DashboardCustomizationScreen> createState() => _DashboardCustomizationScreenState();
}

class _DashboardCustomizationScreenState extends ConsumerState<DashboardCustomizationScreen> {
 bool _isEditMode = true;
 List<DashboardWidget> _availableWidgets = [];

 @override
 void initState() {
 super.initState();
 _loadAvailableWidgets();
 WidgetsBinding.instance.addPostFrameCallback((_) {
 ref.read(dashboardProvider.notifier).loadDashboard();
});
 }

 void _loadAvailableWidgets() {
 _availableWidgets = [
 DashboardWidget(
 id: 'kpi_employees',
 title: 'Total Employés',
 type: WidgetType.kpi,
 row: 0,
 column: 0,
 rowSpan: 1,
 columnSpan: 1,
 config: {'icon': 'people', 'color': '#2196F3'},
 lastUpdated: DateTime.now(),
 ),
 DashboardWidget(
 id: 'kpi_leave_requests',
 title: 'Demandes de Congé',
 type: WidgetType.kpi,
 row: 0,
 column: 1,
 rowSpan: 1,
 columnSpan: 1,
 config: {'icon': 'event', 'color': '#FF9800'},
 lastUpdated: DateTime.now(),
 ),
 DashboardWidget(
 id: 'chart_sales',
 title: 'Ventes Mensuelles',
 type: WidgetType.chart,
 chartType: ChartType.bar,
 row: 1,
 column: 0,
 rowSpan: 2,
 columnSpan: 2,
 config: {'chartType': 'bar'},
 lastUpdated: DateTime.now(),
 ),
 DashboardWidget(
 id: 'chart_performance',
 title: 'Performance',
 type: WidgetType.chart,
 chartType: ChartType.line,
 row: 1,
 column: 2,
 rowSpan: 2,
 columnSpan: 2,
 config: {'chartType': 'line'},
 lastUpdated: DateTime.now(),
 ),
 DashboardWidget(
 id: 'alert_system',
 title: 'Alertes Système',
 type: WidgetType.alert,
 row: 3,
 column: 0,
 rowSpan: 2,
 columnSpan: 2,
 config: {'category': 'system'},
 lastUpdated: DateTime.now(),
 ),
 ];
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Personnaliser le Tableau de Bord'),
 backgroundColor: Theme.of(context).colorScheme.inversePrimary,
 actions: [
 IconButton(
 icon: Icon(_isEditMode ? Icons.preview : Icons.edit),
 onPressed: () {
 setState(() {
 _isEditMode = !_isEditMode;
 });
},
 tooltip: _isEditMode ? 'Aperçu' : 'Mode Édition',
 ),
 TextButton(
 onPressed: _saveLayout,
 child: const Text('Sauvegarder'),
 ),
 ],
 ),
 body: Consumer(
 builder: (context, ref, child) {
 final provider = ref.watch(dashboardProvider);
 
 if (provider.isLoading) {{
 return const Center(child: CircularProgressIndicator());
}

 if (provider.error != null) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.error_outline,
 size: 64,
 color: Theme.of(context).colorScheme.error,
 ),
 const SizedBox(height: 16),
 Text(
 'Erreur: ${provider.error}',
 style: Theme.of(context).textTheme.titleMedium,
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 16),
 ElevatedButton(
 onPressed: () => ref.read(dashboardProvider.notifier).loadDashboard(),
 child: const Text('Réessayer'),
 ),
 ],
 ),
 );
}

 return Column(
 children: [
 _buildToolbar(),
 Expanded(
 child: Row(
 children: [
 // Panneau des widgets disponibles
 if (_isEditMode) _{buildAvailableWidgetsPanel(),
 // Grille du tableau de bord
 Expanded(
 child: _buildDashboardGrid(provider),
 ),
 ],
 ),
 ),
 ],
 );
 },
 ),
 );
 }

 Widget _buildToolbar() {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 boxShadow: [
 BoxShadow(
 color: Colors.black.withOpacity(0.1),
 blurRadius: 4,
 offset: const Offset(0, 2),
 ),
 ],
 ),
 child: Row(
 children: [
 Icon(
 Icons.dashboard_customize,
 color: Theme.of(context).primaryColor,
 ),
 const SizedBox(width: 8),
 Text(
 _isEditMode ? 'Mode Édition' : 'Mode Aperçu',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 ),
 ),
 const Spacer(),
 if (_isEditMode) .{..[
 OutlinedButton.icon(
 onPressed: _resetLayout,
 icon: const Icon(Icons.refresh),
 label: const Text('Réinitialiser'),
 ),
 const SizedBox(width: 8),
 OutlinedButton.icon(
 onPressed: _optimizeLayout,
 icon: const Icon(Icons.auto_awesome),
 label: const Text('Optimiser'),
 ),
 ],
 ],
 ),
 );
 }

 Widget _buildAvailableWidgetsPanel() {
 return Container(
 width: 300,
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 border: Border(
 right: BorderSide(
 color: Theme.of(context).dividerColor,
 width: 1,
 ),
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Container(
 padding: const EdgeInsets.all(1),
 child: Text(
 'Widgets Disponibles',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 ),
 ),
 ),
 Divider(height: 1),
 Expanded(
 child: ListView.builder(
 padding: const EdgeInsets.all(1),
 itemCount: _availableWidgets.length,
 itemBuilder: (context, index) {
 final widget = _availableWidgets[index];
 return _buildAvailableWidgetCard(widget);
 },
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildAvailableWidgetCard(DashboardWidget widget) {
 return Card(
 margin: const EdgeInsets.symmetric(1),
 child: ListTile(
 leading: CircleAvatar(
 backgroundColor: _getWidgetColor(widget.type),
 child: Icon(
 _getWidgetIcon(widget.type),
 color: Colors.white,
 size: 20,
 ),
 ),
 title: Text(
 widget.title,
 style: const TextStyle(fontWeight: FontWeight.w600),
 ),
 subtitle: Text(_getWidgetDescription(widget.type)),
 trailing: const Icon(Icons.add_circle_outline),
 onTap: () => _addWidgetToDashboard(widget),
 ),
 );
 }

 Widget _buildDashboardGrid(DashboardProvider provider) {
 return Container(
 padding: const EdgeInsets.all(1),
 child: DashboardGrid(
 widgets: provider.widgets,
 isEditMode: _isEditMode,
 onWidgetTap: _onWidgetTap,
 onWidgetEdit: _onWidgetEdit,
 onWidgetDelete: _onWidgetDelete,
 onWidgetMove: _onWidgetMove,
 ),
 );
 }

 void _addWidgetToDashboard(DashboardWidget widget) {
 try {
 final provider = ref.read(dashboardProvider);
 final position = DashboardGridLayoutManager.findAvailableSpace(
 provider.widgets,
 widget.columnSpan,
 widget.rowSpan,
 );

 final newWidget = widget.copyWith(
 id: '${widget.id}_${DateTime.now().millisecondsSinceEpoch}',
 row: position['row']!,
 column: position['col']!,
 );

 ref.read(dashboardProvider.notifier).addWidget(newWidget);
 
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('Widget "${widget.title}" ajouté avec succès'),
 backgroundColor: Colors.green,
 ),
 );
} catch (e) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('Erreur: ${e.toString()}'),
 backgroundColor: Colors.red,
 ),
 );
}
 }

 void _onWidgetTap(DashboardWidget widget) {
 if (!_isEditMode) {{
 // En mode aperçu, afficher les détails du widget
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: Text(widget.title),
 content: Column(
 mainAxisSize: MainAxisSize.min,
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text('Type: ${widget.type.name}'),
 Text('Position: (${widget.row}, ${widget.column})'),
 Text('Taille: ${widget.rowSpan}x${widget.columnSpan}'),
 if (widget.dataSource != null) 
 T{ext('Source: ${widget.dataSource}'),
 ],
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(),
 child: const Text('Fermer'),
 ),
 ],
 ),
 );
}
 }

 void _onWidgetEdit(DashboardWidget widget) {
 showDialog(
 context: context,
 builder: (context) => _buildWidgetEditDialog(widget),
 );
 }

 void _onWidgetDelete(DashboardWidget widget) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Supprimer le Widget'),
 content: Text('Voulez-vous vraiment supprimer le widget "${widget.title}" ?'),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () {
 ref.read(dashboardProvider.notifier).removeWidget(widget.id);
 Navigator.of(context).pop();
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('Widget "${widget.title}" supprimé'),
 backgroundColor: Colors.orange,
 ),
 );
},
 child: const Text('Supprimer'),
 ),
 ],
 ),
 );
 }

 void _onWidgetMove(DashboardWidget widget, int row, int col) {
 final updatedWidget = widget.copyWith(row: row, column: col);
 ref.read(dashboardProvider.notifier).updateWidget(updatedWidget);
 }

 Widget _buildWidgetEditDialog(DashboardWidget widget) {
 final titleController = TextEditingController(text: widget.title);
 
 return AlertDialog(
 title: Text('Modifier: ${widget.title}'),
 content: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 TextField(
 controller: titleController,
 decoration: const InputDecoration(
 labelText: 'Titre',
 border: OutlineInputBorder(),
 ),
 ),
 const SizedBox(height: 16),
 Row(
 children: [
 Expanded(
 child: ListTile(
 title: const Text('Hauteur'),
 subtitle: Text('${widget.rowSpan}'),
 trailing: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 IconButton(
 icon: const Icon(Icons.remove),
 onPressed: widget.rowSpan > 1 ? () {
 final updated = widget.copyWith(rowSpan: widget.rowSpan - 1);
 ref.read(dashboardProvider.notifier).updateWidget(updated);
 Navigator.of(context).pop();
 _onWidgetEdit(updated);
} : null,
 ),
 IconButton(
 icon: const Icon(Icons.add),
 onPressed: widget.rowSpan < 4 ? () {
 final updated = widget.copyWith(rowSpan: widget.rowSpan + 1);
 ref.read(dashboardProvider.notifier).updateWidget(updated);
 Navigator.of(context).pop();
 _onWidgetEdit(updated);
} : null,
 ),
 ],
 ),
 ),
 ),
 Expanded(
 child: ListTile(
 title: const Text('Largeur'),
 subtitle: Text('${widget.columnSpan}'),
 trailing: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 IconButton(
 icon: const Icon(Icons.remove),
 onPressed: widget.columnSpan > 1 ? () {
 final updated = widget.copyWith(columnSpan: widget.columnSpan - 1);
 ref.read(dashboardProvider.notifier).updateWidget(updated);
 Navigator.of(context).pop();
 _onWidgetEdit(updated);
} : null,
 ),
 IconButton(
 icon: const Icon(Icons.add),
 onPressed: widget.columnSpan < 4 ? () {
 final updated = widget.copyWith(columnSpan: widget.columnSpan + 1);
 ref.read(dashboardProvider.notifier).updateWidget(updated);
 Navigator.of(context).pop();
 _onWidgetEdit(updated);
} : null,
 ),
 ],
 ),
 ),
 ),
 ],
 ),
 ],
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () {
 final updatedWidget = widget.copyWith(title: titleController.text);
 ref.read(dashboardProvider.notifier).updateWidget(updatedWidget);
 Navigator.of(context).pop();
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Widget mis à jour'),
 backgroundColor: Colors.green,
 ),
 );
},
 child: const Text('Sauvegarder'),
 ),
 ],
 );
 }

 void _saveLayout() {
 ref.read(dashboardProvider.notifier).saveDashboard();
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Tableau de bord sauvegardé avec succès'),
 backgroundColor: Colors.green,
 ),
 );
 Navigator.of(context).pop();
 }

 void _resetLayout() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Réinitialiser le Tableau de Bord'),
 content: const Text('Voulez-vous vraiment réinitialiser le tableau de bord à sa configuration par défaut ?'),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () {
 ref.read(dashboardProvider.notifier).resetToDefault();
 Navigator.of(context).pop();
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Tableau de bord réinitialisé'),
 backgroundColor: Colors.orange,
 ),
 );
},
 child: const Text('Réinitialiser'),
 ),
 ],
 ),
 );
 }

 void _optimizeLayout() {
 final provider = ref.read(dashboardProvider);
 final optimizedWidgets = DashboardGridLayoutManager.optimizeLayout(
 provider.widgets,
 );
 
 for (final widget in optimizedWidgets) {
 ref.read(dashboardProvider.notifier).updateWidget(widget);
}
 
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Disposition optimisée'),
 backgroundColor: Colors.blue,
 ),
 );
 }

 Color _getWidgetColor(WidgetType type) {
 switch (type) {
 case WidgetType.kpi:
 return Colors.blue;
 case WidgetType.chart:
 return Colors.green;
 case WidgetType.alert:
 return Colors.orange;
 case WidgetType.table:
 return Colors.purple;
 case WidgetType.calendar:
 return Colors.red;
 case WidgetType.news:
 return Colors.teal;
}
 }

 IconData _getWidgetIcon(WidgetType type) {
 switch (type) {
 case WidgetType.kpi:
 return Icons.speed;
 case WidgetType.chart:
 return Icons.bar_chart;
 case WidgetType.alert:
 return Icons.notifications;
 case WidgetType.table:
 return Icons.table_chart;
 case WidgetType.calendar:
 return Icons.calendar_today;
 case WidgetType.news:
 return Icons.article;
}
 }

 String _getWidgetDescription(WidgetType type) {
 switch (type) {
 case WidgetType.kpi:
 return 'Indicateur de performance clé';
 case WidgetType.chart:
 return 'Graphique de données';
 case WidgetType.alert:
 return 'Panneau d\'alertes';
 case WidgetType.table:
 return 'Tableau de données';
 case WidgetType.calendar:
 return 'Calendrier d\'événements';
 case WidgetType.news:
 return 'Fil d\'actualités';
}
 }
}

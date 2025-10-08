import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/export_preview.dart';
import '../../core/models/export_options.dart';
import '../../core/models/order_status.dart';
import '../../core/services/export_service.dart';

class ExportOrdersScreen extends ConsumerStatefulWidget {
 const ExportOrdersScreen({super.key});

 @override
 ConsumerState<ExportOrdersScreen> createState() => _ExportOrdersScreenState();
}

class _ExportOrdersScreenState extends ConsumerState<ExportOrdersScreen>
 with TickerProviderStateMixin {
 late TabController _tabController;
 late TextEditingController _fileNameController;
 late TextEditingController _searchController;
 
 ExportFormat _selectedFormat = ExportFormat.pdf;
 ExportTemplate _selectedTemplate = ExportTemplate.standard;
 List<ExportColumn> _selectedColumns = [];
 ExportFilter _filter = const ExportFilter();
 
 bool _includeHeaders = true;
 bool _includeTotals = true;
 bool _includeCharts = false;
 bool _isLoading = false;

 @override
 void initState() {
 super.initState();
 _tabController = TabController(length: 2, vsync: this);
 _fileNameController = TextEditingController();
 _searchController = TextEditingController();
 _loadDefaultColumns();
 }

 @override
 void dispose() {
 _tabController.dispose();
 _fileNameController.dispose();
 _searchController.dispose();
 super.dispose();
 }

 void _loadDefaultColumns() {
 final exportService = ExportService();
 _selectedColumns = exportService.getTemplateColumns(_selectedTemplate);
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Exporter les Commandes'),
 bottom: TabBar(
 controller: _tabController,
 tabs: const [
 Tab(text: 'Options', icon: Icon(Icons.settings)),
 Tab(text: 'Aperçu', icon: Icon(Icons.preview)),
 ],
 ),
 actions: [
 IconButton(
 icon: const Icon(Icons.history),
 onPressed: _showExportHistory,
 tooltip: 'Historique des exports',
 ),
 ],
 ),
 body: LoadingOverlay(
 isLoading: _isLoading,
 child: TabBarView(
 controller: _tabController,
 children: [
 _buildOptionsTab(),
 _buildPreviewTab(),
 ],
 ),
 ),
 bottomNavigationBar: _buildBottomBar(),
 );
 }

 Widget _buildOptionsTab() {
 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildFormatSection(),
 const SizedBox(height: 24),
 _buildTemplateSection(),
 const SizedBox(height: 24),
 _buildFileNameSection(),
 const SizedBox(height: 24),
 _buildFilterSection(),
 const SizedBox(height: 24),
 _buildColumnsSection(),
 const SizedBox(height: 24),
 _buildAdditionalOptions(),
 ],
 ),
 );
 }

 Widget _buildFormatSection() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text(
 'Format d\'export',
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 Wrap(
 spacing: 8.0,
 children: ExportFormat.values.map((format) {
 final isSelected = _selectedFormat == format;
 return ChoiceChip(
 label: Text(format.displayName),
 selected: isSelected,
 onSelected: (selected) {
 if (selected) {{
 setState(() {
 _selectedFormat = format;
});
 }
 },
 avatar: Icon(_getFormatIcon(format)),
 );
 }).toList(),
 ),
 const SizedBox(height: 8),
 Text(
 _getFormatDescription(_selectedFormat),
 style: Theme.of(context).textTheme.bodySmall,
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildTemplateSection() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text(
 'Modèle d\'export',
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 Wrap(
 spacing: 8.0,
 children: ExportTemplate.values.map((template) {
 final isSelected = _selectedTemplate == template;
 return ChoiceChip(
 label: Text(template.displayName),
 selected: isSelected,
 onSelected: (selected) {
 if (selected) {{
 setState(() {
 _selectedTemplate = template;
 _loadDefaultColumns();
});
 }
 },
 );
 }).toList(),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildFileNameSection() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text(
 'Nom du fichier',
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 TextField(
 controller: _fileNameController,
 decoration: InputDecoration(
 labelText: 'Nom du fichier (sans extension)',
 hintText: 'export_commandes',
 suffixText: '.${_selectedFormat.extension}',
 border: const OutlineInputBorder(),
 prefixIcon: const Icon(Icons.description),
 ),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildFilterSection() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 const Text(
 'Filtres',
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 ),
 ),
 TextButton(
 onPressed: _showAdvancedFilters,
 child: const Text('Filtres avancés'),
 ),
 ],
 ),
 const SizedBox(height: 16),
 _buildDateRangeFilter(),
 const SizedBox(height: 12),
 _buildStatusFilter(),
 const SizedBox(height: 12),
 _buildAmountFilter(),
 ],
 ),
 ),
 );
 }

 Widget _buildDateRangeFilter() {
 return Row(
 children: [
 Expanded(
 child: ListTile(
 title: const Text('Date de début'),
 subtitle: Text(_filter.startDate != null
 ? DateFormat('dd/MM/yyyy').format(_filter.startDate!)
 : 'Non définie'),
 leading: const Icon(Icons.calendar_today),
 onTap: _selectStartDate,
 contentPadding: const EdgeInsets.zero,
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: ListTile(
 title: const Text('Date de fin'),
 subtitle: Text(_filter.endDate != null
 ? DateFormat('dd/MM/yyyy').format(_filter.endDate!)
 : 'Non définie'),
 leading: const Icon(Icons.calendar_today),
 onTap: _selectEndDate,
 contentPadding: const EdgeInsets.zero,
 ),
 ),
 ],
 );
 }

 Widget _buildStatusFilter() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text('Statuts à inclure:'),
 const SizedBox(height: 8),
 Wrap(
 spacing: 8.0,
 children: OrderStatus.values.map((status) {
 final isSelected = _filter.statuses?.contains(status.name) ?? false;
 return FilterChip(
 label: Text(status.displayName),
 selected: isSelected,
 onSelected: (selected) {
 setState(() {
 final statuses = List<String>.from(_filter.statuses ?? []);
 if (selected) {{
 statuses.add(status.name);
 } else {
 statuses.remove(status.name);
 }
 _filter = _filter.copyWith(statuses: statuses);
 });
 },
 );
}).toList(),
 ),
 ],
 );
 }

 Widget _buildAmountFilter() {
 return Row(
 children: [
 Expanded(
 child: TextField(
 decoration: const InputDecoration(
 labelText: 'Montant minimum',
 prefixText: '€ ',
 border: OutlineInputBorder(),
 ),
 keyboardType: TextInputType.number,
 onChanged: (value) {
 final amount = double.tryParse(value);
 setState(() {
 _filter = _filter.copyWith(minAmount: amount);
 });
},
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: TextField(
 decoration: const InputDecoration(
 labelText: 'Montant maximum',
 prefixText: '€ ',
 border: OutlineInputBorder(),
 ),
 keyboardType: TextInputType.number,
 onChanged: (value) {
 final amount = double.tryParse(value);
 setState(() {
 _filter = _filter.copyWith(maxAmount: amount);
 });
},
 ),
 ),
 ],
 );
 }

 Widget _buildColumnsSection() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 const Text(
 'Colonnes à exporter',
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 ),
 ),
 Row(
 children: [
 TextButton(
 onPressed: _selectAllColumns,
 child: const Text('Tout sélectionner'),
 ),
 TextButton(
 onPressed: _deselectAllColumns,
 child: const Text('Tout désélectionner'),
 ),
 ],
 ),
 ],
 ),
 const SizedBox(height: 16),
 ..._selectedColumns.map((column) => CheckboxListTile(
 title: Text(column.label),
 subtitle: Text('Largeur: ${column.width.toInt()}px'),
 value: column.selected,
 onChanged: (selected) {
 setState(() {
 final index = _selectedColumns.indexWhere((col) => col.key == column.key);
 if (index != -1) {{
 _selectedColumns[index] = column.copyWith(selected: selected ?? false);
 }
 });
 },
 controlAffinity: ListTileControlAffinity.leading,
 )),
 ],
 ),
 ),
 );
 }

 Widget _buildAdditionalOptions() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text(
 'Options supplémentaires',
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 SwitchListTile(
 title: const Text('Inclure les en-têtes'),
 subtitle: const Text('Ajouter une ligne d\'en-têtes'),
 value: _includeHeaders,
 onChanged: (value) {
 setState(() {
 _includeHeaders = value;
 });
 },
 ),
 SwitchListTile(
 title: const Text('Inclure les totaux'),
 subtitle: const Text('Ajouter une ligne de totaux'),
 value: _includeTotals,
 onChanged: (value) {
 setState(() {
 _includeTotals = value;
 });
 },
 ),
 if (_selectedFormat == ExportFormat.pdf)
 S{witchListTile(
 title: const Text('Inclure les graphiques'),
 subtitle: const Text('Ajouter des graphiques statistiques'),
 value: _includeCharts,
 onChanged: (value) {
 setState(() {
 _includeCharts = value;
 });
 },
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildPreviewTab() {
 return ExportPreview(
 format: _selectedFormat,
 template: _selectedTemplate,
 columns: _selectedColumns.where((col) => col.selected).toList(),
 filter: _filter,
 includeHeaders: _includeHeaders,
 includeTotals: _includeTotals,
 includeCharts: _includeCharts,
 );
 }

 Widget _buildBottomBar() {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 boxShadow: [
 BoxShadow(
 color: Colors.black.withOpacity(0.1),
 blurRadius: 4,
 offset: const Offset(0, -2),
 ),
 ],
 ),
 child: Row(
 children: [
 Expanded(
 child: OutlinedButton(
 onPressed: _resetOptions,
 child: const Text('Réinitialiser'),
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 flex: 2,
 child: CustomButton(
 text: 'Exporter',
 onPressed: _performExport,
 icon: Icons.download,
 ),
 ),
 ],
 ),
 );
 }

 IconData _getFormatIcon(ExportFormat format) {
 switch (format) {
 case ExportFormat.pdf:
 return Icons.picture_as_pdf;
 case ExportFormat.excel:
 return Icons.table_chart;
 case ExportFormat.csv:
 return Icons.description;
 case ExportFormat.json:
 return Icons.code;
}
 }

 String _getFormatDescription(ExportFormat format) {
 switch (format) {
 case ExportFormat.pdf:
 return 'Format PDF idéal pour l\'impression et le partage';
 case ExportFormat.excel:
 return 'Format Excel avec mise en forme et formules';
 case ExportFormat.csv:
 return 'Format CSV pour l\'import dans d\'autres applications';
 case ExportFormat.json:
 return 'Format JSON pour les développeurs et l\'intégration';
}
 }

 void _selectStartDate() async {
 final date = await showDatePicker(
 context: context,
 initialDate: _filter.startDate ?? DateTime.now(),
 firstDate: DateTime(2020),
 lastDate: DateTime.now(),
 );
 if (date != null) {{
 setState(() {
 _filter = _filter.copyWith(startDate: date);
 });
}
 }

 void _selectEndDate() async {
 final date = await showDatePicker(
 context: context,
 initialDate: _filter.endDate ?? DateTime.now(),
 firstDate: DateTime(2020),
 lastDate: DateTime.now(),
 );
 if (date != null) {{
 setState(() {
 _filter = _filter.copyWith(endDate: date);
 });
}
 }

 void _showAdvancedFilters() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Filtres avancés'),
 content: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 TextField(
 controller: _searchController,
 decoration: const InputDecoration(
 labelText: 'Recherche textuelle',
 hintText: 'Rechercher dans tous les champs...',
 prefixIcon: Icon(Icons.search),
 ),
 ),
 const SizedBox(height: 16),
 // Ajouter d'autres filtres avancés ici
 ],
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () {
 setState(() {
 _filter = _filter.copyWith(
 searchQuery: _searchController.text.isNotEmpty 
 ? _searchController.text 
 : null,
 );
 });
 Navigator.pop(context);
},
 child: const Text('Appliquer'),
 ),
 ],
 ),
 );
 }

 void _selectAllColumns() {
 setState(() {
 _selectedColumns = _selectedColumns.map((col) => col.copyWith(selected: true)).toList();
});
 }

 void _deselectAllColumns() {
 setState(() {
 _selectedColumns = _selectedColumns.map((col) => col.copyWith(selected: false)).toList();
});
 }

 void _resetOptions() {
 setState(() {
 _selectedFormat = ExportFormat.pdf;
 _selectedTemplate = ExportTemplate.standard;
 _loadDefaultColumns();
 _filter = const ExportFilter();
 _includeHeaders = true;
 _includeTotals = true;
 _includeCharts = false;
 _fileNameController.clear();
 _searchController.clear();
});
 }

 Future<void> _performExport() {async {
 if (_selectedColumns.where((col) ={> col.selected).isEmpty) {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Veuillez sélectionner au moins une colonne'),
 backgroundColor: Colors.red,
 ),
 );
 return;
}

 setState(() {
 _isLoading = true;
});

 try {
 final exportService = ExportService();
 final options = ExportOptions(
 format: _selectedFormat,
 template: _selectedTemplate,
 columns: _selectedColumns,
 filter: _filter,
 includeHeaders: _includeHeaders,
 includeTotals: _includeTotals,
 includeCharts: _includeCharts,
 customFileName: _fileNameController.text.isNotEmpty 
 ? _fileNameController.text 
 : null,
 );

 final history = await exportService.exportOrders(options);

 if (mounted) {{
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('Export réussi: ${history.fileName}'),
 backgroundColor: Colors.green,
 action: SnackBarAction(
 label: 'Partager',
 onPressed: () => exportService.shareFile(history.filePath!),
 ),
 ),
 );
 }
} catch (e) {
 if (mounted) {{
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('Erreur lors de l\'export: $e'),
 backgroundColor: Colors.red,
 ),
 );
 }
} finally {
 if (mounted) {{
 setState(() {
 _isLoading = false;
 });
 }
}
 }

 void _showExportHistory() {
 Navigator.pushNamed(context, '/export_history');
 }
}

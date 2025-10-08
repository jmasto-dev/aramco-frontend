import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/export_options.dart';
import '../../core/models/order_status.dart';

class ExportPreview extends StatelessWidget {
 final ExportFormat format;
 final ExportTemplate template;
 final List<ExportColumn> columns;
 final ExportFilter filter;
 final bool includeHeaders;
 final bool includeTotals;
 final bool includeCharts;

 const ExportPreview({
 super.key,
 required this.format,
 required this.template,
 required this.columns,
 required this.filter,
 required this.includeHeaders,
 required this.includeTotals,
 required this.includeCharts,
 });

 @override
 Widget build(BuildContext context) {
 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildSummaryCard(),
 const SizedBox(height: 16),
 _buildFilterSummary(),
 const SizedBox(height: 16),
 _buildColumnsPreview(),
 const SizedBox(height: 16),
 _buildDataPreview(),
 if (includeTotals) .{..[
 const SizedBox(height: 16),
 _buildTotalsPreview(),
 ],
 ],
 ),
 );
 }

 Widget _buildSummaryCard() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Résumé de l\'export',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 16),
 Row(
 children: [
 Expanded(
 child: _buildSummaryItem(
 'Format',
 format.displayName,
 _getFormatIcon(format),
 ),
 ),
 Expanded(
 child: _buildSummaryItem(
 'Modèle',
 template.displayName,
 Icons.description,
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 Row(
 children: [
 Expanded(
 child: _buildSummaryItem(
 'Colonnes',
 '${columns.length}',
 Icons.view_column,
 ),
 ),
 Expanded(
 child: _buildSummaryItem(
 'Extension',
 '.${format.extension}',
 Icons.insert_drive_file,
 ),
 ),
 ],
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildSummaryItem(String label, String value, IconData icon) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 border: Border.all(color: Colors.grey.shade300),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Column(
 children: [
 Icon(icon, size: 24, color: Colors.blue),
 const SizedBox(height: 4),
 Text(
 label,
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey,
 ),
 ),
 const SizedBox(height: 2),
 Text(
 value,
 style: const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.bold,
 ),
 textAlign: TextAlign.center,
 ),
 ],
 ),
 );
 }

 Widget _buildFilterSummary() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Filtres appliqués',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 16),
 _buildFilterItem('Période', _getDateRangeText()),
 _buildFilterItem('Statuts', _getStatusesText()),
 _buildFilterItem('Montant', _getAmountRangeText()),
 if (filter.searchQuery != null)
 _{buildFilterItem('Recherche', filter.searchQuery!),
 ],
 ),
 ),
 );
 }

 Widget _buildFilterItem(String label, String value) {
 return Padding(
 padding: const EdgeInsets.only(bottom: 8.0),
 child: Row(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const SizedBox(
 width: 80,
 child: Text(
 '$label:',
 style: const TextStyle(
 fontWeight: FontWeight.bold,
 color: Colors.grey,
 ),
 ),
 ),
 Expanded(
 child: Text(
 value.isNotEmpty ? value : 'Non défini',
 style: const TextStyle(
 color: value.isNotEmpty ? null : Colors.grey,
 ),
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildColumnsPreview() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Colonnes sélectionnées',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 16),
 if (columns.isEmpty)
 c{onst Text('Aucune colonne sélectionnée')
 else
 Wrap(
 spacing: 8.0,
 runSpacing: 4.0,
 children: columns.map((column) => Chip(
 label: Text(
 column.label,
 style: const TextStyle(fontSize: 12),
 ),
 backgroundColor: Colors.blue.shade50,
 side: BorderSide(color: Colors.blue.shade200),
 )).toList(),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildDataPreview() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Aperçu des données',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 16),
 Container(
 decoration: BoxDecoration(
 border: Border.all(color: Colors.grey.shade300),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: _buildPreviewTable(),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildPreviewTable() {
 return Column(
 children: [
 // En-têtes
 if (includeHeaders)
 C{ontainer(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.grey.shade100,
 border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
 ),
 child: Row(
 children: columns.map((column) => Expanded(
 flex: (column.width / 50).round(),
 child: Text(
 column.label,
 style: const TextStyle(
 fontWeight: FontWeight.bold,
 fontSize: 12,
 ),
 textAlign: TextAlign.center,
 ),
 )).toList(),
 ),
 ),
 // Données exemples
 ...List.generate(3, (index) => _buildPreviewRow(index)),
 ],
 );
 }

 Widget _buildPreviewRow(int index) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
 ),
 child: Row(
 children: columns.map((column) => Expanded(
 flex: (column.width / 50).round(),
 child: Text(
 _getPreviewValue(column, index),
 style: const TextStyle(fontSize: 12),
 textAlign: TextAlign.center,
 ),
 )).toList(),
 ),
 );
 }

 Widget _buildTotalsPreview() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Aperçu des totaux',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 16),
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.green.shade50,
 border: Border.all(color: Colors.green.shade200),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Row(
 mainAxisAlignment: MainAxisAlignment.spaceAround,
 children: [
 _buildTotalItem('Total commandes', '0'),
 _buildTotalItem('Montant total', '0.00 €'),
 _buildTotalItem('Articles totaux', '0'),
 ],
 ),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildTotalItem(String label, String value) {
 return Column(
 children: [
 Text(
 label,
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey,
 ),
 ),
 const SizedBox(height: 4),
 Text(
 value,
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.bold,
 color: Colors.green,
 ),
 ),
 ],
 );
 }

 String _getDateRangeText() {
 if (filter.startDate != null && filter.endDate != null) {{
 return 'Du ${DateFormat('dd/MM/yyyy').format(filter.startDate!)} '
 'au ${DateFormat('dd/MM/yyyy').format(filter.endDate!)}';
} else if (filter.startDate != null) {{
 return 'À partir du ${DateFormat('dd/MM/yyyy').format(filter.startDate!)}';
} else if (filter.endDate != null) {{
 return 'Jusqu\'au ${DateFormat('dd/MM/yyyy').format(filter.endDate!)}';
}
 return 'Toutes les dates';
 }

 String _getStatusesText() {
 if (filter.statuses == null || filter.statuses!.isEmpty) {{
 return 'Tous les statuts';
}
 return filter.statuses!.map((status) {
 final orderStatus = OrderStatus.values.firstWhere(
 (s) => s.name == status,
 orElse: () => OrderStatus.pending,
 );
 return orderStatus.displayName;
}).join(', ');
 }

 String _getAmountRangeText() {
 if (filter.minAmount != null && filter.maxAmount != null) {{
 return '${filter.minAmount!.toStringAsFixed(2)} € - ${filter.maxAmount!.toStringAsFixed(2)} €';
} else if (filter.minAmount != null) {{
 return 'Minimum ${filter.minAmount!.toStringAsFixed(2)} €';
} else if (filter.maxAmount != null) {{
 return 'Maximum ${filter.maxAmount!.toStringAsFixed(2)} €';
}
 return 'Tous les montants';
 }

 String _getPreviewValue(ExportColumn column, int index) {
 switch (column.key) {
 case 'id':
 return '#${1000 + index}';
 case 'customerName':
 return 'Client ${index + 1}';
 case 'customerEmail':
 return 'client${index + 1}@example.com';
 case 'customerPhone':
 return '+33 6 12 34 56 7${index}';
 case 'status':
 return OrderStatus.values[index % OrderStatus.values.length].displayName;
 case 'totalAmount':
 return '${((index + 1) * 150.50).toStringAsFixed(2)} €';
 case 'taxAmount':
 return '${((index + 1) * 30.10).toStringAsFixed(2)} €';
 case 'shippingAmount':
 return '${(10.0 + index).toStringAsFixed(2)} €';
 case 'itemCount':
 return '${(index + 1) * 2}';
 case 'shippingAddress':
 return '${index + 1} Rue Example, 75000 Paris';
 case 'createdAt':
 return DateFormat('dd/MM/yyyy HH:mm').format(
 DateTime.now().subtract(Duration(days: index)),
 );
 case 'updatedAt':
 return DateFormat('dd/MM/yyyy HH:mm').format(
 DateTime.now().subtract(Duration(hours: index)),
 );
 default:
 return '...';
}
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
}

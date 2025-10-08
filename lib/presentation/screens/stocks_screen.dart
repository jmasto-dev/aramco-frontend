import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../widgets/stock_card.dart';
import '../widgets/stock_filter.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/custom_button.dart';
import '../../core/models/stock_item.dart';
import '../../core/models/warehouse.dart';

class StocksScreen extends StatefulWidget {
 const StocksScreen({Key? key}) : super(key: key);

 @override
 State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
 final ScrollController _scrollController = ScrollController();
 bool _isInitialized = false;

 @override
 void initState() {
 super.initState();
 _scrollController.addListener(_onScroll);
 WidgetsBinding.instance.addPostFrameCallback((_) {
 _initializeData();
});
 }

 @override
 void dispose() {
 _scrollController.dispose();
 super.dispose();
 }

 void _initializeData() {
 if (!_isInitialized) {{
 final stockProvider = Provider.of<StockProvider>(context, listen: false);
 stockProvider.loadWarehouses();
 stockProvider.loadStockItems(refresh: true);
 stockProvider.loadStatistics();
 _isInitialized = true;
}
 }

 void _onScroll() {
 if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {{
 final stockProvider = Provider.of<StockProvider>(context, listen: false);
 if (!stockProvider.isLoadingStockItems && stockProvider.hasNextPage) {{
 stockProvider.loadStockItems();
 }
}
 }

 void _refreshData() {
 final stockProvider = Provider.of<StockProvider>(context, listen: false);
 stockProvider.refreshStockItems();
 stockProvider.loadStatistics();
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Gestion des Stocks'),
 backgroundColor: Theme.of(context).colorScheme.primary,
 foregroundColor: Colors.white,
 actions: [
 IconButton(
 icon: const Icon(Icons.refresh),
 onPressed: _refreshData,
 tooltip: 'Actualiser',
 ),
 IconButton(
 icon: const Icon(Icons.notifications),
 onPressed: () => _showAlerts(context),
 tooltip: 'Alertes',
 ),
 PopupMenuButton<String>(
 onSelected: (value) => _handleMenuAction(context, value),
 itemBuilder: (context) => [
 const PopupMenuItem(
 value: 'add_stock',
 child: ListTile(
 leading: Icon(Icons.add),
 title: Text('Ajouter un article'),
 contentPadding: const EdgeInsets.zero,
 ),
 ),
 const PopupMenuItem(
 value: 'transfer',
 child: ListTile(
 leading: Icon(Icons.swap_horiz),
 title: Text('Transfert de stock'),
 contentPadding: const EdgeInsets.zero,
 ),
 ),
 const PopupMenuItem(
 value: 'movement',
 child: ListTile(
 leading: Icon(Icons.history),
 title: Text('Mouvements'),
 contentPadding: const EdgeInsets.zero,
 ),
 ),
 const PopupMenuItem(
 value: 'reports',
 child: ListTile(
 leading: Icon(Icons.assessment),
 title: Text('Rapports'),
 contentPadding: const EdgeInsets.zero,
 ),
 ),
 ],
 ),
 ],
 ),
 body: Consumer<StockProvider>(
 builder: (context, stockProvider, child) {
 return LoadingOverlay(
 isLoading: stockProvider.isLoadingStockItems && stockProvider.stockItems.isEmpty,
 child: Column(
 children: [
 _buildStatisticsCards(stockProvider),
 _buildFilters(stockProvider),
 _buildStockList(stockProvider),
 ],
 ),
 );
 },
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: () => _showAddStockDialog(context),
 backgroundColor: Theme.of(context).colorScheme.primary,
 child: const Icon(Icons.add, color: Colors.white),
 tooltip: 'Ajouter un article',
 ),
 );
 }

 Widget _buildStatisticsCards(StockProvider stockProvider) {
 return Container(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text(
 'Statistiques',
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 12),
 Row(
 children: [
 Expanded(
 child: _buildStatCard(
 'Total Articles',
 '${stockProvider.getTotalStockQuantity()}',
 Icons.inventory,
 Colors.blue,
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: _buildStatCard(
 'Valeur Totale',
 '${stockProvider.getTotalStockValue()} €',
 Icons.euro,
 Colors.green,
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: _buildStatCard(
 'Alertes',
 '${stockProvider.getUnacknowledgedAlerts().length}',
 Icons.warning,
 Colors.orange,
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildStatCard(String title, String value, IconData icon, Color color) {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(icon, color: color, size: 20),
 const SizedBox(width: 8),
 Expanded(
 child: Text(
 title,
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey,
 ),
 ),
 ),
 ],
 ),
 const SizedBox(height: 8),
 Text(
 value,
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 color: color,
 ),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildFilters(StockProvider stockProvider) {
 return Container(
 padding: const EdgeInsets.symmetric(1),
 child: StockFilter(
 warehouses: stockProvider.warehouses,
 selectedWarehouseId: stockProvider.selectedWarehouseId,
 selectedStatus: stockProvider.selectedStatus,
 onWarehouseChanged: stockProvider.setWarehouseFilter,
 onStatusChanged: stockProvider.setStatusFilter,
 onClearFilters: stockProvider.clearFilters,
 ),
 );
 }

 Widget _buildStockList(StockProvider stockProvider) {
 if (stockProvider.stockItemsError != null) {{
 return Expanded(
 child: Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const Icon(
 Icons.error_outline,
 size: 64,
 color: Colors.red,
 ),
 const SizedBox(height: 16),
 Text(
 'Erreur: ${stockProvider.stockItemsError}',
 textAlign: TextAlign.center,
 style: const TextStyle(color: Colors.red),
 ),
 const SizedBox(height: 16),
 CustomButton(
 text: 'Réessayer',
 onPressed: _refreshData,
 ),
 ],
 ),
 ),
 );
}

 if (stockProvider.stockItems.isEmpty && !stockProvider.isLoadingStockItems) {{
 return const Expanded(
 child: Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.inventory_2_outlined,
 size: 64,
 color: Colors.grey,
 ),
 const SizedBox(height: 16),
 Text(
 'Aucun article en stock',
 style: const TextStyle(
 fontSize: 18,
 color: Colors.grey,
 ),
 ),
 const SizedBox(height: 8),
 Text(
 'Ajoutez votre premier article en stock',
 style: const TextStyle(color: Colors.grey),
 ),
 ],
 ),
 ),
 );
}

 return Expanded(
 child: RefreshIndicator(
 onRefresh: () async => _refreshData(),
 child: ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 itemCount: stockProvider.stockItems.length + (stockProvider.isLoadingStockItems ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == stockProvider.stockItems.length) {{
 return const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
}

 final stockItem = stockProvider.stockItems[index];
 return StockCard(
 stockItem: stockItem,
 onTap: () => _showStockDetails(context, stockItem),
 onEdit: () => _showEditStockDialog(context, stockItem),
 onDelete: () => _confirmDeleteStock(context, stockItem),
 );
},
 ),
 ),
 );
 }

 void _handleMenuAction(BuildContext context, String action) {
 switch (action) {
 case 'add_stock':
 _showAddStockDialog(context);
 break;
 case 'transfer':
 _showTransferDialog(context);
 break;
 case 'movement':
 _showMovements(context);
 break;
 case 'reports':
 _showReports(context);
 break;
}
 }

 void _showStockDetails(BuildContext context, StockItem stockItem) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: Text(stockItem.product?.name ?? 'Article'),
 content: SingleChildScrollView(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 mainAxisSize: MainAxisSize.min,
 children: [
 _buildDetailRow('Quantité', '${stockItem.quantity}'),
 _buildDetailRow('Quantité Min', '${stockItem.minQuantity}'),
 _buildDetailRow('Quantité Max', '${stockItem.maxQuantity}'),
 _buildDetailRow('Coût Unitaire', '${stockItem.unitCost} €'),
 _buildDetailRow('Valeur Totale', '${stockItem.totalValue} €'),
 _buildDetailRow('Emplacement', stockItem.location),
 _buildDetailRow('Statut', stockItem.stockStatusText),
 if (stockItem.batchNumber != null)
 _{buildDetailRow('Numéro de Lot', stockItem.batchNumber!),
 if (stockItem.expiryDate != null)
 _{buildDetailRow('Date d\'Expiration', 
 '${stockItem.expiryDate!.day}/${stockItem.expiryDate!.month}/${stockItem.expiryDate!.year}'),
 _buildDetailRow('Dernière Mise à Jour', 
 '${stockItem.lastUpdated.day}/${stockItem.lastUpdated.month}/${stockItem.lastUpdated.year}'),
 ],
 ),
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Fermer'),
 ),
 TextButton(
 onPressed: () {
 Navigator.pop(context);
 _showEditStockDialog(context, stockItem);
},
 child: const Text('Modifier'),
 ),
 ],
 ),
 );
 }

 Widget _buildDetailRow(String label, String value) {
 return Padding(
 padding: const EdgeInsets.symmetric(1),
 child: Row(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const SizedBox(
 width: 120,
 child: Text(
 '$label:',
 style: const TextStyle(fontWeight: FontWeight.bold),
 ),
 ),
 Expanded(child: Text(value)),
 ],
 ),
 );
 }

 void _showAddStockDialog(BuildContext context) {
 // Implementation pour ajouter un article
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité d\'ajout en cours de développement')),
 );
 }

 void _showEditStockDialog(BuildContext context, StockItem stockItem) {
 // Implementation pour modifier un article
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité de modification en cours de développement')),
 );
 }

 void _confirmDeleteStock(BuildContext context, StockItem stockItem) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Confirmer la suppression'),
 content: Text('Êtes-vous sûr de vouloir supprimer l\'article ${stockItem.product?.name ?? ''} ?'),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () {
 Navigator.pop(context);
 // Implementation pour supprimer
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité de suppression en cours de développement')),
 );
},
 child: const Text('Supprimer', style: const TextStyle(color: Colors.red)),
 ),
 ],
 ),
 );
 }

 void _showAlerts(BuildContext context) {
 // Implementation pour afficher les alertes
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité d\'alertes en cours de développement')),
 );
 }

 void _showTransferDialog(BuildContext context) {
 // Implementation pour les transferts
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité de transfert en cours de développement')),
 );
 }

 void _showMovements(BuildContext context) {
 // Implementation pour les mouvements
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité des mouvements en cours de développement')),
 );
 }

 void _showReports(BuildContext context) {
 // Implementation pour les rapports
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité des rapports en cours de développement')),
 );
 }
}

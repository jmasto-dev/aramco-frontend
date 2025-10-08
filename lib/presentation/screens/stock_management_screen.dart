import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/stock_item.dart';
import '../../core/models/warehouse.dart';
import '../../core/models/stock_item.dart';
import '../providers/stock_provider.dart';
import '../widgets/stock_item_card.dart';
import '../widgets/stock_filter_widget.dart';
import '../widgets/stock_statistics_widget.dart';
import '../widgets/loading_overlay.dart';

class StockManagementScreen extends StatefulWidget {
 const StockManagementScreen({Key? key}) : super(key: key);

 @override
 State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen>
 with SingleTickerProviderStateMixin {
 late TabController _tabController;
 final ScrollController _scrollController = ScrollController();
 final TextEditingController _searchController = TextEditingController();

 @override
 void initState() {
 super.initState();
 _tabController = TabController(length: 4, vsync: this);
 _scrollController.addListener(_onScroll);
 
 // Load initial data
 WidgetsBinding.instance.addPostFrameCallback((_) {
 context.read<StockProvider>().loadStockItems(refresh: true);
 context.read<StockProvider>().loadWarehouses();
 context.read<StockProvider>().loadStatistics();
});
 }

 @override
 void dispose() {
 _tabController.dispose();
 _scrollController.dispose();
 _searchController.dispose();
 super.dispose();
 }

 void _onScroll() {
 if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {{
 final provider = context.read<StockProvider>();
 if (provider.hasNextPage && !provider.isLoadingStockItems) {{
 provider.loadStockItems();
 }
}
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Gestion des Stocks'),
 backgroundColor: Theme.of(context).colorScheme.inversePrimary,
 bottom: TabBar(
 controller: _tabController,
 tabs: const [
 Tab(icon: Icon(Icons.inventory), text: 'Articles'),
 Tab(icon: Icon(Icons.warehouse), text: 'Entrepôts'),
 Tab(icon: Icon(Icons.notifications), text: 'Alertes'),
 Tab(icon: Icon(Icons.analytics), text: 'Statistiques'),
 ],
 ),
 actions: [
 IconButton(
 icon: const Icon(Icons.search),
 onPressed: _showSearchDialog,
 ),
 IconButton(
 icon: const Icon(Icons.filter_list),
 onPressed: _showFilterDialog,
 ),
 PopupMenuButton<String>(
 onSelected: _handleMenuAction,
 itemBuilder: (context) => [
 const PopupMenuItem(
 value: 'refresh',
 child: ListTile(
 leading: Icon(Icons.refresh),
 title: Text('Actualiser'),
 ),
 ),
 const PopupMenuItem(
 value: 'export',
 child: ListTile(
 leading: Icon(Icons.download),
 title: Text('Exporter'),
 ),
 ),
 const PopupMenuItem(
 value: 'transfer',
 child: ListTile(
 leading: Icon(Icons.swap_horiz),
 title: Text('Transfert de stock'),
 ),
 ),
 ],
 ),
 ],
 ),
 body: TabBarView(
 controller: _tabController,
 children: [
 _buildStockItemsTab(),
 _buildWarehousesTab(),
 _buildAlertsTab(),
 _buildStatisticsTab(),
 ],
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: _showAddStockItemDialog,
 child: const Icon(Icons.add),
 ),
 );
 }

 Widget _buildStockItemsTab() {
 return Consumer<StockProvider>(
 builder: (context, provider, child) {
 if (provider.isLoadingStockItems && provider.stockItems.isEmpty) {{
 return const Center(child: CircularProgressIndicator());
 }

 if (provider.stockItemsError != null) {{
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
 'Erreur de chargement',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 8),
 Text(
 provider.stockItemsError!,
 style: Theme.of(context).textTheme.bodyMedium,
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 16),
 ElevatedButton(
 onPressed: () => provider.refreshStockItems(),
 child: const Text('Réessayer'),
 ),
 ],
 ),
 );
 }

 if (provider.stockItems.isEmpty) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.inventory_2_outlined,
 size: 64,
 color: Theme.of(context).colorScheme.primary,
 ),
 const SizedBox(height: 16),
 Text(
 'Aucun article en stock',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 8),
 Text(
 'Ajoutez votre premier article en stock',
 style: Theme.of(context).textTheme.bodyMedium,
 ),
 const SizedBox(height: 16),
 ElevatedButton(
 onPressed: _showAddStockItemDialog,
 child: const Text('Ajouter un article'),
 ),
 ],
 ),
 );
 }

 return RefreshIndicator(
 onRefresh: () async => await provider.refreshStockItems(),
 child: Column(
 children: [
 // Summary cards
 Container(
 padding: const EdgeInsets.all(1),
 child: Row(
 children: [
 Expanded(
 child: _buildSummaryCard(
 'Total Articles',
 '${provider.stockItems.length}',
 Icons.inventory,
 Colors.blue,
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: _buildSummaryCard(
 'Valeur Totale',
 '${provider.getTotalStockValue()} €',
 Icons.euro,
 Colors.green,
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: _buildSummaryCard(
 'Stock Critique',
 '${provider.getCriticalStockItems().length}',
 Icons.warning,
 Colors.orange,
 ),
 ),
 ],
 ),
 ),
 // Stock items list
 Expanded(
 child: ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 itemCount: provider.stockItems.length + (provider.hasNextPage ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == provider.stockItems.length) {{
 return const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
 }

 final stockItem = provider.stockItems[index];
 return StockItemCard(
 stockItem: stockItem,
 onTap: () => _showStockItemDetails(stockItem),
 onEdit: () => _showEditStockItemDialog(stockItem),
 onDelete: () => _confirmDeleteStockItem(stockItem),
 );
 },
 ),
 ),
 ],
 ),
 );
 },
 );
 }

 Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 Icon(icon, color: color, size: 24),
 const SizedBox(height: 4),
 Text(
 title,
 style: Theme.of(context).textTheme.bodySmall,
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 2),
 Text(
 value,
 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
 fontWeight: FontWeight.bold,
 color: color,
 ),
 textAlign: TextAlign.center,
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildWarehousesTab() {
 return Consumer<StockProvider>(
 builder: (context, provider, child) {
 if (provider.isLoadingWarehouses) {{
 return const Center(child: CircularProgressIndicator());
 }

 if (provider.warehousesError != null) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const Icon(Icons.error_outline, size: 64),
 const SizedBox(height: 16),
 Text('Erreur: ${provider.warehousesError}'),
 const SizedBox(height: 16),
 ElevatedButton(
 onPressed: () => provider.loadWarehouses(),
 child: const Text('Réessayer'),
 ),
 ],
 ),
 );
 }

 if (provider.warehouses.isEmpty) {{
 return const Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(Icons.warehouse_outlined, size: 64),
 const SizedBox(height: 16),
 Text('Aucun entrepôt configuré'),
 const SizedBox(height: 16),
 Text('Ajoutez des entrepôts pour gérer votre stock'),
 ],
 ),
 );
 }

 return ListView.builder(
 padding: const EdgeInsets.all(1),
 itemCount: provider.warehouses.length,
 itemBuilder: (context, index) {
 final warehouse = provider.warehouses[index];
 return Card(
 margin: const EdgeInsets.symmetric(1),
 child: ListTile(
 leading: CircleAvatar(
 backgroundColor: Theme.of(context).colorScheme.primary,
 child: Icon(Icons.warehouse, color: Colors.white),
 ),
 title: Text(warehouse.name),
 subtitle: Text('${warehouse.address}, ${warehouse.city}'),
 trailing: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 crossAxisAlignment: CrossAxisAlignment.end,
 children: [
 Text(
 '${(warehouse.utilizationRate * 100).toStringAsFixed(1)}%',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 fontWeight: FontWeight.bold,

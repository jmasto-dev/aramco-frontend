import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/custom_button.dart';
import '../../core/models/order.dart';
import '../../core/models/order_status.dart';
import '../../core/utils/constants.dart';

class OrdersScreen extends ConsumerStatefulWidget {
 const OrdersScreen({super.key});

 @override
 ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
 with SingleTickerProviderStateMixin {
 late TabController _tabController;
 final ScrollController _scrollController = ScrollController();
 final TextEditingController _searchController = TextEditingController();
 String _selectedView = 'list'; // 'list', 'grid', 'compact'

 @override
 void initState() {
 super.initState();
 _tabController = TabController(length: 6, vsync: this);
 _tabController.addListener(_onTabChanged);
 _scrollController.addListener(_onScroll);
 
 // Charger les commandes au démarrage
 WidgetsBinding.instance.addPostFrameCallback((_) {
 ref.read(orderProvider.notifier).loadOrders();
});
 }

 @override
 void dispose() {
 _tabController.dispose();
 _scrollController.dispose();
 _searchController.dispose();
 super.dispose();
 }

 void _onTabChanged() {
 if (!_tabController.indexIsChanging) r{eturn;
 
 final status = _getStatusForTab(_tabController.index);
 ref.read(orderProvider.notifier).applyFilters(statusFilter: status);
 }

 void _onScroll() {
 if (_scrollController.position.pixels >= 
 _scrollController.position.maxScrollExtent - 200) {{
 ref.read(orderProvider.notifier).loadMoreOrders();
}
 }

 OrderStatus? _getStatusForTab(int index) {
 switch (index) {
 case 0: return null; // Toutes
 case 1: return OrderStatus.pending;
 case 2: return OrderStatus.confirmed;
 case 3: return OrderStatus.processing;
 case 4: return OrderStatus.shipped;
 case 5: return OrderStatus.delivered;
 default: return null;
}
 }

 String _getTabTitle(int index) {
 switch (index) {
 case 0: return 'Toutes';
 case 1: return 'En attente';
 case 2: return 'Confirmées';
 case 3: return 'En cours';
 case 4: return 'Expédiées';
 case 5: return 'Livrées';
 default: return '';
}
 }

 @override
 Widget build(BuildContext context) {
 final state = ref.watch(orderProvider);
 final theme = Theme.of(context);

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Commandes'),
 backgroundColor: theme.colorScheme.surface,
 elevation: 0,
 actions: [
 IconButton(
 icon: Icon(_selectedView == 'list' 
 ? Icons.view_list 
 : _selectedView == 'grid' 
 ? Icons.grid_view 
 : Icons.view_list),
 onPressed: _toggleView,
 tooltip: 'Changer la vue',
 ),
 PopupMenuButton<String>(
 onSelected: _handleMenuAction,
 itemBuilder: (context) => [
 const PopupMenuItem(
 value: 'refresh',
 child: Row(
 children: [
 Icon(Icons.refresh),
 const SizedBox(width: 8),
 Text('Actualiser'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'export',
 child: Row(
 children: [
 Icon(Icons.download),
 const SizedBox(width: 8),
 Text('Exporter'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'filters',
 child: Row(
 children: [
 Icon(Icons.filter_list),
 const SizedBox(width: 8),
 Text('Filtres avancés'),
 ],
 ),
 ),
 ],
 ),
 ],
 bottom: PreferredSize(
 preferredSize: const Size.fromHeight(120),
 child: Column(
 children: [
 _buildSearchBar(),
 _buildTabBar(),
 ],
 ),
 ),
 ),
 body: LoadingOverlay(
 isLoading: state.isLoading && state.orders.isEmpty,
 child: Column(
 children: [
 _buildStatisticsHeader(),
 _buildFilterChips(),
 Expanded(
 child: TabBarView(
 controller: _tabController,
 children: List.generate(6, (index) => _buildOrdersList()),
 ),
 ),
 ],
 ),
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: _navigateToCreateOrder,
 child: const Icon(Icons.add),
 tooltip: 'Nouvelle commande',
 ),
 );
 }

 Widget _buildSearchBar() {
 return Padding(
 padding: const EdgeInsets.all(1),
 child: TextField(
 controller: _searchController,
 decoration: InputDecoration(
 hintText: 'Rechercher une commande...',
 prefixIcon: const Icon(Icons.search),
 suffixIcon: _searchController.text.isNotEmpty
 ? IconButton(
 icon: const Icon(Icons.clear),
 onPressed: () {
 _searchController.clear();
 ref.read(orderProvider.notifier).applyFilters(searchQuery: '');
 },
 )
 : null,
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 filled: true,
 fillColor: Theme.of(context).colorScheme.surface,
 ),
 onChanged: (value) {
 ref.read(orderProvider.notifier).applyFilters(searchQuery: value);
 },
 ),
 );
 }

 Widget _buildTabBar() {
 return TabBar(
 controller: _tabController,
 isScrollable: true,
 tabAlignment: TabAlignment.center,
 labelStyle: const TextStyle(fontWeight: FontWeight.w600),
 unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
 indicatorSize: TabBarIndicatorSize.tab,
 tabs: List.generate(6, (index) {
 final status = _getStatusForTab(index);
 final count = status != null 
 ? ref.watch(ordersByStatusProvider)[status] ?? 0
 : ref.watch(ordersCountProvider);
 
 return Tab(
 child: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 Text(_getTabTitle(index)),
 if (count > 0) .{..[
 const SizedBox(width: 6),
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.primary,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 count.toString(),
 style: const TextStyle(
 color: Colors.white,
 fontSize: 12.0,
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 ],
 ],
 ),
 );
 }),
 );
 }

 Widget _buildStatisticsHeader() {
 final statistics = ref.watch(orderStatisticsProvider);
 
 return Container(
 margin: const EdgeInsets.all(1),
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.primaryContainer,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Aperçu des commandes',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 color: Theme.of(context).colorScheme.onPrimaryContainer,
 ),
 ),
 const SizedBox(height: 12.0),
 Row(
 children: [
 Expanded(
 child: _buildStatItem(
 'Total',
 statistics['totalOrders'].toString(),
 Icons.shopping_bag,
 ),
 ),
 Expanded(
 child: _buildStatItem(
 'Revenus',
 NumberFormat.currency(locale: 'fr_FR', symbol: '€')
 .format(statistics['totalRevenue']),
 Icons.euro,
 ),
 ),
 Expanded(
 child: _buildStatItem(
 'En attente',
 statistics['pendingOrders'].toString(),
 Icons.hourglass_empty,
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildStatItem(String label, String value, IconData icon) {
 return Column(
 children: [
 Icon(
 icon,
 color: Theme.of(context).colorScheme.primary,
 size: 24.0,
 ),
 const SizedBox(height: 4.0),
 Text(
 value,
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 fontWeight: FontWeight.bold,
 color: Theme.of(context).colorScheme.onPrimaryContainer,
 ),
 ),
 Text(
 label,
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
 ),
 ),
 ],
 );
 }

 Widget _buildFilterChips() {
 final state = ref.watch(orderProvider);
 
 if (!state.hasFilters) r{eturn const SizedBox.shrink();
 
 return Container(
 height: 60.0,
 padding: const EdgeInsets.symmetric(1),
 child: ListView(
 scrollDirection: Axis.horizontal,
 children: [
 if (state.statusFilter != null)
 P{adding(
 padding: const EdgeInsets.only(right: 8.0),
 child: Chip(
 label: Text(state.statusFilter!.displayName),
 avatar: const Icon(Icons.filter_list, size: 16),
 onDeleted: () {
 ref.read(orderProvider.notifier).clearFilters();
 },
 ),
 ),
 if (state.dateRange != null)
 P{adding(
 padding: const EdgeInsets.only(right: 8.0),
 child: Chip(
 label: Text(
 '${DateFormat('dd/MM').format(state.dateRange!.start)} - '
 '${DateFormat('dd/MM').format(state.dateRange!.end)}',
 ),
 avatar: const Icon(Icons.date_range, size: 16),
 onDeleted: () {
 ref.read(orderProvider.notifier).clearFilters();
 },
 ),
 ),
 if (state.searchQuery.isNotEmpty)
 P{adding(
 padding: const EdgeInsets.only(right: 8.0),
 child: Chip(
 label: Text('Recherche: ${state.searchQuery}'),
 avatar: const Icon(Icons.search, size: 16),
 onDeleted: () {
 _searchController.clear();
 ref.read(orderProvider.notifier).clearFilters();
 },
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildOrdersList() {
 final state = ref.watch(orderProvider);
 
 if (state.hasError) {{
 return _buildErrorWidget(state.error!);
}
 
 if (state.orders.isEmpty && !state.isLoading) {{
 return _buildEmptyWidget();
}
 
 return RefreshIndicator(
 onRefresh: () async {
 await ref.read(orderProvider.notifier).refreshOrders();
 },
 child: _buildOrdersContent(),
 );
 }

 Widget _buildOrdersContent() {
 final state = ref.watch(orderProvider);
 
 switch (_selectedView) {
 case 'grid':
 return _buildGridView();
 case 'compact':
 return _buildCompactView();
 case 'list':
 default:
 return _buildListView();
}
 }

 Widget _buildListView() {
 final state = ref.watch(orderProvider);
 
 return ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 itemCount: state.orders.length + (state.hasMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == state.orders.length) {{
 return const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
 }
 
 final order = state.orders[index];
 return OrderCard(
 order: order,
 onTap: () => _navigateToOrderDetails(order),
 onEdit: () => _navigateToEditOrder(order),
 onCancel: order.status.canBeCancelled 
 ? () => _cancelOrder(order) 
 : null,
 onDuplicate: () => _duplicateOrder(order),
 variant: CardVariant.standard,
 );
 },
 );
 }

 Widget _buildGridView() {
 final state = ref.watch(orderProvider);
 
 return GridView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
 crossAxisCount: 2,
 childAspectRatio: 0.8,
 crossAxisSpacing: 16.0,
 mainAxisSpacing: 16.0,
 ),
 itemCount: state.orders.length + (state.hasMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == state.orders.length) {{
 return const Center(
 child: CircularProgressIndicator(),
 );
 }
 
 final order = state.orders[index];
 return OrderCard(
 order: order,
 onTap: () => _navigateToOrderDetails(order),
 onEdit: () => _navigateToEditOrder(order),
 onCancel: order.status.canBeCancelled 
 ? () => _cancelOrder(order) 
 : null,
 onDuplicate: () => _duplicateOrder(order),
 variant: CardVariant.compact,
 );
 },
 );
 }

 Widget _buildCompactView() {
 final state = ref.watch(orderProvider);
 
 return ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 itemCount: state.orders.length + (state.hasMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == state.orders.length) {{
 return const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
 }
 
 final order = state.orders[index];
 return OrderCard(
 order: order,
 onTap: () => _navigateToOrderDetails(order),
 onEdit: () => _navigateToEditOrder(order),
 onCancel: order.status.canBeCancelled 
 ? () => _cancelOrder(order) 
 : null,
 onDuplicate: () => _duplicateOrder(order),
 variant: CardVariant.compact,
 );
 },
 );
 }

 Widget _buildErrorWidget(String error) {
 return Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.error_outline,
 size: 64.0,
 color: Theme.of(context).colorScheme.error,
 ),
 const SizedBox(height: 16.0),
 Text(
 'Erreur de chargement',
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 color: Theme.of(context).colorScheme.error,
 ),
 ),
 const SizedBox(height: 8.0),
 Text(
 error,
 style: Theme.of(context).textTheme.bodyMedium,
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 24.0),
 CustomButton(
 text: 'Réessayer',
 onPressed: () {
 ref.read(orderProvider.notifier).refreshOrders();
 },
 type: ButtonType.primary,
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildEmptyWidget() {
 return Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.shopping_bag_outlined,
 size: 64.0,
 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
 ),
 const SizedBox(height: 16.0),
 Text(
 'Aucune commande',
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
 ),
 ),
 const SizedBox(height: 8.0),
 Text(
 'Commencez par créer votre première commande',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
 ),
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 24.0),
 CustomButton(
 text: 'Créer une commande',
 onPressed: _navigateToCreateOrder,
 type: ButtonType.primary,
 ),
 ],
 ),
 ),
 );
 }

 void _toggleView() {
 setState(() {
 switch (_selectedView) {
 case 'list':
 _selectedView = 'grid';
 break;
 case 'grid':
 _selectedView = 'compact';
 break;
 case 'compact':
 _selectedView = 'list';
 break;
 }
});
 }

 void _handleMenuAction(String action) {
 switch (action) {
 case 'refresh':
 ref.read(orderProvider.notifier).refreshOrders();
 break;
 case 'export':
 _exportOrders();
 break;
 case 'filters':
 _showAdvancedFilters();
 break;
}
 }

 void _navigateToCreateOrder() {
 // TODO: Naviguer vers l'écran de création de commande
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité en développement')),
 );
 }

 void _navigateToOrderDetails(Order order) {
 // TODO: Naviguer vers les détails de la commande
 ref.read(orderProvider.notifier).selectOrder(order);
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Détails de la commande ${order.id}')),
 );
 }

 void _navigateToEditOrder(Order order) {
 // TODO: Naviguer vers l'édition de la commande
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Modification de la commande ${order.id}')),
 );
 }

 void _cancelOrder(Order order) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Annuler la commande'),
 content: Text(
 'Êtes-vous sûr de vouloir annuler la commande ${order.id} ?',
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(),
 child: const Text('Non'),
 ),
 TextButton(
 onPressed: () async {
 Navigator.of(context).pop();
 final success = await ref.read(orderProvider.notifier)
 .updateOrderStatus(order.id, OrderStatus.cancelled);
 
 if (success) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Commande annulée avec succès')),
 );
 }
},
 child: const Text('Oui'),
 ),
 ],
 ),
 );
 }

 void _duplicateOrder(Order order) {
 // TODO: Dupliquer la commande
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Duplication de la commande ${order.id}')),
 );
 }

 void _exportOrders() {
 // TODO: Exporter les commandes
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Export des commandes en développement')),
 );
 }

 void _showAdvancedFilters() {
 // TODO: Afficher les filtres avancés
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Filtres avancés en développement')),
 );
 }
}

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/order.dart';
import '../../core/models/order_status.dart';
import '../../core/models/user.dart';
import '../../core/services/order_service.dart';
import '../../core/services/api_service.dart';
import '../../presentation/widgets/custom_button.dart';
import '../../presentation/widgets/custom_text_field.dart';
import '../../presentation/widgets/loading_overlay.dart';
import '../../presentation/widgets/status_badge.dart';
import '../../core/utils/formatters.dart';

class OrderHistoryScreen extends StatefulWidget {
 final User? currentUser;

 const OrderHistoryScreen({
 Key? key,
 this.currentUser,
 }) : super(key: key);

 @override
 State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
 final OrderService _orderService = OrderService(ApiService());
 final _searchController = TextEditingController();
 final _scrollController = ScrollController();
 
 bool _isLoading = false;
 bool _isLoadingMore = false;
 bool _hasMore = true;
 
 List<Order> _orders = [];
 List<Order> _filteredOrders = [];
 String _searchQuery = '';
 String? _selectedStatus;
 String? _selectedPeriod;
 bool _sortByDate = true;
 bool _sortByAmount = false;
 
 int _currentPage = 1;
 final int _pageSize = 20;

 @override
 void initState() {
 super.initState();
 _loadOrders();
 _scrollController.addListener(_onScroll);
 }

 @override
 void dispose() {
 _searchController.dispose();
 _scrollController.dispose();
 super.dispose();
 }

 void _onScroll() {
 if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {{
 _loadMoreOrders();
}
 }

 Future<void> _loadOrders({bool refresh = false}) {async {
 if (refresh) {{
 setState(() {
 _isLoading = true;
 _currentPage = 1;
 _hasMore = true;
 _orders.clear();
 });
} else {
 setState(() {
 _isLoading = true;
 });
}

 try {
 final response = await _orderService.getOrders(
 page: _currentPage,
 limit: _pageSize,
 search: _searchQuery.isEmpty ? null : _searchQuery,
 status: _selectedStatus != null ? OrderStatus.values.firstWhere(
 (s) => s.name == _selectedStatus,
 orElse: () => OrderStatus.pending,
 ) : null,
 sortBy: 'createdAt',
 );

 if (response.isSuccess && response.data != null) {{
 setState(() {
 if (refresh) {{
 _orders = response.data!;
} else {
 _orders.addAll(response.data!);
}
 _filteredOrders = _filterOrders(_orders);
 _hasMore = response.data!.length == _pageSize;
 _currentPage++;
 });
 } else {
 _showErrorSnackBar(response.errorMessage ?? 'Erreur lors du chargement des commandes');
 }
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
} finally {
 setState(() {
 _isLoading = false;
 });
}
 }

 Future<void> _loadMoreOrders() {async {
 if (_isLoadingMore || !_hasMore) r{eturn;

 setState(() {
 _isLoadingMore = true;
});

 try {
 final response = await _orderService.getOrders(
 page: _currentPage,
 limit: _pageSize,
 search: _searchQuery.isEmpty ? null : _searchQuery,
 status: _selectedStatus != null ? OrderStatus.values.firstWhere(
 (s) => s.name == _selectedStatus,
 orElse: () => OrderStatus.pending,
 ) : null,
 sortBy: 'createdAt',
 );

 if (response.isSuccess && response.data != null) {{
 setState(() {
 _orders.addAll(response.data!);
 _filteredOrders = _filterOrders(_orders);
 _hasMore = response.data!.length == _pageSize;
 _currentPage++;
 });
 }
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
} finally {
 setState(() {
 _isLoadingMore = false;
 });
}
 }

 List<Order> _filterOrders(List<Order> orders) {
 var filtered = orders;

 // Filtrer par recherche
 if (_searchQuery.isNotEmpty) {{
 filtered = filtered.where((order) =>
 order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
 order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
 order.customerEmail.toLowerCase().contains(_searchQuery.toLowerCase())
 ).toList();
}

 // Filtrer par statut
 if (_selectedStatus != null) {{
 filtered = filtered.where((order) => order.status.name == _selectedStatus).toList();
}

 // Filtrer par période
 if (_selectedPeriod != null) {{
 final now = DateTime.now();
 DateTime startDate;

 switch (_selectedPeriod) {
 case 'today':
 startDate = DateTime(now.year, now.month, now.day);
 break;
 case 'week':
 startDate = now.subtract(const Duration(days: 7));
 break;
 case 'month':
 startDate = DateTime(now.year, now.month, 1);
 break;
 case 'quarter':
 startDate = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
 break;
 case 'year':
 startDate = DateTime(now.year, 1, 1);
 break;
 default:
 startDate = DateTime(2000);
 }

 filtered = filtered.where((order) => order.createdAt.isAfter(startDate)).toList();
}

 // Trier
 if (_sortByDate) {{
 filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
} else if (_sortByAmount) {{
 filtered.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
}

 return filtered;
 }

 void _onSearchChanged(String value) {
 setState(() {
 _searchQuery = value;
 _filteredOrders = _filterOrders(_orders);
});
 }

 void _onStatusChanged(String? status) {
 setState(() {
 _selectedStatus = status;
 _filteredOrders = _filterOrders(_orders);
});
 }

 void _onPeriodChanged(String? period) {
 setState(() {
 _selectedPeriod = period;
 _filteredOrders = _filterOrders(_orders);
});
 }

 void _onSortChanged(String sortType) {
 setState(() {
 _sortByDate = sortType == 'date';
 _sortByAmount = sortType == 'amount';
 _filteredOrders = _filterOrders(_orders);
});
 }

 void _navigateToOrderDetails(Order order) {
 Navigator.of(context).pushNamed('/order-details', arguments: order);
 }

 void _showErrorSnackBar(String message) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(message),
 backgroundColor: Colors.red,
 behavior: SnackBarBehavior.floating,
 ),
 );
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Historique des commandes'),
 actions: [
 IconButton(
 icon: const Icon(Icons.refresh),
 onPressed: () => _loadOrders(refresh: true),
 tooltip: 'Actualiser',
 ),
 ],
 ),
 body: Column(
 children: [
 // Filtres et recherche
 _buildFiltersSection(),
 
 // Statistiques
 _buildStatsSection(),
 
 // Liste des commandes
 Expanded(
 child: _buildOrdersList(),
 ),
 ],
 ),
 );
 }

 Widget _buildFiltersSection() {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.grey[50],
 border: Border(
 bottom: BorderSide(color: Colors.grey[300]!),
 ),
 ),
 child: Column(
 children: [
 // Barre de recherche
 CustomTextField(
 controller: _searchController,
 label: 'Rechercher une commande',
 hintText: 'N° commande, client, email...',
 onChanged: _onSearchChanged,
 prefixIcon: Icons.search,
 ),
 const SizedBox(height: 16),
 
 // Filtres
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<String?>(
 value: _selectedStatus,
 decoration: const InputDecoration(
 labelText: 'Statut',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem(value: null, child: Text('Tous')),
 const DropdownMenuItem(value: 'pending', child: Text('En attente')),
 const DropdownMenuItem(value: 'confirmed', child: Text('Confirmée')),
 const DropdownMenuItem(value: 'preparing', child: Text('En préparation')),
 const DropdownMenuItem(value: 'shipped', child: Text('Expédiée')),
 const DropdownMenuItem(value: 'delivered', child: Text('Livrée')),
 const DropdownMenuItem(value: 'cancelled', child: Text('Annulée')),
 ],
 onChanged: _onStatusChanged,
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: DropdownButtonFormField<String?>(
 value: _selectedPeriod,
 decoration: const InputDecoration(
 labelText: 'Période',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem(value: null, child: Text('Toutes')),
 const DropdownMenuItem(value: 'today', child: Text("Aujourd'hui")),
 const DropdownMenuItem(value: 'week', child: Text('Cette semaine')),
 const DropdownMenuItem(value: 'month', child: Text('Ce mois')),
 const DropdownMenuItem(value: 'quarter', child: Text('Ce trimestre')),
 const DropdownMenuItem(value: 'year', child: Text('Cette année')),
 ],
 onChanged: _onPeriodChanged,
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 
 // Tri
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<String>(
 value: _sortByDate ? 'date' : _sortByAmount ? 'amount' : 'date',
 decoration: const InputDecoration(
 labelText: 'Trier par',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: const [
 DropdownMenuItem(value: 'date', child: Text('Date')),
 DropdownMenuItem(value: 'amount', child: Text('Montant')),
 ],
 onChanged: (value) {
 if (value != null) {{
 _onSortChanged(value);
 }
 },
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildStatsSection() {
 if (_filteredOrders.isEmpty) r{eturn const SizedBox.shrink();

 final totalOrders = _filteredOrders.length;
 final totalAmount = _filteredOrders.fold<double>(0, (sum, order) => sum + order.totalAmount);
 final deliveredOrders = _filteredOrders.where((order) => order.status.name == 'delivered').length;
 final pendingOrders = _filteredOrders.where((order) => order.status.name == 'pending').length;

 return Container(
 padding: const EdgeInsets.all(1),
 margin: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.blue[50],
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(color: Colors.blue[200]!),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Statistiques',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.bold,
 color: Colors.blue[700],
 ),
 ),
 const SizedBox(height: 12),
 Row(
 children: [
 Expanded(
 child: _buildStatItem('Total commandes', '$totalOrders', Icons.shopping_cart),
 ),
 Expanded(
 child: _buildStatItem('Montant total', '${totalAmount.toStringAsFixed(2)} €', Icons.euro),
 ),
 ],
 ),
 const SizedBox(height: 8),
 Row(
 children: [
 Expanded(
 child: _buildStatItem('Livrées', '$deliveredOrders', Icons.check_circle, Colors.green),
 ),
 Expanded(
 child: _buildStatItem('En attente', '$pendingOrders', Icons.pending, Colors.orange),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
 return Column(
 children: [
 Icon(icon, color: color ?? Colors.blue, size: 24),
 const SizedBox(height: 4),
 Text(
 value,
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.bold,
 color: color ?? Colors.blue,
 ),
 ),
 Text(
 label,
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey[600],
 ),
 ),
 ],
 );
 }

 Widget _buildOrdersList() {
 if (_isLoading && _orders.isEmpty) {{
 return const Center(child: CircularProgressIndicator());
}

 if (_filteredOrders.isEmpty) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(Icons.history, size: 64, color: Colors.grey),
 const SizedBox(height: 16),
 Text(
 'Aucune commande trouvée',
 style: const TextStyle(fontSize: 16, color: Colors.grey),
 ),
 const SizedBox(height: 8),
 Text(
 'Essayez de modifier vos filtres de recherche',
 style: const TextStyle(fontSize: 14, color: Colors.grey),
 ),
 ],
 ),
 );
}

 return RefreshIndicator(
 onRefresh: () => _loadOrders(refresh: true),
 child: ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 itemCount: _filteredOrders.length + (_hasMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == _filteredOrders.length && _hasMore) {{
 return const Center(child: CircularProgressIndicator());
}
 
 final order = _filteredOrders[index];
 return _buildOrderCard(order);
 },
 ),
 );
 }

 Widget _buildOrderCard(Order order) {
 return Card(
 margin: const EdgeInsets.only(bottom: 12),
 child: InkWell(
 onTap: () => _navigateToOrderDetails(order),
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'CMD-${order.id.substring(0, 8).toUpperCase()}',
 style: const TextStyle(
 fontWeight: FontWeight.bold,
 fontSize: 16,
 ),
 ),
 const SizedBox(height: 4),
 Text(
 order.customerName,
 style: const TextStyle(
 fontSize: 14,
 color: Colors.grey[600],
 ),
 ),
 ],
 ),
 ),
 StatusBadge(status: order.status),
 ],
 ),
 
 const SizedBox(height: 12),
 
 // Détails
 Row(
 children: [
 Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 4),
 Text(
 Formatters.formatDateTime(order.createdAt),
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(width: 16),
 Icon(Icons.euro, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 4),
 Text(
 '${order.totalAmount.toStringAsFixed(2)} €',
 style: const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.bold,
 color: Colors.green,
 ),
 ),
 ],
 ),
 
 const SizedBox(height: 8),
 
 // Articles
 Row(
 children: [
 Icon(Icons.inventory_2, size: 16, color: Colors.grey[600]),
 const SizedBox(width: 4),
 Text(
 '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey[600],
 ),
 ),
 ],
 ),
 ],
 ),
 ),
 ),
 );
 }
}

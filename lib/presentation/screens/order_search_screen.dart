import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/order.dart';
import '../../core/models/order_status.dart';
import '../../core/models/product.dart';
import '../../core/models/user.dart';
import '../../core/services/order_service.dart';
import '../../core/services/product_service.dart';
import '../../core/services/api_service.dart';
import '../../presentation/widgets/custom_button.dart';
import '../../presentation/widgets/custom_text_field.dart';
import '../../presentation/widgets/status_badge.dart';
import '../../presentation/widgets/order_card.dart';
import '../../presentation/widgets/loading_overlay.dart';
import '../../presentation/widgets/date_range_picker.dart';
import 'order_status_update_screen.dart';

class OrderSearchScreen extends StatefulWidget {
 final User? currentUser;

 const OrderSearchScreen({
 Key? key,
 this.currentUser,
 }) : super(key: key);

 @override
 State<OrderSearchScreen> createState() => _OrderSearchScreenState();
}

class _OrderSearchScreenState extends State<OrderSearchScreen> {
 final _searchController = TextEditingController();
 final _minAmountController = TextEditingController();
 final _maxAmountController = TextEditingController();
 final _orderIdController = TextEditingController();
 final _customerEmailController = TextEditingController();
 final _customerPhoneController = TextEditingController();
 
 final OrderService _orderService = OrderService(ApiService());
 final ProductService _productService = ProductService(ApiService());
 
 bool _isLoading = false;
 bool _isLoadingProducts = false;
 bool _hasSearched = false;
 
 List<Order> _orders = [];
 List<Product> _products = [];
 
 // Filtres
 String _searchQuery = '';
 OrderStatus? _selectedStatus;
 String? _selectedProductId;
 String? _selectedPaymentMethod;
 String? _selectedDeliveryMethod;
 bool? _isPaid;
 bool? _isOverdue;
 List<String> _selectedCategories = [];
 DateTime? _dateFrom;
 DateTime? _dateTo;
 double? _minAmount;
 double? _maxAmount;
 String _sortBy = 'createdAt';
 bool _sortOrderDesc = true;
 
 // Options de tri
 final List<Map<String, String>> _sortOptions = [
 {'value': 'createdAt', 'label': 'Date de création'},
 {'value': 'updatedAt', 'label': 'Date de mise à jour'},
 {'value': 'totalAmount', 'label': 'Montant total'},
 {'value': 'customerName', 'label': 'Nom du client'},
 {'value': 'expectedDeliveryDate', 'label': 'Date de livraison'},
 ];
 
 // Options de paiement
 final List<String> _paymentMethods = [
 'Carte bancaire',
 'Espèces',
 'Virement bancaire',
 'PayPal',
 'Stripe',
 'Chèque',
 'Autre',
 ];
 
 // Options de livraison
 final List<String> _deliveryMethods = [
 'Livraison à domicile',
 'Point relais',
 'Retrait en magasin',
 'Livraison express',
 'Livraison internationale',
 ];

 @override
 void initState() {
 super.initState();
 _loadProducts();
 }

 @override
 void dispose() {
 _searchController.dispose();
 _minAmountController.dispose();
 _maxAmountController.dispose();
 _orderIdController.dispose();
 _customerEmailController.dispose();
 _customerPhoneController.dispose();
 super.dispose();
 }

 Future<void> _loadProducts() {async {
 setState(() {
 _isLoadingProducts = true;
});

 try {
 final response = await _productService.getProducts();
 if (response.isSuccess && response.data != null) {{
 setState(() {
 _products = response.data!;
 });
 }
} catch (e) {
 // Ignorer l'erreur pour le moment
; finally {
 setState(() {
 _isLoadingProducts = false;
 });
}
 }

 Future<void> _searchOrders() {async {
 setState(() {
 _isLoading = true;
 _hasSearched = true;
});

 try {
 final response = await _orderService.getOrders(
 search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
 status: _selectedStatus,
 productId: _selectedProductId,
 dateFrom: _dateFrom,
 dateTo: _dateTo,
 minAmount: _minAmount,
 maxAmount: _maxAmount,
 isPaid: _isPaid,
 isOverdue: _isOverdue,
 productCategories: _selectedCategories.isEmpty ? null : _selectedCategories,
 deliveryMethod: _selectedDeliveryMethod,
 paymentMethod: _selectedPaymentMethod,
 sortBy: _sortBy,
 sortOrderDesc: _sortOrderDesc,
 );

 if (response.isSuccess && response.data != null) {{
 setState(() {
 _orders = response.data!;
 });
 } else {
 _showErrorSnackBar(response.errorMessage ?? 'Erreur lors de la recherche');
 }
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
} finally {
 setState(() {
 _isLoading = false;
 });
}
 }

 void _resetFilters() {
 setState(() {
 _searchController.clear();
 _minAmountController.clear();
 _maxAmountController.clear();
 _orderIdController.clear();
 _customerEmailController.clear();
 _customerPhoneController.clear();
 
 _searchQuery = '';
 _selectedStatus = null;
 _selectedProductId = null;
 _selectedPaymentMethod = null;
 _selectedDeliveryMethod = null;
 _isPaid = null;
 _isOverdue = null;
 _selectedCategories = [];
 _dateFrom = null;
 _dateTo = null;
 _minAmount = null;
 _maxAmount = null;
 _sortBy = 'createdAt';
 _sortOrderDesc = true;
 _orders = [];
 _hasSearched = false;
});
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
 title: const Text('Recherche avancée'),
 actions: [
 IconButton(
 icon: const Icon(Icons.refresh),
 onPressed: _resetFilters,
 tooltip: 'Réinitialiser les filtres',
 ),
 ],
 ),
 body: Column(
 children: [
 // Filtres
 _buildFiltersSection(),
 
 // Résultats
 Expanded(
 child: _buildResultsSection(),
 ),
 ],
 ),
 );
 }

 Widget _buildFiltersSection() {
 return Container(
 height: 300,
 decoration: BoxDecoration(
 color: Colors.grey[50],
 border: Border(
 bottom: BorderSide(color: Colors.grey[300]!),
 ),
 ),
 child: SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Recherche rapide
 Row(
 children: [
 Expanded(
 child: CustomTextField(
 controller: _searchController,
 label: 'Recherche rapide',
 hintText: 'ID commande, nom client, email...',
 onChanged: (value) {
 _searchQuery = value;
 },
 ),
 ),
 const SizedBox(width: 16),
 CustomButton(
 text: 'Rechercher',
 onPressed: _searchOrders,
 isLoading: _isLoading,
 ),
 ],
 ),
 const SizedBox(height: 16),
 
 // Filtres avancés
 ExpansionTile(
 title: const Text('Filtres avancés'),
 children: [
 _buildAdvancedFilters(),
 ],
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildAdvancedFilters() {
 return Column(
 children: [
 const SizedBox(height: 16),
 
 // Première ligne de filtres
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<OrderStatus?>(
 value: _selectedStatus,
 decoration: const InputDecoration(
 labelText: 'Statut',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem(value: null, child: Text('Tous')),
 ...OrderStatus.values.map((status) {
 return DropdownMenuItem(
 value: status,
 child: Text(status.displayName),
 );
 }),
 ],
 onChanged: (value) {
 setState(() {
 _selectedStatus = value;
 });
 },
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: DropdownButtonFormField<String?>(
 value: _selectedProductId,
 decoration: const InputDecoration(
 labelText: 'Produit',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem(value: null, child: Text('Tous')),
 ..._products.map((product) {
 return DropdownMenuItem(
 value: product.id,
 child: Text(product.name),
 );
 }),
 ],
 onChanged: (value) {
 setState(() {
 _selectedProductId = value;
 });
 },
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 
 // Deuxième ligne de filtres
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<String?>(
 value: _selectedPaymentMethod,
 decoration: const InputDecoration(
 labelText: 'Méthode de paiement',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem(value: null, child: Text('Toutes')),
 ..._paymentMethods.map((method) {
 return DropdownMenuItem(
 value: method,
 child: Text(method),
 );
 }),
 ],
 onChanged: (value) {
 setState(() {
 _selectedPaymentMethod = value;
 });
 },
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: DropdownButtonFormField<String?>(
 value: _selectedDeliveryMethod,
 decoration: const InputDecoration(
 labelText: 'Méthode de livraison',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem(value: null, child: Text('Toutes')),
 ..._deliveryMethods.map((method) {
 return DropdownMenuItem(
 value: method,
 child: Text(method),
 );
 }),
 ],
 onChanged: (value) {
 setState(() {
 _selectedDeliveryMethod = value;
 });
 },
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 
 // Filtres de montant
 Row(
 children: [
 Expanded(
 child: CustomTextField(
 controller: _minAmountController,
 label: 'Montant minimum (€)',
 hintText: '0.00',
 keyboardType: const TextInputType.numberWithOptions(decimal: true),
 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
 onChanged: (value) {
 _minAmount = double.tryParse(value);
 },
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: CustomTextField(
 controller: _maxAmountController,
 label: 'Montant maximum (€)',
 hintText: '0.00',
 keyboardType: const TextInputType.numberWithOptions(decimal: true),
 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
 onChanged: (value) {
 _maxAmount = double.tryParse(value);
 },
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 
 // Filtres de dates
 Row(
 children: [
 Expanded(
 child: InkWell(
 onTap: _selectDateFrom,
 child: InputDecorator(
 decoration: const InputDecoration(
 labelText: 'Date de début',
 border: OutlineInputBorder(),
 suffixIcon: Icon(Icons.calendar_today),
 ),
 child: Text(
 _dateFrom != null
 ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}'
 : 'Sélectionner',
 ),
 ),
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: InkWell(
 onTap: _selectDateTo,
 child: InputDecorator(
 decoration: const InputDecoration(
 labelText: 'Date de fin',
 border: OutlineInputBorder(),
 suffixIcon: Icon(Icons.calendar_today),
 ),
 child: Text(
 _dateTo != null
 ? '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'
 : 'Sélectionner',
 ),
 ),
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 
 // Filtres booléens
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<bool?>(
 value: _isPaid,
 decoration: const InputDecoration(
 labelText: 'Statut paiement',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: const [
 DropdownMenuItem(value: null, child: Text('Tous')),
 DropdownMenuItem(value: true, child: Text('Payée')),
 DropdownMenuItem(value: false, child: Text('Non payée')),
 ],
 onChanged: (value) {
 setState(() {
 _isPaid = value;
 });
 },
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: DropdownButtonFormField<bool?>(
 value: _isOverdue,
 decoration: const InputDecoration(
 labelText: 'Retard',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: const [
 DropdownMenuItem(value: null, child: Text('Toutes')),
 DropdownMenuItem(value: true, child: Text('En retard')),
 DropdownMenuItem(value: false, child: Text('À jour')),
 ],
 onChanged: (value) {
 setState(() {
 _isOverdue = value;
 });
 },
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
 value: _sortBy,
 decoration: const InputDecoration(
 labelText: 'Trier par',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: _sortOptions.map((option) {
 return DropdownMenuItem(
 value: option['value'],
 child: Text(option['label']!),
 );
 }).toList(),
 onChanged: (value) {
 if (value != null) {{
 setState(() {
 _sortBy = value;
 });
 }
 },
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: Row(
 children: [
 const Text('Ordre:'),
 const SizedBox(width: 8),
 ToggleButtons(
 isSelected: [_sortOrderDesc, !_sortOrderDesc],
 onPressed: (index) {
 setState(() {
 _sortOrderDesc = index == 0;
});
 },
 children: const [
 Padding(
 padding: const EdgeInsets.symmetric(1),
 child: Text('Desc'),
 ),
 Padding(
 padding: const EdgeInsets.symmetric(1),
 child: Text('Asc'),
 ),
 ],
 ),
 ],
 ),
 ),
 ],
 ),
 ],
 );
 }

 Widget _buildResultsSection() {
 if (!_hasSearched) {{
 return const Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(Icons.search, size: 64, color: Colors.grey),
 const SizedBox(height: 16),
 Text(
 'Effectuez une recherche pour voir les résultats',
 style: const TextStyle(fontSize: 16, color: Colors.grey),
 ),
 ],
 ),
 );
}

 if (_isLoading) {{
 return const Center(child: CircularProgressIndicator());
}

 if (_orders.isEmpty) {{
 return const Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
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

 return Column(
 children: [
 // En-tête des résultats
 Container(
 width: double.infinity,
 padding: const EdgeInsets.all(1),
 color: Colors.grey[100],
 child: Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 '${_orders.length} commande(s) trouvée(s)',
 style: const TextStyle(
 fontWeight: FontWeight.bold,
 fontSize: 16,
 ),
 ),
 CustomButton(
 text: 'Exporter',
 onPressed: _exportResults,
 type: ButtonType.secondary,
 ),
 ],
 ),
 ),
 
 // Liste des résultats
 Expanded(
 child: ListView.builder(
 padding: const EdgeInsets.all(1),
 itemCount: _orders.length,
 itemBuilder: (context, index) {
 final order = _orders[index];
 return Padding(
 padding: const EdgeInsets.only(bottom: 16),
 child: OrderCard(
 order: order,
 onTap: () => _navigateToOrderDetails(order),
 onEdit: () => _navigateToStatusUpdate(order),
 ),
 );
},
 ),
 ),
 ],
 );
 }

 void _navigateToOrderDetails(Order order) {
 Navigator.of(context).pushNamed('/order-details', arguments: order);
 }

 void _navigateToStatusUpdate(Order order) {
 Navigator.of(context).push(
 MaterialPageRoute(
 builder: (context) => OrderStatusUpdateScreen(
 order: order,
 currentUser: widget.currentUser,
 ),
 ),
 );
 }

 Future<void> _exportResults() {async {
 try {
 final response = await _orderService.exportOrders(
 format: 'csv',
 filters: {
 'search': _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
 'status': _selectedStatus?.apiValue,
 'product_id': _selectedProductId,
 'date_from': _dateFrom?.toIso8601String(),
 'date_to': _dateTo?.toIso8601String(),
 'min_amount': _minAmount,
 'max_amount': _maxAmount,
 'is_paid': _isPaid,
 'is_overdue': _isOverdue,
 'product_categories': _selectedCategories.isEmpty ? null : _selectedCategories.join(','),
 'delivery_method': _selectedDeliveryMethod,
 'payment_method': _selectedPaymentMethod,
 'sort_by': _sortBy,
 'sort_order': _sortOrderDesc ? 'desc' : 'asc',
 },
 );

 if (response.isSuccess) {{
 _showSuccessSnackBar('Export réussi');
 } else {
 _showErrorSnackBar(response.errorMessage ?? 'Erreur lors de l\'export');
 }
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
}
 }

 Future<void> _selectDateFrom() {async {
 final DateTime? picked = await showDatePicker(
 context: context,
 initialDate: _dateFrom ?? DateTime.now(),
 firstDate: DateTime(2020),
 lastDate: DateTime.now().add(const Duration(days: 365)),
 );
 
 if (picked != null) {{
 setState(() {
 _dateFrom = picked;
 });
}
 }

 Future<void> _selectDateTo() {async {
 final DateTime? picked = await showDatePicker(
 context: context,
 initialDate: _dateTo ?? DateTime.now(),
 firstDate: DateTime(2020),
 lastDate: DateTime.now().add(const Duration(days: 365)),
 );
 
 if (picked != null) {{
 setState(() {
 _dateTo = picked;
 });
}
 }

 void _showSuccessSnackBar(String message) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(message),
 backgroundColor: Colors.green,
 behavior: SnackBarBehavior.floating,
 ),
 );
 }
}

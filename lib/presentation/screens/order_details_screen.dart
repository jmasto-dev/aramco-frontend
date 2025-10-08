import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/models/order.dart';
import '../../core/models/order_status.dart';
import '../../core/models/user.dart';
import '../../core/services/order_service.dart';
import '../../core/services/api_service.dart';
import '../../presentation/widgets/custom_button.dart';
import '../../presentation/widgets/custom_text_field.dart';
import '../../presentation/widgets/status_badge.dart';
import '../../presentation/widgets/loading_overlay.dart';
import 'order_status_update_screen.dart';
import 'order_form_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
 final Order order;
 final User? currentUser;

 const OrderDetailsScreen({
 Key? key,
 required this.order,
 this.currentUser,
 }) : super(key: key);

 @override
 State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with TickerProviderStateMixin {
 final OrderService _orderService = OrderService(ApiService());
 
 bool _isLoading = false;
 bool _isDeleting = false;
 Order? _currentOrder;
 late TabController _tabController;
 
 @override
 void initState() {
 super.initState();
 _currentOrder = widget.order;
 _tabController = TabController(length: 4, vsync: this);
 }

 @override
 void dispose() {
 _tabController.dispose();
 super.dispose();
 }

 Future<void> _refreshOrder() {async {
 setState(() {
 _isLoading = true;
});

 try {
 final response = await _orderService.getOrderById(_currentOrder!.id);
 if (response.isSuccess && response.data != null) {{
 setState(() {
 _currentOrder = response.data!;
 });
 } else {
 _showErrorSnackBar(response.errorMessage ?? 'Erreur lors du chargement');
 }
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
} finally {
 setState(() {
 _isLoading = false;
 });
}
 }

 Future<void> _deleteOrder() {async {
 final confirmed = await _showDeleteConfirmation();
 if (!confirmed) r{eturn;

 setState(() {
 _isDeleting = true;
});

 try {
 final response = await _orderService.deleteOrder(_currentOrder!.id);
 if (response.isSuccess) {{
 _showSuccessSnackBar('Commande supprimée avec succès');
 Navigator.of(context).pop(true);
 } else {
 _showErrorSnackBar(response.errorMessage ?? 'Erreur lors de la suppression');
 }
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
} finally {
 setState(() {
 _isDeleting = false;
 });
}
 }

 Future<bool> _showDeleteConfirmation() {async {
 final result = await showDialog<bool>(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Confirmer la suppression'),
 content: const Text('Êtes-vous sûr de vouloir supprimer cette commande ? Cette action est irréversible.'),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(false),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () => Navigator.of(context).pop(true),
 style: TextButton.styleFrom(foregroundColor: Colors.red),
 child: const Text('Supprimer'),
 ),
 ],
 ),
 );
 return result ?? false;
 }

 void _navigateToEdit() {
 Navigator.of(context).push(
 MaterialPageRoute(
 builder: (context) => OrderFormScreen(
 order: _currentOrder,
 currentUser: widget.currentUser,
 ),
 ),
 ).then((result) {
 if (result == true) {{
 _refreshOrder();
 }
});
 }

 void _navigateToStatusUpdate() {
 Navigator.of(context).push(
 MaterialPageRoute(
 builder: (context) => OrderStatusUpdateScreen(
 order: _currentOrder!,
 currentUser: widget.currentUser,
 ),
 ),
 ).then((result) {
 if (result == true) {{
 _refreshOrder();
 }
});
 }

 void _duplicateOrder() {
 Navigator.of(context).push(
 MaterialPageRoute(
 builder: (context) => OrderFormScreen(
 order: _currentOrder?.copyWith(
 id: 'order_${DateTime.now().millisecondsSinceEpoch}',
 status: OrderStatus.pending,
 createdAt: DateTime.now(),
 updatedAt: DateTime.now(),
 ),
 currentUser: widget.currentUser,
 ),
 ),
 );
 }

 void _printOrder() {
 // TODO: Implémenter l'impression
 _showSuccessSnackBar('Impression en cours de développement');
 }

 void _exportOrder() async {
 try {
 final response = await _orderService.exportOrders(
 format: 'pdf',
 filters: {
 'order_id': _currentOrder!.id,
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

 void _showErrorSnackBar(String message) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(message),
 backgroundColor: Colors.red,
 behavior: SnackBarBehavior.floating,
 ),
 );
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

 @override
 Widget build(BuildContext context) {
 if (_currentOrder == null) {{
 return const Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 body: Center(child: CircularProgressIndicator()),
 );
}

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: Text('Commande #${_currentOrder!.id.substring(0, 8).toUpperCase()}'),
 actions: [
 IconButton(
 icon: const Icon(Icons.refresh),
 onPressed: _refreshOrder,
 tooltip: 'Actualiser',
 ),
 PopupMenuButton<String>(
 onSelected: (value) {
 switch (value) {
 case 'edit':
 _navigateToEdit();
 break;
 case 'status':
 _navigateToStatusUpdate();
 break;
 case 'duplicate':
 _duplicateOrder();
 break;
 case 'print':
 _printOrder();
 break;
 case 'export':
 _exportOrder();
 break;
 case 'delete':
 _deleteOrder();
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
 const PopupMenuItem(
 value: 'status',
 child: Row(
 children: [
 Icon(Icons.update, size: 16),
 const SizedBox(width: 8),
 Text('Mettre à jour le statut'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'duplicate',
 child: Row(
 children: [
 Icon(Icons.copy, size: 16),
 const SizedBox(width: 8),
 Text('Dupliquer'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'print',
 child: Row(
 children: [
 Icon(Icons.print, size: 16),
 const SizedBox(width: 8),
 Text('Imprimer'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'export',
 child: Row(
 children: [
 Icon(Icons.download, size: 16),
 const SizedBox(width: 8),
 Text('Exporter'),
 ],
 ),
 ),
 if (_currentOrder!.status.canBeCancelled)
 c{onst PopupMenuItem(
 value: 'delete',
 child: Row(
 children: [
 Icon(Icons.delete, size: 16, color: Colors.red),
 const SizedBox(width: 8),
 Text('Supprimer', style: const TextStyle(color: Colors.red)),
 ],
 ),
 ),
 ],
 ),
 ],
 bottom: TabBar(
 controller: _tabController,
 tabs: const [
 Tab(text: 'Informations', icon: Icon(Icons.info)),
 Tab(text: 'Articles', icon: Icon(Icons.shopping_bag)),
 Tab(text: 'Livraison', icon: Icon(Icons.local_shipping)),
 Tab(text: 'Paiement', icon: Icon(Icons.payment)),
 ],
 ),
 ),
 body: LoadingOverlay(
 isLoading: _isLoading || _isDeleting,
 child: TabBarView(
 controller: _tabController,
 children: [
 _buildInfoTab(),
 _buildItemsTab(),
 _buildShippingTab(),
 _buildPaymentTab(),
 ],
 ),
 ),
 );
 }

 Widget _buildInfoTab() {
 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête avec statut
 _buildOrderHeader(),
 const SizedBox(height: 24),
 
 // Informations client
 _buildCustomerInfo(),
 const SizedBox(height: 24),
 
 // Informations générales
 _buildGeneralInfo(),
 const SizedBox(height: 24),
 
 // Notes
 if (_currentOrder!.notes != null && _currentOrder!.notes!.isNotEmpty) .{..[
 _buildNotesSection(),
 const SizedBox(height: 24),
 ],
 
 // Actions rapides
 _buildQuickActions(),
 ],
 ),
 );
 }

 Widget _buildOrderHeader() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Commande #${_currentOrder!.id.substring(0, 8).toUpperCase()}',
 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 4),
 Text(
 'Créée le ${_formatDate(_currentOrder!.createdAt)}',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 if (_currentOrder!.updatedAt != null) .{..[
 const SizedBox(height: 2),
 Text(
 'Modifiée le ${_formatDate(_currentOrder!.updatedAt!)}',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[500],
 ),
 ),
 ],
 ],
 ),
 ),
 StatusBadge(status: _currentOrder!.status),
 ],
 ),
 const SizedBox(height: 16),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Montant total:',
 style: Theme.of(context).textTheme.titleMedium,
 ),
 Text(
 _currentOrder!.formattedTotalAmount,
 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
 fontWeight: FontWeight.bold,
 color: Theme.of(context).primaryColor,
 ),
 ),
 ],
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildCustomerInfo() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.person, color: Theme.of(context).primaryColor),
 const SizedBox(width: 8),
 Text(
 'Informations client',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 _buildInfoRow('Nom', _currentOrder!.customerName),
 _buildInfoRow('Email', _currentOrder!.customerEmail),
 _buildInfoRow('Téléphone', _currentOrder!.customerPhone),
 ],
 ),
 ),
 );
 }

 Widget _buildGeneralInfo() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.info, color: Theme.of(context).primaryColor),
 const SizedBox(width: 8),
 Text(
 'Informations générales',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 _buildInfoRow('ID Commande', _currentOrder!.id),
 _buildInfoRow('Date de création', _formatDate(_currentOrder!.createdAt)),
 if (_currentOrder!.expectedDeliveryDate != null)
 _{buildInfoRow('Date de livraison souhaitée', _formatDate(_currentOrder!.expectedDeliveryDate!)),
 _buildInfoRow('Nombre d\'articles', '${_currentOrder!.itemCount}'),
 _buildInfoRow('Devise', _currentOrder!.currency),
 if (_currentOrder!.taxAmount > 0)
 _{buildInfoRow('TVA', '${_currentOrder!.taxAmount.toStringAsFixed(2)} ${_currentOrder!.currency}'),
 if (_currentOrder!.shippingAmount > 0)
 _{buildInfoRow('Frais de livraison', '${_currentOrder!.shippingAmount.toStringAsFixed(2)} ${_currentOrder!.currency}'),
 ],
 ),
 ),
 );
 }

 Widget _buildNotesSection() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.note, color: Theme.of(context).primaryColor),
 const SizedBox(width: 8),
 Text(
 'Notes',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 Text(_currentOrder!.notes!),
 ],
 ),
 ),
 );
 }

 Widget _buildQuickActions() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Actions rapides',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: [
 CustomButton(
 text: 'Modifier',
 onPressed: _navigateToEdit,
 icon: Icons.edit,
 ),
 CustomButton(
 text: 'Mettre à jour le statut',
 onPressed: _navigateToStatusUpdate,
 type: ButtonType.secondary,
 icon: Icons.update,
 ),
 CustomButton(
 text: 'Dupliquer',
 onPressed: _duplicateOrder,
 type: ButtonType.secondary,
 icon: Icons.copy,
 ),
 CustomButton(
 text: 'Exporter',
 onPressed: _exportOrder,
 type: ButtonType.tertiary,
 icon: Icons.download,
 ),
 ],
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildItemsTab() {
 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 // Résumé des articles
 Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Résumé',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text('Sous-total:'),
 Text(_currentOrder!.formattedSubtotalAmount),
 ],
 ),
 if (_currentOrder!.taxAmount > 0) .{..[
 const SizedBox(height: 4),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text('TVA:'),
 Text(_currentOrder!.formattedTaxAmount),
 ],
 ),
 ],
 if (_currentOrder!.shippingAmount > 0) .{..[
 const SizedBox(height: 4),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text('Livraison:'),
 Text(_currentOrder!.formattedShippingAmount),
 ],
 ),
 ],
 const Divider(),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Total:',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 Text(
 _currentOrder!.formattedTotalAmount,
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 color: Theme.of(context).primaryColor,
 ),
 ),
 ],
 ),
 ],
 ),
 ),
 ),
 const SizedBox(height: 16),
 
 // Liste des articles
 Card(
 child: Column(
 children: [
 ListTile(
 title: Text(
 'Articles (${_currentOrder!.itemCount})',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 const Divider(height: 1),
 ..._currentOrder!.items.asMap().entries.map((entry) {
 final index = entry.key;
 final item = entry.value;
 return Column(
 children: [
 ListTile(
 leading: item.productImage != null
 ? ClipRRect(
 borderRadius: const Borderconst Radius.circular(1),
 child: Image.network(
 item.productImage!,
 width: 48,
 height: 48,
 fit: BoxFit.cover,
 errorBuilder: (context, error, stackTrace) {
 return const SizedBox(
 width: 48,
 height: 48,
 color: Colors.grey[300],
 child: const Icon(Icons.image, color: Colors.grey),
 );
 },
 ),
 )
 : const SizedBox(
 width: 48,
 height: 48,
 decoration: BoxDecoration(
 color: Colors.grey[300],
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: const Icon(Icons.image, color: Colors.grey),
 ),
 title: Text(item.productName),
 subtitle: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text('SKU: ${item.productSku}'),
 if (item.productCategory != null)
 T{ext('Catégorie: ${item.productCategory}'),
 Text('Prix unitaire: ${item.formattedUnitPrice}'),
 ],
 ),
 trailing: Column(
 crossAxisAlignment: CrossAxisAlignment.end,
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Text(
 '${item.quantity}x',
 style: Theme.of(context).textTheme.titleSmall?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 Text(
 item.formattedTotalPrice,
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 color: Theme.of(context).primaryColor,
 ),
 ),
 ],
 ),
 ),
 if (index < _currentOrder!.items.length - 1)
 c{onst Divider(height: 1),
 ],
 );
 }),
 ],
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildShippingTab() {
 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 // Adresse de livraison
 Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
 const SizedBox(width: 8),
 Text(
 'Adresse de livraison',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 Text(_currentOrder!.shippingAddress.fullAddress),
 ],
 ),
 ),
 ),
 const SizedBox(height: 16),
 
 // Adresse de facturation
 if (_currentOrder!.billingAddress != null) .{..[
 Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.receipt, color: Theme.of(context).primaryColor),
 const SizedBox(width: 8),
 Text(
 'Adresse de facturation',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 Text(_currentOrder!.billingAddress!.fullAddress),
 ],
 ),
 ),
 ),
 const SizedBox(height: 16),
 ],
 
 // Informations de livraison
 Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.info, color: Theme.of(context).primaryColor),
 const SizedBox(width: 8),
 Text(
 'Informations de livraison',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 if (_currentOrder!.expectedDeliveryDate != null)
 _{buildInfoRow('Date de livraison souhaitée', _formatDate(_currentOrder!.expectedDeliveryDate!)),
 _buildInfoRow('Frais de livraison', '${_currentOrder!.shippingAmount.toStringAsFixed(2)} ${_currentOrder!.currency}'),
 _buildInfoRow('Statut de livraison', _currentOrder!.deliveryStatus),
 ],
 ),
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildPaymentTab() {
 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 // Informations de paiement
 Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.payment, color: Theme.of(context).primaryColor),
 const SizedBox(width: 8),
 Text(
 'Informations de paiement',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 _buildInfoRow('ID Paiement', _currentOrder!.paymentInfo.id),
 _buildInfoRow('Méthode', _getPaymentMethodName(_currentOrder!.paymentInfo.method)),
 _buildInfoRow('Statut', _getPaymentStatusName(_currentOrder!.paymentInfo.status)),
 _buildInfoRow('Montant', '${_currentOrder!.paymentInfo.amount.toStringAsFixed(2)} ${_currentOrder!.paymentInfo.currency}'),
 if (_currentOrder!.paymentInfo.paidAt != null)
 _{buildInfoRow('Date de paiement', _formatDate(_currentOrder!.paymentInfo.paidAt!)),
 ],
 ),
 ),
 ),
 const SizedBox(height: 16),
 
 // Résumé financier
 Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.account_balance, color: Theme.of(context).primaryColor),
 const SizedBox(width: 8),
 Text(
 'Résumé financier',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text('Sous-total:'),
 Text(_currentOrder!.formattedSubtotalAmount),
 ],
 ),
 if (_currentOrder!.taxAmount > 0) .{..[
 const SizedBox(height: 4),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text('TVA:'),
 Text(_currentOrder!.formattedTaxAmount),
 ],
 ),
 ],
 if (_currentOrder!.shippingAmount > 0) .{..[
 const SizedBox(height: 4),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text('Livraison:'),
 Text(_currentOrder!.formattedShippingAmount),
 ],
 ),
 ],
 const Divider(),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Total:',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 Text(
 _currentOrder!.formattedTotalAmount,
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 color: Theme.of(context).primaryColor,
 ),
 ),
 ],
 ),
 const SizedBox(height: 8),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Statut paiement:',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 StatusBadgeSmall(
 status: _currentOrder!.isPaid ? OrderStatus.confirmed : OrderStatus.pending,
 ),
 ],
 ),
 ],
 ),
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildInfoRow(String label, String value) {
 return Padding(
 padding: const EdgeInsets.only(bottom: 8),
 child: Row(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const SizedBox(
 width: 120,
 child: Text(
 '$label:',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 ),
 Expanded(
 child: Text(
 value,
 style: Theme.of(context).textTheme.bodyMedium,
 ),
 ),
 ],
 ),
 );
 }

 String _formatDate(DateTime date) {
 return DateFormat('dd/MM/yyyy à HH:mm').format(date);
 }

 String _getPaymentMethodName(PaymentMethod method) {
 switch (method) {
 case PaymentMethod.creditCard:
 return 'Carte de crédit';
 case PaymentMethod.debitCard:
 return 'Carte de débit';
 case PaymentMethod.paypal:
 return 'PayPal';
 case PaymentMethod.bankTransfer:
 return 'Virement bancaire';
 case PaymentMethod.cashOnDelivery:
 return 'Paiement à la livraison';
 case PaymentMethod.crypto:
 return 'Cryptomonnaie';
 case PaymentMethod.check:
 return 'Chèque';
 case PaymentMethod.other:
 return 'Autre';
}
 }

 String _getPaymentStatusName(PaymentStatus status) {
 switch (status) {
 case PaymentStatus.pending:
 return 'En attente';
 case PaymentStatus.processing:
 return 'En traitement';
 case PaymentStatus.paid:
 return 'Payé';
 case PaymentStatus.failed:
 return 'Échoué';
 case PaymentStatus.refunded:
 return 'Remboursé';
 case PaymentStatus.partiallyRefunded:
 return 'Partiellement remboursé';
}
 }
}

// Extension pour copier une commande
extension OrderCopy on Order {
 Order copyWith({
 String? id,
 String? customerId,
 String? customerName,
 String? customerEmail,
 String? customerPhone,
 List<OrderItem>? items,
 OrderStatus? status,
 DateTime? createdAt,
 DateTime? updatedAt,
 DateTime? expectedDeliveryDate,
 double? totalAmount,
 double? taxAmount,
 double? shippingAmount,
 String? currency,
 String? notes,
 ShippingAddress? shippingAddress,
 BillingAddress? billingAddress,
 PaymentInfo? paymentInfo,
 }) {
 return Order(
 id: id ?? this.id,
 customerId: customerId ?? this.customerId,
 customerName: customerName ?? this.customerName,
 customerEmail: customerEmail ?? this.customerEmail,
 customerPhone: customerPhone ?? this.customerPhone,
 items: items ?? this.items,
 status: status ?? this.status,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
 totalAmount: totalAmount ?? this.totalAmount,
 taxAmount: taxAmount ?? this.taxAmount,
 shippingAmount: shippingAmount ?? this.shippingAmount,
 currency: currency ?? this.currency,
 notes: notes ?? this.notes,
 shippingAddress: shippingAddress ?? this.shippingAddress,
 billingAddress: billingAddress ?? this.billingAddress,
 paymentInfo: paymentInfo ?? this.paymentInfo,
 );
 }
}

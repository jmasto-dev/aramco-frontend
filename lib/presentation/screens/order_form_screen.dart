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
import '../../core/utils/validators.dart';
import '../../presentation/widgets/custom_button.dart';
import '../../presentation/widgets/custom_text_field.dart';
import '../../presentation/widgets/product_selector.dart';
import '../../presentation/widgets/loading_overlay.dart';

class OrderFormScreen extends StatefulWidget {
 final Order? order; // Pour la modification d'une commande existante
 final User? currentUser;

 const OrderFormScreen({
 Key? key,
 this.order,
 this.currentUser,
 }) : super(key: key);

 @override
 State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
 final _formKey = GlobalKey<FormState>();
 final _customerNameController = TextEditingController();
 final _customerEmailController = TextEditingController();
 final _customerPhoneController = TextEditingController();
 final _shippingAddressController = TextEditingController();
 final _billingAddressController = TextEditingController();
 final _notesController = TextEditingController();
 
 final OrderService _orderService = OrderService(ApiService());
 final ProductService _productService = ProductService(ApiService());
 
 bool _isLoading = false;
 bool _isLoadingProducts = false;
 List<Product> _products = [];
 Map<String, int> _selectedProducts = {};
 
 OrderStatus _selectedStatus = OrderStatus.pending;
 String? _selectedPriority;
 DateTime? _deliveryDate;
 double _shippingCost = 0.0;
 double _taxRate = 0.0; // Taux de TVA par défaut
 
 @override
 void initState() {
 super.initState();
 _loadData();
 _initializeForm();
 }

 @override
 void dispose() {
 _customerNameController.dispose();
 _customerEmailController.dispose();
 _customerPhoneController.dispose();
 _shippingAddressController.dispose();
 _billingAddressController.dispose();
 _notesController.dispose();
 super.dispose();
 }

 void _initializeForm() {
 if (widget.order != null) {{
 // Mode modification
 final order = widget.order!;
 _customerNameController.text = order.customerName;
 _customerEmailController.text = order.customerEmail;
 _customerPhoneController.text = order.customerPhone;
 _shippingAddressController.text = order.shippingAddress.fullAddress;
 _billingAddressController.text = order.billingAddress?.fullAddress ?? '';
 _notesController.text = order.notes ?? '';
 _selectedStatus = order.status;
 _deliveryDate = order.expectedDeliveryDate;
 _shippingCost = order.shippingAmount;
 
 // Initialiser les produits sélectionnés
 _selectedProducts = {
 for (final item in order.items)
 item.productId: item.quantity,
 };
} else if (widget.currentUser != null) {{
 // Mode création avec utilisateur connecté
 final user = widget.currentUser!;
 _customerNameController.text = user.fullName;
 _customerEmailController.text = user.email;
}
 }

 Future<void> _loadData() {async {
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
 _showErrorSnackBar('Erreur lors du chargement des produits: $e');
} finally {
 setState(() {
 _isLoadingProducts = false;
 });
}
 }

 void _onProductSelectionChanged(Map<String, int> selectedProducts) {
 setState(() {
 _selectedProducts = selectedProducts;
});
 }

 double _calculateSubtotal() {
 double subtotal = 0.0;
 for (final entry in _selectedProducts.entries) {
 final product = _products.firstWhere(
 (p) => p.id == entry.key,
 orElse: () => throw Exception('Product not found'),
 );
 subtotal += product.effectivePrice * entry.value;
}
 return subtotal;
 }

 double _calculateTax() {
 return _calculateSubtotal() * _taxRate;
 }

 double _calculateTotal() {
 return _calculateSubtotal() + _calculateTax() + _shippingCost;
 }

 List<OrderItem> _createOrderItems() {
 return _selectedProducts.entries.map((entry) {
 final product = _products.firstWhere(
 (p) => p.id == entry.key,
 orElse: () => throw Exception('Product not found'),
 );
 
 return OrderItem(
 productId: product.id,
 productName: product.name,
 productSku: product.sku ?? '',
 productImage: product.images.isNotEmpty ? product.images.first : null,
 quantity: entry.value,
 unitPrice: product.effectivePrice,
 totalPrice: product.effectivePrice * entry.value,
 productCategory: product.category,
 );
}).toList();
 }

 Future<void> _saveOrder() {async {
 if (!_formKey.currentState!.validate()){ {
 return;
}

 if (_selectedProducts.isEmpty) {{
 _showErrorSnackBar('Veuillez sélectionner au moins un produit');
 return;
}

 setState(() {
 _isLoading = true;
});

 try {
 // Créer les adresses
 final shippingAddress = ShippingAddress(
 street: _shippingAddressController.text.trim(),
 city: 'Ville', // TODO: Extraire de l'adresse complète
 postalCode: '00000', // TODO: Extraire de l'adresse complète
 country: 'Sénégal', // TODO: Extraire de l'adresse complète
 );

 final billingAddress = _billingAddressController.text.trim().isNotEmpty
 ? BillingAddress(
 street: _billingAddressController.text.trim(),
 city: 'Ville', // TODO: Extraire de l'adresse complète
 postalCode: '00000', // TODO: Extraire de l'adresse complète
 country: 'Sénégal', // TODO: Extraire de l'adresse complète
 )
 : null;

 // Créer les informations de paiement
 final paymentInfo = PaymentInfo(
 id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
 method: PaymentMethod.other,
 status: PaymentStatus.pending,
 amount: _calculateTotal(),
 currency: 'EUR',
 );

 // Créer l'objet Order
 final order = Order(
 id: widget.order?.id ?? 'order_${DateTime.now().millisecondsSinceEpoch}',
 customerId: widget.currentUser?.id ?? 'customer_${DateTime.now().millisecondsSinceEpoch}',
 customerName: _customerNameController.text.trim(),
 customerEmail: _customerEmailController.text.trim(),
 customerPhone: _customerPhoneController.text.trim().isEmpty 
 ? 'Non spécifié' 
 : _customerPhoneController.text.trim(),
 items: _createOrderItems(),
 status: _selectedStatus,
 createdAt: widget.order?.createdAt ?? DateTime.now(),
 updatedAt: DateTime.now(),
 expectedDeliveryDate: _deliveryDate,
 totalAmount: _calculateTotal(),
 taxAmount: _calculateTax(),
 shippingAmount: _shippingCost,
 currency: 'EUR',
 notes: _notesController.text.trim().isEmpty 
 ? null 
 : _notesController.text.trim(),
 shippingAddress: shippingAddress,
 billingAddress: billingAddress,
 paymentInfo: paymentInfo,
 );

 final response = widget.order != null
 ? await _orderService.updateOrder(order)
 : await _orderService.createOrder(order);

 if (response.isSuccess) {{
 _showSuccessSnackBar(
 widget.order != null 
 ? 'Commande mise à jour avec succès' 
 : 'Commande créée avec succès');
 Navigator.of(context).pop(true);
 } else {
 _showErrorSnackBar(response.errorMessage ?? 'Erreur lors de la sauvegarde');
 }
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
} finally {
 setState(() {
 _isLoading = false;
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

 void _showErrorSnackBar(String message) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(message),
 backgroundColor: Colors.red,
 behavior: SnackBarBehavior.floating,
 ),
 );
 }

 Future<void> _selectDeliveryDate() {async {
 final DateTime? picked = await showDatePicker(
 context: context,
 initialDate: _deliveryDate ?? DateTime.now().add(const Duration(days: 7)),
 firstDate: DateTime.now(),
 lastDate: DateTime.now().add(const Duration(days: 365)),
 );
 
 if (picked != null) {{
 setState(() {
 _deliveryDate = picked;
 });
}
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: Text(widget.order != null ? 'Modifier la commande' : 'Nouvelle commande'),
 actions: [
 if (widget.order != null)
 I{conButton(
 icon: const Icon(Icons.delete),
 onPressed: _confirmDelete,
 ),
 ],
 ),
 body: LoadingOverlay(
 isLoading: _isLoading,
 child: Form(
 key: _formKey,
 child: Column(
 children: [
 // En-tête avec résumé
 _buildOrderSummary(),
 
 // Formulaire
 Expanded(
 child: SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Informations client
 _buildCustomerSection(),
 const SizedBox(height: 24),
 
 // Sélection des produits
 _buildProductsSection(),
 const SizedBox(height: 24),
 
 // Options de livraison
 _buildShippingSection(),
 const SizedBox(height: 24),
 
 // Notes additionnelles
 _buildNotesSection(),
 const SizedBox(height: 32),
 
 // Boutons d'action
 _buildActionButtons(),
 ],
 ),
 ),
 ),
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildOrderSummary() {
 return Container(
 width: double.infinity,
 padding: const EdgeInsets.all(1),
 color: Theme.of(context).primaryconst Color.withOpacity(0.1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Résumé de la commande',
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text('Sous-total:'),
 Text('${_calculateSubtotal().toStringAsFixed(2)} €'),
 ],
 ),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text('TVA (${(_taxRate * 100).toStringAsFixed(1)}%):'),
 Text('${_calculateTax().toStringAsFixed(2)} €'),
 ],
 ),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text('Frais de livraison:'),
 Text('${_shippingCost.toStringAsFixed(2)} €'),
 ],
 ),
 const Divider(),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Total:',
 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
 ),
 Text(
 '${_calculateTotal().toStringAsFixed(2)} €',
 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildCustomerSection() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Informations client',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 
 CustomTextField(
 controller: _customerNameController,
 label: 'Nom complet',
 hintText: 'Entrez le nom du client',
 validator: (value) {
 if (value == null || value.trim().{isEmpty) {
 return 'Ce champ est obligatoire';
}
 return null;
},
 inputFormatters: [
 FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\-]')),
 ],
 ),
 const SizedBox(height: 16),
 
 CustomTextField(
 controller: _customerEmailController,
 label: 'Email',
 hintText: 'client@example.com',
 keyboardType: TextInputType.emailAddress,
 validator: (value) {
 if (value == null || value.trim().{isEmpty) {
 return 'Ce champ est obligatoire';
}
 if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+{[\w-]{2,4}$').hasMatch(value)) {
 return 'Veuillez entrer une adresse email valide';
}
 return null;
},
 ),
 const SizedBox(height: 16),
 
 CustomTextField(
 controller: _customerPhoneController,
 label: 'Téléphone',
 hintText: '+221 33 123 45 67',
 keyboardType: TextInputType.phone,
 validator: (value) {
 if (value != null && value.isNotEmpty) {{
 if (!RegExp(r'^[\d\s\+\-\(\)]{+$').hasMatch(value)) {
 return 'Veuillez entrer un numéro de téléphone valide';
 }
}
 return null;
},
 ),
 const SizedBox(height: 16),
 
 CustomTextField(
 controller: _shippingAddressController,
 label: 'Adresse de livraison',
 hintText: 'Entrez l\'adresse de livraison',
 validator: (value) {
 if (value == null || value.trim().{isEmpty) {
 return 'Ce champ est obligatoire';
}
 return null;
},
 maxLines: 3,
 ),
 const SizedBox(height: 16),
 
 CustomTextField(
 controller: _billingAddressController,
 label: 'Adresse de facturation',
 hintText: 'Entrez l\'adresse de facturation (optionnel)',
 maxLines: 3,
 ),
 ],
 );
 }

 Widget _buildProductsSection() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Produits',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 
 if (_isLoadingProducts)
 c{onst Center(child: CircularProgressIndicator())
 else
 Container(
 height: 400,
 decoration: BoxDecoration(
 border: Border.all(color: Colors.grey.shade300),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: ProductSelector(
 products: _products,
 selectedProducts: _selectedProducts,
 onSelectionChanged: _onProductSelectionChanged,
 ),
 ),
 ],
 );
 }

 Widget _buildShippingSection() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Options de livraison',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 
 // Statut de la commande
 DropdownButtonFormField<OrderStatus>(
 value: _selectedStatus,
 decoration: const InputDecoration(
 labelText: 'Statut',
 border: OutlineInputBorder(),
 ),
 items: OrderStatus.values.map((status) {
 return DropdownMenuItem(
 value: status,
 child: Text(status.displayName),
 );
}).toList(),
 onChanged: (value) {
 if (value != null) {{
 setState(() {
 _selectedStatus = value;
 });
}
},
 ),
 const SizedBox(height: 16),
 
 // Priorité
 DropdownButtonFormField<String>(
 value: _selectedPriority,
 decoration: const InputDecoration(
 labelText: 'Priorité',
 border: OutlineInputBorder(),
 ),
 items: const [
 DropdownMenuItem(value: null, child: Text('Normale')),
 DropdownMenuItem(value: 'low', child: Text('Basse')),
 DropdownMenuItem(value: 'medium', child: Text('Moyenne')),
 DropdownMenuItem(value: 'high', child: Text('Haute')),
 DropdownMenuItem(value: 'urgent', child: Text('Urgente')),
 ],
 onChanged: (value) {
 setState(() {
 _selectedPriority = value;
});
},
 ),
 const SizedBox(height: 16),
 
 // Date de livraison
 InkWell(
 onTap: _selectDeliveryDate,
 child: InputDecorator(
 decoration: const InputDecoration(
 labelText: 'Date de livraison souhaitée',
 border: OutlineInputBorder(),
 suffixIcon: Icon(Icons.calendar_today),
 ),
 child: Text(
 _deliveryDate != null
 ? '${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year}'
 : 'Sélectionner une date',
 ),
 ),
 ),
 const SizedBox(height: 16),
 
 // Frais de livraison
 CustomTextField(
 controller: TextEditingController(text: _shippingCost.toString()),
 label: 'Frais de livraison (€)',
 hintText: '0.00',
 keyboardType: const TextInputType.numberWithOptions(decimal: true),
 onChanged: (value) {
 final cost = double.tryParse(value) ?? 0.0;
 setState(() {
 _shippingCost = cost;
});
},
 ),
 ],
 );
 }

 Widget _buildNotesSection() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Notes additionnelles',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 
 CustomTextField(
 controller: _notesController,
 label: 'Notes',
 hintText: 'Entrez des notes ou instructions spéciales...',
 maxLines: 4,
 ),
 ],
 );
 }

 Widget _buildActionButtons() {
 return Row(
 children: [
 Expanded(
 child: CustomButton(
 text: 'Annuler',
 onPressed: () => Navigator.of(context).pop(),
 type: ButtonType.secondary,
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: CustomButton(
 text: widget.order != null ? 'Mettre à jour' : 'Créer la commande',
 onPressed: _saveOrder,
 isLoading: _isLoading,
 ),
 ),
 ],
 );
 }

 void _confirmDelete() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Confirmer la suppression'),
 content: const Text('Êtes-vous sûr de vouloir supprimer cette commande ? Cette action est irréversible.'),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () async {
 Navigator.of(context).pop();
 await _deleteOrder();
},
 child: const Text('Supprimer', style: const TextStyle(color: Colors.red)),
 ),
 ],
 ),
 );
 }

 Future<void> _deleteOrder() {async {
 if (widget.order == null) r{eturn;

 setState(() {
 _isLoading = true;
});

 try {
 final response = await _orderService.deleteOrder(widget.order!.id);
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
 _isLoading = false;
 });
}
 }
}

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
import '../../presentation/widgets/status_badge.dart';
import '../../presentation/widgets/loading_overlay.dart';

class OrderStatusUpdateScreen extends StatefulWidget {
 final Order order;
 final User? currentUser;

 const OrderStatusUpdateScreen({
 Key? key,
 required this.order,
 this.currentUser,
 }) : super(key: key);

 @override
 State<OrderStatusUpdateScreen> createState() => _OrderStatusUpdateScreenState();
}

class _OrderStatusUpdateScreenState extends State<OrderStatusUpdateScreen> {
 final _formKey = GlobalKey<FormState>();
 final _commentController = TextEditingController();
 final _internalNoteController = TextEditingController();
 
 final OrderService _orderService = OrderService(ApiService());
 
 bool _isLoading = false;
 OrderStatus? _selectedStatus;
 List<OrderStatus> _availableStatuses = [];
 
 @override
 void initState() {
 super.initState();
 _initializeStatuses();
 _selectedStatus = widget.order.status;
 }

 @override
 void dispose() {
 _commentController.dispose();
 _internalNoteController.dispose();
 super.dispose();
 }

 void _initializeStatuses() {
 // Définir les statuts disponibles selon le statut actuel
 switch (widget.order.status) {
 case OrderStatus.pending:
 _availableStatuses = [
 OrderStatus.pending,
 OrderStatus.confirmed,
 OrderStatus.cancelled,
 ];
 break;
 case OrderStatus.confirmed:
 _availableStatuses = [
 OrderStatus.confirmed,
 OrderStatus.processing,
 OrderStatus.cancelled,
 ];
 break;
 case OrderStatus.processing:
 _availableStatuses = [
 OrderStatus.processing,
 OrderStatus.shipped,
 OrderStatus.cancelled,
 ];
 break;
 case OrderStatus.shipped:
 _availableStatuses = [
 OrderStatus.shipped,
 OrderStatus.delivered,
 ];
 break;
 case OrderStatus.delivered:
 _availableStatuses = [
 OrderStatus.delivered,
 ];
 break;
 case OrderStatus.cancelled:
 _availableStatuses = [
 OrderStatus.cancelled,
 OrderStatus.pending, // Permettre la réactivation
 ];
 break;
 case OrderStatus.refunded:
 _availableStatuses = [
 OrderStatus.refunded,
 ];
 break;
 case OrderStatus.returned:
 _availableStatuses = [
 OrderStatus.returned,
 OrderStatus.refunded,
 ];
 break;
}
 }

 bool _canChangeStatus(OrderStatus newStatus) {
 // Vérifier si le changement de statut est autorisé
 if (newStatus == widget.order.status) r{eturn true;
 
 // Règles métier pour les changements de statut
 switch (widget.order.status) {
 case OrderStatus.pending:
 return [OrderStatus.confirmed, OrderStatus.cancelled].contains(newStatus);
 case OrderStatus.confirmed:
 return [OrderStatus.processing, OrderStatus.cancelled].contains(newStatus);
 case OrderStatus.processing:
 return [OrderStatus.shipped, OrderStatus.cancelled].contains(newStatus);
 case OrderStatus.shipped:
 return [OrderStatus.delivered].contains(newStatus);
 case OrderStatus.delivered:
 return false; // Statut final
 case OrderStatus.cancelled:
 return [OrderStatus.pending].contains(newStatus); // Réactivation possible
 case OrderStatus.refunded:
 return false; // Statut final
 case OrderStatus.returned:
 return [OrderStatus.refunded].contains(newStatus);
}
 }

 String _getStatusChangeDescription(OrderStatus from, OrderStatus to) {
 switch (from) {
 case OrderStatus.pending:
 switch (to) {
 case OrderStatus.confirmed:
 return 'La commande a été confirmée et sera préparée.';
 case OrderStatus.cancelled:
 return 'La commande a été annulée.';
 default:
 return 'Statut mis à jour.';
 }
 case OrderStatus.confirmed:
 switch (to) {
 case OrderStatus.processing:
 return 'La commande est en cours de préparation.';
 case OrderStatus.cancelled:
 return 'La commande a été annulée.';
 default:
 return 'Statut mis à jour.';
 }
 case OrderStatus.processing:
 switch (to) {
 case OrderStatus.shipped:
 return 'La commande a été expédiée.';
 case OrderStatus.cancelled:
 return 'La commande a été annulée.';
 default:
 return 'Statut mis à jour.';
 }
 case OrderStatus.shipped:
 switch (to) {
 case OrderStatus.delivered:
 return 'La commande a été livrée avec succès.';
 default:
 return 'Statut mis à jour.';
 }
 case OrderStatus.delivered:
 return 'Commande déjà livrée.';
 case OrderStatus.cancelled:
 switch (to) {
 case OrderStatus.pending:
 return 'La commande a été réactivée.';
 default:
 return 'Statut mis à jour.';
 }
 case OrderStatus.refunded:
 return 'Commande déjà remboursée.';
 case OrderStatus.returned:
 switch (to) {
 case OrderStatus.refunded:
 return 'Le remboursement a été traité.';
 default:
 return 'Statut mis à jour.';
 }
}
 }

 Future<void> _updateStatus() {async {
 if (!_formKey.currentState!.validate()){ {
 return;
}

 if (_selectedStatus == null) {{
 _showErrorSnackBar('Veuillez sélectionner un statut');
 return;
}

 if (!_canChangeStatus(_selectedStatus!)){ {
 _showErrorSnackBar('Ce changement de statut n\'est pas autorisé');
 return;
}

 setState(() {
 _isLoading = true;
});

 try {
 final response = await _orderService.updateOrderStatus(
 widget.order.id,
 _selectedStatus!,
 comment: _commentController.text.trim().isEmpty 
 ? null 
 : _commentController.text.trim(),
 internalNote: _internalNoteController.text.trim().isEmpty 
 ? null 
 : _internalNoteController.text.trim(),
 );

 if (response.isSuccess) {{
 _showSuccessSnackBar('Statut mis à jour avec succès');
 Navigator.of(context).pop(true);
 } else {
 _showErrorSnackBar(response.errorMessage ?? 'Erreur lors de la mise à jour');
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

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Mettre à jour le statut'),
 ),
 body: LoadingOverlay(
 isLoading: _isLoading,
 child: Form(
 key: _formKey,
 child: Column(
 children: [
 // En-tête avec informations de la commande
 _buildOrderHeader(),
 
 // Formulaire
 Expanded(
 child: SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Statut actuel
 _buildCurrentStatusSection(),
 const SizedBox(height: 24),
 
 // Sélection du nouveau statut
 _buildStatusSelectionSection(),
 const SizedBox(height: 24),
 
 // Description du changement
 if (_selectedStatus != null && _selectedStatus != widget.order.status)
 _{buildStatusChangeDescription(),
 const SizedBox(height: 24),
 
 // Commentaire client
 _buildCommentSection(),
 const SizedBox(height: 24),
 
 // Note interne
 _buildInternalNoteSection(),
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

 Widget _buildOrderHeader() {
 return Container(
 width: double.infinity,
 padding: const EdgeInsets.all(1),
 color: Theme.of(context).primaryconst Color.withOpacity(0.1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Commande #${widget.order.id}',
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 4),
 Text(
 'Client: ${widget.order.customerName}',
 style: Theme.of(context).textTheme.bodyMedium,
 ),
 const SizedBox(height: 4),
 Text(
 'Montant: ${widget.order.totalAmount.toStringAsFixed(2)} €',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildCurrentStatusSection() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Statut actuel',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 StatusBadge(status: widget.order.status),
 const SizedBox(height: 8),
 Text(
 'Date: ${_formatDate(widget.order.updatedAt ?? DateTime.now())}',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 ],
 );
 }

 Widget _buildStatusSelectionSection() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Nouveau statut',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 
 // Liste des statuts disponibles
 ..._availableStatuses.map((status) {
 final isSelected = _selectedStatus == status;
 final isCurrent = status == widget.order.status;
 final canChange = _canChangeStatus(status);
 
 return Card(
 margin: const EdgeInsets.only(bottom: 8),
 color: isSelected 
 ? Theme.of(context).primaryconst Color.withOpacity(0.1)
 : isCurrent 
 ? Colors.grey.withOpacity(0.1)
 : null,
 child: InkWell(
 onTap: canChange ? () {
 setState(() {
 _selectedStatus = status;
 });
 } : null,
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Row(
 children: [
 Radio<OrderStatus>(
 value: status,
 groupValue: _selectedStatus,
 onChanged: canChange ? (value) {
 if (value != null) {{
 setState(() {
 _selectedStatus = value;
});
}
} : null,
 ),
 const SizedBox(width: 12),
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 StatusBadge(status: status),
 if (isCurrent) .{..[
 const SizedBox(width: 8),
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: Colors.orange,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: const Text(
 'Actuel',
 style: const TextStyle(
 color: Colors.white,
 fontSize: 10,
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 ],
 ],
 ),
 const SizedBox(height: 4),
 Text(
 _getStatusDescription(status),
 style: Theme.of(context).textTheme.bodySmall,
 ),
 if (!canChange && !isCurrent) .{..[
 const SizedBox(height: 4),
 Text(
 'Non disponible',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.red,
 fontStyle: FontStyle.italic,
 ),
 ),
 ],
 ],
 ),
 ),
 ],
 ),
 ),
 ),
 );
 }),
 ],
 );
 }

 Widget _buildStatusChangeDescription() {
 if (_selectedStatus == null || _selectedStatus == widget.order.status) {{
 return const SizedBox.shrink();
}

 return Container(
 width: double.infinity,
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.blue.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(color: Colors.blue.withOpacity(0.3)),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.info_outline, color: Colors.blue[700]),
 const SizedBox(width: 8),
 Text(
 'Description du changement',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 color: Colors.blue[700],
 ),
 ),
 ],
 ),
 const SizedBox(height: 8),
 Text(
 _getStatusChangeDescription(widget.order.status, _selectedStatus!),
 style: Theme.of(context).textTheme.bodyMedium,
 ),
 ],
 ),
 );
 }

 Widget _buildCommentSection() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Commentaire client (optionnel)',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 Text(
 'Ce commentaire sera visible par le client',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(height: 8),
 CustomTextField(
 controller: _commentController,
 label: 'Commentaire',
 hintText: 'Entrez un commentaire pour le client...',
 maxLines: 3,
 ),
 ],
 );
 }

 Widget _buildInternalNoteSection() {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Note interne (optionnel)',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 Text(
 'Cette note ne sera pas visible par le client',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(height: 8),
 CustomTextField(
 controller: _internalNoteController,
 label: 'Note interne',
 hintText: 'Entrez une note interne...',
 maxLines: 3,
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
 text: 'Mettre à jour',
 onPressed: _updateStatus,
 isLoading: _isLoading,
 ),
 ),
 ],
 );
 }

 String _formatDate(DateTime date) {
 return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
 }

 String _getStatusDescription(OrderStatus status) {
 switch (status) {
 case OrderStatus.pending:
 return 'En attente de confirmation';
 case OrderStatus.confirmed:
 return 'Commande confirmée, en préparation';
 case OrderStatus.processing:
 return 'En cours de préparation';
 case OrderStatus.shipped:
 return 'Expédiée, en cours de livraison';
 case OrderStatus.delivered:
 return 'Livrée avec succès';
 case OrderStatus.cancelled:
 return 'Commande annulée';
 case OrderStatus.refunded:
 return 'Remboursée';
 case OrderStatus.returned:
 return 'Retournée par le client';
}
 }
}

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/order.dart';
import '../../core/models/order_status.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
 final Order order;
 final VoidCallback? onTap;
 final VoidCallback? onEdit;
 final VoidCallback? onCancel;
 final VoidCallback? onDuplicate;
 final bool showActions;
 final CardVariant variant;

 const OrderCard({
 super.key,
 required this.order,
 this.onTap,
 this.onEdit,
 this.onCancel,
 this.onDuplicate,
 this.showActions = true,
 this.variant = CardVariant.standard,
 });

 @override
 Widget build(BuildContext context) {
 final theme = Theme.of(context);
 
 switch (variant) {
 case CardVariant.compact:
 return _buildCompactCard(context, theme);
 case CardVariant.detailed:
 return _buildDetailedCard(context, theme);
 case CardVariant.standard:
 default:
 return _buildStandardCard(context, theme);
}
 }

 Widget _buildStandardCard(BuildContext context, ThemeData theme) {
 return Card(
 elevation: 2.0,
 margin: const EdgeInsets.symmetric(1),
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildHeader(theme),
 const SizedBox(height: 12.0),
 _buildCustomerInfo(theme),
 const SizedBox(height: 12.0),
 _buildItemsSummary(theme),
 const SizedBox(height: 12.0),
 _buildFooter(theme),
 if (showActions) .{..[
 const SizedBox(height: 12.0),
 _buildActions(context),
 ],
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildCompactCard(BuildContext context, ThemeData theme) {
 return Card(
 elevation: 1.0,
 margin: const EdgeInsets.symmetric(1),
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Row(
 children: [
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Text(
 'CMD-${order.id.substring(0, 8).toUpperCase()}',
 style: theme.textTheme.titleSmall?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(width: 8.0),
 StatusBadgeSmall(status: order.status),
 ],
 ),
 const SizedBox(height: 4.0),
 Text(
 order.customerName,
 style: theme.textTheme.bodyMedium,
 overflow: TextOverflow.ellipsis,
 ),
 const SizedBox(height: 4.0),
 Text(
 order.formattedTotalAmount,
 style: theme.textTheme.titleSmall?.copyWith(
 color: theme.colorScheme.primary,
 fontWeight: FontWeight.w600,
 ),
 ),
 ],
 ),
 ),
 if (showActions)
 P{opupMenuButton<String>(
 onSelected: (value) => _handleMenuAction(context, value),
 itemBuilder: (context) => [
 if (onEdit != null)
 c{onst PopupMenuItem(
 value: 'edit',
 child: Row(
 children: [
 Icon(Icons.edit, size: 16),
 const SizedBox(width: 8),
 Text('Modifier'),
 ],
 ),
 ),
 if (onCancel != null && order.status.canBeCancelled)
 c{onst PopupMenuItem(
 value: 'cancel',
 child: Row(
 children: [
 Icon(Icons.cancel, size: 16),
 const SizedBox(width: 8),
 Text('Annuler'),
 ],
 ),
 ),
 if (onDuplicate != null)
 c{onst PopupMenuItem(
 value: 'duplicate',
 child: Row(
 children: [
 Icon(Icons.copy, size: 16),
 const SizedBox(width: 8),
 Text('Dupliquer'),
 ],
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

 Widget _buildDetailedCard(BuildContext context, ThemeData theme) {
 return Card(
 elevation: 3.0,
 margin: const EdgeInsets.symmetric(1),
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildHeader(theme),
 const SizedBox(height: 16.0),
 _buildDetailedCustomerInfo(theme),
 const SizedBox(height: 16.0),
 _buildDetailedItemsList(theme),
 const SizedBox(height: 16.0),
 _buildDetailedFooter(theme),
 if (showActions) .{..[
 const SizedBox(height: 16.0),
 _buildActions(context),
 ],
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildHeader(ThemeData theme) {
 return Row(
 children: [
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'CMD-${order.id.substring(0, 8).toUpperCase()}',
 style: theme.textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 4.0),
 Text(
 'Créée le ${_formatDate(order.createdAt)}',
 style: theme.textTheme.bodySmall?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 ),
 ],
 ),
 ),
 StatusBadge(status: order.status),
 ],
 );
 }

 Widget _buildCustomerInfo(ThemeData theme) {
 return Row(
 children: [
 Icon(
 Icons.person_outline,
 size: 16.0,
 color: theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 const SizedBox(width: 8.0),
 Expanded(
 child: Text(
 order.customerName,
 style: theme.textTheme.bodyMedium,
 overflow: TextOverflow.ellipsis,
 ),
 ),
 const SizedBox(width: 16.0),
 Text(
 order.formattedTotalAmount,
 style: theme.textTheme.titleMedium?.copyWith(
 color: theme.colorScheme.primary,
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 );
 }

 Widget _buildDetailedCustomerInfo(ThemeData theme) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: theme.colorScheme.surface,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: theme.colorScheme.outline.withOpacity(0.2),
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(
 Icons.person_outline,
 size: 16.0,
 color: theme.colorScheme.primary,
 ),
 const SizedBox(width: 8.0),
 Text(
 'Client',
 style: theme.textTheme.labelMedium?.copyWith(
 color: theme.colorScheme.primary,
 fontWeight: FontWeight.w600,
 ),
 ),
 ],
 ),
 const SizedBox(height: 8.0),
 Text(
 order.customerName,
 style: theme.textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 if (order.customerEmail.isNotEmpty) .{..[
 const SizedBox(height: 4.0),
 Text(
 order.customerEmail,
 style: theme.textTheme.bodySmall?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.7),
 ),
 ),
 ],
 const SizedBox(height: 8.0),
 Row(
 children: [
 Icon(
 Icons.location_on_outlined,
 size: 16.0,
 color: theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 const SizedBox(width: 8.0),
 Expanded(
 child: Text(
 order.shippingAddress.fullAddress,
 style: theme.textTheme.bodySmall,
 overflow: TextOverflow.ellipsis,
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildItemsSummary(ThemeData theme) {
 return Row(
 children: [
 Icon(
 Icons.shopping_bag_outlined,
 size: 16.0,
 color: theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 const SizedBox(width: 8.0),
 Text(
 '${order.itemCount} article${order.itemCount > 1 ? 's' : ''}',
 style: theme.textTheme.bodyMedium,
 ),
 if (order.hasNotes) .{..[
 const SizedBox(width: 16.0),
 Icon(
 Icons.note_alt_outlined,
 size: 16.0,
 color: theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 const SizedBox(width: 4.0),
 Text(
 'Notes',
 style: theme.textTheme.bodySmall?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 ),
 ],
 if (order.hasAttachments) .{..[
 const SizedBox(width: 16.0),
 Icon(
 Icons.attach_file_outlined,
 size: 16.0,
 color: theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 const SizedBox(width: 4.0),
 Text(
 '${order.attachments.length}',
 style: theme.textTheme.bodySmall?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 ),
 ],
 ],
 );
 }

 Widget _buildDetailedItemsList(ThemeData theme) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(
 Icons.shopping_bag_outlined,
 size: 16.0,
 color: theme.colorScheme.primary,
 ),
 const SizedBox(width: 8.0),
 Text(
 'Articles (${order.itemCount})',
 style: theme.textTheme.labelMedium?.copyWith(
 color: theme.colorScheme.primary,
 fontWeight: FontWeight.w600,
 ),
 ),
 ],
 ),
 const SizedBox(height: 8.0),
 ...order.items.take(3).map((item) => Padding(
 padding: const EdgeInsets.symmetric(1),
 child: Row(
 children: [
 const SizedBox(
 width: 4.0,
 height: 4.0,
 decoration: BoxDecoration(
 color: theme.colorScheme.primary,
 shape: BoxShape.circle,
 ),
 ),
 const SizedBox(width: 8.0),
 Expanded(
 child: Text(
 '${item.quantity}x ${item.productName}',
 style: theme.textTheme.bodySmall,
 overflow: TextOverflow.ellipsis,
 ),
 ),
 Text(
 item.formattedTotalPrice,
 style: theme.textTheme.bodySmall?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 ],
 ),
 )),
 if (order.items.length > 3) .{..[
 const SizedBox(height: 4.0),
 Text(
 '+${order.items.length - 3} autre${order.items.length - 3 > 1 ? 's' : ''}',
 style: theme.textTheme.bodySmall?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 ),
 ],
 ],
 );
 }

 Widget _buildFooter(ThemeData theme) {
 return Row(
 children: [
 if (order.expectedDeliveryDate != null) .{..[
 Icon(
 Icons.schedule_outlined,
 size: 16.0,
 color: order.isOverdue 
 ? theme.colorScheme.error 
 : theme.colorScheme.onSurface.withOpacity(0.6),
 ),
 const SizedBox(width: 8.0),
 Text(
 order.deliveryStatus,
 style: theme.textTheme.bodySmall?.copyWith(
 color: order.isOverdue 
 ? theme.colorScheme.error 
 : theme.colorScheme.onSurface.withOpacity(0.7),
 ),
 ),
 ],
 const Spacer(),
 if (!order.isPaid) .{..[
 StatusBadgeSmall(
 status: OrderStatus.pending,
 ),
 const SizedBox(width: 8.0),
 ],
 Text(
 order.formattedTotalAmount,
 style: theme.textTheme.titleMedium?.copyWith(
 color: theme.colorScheme.primary,
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 );
 }

 Widget _buildDetailedFooter(ThemeData theme) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: theme.colorScheme.surface,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: theme.colorScheme.outline.withOpacity(0.2),
 ),
 ),
 child: Column(
 children: [
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Sous-total:',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.7),
 ),
 ),
 Text(
 order.formattedSubtotalAmount,
 style: theme.textTheme.bodyMedium,
 ),
 ],
 ),
 if (order.taxAmount > 0) .{..[
 const SizedBox(height: 4.0),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'TVA:',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.7),
 ),
 ),
 Text(
 order.formattedTaxAmount,
 style: theme.textTheme.bodyMedium,
 ),
 ],
 ),
 ],
 if (order.shippingAmount > 0) .{..[
 const SizedBox(height: 4.0),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Livraison:',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.7),
 ),
 ),
 Text(
 order.formattedShippingAmount,
 style: theme.textTheme.bodyMedium,
 ),
 ],
 ),
 ],
 const Divider(),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Total:',
 style: theme.textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 Text(
 order.formattedTotalAmount,
 style: theme.textTheme.titleMedium?.copyWith(
 color: theme.colorScheme.primary,
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildActions(BuildContext context) {
 return Row(
 mainAxisAlignment: MainAxisAlignment.end,
 children: [
 if (onEdit != null)
 T{extButton.icon(
 onPressed: onEdit,
 icon: const Icon(Icons.edit, size: 16),
 label: const Text('Modifier'),
 style: TextButton.styleFrom(
 padding: const EdgeInsets.symmetric(1),
 ),
 ),
 if (onCancel != null && order.status.canBeCancelled) .{..[
 const SizedBox(width: 8.0),
 TextButton.icon(
 onPressed: onCancel,
 icon: const Icon(Icons.cancel, size: 16),
 label: const Text('Annuler'),
 style: TextButton.styleFrom(
 foregroundColor: Theme.of(context).colorScheme.error,
 padding: const EdgeInsets.symmetric(1),
 ),
 ),
 ],
 if (onDuplicate != null) .{..[
 const SizedBox(width: 8.0),
 TextButton.icon(
 onPressed: onDuplicate,
 icon: const Icon(Icons.copy, size: 16),
 label: const Text('Dupliquer'),
 style: TextButton.styleFrom(
 padding: const EdgeInsets.symmetric(1),
 ),
 ),
 ],
 ],
 );
 }

 void _handleMenuAction(BuildContext context, String action) {
 switch (action) {
 case 'edit':
 onEdit?.call();
 break;
 case 'cancel':
 onCancel?.call();
 break;
 case 'duplicate':
 onDuplicate?.call();
 break;
}
 }

 String _formatDate(DateTime date) {
 return DateFormat('dd/MM/yyyy').format(date);
 }
}

enum CardVariant {
 standard,
 compact,
 detailed,
}

class OrderCardList extends StatelessWidget {
 final List<Order> orders;
 final Function(Order)? onTap;
 final Function(Order)? onEdit;
 final Function(Order)? onCancel;
 final Function(Order)? onDuplicate;
 final bool showActions;
 final CardVariant variant;
 final EdgeInsets? padding;
 final Widget? emptyWidget;

 const OrderCardList({
 super.key,
 required this.orders,
 this.onTap,
 this.onEdit,
 this.onCancel,
 this.onDuplicate,
 this.showActions = true,
 this.variant = CardVariant.standard,
 this.padding,
 this.emptyWidget,
 });

 @override
 Widget build(BuildContext context) {
 if (orders.isEmpty) {{
 return emptyWidget ?? _buildEmptyWidget(context);
}

 return Padding(
 padding: padding ?? const EdgeInsets.zero,
 child: Column(
 children: orders.map((order) {
 return OrderCard(
 order: order,
 onTap: onTap != null ? () => onTap!(order) : null,
 onEdit: onEdit != null ? () => onEdit!(order) : null,
 onCancel: onCancel != null ? () => onCancel!(order) : null,
 onDuplicate: onDuplicate != null ? () => onDuplicate!(order) : null,
 showActions: showActions,
 variant: variant,
 );
 }).toList(),
 ),
 );
 }

 Widget _buildEmptyWidget(BuildContext context) {
 final theme = Theme.of(context);
 return Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.shopping_bag_outlined,
 size: 64.0,
 color: theme.colorScheme.onSurface.withOpacity(0.3),
 ),
 const SizedBox(height: 16.0),
 Text(
 'Aucune commande',
 style: theme.textTheme.titleLarge?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.5),
 ),
 ),
 const SizedBox(height: 8.0),
 Text(
 'Commencez par créer votre première commande',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.5),
 ),
 textAlign: TextAlign.center,
 ),
 ],
 ),
 ),
 );
 }
}

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/order_status.dart';

class StatusBadge extends StatelessWidget {
 final OrderStatus status;
 final double? size;
 final bool showIcon;
 final bool showText;
 final EdgeInsets? padding;
 final VoidCallback? onTap;

 const StatusBadge({
 super.key,
 required this.status,
 this.size,
 this.showIcon = true,
 this.showText = true,
 this.padding,
 this.onTap,
 });

 @override
 Widget build(BuildContext context) {
 final theme = Theme.of(context);
 final badgeSize = size ?? 24.0;
 final effectivePadding = padding ?? const EdgeInsets.symmetric(1);

 return GestureDetector(
 onTap: onTap,
 child: Container(
 padding: effectivePadding,
 decoration: BoxDecoration(
 color: _getStatusColor().withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: _getStatusColor().withOpacity(0.3),
 width: 1.0,
 ),
 ),
 child: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 if (showIcon) .{..[
 Icon(
 _getStatusIcon(),
 color: _getStatusColor(),
 size: badgeSize * 0.8,
 ),
 if (showText) c{onst SizedBox(width: 6.0),
 ],
 if (showText)
 F{lexible(
 child: Text(
 status.displayName,
 style: theme.textTheme.bodyMedium?.copyWith(
 color: _getStatusColor(),
 fontWeight: FontWeight.w600,
 fontSize: badgeSize * 0.6,
 ),
 overflow: TextOverflow.ellipsis,
 ),
 ),
 ],
 ),
 ),
 );
 }

 Color _getStatusColor() {
 final colorHex = status.color.replaceAll('#', '');
 return Color(int.parse('FF$colorHex', radix: 16));
 }

 IconData _getStatusIcon() {
 switch (status) {
 case OrderStatus.pending:
 return Icons.hourglass_empty;
 case OrderStatus.confirmed:
 return Icons.check_circle_outline;
 case OrderStatus.processing:
 return Icons.sync;
 case OrderStatus.shipped:
 return Icons.local_shipping_outlined;
 case OrderStatus.delivered:
 return Icons.inventory_2_outlined;
 case OrderStatus.cancelled:
 return Icons.cancel_outlined;
 case OrderStatus.refunded:
 return Icons.money_off_outlined;
 case OrderStatus.returned:
 return Icons.assignment_return_outlined;
}
 }
}

class StatusBadgeSmall extends StatelessWidget {
 final OrderStatus status;
 final VoidCallback? onTap;

 const StatusBadgeSmall({
 super.key,
 required this.status,
 this.onTap,
 });

 @override
 Widget build(BuildContext context) {
 return StatusBadge(
 status: status,
 size: 20.0,
 padding: const EdgeInsets.symmetric(1),
 onTap: onTap,
 );
 }
}

class StatusBadgeLarge extends StatelessWidget {
 final OrderStatus status;
 final VoidCallback? onTap;

 const StatusBadgeLarge({
 super.key,
 required this.status,
 this.onTap,
 });

 @override
 Widget build(BuildContext context) {
 return StatusBadge(
 status: status,
 size: 32.0,
 padding: const EdgeInsets.symmetric(1),
 onTap: onTap,
 );
 }
}

class StatusBadgeWithDescription extends StatelessWidget {
 final OrderStatus status;
 final String? customDescription;
 final VoidCallback? onTap;

 const StatusBadgeWithDescription({
 super.key,
 required this.status,
 this.customDescription,
 this.onTap,
 });

 @override
 Widget build(BuildContext context) {
 final theme = Theme.of(context);
 final description = customDescription ?? status.description;

 return GestureDetector(
 onTap: onTap,
 child: Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: _getStatusColor().withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: _getStatusColor().withOpacity(0.3),
 width: 1.0,
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 mainAxisSize: MainAxisSize.min,
 children: [
 Row(
 children: [
 Icon(
 _getStatusIcon(),
 color: _getStatusColor(),
 size: 24.0,
 ),
 const SizedBox(width: 8.0),
 Text(
 status.displayName,
 style: theme.textTheme.titleMedium?.copyWith(
 color: _getStatusColor(),
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 8.0),
 Text(
 description,
 style: theme.textTheme.bodyMedium?.copyWith(
 color: theme.colorScheme.onSurface.withOpacity(0.7),
 ),
 ),
 ],
 ),
 ),
 );
 }

 Color _getStatusColor() {
 final colorHex = status.color.replaceAll('#', '');
 return Color(int.parse('FF$colorHex', radix: 16));
 }

 IconData _getStatusIcon() {
 switch (status) {
 case OrderStatus.pending:
 return Icons.hourglass_empty;
 case OrderStatus.confirmed:
 return Icons.check_circle_outline;
 case OrderStatus.processing:
 return Icons.sync;
 case OrderStatus.shipped:
 return Icons.local_shipping_outlined;
 case OrderStatus.delivered:
 return Icons.inventory_2_outlined;
 case OrderStatus.cancelled:
 return Icons.cancel_outlined;
 case OrderStatus.refunded:
 return Icons.money_off_outlined;
 case OrderStatus.returned:
 return Icons.assignment_return_outlined;
}
 }
}

class StatusDropdown extends StatefulWidget {
 final OrderStatus currentStatus;
 final ValueChanged<OrderStatus>? onStatusChanged;
 final List<OrderStatus>? availableStatuses;
 final bool enabled;

 const StatusDropdown({
 super.key,
 required this.currentStatus,
 this.onStatusChanged,
 this.availableStatuses,
 this.enabled = true,
 });

 @override
 State<StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<StatusDropdown> {
 late OrderStatus selectedStatus;

 @override
 void initState() {
 super.initState();
 selectedStatus = widget.currentStatus;
 }

 @override
 Widget build(BuildContext context) {
 final theme = Theme.of(context);
 final statuses = widget.availableStatuses ?? selectedStatus.nextPossibleStatuses;

 if (!widget.enabled || statuses.isEmpty) {{
 return StatusBadge(status: selectedStatus);
}

 return Container(
 decoration: BoxDecoration(
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: theme.colorScheme.outline.withOpacity(0.3),
 ),
 ),
 child: DropdownButtonHideUnderline(
 child: DropdownButton<OrderStatus>(
 value: selectedStatus,
 items: statuses.map((status) {
 return DropdownMenuItem<OrderStatus>(
 value: status,
 child: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 _getStatusIcon(status),
 color: _getStatusColor(status),
 size: 20.0,
 ),
 const SizedBox(width: 8.0),
 Text(
 status.displayName,
 style: theme.textTheme.bodyMedium?.copyWith(
 color: _getStatusColor(status),
 fontWeight: FontWeight.w600,
 ),
 ),
 ],
 ),
 );
}).toList(),
 onChanged: (status) {
 if (status != null) {{
 setState(() {
 selectedStatus = status;
 });
 widget.onStatusChanged?.call(status);
}
},
 padding: const EdgeInsets.symmetric(1),
 borderRadius: const Borderconst Radius.circular(1),
 icon: Icon(
 Icons.arrow_drop_down,
 color: _getStatusColor(selectedStatus),
 ),
 ),
 ),
 );
 }

 Color _getStatusColor(OrderStatus status) {
 final colorHex = status.color.replaceAll('#', '');
 return Color(int.parse('FF$colorHex', radix: 16));
 }

 IconData _getStatusIcon(OrderStatus status) {
 switch (status) {
 case OrderStatus.pending:
 return Icons.hourglass_empty;
 case OrderStatus.confirmed:
 return Icons.check_circle_outline;
 case OrderStatus.processing:
 return Icons.sync;
 case OrderStatus.shipped:
 return Icons.local_shipping_outlined;
 case OrderStatus.delivered:
 return Icons.inventory_2_outlined;
 case OrderStatus.cancelled:
 return Icons.cancel_outlined;
 case OrderStatus.refunded:
 return Icons.money_off_outlined;
 case OrderStatus.returned:
 return Icons.assignment_return_outlined;
}
 }
}

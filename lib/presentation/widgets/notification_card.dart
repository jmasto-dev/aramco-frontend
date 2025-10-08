import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/notification.dart' as app_notification;

class NotificationCard extends StatelessWidget {
 final app_notification.Notification notification;
 final VoidCallback? onTap;
 final VoidCallback? onMarkAsRead;
 final VoidCallback? onDelete;

 const NotificationCard({
 Key? key,
 required this.notification,
 this.onTap,
 this.onMarkAsRead,
 this.onDelete,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.only(bottom: 12),
 elevation: notification.isRead ? 1 : 3,
 color: notification.isRead ? Colors.grey[50] : Colors.white,
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: _getNotificationTypeColor().withOpacity(0.2),
 width: notification.isRead ? 1 : 2,
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête avec icône, titre et actions
 Row(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Icône de notification
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: _getNotificationTypeColor().withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Icon(
 _getNotificationTypeIcon(),
 color: _getNotificationTypeColor(),
 size: 20,
 ),
 ),
 const SizedBox(width: 12),
 
 // Titre et date
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 notification.title,
 style: const TextStyle(
 fontSize: 16,
 fontWeight: notification.isRead 
 ? FontWeight.normal 
 : FontWeight.bold,
 color: notification.isRead 
 ? Colors.grey[700] 
 : Colors.black87,
 ),
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 const SizedBox(height: 4),
 Text(
 _formatDate(notification.createdAt),
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey[600],
 ),
 ),
 ],
 ),
 ),
 
 // Actions
 PopupMenuButton<String>(
 onSelected: (value) {
 switch (value) {
 case 'mark_read':
 onMarkAsRead?.call();
 break;
 case 'delete':
 onDelete?.call();
 break;
}
 },
 itemBuilder: (context) => [
 if (!notification.isRead)
 c{onst PopupMenuItem(
 value: 'mark_read',
 child: Row(
 children: [
 Icon(Icons.mark_email_read, size: 16),
 const SizedBox(width: 8),
 Text('Marquer comme lu'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'delete',
 child: Row(
 children: [
 Icon(Icons.delete, size: 16),
 const SizedBox(width: 8),
 Text('Supprimer'),
 ],
 ),
 ),
 ],
 child: const Icon(
 Icons.more_vert,
 color: Colors.grey,
 ),
 ),
 ],
 ),
 
 const SizedBox(height: 12),
 
 // Message
 Text(
 notification.message,
 style: const TextStyle(
 fontSize: 14,
 color: notification.isRead 
 ? Colors.grey[600] 
 : Colors.black87,
 height: 1.4,
 ),
 maxLines: 3,
 overflow: TextOverflow.ellipsis,
 ),
 
 // Badge de type
 const SizedBox(height: 12),
 Row(
 children: [
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: _getNotificationTypeColor().withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: _getNotificationTypeColor().withOpacity(0.3),
 ),
 ),
 child: Text(
 _getNotificationTypeLabel(),
 style: const TextStyle(
 fontSize: 11,
 color: _getNotificationTypeColor(),
 fontWeight: FontWeight.w500,
 ),
 ),
 ),
 
 if (!notification.isRead) .{..[
 const SizedBox(width: 8),
 const SizedBox(
 width: 8,
 height: 8,
 decoration: BoxDecoration(
 color: _getNotificationTypeColor(),
 shape: BoxShape.circle,
 ),
 ),
 ],
 
 const Spacer(),
 
 if (notification.actionUrl != null)
 I{con(
 Icons.arrow_forward,
 size: 16,
 color: Colors.grey[400],
 ),
 ],
 ),
 ],
 ),
 ),
 ),
 );
 }

 Color _getNotificationTypeColor() {
 switch (notification.type.toLowerCase()) {
 case 'info':
 return Colors.blue;
 case 'success':
 return Colors.green;
 case 'warning':
 return Colors.orange;
 case 'error':
 return Colors.red;
 case 'system':
 return Colors.purple;
 case 'hr':
 return Colors.teal;
 case 'order':
 return Colors.indigo;
 case 'finance':
 return Colors.amber[700]!;
 default:
 return Colors.grey;
}
 }

 IconData _getNotificationTypeIcon() {
 switch (notification.type.toLowerCase()) {
 case 'info':
 return Icons.info_outline;
 case 'success':
 return Icons.check_circle_outline;
 case 'warning':
 return Icons.warning_amber_outlined;
 case 'error':
 return Icons.error_outline;
 case 'system':
 return Icons.settings_outlined;
 case 'hr':
 return Icons.people_outline;
 case 'order':
 return Icons.shopping_cart_outlined;
 case 'finance':
 return Icons.account_balance_wallet_outlined;
 default:
 return Icons.notifications_outlined;
}
 }

 String _getNotificationTypeLabel() {
 switch (notification.type.toLowerCase()) {
 case 'info':
 return 'Information';
 case 'success':
 return 'Succès';
 case 'warning':
 return 'Attention';
 case 'error':
 return 'Erreur';
 case 'system':
 return 'Système';
 case 'hr':
 return 'RH';
 case 'order':
 return 'Commande';
 case 'finance':
 return 'Finance';
 default:
 return 'Notification';
}
 }

 String _formatDate(DateTime date) {
 final now = DateTime.now();
 final difference = now.difference(date);

 if (difference.inDays == 0) {{
 if (difference.inHours == 0) {{
 if (difference.inMinutes == 0) {{
 return 'À l\'instant';
 }
 return 'Il y a ${difference.inMinutes} min';
 }
 return 'Il y a ${difference.inHours}h';
} else if (difference.inDays == 1) {{
 return 'Hier';
} else if (difference.inDays < 7) {{
 return 'Il y a ${difference.inDays} jours';
} else {
 return '${date.day}/${date.month}/${date.year}';
}
 }
}

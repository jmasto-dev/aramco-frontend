import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/services/search_service.dart';

class SearchResultItem extends StatelessWidget {
 final SearchResult result;
 final VoidCallback? onTap;

 const SearchResultItem({
 Key? key,
 required this.result,
 this.onTap,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.only(bottom: 12),
 elevation: 2,
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: _getTypeColor().withOpacity(0.2),
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête avec icône, titre et type
 Row(
 children: [
 // Icône du type
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: _getTypeColor().withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Icon(
 _getTypeIcon(),
 color: _getTypeColor(),
 size: 20,
 ),
 ),
 const SizedBox(width: 12),
 
 // Titre et type
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 result.title,
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w600,
 ),
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 const SizedBox(height: 4),
 Row(
 children: [
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: _getTypeColor().withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 _getTypeLabel(),
 style: const TextStyle(
 fontSize: 11,
 color: _getTypeColor(),
 fontWeight: FontWeight.w500,
 ),
 ),
 ),
 const SizedBox(width: 8),
 Text(
 _formatDate(result.createdAt),
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
 
 // Flèche de navigation
 Icon(
 Icons.arrow_forward_ios,
 size: 16,
 color: Colors.grey[400],
 ),
 ],
 ),
 
 // Sous-titre
 if (result.subtitle != null) .{..[
 const SizedBox(height: 8),
 Text(
 result.subtitle!,
 style: const TextStyle(
 fontSize: 14,
 color: Colors.grey[700],
 fontWeight: FontWeight.w500,
 ),
 maxLines: 1,
 overflow: TextOverflow.ellipsis,
 ),
 ],
 
 // Description
 if (result.description != null) .{..[
 const SizedBox(height: 8),
 Text(
 result.description!,
 style: const TextStyle(
 fontSize: 14,
 color: Colors.grey[600],
 height: 1.4,
 ),
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 ],
 
 // Métadonnées
 if (result.metadata != null && result.metadata!.isNotEmpty) .{..[
 const SizedBox(height: 12),
 _buildMetadataRow(),
 ],
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildMetadataRow() {
 final metadata = result.metadata!;
 final List<Widget> metadataWidgets = [];

 // Ajouter les métadonnées importantes selon le type
 switch (result.type.toLowerCase()) {
 case 'employee':
 if (metadata['department'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.business,
 metadata['department'],
 ));
 }
 if (metadata['position'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.work,
 metadata['position'],
 ));
 }
 break;
 
 case 'order':
 if (metadata['status'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.info_outline,
 metadata['status'],
 ));
 }
 if (metadata['total'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.attach_money,
 metadata['total'],
 ));
 }
 break;
 
 case 'product':
 if (metadata['category'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.category,
 metadata['category'],
 ));
 }
 if (metadata['price'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.attach_money,
 metadata['price'],
 ));
 }
 break;
 
 case 'leave_request':
 if (metadata['type'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.event,
 metadata['type'],
 ));
 }
 if (metadata['status'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.info_outline,
 metadata['status'],
 ));
 }
 break;
 
 case 'payslip':
 if (metadata['month'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.calendar_today,
 metadata['month'],
 ));
 }
 if (metadata['net_salary'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.attach_money,
 metadata['net_salary'],
 ));
 }
 break;
 
 case 'supplier':
 if (metadata['category'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.category,
 metadata['category'],
 ));
 }
 if (metadata['city'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.location_on,
 metadata['city'],
 ));
 }
 break;
 
 case 'purchase_request':
 if (metadata['status'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.info_outline,
 metadata['status'],
 ));
 }
 if (metadata['total'] != null) {{
 metadataWidgets.add(_buildMetadataChip(
 Icons.attach_money,
 metadata['total'],
 ));
 }
 break;
}

 return Wrap(
 spacing: 8,
 runSpacing: 4,
 children: metadataWidgets,
 );
 }

 Widget _buildMetadataChip(IconData icon, String value) {
 return Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: Colors.grey[100],
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 icon,
 size: 12,
 color: Colors.grey[600],
 ),
 const SizedBox(width: 4),
 Text(
 value,
 style: const TextStyle(
 fontSize: 11,
 color: Colors.grey[700],
 fontWeight: FontWeight.w500,
 ),
 ),
 ],
 ),
 );
 }

 Color _getTypeColor() {
 switch (result.type.toLowerCase()) {
 case 'employee':
 return Colors.blue;
 case 'order':
 return Colors.green;
 case 'product':
 return Colors.orange;
 case 'supplier':
 return Colors.purple;
 case 'leave_request':
 return Colors.teal;
 case 'payslip':
 return Colors.indigo;
 case 'performance_review':
 return Colors.amber[700]!;
 case 'purchase_request':
 return Colors.red;
 case 'report':
 return Colors.brown;
 case 'notification':
 return Colors.cyan;
 default:
 return Colors.grey;
}
 }

 IconData _getTypeIcon() {
 switch (result.type.toLowerCase()) {
 case 'employee':
 return Icons.person;
 case 'order':
 return Icons.shopping_cart;
 case 'product':
 return Icons.inventory_2;
 case 'supplier':
 return Icons.business;
 case 'leave_request':
 return Icons.event;
 case 'payslip':
 return Icons.attach_money;
 case 'performance_review':
 return Icons.star;
 case 'purchase_request':
 return Icons.receipt;
 case 'report':
 return Icons.assessment;
 case 'notification':
 return Icons.notifications;
 default:
 return Icons.description;
}
 }

 String _getTypeLabel() {
 switch (result.type.toLowerCase()) {
 case 'employee':
 return 'Employé';
 case 'order':
 return 'Commande';
 case 'product':
 return 'Produit';
 case 'supplier':
 return 'Fournisseur';
 case 'leave_request':
 return 'Congé';
 case 'payslip':
 return 'Paie';
 case 'performance_review':
 return 'Évaluation';
 case 'purchase_request':
 return 'Achat';
 case 'report':
 return 'Rapport';
 case 'notification':
 return 'Notification';
 default:
 return result.type;
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
} else if (difference.inDays < 30) {{
 return 'Il y a ${difference.inDays ~/ 7} sem';
} else if (difference.inDays < 365) {{
 return 'Il y a ${difference.inDays ~/ 30} mois';
} else {
 return 'Il y a ${difference.inDays ~/ 365} an${difference.inDays ~/ 365 > 1 ? 's' : ''}';
}
 }
}

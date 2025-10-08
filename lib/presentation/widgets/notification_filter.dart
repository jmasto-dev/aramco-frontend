import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class NotificationFilter extends StatefulWidget {
 final String selectedType;
 final Function(String) onTypeChanged;

 const NotificationFilter({
 Key? key,
 required this.selectedType,
 required this.onTypeChanged,
 }) : super(key: key);

 @override
 State<NotificationFilter> createState() => _NotificationFilterState();
}

class _NotificationFilterState extends State<NotificationFilter> {
 final ScrollController _scrollController = ScrollController();

 final List<Map<String, dynamic>> _filterTypes = [
 {
 'value': 'all',
 'label': 'Toutes',
 'icon': Icons.notifications,
 'color': Colors.grey,
},
 {
 'value': 'info',
 'label': 'Info',
 'icon': Icons.info_outline,
 'color': Colors.blue,
},
 {
 'value': 'success',
 'label': 'Succès',
 'icon': Icons.check_circle_outline,
 'color': Colors.green,
},
 {
 'value': 'warning',
 'label': 'Attention',
 'icon': Icons.warning_amber_outlined,
 'color': Colors.orange,
},
 {
 'value': 'error',
 'label': 'Erreur',
 'icon': Icons.error_outline,
 'color': Colors.red,
},
 {
 'value': 'system',
 'label': 'Système',
 'icon': Icons.settings_outlined,
 'color': Colors.purple,
},
 {
 'value': 'hr',
 'label': 'RH',
 'icon': Icons.people_outline,
 'color': Colors.teal,
},
 {
 'value': 'order',
 'label': 'Commande',
 'icon': Icons.shopping_cart_outlined,
 'color': Colors.indigo,
},
 {
 'value': 'finance',
 'label': 'Finance',
 'icon': Icons.account_balance_wallet_outlined,
 'color': Colors.amber[700],
},
 ];

 @override
 void dispose() {
 _scrollController.dispose();
 super.dispose();
 }

 @override
 Widget build(BuildContext context) {
 return Container(
 height: 60,
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 border: Border(
 bottom: BorderSide(
 color: Colors.grey[300]!,
 width: 1,
 ),
 ),
 ),
 child: ListView.builder(
 controller: _scrollController,
 scrollDirection: Axis.horizontal,
 padding: const EdgeInsets.symmetric(1),
 itemCount: _filterTypes.length,
 itemBuilder: (context, index) {
 final filterType = _filterTypes[index];
 final isSelected = widget.selectedType == filterType['value'];
 
 return Container(
 margin: const EdgeInsets.only(right: 8),
 child: FilterChip(
 label: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 filterType['icon'] as IconData,
 size: 16,
 color: isSelected 
 ? Colors.white 
 : filterType['color'] as Color,
 ),
 const SizedBox(width: 6),
 Text(
 filterType['label'] as String,
 style: const TextStyle(
 color: isSelected 
 ? Colors.white 
 : Colors.grey[700],
 fontWeight: isSelected 
 ? FontWeight.w600 
 : FontWeight.normal,
 fontSize: 13,
 ),
 ),
 ],
 ),
 selected: isSelected,
 onSelected: (selected) {
 if (selected) {{
 widget.onTypeChanged(filterType['value'] as String);
 }
 },
 backgroundColor: Colors.white,
 selectedColor: filterType['color'] as Color,
 checkmarkColor: Colors.white,
 side: BorderSide(
 color: (filterType['color'] as Color).withOpacity(0.3),
 width: isSelected ? 2 : 1,
 ),
 shape: RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 elevation: isSelected ? 2 : 0,
 pressElevation: 4,
 ),
 );
 },
 ),
 );
 }
}

// Widget alternatif pour les filtres sous forme de boutons
class NotificationFilterButtons extends StatelessWidget {
 final String selectedType;
 final Function(String) onTypeChanged;

 const NotificationFilterButtons({
 Key? key,
 required this.selectedType,
 required this.onTypeChanged,
 }) : super(key: key);

 final List<Map<String, dynamic>> _filterTypes = const [
 {
 'value': 'all',
 'label': 'Toutes',
 'icon': Icons.notifications,
},
 {
 'value': 'info',
 'label': 'Info',
 'icon': Icons.info_outline,
},
 {
 'value': 'success',
 'label': 'Succès',
 'icon': Icons.check_circle_outline,
},
 {
 'value': 'warning',
 'label': 'Attention',
 'icon': Icons.warning_amber_outlined,
},
 {
 'value': 'error',
 'label': 'Erreur',
 'icon': Icons.error_outline,
},
 ];

 @override
 Widget build(BuildContext context) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: Colors.grey[300]!,
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Filtrer par type',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w600,
 color: Colors.grey[800],
 ),
 ),
 const SizedBox(height: 12),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: _filterTypes.map((filterType) {
 final isSelected = selectedType == filterType['value'];
 
 return OutlinedButton.icon(
 onPressed: () => onTypeChanged(filterType['value'] as String),
 icon: Icon(
 filterType['icon'] as IconData,
 size: 16,
 ),
 label: Text(filterType['label'] as String),
 style: OutlinedButton.styleFrom(
 backgroundColor: isSelected 
 ? Theme.of(context).colorScheme.primary 
 : Colors.transparent,
 foregroundColor: isSelected 
 ? Colors.white 
 : Colors.grey[700],
 side: BorderSide(
 color: isSelected 
 ? Theme.of(context).colorScheme.primary 
 : Colors.grey[300]!,
 ),
 shape: RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 padding: const EdgeInsets.symmetric(1),
 ),
 );
}).toList(),
 ),
 ],
 ),
 );
 }
}

// Widget pour les filtres avancés
class AdvancedNotificationFilter extends StatefulWidget {
 final String selectedType;
 final String? dateRange;
 final bool unreadOnly;
 final Function(String) onTypeChanged;
 final Function(String?) onDateRangeChanged;
 final Function(bool) onUnreadOnlyChanged;

 const AdvancedNotificationFilter({
 Key? key,
 required this.selectedType,
 this.dateRange,
 this.unreadOnly = false,
 required this.onTypeChanged,
 required this.onDateRangeChanged,
 required this.onUnreadOnlyChanged,
 }) : super(key: key);

 @override
 State<AdvancedNotificationFilter> createState() => _AdvancedNotificationFilterState();
}

class _AdvancedNotificationFilterState extends State<AdvancedNotificationFilter> {
 final List<Map<String, dynamic>> _filterTypes = [
 {'value': 'all', 'label': 'Toutes'},
 {'value': 'info', 'label': 'Information'},
 {'value': 'success', 'label': 'Succès'},
 {'value': 'warning', 'label': 'Attention'},
 {'value': 'error', 'label': 'Erreur'},
 {'value': 'system', 'label': 'Système'},
 {'value': 'hr', 'label': 'RH'},
 {'value': 'order', 'label': 'Commande'},
 {'value': 'finance', 'label': 'Finance'},
 ];

 final List<Map<String, dynamic>> _dateRanges = [
 {'value': null, 'label': 'Toutes les dates'},
 {'value': 'today', 'label': "Aujourd'hui"},
 {'value': 'yesterday', 'label': 'Hier'},
 {'value': 'week', 'label': 'Cette semaine'},
 {'value': 'month', 'label': 'Ce mois'},
 {'value': 'quarter', 'label': 'Ce trimestre'},
 {'value': 'year', 'label': 'Cette année'},
 ];

 @override
 Widget build(BuildContext context) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: Colors.grey[300]!,
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Type de notification
 Text(
 'Type de notification',
 style: const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.w600,
 color: Colors.grey[800],
 ),
 ),
 const SizedBox(height: 8),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: _filterTypes.map((filterType) {
 final isSelected = widget.selectedType == filterType['value'];
 
 return FilterChip(
 label: Text(filterType['label'] as String),
 selected: isSelected,
 onSelected: (selected) {
 if (selected) {{
 widget.onTypeChanged(filterType['value'] as String);
 }
 },
 backgroundColor: Colors.white,
 selectedColor: Theme.of(context).colorScheme.primary,
 checkmarkColor: Colors.white,
 );
}).toList(),
 ),
 
 const SizedBox(height: 16),
 
 // Plage de dates
 Text(
 'Plage de dates',
 style: const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.w600,
 color: Colors.grey[800],
 ),
 ),
 const SizedBox(height: 8),
 DropdownButtonFormField<String>(
 value: widget.dateRange,
 decoration: const InputDecoration(
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: _dateRanges.map((dateRange) {
 return DropdownMenuItem<String>(
 value: dateRange['value'] as String?,
 child: Text(dateRange['label'] as String),
 );
}).toList(),
 onChanged: (value) {
 widget.onDateRangeChanged(value);
},
 ),
 
 const SizedBox(height: 16),
 
 // Filtre non lu uniquement
 Row(
 children: [
 Checkbox(
 value: widget.unreadOnly,
 onChanged: (value) {
 widget.onUnreadOnlyChanged(value ?? false);
 },
 activeColor: Theme.of(context).colorScheme.primary,
 ),
 const SizedBox(width: 8),
 Text(
 'Notifications non lues uniquement',
 style: const TextStyle(
 fontSize: 14,
 color: Colors.grey[700],
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }
}

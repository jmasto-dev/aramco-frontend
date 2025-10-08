import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/leave_request.dart';

class LeaveTypeSelector extends ConsumerStatefulWidget {
 final LeaveType? selectedType;
 final ValueChanged<LeaveType?> onTypeSelected;
 final bool enabled;
 final String? label;
 final bool showDescriptions;
 final bool showIcons;

 const LeaveTypeSelector({
 super.key,
 this.selectedType,
 required this.onTypeSelected,
 this.enabled = true,
 this.label,
 this.showDescriptions = true,
 this.showIcons = true,
 });

 @override
 ConsumerState<LeaveTypeSelector> createState() => _LeaveTypeSelectorState();
}

class _LeaveTypeSelectorState extends ConsumerState<LeaveTypeSelector> {
 @override
 Widget build(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 if (widget.label != null) .{..[
 Text(
 widget.label!,
 style: theme.textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 color: colorScheme.onSurface,
 ),
 ),
 const SizedBox(height: 12),
 ],
 _buildTypeGrid(context),
 ],
 );
 }

 Widget _buildTypeGrid(BuildContext context) {
 final leaveTypes = LeaveType.values;
 
 return GridView.builder(
 shrinkWrap: true,
 physics: const NeverScrollableScrollPhysics(),
 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
 crossAxisCount: 2,
 childAspectRatio: 2.5,
 crossAxisSpacing: 12,
 mainAxisSpacing: 12,
 ),
 itemCount: leaveTypes.length,
 itemBuilder: (context, index) {
 final type = leaveTypes[index];
 final isSelected = widget.selectedType == type;
 
 return _buildTypeCard(context, type, isSelected);
 },
 );
 }

 Widget _buildTypeCard(BuildContext context, LeaveType type, bool isSelected) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return InkWell(
 onTap: widget.enabled ? () => widget.onTypeSelected(type) : null,
 borderRadius: const Borderconst Radius.circular(1),
 child: Container(
 decoration: BoxDecoration(
 color: isSelected 
 ? colorScheme.primaryContainer
 : colorScheme.surface,
 border: Border.all(
 color: isSelected 
 ? colorScheme.primary
 : colorScheme.outline.withOpacity(0.3),
 width: isSelected ? 2 : 1,
 ),
 borderRadius: const Borderconst Radius.circular(1),
 boxShadow: isSelected 
 ? [
 BoxShadow(
 color: colorScheme.primary.withOpacity(0.2),
 blurRadius: 8,
 offset: const Offset(0, 2),
 ),
 ]
 : null,
 ),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Row(
 children: [
 if (widget.showIcons) .{..[
 _buildTypeIcon(context, type, isSelected),
 const SizedBox(width: 12),
 ],
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Text(
 type.displayName,
 style: theme.textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w600,
 color: isSelected 
 ? colorScheme.onPrimaryContainer
 : colorScheme.onSurface,
 ),
 maxLines: 1,
 overflow: TextOverflow.ellipsis,
 ),
 if (widget.showDescriptions) .{..[
 const SizedBox(height: 2),
 Text(
 type.description,
 style: theme.textTheme.bodySmall?.copyWith(
 color: isSelected 
 ? colorScheme.onPrimaryContainer.withOpacity(0.8)
 : colorScheme.onSurface.withOpacity(0.6),
 ),
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 ],
 ],
 ),
 ),
 if (isSelected) .{..[
 Icon(
 Icons.check_circle,
 color: colorScheme.primary,
 size: 20,
 ),
 ],
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildTypeIcon(BuildContext context, LeaveType type, bool isSelected) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 IconData iconData;
 Color iconColor;

 switch (type) {
 case LeaveType.annual:
 iconData = Icons.beach_access;
 iconColor = Colors.blue;
 break;
 case LeaveType.sick:
 iconData = Icons.medical_services;
 iconColor = Colors.red;
 break;
 case LeaveType.maternity:
 iconData = Icons.pregnant_woman;
 iconColor = Colors.pink;
 break;
 case LeaveType.paternity:
 iconData = Icons.family_restroom;
 iconColor = Colors.teal;
 break;
 case LeaveType.unpaid:
 iconData = Icons.money_off;
 iconColor = Colors.grey;
 break;
 case LeaveType.bereavement:
 iconData = Icons.sentiment_very_dissatisfied;
 iconColor = Colors.brown;
 break;
 case LeaveType.emergency:
 iconData = Icons.warning;
 iconColor = Colors.orange;
 break;
 case LeaveType.training:
 iconData = Icons.school;
 iconColor = Colors.purple;
 break;
 case LeaveType.other:
 iconData = Icons.more_horiz;
 iconColor = Colors.grey;
 break;
}

 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: isSelected 
 ? colorScheme.primary.withOpacity(0.2)
 : iconconst Color.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Icon(
 iconData,
 color: isSelected 
 ? colorScheme.primary
 : iconColor,
 size: 24,
 ),
 );
 }
}

// Widget pour la sélection de la priorité
class LeavePrioritySelector extends ConsumerWidget {
 final LeavePriority? selectedPriority;
 final ValueChanged<LeavePriority?> onPrioritySelected;
 final bool enabled;
 final String? label;
 final bool showColors;

 const LeavePrioritySelector({
 super.key,
 this.selectedPriority,
 required this.onPrioritySelected,
 this.enabled = true,
 this.label,
 this.showColors = true,
 });

 @override
 Widget build(BuildContext context, WidgetRef ref) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 if (label != null) .{..[
 Text(
 label!,
 style: theme.textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 color: colorScheme.onSurface,
 ),
 ),
 const SizedBox(height: 12),
 ],
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: LeavePriority.values.map((priority) {
 final isSelected = selectedPriority == priority;
 
 return _buildPriorityChip(context, priority, isSelected);
}).toList(),
 ),
 ],
 );
 }

 Widget _buildPriorityChip(BuildContext context, LeavePriority priority, bool isSelected) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 Color chipColor;
 Color chipBackgroundColor;
 Color textColor;

 switch (priority) {
 case LeavePriority.low:
 chipColor = Colors.green;
 chipBackgroundColor = Colors.green.withOpacity(0.1);
 textColor = Colors.green;
 break;
 case LeavePriority.medium:
 chipColor = Colors.orange;
 chipBackgroundColor = Colors.orange.withOpacity(0.1);
 textColor = Colors.orange;
 break;
 case LeavePriority.high:
 chipColor = Colors.red;
 chipBackgroundColor = Colors.red.withOpacity(0.1);
 textColor = Colors.red;
 break;
 case LeavePriority.urgent:
 chipColor = Colors.purple;
 chipBackgroundColor = Colors.purple.withOpacity(0.1);
 textColor = Colors.purple;
 break;
}

 return FilterChip(
 label: Text(
 priority.displayName,
 style: theme.textTheme.bodyMedium?.copyWith(
 color: isSelected ? colorScheme.onPrimary : textColor,
 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
 ),
 ),
 selected: isSelected,
 onSelected: enabled ? (selected) {
 onPrioritySelected(selected ? priority : null);
 } : null,
 backgroundColor: showColors ? chipBackgroundColor : colorScheme.surface,
 selectedColor: showColors ? chipColor : colorScheme.primaryContainer,
 checkmarkColor: colorScheme.onPrimary,
 side: BorderSide(
 color: isSelected 
 ? (showColors ? chipColor : colorScheme.primary)
 : colorScheme.outline.withOpacity(0.3),
 width: isSelected ? 2 : 1,
 ),
 avatar: showColors ? const SizedBox(
 width: 8,
 height: 8,
 decoration: BoxDecoration(
 color: chipColor,
 shape: BoxShape.circle,
 ),
 ) : null,
 );
 }
}

// Widget pour afficher les informations sur un type de congé
class LeaveTypeInfoWidget extends StatelessWidget {
 final LeaveType leaveType;

 const LeaveTypeInfoWidget({
 super.key,
 required this.leaveType,
 });

 @override
 Widget build(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: colorScheme.primaryContainer.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: colorScheme.primary.withOpacity(0.2),
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(
 _getLeaveTypeIcon(leaveType),
 color: colorScheme.primary,
 size: 20,
 ),
 const SizedBox(width: 8),
 Text(
 leaveType.displayName,
 style: theme.textTheme.titleSmall?.copyWith(
 fontWeight: FontWeight.w600,
 color: colorScheme.primary,
 ),
 ),
 ],
 ),
 const SizedBox(height: 8),
 Text(
 leaveType.description,
 style: theme.textTheme.bodyMedium?.copyWith(
 color: colorScheme.onSurface.withOpacity(0.8),
 ),
 ),
 const SizedBox(height: 12),
 _buildInfoRow(
 context,
 'Durée maximale',
 '${leaveType.maxDays} jour${leaveType.maxDays > 1 ? 's' : ''}',
 Icons.timer_outlined,
 ),
 if (leaveType.requiresDocument) .{..[
 const SizedBox(height: 8),
 _buildInfoRow(
 context,
 'Document requis',
 'Oui',
 Icons.description_outlined,
 ),
 ],
 const SizedBox(height: 8),
 _buildInfoRow(
 context,
 'Jours payés',
 _getPaidDaysInfo(leaveType),
 Icons.attach_money_outlined,
 ),
 ],
 ),
 );
 }

 Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Row(
 children: [
 Icon(
 icon,
 size: 16,
 color: colorScheme.onSurface.withOpacity(0.6),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: Text(
 label,
 style: theme.textTheme.bodySmall?.copyWith(
 color: colorScheme.onSurface.withOpacity(0.6),
 ),
 ),
 ),
 Text(
 value,
 style: theme.textTheme.bodySmall?.copyWith(
 fontWeight: FontWeight.w600,
 color: colorScheme.onSurface,
 ),
 ),
 ],
 );
 }

 IconData _getLeaveTypeIcon(LeaveType type) {
 switch (type) {
 case LeaveType.annual:
 return Icons.beach_access;
 case LeaveType.sick:
 return Icons.medical_services;
 case LeaveType.maternity:
 return Icons.pregnant_woman;
 case LeaveType.paternity:
 return Icons.family_restroom;
 case LeaveType.unpaid:
 return Icons.money_off;
 case LeaveType.bereavement:
 return Icons.sentiment_very_dissatisfied;
 case LeaveType.emergency:
 return Icons.warning;
 case LeaveType.training:
 return Icons.school;
 case LeaveType.other:
 return Icons.more_horiz;
}
 }

 String _getPaidDaysInfo(LeaveType type) {
 switch (type) {
 case LeaveType.annual:
 case LeaveType.sick:
 case LeaveType.maternity:
 case LeaveType.paternity:
 case LeaveType.bereavement:
 case LeaveType.emergency:
 case LeaveType.training:
 return '100%';
 case LeaveType.unpaid:
 case LeaveType.other:
 return '0%';
}
 }
}

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateRangePickerWidget extends ConsumerStatefulWidget {
 final DateTime? startDate;
 final DateTime? endDate;
 final ValueChanged<DateTimeRange?> onDateRangeChanged;
 final String? startDateLabel;
 final String? endDateLabel;
 final DateTime? firstDate;
 final DateTime? lastDate;
 final bool enabled;
 final String? Function(DateTime?, DateTime?)? validator;

 const DateRangePickerWidget({
 super.key,
 this.startDate,
 this.endDate,
 required this.onDateRangeChanged,
 this.startDateLabel,
 this.endDateLabel,
 this.firstDate,
 this.lastDate,
 this.enabled = true,
 this.validator,
 });

 @override
 ConsumerState<DateRangePickerWidget> createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends ConsumerState<DateRangePickerWidget> {
 String? _errorText;

 @override
 Widget build(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Expanded(
 child: _buildDateField(
 context,
 label: widget.startDateLabel ?? 'Date de début',
 date: widget.startDate,
 onTap: widget.enabled ? () => _selectStartDate(context) : null,
 enabled: widget.enabled,
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: _buildDateField(
 context,
 label: widget.endDateLabel ?? 'Date de fin',
 date: widget.endDate,
 onTap: widget.enabled ? () => _selectEndDate(context) : null,
 enabled: widget.enabled,
 ),
 ),
 ],
 ),
 if (_errorText != null) .{..[
 const SizedBox(height: 8),
 Text(
 _errorText!,
 style: theme.textTheme.bodySmall?.copyWith(
 color: colorScheme.error,
 ),
 ),
 ],
 if (widget.startDate != null && widget.endDate != null) .{..[
 const SizedBox(height: 8),
 _buildDurationInfo(context),
 ],
 ],
 );
 }

 Widget _buildDateField(
 BuildContext context, {
 required String label,
 required DateTime? date,
 required VoidCallback? onTap,
 required bool enabled,
 }) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: InputDecorator(
 decoration: InputDecoration(
 labelText: label,
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 enabled: enabled,
 filled: true,
 fillColor: enabled 
 ? colorScheme.surface 
 : colorScheme.surface.withOpacity(0.5),
 suffixIcon: Icon(
 Icons.calendar_today,
 color: enabled 
 ? colorScheme.primary 
 : colorScheme.onSurface.withOpacity(0.38),
 ),
 ),
 child: Text(
 date != null 
 ? _formatDate(date)
 : 'Sélectionner une date',
 style: theme.textTheme.bodyLarge?.copyWith(
 color: date != null 
 ? colorScheme.onSurface 
 : colorScheme.onSurface.withOpacity(0.6),
 ),
 ),
 ),
 );
 }

 Widget _buildDurationInfo(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;
 
 final duration = widget.endDate!.difference(widget.startDate!);
 final days = duration.inDays + 1; // Inclure le jour de début

 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: colorScheme.primaryContainer.withOpacity(0.3),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: colorScheme.primary.withOpacity(0.3),
 ),
 ),
 child: Row(
 children: [
 Icon(
 Icons.info_outline,
 color: colorScheme.primary,
 size: 20,
 ),
 const SizedBox(width: 8),
 Expanded(
 child: Text(
 'Durée: $days jour${days > 1 ? 's' : ''}',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: colorScheme.primary,
 fontWeight: FontWeight.w500,
 ),
 ),
 ),
 ],
 ),
 );
 }

 Future<void> _selectStartDate(BuildContext context) {async {
 final DateTime? picked = await showDatePicker(
 context: context,
 initialDate: widget.startDate ?? DateTime.now(),
 firstDate: widget.firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
 lastDate: widget.lastDate ?? DateTime.now().add(const Duration(days: 365)),
 locale: const Locale('fr', 'FR'),
 builder: (context, child) {
 return Theme(
 data: Theme.of(context).copyWith(
 colorScheme: Theme.of(context).colorScheme.copyWith(
 primary: Theme.of(context).colorScheme.primary,
 ),
 ),
 child: child!,
 );
 },
 );

 if (picked != null) {{
 final newEndDate = widget.endDate != null && widget.endDate!.isBefore(picked)
 ? picked
 : widget.endDate;

 final dateRange = newEndDate != null 
 ? DateTimeRange(start: picked, end: newEndDate)
 : null;

 widget.onDateRangeChanged(dateRange);
 _validateDates(picked, newEndDate);
}
 }

 Future<void> _selectEndDate(BuildContext context) {async {
 final DateTime? picked = await showDatePicker(
 context: context,
 initialDate: widget.endDate ?? widget.startDate ?? DateTime.now(),
 firstDate: widget.startDate ?? DateTime.now().subtract(const Duration(days: 365)),
 lastDate: widget.lastDate ?? DateTime.now().add(const Duration(days: 365)),
 locale: const Locale('fr', 'FR'),
 builder: (context, child) {
 return Theme(
 data: Theme.of(context).copyWith(
 colorScheme: Theme.of(context).colorScheme.copyWith(
 primary: Theme.of(context).colorScheme.primary,
 ),
 ),
 child: child!,
 );
 },
 );

 if (picked != null) {{
 final dateRange = widget.startDate != null 
 ? DateTimeRange(start: widget.startDate!, end: picked)
 : null;

 widget.onDateRangeChanged(dateRange);
 _validateDates(widget.startDate, picked);
}
 }

 void _validateDates(DateTime? startDate, DateTime? endDate) {
 if (widget.validator != null) {{
 final error = widget.validator!(startDate, endDate);
 setState(() {
 _errorText = error;
 });
} else {
 // Validation par défaut
 if (startDate != null && endDate != null) {{
 if (endDate.isBefore(startDate)){ {
 setState(() {
 _errorText = 'La date de fin ne peut pas être avant la date de début';
});
 } else if (endDate.difference(startDate).{inDays > 365) {
 setState(() {
 _errorText = 'La durée maximale est de 365 jours';
});
 } else {
 setState(() {
 _errorText = null;
});
 }
 } else {
 setState(() {
 _errorText = null;
 });
 }
}
 }

 String _formatDate(DateTime date) {
 return '${date.day.toString().padLeft(2, '0')}/'
 '${date.month.toString().padLeft(2, '0')}/'
 '${date.year}';
 }
}

// Widget pour afficher un calendrier simplifié
class SimpleCalendarWidget extends StatelessWidget {
 final DateTime selectedDate;
 final ValueChanged<DateTime> onDateSelected;
 final DateTime? firstDate;
 final DateTime? lastDate;
 final List<DateTime>? disabledDates;
 final List<DateTime>? highlightedDates;

 const SimpleCalendarWidget({
 super.key,
 required this.selectedDate,
 required this.onDateSelected,
 this.firstDate,
 this.lastDate,
 this.disabledDates,
 this.highlightedDates,
 });

 @override
 Widget build(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Container(
 decoration: BoxDecoration(
 color: colorScheme.surface,
 borderRadius: const Borderconst Radius.circular(1),
 boxShadow: [
 BoxShadow(
 color: colorScheme.shadow.withOpacity(0.1),
 blurRadius: 8,
 offset: const Offset(0, 2),
 ),
 ],
 ),
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 _buildHeader(context),
 _buildWeekdayHeaders(context),
 _buildCalendarGrid(context),
 ],
 ),
 );
 }

 Widget _buildHeader(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: colorScheme.primaryContainer,
 borderRadius: const Borderconst Radius.only(
 topLeft: const Radius.circular(12),
 topRight: const Radius.circular(12),
 ),
 ),
 child: Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 IconButton(
 onPressed: () {
 final previousMonth = DateTime(
 selectedDate.year,
 selectedDate.month - 1,
 1,
 );
 onDateSelected(previousMonth);
},
 icon: const Icon(Icons.chevron_left),
 ),
 Text(
 _formatMonthYear(selectedDate),
 style: theme.textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 color: colorScheme.onPrimaryContainer,
 ),
 ),
 IconButton(
 onPressed: () {
 final nextMonth = DateTime(
 selectedDate.year,
 selectedDate.month + 1,
 1,
 );
 onDateSelected(nextMonth);
},
 icon: const Icon(Icons.chevron_right),
 ),
 ],
 ),
 );
 }

 Widget _buildWeekdayHeaders(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;
 final weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

 return Padding(
 padding: const EdgeInsets.symmetric(1),
 child: Row(
 mainAxisAlignment: MainAxisAlignment.spaceAround,
 children: weekdays.map((weekday) {
 return const SizedBox(
 width: 32,
 height: 32,
 child: Center(
 child: Text(
 weekday,
 style: theme.textTheme.bodySmall?.copyWith(
 fontWeight: FontWeight.bold,
 color: colorScheme.onSurface.withOpacity(0.6),
 ),
 ),
 ),
 );
 }).toList(),
 ),
 );
 }

 Widget _buildCalendarGrid(BuildContext context) {
 final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
 final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
 final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
 
 final days = <DateTime>[];
 for (int i = 0; i < 42; i++) {
 days.add(startDate.add(Duration(days: i)));
}

 return Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 for (int week = 0; week < 6; week++)
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceAround,
 children: [
 for (int day = 0; day < 7; day++)
 _buildDayCell(
 context,
 days[week * 7 + day],
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildDayCell(BuildContext context, DateTime date) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;
 
 final isCurrentMonth = date.month == selectedDate.month;
 final isSelected = _isSameDay(date, selectedDate);
 final isToday = _isSameDay(date, DateTime.now());
 final isDisabled = _isDateDisabled(date);
 final isHighlighted = _isDateHighlighted(date);

 return const SizedBox(
 width: 32,
 height: 32,
 child: InkWell(
 onTap: isDisabled ? null : () => onDateSelected(date),
 borderRadius: const Borderconst Radius.circular(1),
 child: Container(
 decoration: BoxDecoration(
 color: isSelected 
 ? colorScheme.primary
 : isHighlighted
 ? colorScheme.primaryContainer
 : isToday
 ? colorScheme.primaryContainer.withOpacity(0.5)
 : null,
 shape: BoxShape.circle,
 border: isToday && !isSelected 
 ? Border.all(color: colorScheme.primary)
 : null,
 ),
 child: Center(
 child: Text(
 date.day.toString(),
 style: theme.textTheme.bodySmall?.copyWith(
 color: isSelected
 ? colorScheme.onPrimary
 : isDisabled
 ? colorScheme.onSurface.withOpacity(0.38)
 : isCurrentMonth
 ? colorScheme.onSurface
 : colorScheme.onSurface.withOpacity(0.6),
 fontWeight: isSelected || isToday 
 ? FontWeight.bold 
 : FontWeight.normal,
 ),
 ),
 ),
 ),
 ),
 );
 }

 bool _isSameDay(DateTime date1, DateTime date2) {
 return date1.year == date2.year &&
 date1.month == date2.month &&
 date1.day == date2.day;
 }

 bool _isDateDisabled(DateTime date) {
 if (firstDate != null && date.isBefore(firstDate!)){ return true;
 if (lastDate != null && date.isAfter(lastDate!)){ return true;
 if (disabledDates != null) {{
 return disabledDates!.any((disabledDate) => _isSameDay(date, disabledDate));
}
 return false;
 }

 bool _isDateHighlighted(DateTime date) {
 if (highlightedDates != null) {{
 return highlightedDates!.any((highlightedDate) => _isSameDay(date, highlightedDate));
}
 return false;
 }

 String _formatMonthYear(DateTime date) {
 const months = [
 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
 ];
 return '${months[date.month - 1]} ${date.year}';
 }
}

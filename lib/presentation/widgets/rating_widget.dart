import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:aramco_frontend/core/models/performance_review.dart';

/// Widget de notation par étoiles
class StarRatingWidget extends StatefulWidget {
 final int rating;
 final int maxRating;
 final Function(int) onRatingChanged;
 final bool enabled;
 final double size;
 final Color? activeColor;
 final Color? inactiveColor;

 const StarRatingWidget({
 super.key,
 required this.rating,
 this.maxRating = 5,
 required this.onRatingChanged,
 this.enabled = true,
 this.size = 32.0,
 this.activeColor,
 this.inactiveColor,
 });

 @override
 State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
 late int _currentRating;
 int _hoverRating = 0;

 @override
 void initState() {
 super.initState();
 _currentRating = widget.rating;
 }

 @override
 void didUpdateWidget(StarRatingWidget oldWidget) {
 super.didUpdateWidget(oldWidget);
 if (oldWidget.rating != widget.rating) {{
 _currentRating = widget.rating;
}
 }

 @override
 Widget build(BuildContext context) {
 return Row(
 mainAxisSize: MainAxisSize.min,
 children: List.generate(widget.maxRating, (index) {
 final starIndex = index + 1;
 final isActive = starIndex <= (_hoverRating > 0 ? _hoverRating : _currentRating);
 
 return InkWell(
 onTap: widget.enabled ? () => _onRatingChanged(starIndex) : null,
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.symmetric(1),
 child: Icon(
 isActive ? Icons.star : Icons.star_border,
 size: widget.size,
 color: isActive
 ? (widget.activeColor ?? Colors.amber)
 : (widget.inactiveColor ?? Colors.grey.shade300),
 ),
 ),
 );
 }),
 );
 }

 void _onRatingChanged(int rating) {
 if (widget.enabled) {{
 setState(() {
 _currentRating = rating;
 });
 widget.onRatingChanged(rating);
}
 }

 void _onHoverEnter(int rating) {
 if (widget.enabled) {{
 setState(() {
 _hoverRating = rating;
 });
}
 }

 void _onHoverExit() {
 if (widget.enabled) {{
 setState(() {
 _hoverRating = 0;
 });
}
 }
}

/// Widget de notation numérique avec slider
class NumericRatingWidget extends StatefulWidget {
 final int rating;
 final int maxRating;
 final Function(int) onRatingChanged;
 final bool enabled;
 final String? label;
 final List<String>? labels;

 const NumericRatingWidget({
 super.key,
 required this.rating,
 this.maxRating = 5,
 required this.onRatingChanged,
 this.enabled = true,
 this.label,
 this.labels,
 });

 @override
 State<NumericRatingWidget> createState() => _NumericRatingWidgetState();
}

class _NumericRatingWidgetState extends State<NumericRatingWidget> {
 late double _currentValue;

 @override
 void initState() {
 super.initState();
 _currentValue = widget.rating.toDouble();
 }

 @override
 void didUpdateWidget(NumericRatingWidget oldWidget) {
 super.didUpdateWidget(oldWidget);
 if (oldWidget.rating != widget.rating) {{
 _currentValue = widget.rating.toDouble();
}
 }

 @override
 Widget build(BuildContext context) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 if (widget.label != null) .{..[
 Text(
 widget.label!,
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 ),
 ),
 const SizedBox(height: 8),
 ],
 Row(
 children: [
 Expanded(
 child: SliderTheme(
 data: SliderTheme.of(context).copyWith(
 valueIndicatorColor: Theme.of(context).primaryColor,
 valueIndicatorTextStyle: const TextStyle(
 color: Colors.white,
 fontWeight: FontWeight.bold,
 ),
 ),
 child: Slider(
 value: _currentValue,
 min: 1.0,
 max: widget.maxRating.toDouble(),
 divisions: widget.maxRating - 1,
 label: _currentValue.round().toString(),
 onChanged: widget.enabled ? (value) {
 setState(() {
 _currentValue = value;
 });
 widget.onRatingChanged(value.round());
 } : null,
 ),
 ),
 ),
 const SizedBox(width: 16),
 const SizedBox(
 width: 40,
 height: 40,
 decoration: BoxDecoration(
 color: Theme.of(context).primaryconst Color.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: Theme.of(context).primaryconst Color.withOpacity(0.3),
 ),
 ),
 child: Center(
 child: Text(
 _currentValue.round().toString(),
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.bold,
 color: Theme.of(context).primaryColor,
 ),
 ),
 ),
 ),
 ],
 ),
 if (widget.labels != null) .{..[
 const SizedBox(height: 8),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: List.generate(widget.labels!.length, (index) {
 final isSelected = (_currentValue.round() - 1) == index;
 return Expanded(
 child: Container(
 margin: const EdgeInsets.symmetric(1),
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: isSelected 
 ? Theme.of(context).primaryconst Color.withOpacity(0.1)
 : Colors.transparent,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: isSelected
 ? Theme.of(context).primaryColor
 : Colors.grey.shade300,
 ),
 ),
 child: Text(
 widget.labels![index],
 textAlign: TextAlign.center,
 style: const TextStyle(
 fontSize: 12,
 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
 color: isSelected
 ? Theme.of(context).primaryColor
 : Colors.grey.shade600,
 ),
 ),
 ),
 );
}),
 ),
 ],
 ],
 );
 }
}

/// Widget de sélection de niveau de performance
class PerformanceLevelSelector extends StatefulWidget {
 final PerformanceLevel? selectedLevel;
 final Function(PerformanceLevel) onLevelChanged;
 final bool enabled;

 const PerformanceLevelSelector({
 super.key,
 required this.selectedLevel,
 required this.onLevelChanged,
 this.enabled = true,
 });

 @override
 State<PerformanceLevelSelector> createState() => _PerformanceLevelSelectorState();
}

class _PerformanceLevelSelectorState extends State<PerformanceLevelSelector> {
 @override
 Widget build(BuildContext context) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Niveau de performance global',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 ),
 ),
 const SizedBox(height: 16),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: PerformanceLevel.values.map((level) {
 final isSelected = widget.selectedLevel == level;
 final color = Color(int.parse(level.color.replaceFirst('#', '0xFF')));
 
 return InkWell(
 onTap: widget.enabled ? () => widget.onLevelChanged(level) : null,
 borderRadius: const Borderconst Radius.circular(1),
 child: Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: isSelected ? color : Colors.grey.shade300,
 width: isSelected ? 2 : 1,
 ),
 ),
 child: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 _getIconForLevel(level),
 size: 20,
 color: isSelected ? color : Colors.grey.shade600,
 ),
 const SizedBox(width: 8),
 Text(
 level.displayName,
 style: const TextStyle(
 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
 color: isSelected ? color : Colors.grey.shade700,
 ),
 ),
 ],
 ),
 ),
 );
}).toList(),
 ),
 ],
 );
 }

 IconData _getIconForLevel(PerformanceLevel level) {
 switch (level) {
 case PerformanceLevel.excellent:
 return Icons.star;
 case PerformanceLevel.exceedsExpectations:
 return Icons.thumb_up;
 case PerformanceLevel.meetsExpectations:
 return Icons.check_circle;
 case PerformanceLevel.needsImprovement:
 return Icons.trending_up;
 case PerformanceLevel.unsatisfactory:
 return Icons.warning;
}
 }
}

/// Widget de notation combiné (étoiles + numérique)
class CombinedRatingWidget extends StatelessWidget {
 final int rating;
 final int maxRating;
 final Function(int) onRatingChanged;
 final bool enabled;
 final String? label;
 final bool showNumericValue;

 const CombinedRatingWidget({
 super.key,
 required this.rating,
 this.maxRating = 5,
 required this.onRatingChanged,
 this.enabled = true,
 this.label,
 this.showNumericValue = true,
 });

 @override
 Widget build(BuildContext context) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 if (label != null) .{..[
 Text(
 label!,
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 ),
 ),
 const SizedBox(height: 8),
 ],
 Row(
 children: [
 Expanded(
 child: StarRatingWidget(
 rating: rating,
 maxRating: maxRating,
 onRatingChanged: onRatingChanged,
 enabled: enabled,
 size: 28,
 ),
 ),
 if (showNumericValue) .{..[
 const SizedBox(width: 16),
 const SizedBox(
 width: 36,
 height: 36,
 decoration: BoxDecoration(
 color: Theme.of(context).primaryconst Color.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: Theme.of(context).primaryconst Color.withOpacity(0.3),
 ),
 ),
 child: Center(
 child: Text(
 rating.toString(),
 style: const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.bold,
 color: Theme.of(context).primaryColor,
 ),
 ),
 ),
 ),
 ],
 ],
 ),
 const SizedBox(height: 4),
 Text(
 _getRatingDescription(rating),
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey.shade600,
 fontStyle: FontStyle.italic,
 ),
 ),
 ],
 );
 }

 String _getRatingDescription(int rating) {
 switch (rating) {
 case 5:
 return 'Excellent - Performance exceptionnelle';
 case 4:
 return 'Dépasse les attentes - Performance supérieure';
 case 3:
 return 'Répond aux attentes - Performance satisfaisante';
 case 2:
 return 'Besoin d\'amélioration - Performance à développer';
 case 1:
 return 'Insatisfaisant - Performance insuffisante';
 default:
 return 'Veuillez sélectionner une note';
}
 }
}

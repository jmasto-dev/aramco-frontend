import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/models/dashboard_widget.dart';

class ChartWidget extends StatelessWidget {
 final ChartData data;
 final ChartType? type;

 const ChartWidget({
 Key? key,
 required this.data,
 this.type,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 borderRadius: const Borderconst Radius.circular(1),
 boxShadow: [
 BoxShadow(
 color: Colors.black.withOpacity(0.1),
 blurRadius: 4,
 offset: const Offset(0, 2),
 ),
 ],
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildHeader(),
 const SizedBox(height: 16),
 Expanded(
 child: _buildChart(),
 ),
 if (data.datasetLabels.isNotEmpty) .{..[
 const SizedBox(height: 12),
 _buildLegend(),
 ],
 ],
 ),
 );
 }

 Widget _buildHeader() {
 return Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Expanded(
 child: Text(
 data.options['title'] ?? 'Graphique',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w600,
 ),
 ),
 ),
 if (data.options['showExport'] == true)
 I{conButton(
 icon: const Icon(Icons.download, size: 20),
 onPressed: () {
 // TODO: Implémenter l'export du graphique
;,
 ),
 ],
 );
 }

 Widget _buildChart() {
 switch (type) {
 case ChartType.line:
 return _buildLineChart();
 case ChartType.bar:
 return _buildBarChart();
 case ChartType.pie:
 return _buildPieChart();
 case ChartType.gauge:
 return _buildGaugeChart();
 case ChartType.area:
 return _buildAreaChart();
 default:
 return _buildLineChart();
}
 }

 Widget _buildLineChart() {
 return CustomPaint(
 painter: LineChartPainter(data),
 child: Container(),
 );
 }

 Widget _buildBarChart() {
 return CustomPaint(
 painter: BarChartPainter(data),
 child: Container(),
 );
 }

 Widget _buildPieChart() {
 return CustomPaint(
 painter: PieChartPainter(data),
 child: Container(),
 );
 }

 Widget _buildGaugeChart() {
 return CustomPaint(
 painter: GaugeChartPainter(data),
 child: Container(),
 );
 }

 Widget _buildAreaChart() {
 return CustomPaint(
 painter: AreaChartPainter(data),
 child: Container(),
 );
 }

 Widget _buildLegend() {
 return Wrap(
 spacing: 16,
 runSpacing: 8,
 children: List.generate(data.datasetLabels.length, (index) {
 final color = Color(int.parse(data.colors[index].replaceAll('#', '0xFF')));
 return Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 const SizedBox(
 width: 12,
 height: 12,
 decoration: BoxDecoration(
 color: color,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 ),
 const SizedBox(width: 6),
 Text(
 data.datasetLabels[index],
 style: const TextStyle(fontSize: 12),
 ),
 ],
 );
 }),
 );
 }
}

// Painters pour les différents types de graphiques

class LineChartPainter extends CustomPainter {
 final ChartData data;

 LineChartPainter(this.data);

 @override
 void paint(Canvas canvas, Size size) {
 final paint = Paint()
 ..color = Colors.blue
 ..strokeWidth = 2
 ..style = PaintingStyle.stroke;

 final path = Path();
 
 // Calculer les points
 final points = <Offset>[];
 for (int i = 0; i < data.labels.length; i++) {
 final x = (i / (data.labels.length - 1)) * size.width;
 final maxValue = _getMaxValue();
 final y = size.height - ((data.datasets[0][i] / maxValue) * size.height);
 points.add(Offset(x, y));
}

 // Dessiner la ligne
 if (points.isNotEmpty) {{
 path.moveTo(points.first.dx, points.first.dy);
 for (int i = 1; i < points.length; i++) {
 path.lineTo(points[i].dx, points[i].dy);
 }
 canvas.drawPath(path, paint);

 // Dessiner les points
 final pointPaint = Paint()
 ..color = Colors.blue
 ..style = PaintingStyle.fill;

 for (final point in points) {
 canvas.drawCircle(point, 4, pointPaint);
 }
}

 // Dessiner les axes
 _drawAxes(canvas, size);
 }

 void _drawAxes(Canvas canvas, Size size) {
 final axisPaint = Paint()
 ..color = Colors.grey
 ..strokeWidth = 1;

 // Axe X
 canvas.drawLine(
 Offset(0, size.height),
 Offset(size.width, size.height),
 axisPaint,
 );

 // Axe Y
 canvas.drawLine(
 Offset(0, 0),
 Offset(0, size.height),
 axisPaint,
 );
 }

 double _getMaxValue() {
 double max = 0;
 for (final dataset in data.datasets) {
 for (final value in dataset) {
 if (value > max) m{ax = value;
 }
}
 return max == 0 ? 1 : max;
 }

 @override
 bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartPainter extends CustomPainter {
 final ChartData data;

 BarChartPainter(this.data);

 @override
 void paint(Canvas canvas, Size size) {
 final maxValue = _getMaxValue();
 final barWidth = size.width / (data.labels.length * 2);
 final spacing = barWidth;

 for (int i = 0; i < data.labels.length; i++) {
 final value = data.datasets[0][i];
 final barHeight = (value / maxValue) * size.height;
 final x = spacing + (i * (barWidth + spacing));
 final y = size.height - barHeight;

 final paint = Paint()
 ..color = Color(int.parse(data.colors[0].replaceAll('#', '0xFF')))
 ..style = PaintingStyle.fill;

 canvas.drawRRect(
 RRect.fromRectAndRadius(
 Rect.fromLTWH(x, y, barWidth, barHeight),
 const Radius.circular(4),
 ),
 paint,
 );
}

 _drawAxes(canvas, size);
 }

 void _drawAxes(Canvas canvas, Size size) {
 final axisPaint = Paint()
 ..color = Colors.grey
 ..strokeWidth = 1;

 canvas.drawLine(
 Offset(0, size.height),
 Offset(size.width, size.height),
 axisPaint,
 );
 }

 double _getMaxValue() {
 double max = 0;
 for (final dataset in data.datasets) {
 for (final value in dataset) {
 if (value > max) m{ax = value;
 }
}
 return max == 0 ? 1 : max;
 }

 @override
 bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
 final ChartData data;

 PieChartPainter(this.data);

 @override
 void paint(Canvas canvas, Size size) {
 final center = Offset(size.width / 2, size.height / 2);
 final radius = math.min(size.width, size.height) / 2 - 20;
 
 double total = data.datasets[0].reduce((a, b) => a + b);
 double startAngle = -math.pi / 2;

 for (int i = 0; i < data.datasets[0].length; i++) {
 final value = data.datasets[0][i];
 final sweepAngle = (value / total) * 2 * math.pi;
 
 final paint = Paint()
 ..color = Color(int.parse(data.colors[i].replaceAll('#', '0xFF')))
 ..style = PaintingStyle.fill;

 canvas.drawArc(
 Rect.fromCircle(center: center, radius: radius),
 startAngle,
 sweepAngle,
 true,
 paint,
 );

 // Dessiner le label
 final labelAngle = startAngle + sweepAngle / 2;
 final labelX = center.dx + (radius * 0.7) * math.cos(labelAngle);
 final labelY = center.dy + (radius * 0.7) * math.sin(labelAngle);
 
 final textPainter = TextPainter(
 text: TextSpan(
 text: '${(value / total * 100).toStringAsFixed(1)}%',
 style: const TextStyle(
 color: Colors.white,
 fontSize: 12,
 fontWeight: FontWeight.bold,
 ),
 ),
 textDirection: TextDirection.ltr,
 );
 textPainter.layout();
 textPainter.paint(
 canvas,
 Offset(
 labelX - textPainter.width / 2,
 labelY - textPainter.height / 2,
 ),
 );

 startAngle += sweepAngle;
}
 }

 @override
 bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GaugeChartPainter extends CustomPainter {
 final ChartData data;

 GaugeChartPainter(this.data);

 @override
 void paint(Canvas canvas, Size size) {
 final center = Offset(size.width / 2, size.height / 2);
 final radius = math.min(size.width, size.height) / 2 - 20;
 
 final value = data.datasets[0][0];
 final maxValue = data.options['maxValue'] ?? 100.0;
 final percentage = value / maxValue;

 // Dessiner l'arc de fond
 final backgroundPaint = Paint()
 ..color = Colors.grey[300]!
 ..strokeWidth = 20
 ..style = PaintingStyle.stroke;

 canvas.drawArc(
 Rect.fromCircle(center: center, radius: radius),
 math.pi * 0.75,
 math.pi * 1.5,
 false,
 backgroundPaint,
 );

 // Dessiner l'arc de valeur
 final valuePaint = Paint()
 ..color = _getGaugeColor(percentage)
 ..strokeWidth = 20
 ..style = PaintingStyle.stroke
 ..strokeCap = StrokeCap.round;

 canvas.drawArc(
 Rect.fromCircle(center: center, radius: radius),
 math.pi * 0.75,
 math.pi * 1.5 * percentage,
 false,
 valuePaint,
 );

 // Dessiner la valeur centrale
 final textPainter = TextPainter(
 text: TextSpan(
 text: value.toStringAsFixed(1),
 style: const TextStyle(
 color: _getGaugeColor(percentage),
 fontSize: 32,
 fontWeight: FontWeight.bold,
 ),
 ),
 textDirection: TextDirection.ltr,
 );
 textPainter.layout();
 textPainter.paint(
 canvas,
 Offset(
 center.dx - textPainter.width / 2,
 center.dy - textPainter.height / 2,
 ),
 );
 }

 Color _getGaugeColor(double percentage) {
 if (percentage >= 0.8) r{eturn Colors.green;
 if (percentage >= 0.5) r{eturn Colors.orange;
 return Colors.red;
 }

 @override
 bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AreaChartPainter extends CustomPainter {
 final ChartData data;

 AreaChartPainter(this.data);

 @override
 void paint(Canvas canvas, Size size) {
 final paint = Paint()
 ..color = Colors.blue.withOpacity(0.3)
 ..style = PaintingStyle.fill;

 final strokePaint = Paint()
 ..color = Colors.blue
 ..strokeWidth = 2
 ..style = PaintingStyle.stroke;

 final path = Path();
 final points = <Offset>[];
 
 // Calculer les points
 for (int i = 0; i < data.labels.length; i++) {
 final x = (i / (data.labels.length - 1)) * size.width;
 final maxValue = _getMaxValue();
 final y = size.height - ((data.datasets[0][i] / maxValue) * size.height);
 points.add(Offset(x, y));
}

 // Créer le chemin de l'aire
 if (points.isNotEmpty) {{
 path.moveTo(points.first.dx, size.height);
 path.lineTo(points.first.dx, points.first.dy);
 
 for (int i = 1; i < points.length; i++) {
 path.lineTo(points[i].dx, points[i].dy);
 }
 
 path.lineTo(points.last.dx, size.height);
 path.close();
 
 canvas.drawPath(path, paint);
 canvas.drawPath(path, strokePaint);
}

 _drawAxes(canvas, size);
 }

 void _drawAxes(Canvas canvas, Size size) {
 final axisPaint = Paint()
 ..color = Colors.grey
 ..strokeWidth = 1;

 canvas.drawLine(
 Offset(0, size.height),
 Offset(size.width, size.height),
 axisPaint,
 );
 }

 double _getMaxValue() {
 double max = 0;
 for (final dataset in data.datasets) {
 for (final value in dataset) {
 if (value > max) m{ax = value;
 }
}
 return max == 0 ? 1 : max;
 }

 @override
 bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

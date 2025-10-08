import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
 final Widget child;
 final bool isLoading;
 final String? loadingText;
 final Color? overlayColor;
 final double? progress;
 final bool showProgress;

 const LoadingOverlay({
 super.key,
 required this.child,
 this.isLoading = false,
 this.loadingText,
 this.overlayColor,
 this.progress,
 this.showProgress = false,
 });

 @override
 Widget build(BuildContext context) {
 return Stack(
 children: [
 child,
 if (isLoading) _{buildLoadingOverlay(),
 ],
 );
 }

 Widget _buildLoadingOverlay() {
 return Container(
 color: overlayColor ?? Colors.black.withOpacity(0.5),
 child: Center(
 child: Card(
 elevation: 8,
 shape: RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: AppTheme.surfaceColor,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 if (showProgress && progress != null) .{..[
 _buildProgressIndicator(),
 const SizedBox(height: 16),
 ] else ...[
 _buildLoadingSpinner(),
 const SizedBox(height: 16),
 ],
 if (loadingText != null)
 T{ext(
 loadingText!,
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: AppTheme.textPrimary,
 fontWeight: FontWeight.w500,
 ),
 textAlign: TextAlign.center,
 ),
 ],
 ),
 ),
 ),
 ),
 );
 }

 Widget _buildLoadingSpinner() {
 return const SizedBox(
 width: 40,
 height: 40,
 child: CircularProgressIndicator(
 strokeWidth: 3,
 valueColor: AlwaysStoppedAnimation<Color>(
 AppTheme.primaryColor,
 ),
 ),
 );
 }

 Widget _buildProgressIndicator() {
 return const SizedBox(
 width: 60,
 height: 60,
 child: Stack(
 alignment: Alignment.center,
 children: [
 const SizedBox(
 width: 60,
 height: 60,
 child: CircularProgressIndicator(
 strokeWidth: 4,
 value: progress,
 backgroundColor: AppTheme.dividerColor,
 valueColor: AlwaysStoppedAnimation<Color>(
 AppTheme.primaryColor,
 ),
 ),
 ),
 Text(
 '${((progress ?? 0) * 100).toInt()}%',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: AppTheme.textPrimary,
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 );
 }
}

// Loader plein écran
class FullScreenLoader extends StatelessWidget {
 final String? message;
 final double? progress;
 final bool showProgress;

 const FullScreenLoader({
 super.key,
 this.message,
 this.progress,
 this.showProgress = false,
 });

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 backgroundColor: Colors.black.withOpacity(0.8),
 body: Center(
 child: Card(
 elevation: 8,
 shape: RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: AppTheme.surfaceColor,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 if (showProgress && progress != null) .{..[
 _buildProgressIndicator(),
 const SizedBox(height: 24),
 ] else ...[
 _buildLoadingSpinner(),
 const SizedBox(height: 24),
 ],
 if (message != null) .{..[
 Text(
 message!,
 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
 color: AppTheme.textPrimary,
 fontWeight: FontWeight.w500,
 ),
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 8),
 ],
 Text(
 'Veuillez patienter...',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: AppTheme.textSecondary,
 ),
 textAlign: TextAlign.center,
 ),
 ],
 ),
 ),
 ),
 ),
 );
 }

 Widget _buildLoadingSpinner() {
 return const SizedBox(
 width: 50,
 height: 50,
 child: CircularProgressIndicator(
 strokeWidth: 3,
 valueColor: AlwaysStoppedAnimation<Color>(
 AppTheme.primaryColor,
 ),
 ),
 );
 }

 Widget _buildProgressIndicator() {
 return const SizedBox(
 width: 80,
 height: 80,
 child: Stack(
 alignment: Alignment.center,
 children: [
 const SizedBox(
 width: 80,
 height: 80,
 child: CircularProgressIndicator(
 strokeWidth: 6,
 value: progress,
 backgroundColor: AppTheme.dividerColor,
 valueColor: AlwaysStoppedAnimation<Color>(
 AppTheme.primaryColor,
 ),
 ),
 ),
 Text(
 '${((progress ?? 0) * 100).toInt()}%',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 color: AppTheme.textPrimary,
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 );
 }
}

// Widget de chargement personnalisé
class CustomLoader extends StatefulWidget {
 final double size;
 final Color? color;
 final double strokeWidth;
 final Duration duration;

 const CustomLoader({
 super.key,
 this.size = 40,
 this.color,
 this.strokeWidth = 3,
 this.duration = const Duration(seconds: 1),
 });

 @override
 State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
 with TickerProviderStateMixin {
 late AnimationController _controller;
 late Animation<double> _animation;

 @override
 void initState() {
 super.initState();
 _controller = AnimationController(
 duration: widget.duration,
 vsync: this,
 );
 _animation = Tween<double>(
 begin: 0.0,
 end: 1.0,
 ).animate(CurvedAnimation(
 parent: _controller,
 curve: Curves.easeInOut,
 ));
 _controller.repeat();
 }

 @override
 void dispose() {
 _controller.dispose();
 super.dispose();
 }

 @override
 Widget build(BuildContext context) {
 return const SizedBox(
 width: widget.size,
 height: widget.size,
 child: AnimatedBuilder(
 animation: _animation,
 builder: (context, child) {
 return Transform.rotate(
 angle: _animation.value * 2 * 3.14159,
 child: CustomPaint(
 painter: _LoaderPainter(
 progress: _animation.value,
 color: widget.color ?? AppTheme.primaryColor,
 strokeWidth: widget.strokeWidth,
 ),
 size: Size(widget.size, widget.size),
 ),
 );
 },
 ),
 );
 }
}

class _LoaderPainter extends CustomPainter {
 final double progress;
 final Color color;
 final double strokeWidth;

 _LoaderPainter({
 required this.progress,
 required this.color,
 required this.strokeWidth,
 });

 @override
 void paint(Canvas canvas, Size size) {
 final center = Offset(size.width / 2, size.height / 2);
 final radius = (size.width - strokeWidth) / 2;

 // Cercle de fond
 final backgroundPaint = Paint()
 ..color = color.withOpacity(0.2)
 ..strokeWidth = strokeWidth
 ..style = PaintingStyle.stroke;

 canvas.drawCircle(center, radius, backgroundPaint);

 // Arc de progression
 final progressPaint = Paint()
 ..color = color
 ..strokeWidth = strokeWidth
 ..style = PaintingStyle.stroke
 ..strokeCap = StrokeCap.round;

 final startAngle = -3.14159 / 2; // Commence en haut
 final sweepAngle = progress * 2 * 3.14159;

 canvas.drawArc(
 Rect.fromCircle(center: center, radius: radius),
 startAngle,
 sweepAngle,
 false,
 progressPaint,
 );
 }

 @override
 bool shouldRepaint(_LoaderPainter oldDelegate) {
 return oldDelegate.progress != progress;
 }
}

// Widget de skeleton loading
class SkeletonLoader extends StatefulWidget {
 final Widget child;
 final Duration duration;
 final Color baseColor;
 final Color highlightColor;

 const SkeletonLoader({
 super.key,
 required this.child,
 this.duration = const Duration(milliseconds: 1500),
 this.baseColor = const Color(0xFFE0E0E0),
 this.highlightColor = const Color(0xFFF5F5F5),
 });

 @override
 State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
 with SingleTickerProviderStateMixin {
 late AnimationController _controller;
 late Animation<double> _animation;

 @override
 void initState() {
 super.initState();
 _controller = AnimationController(
 duration: widget.duration,
 vsync: this,
 );
 _animation = Tween<double>(
 begin: -1.0,
 end: 2.0,
 ).animate(CurvedAnimation(
 parent: _controller,
 curve: Curves.easeInOut,
 ));
 _controller.repeat();
 }

 @override
 void dispose() {
 _controller.dispose();
 super.dispose();
 }

 @override
 Widget build(BuildContext context) {
 return AnimatedBuilder(
 animation: _animation,
 builder: (context, child) {
 return ShaderMask(
 shaderCallback: (bounds) {
 return LinearGradient(
 begin: Alignment.centerLeft,
 end: Alignment.centerRight,
 colors: [
 widget.baseColor,
 widget.highlightColor,
 widget.baseColor,
 ],
 stops: [
 0.0,
 _animation.value,
 1.0,
 ],
 ).createShader(bounds);
},
 child: widget.child,
 );
 },
 );
 }
}

// Widget de chargement pour les listes
class ListSkeletonLoader extends StatelessWidget {
 final int itemCount;
 final double itemHeight;
 final EdgeInsets padding;

 const ListSkeletonLoader({
 super.key,
 this.itemCount = 5,
 this.itemHeight = 60,
 this.padding = const EdgeInsets.all(1),
 });

 @override
 Widget build(BuildContext context) {
 return ListView.builder(
 padding: padding,
 itemCount: itemCount,
 itemBuilder: (context, index) {
 return Container(
 margin: const EdgeInsets.only(bottom: 12),
 height: itemHeight,
 decoration: BoxDecoration(
 color: AppTheme.surfaceColor,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: SkeletonLoader(
 child: Container(
 decoration: BoxDecoration(
 color: Colors.grey,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 ),
 ),
 );
 },
 );
 }
}

// Widget de chargement pour les cartes
class CardSkeletonLoader extends StatelessWidget {
 final double width;
 final double height;
 final BorderRadius? borderRadius;

 const CardSkeletonLoader({
 super.key,
 required this.width,
 required this.height,
 this.borderRadius,
 });

 @override
 Widget build(BuildContext context) {
 return const SizedBox(
 width: width,
 height: height,
 decoration: BoxDecoration(
 color: AppTheme.surfaceColor,
 borderRadius: borderRadius ?? const Borderconst Radius.circular(1),
 ),
 child: SkeletonLoader(
 child: Container(
 decoration: BoxDecoration(
 color: Colors.grey,
 borderRadius: borderRadius ?? const Borderconst Radius.circular(1),
 ),
 ),
 ),
 );
 }
}

// Widget de chargement pour les images
class ImageSkeletonLoader extends StatelessWidget {
 final double width;
 final double height;
 final BorderRadius? borderRadius;

 const ImageSkeletonLoader({
 super.key,
 required this.width,
 required this.height,
 this.borderRadius,
 });

 @override
 Widget build(BuildContext context) {
 return const SizedBox(
 width: width,
 height: height,
 decoration: BoxDecoration(
 color: AppTheme.surfaceColor,
 borderRadius: borderRadius ?? const Borderconst Radius.circular(1),
 ),
 child: SkeletonLoader(
 child: Container(
 decoration: BoxDecoration(
 color: Colors.grey,
 borderRadius: borderRadius ?? const Borderconst Radius.circular(1),
 ),
 child: const Center(
 child: Icon(
 Icons.image,
 color: Colors.grey,
 size: 32,
 ),
 ),
 ),
 ),
 );
 }
}

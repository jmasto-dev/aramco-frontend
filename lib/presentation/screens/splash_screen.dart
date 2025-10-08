import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/utils/constants.dart';
import '../providers/auth_provider.dart';
import '../../core/providers/service_providers.dart';
import 'login_screen.dart';
import 'main_layout.dart';

class SplashScreen extends ConsumerStatefulWidget {
 const SplashScreen({super.key});

 @override
 ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
 with TickerProviderStateMixin {
 late AnimationController _logoController;
 late AnimationController _textController;
 late Animation<double> _logoAnimation;
 late Animation<double> _textAnimation;
 late Animation<double> _progressAnimation;

 @override
 void initState() {
 super.initState();
 _initializeAnimations();
 _startAnimations();
 _navigateToNextScreen();
 }

 void _initializeAnimations() {
 _logoController = AnimationController(
 duration: const Duration(milliseconds: 1500),
 vsync: this,
 );

 _textController = AnimationController(
 duration: const Duration(milliseconds: 1000),
 vsync: this,
 );

 _logoAnimation = Tween<double>(
 begin: 0.0,
 end: 1.0,
 ).animate(CurvedAnimation(
 parent: _logoController,
 curve: Curves.elasticOut,
 ));

 _textAnimation = Tween<double>(
 begin: 0.0,
 end: 1.0,
 ).animate(CurvedAnimation(
 parent: _textController,
 curve: Curves.easeInOut,
 ));

 _progressAnimation = Tween<double>(
 begin: 0.0,
 end: 1.0,
 ).animate(CurvedAnimation(
 parent: _logoController,
 curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
 ));
 }

 void _startAnimations() async {
 await _logoController.forward();
 _textController.forward();
 }

 void _navigateToNextScreen() async {
 // Attendre la fin des animations et un minimum de temps d'affichage
 await Future.delayed(const Duration(seconds: 3));

 if (!mounted) return;

 final authState = ref.read(authProvider);

 if (authState.isAuthenticated && authState.user != null) {
 // Utilisateur déjà connecté
 Navigator.of(context).pushReplacement(
 MaterialPageRoute(
 builder: (context) => const MainLayout(),
 ),
 );
 } else {
 // Utilisateur non connecté
 Navigator.of(context).pushReplacement(
 MaterialPageRoute(
 builder: (context) => const LoginScreen(),
 ),
 );
 }
 }

 @override
 void dispose() {
 _logoController.dispose();
 _textController.dispose();
 super.dispose();
 }

 @override
 Widget build(BuildContext context) {
 final authState = ref.watch(authProvider);

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 backgroundColor: AppTheme.backgroundColor,
 body: Container(
 decoration: BoxDecoration(
 gradient: LinearGradient(
 begin: Alignment.topCenter,
 end: Alignment.bottomCenter,
 colors: [
 AppTheme.primaryconst Color.withOpacity(0.1),
 AppTheme.backgroundColor,
 ],
 ),
 ),
 child: SafeArea(
 child: Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const Spacer(flex: 2),

 // Logo animé
 AnimatedBuilder(
 animation: _logoAnimation,
 builder: (context, child) {
 return Transform.scale(
 scale: _logoAnimation.value,
 child: Opacity(
 opacity: _logoAnimation.value,
 child: _buildLogo(),
 ),
 );
 },
 ),

 const SizedBox(height: AppConstants.spacingXL),

 // Nom de l'application animé
 AnimatedBuilder(
 animation: _textAnimation,
 builder: (context, child) {
 return Opacity(
 opacity: _textAnimation.value,
 child: Transform.translate(
 offset: Offset(0, 20 * (1 - _textAnimation.value)),
 child: _buildAppName(),
 ),
 );
 },
 ),

 const SizedBox(height: AppConstants.spacingXL),

 // Barre de progression
 AnimatedBuilder(
 animation: _progressAnimation,
 builder: (context, child) {
 return _buildProgressBar();
 },
 ),

 const Spacer(flex: 1),

 // Message de chargement
 if (authState.isLoading)
 _{buildLoadingMessage(),

 const SizedBox(height: AppConstants.spacingLG),

 // Version de l'application
 _buildVersionInfo(),

 const SizedBox(height: AppConstants.spacingMD),
 ],
 ),
 ),
 ),
 ),
 );
 }

 Widget _buildLogo() {
 return const SizedBox(
 width: 120,
 height: 120,
 decoration: BoxDecoration(
 gradient: AppTheme.primaryGradient,
 borderRadius: const Borderconst Radius.circular(1),
 boxShadow: AppTheme.elevatedShadow,
 ),
 child: const Icon(
 Icons.business,
 size: 60,
 color: AppTheme.textOnPrimary,
 ),
 );
 }

 Widget _buildAppName() {
 return Column(
 children: [
 Text(
 AppConstants.appName,
 style: Theme.of(context).textTheme.displayMedium?.copyWith(
 fontWeight: FontWeight.bold,
 color: AppTheme.primaryColor,
 ),
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: AppConstants.spacingSM),
 Text(
 AppConstants.appDescription,
 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
 color: AppTheme.textSecondary,
 ),
 textAlign: TextAlign.center,
 ),
 ],
 );
 }

 Widget _buildProgressBar() {
 return const SizedBox(
 width: 200,
 height: 4,
 decoration: BoxDecoration(
 color: AppTheme.dividerColor,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: ClipRRect(
 borderRadius: const Borderconst Radius.circular(1),
 child: LinearProgressIndicator(
 value: _progressAnimation.value,
 backgroundColor: Colors.transparent,
 valueColor: AlwaysStoppedAnimation<Color>(
 AppTheme.primaryColor,
 ),
 ),
 ),
 );
 }

 Widget _buildLoadingMessage() {
 return Column(
 children: [
 const SizedBox(
 width: 20,
 height: 20,
 child: CircularProgressIndicator(
 strokeWidth: 2,
 valueColor: AlwaysStoppedAnimation<Color>(
 AppTheme.primaryColor,
 ),
 ),
 ),
 const SizedBox(height: AppConstants.spacingSM),
 Text(
 'Initialisation...',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: AppTheme.textSecondary,
 ),
 ),
 ],
 );
 }

 Widget _buildVersionInfo() {
 return Text(
 'Version ${AppConstants.appVersion}',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: AppTheme.textDisabled,
 ),
 );
 }
}

// Splash screen personnalisé pour l'erreur
class ErrorSplashScreen extends ConsumerWidget {
 final String error;
 final VoidCallback? onRetry;

 const ErrorSplashScreen({
 super.key,
 required this.error,
 this.onRetry,
 });

 @override
 Widget build(BuildContext context, WidgetRef ref) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 backgroundColor: AppTheme.backgroundColor,
 body: Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.error_outline,
 size: 80,
 color: AppTheme.errorColor,
 ),
 const SizedBox(height: AppConstants.spacingXL),
 Text(
 'Erreur de démarrage',
 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
 color: AppTheme.errorColor,
 fontWeight: FontWeight.bold,
 ),
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: AppConstants.spacingMD),
 Text(
 error,
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: AppTheme.textSecondary,
 ),
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: AppConstants.spacingXL),
 if (onRetry != null)
 E{levatedButton.icon(
 onPressed: onRetry,
 icon: const Icon(Icons.refresh),
 label: const Text('Réessayer'),
 style: ElevatedButton.styleFrom(
 backgroundColor: AppTheme.primaryColor,
 foregroundColor: AppTheme.textOnPrimary,
 padding: const EdgeInsets.symmetric(1),
 ),
 ),
 ],
 ),
 ),
 ),
 );
 }
}

// Splash screen pour le premier lancement
class FirstLaunchSplashScreen extends ConsumerStatefulWidget {
 const FirstLaunchSplashScreen({super.key});

 @override
 ConsumerState<FirstLaunchSplashScreen> createState() =>
 _FirstLaunchSplashScreenState();
}

class _FirstLaunchSplashScreenState
 extends ConsumerState<FirstLaunchSplashScreen>
 with TickerProviderStateMixin {
 late AnimationController _controller;
 late Animation<double> _fadeAnimation;

 @override
 void initState() {
 super.initState();
 _initializeAnimations();
 _startAnimations();
 }

 void _initializeAnimations() {
 _controller = AnimationController(
 duration: const Duration(milliseconds: 2000),
 vsync: this,
 );

 _fadeAnimation = Tween<double>(
 begin: 0.0,
 end: 1.0,
 ).animate(CurvedAnimation(
 parent: _controller,
 curve: Curves.easeInOut,
 ));
 }

 void _startAnimations() async {
 await _controller.forward();
 
 // Marquer le premier lancement comme terminé
 await ref.read(storageServiceProvider).setFirstLaunch(false);
 
 if (mounted) {{
 Navigator.of(context).pushReplacement(
 MaterialPageRoute(
 builder: (context) => const LoginScreen(),
 ),
 );
}
 }

 @override
 void dispose() {
 _controller.dispose();
 super.dispose();
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 backgroundColor: AppTheme.backgroundColor,
 body: AnimatedBuilder(
 animation: _fadeAnimation,
 builder: (context, child) {
 return Opacity(
 opacity: _fadeAnimation.value,
 child: Container(
 decoration: BoxDecoration(
 gradient: LinearGradient(
 begin: Alignment.topCenter,
 end: Alignment.bottomCenter,
 colors: [
 AppTheme.primaryconst Color.withOpacity(0.2),
 AppTheme.backgroundColor,
 ],
 ),
 ),
 child: SafeArea(
 child: Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.waving_hand,
 size: 100,
 color: AppTheme.primaryColor,
 ),
 const SizedBox(height: AppConstants.spacingXL),
 Text(
 'Bienvenue !',
 style: Theme.of(context).textTheme.displayMedium?.copyWith(
 color: AppTheme.primaryColor,
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: AppConstants.spacingMD),
 Text(
 'Découvrez la solution de gestion intégrée pour Aramco SA',
 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
 color: AppTheme.textSecondary,
 ),
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: AppConstants.spacingXL),
 _buildFeatureList(),
 ],
 ),
 ),
 ),
 ),
 ),
 );
 },
 ),
 );
 }

 Widget _buildFeatureList() {
 final features = [
 'Gestion des employés',
 'Suivi des commandes',
 'Livraisons optimisées',
 'Comptabilité complète',
 'Rapports détaillés',
 ];

 return Column(
 children: features.map((feature) {
 return Padding(
 padding: const EdgeInsets.symmetric(1),
 child: Row(
 children: [
 Icon(
 Icons.check_circle,
 color: AppTheme.secondaryColor,
 size: 20,
 ),
 const SizedBox(width: AppConstants.spacingSM),
 Text(
 feature,
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: AppTheme.textPrimary,
 ),
 ),
 ],
 ),
 );
 }).toList(),
 );
 }
}

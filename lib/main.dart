import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/constants.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'package:provider/provider.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
 
 // Initialisation des services
 await _initializeServices();
 
 runApp(
 const ProviderScope(
 child: AramcoApp(),
 ),
 );
}

// Initialisation des services de l'application
Future<void> _initializeServices() async {
 try {
 // Initialiser le service de stockage
 await StorageService().initialize();
 
 // Initialiser le service API
 ApiService().initialize();
 
 // Nettoyer les données expirées
 await StorageService().cleanupExpiredData();
 
 if (AppConstants.appName.contains('debug')) {
 debugPrint('Services initialisés avec succès');
 }
 } catch (e) {
 if (AppConstants.appName.contains('debug')) {
 debugPrint('Erreur lors de l\'initialisation des services: $e');
 }
 // En cas d'erreur, on continue quand même l'application
 }
}

class AramcoApp extends ConsumerWidget {
 const AramcoApp({super.key});

 @override
 Widget build(BuildContext context, WidgetRef ref) {
 final themeMode = ref.watch(themeProvider);
 final locale = ref.watch(languageProvider);
 
 return MaterialApp(
 title: AppConstants.appName,
 debugShowCheckedModeBanner: false,
 
 // Configuration du thème
 theme: AppTheme.lightTheme,
 darkTheme: AppTheme.darkTheme,
 themeMode: themeMode,
 
 // Configuration de la langue
 locale: locale,
 supportedLocales: const [
 Locale('fr', 'FR'), // Français
 Locale('en', 'US'), // Anglais
 Locale('ar', 'SA'), // Arabe
 ],
 
 // Localisation
 localizationsDelegates: const [
 GlobalMaterialLocalizations.delegate,
 GlobalWidgetsLocalizations.delegate,
 GlobalCupertinoLocalizations.delegate,
 ],
 
 // Configuration des routes
 home: const SplashScreen(),
 
 // Configuration du builder pour les animations et les dialogues globaux
 builder: (context, child) {
 return MediaQuery(
 data: MediaQuery.of(context).copyWith(
 textScaleFactor: 1.0, // Éviter le redimensionnement du texte
 ),
 child: Directionality(
 textDirection: _getTextDirection(locale.languageCode),
 child: child!,
 ),
 );
 },
 
 // Configuration des animations
 themeAnimationDuration: AppConstants.defaultAnimationDuration,
 themeAnimationCurve: Curves.easeInOut,
 
 // Configuration des scrollbars
 scrollBehavior: const MaterialScrollBehavior().copyWith(
 scrollbars: true,
 overscroll: true,
 dragDevices: {
 PointerDeviceKind.touch,
 PointerDeviceKind.mouse,
 PointerDeviceKind.stylus,
 PointerDeviceKind.trackpad,
 },
 ),
 
 // Configuration des dialogues
 useInheritedMediaQuery: true,
 
 );
 }
 
 // Obtenir la direction du texte en fonction de la langue
 TextDirection _getTextDirection(String languageCode) {
 switch (languageCode) {
 case 'ar':
 return TextDirection.rtl;
 default:
 return TextDirection.ltr;
}
 }
}

// Widget pour gérer les erreurs globales
class ErrorBoundary extends ConsumerWidget {
 final Widget child;
 final String? errorMessage;
 
 const ErrorBoundary({
 super.key,
 required this.child,
 this.errorMessage,
 });

 @override
 Widget build(BuildContext context, WidgetRef ref) {
 return child;
 }
}

// Widget pour afficher un écran d'erreur
class ErrorScreen extends StatelessWidget {
 final String error;
 final VoidCallback? onRetry;
 
 const ErrorScreen({
 super.key,
 required this.error,
 this.onRetry,
 });

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 backgroundColor: AppTheme.backgroundColor,
 body: Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.error_outline,
 size: 64,
 color: AppTheme.errorColor,
 ),
 const SizedBox(height: AppConstants.spacingLG),
 Text(
 'Une erreur est survenue',
 style: Theme.of(context).textTheme.headlineMedium,
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: AppConstants.spacingMD),
 Text(
 error,
 style: Theme.of(context).textTheme.bodyMedium,
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: AppConstants.spacingXL),
 if (onRetry != null)
 ElevatedButton(
 onPressed: onRetry,
 child: const Text('Réessayer'),
 ),
 ],
 ),
 ),
 ),
 );
 }
}

// Widget pour afficher un écran de chargement
class LoadingScreen extends StatelessWidget {
 final String? message;
 
 const LoadingScreen({
 super.key,
 this.message,
 });

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 backgroundColor: AppTheme.backgroundColor,
 body: Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 CircularProgressIndicator(
 color: AppTheme.primaryColor,
 ),
 const SizedBox(height: AppConstants.spacingMD),
 if (message != null)
 Text(
 message!,
 style: Theme.of(context).textTheme.bodyMedium,
 textAlign: TextAlign.center,
 ),
 ],
 ),
 ),
 );
 }
}

// Widget pour gérer l'état de connexion
class ConnectivityWrapper extends ConsumerWidget {
 final Widget child;
 
 const ConnectivityWrapper({
 super.key,
 required this.child,
 });

 @override
 Widget build(BuildContext context, WidgetRef ref) {
 // TODO: Implémenter la vérification de connectivité
 return child;
 }
}

// Widget pour gérer les notifications
class NotificationWrapper extends ConsumerWidget {
 final Widget child;
 
 const NotificationWrapper({
 super.key,
 required this.child,
 });

 @override
 Widget build(BuildContext context, WidgetRef ref) {
 // TODO: Implémenter la gestion des notifications
 return child;
 }
}

// Widget pour gérer les mises à jour
class UpdateWrapper extends ConsumerWidget {
 final Widget child;
 
 const UpdateWrapper({
 super.key,
 required this.child,
 });

 @override
 Widget build(BuildContext context, WidgetRef ref) {
 // TODO: Implémenter la vérification des mises à jour
 return child;
 }
}

// Configuration globale de l'application
class AppConfig {
 static const bool isDebugMode = true; // À remplacer par kDebugMode
 static const bool enableAnalytics = false; // À configurer selon les besoins
 static const bool enableCrashReporting = true; // À configurer selon les besoins
 static const bool enablePerformanceMonitoring = false; // À configurer selon les besoins
 
 // Configuration de l'environnement
 static const String environment = 'development'; // development, staging, production
 
 // URLs de l'API selon l'environnement
 static String get apiBaseUrl {
 switch (environment) {
 case 'production':
 return 'https://api.aramco-sa.com';
 case 'staging':
 return 'https://staging-api.aramco-sa.com';
 default:
 return 'https://dev-api.aramco-sa.com';
}
 }
 
 // Configuration des logs
 static const bool enableVerboseLogs = true;
 static const bool enableNetworkLogs = true;
 static const bool enablePerformanceLogs = false;
 
 // Configuration du cache
 static const Duration cacheExpiration = Duration(hours: 24);
 static const int maxCacheSize = 100; // MB
 
 // Configuration des timeouts
 static const Duration connectionTimeout = Duration(seconds: 30);
 static const Duration receiveTimeout = Duration(seconds: 30);
 static const Duration sendTimeout = Duration(seconds: 30);
 
 // Configuration de la pagination
 static const int defaultPageSize = 20;
 static const int maxPageSize = 100;
 
 // Configuration des fichiers
 static const int maxFileSize = 10; // MB
 static const List<String> allowedFileTypes = [
 'jpg', 'jpeg', 'png', 'gif', 'webp', // Images
 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'csv', // Documents
 ];
 
 // Configuration de la sécurité
 static const int maxLoginAttempts = 3;
 static const Duration sessionTimeout = Duration(minutes: 30);
 static const Duration lockoutDuration = Duration(minutes: 5);
 
 // Configuration des animations
 static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
 static const Duration fastAnimationDuration = Duration(milliseconds: 150);
 static const Duration slowAnimationDuration = Duration(milliseconds: 500);
 
 // Configuration des couleurs
 static const Map<String, String> colorPalette = {
 'primary': '#0066CC',
 'secondary': '#00AA00',
 'accent': '#FF6600',
 'error': '#DC3545',
 'warning': '#FFC107',
 'info': '#17A2B8',
 'success': '#28A745',
 };
}

// Extensions utiles pour l'application
extension AppContext on BuildContext {
 // Obtenir la taille de l'écran
 Size get screenSize => MediaQuery.of(this).size;
 
 // Obtenir la largeur de l'écran
 double get screenWidth => screenSize.width;
 
 // Obtenir la hauteur de l'écran
 double get screenHeight => screenSize.height;
 
 // Vérifier si c'est un mobile
 bool get isMobile => screenWidth < 768;
 
 // Vérifier si c'est une tablette
 bool get isTablet => screenWidth >= 768 && screenWidth < 1024;
 
 // Vérifier si c'est un desktop
 bool get isDesktop => screenWidth >= 1024;
 
 // Obtenir le thème actuel
 ThemeData get theme => Theme.of(this);
 
 // Obtenir le schéma de couleurs
 ColorScheme get colorScheme => Theme.of(this).colorScheme;
 
 // Obtenir le style de texte
 TextTheme get textTheme => theme.textTheme;
 
 // Afficher un snackbar
 void showSnackBar(String message, {Color? backgroundColor}) {
 ScaffoldMessenger.of(this).showSnackBar(
 SnackBar(
 content: Text(message),
 backgroundColor: backgroundColor ?? colorScheme.error,
 behavior: SnackBarBehavior.floating,
 ),
 );
 }
 
 // Afficher un dialogue de confirmation
 Future<bool?> showConfirmationDialog({
 required String title,
 required String content,
 String confirmText = 'Confirmer',
 String cancelText = 'Annuler',
 }) {
 return showDialog<bool>(
 context: this,
 builder: (context) => AlertDialog(
 title: Text(title),
 content: Text(content),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(false),
 child: Text(cancelText),
 ),
 ElevatedButton(
 onPressed: () => Navigator.of(context).pop(true),
 child: Text(confirmText),
 ),
 ],
 ),
 );
 }
 
 // Masquer le clavier
 void hideKeyboard() {
 FocusScope.of(this).unfocus();
 }
}

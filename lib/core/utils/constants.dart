class AppConstants {
 // Informations sur l'application
 static const String appName = 'Aramco SA';
 static const String appVersion = '1.0.0';
 static const String appDescription = 'Solution de gestion d\'entreprise intégrée';

 // Configuration API
 static const String apiBaseUrl = 'http://localhost:8000/api/v1';
 static const String apiVersion = 'v1';
 static const String apiTimeout = '30'; // secondes
 
 // Endpoints API principaux
 static const String loginEndpoint = '/auth/login';
 static const String registerEndpoint = '/auth/register';
 static const String logoutEndpoint = '/auth/logout';
 static const String profileEndpoint = '/auth/me';
 static const String usersEndpoint = '/users';
 static const String employeesEndpoint = '/employees';
 static const String performanceReviewsEndpoint = '/performance-reviews';
 static const String leaveRequestsEndpoint = '/leave/requests';
 static const String leaveTypesEndpoint = '/leave/types';
 static const String leaveBalancesEndpoint = '/leave/balances';
 static const String ordersEndpoint = '/orders';
 static const String productsEndpoint = '/products';
 static const String suppliersEndpoint = '/suppliers';
 static const String deliveriesEndpoint = '/deliveries';
 static const String accountingEndpoint = '/accounting/transactions';
 static const String taxEndpoint = '/tax/declarations';
 static const String dashboardEndpoint = '/dashboard';
 static const String dashboardWidgetsEndpoint = '/dashboard/widgets';
 static const String reportsEndpoint = '/reports';
 static const String exportPdfEndpoint = '/export/pdf';
 static const String exportExcelEndpoint = '/export/excel';
 static const String healthEndpoint = '/health';
 static const String searchEndpoint = '/search';

 // Clés de stockage sécurisé
 static const String tokenKey = 'auth_token';
 static const String refreshTokenKey = 'refresh_token';
 static const String userKey = 'user_data';
 static const String languageKey = 'app_language';
 static const String themeKey = 'app_theme';
 static const String biometricKey = 'biometric_enabled';

 // Rôles utilisateurs
 static const List<String> userRoles = [
 'admin',
 'manager',
 'operator',
 'rh',
 'comptable',
 'logistique',
 ];

 // Statuts des commandes
 static const List<String> orderStatuses = [
 'pending',
 'approved',
 'processing',
 'delivered',
 'cancelled',
 'rejected',
 ];

 // Statuts des livraisons
 static const List<String> deliveryStatuses = [
 'preparing',
 'in_transit',
 'delivered',
 'cancelled',
 ];

 // Types de transactions comptables
 static const List<String> transactionTypes = [
 'income',
 'expense',
 'transfer',
 ];

 // Types de taxes
 static const List<String> taxTypes = [
 'vat',
 'income_tax',
 'corporate_tax',
 ];

 // Langues supportées
 static const List<String> supportedLanguages = [
 'fr',
 'en',
 'ar',
 ];

 // Devise par défaut
 static const String defaultCurrency = 'XOF'; // FCFA
 static const List<String> supportedCurrencies = [
 'XOF', // FCFA
 'EUR', // Euro
 'USD', // Dollar américain
 ];

 // Formats de date et heure
 static const String dateFormat = 'dd/MM/yyyy';
 static const String timeFormat = 'HH:mm';
 static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
 static const String apiDateFormat = 'yyyy-MM-dd';
 static const String apiDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

 // Limites et contraintes
 static const int maxLoginAttempts = 3;
 static const int sessionTimeoutMinutes = 30;
 static const int passwordMinLength = 8;
 static const int maxFileSizeMB = 10;
 static const int paginationSize = 20;

 // Messages d'erreur
 static const String networkErrorMessage = 'Erreur de connexion. Vérifiez votre réseau.';
 static const String serverErrorMessage = 'Erreur serveur. Veuillez réessayer plus tard.';
 static const String unauthorizedMessage = 'Session expirée. Veuillez vous reconnecter.';
 static const String forbiddenMessage = 'Accès non autorisé.';
 static const String notFoundMessage = 'Ressource introuvable.';
 static const String validationErrorMessage = 'Veuillez corriger les erreurs dans le formulaire.';

 // Messages de succès
 static const String loginSuccessMessage = 'Connexion réussie';
 static const String logoutSuccessMessage = 'Déconnexion réussie';
 static const String saveSuccessMessage = 'Enregistrement réussi';
 static const String deleteSuccessMessage = 'Suppression réussie';
 static const String updateSuccessMessage = 'Mise à jour réussie';

 // Patterns de validation
 static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
 static const String phonePattern = r'^\+?[0-9]{10,15}$';
 static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

 // Dimensions et tailles
 static const double defaultPadding = 16.0;
 static const double defaultMargin = 16.0;
 static const double defaultBorderRadius = 8.0;
 static const double defaultElevation = 2.0;

 // Espacements
 static const double spacingXS = 4.0;
 static const double spacingSM = 8.0;
 static const double spacingMD = 16.0;
 static const double spacingLG = 24.0;
 static const double spacingXL = 32.0;

 // Animations
 static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
 static const Duration shortAnimationDuration = Duration(milliseconds: 150);
 static const Duration longAnimationDuration = Duration(milliseconds: 500);

 // URLs externes
 static const String supportUrl = 'https://support.aramco-sa.com';
 static const String documentationUrl = 'https://docs.aramco-sa.com';
 static const String privacyPolicyUrl = 'https://aramco-sa.com/privacy';
 static const String termsOfServiceUrl = 'https://aramco-sa.com/terms';

 // Configuration des notifications
 static const String notificationChannelId = 'aramco_notifications';
 static const String notificationChannelName = 'Aramco SA Notifications';
 static const String notificationChannelDescription = 'Notifications importantes de l\'application Aramco SA';

 // Clés pour les préférences partagées
 static const String firstLaunchKey = 'first_launch';
 static const String lastSyncKey = 'last_sync';
 static const String offlineModeKey = 'offline_mode';
 static const String autoBackupKey = 'auto_backup';

 // Configuration du cache
 static const int cacheMaxSize = 100; // MB
 static const Duration cacheExpiration = Duration(hours: 24);

 // Configuration des logs
 static const String logFileName = 'aramco_app.log';
 static const int maxLogFileSize = 5; // MB
 static const int maxLogFiles = 3;

 // Configuration de la sécurité
 static const int maxConcurrentSessions = 3;
 static const Duration inactivityTimeout = Duration(minutes: 15);
 static const Duration lockoutDuration = Duration(minutes: 5);

 // Configuration des exports
 static const List<String> supportedExportFormats = [
 'pdf',
 'excel',
 'csv',
 ];

 // Configuration des imports
 static const List<String> supportedImportFormats = [
 'excel',
 'csv',
 ];

 // Types de fichiers supportés
 static const List<String> supportedImageFormats = [
 'jpg',
 'jpeg',
 'png',
 'gif',
 'webp',
 ];

 static const List<String> supportedDocumentFormats = [
 'pdf',
 'doc',
 'docx',
 'xls',
 'xlsx',
 'csv',
 ];

 // Configuration des rapports
 static const List<String> reportTypes = [
 'daily',
 'weekly',
 'monthly',
 'quarterly',
 'yearly',
 ];

 // Configuration des alertes
 static const List<String> alertTypes = [
 'info',
 'warning',
 'error',
 'success',
 ];

 // Configuration des widgets du dashboard
 static const List<String> dashboardWidgetTypes = [
 'kpi',
 'chart',
 'table',
 'alert',
 'quick_action',
 ];

 // Configuration des permissions
 static const Map<String, List<String>> rolePermissions = {
 'admin': [
 'users.create',
 'users.read',
 'users.update',
 'users.delete',
 'employees.create',
 'employees.read',
 'employees.update',
 'employees.delete',
 'orders.create',
 'orders.read',
 'orders.update',
 'orders.delete',
 'deliveries.create',
 'deliveries.read',
 'deliveries.update',
 'deliveries.delete',
 'accounting.create',
 'accounting.read',
 'accounting.update',
 'accounting.delete',
 'tax.create',
 'tax.read',
 'tax.update',
 'tax.delete',
 'dashboard.read',
 'export.create',
 ],
 'manager': [
 'employees.read',
 'employees.update',
 'orders.create',
 'orders.read',
 'orders.update',
 'deliveries.read',
 'deliveries.update',
 'accounting.read',
 'dashboard.read',
 'export.create',
 ],
 'operator': [
 'orders.create',
 'orders.read',
 'orders.update',
 'deliveries.read',
 'dashboard.read',
 ],
 'rh': [
 'employees.create',
 'employees.read',
 'employees.update',
 'dashboard.read',
 'export.create',
 ],
 'comptable': [
 'accounting.create',
 'accounting.read',
 'accounting.update',
 'tax.create',
 'tax.read',
 'tax.update',
 'dashboard.read',
 'export.create',
 ],
 'logistique': [
 'deliveries.create',
 'deliveries.read',
 'deliveries.update',
 'orders.read',
 'dashboard.read',
 ],
 };
}


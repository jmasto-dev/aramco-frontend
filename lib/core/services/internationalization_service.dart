import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
 final Locale locale;

 AppLocalizations(this.locale);

 static const LocalizationsDelegate<AppLocalizations> delegate =
 _AppLocalizationsDelegate();

 static AppLocalizations of(BuildContext context) {
 return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
 }

 // Général
 String get appName => _localizedValues[locale.languageCode]?['appName'] ?? 'Aramco Frontend';
 String get ok => _localizedValues[locale.languageCode]?['ok'] ?? 'OK';
 String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
 String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
 String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
 String get edit => _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
 String get add => _localizedValues[locale.languageCode]?['add'] ?? 'Add';
 String get search => _localizedValues[locale.languageCode]?['search'] ?? 'Search';
 String get filter => _localizedValues[locale.languageCode]?['filter'] ?? 'Filter';
 String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
 String get error => _localizedValues[locale.languageCode]?['error'] ?? 'Error';
 String get success => _localizedValues[locale.languageCode]?['success'] ?? 'Success';
 String get warning => _localizedValues[locale.languageCode]?['warning'] ?? 'Warning';
 String get info => _localizedValues[locale.languageCode]?['info'] ?? 'Information';

 // Navigation
 String get dashboard => _localizedValues[locale.languageCode]?['dashboard'] ?? 'Dashboard';
 String get employees => _localizedValues[locale.languageCode]?['employees'] ?? 'Employees';
 String get orders => _localizedValues[locale.languageCode]?['orders'] ?? 'Orders';
 String get reports => _localizedValues[locale.languageCode]?['reports'] ?? 'Reports';
 String get notifications => _localizedValues[locale.languageCode]?['notifications'] ?? 'Notifications';
 String get messages => _localizedValues[locale.languageCode]?['messages'] ?? 'Messages';
 String get tasks => _localizedValues[locale.languageCode]?['tasks'] ?? 'Tasks';
 String get stocks => _localizedValues[locale.languageCode]?['stocks'] ?? 'Stocks';
 String get suppliers => _localizedValues[locale.languageCode]?['suppliers'] ?? 'Suppliers';
 String get purchases => _localizedValues[locale.languageCode]?['purchases'] ?? 'Purchases';
 String get taxes => _localizedValues[locale.languageCode]?['taxes'] ?? 'Taxes';
 String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
 String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
 String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';

 // Authentification
 String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Login';
 String get email => _localizedValues[locale.languageCode]?['email'] ?? 'Email';
 String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Password';
 String get forgotPassword => _localizedValues[locale.languageCode]?['forgotPassword'] ?? 'Forgot Password?';
 String get rememberMe => _localizedValues[locale.languageCode]?['rememberMe'] ?? 'Remember Me';
 String get loginSuccess => _localizedValues[locale.languageCode]?['loginSuccess'] ?? 'Login successful';
 String get loginError => _localizedValues[locale.languageCode]?['loginError'] ?? 'Login failed';
 String get invalidCredentials => _localizedValues[locale.languageCode]?['invalidCredentials'] ?? 'Invalid credentials';

 // Employés
 String get employeeName => _localizedValues[locale.languageCode]?['employeeName'] ?? 'Employee Name';
 String get employeeEmail => _localizedValues[locale.languageCode]?['employeeEmail'] ?? 'Employee Email';
 String get employeePhone => _localizedValues[locale.languageCode]?['employeePhone'] ?? 'Employee Phone';
 String get employeeDepartment => _localizedValues[locale.languageCode]?['employeeDepartment'] ?? 'Department';
 String get employeePosition => _localizedValues[locale.languageCode]?['employeePosition'] ?? 'Position';
 String get employeeSalary => _localizedValues[locale.languageCode]?['employeeSalary'] ?? 'Salary';
 String get employeeStatus => _localizedValues[locale.languageCode]?['employeeStatus'] ?? 'Status';
 String get active => _localizedValues[locale.languageCode]?['active'] ?? 'Active';
 String get inactive => _localizedValues[locale.languageCode]?['inactive'] ?? 'Inactive';
 String get onLeave => _localizedValues[locale.languageCode]?['onLeave'] ?? 'On Leave';

 // Commandes
 String get orderReference => _localizedValues[locale.languageCode]?['orderReference'] ?? 'Order Reference';
 String get orderDate => _localizedValues[locale.languageCode]?['orderDate'] ?? 'Order Date';
 String get orderStatus => _localizedValues[locale.languageCode]?['orderStatus'] ?? 'Order Status';
 String get orderTotal => _localizedValues[locale.languageCode]?['orderTotal'] ?? 'Order Total';
 String get orderCustomer => _localizedValues[locale.languageCode]?['orderCustomer'] ?? 'Customer';
 String get pending => _localizedValues[locale.languageCode]?['pending'] ?? 'Pending';
 String get processing => _localizedValues[locale.languageCode]?['processing'] ?? 'Processing';
 String get shipped => _localizedValues[locale.languageCode]?['shipped'] ?? 'Shipped';
 String get delivered => _localizedValues[locale.languageCode]?['delivered'] ?? 'Delivered';
 String get cancelled => _localizedValues[locale.languageCode]?['cancelled'] ?? 'Cancelled';

 // Rapports
 String get reportType => _localizedValues[locale.languageCode]?['reportType'] ?? 'Report Type';
 String get reportPeriod => _localizedValues[locale.languageCode]?['reportPeriod'] ?? 'Report Period';
 String get generateReport => _localizedValues[locale.languageCode]?['generateReport'] ?? 'Generate Report';
 String get exportReport => _localizedValues[locale.languageCode]?['exportReport'] ?? 'Export Report';
 String get employeeReport => _localizedValues[locale.languageCode]?['employeeReport'] ?? 'Employee Report';
 String get orderReport => _localizedValues[locale.languageCode]?['orderReport'] ?? 'Order Report';
 String get financialReport => _localizedValues[locale.languageCode]?['financialReport'] ?? 'Financial Report';

 // Notifications
 String get notificationTitle => _localizedValues[locale.languageCode]?['notificationTitle'] ?? 'Notification Title';
 String get notificationMessage => _localizedValues[locale.languageCode]?['notificationMessage'] ?? 'Notification Message';
 String get notificationDate => _localizedValues[locale.languageCode]?['notificationDate'] ?? 'Notification Date';
 String get markAsRead => _localizedValues[locale.languageCode]?['markAsRead'] ?? 'Mark as Read';
 String get markAsUnread => _localizedValues[locale.languageCode]?['markAsUnread'] ?? 'Mark as Unread';
 String get allNotifications => _localizedValues[locale.languageCode]?['allNotifications'] ?? 'All Notifications';
 String get unreadNotifications => _localizedValues[locale.languageCode]?['unreadNotifications'] ?? 'Unread Notifications';

 // Messages
 String get messageSubject => _localizedValues[locale.languageCode]?['messageSubject'] ?? 'Subject';
 String get messageContent => _localizedValues[locale.languageCode]?['messageContent'] ?? 'Message';
 String get sendMessage => _localizedValues[locale.languageCode]?['sendMessage'] ?? 'Send Message';
 String get recipient => _localizedValues[locale.languageCode]?['recipient'] ?? 'Recipient';
 String get compose => _localizedValues[locale.languageCode]?['compose'] ?? 'Compose';
 String get inbox => _localizedValues[locale.languageCode]?['inbox'] ?? 'Inbox';
 String get sent => _localizedValues[locale.languageCode]?['sent'] ?? 'Sent';
 String get drafts => _localizedValues[locale.languageCode]?['drafts'] ?? 'Drafts';

 // Tâches
 String get taskTitle => _localizedValues[locale.languageCode]?['taskTitle'] ?? 'Task Title';
 String get taskDescription => _localizedValues[locale.languageCode]?['taskDescription'] ?? 'Task Description';
 String get taskPriority => _localizedValues[locale.languageCode]?['taskPriority'] ?? 'Priority';
 String get taskDueDate => _localizedValues[locale.languageCode]?['taskDueDate'] ?? 'Due Date';
 String get taskAssignee => _localizedValues[locale.languageCode]?['taskAssignee'] ?? 'Assignee';
 String get high => _localizedValues[locale.languageCode]?['high'] ?? 'High';
 String get medium => _localizedValues[locale.languageCode]?['medium'] ?? 'Medium';
 String get low => _localizedValues[locale.languageCode]?['low'] ?? 'Low';
 String get completed => _localizedValues[locale.languageCode]?['completed'] ?? 'Completed';
 String get inProgress => _localizedValues[locale.languageCode]?['inProgress'] ?? 'In Progress';
 String get todo => _localizedValues[locale.languageCode]?['todo'] ?? 'To Do';

 // Stocks
 String get productName => _localizedValues[locale.languageCode]?['productName'] ?? 'Product Name';
 String get productQuantity => _localizedValues[locale.languageCode]?['productQuantity'] ?? 'Quantity';
 String get productPrice => _localizedValues[locale.languageCode]?['productPrice'] ?? 'Price';
 String get warehouse => _localizedValues[locale.languageCode]?['warehouse'] ?? 'Warehouse';
 String get stockAlert => _localizedValues[locale.languageCode]?['stockAlert'] ?? 'Stock Alert';
 String get lowStock => _localizedValues[locale.languageCode]?['lowStock'] ?? 'Low Stock';
 String get outOfStock => _localizedValues[locale.languageCode]?['outOfStock'] ?? 'Out of Stock';

 // Fournisseurs
 String get supplierName => _localizedValues[locale.languageCode]?['supplierName'] ?? 'Supplier Name';
 String get supplierContact => _localizedValues[locale.languageCode]?['supplierContact'] ?? 'Contact';
 String get supplierAddress => _localizedValues[locale.languageCode]?['supplierAddress'] ?? 'Address';
 String get supplierPhone => _localizedValues[locale.languageCode]?['supplierPhone'] ?? 'Phone';
 String get supplierEmail => _localizedValues[locale.languageCode]?['supplierEmail'] ?? 'Email';

 // Taxes
 String get taxType => _localizedValues[locale.languageCode]?['taxType'] ?? 'Tax Type';
 String get taxAmount => _localizedValues[locale.languageCode]?['taxAmount'] ?? 'Tax Amount';
 String get taxRate => _localizedValues[locale.languageCode]?['taxRate'] ?? 'Tax Rate';
 String get taxPeriod => _localizedValues[locale.languageCode]?['taxPeriod'] ?? 'Tax Period';
 String get taxDeclaration => _localizedValues[locale.languageCode]?['taxDeclaration'] ?? 'Tax Declaration';

 // Validation
 String get fieldRequired => _localizedValues[locale.languageCode]?['fieldRequired'] ?? 'This field is required';
 String get invalidEmail => _localizedValues[locale.languageCode]?['invalidEmail'] ?? 'Invalid email address';
 String get invalidPhone => _localizedValues[locale.languageCode]?['invalidPhone'] ?? 'Invalid phone number';
 String get invalidNumber => _localizedValues[locale.languageCode]?['invalidNumber'] ?? 'Invalid number';
 String get minLength => _localizedValues[locale.languageCode]?['minLength'] ?? 'Minimum length is';
 String get maxLength => _localizedValues[locale.languageCode]?['maxLength'] ?? 'Maximum length is';

 // Messages de succès
 String get saveSuccess => _localizedValues[locale.languageCode]?['saveSuccess'] ?? 'Saved successfully';
 String get deleteSuccess => _localizedValues[locale.languageCode]?['deleteSuccess'] ?? 'Deleted successfully';
 String get updateSuccess => _localizedValues[locale.languageCode]?['updateSuccess'] ?? 'Updated successfully';
 String get createSuccess => _localizedValues[locale.languageCode]?['createSuccess'] ?? 'Created successfully';
 String get sendSuccess => _localizedValues[locale.languageCode]?['sendSuccess'] ?? 'Sent successfully';

 // Messages d'erreur
 String get networkError => _localizedValues[locale.languageCode]?['networkError'] ?? 'Network error';
 String get serverError => _localizedValues[locale.languageCode]?['serverError'] ?? 'Server error';
 String get unauthorized => _localizedValues[locale.languageCode]?['unauthorized'] ?? 'Unauthorized access';
 String get forbidden => _localizedValues[locale.languageCode]?['forbidden'] ?? 'Access forbidden';
 String get notFound => _localizedValues[locale.languageCode]?['notFound'] ?? 'Resource not found';

 // Confirmation
 String get confirmDelete => _localizedValues[locale.languageCode]?['confirmDelete'] ?? 'Are you sure you want to delete this item?';
 String get confirm => _localizedValues[locale.languageCode]?['confirm'] ?? 'Confirm';
 String get yes => _localizedValues[locale.languageCode]?['yes'] ?? 'Yes';
 String get no => _localizedValues[locale.languageCode]?['no'] ?? 'No';

 static const Map<String, Map<String, String>> _localizedValues = {
 'en': {
 'appName': 'Aramco Frontend',
 'ok': 'OK',
 'cancel': 'Cancel',
 'save': 'Save',
 'delete': 'Delete',
 'edit': 'Edit',
 'add': 'Add',
 'search': 'Search',
 'filter': 'Filter',
 'loading': 'Loading...',
 'error': 'Error',
 'success': 'Success',
 'warning': 'Warning',
 'info': 'Information',
 'dashboard': 'Dashboard',
 'employees': 'Employees',
 'orders': 'Orders',
 'reports': 'Reports',
 'notifications': 'Notifications',
 'messages': 'Messages',
 'tasks': 'Tasks',
 'stocks': 'Stocks',
 'suppliers': 'Suppliers',
 'purchases': 'Purchases',
 'taxes': 'Taxes',
 'settings': 'Settings',
 'profile': 'Profile',
 'logout': 'Logout',
 'login': 'Login',
 'email': 'Email',
 'password': 'Password',
 'forgotPassword': 'Forgot Password?',
 'rememberMe': 'Remember Me',
 'loginSuccess': 'Login successful',
 'loginError': 'Login failed',
 'invalidCredentials': 'Invalid credentials',
 'employeeName': 'Employee Name',
 'employeeEmail': 'Employee Email',
 'employeePhone': 'Employee Phone',
 'employeeDepartment': 'Department',
 'employeePosition': 'Position',
 'employeeSalary': 'Salary',
 'employeeStatus': 'Status',
 'active': 'Active',
 'inactive': 'Inactive',
 'onLeave': 'On Leave',
 'orderReference': 'Order Reference',
 'orderDate': 'Order Date',
 'orderStatus': 'Order Status',
 'orderTotal': 'Order Total',
 'orderCustomer': 'Customer',
 'pending': 'Pending',
 'processing': 'Processing',
 'shipped': 'Shipped',
 'delivered': 'Delivered',
 'cancelled': 'Cancelled',
 'reportType': 'Report Type',
 'reportPeriod': 'Report Period',
 'generateReport': 'Generate Report',
 'exportReport': 'Export Report',
 'employeeReport': 'Employee Report',
 'orderReport': 'Order Report',
 'financialReport': 'Financial Report',
 'notificationTitle': 'Notification Title',
 'notificationMessage': 'Notification Message',
 'notificationDate': 'Notification Date',
 'markAsRead': 'Mark as Read',
 'markAsUnread': 'Mark as Unread',
 'allNotifications': 'All Notifications',
 'unreadNotifications': 'Unread Notifications',
 'messageSubject': 'Subject',
 'messageContent': 'Message',
 'sendMessage': 'Send Message',
 'recipient': 'Recipient',
 'compose': 'Compose',
 'inbox': 'Inbox',
 'sent': 'Sent',
 'drafts': 'Drafts',
 'taskTitle': 'Task Title',
 'taskDescription': 'Task Description',
 'taskPriority': 'Priority',
 'taskDueDate': 'Due Date',
 'taskAssignee': 'Assignee',
 'high': 'High',
 'medium': 'Medium',
 'low': 'Low',
 'completed': 'Completed',
 'inProgress': 'In Progress',
 'todo': 'To Do',
 'productName': 'Product Name',
 'productQuantity': 'Quantity',
 'productPrice': 'Price',
 'warehouse': 'Warehouse',
 'stockAlert': 'Stock Alert',
 'lowStock': 'Low Stock',
 'outOfStock': 'Out of Stock',
 'supplierName': 'Supplier Name',
 'supplierContact': 'Contact',
 'supplierAddress': 'Address',
 'supplierPhone': 'Phone',
 'supplierEmail': 'Email',
 'taxType': 'Tax Type',
 'taxAmount': 'Tax Amount',
 'taxRate': 'Tax Rate',
 'taxPeriod': 'Tax Period',
 'taxDeclaration': 'Tax Declaration',
 'fieldRequired': 'This field is required',
 'invalidEmail': 'Invalid email address',
 'invalidPhone': 'Invalid phone number',
 'invalidNumber': 'Invalid number',
 'minLength': 'Minimum length is',
 'maxLength': 'Maximum length is',
 'saveSuccess': 'Saved successfully',
 'deleteSuccess': 'Deleted successfully',
 'updateSuccess': 'Updated successfully',
 'createSuccess': 'Created successfully',
 'sendSuccess': 'Sent successfully',
 'networkError': 'Network error',
 'serverError': 'Server error',
 'unauthorized': 'Unauthorized access',
 'forbidden': 'Access forbidden',
 'notFound': 'Resource not found',
 'confirmDelete': 'Are you sure you want to delete this item?',
 'confirm': 'Confirm',
 'yes': 'Yes',
 'no': 'No',
},
 'fr': {
 'appName': 'Aramco Frontend',
 'ok': 'OK',
 'cancel': 'Annuler',
 'save': 'Enregistrer',
 'delete': 'Supprimer',
 'edit': 'Modifier',
 'add': 'Ajouter',
 'search': 'Rechercher',
 'filter': 'Filtrer',
 'loading': 'Chargement...',
 'error': 'Erreur',
 'success': 'Succès',
 'warning': 'Avertissement',
 'info': 'Information',
 'dashboard': 'Tableau de Bord',
 'employees': 'Employés',
 'orders': 'Commandes',
 'reports': 'Rapports',
 'notifications': 'Notifications',
 'messages': 'Messages',
 'tasks': 'Tâches',
 'stocks': 'Stocks',
 'suppliers': 'Fournisseurs',
 'purchases': 'Achats',
 'taxes': 'Taxes',
 'settings': 'Paramètres',
 'profile': 'Profil',
 'logout': 'Déconnexion',
 'login': 'Se connecter',
 'email': 'Email',
 'password': 'Mot de passe',
 'forgotPassword': 'Mot de passe oublié?',
 'rememberMe': 'Se souvenir de moi',
 'loginSuccess': 'Connexion réussie',
 'loginError': 'Connexion échouée',
 'invalidCredentials': 'Identifiants incorrects',
 'employeeName': 'Nom de l\'employé',
 'employeeEmail': 'Email de l\'employé',
 'employeePhone': 'Téléphone de l\'employé',
 'employeeDepartment': 'Département',
 'employeePosition': 'Poste',
 'employeeSalary': 'Salaire',
 'employeeStatus': 'Statut',
 'active': 'Actif',
 'inactive': 'Inactif',
 'onLeave': 'En congé',
 'orderReference': 'Référence commande',
 'orderDate': 'Date commande',
 'orderStatus': 'Statut commande',
 'orderTotal': 'Total commande',
 'orderCustomer': 'Client',
 'pending': 'En attente',
 'processing': 'En cours',
 'shipped': 'Expédiée',
 'delivered': 'Livrée',
 'cancelled': 'Annulée',
 'reportType': 'Type de rapport',
 'reportPeriod': 'Période du rapport',
 'generateReport': 'Générer le rapport',
 'exportReport': 'Exporter le rapport',
 'employeeReport': 'Rapport des employés',
 'orderReport': 'Rapport des commandes',
 'financialReport': 'Rapport financier',
 'notificationTitle': 'Titre de la notification',
 'notificationMessage': 'Message de la notification',
 'notificationDate': 'Date de la notification',
 'markAsRead': 'Marquer comme lu',
 'markAsUnread': 'Marquer comme non lu',
 'allNotifications': 'Toutes les notifications',
 'unreadNotifications': 'Notifications non lues',
 'messageSubject': 'Sujet',
 'messageContent': 'Message',
 'sendMessage': 'Envoyer le message',
 'recipient': 'Destinataire',
 'compose': 'Composer',
 'inbox': 'Boîte de réception',
 'sent': 'Envoyés',
 'drafts': 'Brouillons',
 'taskTitle': 'Titre de la tâche',
 'taskDescription': 'Description de la tâche',
 'taskPriority': 'Priorité',
 'taskDueDate': 'Date d\'échéance',
 'taskAssignee': 'Assigné à',
 'high': 'Élevée',
 'medium': 'Moyenne',
 'low': 'Basse',
 'completed': 'Terminée',
 'inProgress': 'En cours',
 'todo': 'À faire',
 'productName': 'Nom du produit',
 'productQuantity': 'Quantité',
 'productPrice': 'Prix',
 'warehouse': 'Entrepôt',
 'stockAlert': 'Alerte de stock',
 'lowStock': 'Stock faible',
 'outOfStock': 'Rupture de stock',
 'supplierName': 'Nom du fournisseur',
 'supplierContact': 'Contact',
 'supplierAddress': 'Adresse',
 'supplierPhone': 'Téléphone',
 'supplierEmail': 'Email',
 'taxType': 'Type de taxe',
 'taxAmount': 'Montant de la taxe',
 'taxRate': 'Taux de taxe',
 'taxPeriod': 'Période fiscale',
 'taxDeclaration': 'Déclaration fiscale',
 'fieldRequired': 'Ce champ est requis',
 'invalidEmail': 'Adresse email invalide',
 'invalidPhone': 'Numéro de téléphone invalide',
 'invalidNumber': 'Numéro invalide',
 'minLength': 'La longueur minimale est de',
 'maxLength': 'La longueur maximale est de',
 'saveSuccess': 'Enregistré avec succès',
 'deleteSuccess': 'Supprimé avec succès',
 'updateSuccess': 'Mis à jour avec succès',
 'createSuccess': 'Créé avec succès',
 'sendSuccess': 'Envoyé avec succès',
 'networkError': 'Erreur réseau',
 'serverError': 'Erreur serveur',
 'unauthorized': 'Accès non autorisé',
 'forbidden': 'Accès interdit',
 'notFound': 'Ressource non trouvée',
 'confirmDelete': 'Êtes-vous sûr de vouloir supprimer cet élément?',
 'confirm': 'Confirmer',
 'yes': 'Oui',
 'no': 'Non',
},
 };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
 const _AppLocalizationsDelegate();

 @override
 bool isSupported(Locale locale) {
 return AppLocalizations._localizedValues.containsKey(locale.languageCode);
 }

 @override
 Future<AppLocalizations> load(Locale locale) {async {
 return AppLocalizations(locale);
 }

 @override
 bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

class InternationalizationService {
 static List<Locale> get supportedLocales => [
 const Locale('en', 'US'), // English
 const Locale('fr', 'FR'), // French
 ];

 static Locale? get fallbackLocale => const Locale('en', 'US');

 static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
 AppLocalizations.delegate,
 GlobalMaterialLocalizations.delegate,
 GlobalWidgetsLocalizations.delegate,
 GlobalCupertinoLocalizations.delegate,
 ];

 static bool isLocaleSupported(Locale locale) {
 return supportedLocales.any((supportedLocale) =>
 supportedLocale.languageCode == locale.languageCode);
 }

 static Locale getSystemLocale() {
 // Get system locale and fallback to English if not supported
 final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
 if (isLocaleSupported(systemLocale)){ {
 return systemLocale;
}
 return fallbackLocale!;
 }

 static String getLocaleDisplayName(Locale locale) {
 switch (locale.languageCode) {
 case 'en':
 return 'English';
 case 'fr':
 return 'Français';
 default:
 return locale.languageCode.toUpperCase();
}
 }

 static String getLocaleNativeName(Locale locale) {
 switch (locale.languageCode) {
 case 'en':
 return 'English';
 case 'fr':
 return 'Français';
 default:
 return locale.languageCode.toUpperCase();
}
 }
}

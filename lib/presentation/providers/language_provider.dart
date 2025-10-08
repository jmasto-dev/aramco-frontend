import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/constants.dart';
import '../../core/providers/service_providers.dart';

// État de la langue
class \1 extends ChangeNotifier {
 final Locale locale;
 final bool isLoading;

 const LanguageState({
 this.locale = const Locale('fr', 'FR'),
 this.isLoading = false,
 });

 LanguageState copyWith({
 Locale? locale,
 bool? isLoading,
 }) {
 return LanguageState(
 locale: locale ?? this.locale,
 isLoading: isLoading ?? this.isLoading,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is LanguageState &&
 other.locale == locale &&
 other.isLoading == isLoading;
 }

 @override
 int get hashCode {
 return Object.hash(locale, isLoading);
 }
}

// Provider pour la gestion de la langue
class LanguageNotifier extends StateNotifier<LanguageState> {
 final StorageService _storageService;

 LanguageNotifier(this._storageService) : super(const LanguageState()) {
 _loadLanguage();
 }

 // Charger la langue sauvegardée
 Future<void> _loadLanguage() {async {
 try {
 state = state.copyWith(isLoading: true);

 final savedLanguage = _storageService.getLanguage();
 
 if (savedLanguage != null) {{
 final locale = _parseLocale(savedLanguage);
 state = state.copyWith(locale: locale, isLoading: false);
 } else {
 // Utiliser la langue du système par défaut
 final systemLocale = _getSystemLocale();
 state = state.copyWith(locale: systemLocale, isLoading: false);
 }
} catch (e) {
 // En cas d'erreur, utiliser le français par défaut
 state = state.copyWith(
 locale: const Locale('fr', 'FR'),
 isLoading: false,
 );
}
 }

 // Parser la langue depuis une chaîne
 Locale _parseLocale(String languageCode) {
 final parts = languageCode.split('_');
 if (parts.length >= 2) {{
 return Locale(parts[0], parts[1]);
} else if (parts.length == 1) {{
 return Locale(parts[0]);
}
 return const Locale('fr', 'FR');
 }

 // Obtenir la langue du système
 Locale _getSystemLocale() {
 // Dans une vraie application, vous utiliseriez:
 // return WidgetsBinding.instance.platformDispatcher.locale;
 // Pour l'instant, on retourne le français par défaut
 return const Locale('fr', 'FR');
 }

 // Changer la langue
 Future<void> setLanguage(Locale locale) {async {
 try {
 state = state.copyWith(isLoading: true);

 // Sauvegarder la langue
 final languageString = '${locale.languageCode}_${locale.countryCode ?? ''}';
 await _storageService.saveLanguage(languageString);

 // Mettre à jour l'état
 state = state.copyWith(locale: locale, isLoading: false);
} catch (e) {
 // En cas d'erreur, ne pas changer la langue
 state = state.copyWith(isLoading: false);
}
 }

 // Changer la langue par code de langue
 Future<void> setLanguageByCode(String languageCode) {async {
 final locale = _parseLocale(languageCode);
 await setLanguage(locale);
 }

 // Activer le français
 Future<void> setFrench() {async {
 await setLanguage(const Locale('fr', 'FR'));
 }

 // Activer l'anglais
 Future<void> setEnglish() {async {
 await setLanguage(const Locale('en', 'US'));
 }

 // Activer l'arabe
 Future<void> setArabic() {async {
 await setLanguage(const Locale('ar', 'SA'));
 }

 // Obtenir le nom de la langue actuelle
 String getLanguageName() {
 switch (state.locale.languageCode) {
 case 'fr':
 return 'Français';
 case 'en':
 return 'English';
 case 'ar':
 return 'العربية';
 default:
 return state.locale.languageCode.toUpperCase();
}
 }

 // Obtenir le drapeau de la langue actuelle
 String getLanguageFlag() {
 switch (state.locale.languageCode) {
 case 'fr':
 return '🇫🇷';
 case 'en':
 return '🇬🇧';
 case 'ar':
 return '🇸🇦';
 default:
 return '🌐';
}
 }

 // Vérifier si la langue est RTL (Right-to-Left)
 bool get isRTL {
 return state.locale.languageCode == 'ar';
 }

 // Obtenir la direction du texte
 TextDirection getTextDirection() {
 return isRTL ? TextDirection.rtl : TextDirection.ltr;
 }

 // Réinitialiser à la langue du système
 Future<void> resetToSystemLanguage() {async {
 final systemLocale = _getSystemLocale();
 await setLanguage(systemLocale);
 }
}

// Provider pour la langue
final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
 return LanguageNotifier(ref.read(storageServiceProvider));
});

// Provider pour la locale actuelle
final localeProvider = Provider<Locale>((ref) {
 return ref.watch(languageProvider).locale;
});

// Provider pour le code de langue actuel
final languageCodeProvider = Provider<String>((ref) {
 return ref.watch(languageProvider).locale.languageCode;
});

// Provider pour le nom de la langue actuelle
final languageNameProvider = Provider<String>((ref) {
 final notifier = ref.watch(languageProvider.notifier);
 return notifier.getLanguageName();
});

// Provider pour le drapeau de la langue actuelle
final languageFlagProvider = Provider<String>((ref) {
 final notifier = ref.watch(languageProvider.notifier);
 return notifier.getLanguageFlag();
});

// Provider pour vérifier si la langue est RTL
final isRTLProvider = Provider<bool>((ref) {
 final notifier = ref.watch(languageProvider.notifier);
 return notifier.isRTL;
});

// Provider pour la direction du texte
final textDirectionProvider = Provider<TextDirection>((ref) {
 final notifier = ref.watch(languageProvider.notifier);
 return notifier.getTextDirection();
});

// Provider pour les langues supportées
final supportedLanguagesProvider = Provider<List<LanguageInfo>>((ref) {
 return [
 LanguageInfo(
 locale: const Locale('fr', 'FR'),
 name: 'Français',
 flag: '🇫🇷',
 isRTL: false,
 ),
 LanguageInfo(
 locale: const Locale('en', 'US'),
 name: 'English',
 flag: '🇬🇧',
 isRTL: false,
 ),
 LanguageInfo(
 locale: const Locale('ar', 'SA'),
 name: 'العربية',
 flag: '🇸🇦',
 isRTL: true,
 ),
 ];
});

// Modèle pour les informations de langue
class \1 extends ChangeNotifier {
 final Locale locale;
 final String name;
 final String flag;
 final bool isRTL;

 const LanguageInfo({
 required this.locale,
 required this.name,
 required this.flag,
 required this.isRTL,
 });

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is LanguageInfo &&
 other.locale == locale &&
 other.name == name &&
 other.flag == flag &&
 other.isRTL == isRTL;
 }

 @override
 int get hashCode {
 return Object.hash(locale, name, flag, isRTL);
 }

 @override
 String toString() {
 return 'LanguageInfo(locale: $locale, name: $name, flag: $flag, isRTL: $isRTL)';
 }
}

// Provider pour les traductions (simulé pour l'instant)
final translationsProvider = Provider<Map<String, Map<String, String>>>((ref) {
 return {
 'fr': {
 'app_name': 'Aramco SA',
 'login': 'Connexion',
 'logout': 'Déconnexion',
 'email': 'Email',
 'password': 'Mot de passe',
 'forgot_password': 'Mot de passe oublié?',
 'login_success': 'Connexion réussie',
 'login_error': 'Erreur de connexion',
 'invalid_credentials': 'Identifiants invalides',
 'network_error': 'Erreur réseau',
 'try_again': 'Réessayer',
 'cancel': 'Annuler',
 'confirm': 'Confirmer',
 'save': 'Enregistrer',
 'delete': 'Supprimer',
 'edit': 'Modifier',
 'add': 'Ajouter',
 'search': 'Rechercher',
 'filter': 'Filtrer',
 'sort': 'Trier',
 'loading': 'Chargement...',
 'no_data': 'Aucune donnée',
 'error': 'Erreur',
 'success': 'Succès',
 'warning': 'Avertissement',
 'info': 'Information',
 'yes': 'Oui',
 'no': 'Non',
 'ok': 'OK',
 'close': 'Fermer',
 'settings': 'Paramètres',
 'profile': 'Profil',
 'dashboard': 'Tableau de bord',
 'employees': 'Employés',
 'orders': 'Commandes',
 'deliveries': 'Livraisons',
 'accounting': 'Comptabilité',
 'tax': 'Fiscalité',
 'reports': 'Rapports',
 'admin': 'Administration',
 'theme': 'Thème',
 'language': 'Langue',
 'light_theme': 'Thème clair',
 'dark_theme': 'Thème sombre',
 'system_theme': 'Thème système',
},
 'en': {
 'app_name': 'Aramco SA',
 'login': 'Login',
 'logout': 'Logout',
 'email': 'Email',
 'password': 'Password',
 'forgot_password': 'Forgot password?',
 'login_success': 'Login successful',
 'login_error': 'Login error',
 'invalid_credentials': 'Invalid credentials',
 'network_error': 'Network error',
 'try_again': 'Try again',
 'cancel': 'Cancel',
 'confirm': 'Confirm',
 'save': 'Save',
 'delete': 'Delete',
 'edit': 'Edit',
 'add': 'Add',
 'search': 'Search',
 'filter': 'Filter',
 'sort': 'Sort',
 'loading': 'Loading...',
 'no_data': 'No data',
 'error': 'Error',
 'success': 'Success',
 'warning': 'Warning',
 'info': 'Information',
 'yes': 'Yes',
 'no': 'No',
 'ok': 'OK',
 'close': 'Close',
 'settings': 'Settings',
 'profile': 'Profile',
 'dashboard': 'Dashboard',
 'employees': 'Employees',
 'orders': 'Orders',
 'deliveries': 'Deliveries',
 'accounting': 'Accounting',
 'tax': 'Tax',
 'reports': 'Reports',
 'admin': 'Administration',
 'theme': 'Theme',
 'language': 'Language',
 'light_theme': 'Light theme',
 'dark_theme': 'Dark theme',
 'system_theme': 'System theme',
},
 'ar': {
 'app_name': 'أرامكو',
 'login': 'تسجيل الدخول',
 'logout': 'تسجيل الخروج',
 'email': 'البريد الإلكتروني',
 'password': 'كلمة المرور',
 'forgot_password': 'نسيت كلمة المرور؟',
 'login_success': 'تم تسجيل الدخول بنجاح',
 'login_error': 'خطأ في تسجيل الدخول',
 'invalid_credentials': 'بيانات الاعتماد غير صالحة',
 'network_error': 'خطأ في الشبكة',
 'try_again': 'حاول مرة أخرى',
 'cancel': 'إلغاء',
 'confirm': 'تأكيد',
 'save': 'حفظ',
 'delete': 'حذف',
 'edit': 'تعديل',
 'add': 'إضافة',
 'search': 'بحث',
 'filter': 'تصفية',
 'sort': 'فرز',
 'loading': 'جاري التحميل...',
 'no_data': 'لا توجد بيانات',
 'error': 'خطأ',
 'success': 'نجاح',
 'warning': 'تحذير',
 'info': 'معلومات',
 'yes': 'نعم',
 'no': 'لا',
 'ok': 'موافق',
 'close': 'إغلاق',
 'settings': 'الإعدادات',
 'profile': 'الملف الشخصي',
 'dashboard': 'لوحة التحكم',
 'employees': 'الموظفون',
 'orders': 'الطلبات',
 'deliveries': 'التوصيلات',
 'accounting': 'المحاسبة',
 'tax': 'الضرائب',
 'reports': 'التقارير',
 'admin': 'الإدارة',
 'theme': 'المظهر',
 'language': 'اللغة',
 'light_theme': 'المظهر الفاتح',
 'dark_theme': 'المظهر الداكن',
 'system_theme': 'مظهر النظام',
},
 };
});

// Extensions utiles pour la langue
extension LanguageExtensions on WidgetRef {
 // Obtenir une traduction
 String translate(String key) {
 final translations = read(translationsProvider);
 final languageCode = read(languageCodeProvider);
 return translations[languageCode]?[key] ?? key;
 }

 // Obtenir la langue actuelle
 Locale get currentLocale => read(localeProvider);

 // Vérifier si la langue est RTL
 bool get isRTL => read(isRTLProvider);

 // Obtenir la direction du texte
 TextDirection get textDirection => read(textDirectionProvider);
}

// Extension pour les traductions directement sur les BuildContext
extension BuildContextLanguageExtensions on BuildContext {
 // Obtenir une traduction
 String translate(String key) {
 // Cette extension nécessiterait d'avoir accès au Provider
 // Pour l'instant, on retourne la clé
 return key;
 }
}

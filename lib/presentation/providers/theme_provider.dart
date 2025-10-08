import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/constants.dart';
import '../../core/providers/service_providers.dart';

// État du thème
class \1 extends ChangeNotifier {
 final ThemeMode themeMode;
 final bool isDarkMode;
 final bool isSystemMode;

 const ThemeState({
 this.themeMode = ThemeMode.system,
 this.isDarkMode = false,
 this.isSystemMode = true,
 });

 ThemeState copyWith({
 ThemeMode? themeMode,
 bool? isDarkMode,
 bool? isSystemMode,
 }) {
 return ThemeState(
 themeMode: themeMode ?? this.themeMode,
 isDarkMode: isDarkMode ?? this.isDarkMode,
 isSystemMode: isSystemMode ?? this.isSystemMode,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is ThemeState &&
 other.themeMode == themeMode &&
 other.isDarkMode == isDarkMode &&
 other.isSystemMode == isSystemMode;
 }

 @override
 int get hashCode {
 return Object.hash(themeMode, isDarkMode, isSystemMode);
 }
}

// Provider pour la gestion du thème
class ThemeNotifier extends StateNotifier<ThemeState> {
 final StorageService _storageService;

 ThemeNotifier(this._storageService) : super(const ThemeState()) {
 _loadTheme();
 }

 // Charger le thème sauvegardé
 Future<void> _loadTheme() {async {
 try {
 final savedTheme = _storageService.getTheme();
 
 if (savedTheme != null) {{
 switch (savedTheme.toLowerCase()) {
 case 'light':
 state = const ThemeState(
 themeMode: ThemeMode.light,
 isDarkMode: false,
 isSystemMode: false,
 );
 break;
 case 'dark':
 state = const ThemeState(
 themeMode: ThemeMode.dark,
 isDarkMode: true,
 isSystemMode: false,
 );
 break;
 case 'system':
 default:
 state = const ThemeState(
 themeMode: ThemeMode.system,
 isDarkMode: false,
 isSystemMode: true,
 );
 break;
 }
 }
} catch (e) {
 // En cas d'erreur, utiliser le thème système par défaut
 state = const ThemeState(
 themeMode: ThemeMode.system,
 isDarkMode: false,
 isSystemMode: true,
 );
}
 }

 // Changer le thème
 Future<void> setTheme(ThemeMode themeMode) {async {
 try {
 String themeString;
 bool isDarkMode;
 bool isSystemMode;

 switch (themeMode) {
 case ThemeMode.light:
 themeString = 'light';
 isDarkMode = false;
 isSystemMode = false;
 break;
 case ThemeMode.dark:
 themeString = 'dark';
 isDarkMode = true;
 isSystemMode = false;
 break;
 case ThemeMode.system:
 default:
 themeString = 'system';
 isDarkMode = false;
 isSystemMode = true;
 break;
 }

 // Sauvegarder le thème
 await _storageService.saveTheme(themeString);

 // Mettre à jour l'état
 state = ThemeState(
 themeMode: themeMode,
 isDarkMode: isDarkMode,
 isSystemMode: isSystemMode,
 );
} catch (e) {
 // En cas d'erreur, ne pas changer le thème
;
 }

 // Activer le thème clair
 Future<void> setLightTheme() {async {
 await setTheme(ThemeMode.light);
 }

 // Activer le thème sombre
 Future<void> setDarkTheme() {async {
 await setTheme(ThemeMode.dark);
 }

 // Activer le thème système
 Future<void> setSystemTheme() {async {
 await setTheme(ThemeMode.system);
 }

 // Basculer entre le thème clair et sombre
 Future<void> toggleTheme() {async {
 if (state.isSystemMode) {{
 // Si en mode système, passer en mode clair
 await setLightTheme();
} else if (state.isDarkMode) {{
 // Si en mode sombre, passer en mode clair
 await setLightTheme();
} else {
 // Si en mode clair, passer en mode sombre
 await setDarkTheme();
}
 }

 // Obtenir le thème actuel en fonction des préférences système
 ThemeMode getEffectiveTheme(Brightness systemBrightness) {
 if (state.isSystemMode) {{
 return systemBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
}
 return state.themeMode;
 }

 // Vérifier si le thème effectif est sombre
 bool isEffectiveDarkMode(Brightness systemBrightness) {
 final effectiveTheme = getEffectiveTheme(systemBrightness);
 return effectiveTheme == ThemeMode.dark;
 }

 // Réinitialiser au thème système
 Future<void> resetToSystemTheme() {async {
 await setSystemTheme();
 }
}

// Provider pour le thème
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
 return ThemeNotifier(ref.read(storageServiceProvider));
});

// Provider pour le mode de thème actuel
final themeModeProvider = Provider<ThemeMode>((ref) {
 return ref.watch(themeProvider).themeMode;
});

// Provider pour vérifier si le mode sombre est actif
final isDarkModeProvider = Provider<bool>((ref) {
 return ref.watch(themeProvider).isDarkMode;
});

// Provider pour vérifier si le mode système est actif
final isSystemModeProvider = Provider<bool>((ref) {
 return ref.watch(themeProvider).isSystemMode;
});

// Provider pour obtenir le thème effectif en fonction de la luminosité système
final effectiveThemeProvider = Provider<ThemeMode>((ref) {
 final themeState = ref.watch(themeProvider);
 final systemBrightness = ref.watch(systemBrightnessProvider);
 
 if (themeState.isSystemMode) {{
 return systemBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
 }
 return themeState.themeMode;
});

// Provider pour vérifier si le thème effectif est sombre
final isEffectiveDarkModeProvider = Provider<bool>((ref) {
 final themeNotifier = ref.watch(themeProvider.notifier);
 final systemBrightness = ref.watch(systemBrightnessProvider);
 
 return themeNotifier.isEffectiveDarkMode(systemBrightness);
});

// Provider pour la luminosité système (simulé pour l'instant)
// Dans une vraie application, vous utiliseriez MediaQuery ou un package comme system_brightness
final systemBrightnessProvider = Provider<Brightness>((ref) {
 // Pour l'instant, on retourne une valeur par défaut
 // Dans une vraie implémentation, vous pourriez utiliser:
 // return MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;
 return Brightness.light;
});

// Provider pour les couleurs dynamiques basées sur le thème
final dynamicColorProvider = Provider<Map<String, Color>>((ref) {
 final isDarkMode = ref.watch(isEffectiveDarkModeProvider);
 
 if (isDarkMode) {{
 return {
 'primary': const Color(0xFF4A90E2), // Bleu plus clair pour le mode sombre
 'secondary': const Color(0xFF4CAF50), // Vert plus clair
 'accent': const Color(0xFFFF9800), // Orange plus clair
 'background': const Color(0xFF121212),
 'surface': const Color(0xFF1E1E1E),
 'card': const Color(0xFF2C2C2C),
 'text': const Color(0xFFFFFFFF),
 'textSecondary': const Color(0xFFB0B0B0),
};
 } else {
 return {
 'primary': const Color(0xFF0066CC), // Bleu Aramco
 'secondary': const Color(0xFF00AA00), // Vert succès
 'accent': const Color(0xFFFF6600), // Orange accent
 'background': const Color(0xFFF8F9FA),
 'surface': const Color(0xFFFFFFFF),
 'card': const Color(0xFFFFFFFF),
 'text': const Color(0xFF212529),
 'textSecondary': const Color(0xFF6C757D),
};
 }
});

// Provider pour les couleurs de statut basées sur le thème
final statusColorProvider = Provider<Map<String, Color>>((ref) {
 final isDarkMode = ref.watch(isEffectiveDarkModeProvider);
 
 if (isDarkMode) {{
 return {
 'success': const Color(0xFF4CAF50),
 'warning': const Color(0xFFFF9800),
 'error': const Color(0xFFF44336),
 'info': const Color(0xFF2196F3),
 'pending': const Color(0xFFFFC107),
 'approved': const Color(0xFF4CAF50),
 'rejected': const Color(0xFFF44336),
 'delivered': const Color(0xFF2196F3),
};
 } else {
 return {
 'success': const Color(0xFF28A745),
 'warning': const Color(0xFFFFC107),
 'error': const Color(0xFFDC3545),
 'info': const Color(0xFF17A2B8),
 'pending': const Color(0xFFFFC107),
 'approved': const Color(0xFF28A745),
 'rejected': const Color(0xFFDC3545),
 'delivered': const Color(0xFF17A2B8),
};
 }
});

// Provider pour les couleurs de rôle basées sur le thème
final roleColorProvider = Provider<Map<String, Color>>((ref) {
 final isDarkMode = ref.watch(isEffectiveDarkModeProvider);
 
 if (isDarkMode) {{
 return {
 'admin': const Color(0xFFE57373), // Rouge plus clair
 'manager': const Color(0xFFFFB74D), // Orange plus clair
 'operator': const Color(0xFF81C784), // Vert plus clair
 'rh': const Color(0xFF64B5F6), // Bleu plus clair
 'comptable': const Color(0xFFBA68C8), // Violet plus clair
 'logistique': const Color(0xFF4DB6AC), // Turquoise plus clair
;;
 } else {
 return {
 'admin': const Color(0xFFDC3545),
 'manager': const Color(0xFFFF6600),
 'operator': const Color(0xFF28A745),
 'rh': const Color(0xFF17A2B8),
 'comptable': const Color(0xFF6F42C1),
 'logistique': const Color(0xFFFD7E14),
};
 }
});

// Extensions utiles pour le thème
extension ThemeExtensions on WidgetRef {
 // Obtenir une couleur dynamique
 Color getDynamicColor(String key) {
 final colors = read(dynamicColorProvider);
 return colors[key] ?? Colors.grey;
 }

 // Obtenir une couleur de statut
 Color getStatusColor(String status) {
 final colors = read(statusColorProvider);
 return colors[status] ?? Colors.grey;
 }

 // Obtenir une couleur de rôle
 Color getRoleColor(String role) {
 final colors = read(roleColorProvider);
 return colors[role] ?? Colors.grey;
 }

 // Vérifier si le thème est sombre
 bool get isDarkMode => read(isEffectiveDarkModeProvider);
}

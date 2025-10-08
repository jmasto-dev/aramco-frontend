# Documentation Technique - Aramco Frontend

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Structure du Projet](#structure-du-projet)
4. [Configuration](#configuration)
5. [Dépendances](#dépendances)
6. [Services](#services)
7. [Providers](#providers)
8. [Widgets](#widgets)
9. [Tests](#tests)
10. [Déploiement](#déploiement)
11. [Dépannage](#dépannage)

## 🎯 Vue d'ensemble

**Aramco Frontend** est une application mobile Flutter développée pour la gestion des ressources humaines et des opérations d'entreprise. L'application offre une interface moderne et intuitive pour gérer les employés, les congés, les évaluations de performance, les commandes et bien plus encore.

### Caractéristiques Principales

- 🏢 **Gestion RH Complète**: Employés, congés, évaluations, paie
- 📊 **Tableau de Bord**: Widgets personnalisables et KPIs en temps réel
- 📱 **Multi-plateforme**: iOS, Android, Web, Desktop
- ⚡ **Haute Performance**: Cache intelligent, lazy loading, mode offline
- 🔒 **Sécurité**: Authentification JWT, rôles et permissions
- 🌍 **Internationalisation**: Support multilingue

## 🏗️ Architecture

### Pattern Architectural

L'application suit une architecture **MVC (Model-View-Controller)** avec le pattern **Provider** pour la gestion d'état :

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Models      │    │    Providers    │    │     Views       │
│                 │    │                 │    │                 │
│ • User          │◄──►│ • AuthProvider  │◄──►│ • Screens       │
│ • Employee      │    │ • EmployeeProv  │    │ • Widgets       │
│ • Order         │    │ • OrderProvider │    │ • Components    │
│ • ...           │    │ • ...           │    │ • ...           │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │    Services     │
                    │                 │
                    │ • ApiService    │
                    │ • CacheService  │
                    │ • StorageService│
                    │ • ...           │
                    └─────────────────┘
```

### Couches de l'Application

1. **Presentation Layer**: UI Components, Screens, Widgets
2. **Business Logic Layer**: Providers, Controllers
3. **Data Layer**: Services, Models, Repositories
4. **Infrastructure Layer**: Cache, Storage, Network

## 📁 Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée
├── core/                        # Cœur de l'application
│   ├── models/                  # Modèles de données
│   │   ├── user.dart
│   │   ├── employee.dart
│   │   ├── order.dart
│   │   └── ...
│   ├── services/                # Services métier
│   │   ├── api_service.dart
│   │   ├── cache_service.dart
│   │   ├── storage_service.dart
│   │   └── ...
│   └── utils/                   # Utilitaires
│       ├── app_theme.dart
│       ├── validators.dart
│       └── ...
├── presentation/                # Couche présentation
│   ├── providers/               # Gestion d'état
│   │   ├── auth_provider.dart
│   │   ├── employee_provider.dart
│   │   └── ...
│   ├── screens/                 # Écrans
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   └── ...
│   └── widgets/                 # Widgets réutilisables
│       ├── custom_button.dart
│       ├── employee_card.dart
│       └── ...
└── generated/                   # Fichiers générés
    └── intl/
```

## ⚙️ Configuration

### Variables d'Environnement

Créer un fichier `.env` à la racine du projet :

```env
# Configuration API
API_BASE_URL=https://api.aramco.com
API_TIMEOUT=30000

# Configuration Cache
CACHE_SIZE=104857600
CACHE_TTL=300

# Configuration Sécurité
JWT_SECRET=your_jwt_secret_here
ENCRYPTION_KEY=your_encryption_key

# Configuration Features
ENABLE_OFFLINE_MODE=true
ENABLE_ANALYTICS=false
DEBUG_MODE=false
```

### Configuration Flutter

Dans `pubspec.yaml` :

```yaml
name: aramco_frontend
description: Application Aramco Frontend

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # HTTP & Network
  http: ^1.1.0
  dio: ^5.3.2
  
  # Storage & Cache
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # UI Components
  material_symbols_icons: ^4.2719.3
  flutter_svg: ^2.0.9
  
  # Utilities
  intl: ^0.18.1
  json_annotation: ^4.8.1
  crypto: ^3.0.3
  
  # Testing
  mockito: ^5.4.2
  build_runner: ^2.4.7
  json_serializable: ^6.7.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
```

## 🔧 Dépendances Principales

### Core Dependencies

| Package | Version | Usage |
|---------|---------|-------|
| `provider` | ^6.1.1 | Gestion d'état |
| `http` | ^1.1.0 | Requêtes HTTP |
| `hive` | ^2.2.3 | Base de données locale |
| `shared_preferences` | ^2.2.2 | Stockage clé-valeur |
| `intl` | ^0.18.1 | Internationalisation |

### Development Dependencies

| Package | Version | Usage |
|---------|---------|-------|
| `mockito` | ^5.4.2 | Tests unitaires |
| `build_runner` | ^2.4.7 | Génération de code |
| `json_serializable` | ^6.7.1 | Sérialisation JSON |
| `hive_generator` | ^2.0.1 | Génération Hive |

## 🛠️ Services

### ApiService

Service principal pour la communication avec l'API backend :

```dart
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<ApiResponse<T>> get<T>(String endpoint);
  Future<ApiResponse<T>> post<T>(String endpoint, {dynamic data});
  Future<ApiResponse<T>> put<T>(String endpoint, {dynamic data});
  Future<ApiResponse<T>> delete<T>(String endpoint);
}
```

### CacheService

Service de cache multi-niveaux (mémoire + disque) :

```dart
class CacheService {
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<T?> get<T>(String key);
  Future<void> invalidate(String key);
  Future<void> clear();
}
```

### OptimizedApiService

Service API avec optimisations avancées :

```dart
class OptimizedApiService {
  Future<ApiResponse<T>> getWithCache<T>(String url);
  Future<List<ApiResponse<T>>> batchRequest<T>(List<String> urls);
  Future<void> preloadData<T>(List<String> urls);
  PerformanceMetrics getPerformanceMetrics();
}
```

## 📦 Providers

### AuthProvider

Gestion de l'authentification et des sessions :

```dart
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  User? _currentUser;
  
  Future<bool> login(String email, String password);
  Future<void> logout();
  bool get isAuthenticated => _currentUser != null;
}
```

### EmployeeProvider

Gestion des données employés :

```dart
class EmployeeProvider extends ChangeNotifier {
  List<Employee> _employees = [];
  bool _isLoading = false;
  
  Future<void> loadEmployees();
  Future<void> addEmployee(Employee employee);
  Future<void> updateEmployee(Employee employee);
  Future<void> deleteEmployee(String id);
}
```

## 🎨 Widgets

### CustomButton

Bouton personnalisé avec états et thèmes :

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.style,
    this.isLoading = false,
  }) : super(key: key);
}
```

### LazyListView

Liste avec chargement infini :

```dart
class LazyListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int limit) onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  
  // Propriétés...
}
```

## 🧪 Tests

### Structure des Tests

```
test/
├── unit/                        # Tests unitaires
│   ├── services/
│   ├── providers/
│   └── models/
├── widget/                      # Tests de widgets
├── integration/                 # Tests d'intégration
└── test_utils.dart              # Utilitaires de test
```

### Exemple de Test Unitaire

```dart
void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      authProvider = AuthProvider(apiService: mockApiService);
    });

    test('should login successfully', () async {
      // Arrange
      when(mockApiService.login(any, any))
          .thenAnswer((_) async => ApiResponse.success(data: mockUser));

      // Act
      await authProvider.login('test@example.com', 'password');

      // Assert
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, mockUser);
    });
  });
}
```

### Exécution des Tests

```bash
# Exécuter tous les tests
flutter test

# Exécuter les tests avec couverture
flutter test --coverage

# Exécuter un fichier de test spécifique
flutter test test/unit/services/api_service_test.dart
```

## 🚀 Déploiement

### Prérequis

- Flutter SDK 3.10.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- Xcode (pour iOS)
- Git

### Build pour Production

#### Android

```bash
# Générer la clé de signature
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configurer les clés dans android/key.properties
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

#### iOS

```bash
# Configurer les certificats dans Xcode
# Build IPA
flutter build ios --release
```

#### Web

```bash
# Build web
flutter build web --release

# Déployer sur Firebase Hosting
firebase deploy --only hosting
```

### Configuration CI/CD

Exemple avec GitHub Actions :

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test
      - run: flutter analyze

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## 🔧 Dépannage

### Problèmes Communs

#### 1. Erreur de Build Android

**Problème**: `Could not resolve all files for configuration`

**Solution**:
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
./gradlew build
cd ..
flutter build apk
```

#### 2. Erreur de Cache Hive

**Problème**: `HiveError: Box not found`

**Solution**:
```dart
// Initialiser Hive avant utilisation
await Hive.initFlutter();
Hive.registerAdapter(EmployeeAdapter());
await Hive.openBox<Employee>('employees');
```

#### 3. Problème de Performance

**Symptôme**: Application lente au démarrage

**Solution**:
```dart
// Utiliser le lazy loading
class MyHomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MainScreen();
        }
        return SplashScreen();
      },
    );
  }
}
```

### Outils de Debug

#### Flutter Inspector

```bash
flutter run --debug
# Ouvrir Flutter Inspector dans VS Code ou Android Studio
```

#### Performance Overlay

```dart
MaterialApp(
  debugShowCheckedModeBanner: true,
  showPerformanceOverlay: kDebugMode,
  // ...
)
```

#### Logs

```dart
import 'dart:developer' as developer;

developer.log('Debug message', name: 'aramco.app');
```

## 📚 Ressources Additionnelles

### Documentation Flutter

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Hive Database](https://docs.hivedb.dev/)

### Bonnes Pratiques

- Utiliser const constructeurs quand possible
- Implémenter proper error handling
- Écrire des tests pour toute logique métier
- Optimiser les images et assets
- Utiliser le cache intelligemment

### Sécurité

- Ne jamais stocker de secrets dans le code
- Utiliser HTTPS pour toutes les communications
- Valider toutes les entrées utilisateur
- Implémenter proper session management

---

**Dernière mise à jour**: 2 Octobre 2025  
**Version**: 1.0.0  
**Auteur**: Équipe de Développement Aramco Frontend

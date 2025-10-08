# Guide de Déploiement - Aramco Frontend

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Configuration de l'Environnement](#configuration-de-lenvironnement)
3. [Déploiement Local](#déploiement-local)
4. [Déploiement Android](#déploiement-android)
5. [Déploiement iOS](#déploiement-ios)
6. [Déploiement Web](#déploiement-web)
7. [CI/CD](#cicd)
8. [Monitoring et Maintenance](#monitoring-et-maintenance)
9. [Dépannage](#dépannage)

## 🔧 Prérequis

### Système Requis

- **OS**: Windows 10+, macOS 10.14+, Ubuntu 18.04+
- **RAM**: 8GB minimum (16GB recommandé)
- **Stockage**: 10GB d'espace libre
- **Git**: Version 2.0+

### Logiciels Requis

#### Flutter SDK
```bash
# Télécharger Flutter depuis https://flutter.dev/docs/get-started/install
# Ajouter Flutter au PATH
export PATH="$PATH:/path/to/flutter/bin"

# Vérifier l'installation
flutter doctor
```

#### Outils de Développement
- **Android Studio** (avec Flutter plugin)
- **VS Code** (avec Flutter extension)
- **Xcode** (pour iOS uniquement, macOS)

#### Dépendances Platformes

**Android**:
- Android SDK (API level 21+)
- Java Development Kit (JDK) 11+
- Android Build Tools

**iOS**:
- Xcode 14.0+
- iOS Simulator
- CocoaPods

**Web**:
- Chrome (dernière version)
- Node.js 16+ (pour certains outils)

## ⚙️ Configuration de l'Environnement

### 1. Clonage du Projet

```bash
# Cloner le dépôt
git clone https://github.com/jmasto-dev/aramco-frontend.git
cd aramco-frontend

# Vérifier la branche
git checkout main
```

### 2. Installation des Dépendances

```bash
# Installer les dépendances Flutter
flutter pub get

# Générer les fichiers nécessaires
flutter packages pub run build_runner build
```

### 3. Configuration des Variables d'Environnement

Créer le fichier `.env` à la racine :

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

# Configuration Déploiement
ENVIRONMENT=production
FLAVOR=prod
```

### 4. Configuration des Clés de Signature

#### Android

```bash
# Générer la clé de signature
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Créer le fichier android/key.properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/your/upload-keystore.jks
```

#### iOS

```bash
# Configurer dans Xcode
# Project Navigator → Target → Signing & Capabilities
# Ajouter les certificats de distribution
```

## 🏠 Déploiement Local

### 1. Développement

```bash
# Lancer en mode debug
flutter run

# Lancer sur un appareil spécifique
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d macos         # macOS
flutter run -d android       # Android
flutter run -d ios           # iOS
```

### 2. Build Debug

```bash
# Build debug APK
flutter build apk --debug

# Build debug web
flutter build web --debug
```

### 3. Tests Locaux

```bash
# Exécuter tous les tests
flutter test

# Tests avec couverture
flutter test --coverage

# Analyser le code
flutter analyze
```

## 📱 Déploiement Android

### 1. Préparation

```bash
# Nettoyer le projet
flutter clean
flutter pub get

# Vérifier la configuration
flutter doctor -v
```

### 2. Build Release APK

```bash
# Build APK standard
flutter build apk --release

# Build APK avec flavor
flutter build apk --release --flavor prod
```

### 3. Build App Bundle (Recommandé pour Play Store)

```bash
# Build AAB
flutter build appbundle --release

# Build AAB avec flavor
flutter build appbundle --release --flavor prod
```

### 4. Signature du APK

```bash
# Signer manuellement si nécessaire
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ~/upload-keystore.jks build/app/outputs/flutter-apk/app-release.apk upload

# Vérifier la signature
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

### 5. Déploiement sur Play Store

1. **Console Google Play**:
   - Créer une nouvelle application
   - Configurer les tracks (Internal, Alpha, Beta, Production)

2. **Upload**:
   ```bash
   #Uploader l'AAB
   # Utiliser Google Play Console Web ou API
   ```

3. **Configuration**:
   - Remplir la fiche de l'application
   - Ajouter les captures d'écran
   - Configurer les permissions

### 6. Configuration des Flavors

Dans `android/app/build.gradle`:

```gradle
android {
    flavorDimensions "version"
    productFlavors {
        dev {
            dimension "version"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        prod {
            dimension "version"
            applicationId "com.aramco.frontend"
        }
    }
}
```

## 🍎 Déploiement iOS

### 1. Configuration Xcode

```bash
# Ouvrir le projet iOS
open ios/Runner.xcworkspace

# Configurer les signing certificates
# Project Navigator → Runner → Signing & Capabilities
```

### 2. Build iOS

```bash
# Build pour iOS
flutter build ios --release

# Build avec flavor
flutter build ios --release --flavor prod
```

### 3. Configuration dans Xcode

1. **Team and Bundle Identifier**:
   - Sélectionner le team de développement
   - Configurer le Bundle Identifier

2. **Signing**:
   - Ajouter les certificats de distribution
   - Configurer les provisioning profiles

3. **Info.plist**:
   - Configurer les permissions
   - Ajouter les URLs schemes

### 4. Archive et Upload

```bash
# Créer une archive depuis Xcode
# Product → Archive

#Uploader sur App Store Connect
# Window → Organizer → Archives → Distribute App
```

### 5. Configuration App Store Connect

1. **Créer l'application**:
   - Remplir les informations de base
   - Configurer les métadonnées

2. **Upload**:
   - Utiliser Xcode ou Transporter
   - Attendre la validation

3. **Soumission**:
   - Ajouter les captures d'écran
   - Remplir la description
   - Soumettre pour review

## 🌐 Déploiement Web

### 1. Build Web

```bash
# Build web standard
flutter build web --release

# Build avec configuration personnalisée
flutter build web --release --web-renderer canvaskit
```

### 2. Configuration du Build

Dans `web/index.html`:

```html
<meta name="description" content="Application Aramco Frontend">
<meta name="theme-color" content="#1976D2">

<!-- PWA Configuration -->
<link rel="manifest" href="manifest.json">
<meta name="apple-mobile-web-app-capable" content="yes">
```

### 3. Déploiement sur Firebase Hosting

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Initialiser Firebase
firebase init hosting

# Déployer
firebase deploy --only hosting
```

### 4. Déploiement sur Vercel

```bash
# Installer Vercel CLI
npm install -g vercel

# Déployer
vercel --prod
```

### 5. Configuration Nginx (Serveur dédié)

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    root /var/www/aramco-frontend/build/web;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache les assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

## 🔄 CI/CD

### 1. GitHub Actions

Créer `.github/workflows/build.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.10.0'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run tests
        run: flutter test
        
      - name: Analyze code
        run: flutter analyze

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          
      - name: Build APK
        run: flutter build apk --release
        
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          
      - name: Build Web
        run: flutter build web --release
        
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: aramco-frontend
```

### 2. GitLab CI/CD

Créer `.gitlab-ci.yml`:

```yaml
stages:
  - test
  - build
  - deploy

variables:
  FLUTTER_VERSION: "3.10.0"

test:
  stage: test
  image: cirrusci/flutter:$FLUTTER_VERSION
  script:
    - flutter pub get
    - flutter test
    - flutter analyze

build_android:
  stage: build
  image: cirrusci/flutter:$FLUTTER_VERSION
  script:
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk

deploy_web:
  stage: deploy
  image: node:16
  script:
    - npm install -g firebase-tools
    - flutter build web --release
    - firebase deploy --token $FIREBASE_TOKEN --only hosting
  only:
    - main
```

### 3. Docker pour le Web

Créer `Dockerfile`:

```dockerfile
# Build stage
FROM cirrusci/flutter:3.10.0 as build
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Production stage
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 📊 Monitoring et Maintenance

### 1. Configuration du Monitoring

#### Firebase Performance Monitoring

```dart
// Dans main.dart
import 'package:firebase_performance/firebase_performance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Configurer le monitoring
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  
  runApp(MyApp());
}
```

#### Sentry pour le Crash Reporting

```dart
// Configuration Sentry
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) => options.dsn = 'YOUR_SENTRY_DSN',
  );
  
  runApp(MyApp());
}
```

### 2. Analytics

#### Google Analytics

```dart
// Configuration Analytics
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
```

### 3. Logs et Debug

#### Configuration des Logs

```dart
import 'dart:developer' as developer;

class Logger {
  static void debug(String message, [String? name]) {
    developer.log(message, name: name ?? 'AramcoApp');
  }
  
  static void error(String message, [String? name]) {
    developer.log('ERROR: $message', name: name ?? 'AramcoApp');
  }
}
```

### 4. Health Checks

```dart
// Service de health check
class HealthCheckService {
  static Future<Map<String, bool>> checkHealth() async {
    return {
      'api': await _checkApi(),
      'cache': await _checkCache(),
      'storage': await _checkStorage(),
    };
  }
  
  static Future<bool> _checkApi() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

## 🔧 Dépannage

### Problèmes Communs

#### 1. Erreur de Build Android

**Problème**: `Could not resolve all files for configuration`

**Solution**:
```bash
flutter clean
flutter pub cache clean
flutter pub get
cd android
./gradlew clean
./gradlew build
cd ..
flutter build apk --release
```

#### 2. Erreur de Build iOS

**Problème**: `Command line tools are already installed`

**Solution**:
```bash
# Mettre à jour les outils de ligne de commande
sudo xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Nettoyer et rebuild
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter build ios --release
```

#### 3. Problème de Signature Android

**Problème**: `Failed to read key from keystore`

**Solution**:
```bash
# Vérifier le keystore
keytool -list -v -keystore ~/upload-keystore.jks

# Recréer si nécessaire
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### 4. Problème de Déploiement Web

**Problème**: `404 Not Found` sur les routes

**Solution**:
```nginx
# Configuration nginx pour le routing
location / {
    try_files $uri $uri/ /index.html;
}
```

### Scripts Utiles

#### Script de Build Complet

```bash
#!/bin/bash
# build.sh

echo "🚀 Starting build process..."

# Nettoyage
echo "🧹 Cleaning..."
flutter clean
flutter pub get

# Tests
echo "🧪 Running tests..."
flutter test

# Analyse
echo "🔍 Analyzing code..."
flutter analyze

# Build Android
echo "📱 Building Android APK..."
flutter build apk --release

# Build Web
echo "🌐 Building Web..."
flutter build web --release

echo "✅ Build completed successfully!"
```

#### Script de Déploiement

```bash
#!/bin/bash
# deploy.sh

ENVIRONMENT=${1:-production}
echo "🚀 Deploying to $ENVIRONMENT..."

case $ENVIRONMENT in
  "staging")
    firebase deploy --only hosting:staging
    ;;
  "production")
    firebase deploy --only hosting:production
    ;;
  *)
    echo "❌ Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

echo "✅ Deployment completed!"
```

### Monitoring en Production

#### Alertes

- **Uptime monitoring**: UptimeRobot, Pingdom
- **Performance monitoring**: Firebase Performance, New Relic
- **Error tracking**: Sentry, Crashlytics
- **Custom metrics**: Grafana, DataDog

#### Stratégies de Rollback

```bash
# Rollback web
firebase hosting:rollback

# Rollback mobile (Play Store)
# Utiliser les tracks de staging/testing

# Rollback iOS
# Maintenir une version précédente validée
```

---

**Dernière mise à jour**: 2 Octobre 2025  
**Version**: 1.0.0  
**Auteur**: Équipe de Développement Aramco Frontend

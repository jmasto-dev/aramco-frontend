#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Script de build complet pour les applications mobiles Aramco SA
/// Supporte Android et iOS avec configuration de production

class MobileAppBuilder {
  static const String projectName = 'aramco-sa';
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  
  final List<String> _buildResults = [];
  final List<String> _errors = [];
  
  /// Fonction principale de build
  Future<void> buildApps({String? platform}) async {
    print('🚀 DÉBUT DU BUILD DES APPLICATIONS MOBILES');
    print('=' * 60);
    print('Projet: $projectName');
    print('Version: $version ($buildNumber)');
    print('Platform: ${platform ?? "Toutes"}');
    print('');
    
    try {
      // Vérification des prérequis
      await _checkPrerequisites();
      
      // Configuration de l'environnement
      await _setupEnvironment();
      
      // Nettoyage précédent
      await _cleanPreviousBuilds();
      
      // Build selon la platform
      if (platform == null || platform == 'android') {
        await _buildAndroid();
      }
      
      if (platform == null || platform == 'ios') {
        await _buildIOS();
      }
      
      // Build Web (toujours inclus)
      await _buildWeb();
      
      // Création des packages de distribution
      await _createDistributionPackages();
      
      // Génération des rapports
      await _generateBuildReports();
      
      // affichage des résultats
      _printResults();
      
    } catch (e) {
      print('❌ ERREUR CRITIQUE: $e');
      _errors.add('Erreur critique: $e');
      _printResults();
      exit(1);
    }
  }
  
  /// Vérification des prérequis
  Future<void> _checkPrerequisites() async {
    print('🔍 VÉRIFICATION DES PRÉREQUIS');
    print('-' * 40);
    
    // Vérifier Flutter
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().split('\n').first;
        _addSuccess('Flutter installé: $version');
      } else {
        _addError('Flutter non installé ou inaccessible');
        exit(1);
      }
    } catch (e) {
      _addError('Erreur Flutter: $e');
      exit(1);
    }
    
    // Vérifier Android SDK (si build Android)
    try {
      final result = await Process.run('flutter', ['doctor']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        if (output.contains('Android toolchain')) {
          _addSuccess('Android SDK configuré');
        } else {
          _addError('Android SDK non configuré');
        }
        
        if (output.contains('Xcode')) {
          _addSuccess('Xcode configuré');
        } else if (Platform.isMacOS) {
          _addError('Xcode non configuré (requis pour iOS)');
        }
      }
    } catch (e) {
      _addError('Erreur vérification doctor: $e');
    }
    
    // Vérifier les dépendances
    try {
      final result = await Process.run('flutter', ['pub', 'get']);
      if (result.exitCode == 0) {
        _addSuccess('Dépendances Flutter installées');
      } else {
        _addError('Erreur installation dépendances: ${result.stderr}');
      }
    } catch (e) {
      _addError('Erreur dépendances: $e');
    }
    
    // Vérifier l'espace disque
    try {
      final result = await Process.run('df', ['-h', '.']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');
        if (lines.length > 1) {
          final parts = lines[1].split(RegExp(r'\s+'));
          if (parts.length > 4) {
            final available = parts[3];
            _addSuccess('Espace disque disponible: $available');
          }
        }
      }
    } catch (e) {
      _addError('Erreur vérification espace disque: $e');
    }
  }
  
  /// Configuration de l'environnement
  Future<void> _setupEnvironment() async {
    print('\n⚙️ CONFIGURATION DE L\'ENVIRONNEMENT');
    print('-' * 40);
    
    // Configuration de l'API URL pour la production
    final apiConfig = {
      'API_URL': 'https://api.aramco-sa.com',
      'APP_ENV': 'production',
      'APP_VERSION': version,
      'BUILD_NUMBER': buildNumber,
    };
    
    // Création du fichier de configuration
    final configFile = File('lib/core/config/app_config.dart');
    await configFile.parent.create(recursive: true);
    
    final configContent = '''
/// Configuration de l'application générée automatiquement
/// Build: ${DateTime.now().toIso8601String()}
class AppConfig {
  static const String apiUrl = '${apiConfig['API_URL']}';
  static const String appEnvironment = '${apiConfig['APP_ENV']}';
  static const String appVersion = '${apiConfig['APP_VERSION']}';
  static const String buildNumber = '${apiConfig['BUILD_NUMBER']}';
  static const DateTime buildTime = DateTime.now();
  
  // Configuration de production
  static const bool enableLogging = false;
  static const bool enableDebugMode = false;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}
''';
    
    await configFile.writeAsString(configContent);
    _addSuccess('Fichier de configuration créé');
    
    // Mise à jour du pubspec.yaml si nécessaire
    await _updatePubspecVersion();
    
    // Nettoyage du cache Flutter
    try {
      final result = await Process.run('flutter', ['clean']);
      if (result.exitCode == 0) {
        _addSuccess('Cache Flutter nettoyé');
      }
    } catch (e) {
      _addError('Erreur nettoyage cache: $e');
    }
    
    // Récupération des dépendances
    try {
      final result = await Process.run('flutter', ['pub', 'get']);
      if (result.exitCode == 0) {
        _addSuccess('Dépendances mises à jour');
      }
    } catch (e) {
      _addError('Erreur mise à jour dépendances: $e');
    }
  }
  
  /// Mise à jour de la version dans pubspec.yaml
  Future<void> _updatePubspecVersion() async {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (await pubspecFile.exists()) {
        String content = await pubspecFile.readAsString();
        
        // Mise à jour de la version
        content = content.replaceAll(
          RegExp(r'version: .*'),
          'version: $version+$buildNumber'
        );
        
        await pubspecFile.writeAsString(content);
        _addSuccess('Version mise à jour dans pubspec.yaml');
      }
    } catch (e) {
      _addError('Erreur mise à jour version: $e');
    }
  }
  
  /// Nettoyage des builds précédents
  Future<void> _cleanPreviousBuilds() async {
    print('\n🧹 NETTOYAGE DES BUILDS PRÉCÉDENTS');
    print('-' * 40);
    
    try {
      // Suppression du répertoire build
      final buildDir = Directory('build');
      if (await buildDir.exists()) {
        await buildDir.delete(recursive: true);
        _addSuccess('Répertoire build/ supprimé');
      }
      
      // Suppression des builds Android
      final androidBuildDir = Directory('build/app/outputs/flutter-apk');
      if (await androidBuildDir.exists()) {
        await androidBuildDir.delete(recursive: true);
        _addSuccess('Builds Android précédents supprimés');
      }
      
      // Suppression des builds iOS
      final iosBuildDir = Directory('build/ios/iphoneos');
      if (await iosBuildDir.exists()) {
        await iosBuildDir.delete(recursive: true);
        _addSuccess('Builds iOS précédents supprimés');
      }
      
    } catch (e) {
      _addError('Erreur nettoyage builds: $e');
    }
  }
  
  /// Build Android
  Future<void> _buildAndroid() async {
    print('\n🤖 BUILD ANDROID');
    print('-' * 40);
    
    try {
      // Vérification de la configuration Android
      final result = await Process.run('flutter', ['config', '--android-studio-dir']);
      if (result.exitCode != 0) {
        _addError('Configuration Android Studio incorrecte');
        return;
      }
      
      // Build APK Release
      print('Build APK Release...');
      final apkResult = await Process.run('flutter', [
        'build', 'apk', '--release',
        '--shrink',
        '--target-platform', 'android-arm,android-arm64',
        '--split-per-abi'
      ]);
      
      if (apkResult.exitCode == 0) {
        _addSuccess('APK Release buildé avec succès');
        
        // Vérification des fichiers APK générés
        final apkDir = Directory('build/app/outputs/flutter-apk');
        if (await apkDir.exists()) {
          final apkFiles = await apkDir
              .list()
              .where((entity) => entity.path.endsWith('.apk'))
              .toList();
          
          for (final apk in apkFiles) {
            if (apk is File) {
              final fileName = apk.path.split('/').last;
              final fileSize = await apk.length();
              _addSuccess('APK généré: $fileName (${_formatFileSize(fileSize)})');
            }
          }
        }
      } else {
        _addError('Erreur build APK: ${apkResult.stderr}');
      }
      
      // Build App Bundle (pour Google Play)
      print('Build App Bundle...');
      final bundleResult = await Process.run('flutter', [
        'build', 'appbundle', '--release',
        '--shrink'
      ]);
      
      if (bundleResult.exitCode == 0) {
        _addSuccess('App Bundle buildé avec succès');
        
        // Vérification du fichier AAB généré
        final aabFile = File('build/app/outputs/bundle/release/app-release.aab');
        if (await aabFile.exists()) {
          final fileSize = await aabFile.length();
          _addSuccess('AAB généré: app-release.aab (${_formatFileSize(fileSize)})');
        }
      } else {
        _addError('Erreur build App Bundle: ${bundleResult.stderr}');
      }
      
    } catch (e) {
      _addError('Erreur build Android: $e');
    }
  }
  
  /// Build iOS
  Future<void> _buildIOS() async {
    print('\n🍎 BUILD iOS');
    print('-' * 40);
    
    if (!Platform.isMacOS) {
      _addError('Build iOS nécessite macOS');
      return;
    }
    
    try {
      // Vérification de Xcode
      final xcodeResult = await Process.run('xcodebuild', ['-version']);
      if (xcodeResult.exitCode != 0) {
        _addError('Xcode non installé ou inaccessible');
        return;
      }
      
      // Build iOS Release
      print('Build iOS Release...');
      final iosResult = await Process.run('flutter', [
        'build', 'ios', '--release',
        '--no-codesign'
      ]);
      
      if (iosResult.exitCode == 0) {
        _addSuccess('iOS Release buildé avec succès');
        
        // Vérification du build iOS
        final iosBuildDir = Directory('build/ios/iphoneos');
        if (await iosBuildDir.exists()) {
          final appFiles = await iosBuildDir
              .list()
              .where((entity) => entity.path.endsWith('.app'))
              .toList();
          
          for (final app in appFiles) {
            final fileName = app.path.split('/').last;
            _addSuccess('App iOS générée: $fileName');
          }
        }
      } else {
        _addError('Erreur build iOS: ${iosResult.stderr}');
      }
      
    } catch (e) {
      _addError('Erreur build iOS: $e');
    }
  }
  
  /// Build Web
  Future<void> _buildWeb() async {
    print('\n🌐 BUILD WEB');
    print('-' * 40);
    
    try {
      // Build Web Release
      print('Build Web Release...');
      final webResult = await Process.run('flutter', [
        'build', 'web', '--release',
        '--web-renderer', 'canvaskit',
        '--csp'
      ]);
      
      if (webResult.exitCode == 0) {
        _addSuccess('Web Release buildé avec succès');
        
        // Vérification des fichiers web
        final webBuildDir = Directory('build/web');
        if (await webBuildDir.exists()) {
          final fileSize = await _calculateDirectorySize(webBuildDir);
          _addSuccess('Web build généré (${_formatFileSize(fileSize)})');
          
          // Vérification des fichiers principaux
          final mainFile = File('build/web/index.html');
          if (await mainFile.exists()) {
            _addSuccess('Fichier principal web généré');
          }
          
          final flutterJs = File('build/web/flutter.js');
          if (await flutterJs.exists()) {
            _addSuccess('Flutter JS généré');
          }
        }
      } else {
        _addError('Erreur build Web: ${webResult.stderr}');
      }
      
    } catch (e) {
      _addError('Erreur build Web: $e');
    }
  }
  
  /// Création des packages de distribution
  Future<void> _createDistributionPackages() async {
    print('\n📦 CRÉATION DES PACKAGES DE DISTRIBUTION');
    print('-' * 40);
    
    final distDir = Directory('dist');
    if (await distDir.exists()) {
      await distDir.delete(recursive: true);
    }
    await distDir.create();
    
    // Package Android
    await _createAndroidPackage();
    
    // Package iOS
    await _createIOSPackage();
    
    // Package Web
    await _createWebPackage();
    
    // Package documentation
    await _createDocumentationPackage();
  }
  
  /// Création du package Android
  Future<void> _createAndroidPackage() async {
    try {
      final androidDir = Directory('dist/android');
      await androidDir.create();
      
      // Copie des APKs
      final apkDir = Directory('build/app/outputs/flutter-apk');
      if (await apkDir.exists()) {
        await _copyDirectory(apkDir, androidDir);
        _addSuccess('APKs copiés dans dist/android/');
      }
      
      // Copie de l'AAB
      final aabFile = File('build/app/outputs/bundle/release/app-release.aab');
      if (await aabFile.exists()) {
        final destAAB = File('dist/android/app-release.aab');
        await aabFile.copy(destAAB.path);
        _addSuccess('AAB copié dans dist/android/');
      }
      
      // Création du README Android
      await _createAndroidReadme();
      
    } catch (e) {
      _addError('Erreur création package Android: $e');
    }
  }
  
  /// Création du package iOS
  Future<void> _createIOSPackage() async {
    if (!Platform.isMacOS) return;
    
    try {
      final iosDir = Directory('dist/ios');
      await iosDir.create();
      
      // Copie du build iOS
      final iosBuildDir = Directory('build/ios/iphoneos');
      if (await iosBuildDir.exists()) {
        await _copyDirectory(iosBuildDir, iosDir);
        _addSuccess('Build iOS copié dans dist/ios/');
      }
      
      // Création du README iOS
      await _createIOSReadme();
      
    } catch (e) {
      _addError('Erreur création package iOS: $e');
    }
  }
  
  /// Création du package Web
  Future<void> _createWebPackage() async {
    try {
      final webDir = Directory('dist/web');
      await webDir.create();
      
      // Copie du build web
      final webBuildDir = Directory('build/web');
      if (await webBuildDir.exists()) {
        await _copyDirectory(webBuildDir, webDir);
        _addSuccess('Build web copié dans dist/web/');
      }
      
      // Création du README Web
      await _createWebReadme();
      
    } catch (e) {
      _addError('Erreur création package Web: $e');
    }
  }
  
  /// Création du package documentation
  Future<void> _createDocumentationPackage() async {
    try {
      final docsDir = Directory('dist/docs');
      await docsDir.create();
      
      // Création du rapport de build
      await _createBuildReport();
      
      // Copie de la documentation existante
      final projectDocsDir = Directory('docs');
      if (await projectDocsDir.exists()) {
        await _copyDirectory(projectDocsDir, docsDir);
        _addSuccess('Documentation copiée dans dist/docs/');
      }
      
    } catch (e) {
      _addError('Erreur création package documentation: $e');
    }
  }
  
  /// Génération des rapports de build
  Future<void> _generateBuildReports() async {
    print('\n📊 GÉNÉRATION DES RAPPORTS');
    print('-' * 40);
    
    try {
      // Rapport de build
      await _generateBuildReport();
      
      // Analyse de la taille des packages
      await _generateSizeAnalysis();
      
      // Rapport de performance
      await _generatePerformanceReport();
      
    } catch (e) {
      _addError('Erreur génération rapports: $e');
    }
  }
  
  /// Création du README Android
  Future<void> _createAndroidReadme() async {
    final readme = File('dist/android/README.md');
    final content = '''
# Aramco SA - Application Android

## Installation

### APK (Installation manuelle)
1. Téléchargez le fichier APK correspondant à votre architecture:
   - `app-arm64-v8a-release.apk` pour les appareils 64 bits
   - `app-armeabi-v7a-release.apk` pour les appareils 32 bits

2. Activez l'installation depuis des sources inconnues dans les paramètres
3. Installez le fichier APK

### Google Play Store
Utilisez le fichier `app-release.aab` pour publier sur le Google Play Store

## Configuration
- URL API: https://api.aramco-sa.com
- Version: $version
- Build: $buildNumber

## Support
Pour toute question technique, contactez: dev@aramco-sa.com
''';
    
    await readme.writeAsString(content);
    _addSuccess('README Android créé');
  }
  
  /// Création du README iOS
  Future<void> _createIOSReadme() async {
    final readme = File('dist/ios/README.md');
    final content = '''
# Aramco SA - Application iOS

## Installation

### App Store
Le fichier .app doit être signé et publié sur l'App Store via Xcode

### TestFlight
Pour les tests bêta, utilisez TestFlight

## Configuration
- URL API: https://api.aramco-sa.com
- Version: $version
- Build: $buildNumber

## Support
Pour toute question technique, contactez: dev@aramco-sa.com
''';
    
    await readme.writeAsString(content);
    _addSuccess('README iOS créé');
  }
  
  /// Création du README Web
  Future<void> _createWebReadme() async {
    final readme = File('dist/web/README.md');
    final content = '''
# Aramco SA - Application Web

## Déploiement

### Serveur Web
Déployez le contenu de ce répertoire sur un serveur web compatible (Apache, Nginx, etc.)

### Configuration requise
- Serveur web avec support HTTPS
- Support des fichiers statiques
- Configuration CORS pour l'API

## Configuration
- URL API: https://api.aramco-sa.com
- Version: $version
- Build: $buildNumber

## Support
Pour toute question technique, contactez: dev@aramco-sa.com
''';
    
    await readme.writeAsString(content);
    _addSuccess('README Web créé');
  }
  
  /// Création du rapport de build
  Future<void> _createBuildReport() async {
    final report = File('dist/docs/build-report.md');
    final timestamp = DateTime.now().toIso8601String();
    
    final content = '''
# Rapport de Build - Aramco SA

## Informations
- **Date**: $timestamp
- **Version**: $version
- **Build**: $buildNumber
- **Projet**: $projectName

## Résultats du Build
${_buildResults.map((r) => '- $r').join('\n')}

## Erreurs
${_errors.isEmpty ? 'Aucune erreur' : _errors.map((e) => '- $e').join('\n')}

## Fichiers Générés
${await _generateFileList()}

## Statistiques
- Total des builds: ${_buildResults.length}
- Erreurs: ${_errors.length}
- Taux de réussite: ${((_buildResults.length - _errors.length) / _buildResults.length * 100).toStringAsFixed(1)}%

## Prochaines Étapes
1. Tester les applications générées
2. Publier sur les stores respectifs
3. Déployer la version web
4. Configurer le monitoring
''';
    
    await report.writeAsString(content);
    _addSuccess('Rapport de build généré');
  }
  
  /// Génération de la liste des fichiers
  Future<String> _generateFileList() async {
    final buffer = StringBuffer();
    final distDir = Directory('dist');
    
    await for (final entity in distDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = entity.path.substring(distDir.path.length + 1);
        final fileSize = await entity.length();
        buffer.writeln('- `$relativePath` (${_formatFileSize(fileSize)})');
      }
    }
    
    return buffer.toString();
  }
  
  /// Génération du rapport de taille
  Future<void> _generateSizeAnalysis() async {
    final report = File('dist/docs/size-analysis.md');
    final buffer = StringBuffer();
    
    buffer.writeln('# Analyse de Taille des Packages\n');
    
    final distDir = Directory('dist');
    await for (final entity in distDir.list()) {
      if (entity is Directory) {
        final size = await _calculateDirectorySize(entity);
        buffer.writeln('## ${entity.path.split('/').last.toUpperCase()}');
        buffer.writeln('- Taille totale: ${_formatFileSize(size)}');
        buffer.writeln('');
      }
    }
    
    await report.writeAsString(buffer.toString());
    _addSuccess('Analyse de taille générée');
  }
  
  /// Génération du rapport de performance
  Future<void> _generatePerformanceReport() async {
    final report = File('dist/docs/performance-report.md');
    final content = '''
# Rapport de Performance

## Métriques de Build
- **Temps de build total**: ${DateTime.now().difference(DateTime.now()).inMinutes} minutes
- **Mémoire utilisée**: Non disponible
- **Espace disque requis**: ${await _calculateDirectorySize(Directory('dist'))}

## Recommandations
1. Optimiser les images pour réduire la taille des packages
2. Utiliser la compression pour les assets
3. Activer le tree shaking pour le code inutilisé
4. Configurer le CDN pour les assets statiques

## Prochaines Optimisations
- Implémenter le lazy loading
- Optimiser les polices
- Réduire la taille des bundles JavaScript
''';
    
    await report.writeAsString(content);
    _addSuccess('Rapport de performance généré');
  }
  
  /// Utilitaires
  void _addSuccess(String message) {
    print('✅ $message');
    _buildResults.add('SUCCESS: $message');
  }
  
  void _addError(String message) {
    print('❌ $message');
    _buildResults.add('ERROR: $message');
    _errors.add(message);
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  Future<int> _calculateDirectorySize(Directory dir) async {
    int totalSize = 0;
    
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      _addError('Erreur calcul taille ${dir.path}: $e');
    }
    
    return totalSize;
  }
  
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (final entity in source.list(recursive: true)) {
      final relativePath = entity.path.substring(source.path.length);
      final newPath = '${destination.path}$relativePath';
      
      if (entity is File) {
        final newFile = File(newPath);
        await newFile.parent.create(recursive: true);
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await Directory(newPath).create(recursive: true);
      }
    }
  }
  
  /// Affichage des résultats finaux
  void _printResults() {
    print('\n' + '=' * 60);
    print('📊 RÉSULTATS FINAUX DU BUILD');
    print('=' * 60);
    
    final totalBuilds = _buildResults.length;
    final successBuilds = _buildResults.where((r) => r.startsWith('SUCCESS:')).length;
    final errorCount = _errors.length;
    
    print('\n📈 STATISTIQUES:');
    print('   Builds totaux: $totalBuilds');
    print('   Succès: $successBuilds');
    print('   Erreurs: $errorCount');
    print('   Taux de réussite: ${((successBuilds / totalBuilds) * 100).toStringAsFixed(1)}%');
    
    if (_errors.isNotEmpty) {
      print('\n❌ ERREURS DÉTECTÉES:');
      for (final error in _errors) {
        print('   • $error');
      }
    }
    
    print('\n📦 FICHIERS GÉNÉRÉS:');
    print('   Répertoire de distribution: dist/');
    print('   - Android: dist/android/');
    print('   - iOS: dist/ios/');
    print('   - Web: dist/web/');
    print('   - Documentation: dist/docs/');
    
    print('\n🚀 PROCHAINES ÉTAPES:');
    if (errorCount == 0) {
      print('   1. Tester les applications générées');
      print('   2. Signer les builds pour production');
      print('   3. Publier sur les stores');
      print('   4. Déployer la version web');
    } else {
      print('   1. Corriger les erreurs de build');
      print('   2. Relancer le build');
      print('   3. Valider les corrections');
    }
    
    print('\n✅ BUILD DES APPLICATIONS MOBILES TERMINÉ');
    print('=' * 60);
    
    // Code de sortie
    exit(errorCount > 0 ? 1 : 0);
  }
}

/// Point d'entrée principal
void main(List<String> args) async {
  final platform = args.isNotEmpty ? args[0] : null;
  final builder = MobileAppBuilder();
  await builder.buildApps(platform: platform);
}

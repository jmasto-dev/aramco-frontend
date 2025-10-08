#!/usr/bin/env dart

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

/// Script d'exécution complète de tous les tests du projet Aramco SA
/// Usage: dart scripts/run_all_tests.dart
void main() async {
  print('🚀 Exécution Complète des Tests - Projet Aramco SA');
  print('=' * 60);

  final testResults = <TestResult>[];

  // Test 1: Tests de connexion backend
  testResults.add(await runTest('Connexion Backend', runBackendConnectionTest));

  // Test 2: Tests d'intégration Flutter
  testResults.add(await runTest('Tests d\'Intégration Flutter', runFlutterIntegrationTests));

  // Test 3: Tests de performance
  testResults.add(await runTest('Tests de Performance', runPerformanceTests));

  // Test 4: Tests E2E (si disponible)
  testResults.add(await runTest('Tests E2E', runE2ETests));

  // Test 5: Validation de la configuration
  testResults.add(await runTest('Validation Configuration', runConfigurationValidation));

  // Génération du rapport final
  await generateTestReport(testResults);

  print('\n✅ Tous les tests terminés!');
}

Future<TestResult> runBackendConnectionTest() async {
  print('\n📡 Test de Connexion Backend');
  print('-' * 40);

  try {
    // Vérifier si le backend est démarré
    final healthResponse = await _checkBackendHealth();
    if (!healthResponse.success) {
      return TestResult(
        name: 'Connexion Backend',
        success: false,
        message: 'Backend non accessible: ${healthResponse.message}',
        duration: healthResponse.duration,
      );
    }

    print('✅ Backend accessible');

    // Test d'authentification
    final authResult = await _testAuthentication();
    if (!authResult.success) {
      return TestResult(
        name: 'Connexion Backend',
        success: false,
        message: 'Échec de l\'authentification: ${authResult.message}',
        duration: healthResponse.duration + authResult.duration,
      );
    }

    print('✅ Authentification réussie');

    // Test des endpoints principaux
    final endpointsResult = await _testMainEndpoints(authResult.data!);
    if (!endpointsResult.success) {
      return TestResult(
        name: 'Connexion Backend',
        success: false,
        message: 'Échec des endpoints: ${endpointsResult.message}',
        duration: healthResponse.duration + authResult.duration + endpointsResult.duration,
      );
    }

    print('✅ Endpoints principaux fonctionnels');

    return TestResult(
      name: 'Connexion Backend',
      success: true,
      message: 'Tous les tests de connexion réussis',
      duration: healthResponse.duration + authResult.duration + endpointsResult.duration,
      details: {
        'backend_health': healthResponse.data,
        'auth_token': authResult.data != null ? 'valid' : 'invalid',
        'endpoints_tested': endpointsResult.data,
      },
    );
  } catch (e) {
    return TestResult(
      name: 'Connexion Backend',
      success: false,
      message: 'Erreur inattendue: $e',
      duration: Duration.zero,
    );
  }
}

Future<TestResult> runFlutterIntegrationTests() async {
  print('\n🧪 Tests d\'Intégration Flutter');
  print('-' * 40);

  try {
    // Vérifier si Flutter est installé
    final flutterCheck = await _checkFlutterInstallation();
    if (!flutterCheck.success) {
      return TestResult(
        name: 'Tests d\'Intégration Flutter',
        success: false,
        message: 'Flutter non installé: ${flutterCheck.message}',
        duration: flutterCheck.duration,
      );
    }

    print('✅ Flutter installé');

    // Exécuter les tests unitaires
    final unitTestsResult = await _runFlutterTests('test/');
    if (!unitTestsResult.success) {
      return TestResult(
        name: 'Tests d\'Intégration Flutter',
        success: false,
        message: 'Échec des tests unitaires: ${unitTestsResult.message}',
        duration: flutterCheck.duration + unitTestsResult.duration,
      );
    }

    print('✅ Tests unitaires réussis');

    // Exécuter les tests d'intégration
    final integrationTestsResult = await _runFlutterTests('test/integration/');
    if (!integrationTestsResult.success) {
      return TestResult(
        name: 'Tests d\'Intégration Flutter',
        success: false,
        message: 'Échec des tests d\'intégration: ${integrationTestsResult.message}',
        duration: flutterCheck.duration + unitTestsResult.duration + integrationTestsResult.duration,
      );
    }

    print('✅ Tests d\'intégration réussis');

    return TestResult(
      name: 'Tests d\'Intégration Flutter',
      success: true,
      message: 'Tous les tests Flutter réussis',
      duration: flutterCheck.duration + unitTestsResult.duration + integrationTestsResult.duration,
      details: {
        'unit_tests': unitTestsResult.data,
        'integration_tests': integrationTestsResult.data,
      },
    );
  } catch (e) {
    return TestResult(
      name: 'Tests d\'Intégration Flutter',
      success: false,
      message: 'Erreur inattendue: $e',
      duration: Duration.zero,
    );
  }
}

Future<TestResult> runPerformanceTests() async {
  print('\n⚡ Tests de Performance');
  print('-' * 40);

  try {
    // Exécuter le script de test de performance
    final result = await Process.run('dart', ['scripts/performance_test.dart']);
    
    if (result.exitCode != 0) {
      return TestResult(
        name: 'Tests de Performance',
        success: false,
        message: 'Échec des tests de performance: ${result.stderr}',
        duration: Duration(milliseconds: 5000), // Estimation
      );
    }

    print('✅ Tests de performance terminés');

    // Analyser les résultats
    final output = result.stdout as String;
    final performanceMetrics = _parsePerformanceOutput(output);

    return TestResult(
      name: 'Tests de Performance',
      success: true,
      message: 'Tests de performance réussis',
      duration: Duration(milliseconds: 30000), // Estimation
      details: performanceMetrics,
    );
  } catch (e) {
    return TestResult(
      name: 'Tests de Performance',
      success: false,
      message: 'Erreur lors des tests de performance: $e',
      duration: Duration.zero,
    );
  }
}

Future<TestResult> runE2ETests() async {
  print('\n🎮 Tests End-to-End');
  print('-' * 40);

  try {
    // Vérifier si un émulateur/appareil est disponible
    final deviceCheck = await _checkAvailableDevices();
    if (!deviceCheck.success) {
      return TestResult(
        name: 'Tests E2E',
        success: false,
        message: 'Aucun appareil disponible: ${deviceCheck.message}',
        duration: deviceCheck.duration,
      );
    }

    print('✅ Appareil disponible: ${deviceCheck.data}');

    // Exécuter les tests E2E
    final e2eResult = await _runFlutterDriverTests();
    if (!e2eResult.success) {
      return TestResult(
        name: 'Tests E2E',
        success: false,
        message: 'Échec des tests E2E: ${e2eResult.message}',
        duration: deviceCheck.duration + e2eResult.duration,
      );
    }

    print('✅ Tests E2E réussis');

    return TestResult(
      name: 'Tests E2E',
      success: true,
      message: 'Tests E2E réussis',
      duration: deviceCheck.duration + e2eResult.duration,
      details: {
        'device': deviceCheck.data,
        'tests_passed': e2eResult.data,
      },
    );
  } catch (e) {
    return TestResult(
      name: 'Tests E2E',
      success: false,
      message: 'Erreur lors des tests E2E: $e',
      duration: Duration.zero,
    );
  }
}

Future<TestResult> runConfigurationValidation() async {
  print('\n⚙️  Validation de la Configuration');
  print('-' * 40);

  final validations = <String, bool>{};
  final stopwatch = Stopwatch()..start();

  try {
    // Valider la configuration du backend
    validations['backend_env'] = await _validateBackendConfig();
    print('✅ Configuration backend validée');

    // Valider la configuration du frontend
    validations['frontend_config'] = await _validateFrontendConfig();
    print('✅ Configuration frontend validée');

    // Valider la base de données
    validations['database'] = await _validateDatabase();
    print('✅ Base de données validée');

    // Valider les dépendances
    validations['dependencies'] = await _validateDependencies();
    print('✅ Dépendances validées');

    stopwatch.stop();

    final allValid = validations.values.every((v) => v);
    
    return TestResult(
      name: 'Validation Configuration',
      success: allValid,
      message: allValid ? 'Configuration valide' : 'Configuration invalide',
      duration: stopwatch.elapsed,
      details: validations,
    );
  } catch (e) {
    return TestResult(
      name: 'Validation Configuration',
      success: false,
      message: 'Erreur lors de la validation: $e',
      duration: stopwatch.elapsed,
    );
  }
}

Future<TestResult> runTest(String name, Future<TestResult> Function() testFunction) async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await testFunction();
    stopwatch.stop();
    
    return TestResult(
      name: name,
      success: result.success,
      message: result.message,
      duration: stopwatch.elapsed,
      details: result.details,
    );
  } catch (e) {
    stopwatch.stop();
    
    return TestResult(
      name: name,
      success: false,
      message: 'Erreur inattendue: $e',
      duration: stopwatch.elapsed,
    );
  }
}

Future<void> generateTestReport(List<TestResult> results) async {
  print('\n📊 Rapport Final des Tests');
  print('=' * 60);

  final totalTests = results.length;
  final passedTests = results.where((r) => r.success).length;
  final failedTests = totalTests - passedTests;
  final totalDuration = results.fold<Duration>(
    Duration.zero,
    (sum, result) => sum + result.duration,
  );

  print('Tests exécutés: $totalTests');
  print('Tests réussis: $passedTests ✅');
  print('Tests échoués: $failedTests ❌');
  print('Durée totale: ${totalDuration.inMinutes}m ${totalDuration.inSeconds % 60}s');
  print('Taux de réussite: ${((passedTests / totalTests) * 100).toStringAsFixed(1)}%');

  print('\nDétails des tests:');
  for (final result in results) {
    final status = result.success ? '✅' : '❌';
    final duration = '${result.duration.inSeconds}s';
    print('  $status ${result.name} ($duration) - ${result.message}');
  }

  // Générer le fichier JSON
  final report = {
    'timestamp': DateTime.now().toIso8601String(),
    'summary': {
      'total_tests': totalTests,
      'passed_tests': passedTests,
      'failed_tests': failedTests,
      'success_rate': (passedTests / totalTests) * 100,
      'total_duration_ms': totalDuration.inMilliseconds,
    },
    'results': results.map((r) => r.toJson()).toList(),
  };

  final reportFile = File('test_report_${DateTime.now().millisecondsSinceEpoch}.json');
  await reportFile.writeAsString(jsonEncode(report));
  
  print('\n📄 Rapport détaillé sauvegardé: ${reportFile.path}');
}

// Fonctions utilitaires pour les tests

Future<ProcessResult> _checkBackendHealth() async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await Process.run('curl', [
      '-s', '-o', '/dev/null', '-w', '%{http_code}',
      'http://localhost:8000/api/v1/health'
    ]);
    
    stopwatch.stop();
    
    return ProcessResult(
      success: result.exitCode == 0 && (result.stdout as String).trim() == '200',
      message: result.exitCode == 0 ? 'OK' : 'Backend non accessible',
      duration: stopwatch.elapsed,
      data: (result.stdout as String).trim(),
    );
  } catch (e) {
    stopwatch.stop();
    return ProcessResult(
      success: false,
      message: 'Erreur de connexion: $e',
      duration: stopwatch.elapsed,
    );
  }
}

Future<ProcessResult> _testAuthentication() async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await Process.run('curl', [
      '-s', '-X', 'POST',
      '-H', 'Content-Type: application/json',
      '-d', '{"email":"admin@aramco-sa.com","password":"password123"}',
      'http://localhost:8000/api/v1/auth/login'
    ]);
    
    stopwatch.stop();
    
    if (result.exitCode == 0) {
      final response = jsonDecode(result.stdout as String);
      final success = response['status'] == 'success' && response['data']?['token'] != null;
      
      return ProcessResult(
        success: success,
        message: success ? 'Authentification réussie' : 'Token invalide',
        duration: stopwatch.elapsed,
        data: success ? response['data']['token'] : null,
      );
    } else {
      return ProcessResult(
        success: false,
        message: 'Échec de la requête',
        duration: stopwatch.elapsed,
      );
    }
  } catch (e) {
    stopwatch.stop();
    return ProcessResult(
      success: false,
      message: 'Erreur d\'authentification: $e',
      duration: stopwatch.elapsed,
    );
  }
}

Future<ProcessResult> _testMainEndpoints(String token) async {
  final stopwatch = Stopwatch()..start();
  final endpoints = ['/users', '/employees', '/orders', '/dashboard'];
  final results = <String, bool>{};
  
  for (final endpoint in endpoints) {
    try {
      final result = await Process.run('curl', [
        '-s', '-o', '/dev/null', '-w', '%{http_code}',
        '-H', 'Authorization: Bearer $token',
        'http://localhost:8000/api/v1$endpoint'
      ]);
      
      results[endpoint] = result.exitCode == 0 && (result.stdout as String).trim() == '200';
    } catch (e) {
      results[endpoint] = false;
    }
  }
  
  stopwatch.stop();
  
  final allSuccess = results.values.every((success) => success);
  
  return ProcessResult(
    success: allSuccess,
    message: allSuccess ? 'Tous les endpoints accessibles' : 'Certains endpoints inaccessibles',
    duration: stopwatch.elapsed,
    data: results,
  );
}

Future<ProcessResult> _checkFlutterInstallation() async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await Process.run('flutter', ['--version']);
    
    stopwatch.stop();
    
    return ProcessResult(
      success: result.exitCode == 0,
      message: result.exitCode == 0 ? 'Flutter installé' : 'Flutter non trouvé',
      duration: stopwatch.elapsed,
      data: result.exitCode == 0 ? (result.stdout as String).trim() : null,
    );
  } catch (e) {
    stopwatch.stop();
    return ProcessResult(
      success: false,
      message: 'Flutter non installé: $e',
      duration: stopwatch.elapsed,
    );
  }
}

Future<ProcessResult> _runFlutterTests(String testPath) async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await Process.run('flutter', ['test', testPath]);
    
    stopwatch.stop();
    
    return ProcessResult(
      success: result.exitCode == 0,
      message: result.exitCode == 0 ? 'Tests réussis' : 'Tests échoués',
      duration: stopwatch.elapsed,
      data: {
        'exit_code': result.exitCode,
        'output': (result.stdout as String).length,
        'errors': (result.stderr as String).length,
      },
    );
  } catch (e) {
    stopwatch.stop();
    return ProcessResult(
      success: false,
      message: 'Erreur lors des tests: $e',
      duration: stopwatch.elapsed,
    );
  }
}

Future<ProcessResult> _checkAvailableDevices() async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await Process.run('flutter', ['devices']);
    
    stopwatch.stop();
    
    if (result.exitCode == 0) {
      final output = result.stdout as String;
      final lines = output.split('\n');
      
      // Chercher les appareils connectés
      for (final line in lines) {
        if (line.contains('•') && !line.contains('No connected devices')) {
          final deviceName = line.split('•')[1].trim().split('•')[0].trim();
          return ProcessResult(
            success: true,
            message: 'Appareil disponible',
            duration: stopwatch.elapsed,
            data: deviceName,
          );
        }
      }
    }
    
    return ProcessResult(
      success: false,
      message: 'Aucun appareil disponible',
      duration: stopwatch.elapsed,
    );
  } catch (e) {
    stopwatch.stop();
    return ProcessResult(
      success: false,
      message: 'Erreur de vérification des appareils: $e',
      duration: stopwatch.elapsed,
    );
  }
}

Future<ProcessResult> _runFlutterDriverTests() async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await Process.run('flutter', ['drive', '--target=test_driver/app_test.dart']);
    
    stopwatch.stop();
    
    return ProcessResult(
      success: result.exitCode == 0,
      message: result.exitCode == 0 ? 'Tests E2E réussis' : 'Tests E2E échoués',
      duration: stopwatch.elapsed,
      data: {
        'exit_code': result.exitCode,
        'output_length': (result.stdout as String).length,
      },
    );
  } catch (e) {
    stopwatch.stop();
    return ProcessResult(
      success: false,
      message: 'Erreur lors des tests E2E: $e',
      duration: stopwatch.elapsed,
    );
  }
}

Future<bool> _validateBackendConfig() async {
  try {
    final envFile = File('aramco-backend/.env');
    return await envFile.exists();
  } catch (e) {
    return false;
  }
}

Future<bool> _validateFrontendConfig() async {
  try {
    final pubspecFile = File('pubspec.yaml');
    return await pubspecFile.exists();
  } catch (e) {
    return false;
  }
}

Future<bool> _validateDatabase() async {
  try {
    final result = await Process.run('curl', [
      '-s', 'http://localhost:8000/api/v1/health'
    ]);
    
    if (result.exitCode == 0) {
      final response = jsonDecode(result.stdout as String);
      return response['data']?['database'] == 'connected';
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> _validateDependencies() async {
  try {
    final result = await Process.run('flutter', ['pub', 'get']);
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

Map<String, dynamic> _parsePerformanceOutput(String output) {
  final metrics = <String, dynamic>{};
  
  // Parser les métriques de performance du output
  final lines = output.split('\n');
  for (final line in lines) {
    if (line.contains('Taux de succès:')) {
      final rate = line.split(':')[1].trim().replaceAll('%', '');
      metrics['success_rate'] = double.tryParse(rate) ?? 0.0;
    } else if (line.contains('Temps de réponse moyen:')) {
      final time = line.split(':')[1].trim().replaceAll('ms', '');
      metrics['avg_response_time'] = double.tryParse(time) ?? 0.0;
    } else if (line.contains('Requêtes par seconde:')) {
      final rps = line.split(':')[1].trim();
      metrics['requests_per_second'] = double.tryParse(rps) ?? 0.0;
    }
  }
  
  return metrics;
}

class TestResult {
  final String name;
  final bool success;
  final String message;
  final Duration duration;
  final Map<String, dynamic>? details;

  TestResult({
    required this.name,
    required this.success,
    required this.message,
    required this.duration,
    this.details,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'success': success,
    'message': message,
    'duration_ms': duration.inMilliseconds,
    'details': details,
  };
}

class ProcessResult {
  final bool success;
  final String message;
  final Duration duration;
  final dynamic data;

  ProcessResult({
    required this.success,
    required this.message,
    required this.duration,
    this.data,
  });
}

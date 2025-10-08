#!/usr/bin/env dart

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Script de test de charge et performance pour l'API Aramco SA
/// Usage: dart scripts/performance_test.dart
void main() async {
  print('🚀 Test de Charge et Performance - API Aramco SA');
  print('=' * 60);

  const String baseUrl = 'http://localhost:8000/api/v1';
  const int concurrentUsers = 10;
  const int requestsPerUser = 20;
  const Duration testDuration = Duration(seconds: 30);

  // Test 1: Test de charge basique
  await runLoadTest(baseUrl, concurrentUsers, requestsPerUser);

  // Test 2: Test de stress
  await runStressTest(baseUrl, Duration(seconds: 60));

  // Test 3: Test d'endurance
  await runEnduranceTest(baseUrl, testDuration);

  // Test 4: Test de pics de charge
  await runSpikeTest(baseUrl);

  print('\n✅ Tests de performance terminés!');
}

Future<void> runLoadTest(String baseUrl, int users, int requestsPerUser) async {
  print('\n📊 Test 1: Test de Charge Basique');
  print('-' * 40);
  print('Utilisateurs concurrents: $users');
  print('Requêtes par utilisateur: $requestsPerUser');
  print('Total des requêtes: ${users * requestsPerUser}');

  final stopwatch = Stopwatch()..start();
  final futures = <Future<LoadTestResult>>[];
  String? authToken = await getAuthToken();

  for (int i = 0; i < users; i++) {
    futures.add(runUserLoadTest(baseUrl, i + 1, requestsPerUser, authToken));
  }

  final results = await Future.wait(futures);
  stopwatch.stop();

  // Calcul des statistiques
  int totalRequests = 0;
  int successfulRequests = 0;
  int failedRequests = 0;
  int totalResponseTime = 0;

  for (final result in results) {
    totalRequests += result.totalRequests;
    successfulRequests += result.successfulRequests;
    failedRequests += result.failedRequests;
    totalResponseTime += result.totalResponseTime;
  }

  final averageResponseTime = totalResponseTime / totalRequests;
  final successRate = (successfulRequests / totalRequests) * 100;
  final requestsPerSecond = totalRequests / (stopwatch.elapsedMilliseconds / 1000);

  print('\n📈 Résultats du Test de Charge:');
  print('   Durée totale: ${stopwatch.elapsedMilliseconds}ms');
  print('   Requêtes totales: $totalRequests');
  print('   Requêtes réussies: $successfulRequests');
  print('   Requêtes échouées: $failedRequests');
  print('   Taux de succès: ${successRate.toStringAsFixed(2)}%');
  print('   Temps de réponse moyen: ${averageResponseTime.toStringAsFixed(2)}ms');
  print('   Requêtes par seconde: ${requestsPerSecond.toStringAsFixed(2)}');

  // Vérification des seuils de performance
  if (successRate < 95) {
    print('⚠️  Taux de succès inférieur à 95%');
  }
  if (averageResponseTime > 1000) {
    print('⚠️  Temps de réponse moyen supérieur à 1s');
  }
  if (requestsPerSecond < 10) {
    print('⚠️  Moins de 10 requêtes par seconde');
  }
}

Future<void> runStressTest(String baseUrl, Duration duration) async {
  print('\n🔥 Test 2: Test de Stress');
  print('-' * 40);
  print('Durée du test: ${duration.inSeconds} secondes');
  print('Augmentation progressive de la charge');

  final stopwatch = Stopwatch()..start();
  int currentUsers = 1;
  final maxUsers = 50;
  final results = <StressTestResult>[];

  while (stopwatch.elapsed < duration && currentUsers <= maxUsers) {
    print('   Test avec $currentUsers utilisateurs...');
    
    final testStopwatch = Stopwatch()..start();
    final futures = <Future<LoadTestResult>>[];
    String? authToken = await getAuthToken();

    for (int i = 0; i < currentUsers; i++) {
      futures.add(runUserLoadTest(baseUrl, i + 1, 5, authToken));
    }

    final testResults = await Future.wait(futures);
    testStopwatch.stop();

    int successful = 0;
    int totalResponseTime = 0;
    int totalRequests = 0;

    for (final result in testResults) {
      successful += result.successfulRequests;
      totalResponseTime += result.totalResponseTime;
      totalRequests += result.totalRequests;
    }

    final avgResponseTime = totalResponseTime / totalRequests;
    final successRate = (successful / totalRequests) * 100;

    results.add(StressTestResult(
      users: currentUsers,
      successRate: successRate,
      averageResponseTime: avgResponseTime,
      requestsPerSecond: totalRequests / (testStopwatch.elapsedMilliseconds / 1000),
    ));

    print('     Taux de succès: ${successRate.toStringAsFixed(2)}%');
    print('     Temps de réponse: ${avgResponseTime.toStringAsFixed(2)}ms');

    // Augmenter le nombre d'utilisateurs
    currentUsers += 5;
    
    // Attendre avant le prochain test
    await Future.delayed(Duration(seconds: 2));
  }

  // Trouver le point de rupture
  final breakingPoint = results.where((r) => r.successRate < 90).firstOrNull;
  if (breakingPoint != null) {
    print('\n💥 Point de rupture détecté:');
    print('   ${breakingPoint.users} utilisateurs');
    print('   Taux de succès: ${breakingPoint.successRate.toStringAsFixed(2)}%');
  } else {
    print('\n✅ Aucun point de rupture détecté jusqu\'à $maxUsers utilisateurs');
  }
}

Future<void> runEnduranceTest(String baseUrl, Duration duration) async {
  print('\n⏱️  Test 3: Test d\'Endurance');
  print('-' * 40);
  print('Durée du test: ${duration.inMinutes} minutes');
  print('Charge constante: 5 utilisateurs');

  final stopwatch = Stopwatch()..start();
  final results = <EnduranceTestResult>[];
  String? authToken = await getAuthToken();

  while (stopwatch.elapsed < duration) {
    final testStopwatch = Stopwatch()..start();
    final futures = <Future<LoadTestResult>>[];

    for (int i = 0; i < 5; i++) {
      futures.add(runUserLoadTest(baseUrl, i + 1, 10, authToken));
    }

    final testResults = await Future.wait(futures);
    testStopwatch.stop();

    int successful = 0;
    int totalResponseTime = 0;
    int totalRequests = 0;

    for (final result in testResults) {
      successful += result.successfulRequests;
      totalResponseTime += result.totalResponseTime;
      totalRequests += result.totalRequests;
    }

    final avgResponseTime = totalResponseTime / totalRequests;
    final successRate = (successful / totalRequests) * 100;

    results.add(EnduranceTestResult(
      timestamp: stopwatch.elapsed,
      successRate: successRate,
      averageResponseTime: avgResponseTime,
      requestsPerSecond: totalRequests / (testStopwatch.elapsedMilliseconds / 1000),
    ));

    print('   ${stopwatch.elapsed.inMinutes}m: ${successRate.toStringAsFixed(1)}% succès, ${avgResponseTime.toStringAsFixed(0)}ms');

    // Attendre avant le prochain test
    await Future.delayed(Duration(minutes: 1));
  }

  // Analyse de la stabilité
  final successRates = results.map((r) => r.successRate).toList();
  final responseTimes = results.map((r) => r.averageResponseTime).toList();

  final avgSuccessRate = successRates.reduce((a, b) => a + b) / successRates.length;
  final avgResponseTime = responseTimes.reduce((a, b) => a + b) / responseTimes.length;

  final successRateStdDev = _calculateStandardDeviation(successRates);
  final responseTimeStdDev = _calculateStandardDeviation(responseTimes);

  print('\n📊 Résultats du Test d\'Endurance:');
  print('   Taux de succès moyen: ${avgSuccessRate.toStringAsFixed(2)}%');
  print('   Écart-type (succès): ${successRateStdDev.toStringAsFixed(2)}%');
  print('   Temps de réponse moyen: ${avgResponseTime.toStringAsFixed(2)}ms');
  print('   Écart-type (réponse): ${responseTimeStdDev.toStringAsFixed(2)}ms');

  if (successRateStdDev > 5) {
    print('⚠️  Taux de succès instable');
  }
  if (responseTimeStdDev > 200) {
    print('⚠️  Temps de réponse instable');
  }
}

Future<void> runSpikeTest(String baseUrl) async {
  print('\n📈 Test 4: Test de Pics de Charge');
  print('-' * 40);
  print('Simulation de pics soudains de trafic');

  String? authToken = await getAuthToken();

  // Phase 1: Charge normale (2 minutes)
  print('   Phase 1: Charge normale (2 minutes)...');
  await runSpikePhase(baseUrl, 5, Duration(minutes: 2), authToken);

  // Phase 2: Pic de charge (30 secondes)
  print('   Phase 2: Pic de charge (30 secondes)...');
  await runSpikePhase(baseUrl, 30, Duration(seconds: 30), authToken);

  // Phase 3: Retour à la normale (2 minutes)
  print('   Phase 3: Retour à la normale (2 minutes)...');
  await runSpikePhase(baseUrl, 5, Duration(minutes: 2), authToken);

  print('✅ Test de pics terminé');
}

Future<void> runSpikePhase(String baseUrl, int users, Duration duration, String? authToken) async {
  final stopwatch = Stopwatch()..start();
  final futures = <Future<void>>[];

  for (int i = 0; i < users; i++) {
    futures.add(runContinuousLoad(baseUrl, duration, authToken));
  }

  await Future.wait(futures);
  stopwatch.stop();
  print('     Phase terminée en ${stopwatch.elapsed.inSeconds} secondes');
}

Future<void> runContinuousLoad(String baseUrl, Duration duration, String? authToken) async {
  final stopwatch = Stopwatch()..start();
  
  while (stopwatch.elapsed < duration) {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(Duration(seconds: 5));

      if (response.statusCode != 200) {
        print('⚠️  Erreur de réponse: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️  Erreur de requête: $e');
    }

    await Future.delayed(Duration(milliseconds: 100));
  }
}

Future<LoadTestResult> runUserLoadTest(String baseUrl, int userId, int requestCount, String? authToken) async {
  int successfulRequests = 0;
  int failedRequests = 0;
  int totalResponseTime = 0;

  final endpoints = [
    '/health',
    '/users',
    '/employees',
    '/orders',
    '/dashboard',
  ];

  for (int i = 0; i < requestCount; i++) {
    try {
      final endpoint = endpoints[Random().nextInt(endpoints.length)];
      final stopwatch = Stopwatch()..start();

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode == 200) {
        successfulRequests++;
      } else {
        failedRequests++;
      }

      totalResponseTime += stopwatch.elapsedMilliseconds;
    } catch (e) {
      failedRequests++;
    }

    // Pause entre les requêtes
    await Future.delayed(Duration(milliseconds: 50 + Random().nextInt(100)));
  }

  return LoadTestResult(
    userId: userId,
    totalRequests: requestCount,
    successfulRequests: successfulRequests,
    failedRequests: failedRequests,
    totalResponseTime: totalResponseTime,
  );
}

Future<String?> getAuthToken() async {
  try {
    final loginData = {
      'email': 'admin@aramco-sa.com',
      'password': 'password123',
    };

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/v1/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(loginData),
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']?['token'];
    }
  } catch (e) {
    print('Erreur lors de l\'obtention du token: $e');
  }
  
  return null;
}

double _calculateStandardDeviation(List<double> values) {
  if (values.isEmpty) return 0;
  
  final mean = values.reduce((a, b) => a + b) / values.length;
  final variance = values.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / values.length;
  return sqrt(variance);
}

class LoadTestResult {
  final int userId;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final int totalResponseTime;

  LoadTestResult({
    required this.userId,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.totalResponseTime,
  });
}

class StressTestResult {
  final int users;
  final double successRate;
  final double averageResponseTime;
  final double requestsPerSecond;

  StressTestResult({
    required this.users,
    required this.successRate,
    required this.averageResponseTime,
    required this.requestsPerSecond,
  });
}

class EnduranceTestResult {
  final Duration timestamp;
  final double successRate;
  final double averageResponseTime;
  final double requestsPerSecond;

  EnduranceTestResult({
    required this.timestamp,
    required this.successRate,
    required this.averageResponseTime,
    required this.requestsPerSecond,
  });
}

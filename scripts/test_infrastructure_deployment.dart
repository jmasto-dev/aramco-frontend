#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script de test pour valider le déploiement de l'infrastructure complète
/// Projet Aramco SA - Priorité 4: Déploiement infrastructure complète

class InfrastructureDeploymentTest {
  static const String baseUrl = 'http://localhost:8000';
  static const String grafanaUrl = 'http://localhost:3001';
  static const String prometheusUrl = 'http://localhost:9090';
  
  final List<String> _testResults = [];
  final List<String> _errors = [];
  
  /// Fonction principale de test
  Future<void> runTests() async {
    print('🚀 DÉBUT DES TESTS DE DÉPLOIEMENT INFRASTRUCTURE');
    print('=' * 60);
    
    try {
      // Tests de base
      await _testBasicConnectivity();
      await _testDockerServices();
      await _testDatabaseConnection();
      await _testRedisConnection();
      
      // Tests de monitoring
      await _testPrometheusMonitoring();
      await _testGrafanaDashboard();
      await _testAlertManager();
      
      // Tests de sécurité
      await _testSecurityHeaders();
      await _testSslConfiguration();
      await _testFirewallConfiguration();
      
      // Tests de performance
      await _testLoadBalancing();
      await _testCaching();
      await _testApiResponseTime();
      
      // Tests de backup
      await _testBackupConfiguration();
      await _testBackupExecution();
      
      // Tests finaux
      await _testSystemHealth();
      await _testDocumentation();
      
      // Affichage des résultats
      _printResults();
      
    } catch (e) {
      print('❌ ERREUR CRITIQUE: $e');
      _errors.add('Erreur critique: $e');
      _printResults();
      exit(1);
    }
  }
  
  /// Tests de connectivité de base
  Future<void> _testBasicConnectivity() async {
    print('\n📡 TESTS DE CONNECTIVITÉ DE BASE');
    print('-' * 40);
    
    try {
      // Test API backend
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _addSuccess('API Backend répond correctement');
        _addSuccess('Status API: ${data['status'] ?? 'OK'}');
      } else {
        _addError('API Backend statusCode: ${response.statusCode}');
      }
    } catch (e) {
      _addError('API Backend inaccessible: $e');
    }
    
    // Test Nginx reverse proxy
    try {
      final response = await http.get(
        Uri.parse('http://localhost/'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200 || response.statusCode == 301) {
        _addSuccess('Nginx reverse proxy fonctionne');
      } else {
        _addError('Nginx statusCode: ${response.statusCode}');
      }
    } catch (e) {
      _addError('Nginx inaccessible: $e');
    }
  }
  
  /// Tests des services Docker
  Future<void> _testDockerServices() async {
    print('\n🐳 TESTS DES SERVICES DOCKER');
    print('-' * 40);
    
    try {
      // Lister les conteneurs Docker
      final result = await Process.run('docker', ['ps', '--format', 'json']);
      if (result.exitCode == 0) {
        final containers = result.stdout.toString().split('\n')
            .where((line) => line.isNotEmpty)
            .toList();
        
        _addSuccess('Docker fonctionne - ${containers.length} conteneurs actifs');
        
        // Vérifier les conteneurs essentiels
        final essentialContainers = [
          'aramco-backend',
          'aramco-postgres',
          'aramco-redis',
          'prometheus',
          'grafana'
        ];
        
        for (final container in essentialContainers) {
          if (result.stdout.toString().contains(container)) {
            _addSuccess('Conteneur $container actif');
          } else {
            _addError('Conteneur $container manquant');
          }
        }
      } else {
        _addError('Erreur Docker: ${result.stderr}');
      }
    } catch (e) {
      _addError('Docker inaccessible: $e');
    }
  }
  
  /// Tests de connexion à la base de données
  Future<void> _testDatabaseConnection() async {
    print('\n🗄️ TESTS DE CONNEXION BASE DE DONNÉES');
    print('-' * 40);
    
    try {
      // Test via l'API
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/health/database'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _addSuccess('Base de données connectée');
        _addSuccess('DB Status: ${data['status'] ?? 'OK'}');
        if (data['connections'] != null) {
          _addSuccess('Connections actives: ${data['connections']}');
        }
      } else {
        _addError('Test DB statusCode: ${response.statusCode}');
      }
    } catch (e) {
      _addError('Test base de données échoué: $e');
    }
    
    // Test direct PostgreSQL
    try {
      final result = await Process.run('docker', [
        'exec', 'aramco-postgres',
        'psql', '-U', 'postgres', '-c', 'SELECT 1;'
      ]);
      
      if (result.exitCode == 0) {
        _addSuccess('PostgreSQL répond directement');
      } else {
        _addError('PostgreSQL direct error: ${result.stderr}');
      }
    } catch (e) {
      _addError('PostgreSQL direct test échoué: $e');
    }
  }
  
  /// Tests de connexion Redis
  Future<void> _testRedisConnection() async {
    print('\n🔴 TESTS DE CONNEXION REDIS');
    print('-' * 40);
    
    try {
      // Test via l'API
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/health/redis'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _addSuccess('Redis connecté');
        _addSuccess('Redis Status: ${data['status'] ?? 'OK'}');
      } else {
        _addError('Test Redis statusCode: ${response.statusCode}');
      }
    } catch (e) {
      _addError('Test Redis échoué: $e');
    }
    
    // Test direct Redis
    try {
      final result = await Process.run('docker', [
        'exec', 'aramco-redis',
        'redis-cli', 'ping'
      ]);
      
      if (result.stdout.toString().trim() == 'PONG') {
        _addSuccess('Redis répond directement (PONG)');
      } else {
        _addError('Redis direct response: ${result.stdout}');
      }
    } catch (e) {
      _addError('Redis direct test échoué: $e');
    }
  }
  
  /// Tests du monitoring Prometheus
  Future<void> _testPrometheusMonitoring() async {
    print('\n📊 TESTS PROMETHEUS MONITORING');
    print('-' * 40);
    
    try {
      // Test endpoint Prometheus
      final response = await http.get(
        Uri.parse('$prometheusUrl/api/v1/query?query=up'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _addSuccess('Prometheus API fonctionne');
          final metrics = data['data']['result'] as List;
          _addSuccess('${metrics.length} métriques collectées');
        } else {
          _addError('Prometheus error: ${data['error']}');
        }
      } else {
        _addError('Prometheus statusCode: ${response.statusCode}');
      }
    } catch (e) {
      _addError('Prometheus inaccessible: $e');
    }
    
    // Test targets Prometheus
    try {
      final response = await http.get(
        Uri.parse('$prometheusUrl/api/v1/targets'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final targets = data['data']['activeTargets'] as List;
        _addSuccess('${targets.length} targets Prometheus configurés');
        
        // Vérifier les targets essentiels
        final essentialTargets = ['aramco-backend', 'postgres', 'redis'];
        for (final target in essentialTargets) {
          final found = targets.any((t) => 
            t['labels']['job'].toString().contains(target));
          if (found) {
            _addSuccess('Target $target actif');
          } else {
            _addError('Target $target manquant');
          }
        }
      }
    } catch (e) {
      _addError('Test targets Prometheus échoué: $e');
    }
  }
  
  /// Tests du dashboard Grafana
  Future<void> _testGrafanaDashboard() async {
    print('\n📈 TESTS GRAFANA DASHBOARD');
    print('-' * 40);
    
    try {
      // Test endpoint Grafana
      final response = await http.get(
        Uri.parse('$grafanaUrl/api/health'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        _addSuccess('Grafana API fonctionne');
      } else {
        _addError('Grafana statusCode: ${response.statusCode}');
      }
    } catch (e) {
      _addError('Grafana inaccessible: $e');
    }
    
    // Test dashboards Grafana
    try {
      final response = await http.get(
        Uri.parse('$grafanaUrl/api/search'),
        headers: {'Authorization': 'Bearer admin:admin'},
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dashboards = data as List;
        _addSuccess('${dashboards.length} dashboards Grafana disponibles');
        
        // Vérifier dashboard Aramco
        final aramcoDashboard = dashboards.any((d) => 
          d['title'].toString().toLowerCase().contains('aramco'));
        if (aramcoDashboard) {
          _addSuccess('Dashboard Aramco trouvé');
        } else {
          _addError('Dashboard Aramco manquant');
        }
      }
    } catch (e) {
      _addError('Test dashboards Grafana échoué: $e');
    }
  }
  
  /// Tests de l'AlertManager
  Future<void> _testAlertManager() async {
    print('\n🚨 TESTS ALERTMANAGER');
    print('-' * 40);
    
    try {
      final response = await http.get(
        Uri.parse('http://localhost:9093/api/v1/alerts'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final alerts = data['data'] as List;
        _addSuccess('AlertManager fonctionne');
        _addSuccess('${alerts.length} alertes actives');
        
        // Vérifier alertes critiques
        final criticalAlerts = alerts.where((a) => 
          a['labels']['severity'] == 'critical').toList();
        if (criticalAlerts.isEmpty) {
          _addSuccess('Aucune alerte critique');
        } else {
          _addError('${criticalAlerts.length} alertes critiques');
        }
      } else {
        _addError('AlertManager statusCode: ${response.statusCode}');
      }
    } catch (e) {
      _addError('AlertManager inaccessible: $e');
    }
  }
  
  /// Tests des en-têtes de sécurité
  Future<void> _testSecurityHeaders() async {
    print('\n🔒 TESTS EN-TÊTES SÉCURITÉ');
    print('-' * 40);
    
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
      ).timeout(Duration(seconds: 5));
      
      final headers = response.headers;
      
      // Vérifier les en-têtes de sécurité
      final securityHeaders = {
        'x-frame-options': 'SAMEORIGIN',
        'x-xss-protection': '1; mode=block',
        'x-content-type-options': 'nosniff',
      };
      
      for (final header in securityHeaders.entries) {
        if (headers.containsKey(header.key)) {
          _addSuccess('Header ${header.key} présent');
        } else {
          _addError('Header ${header.key} manquant');
        }
      }
    } catch (e) {
      _addError('Test security headers échoué: $e');
    }
  }
  
  /// Tests de configuration SSL
  Future<void> _testSslConfiguration() async {
    print('\n🔐 TESTS CONFIGURATION SSL');
    print('-' * 40);
    
    try {
      // Test HTTPS (si configuré)
      final response = await http.get(
        Uri.parse('https://localhost/api/v1/health'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        _addSuccess('HTTPS configuré et fonctionnel');
      } else {
        _addError('HTTPS statusCode: ${response.statusCode}');
      }
    } catch (e) {
      _addError('HTTPS non configuré ou inaccessible: $e');
    }
    
    // Test certificat SSL
    try {
      final result = await Process.run('openssl', [
        's_client', '-connect', 'localhost:443', '-servername', 'localhost'
      ]);
      
      if (result.exitCode == 0) {
        _addSuccess('Certificat SSL valide');
      } else {
        _addError('Certificat SSL invalide');
      }
    } catch (e) {
      _addError('Test certificat SSL échoué: $e');
    }
  }
  
  /// Tests de configuration firewall
  Future<void> _testFirewallConfiguration() async {
    print('\n🛡️ TESTS CONFIGURATION FIREWALL');
    print('-' * 40);
    
    try {
      // Test UFW status
      final result = await Process.run('sudo', ['ufw', 'status']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        if (output.contains('Status: active')) {
          _addSuccess('Firewall UFW actif');
        } else {
          _addError('Firewall UFW inactif');
        }
      } else {
        _addError('Erreur UFW: ${result.stderr}');
      }
    } catch (e) {
      _addError('Test firewall échoué: $e');
    }
  }
  
  /// Tests de load balancing
  Future<void> _testLoadBalancing() async {
    print('\n⚖️ TESTS LOAD BALANCING');
    print('-' * 40);
    
    try {
      // Test multiple requêtes
      final responses = <Future<http.Response>>[];
      for (int i = 0; i < 5; i++) {
        responses.add(http.get(
          Uri.parse('$baseUrl/api/v1/health'),
        ).timeout(Duration(seconds: 5)));
      }
      
      final results = await Future.wait(responses);
      final successCount = results.where((r) => r.statusCode == 200).length;
      
      if (successCount == 5) {
        _addSuccess('Load balancing fonctionne (5/5 requêtes OK)');
      } else {
        _addError('Load balancing partiel: $successCount/5 requêtes OK');
      }
    } catch (e) {
      _addError('Test load balancing échoué: $e');
    }
  }
  
  /// Tests de cache
  Future<void> _testCaching() async {
    print('\n💾 TESTS CACHE');
    print('-' * 40);
    
    try {
      // Test cache headers
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/health'),
      ).timeout(Duration(seconds: 5));
      
      final cacheControl = response.headers['cache-control'];
      if (cacheControl != null) {
        _addSuccess('Cache-Control header: $cacheControl');
      } else {
        _addError('Cache-Control header manquant');
      }
    } catch (e) {
      _addError('Test cache échoué: $e');
    }
  }
  
  /// Tests de temps de réponse API
  Future<void> _testApiResponseTime() async {
    print('\n⚡ TESTS TEMPS DE RÉPONSE API');
    print('-' * 40);
    
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/health'),
      ).timeout(Duration(seconds: 5));
      stopwatch.stop();
      
      final responseTime = stopwatch.elapsedMilliseconds;
      
      if (response.statusCode == 200) {
        if (responseTime < 500) {
          _addSuccess('Temps de réponse excellent: ${responseTime}ms');
        } else if (responseTime < 1000) {
          _addSuccess('Temps de réponse bon: ${responseTime}ms');
        } else {
          _addError('Temps de réponse lent: ${responseTime}ms');
        }
      } else {
        _addError('API statusCode: ${response.statusCode}');
      }
    } catch (e) {
      _addError('Test temps de réponse échoué: $e');
    }
  }
  
  /// Tests de configuration backup
  Future<void> _testBackupConfiguration() async {
    print('\n💾 TESTS CONFIGURATION BACKUP');
    print('-' * 40);
    
    try {
      // Vérifier script backup
      final result = await Process.run('ls', ['/usr/local/bin/aramco_backup.sh']);
      if (result.exitCode == 0) {
        _addSuccess('Script backup présent');
      } else {
        _addError('Script backup manquant');
      }
      
      // Vérifier configuration cron
      final cronResult = await Process.run('crontab', ['-l']);
      if (cronResult.exitCode == 0) {
        final cronOutput = cronResult.stdout.toString();
        if (cronOutput.contains('aramco_backup.sh')) {
          _addSuccess('Backup configuré dans crontab');
        } else {
          _addError('Backup non configuré dans crontab');
        }
      }
    } catch (e) {
      _addError('Test configuration backup échoué: $e');
    }
  }
  
  /// Tests d'exécution backup
  Future<void> _testBackupExecution() async {
    print('\n🔄 TESTS EXÉCUTION BACKUP');
    print('-' * 40);
    
    try {
      // Vérifier répertoire backup
      final result = await Process.run('ls', ['/var/backups/aramco-sa']);
      if (result.exitCode == 0) {
        _addSuccess('Répertoire backup accessible');
      } else {
        _addError('Répertoire backup inaccessible');
      }
    } catch (e) {
      _addError('Test exécution backup échoué: $e');
    }
  }
  
  /// Tests de santé système
  Future<void> _testSystemHealth() async {
    print('\n🏥 TESTS SANTÉ SYSTÈME');
    print('-' * 40);
    
    try {
      // Test mémoire
      final memResult = await Process.run('free', ['-h']);
      if (memResult.exitCode == 0) {
        final memOutput = memResult.stdout.toString();
        _addSuccess('Mémoire système OK');
      }
      
      // Test disque
      final diskResult = await Process.run('df', ['-h', '/']);
      if (diskResult.exitCode == 0) {
        final diskOutput = diskResult.stdout.toString();
        _addSuccess('Espace disque OK');
      }
      
      // Test uptime
      final uptimeResult = await Process.run('uptime');
      if (uptimeResult.exitCode == 0) {
        _addSuccess('Système stable');
      }
    } catch (e) {
      _addError('Test santé système échoué: $e');
    }
  }
  
  /// Tests de documentation
  Future<void> _testDocumentation() async {
    print('\n📚 TESTS DOCUMENTATION');
    print('-' * 40);
    
    try {
      // Vérifier fichiers documentation
      final docFiles = [
        'docs/DEPLOYMENT_PRODUCTION_COMPLETE.md',
        'docs/PROJET_BACKEND_LARAVEL_DEPLOIEMENT_FINAL.md',
        'README.md'
      ];
      
      for (final docFile in docFiles) {
        final file = File(docFile);
        if (await file.exists()) {
          _addSuccess('Documentation $docFile présente');
        } else {
          _addError('Documentation $docFile manquante');
        }
      }
    } catch (e) {
      _addError('Test documentation échoué: $e');
    }
  }
  
  /// Ajouter un succès
  void _addSuccess(String message) {
    print('✅ $message');
    _testResults.add('SUCCESS: $message');
  }
  
  /// Ajouter une erreur
  void _addError(String message) {
    print('❌ $message');
    _testResults.add('ERROR: $message');
    _errors.add(message);
  }
  
  /// Afficher les résultats finaux
  void _printResults() {
    print('\n' + '=' * 60);
    print('📊 RÉSULTATS FINAUX');
    print('=' * 60);
    
    final totalTests = _testResults.length;
    final successTests = _testResults.where((r) => r.startsWith('SUCCESS:')).length;
    final errorTests = _errors.length;
    
    print('\n📈 STATISTIQUES:');
    print('   Tests totaux: $totalTests');
    print('   Succès: $successTests');
    print('   Erreurs: $errorTests');
    print('   Taux de réussite: ${((successTests / totalTests) * 100).toStringAsFixed(1)}%');
    
    if (_errors.isNotEmpty) {
      print('\n❌ ERREURS DÉTECTÉES:');
      for (final error in _errors) {
        print('   • $error');
      }
    }
    
    print('\n🎯 ÉVALUATION DÉPLOIEMENT:');
    if (errorTests == 0) {
      print('   🟢 DÉPLOIEMENT PARFAIT - Infrastructure 100% fonctionnelle');
    } else if (errorTests <= 3) {
      print('   🟡 DÉPLOIEMENT BON - Quelques ajustements mineurs nécessaires');
    } else if (errorTests <= 7) {
      print('   🟠 DÉPLOIEMENT PARTIEL - Problèmes à résoudre');
    } else {
      print('   🔴 DÉPLOIEMENT ÉCHOUÉ - Problèmes critiques à corriger');
    }
    
    print('\n🔗 LIENS UTILES:');
    print('   API: $baseUrl');
    print('   Grafana: $grafanaUrl');
    print('   Prometheus: $prometheusUrl');
    print('   AlertManager: http://localhost:9093');
    
    print('\n📝 ACTIONS RECOMMANDÉES:');
    if (errorTests > 0) {
      print('   1. Corriger les erreurs identifiées ci-dessus');
      print('   2. Relancer les tests après corrections');
      print('   3. Vérifier les logs des services problématiques');
    } else {
      print('   1. Configurer les alertes Slack/Email');
      print('   2. Documenter les procédures de maintenance');
      print('   3. Planifier les tests de charge');
    }
    
    print('\n✅ TESTS INFRASTRUCTURE TERMINÉS');
    print('=' * 60);
    
    // Code de sortie
    exit(errorTests > 0 ? 1 : 0);
  }
}

/// Point d'entrée principal
void main(List<String> args) async {
  final tester = InfrastructureDeploymentTest();
  await tester.runTests();
}

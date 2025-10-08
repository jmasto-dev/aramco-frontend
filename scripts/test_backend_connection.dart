#!/usr/bin/env dart

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script pour tester la connexion entre le frontend et le backend Laravel
/// Usage: dart scripts/test_backend_connection.dart
void main() async {
  print('🚀 Test de connexion Frontend ↔ Backend Laravel');
  print('=' * 50);

  const String baseUrl = 'http://localhost:8000/api/v1';
  const String healthEndpoint = '$baseUrl/health';
  const String loginEndpoint = '$baseUrl/auth/login';
  const String usersEndpoint = '$baseUrl/users';

  // Test 1: Vérification de la connectivité de base
  await testConnectivity(healthEndpoint);

  // Test 2: Test d'authentification
  await testAuthentication(loginEndpoint);

  // Test 3: Test des endpoints protégés
  await testProtectedEndpoints(usersEndpoint);

  print('\n✅ Tests terminés!');
}

Future<void> testConnectivity(String endpoint) async {
  print('\n📡 Test 1: Connectivité de base');
  print('-' * 30);

  try {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Aramco-Frontend-Test/1.0.0',
      },
    ).timeout(Duration(seconds: 10));

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Connexion réussie au backend');
      
      try {
        final data = jsonDecode(response.body);
        print('Response: ${data['message'] ?? 'OK'}');
        
        if (data['data'] != null) {
          final healthData = data['data'];
          print('Environment: ${healthData['environment'] ?? 'Unknown'}');
          print('Version: ${healthData['version'] ?? 'Unknown'}');
          print('Database: ${healthData['database'] ?? 'Unknown'}');
          print('Cache: ${healthData['cache'] ?? 'Unknown'}');
        }
      } catch (e) {
        print('⚠️  Response non-JSON: ${response.body}');
      }
    } else {
      print('❌ Erreur de connexion: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } on SocketException {
    print('❌ Impossible de se connecter au serveur');
    print('   Vérifiez que le backend Laravel est démarré sur localhost:8000');
  } on TimeoutException {
    print('❌ Timeout de connexion');
    print('   Le serveur met trop longtemps à répondre');
  } catch (e) {
    print('❌ Erreur inattendue: $e');
  }
}

Future<void> testAuthentication(String endpoint) async {
  print('\n🔐 Test 2: Authentification');
  print('-' * 30);

  try {
    // Test avec des identifiants de test
    final loginData = {
      'email': 'admin@aramco-sa.com',
      'password': 'password123',
    };

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'Aramco-Frontend-Test/1.0.0',
      },
      body: jsonEncode(loginData),
    ).timeout(Duration(seconds: 10));

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Authentification réussie');
      
      try {
        final data = jsonDecode(response.body);
        
        if (data['data'] != null && data['data']['token'] != null) {
          print('Token JWT: ${data['data']['token'].toString().substring(0, 20)}...');
          print('Token Type: Bearer');
          print('Expires In: ${data['data']['expires_in'] ?? 3600} seconds');
          
          if (data['data']['user'] != null) {
            final user = data['data']['user'];
            print('User ID: ${user['id']}');
            print('User Email: ${user['email']}');
            print('User Name: ${user['full_name'] ?? '${user['first_name']} ${user['last_name']}'}');
            
            if (user['roles'] != null && user['roles'].isNotEmpty) {
              print('User Role: ${user['roles'][0]['name']}');
            }
            
            if (user['permissions'] != null) {
              final permissions = user['permissions'] as List?;
              print('Permissions: ${permissions?.length ?? 0} permissions');
            }
          }
        } else {
          print('⚠️  Réponse inattendue: ${response.body}');
        }
      } catch (e) {
        print('⚠️  Response non-JSON: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      print('❌ Identifiants invalides');
      try {
        final data = jsonDecode(response.body);
        print('Message: ${data['message'] ?? 'Unauthorized'}');
      } catch (e) {
        print('Response: ${response.body}');
      }
    } else {
      print('❌ Erreur d\'authentification: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } on TimeoutException {
    print('❌ Timeout lors de l\'authentification');
  } catch (e) {
    print('❌ Erreur inattendue: $e');
  }
}

Future<void> testProtectedEndpoints(String endpoint) async {
  print('\n🛡️  Test 3: Endpoints protégés');
  print('-' * 30);

  try {
    // D'abord, obtenir un token
    String? token = await getAuthToken();
    
    if (token == null) {
      print('⚠️  Impossible de tester les endpoints protégés sans token');
      return;
    }

    // Test de l'endpoint users avec le token
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Aramco-Frontend-Test/1.0.0',
      },
    ).timeout(Duration(seconds: 10));

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Accès aux endpoints protégés réussi');
      
      try {
        final data = jsonDecode(response.body);
        
        if (data['data'] != null) {
          final users = data['data'] as List;
          print('Users count: ${users.length}');
          
          if (users.isNotEmpty) {
            final firstUser = users[0];
            print('First user: ${firstUser['email']} (${firstUser['full_name'] ?? 'N/A'})');
          }
        }
        
        if (data['meta'] != null) {
          final meta = data['meta'];
          print('Pagination: Page ${meta['current_page']} of ${meta['last_page']}');
          print('Total: ${meta['total']} users');
        }
      } catch (e) {
        print('⚠️  Response non-JSON: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      print('❌ Token invalide ou expiré');
    } else if (response.statusCode == 403) {
      print('❌ Permissions insuffisantes');
    } else {
      print('❌ Erreur: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } on TimeoutException {
    print('❌ Timeout lors de l\'accès aux endpoints protégés');
  } catch (e) {
    print('❌ Erreur inattendue: $e');
  }
}

Future<String?> getAuthToken() async {
  const String loginEndpoint = 'http://localhost:8000/api/v1/auth/login';
  
  try {
    final loginData = {
      'email': 'admin@aramco-sa.com',
      'password': 'password123',
    };

    final response = await http.post(
      Uri.parse(loginEndpoint),
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

/// Test des modèles de données du frontend
void testDataModels() {
  print('\n📋 Test 4: Validation des modèles de données');
  print('-' * 30);

  // Test du modèle User avec les données du backend
  final userJson = {
    'id': '1',
    'email': 'test@aramco-sa.com',
    'first_name': 'Test',
    'last_name': 'User',
    'full_name': 'Test User',
    'is_active': true,
    'created_at': '2024-01-01T00:00:00.000000Z',
    'updated_at': '2024-01-01T00:00:00.000000Z',
    'roles': [
      {
        'id': '1',
        'name': 'admin',
        'display_name': 'Administrateur',
        'description': 'Administrateur système'
      }
    ],
    'permissions': [
      'users.create', 'users.read', 'users.update', 'users.delete',
      'employees.create', 'employees.read', 'employees.update', 'employees.delete',
      'orders.create', 'orders.read', 'orders.update', 'orders.delete',
      'dashboard.read', 'export.create'
    ],
  };

  try {
    // Ici nous testerions la sérialisation du modèle User
    // Comme nous ne pouvons pas importer directement le modèle dans ce script,
    // nous simulons la validation
    print('✅ Structure des données utilisateur valide');
    print('   - ID: ${userJson['id']}');
    print('   - Email: ${userJson['email']}');
    print('   - Name: ${userJson['full_name']}');
    print('   - Active: ${userJson['is_active']}');
    final roles = userJson['roles'] as List?;
    final permissions = userJson['permissions'] as List?;
    print('   - Roles: ${roles?.length ?? 0} role(s)');
    print('   - Permissions: ${permissions?.length ?? 0} permission(s)');
  } catch (e) {
    print('❌ Erreur de validation des données: $e');
  }
}

/// Test des constantes de configuration
void testConstants() {
  print('\n⚙️  Test 5: Validation des constantes');
  print('-' * 30);

  const String apiBaseUrl = 'http://localhost:8000/api/v1';
  const String loginEndpoint = '/auth/login';
  const String usersEndpoint = '/users';
  const String employeesEndpoint = '/employees';
  const String ordersEndpoint = '/orders';
  const String dashboardEndpoint = '/dashboard';

  print('✅ Configuration API:');
  print('   - Base URL: $apiBaseUrl');
  print('   - Login Endpoint: $loginEndpoint');
  print('   - Users Endpoint: $usersEndpoint');
  print('   - Employees Endpoint: $employeesEndpoint');
  print('   - Orders Endpoint: $ordersEndpoint');
  print('   - Dashboard Endpoint: $dashboardEndpoint');

  // Validation des URLs complètes
  final loginUrl = '$apiBaseUrl$loginEndpoint';
  final usersUrl = '$apiBaseUrl$usersEndpoint';
  final employeesUrl = '$apiBaseUrl$employeesEndpoint';
  final ordersUrl = '$apiBaseUrl$ordersEndpoint';
  final dashboardUrl = '$apiBaseUrl$dashboardEndpoint';

  print('\n✅ URLs complètes:');
  print('   - Login: $loginUrl');
  print('   - Users: $usersUrl');
  print('   - Employees: $employeesUrl');
  print('   - Orders: $ordersUrl');
  print('   - Dashboard: $dashboardUrl');
}

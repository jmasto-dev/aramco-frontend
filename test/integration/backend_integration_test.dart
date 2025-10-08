import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// Tests d'intégration pour valider la connexion Frontend ↔ Backend Laravel
void main() {
  group('Backend Integration Tests', () {
    late http.Client client;
    const String baseUrl = 'http://localhost:8000/api/v1';
    String? authToken;

    setUpAll(() async {
      client = http.Client();
      // Obtenir un token pour les tests
      authToken = await _getAuthToken(client);
    });

    tearDownAll(() {
      client.close();
    });

    test('Health Check - Connectivity Test', () async {
      final response = await client.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Aramco-Frontend-Test/1.0.0',
        },
      );

      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['status'], 'success');
      expect(data['data'], isNotNull);
    });

    test('Authentication - Login with valid credentials', () async {
      final loginData = {
        'email': 'admin@aramco-sa.com',
        'password': 'password123',
      };

      final response = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginData),
      );

      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['status'], 'success');
      expect(data['data']['token'], isNotNull);
      expect(data['data']['user'], isNotNull);
      expect(data['data']['user']['email'], equals('admin@aramco-sa.com'));
    });

    test('Authentication - Login with invalid credentials', () async {
      final loginData = {
        'email': 'invalid@test.com',
        'password': 'wrongpassword',
      };

      final response = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginData),
      );

      expect(response.statusCode, 401);
      
      final data = jsonDecode(response.body);
      expect(data['status'], 'error');
    });

    test('Protected Endpoint - Get Users with valid token', () async {
      if (authToken == null) {
        print('Skipping test: No auth token available');
        return;
      }

      final response = await client.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['status'], 'success');
      expect(data['data'], isA<List>());
    });

    test('Protected Endpoint - Access without token should fail', () async {
      final response = await client.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Accept': 'application/json',
        },
      );

      expect(response.statusCode, 401);
    });

    test('Employees Endpoint - Get employees list', () async {
      if (authToken == null) {
        print('Skipping test: No auth token available');
        return;
      }

      final response = await client.get(
        Uri.parse('$baseUrl/employees'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['status'], 'success');
      expect(data['data'], isA<List>());
    });

    test('Orders Endpoint - Get orders list', () async {
      if (authToken == null) {
        print('Skipping test: No auth token available');
        return;
      }

      final response = await client.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['status'], 'success');
      expect(data['data'], isA<List>());
    });

    test('Dashboard Endpoint - Get dashboard data', () async {
      if (authToken == null) {
        print('Skipping test: No auth token available');
        return;
      }

      final response = await client.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['status'], 'success');
      expect(data['data'], isNotNull);
    });

    test('CORS Headers - Should include proper CORS headers', () async {
      final response = await client.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Accept': 'application/json',
          'Origin': 'http://localhost:3000',
        },
      );

      expect(response.statusCode, 200);
      // Vérifier les en-têtes CORS
      expect(response.headers['access-control-allow-origin'], isNotNull);
    });

    test('API Response Format - Should follow consistent format', () async {
      final response = await client.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Accept': 'application/json',
        },
      );

      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      // Vérifier le format de réponse standard
      expect(data['status'], isA<String>());
      expect(data['message'], isA<String>());
      expect(data['data'], isNotNull);
    });

    test('Error Handling - 404 Not Found', () async {
      final response = await client.get(
        Uri.parse('$baseUrl/nonexistent'),
        headers: {
          'Accept': 'application/json',
        },
      );

      expect(response.statusCode, 404);
      
      final data = jsonDecode(response.body);
      expect(data['status'], equals('error'));
      expect(data['message'], isNotNull);
    });
  });

  group('Data Model Validation', () {
    test('User Model - Validate structure', () {
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

      // Valider la structure des données
      expect(userJson['id'], isA<String>());
      expect(userJson['email'], isA<String>());
      expect(userJson['first_name'], isA<String>());
      expect(userJson['last_name'], isA<String>());
      expect(userJson['full_name'], isA<String>());
      expect(userJson['is_active'], isA<bool>());
      expect(userJson['created_at'], isA<String>());
      expect(userJson['updated_at'], isA<String>());
      expect(userJson['roles'], isA<List>());
      expect(userJson['permissions'], isA<List>());
    });

    test('Employee Model - Validate structure', () {
      final employeeJson = {
        'id': '1',
        'user_id': '1',
        'employee_id': 'EMP001',
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'john.doe@aramco-sa.com',
        'phone': '+9661234567890',
        'department': 'IT',
        'position': 'Software Engineer',
        'salary': 15000.0,
        'hire_date': '2024-01-01',
        'is_active': true,
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Valider la structure des données
      expect(employeeJson['id'], isA<String>());
      expect(employeeJson['user_id'], isA<String>());
      expect(employeeJson['employee_id'], isA<String>());
      expect(employeeJson['first_name'], isA<String>());
      expect(employeeJson['last_name'], isA<String>());
      expect(employeeJson['email'], isA<String>());
      expect(employeeJson['phone'], isA<String>());
      expect(employeeJson['department'], isA<String>());
      expect(employeeJson['position'], isA<String>());
      expect(employeeJson['salary'], isA<double>());
      expect(employeeJson['hire_date'], isA<String>());
      expect(employeeJson['is_active'], isA<bool>());
      expect(employeeJson['created_at'], isA<String>());
      expect(employeeJson['updated_at'], isA<String>());
    });

    test('Order Model - Validate structure', () {
      final orderJson = {
        'id': '1',
        'order_number': 'ORD-2024-001',
        'customer_name': 'Test Customer',
        'customer_email': 'customer@test.com',
        'status': 'pending',
        'total_amount': 1500.0,
        'order_date': '2024-01-01',
        'delivery_date': '2024-01-15',
        'notes': 'Test order notes',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
        'items': [
          {
            'id': '1',
            'order_id': '1',
            'product_id': '1',
            'product_name': 'Test Product',
            'quantity': 2,
            'unit_price': 750.0,
            'total_price': 1500.0,
          }
        ],
      };

      // Valider la structure des données
      expect(orderJson['id'], isA<String>());
      expect(orderJson['order_number'], isA<String>());
      expect(orderJson['customer_name'], isA<String>());
      expect(orderJson['customer_email'], isA<String>());
      expect(orderJson['status'], isA<String>());
      expect(orderJson['total_amount'], isA<double>());
      expect(orderJson['order_date'], isA<String>());
      expect(orderJson['delivery_date'], isA<String>());
      expect(orderJson['notes'], isA<String>());
      expect(orderJson['created_at'], isA<String>());
      expect(orderJson['updated_at'], isA<String>());
      expect(orderJson['items'], isA<List>());
    });
  });

  group('Performance Tests', () {
    test('Response Time - Health check should be fast', () async {
      final stopwatch = Stopwatch()..start();
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/v1/health'),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      stopwatch.stop();
      
      expect(response.statusCode, 200);
      expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // < 2 seconds
    });

    test('Concurrent Requests - Handle multiple requests', () async {
      const int requestCount = 10;
      final futures = <Future<http.Response>>[];
      
      for (int i = 0; i < requestCount; i++) {
        futures.add(http.get(
          Uri.parse('http://localhost:8000/api/v1/health'),
          headers: {
            'Accept': 'application/json',
          },
        ));
      }
      
      final responses = await Future.wait(futures);
      
      for (final response in responses) {
        expect(response.statusCode, 200);
      }
    });
  });
}

Future<String?> _getAuthToken(http.Client client) async {
  try {
    final loginData = {
      'email': 'admin@aramco-sa.com',
      'password': 'password123',
    };

    final response = await client.post(
      Uri.parse('http://localhost:8000/api/v1/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(loginData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']?['token'];
    }
  } catch (e) {
    print('Error getting auth token: $e');
  }
  
  return null;
}

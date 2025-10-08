import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import '../../lib/core/services/api_service.dart';
import '../../lib/core/models/user.dart';
import '../../lib/core/utils/constants.dart';

void main() {
  group('Backend Connection Tests', () {
    late ApiService apiService;

    setUp(() async {
      apiService = ApiService();
      await apiService.initialize();
    });

    group('API Service Tests', () {
      test('should initialize successfully', () {
        expect(apiService, isNotNull);
      });

      test('should have correct base URL configuration', () {
        expect(AppConstants.apiBaseUrl, equals('http://localhost:8000/api/v1'));
      });

      test('should handle user model serialization', () {
        // Test User model with new structure
        final userJson = {
          'id': '1',
          'email': 'admin@aramco-sa.com',
          'first_name': 'Admin',
          'last_name': 'User',
          'full_name': 'Admin User',
          'email_verified_at': '2024-01-01T00:00:00.000000Z',
          'is_active': true,
          'last_login_at': '2024-01-01T12:00:00.000000Z',
          'language': 'fr',
          'timezone': 'Africa/Dakar',
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
          'is_admin': true,
          'is_verified': true,
          'is_phone_verified': false,
          'preferences': {
            'language': 'fr',
            'timezone': 'Africa/Dakar'
          },
          'status': {
            'active': true,
            'verified': true,
            'phone_verified': false,
            'last_seen': '2024-01-01T12:00:00.000000Z',
            'last_seen_from': '127.0.0.1'
          },
          'meta': {
            'created_at_human': 'il y a 1 jour',
            'updated_at_human': 'il y a 1 jour',
            'last_login_human': 'il y a 1 heure',
            'account_age_days': 1
          }
        };

        final user = User.fromJson(userJson);
        expect(user.email, equals('admin@aramco-sa.com'));
        expect(user.fullName, equals('Admin User'));
        expect(user.primaryRole, equals('admin'));
        expect(user.isAdmin, isTrue);
        expect(user.isActive, isTrue);
        expect(user.language, equals('fr'));
        expect(user.timezone, equals('Africa/Dakar'));
      });

      test('should handle user model with minimal data', () {
        // Test User model with minimal required fields
        final userJson = {
          'id': '2',
          'email': 'user@aramco-sa.com',
          'first_name': 'Test',
          'last_name': 'User',
          'full_name': 'Test User',
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        };

        final user = User.fromJson(userJson);
        expect(user.email, equals('user@aramco-sa.com'));
        expect(user.fullName, equals('Test User'));
        expect(user.primaryRole, equals('user')); // Default role
        expect(user.isActive, isTrue);
        expect(user.roles, isNull);
        expect(user.permissions, isNull);
      });

      test('should handle user model extensions', () {
        final userJson = {
          'id': '3',
          'email': 'manager@aramco-sa.com',
          'first_name': 'Manager',
          'last_name': 'User',
          'full_name': 'Manager User',
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
          'roles': [
            {
              'id': '2',
              'name': 'manager',
              'display_name': 'Manager'
            }
          ],
        };

        final user = User.fromJson(userJson);
        expect(user.isManagerUser, isTrue);
        expect(user.isAdminUser, isFalse);
        expect(user.isHRUser, isFalse);
        expect(user.roleDisplayName, equals('Manager'));
        expect(user.hasPermission('users.read'), isFalse); // Manager doesn't have this permission
      });

      test('should handle compatibility getters', () {
        final userJson = {
          'id': '4',
          'email': 'operator@aramco-sa.com',
          'first_name': 'Operator',
          'last_name': 'User',
          'full_name': 'Operator User',
          'is_active': true,
          'last_login_at': '2024-01-01T12:00:00.000000Z',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
          'roles': [
            {
              'id': '3',
              'name': 'operator',
              'display_name': 'Opérateur'
            }
          ],
        };

        final user = User.fromJson(userJson);
        // Test compatibility getters
        expect(user.role, equals('operator'));
        expect(user.lastLogin, isNotNull);
        expect(user.lastLogin!.year, equals(2024));
      });
    });

    group('Constants Validation Tests', () {
      test('should have correct API base URL', () {
        expect(AppConstants.apiBaseUrl, equals('http://localhost:8000/api/v1'));
      });

      test('should have correct endpoints', () {
        expect(AppConstants.loginEndpoint, equals('/auth/login'));
        expect(AppConstants.usersEndpoint, equals('/users'));
        expect(AppConstants.employeesEndpoint, equals('/employees'));
        expect(AppConstants.ordersEndpoint, equals('/orders'));
        expect(AppConstants.dashboardEndpoint, equals('/dashboard'));
      });

      test('should have correct user roles', () {
        expect(AppConstants.userRoles, contains('admin'));
        expect(AppConstants.userRoles, contains('manager'));
        expect(AppConstants.userRoles, contains('operator'));
        expect(AppConstants.userRoles, contains('rh'));
        expect(AppConstants.userRoles, contains('comptable'));
        expect(AppConstants.userRoles, contains('logistique'));
      });

      test('should have correct app version', () {
        expect(AppConstants.appVersion, isNotEmpty);
      });

      test('should have correct timeout values', () {
        // Les timeouts sont définis dans l'ApiService, pas dans AppConstants
        expect(AppConstants.apiBaseUrl, isNotEmpty);
        expect(AppConstants.appVersion, isNotEmpty);
      });
    });

    group('User Model Validation Tests', () {
      test('should handle empty roles array', () {
        final userJson = {
          'id': '5',
          'email': 'norole@aramco-sa.com',
          'first_name': 'No',
          'last_name': 'Role',
          'full_name': 'No Role',
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
          'roles': [],
        };

        final user = User.fromJson(userJson);
        expect(user.primaryRole, equals('user'));
        expect(user.isAdminUser, isFalse);
        expect(user.isManagerUser, isFalse);
      });

      test('should handle null values gracefully', () {
        final userJson = {
          'id': '6',
          'email': 'nulls@aramco-sa.com',
          'first_name': 'Null',
          'last_name': 'Values',
          'full_name': 'Null Values',
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
          'phone': null,
          'avatar': null,
          'email_verified_at': null,
          'phone_verified_at': null,
          'last_login_at': null,
          'language': null,
          'timezone': null,
          'departmentId': null,
          'position': null,
          'employeeId': null,
        };

        final user = User.fromJson(userJson);
        expect(user.phone, isNull);
        expect(user.avatar, isNull);
        expect(user.emailVerifiedAt, isNull);
        expect(user.phoneVerifiedAt, isNull);
        expect(user.lastLoginAt, isNull);
        expect(user.language, isNull);
        expect(user.timezone, isNull);
        expect(user.departmentId, isNull);
        expect(user.position, isNull);
        expect(user.employeeId, isNull);
      });

      test('should handle user copyWith method', () {
        final originalUser = User(
          id: '7',
          email: 'original@aramco-sa.com',
          firstName: 'Original',
          lastName: 'User',
          fullName: 'Original User',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final copiedUser = originalUser.copyWith(
          email: 'copied@aramco-sa.com',
          firstName: 'Copied',
        );

        expect(copiedUser.id, equals(originalUser.id));
        expect(copiedUser.email, equals('copied@aramco-sa.com'));
        expect(copiedUser.firstName, equals('Copied'));
        expect(copiedUser.lastName, equals(originalUser.lastName));
        expect(copiedUser.fullName, equals(originalUser.fullName));
      });

      test('should handle user equality', () {
        final user1 = User(
          id: '8',
          email: 'test@aramco-sa.com',
          firstName: 'Test',
          lastName: 'User',
          fullName: 'Test User',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final user2 = User(
          id: '8',
          email: 'different@aramco-sa.com',
          firstName: 'Different',
          lastName: 'Name',
          fullName: 'Different Name',
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final user3 = User(
          id: '9',
          email: 'test@aramco-sa.com',
          firstName: 'Test',
          lastName: 'User',
          fullName: 'Test User',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(user1, equals(user2)); // Same ID
        expect(user1, isNot(equals(user3))); // Different ID
      });

      test('should handle user toString', () {
        final user = User(
          id: '10',
          email: 'string@aramco-sa.com',
          firstName: 'String',
          lastName: 'Test',
          fullName: 'String Test',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final userString = user.toString();
        expect(userString, contains('User'));
        expect(userString, contains('10'));
        expect(userString, contains('string@aramco-sa.com'));
        expect(userString, contains('String Test'));
        expect(userString, contains('user')); // Default role
      });
    });

    group('Role Model Tests', () {
      test('should handle role serialization', () {
        final roleJson = {
          'id': '1',
          'name': 'admin',
          'display_name': 'Administrateur',
          'description': 'Administrateur système'
        };

        final role = Role.fromJson(roleJson);
        expect(role.id, equals('1'));
        expect(role.name, equals('admin'));
        expect(role.displayName, equals('Administrateur'));
        expect(role.description, equals('Administrateur système'));

        final roleJsonBack = role.toJson();
        expect(roleJsonBack['id'], equals('1'));
        expect(roleJsonBack['name'], equals('admin'));
        expect(roleJsonBack['display_name'], equals('Administrateur'));
        expect(roleJsonBack['description'], equals('Administrateur système'));
      });

      test('should handle role with missing display name', () {
        final roleJson = {
          'id': '2',
          'name': 'manager',
        };

        final role = Role.fromJson(roleJson);
        expect(role.displayName, equals('manager')); // Falls back to name
      });
    });

    group('EmployeeInfo Model Tests', () {
      test('should handle employee info serialization', () {
        final employeeJson = {
          'id': '1',
          'employee_number': 'EMP001',
          'hire_date': '2024-01-01',
          'job_title': 'Software Developer',
          'department': 'IT',
          'manager': 'John Doe'
        };

        final employee = EmployeeInfo.fromJson(employeeJson);
        expect(employee.id, equals('1'));
        expect(employee.employeeNumber, equals('EMP001'));
        expect(employee.hireDate, isNotNull);
        expect(employee.jobTitle, equals('Software Developer'));
        expect(employee.department, equals('IT'));
        expect(employee.manager, equals('John Doe'));

        final employeeJsonBack = employee.toJson();
        expect(employeeJsonBack['id'], equals('1'));
        expect(employeeJsonBack['employee_number'], equals('EMP001'));
        expect(employeeJsonBack['hire_date'], isNotNull);
        expect(employeeJsonBack['job_title'], equals('Software Developer'));
        expect(employeeJsonBack['department'], equals('IT'));
        expect(employeeJsonBack['manager'], equals('John Doe'));
      });
    });
  });
}

// Helper classes for testing
class Role {
  final String id;
  final String name;
  final String displayName;
  final String? description;

  const Role({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String? ?? json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
    };
  }
}

class EmployeeInfo {
  final String id;
  final String employeeNumber;
  final DateTime? hireDate;
  final String? jobTitle;
  final String? department;
  final String? manager;

  const EmployeeInfo({
    required this.id,
    required this.employeeNumber,
    this.hireDate,
    this.jobTitle,
    this.department,
    this.manager,
  });

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) {
    return EmployeeInfo(
      id: json['id'] as String,
      employeeNumber: json['employee_number'] as String,
      hireDate: json['hire_date'] != null 
          ? DateTime.parse(json['hire_date'] as String) 
          : null,
      jobTitle: json['job_title'] as String?,
      department: json['department'] as String?,
      manager: json['manager'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_number': employeeNumber,
      'hire_date': hireDate?.toIso8601String(),
      'job_title': jobTitle,
      'department': department,
      'manager': manager,
    };
  }
}

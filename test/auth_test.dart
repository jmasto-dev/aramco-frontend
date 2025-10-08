import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../lib/core/models/user.dart' as user_model;
import '../lib/core/services/api_service.dart';
import '../lib/core/services/storage_service.dart';
import '../lib/presentation/providers/auth_provider.dart';
import '../lib/core/providers/service_providers.dart';
import '../lib/core/utils/constants.dart';

// Generate mocks
@GenerateMocks([ApiService, StorageService])
import 'auth_test.mocks.dart';

void main() {
  group('Tests d\'authentification', () {
    late MockApiService mockApiService;
    late MockStorageService mockStorageService;
    late ProviderContainer container;

    setUp(() {
      mockApiService = MockApiService();
      mockStorageService = MockStorageService();
      
      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Création d\'un utilisateur à partir de JSON', () {
      final json = {
        'id': '1',
        'email': 'test@aramco-sa.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'role': 'admin',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final user = user_model.User.fromJson(json);

      expect(user.id, '1');
      expect(user.email, 'test@aramco-sa.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.role, 'admin');
      expect(user.fullName, 'John Doe');
      expect(user.initials, 'JD');
      expect(user.isAdmin, true);
    });

    test('Vérification des permissions utilisateur', () {
      final adminUser = user_model.User(
        id: '1',
        email: 'admin@aramco-sa.com',
        firstName: 'Admin',
        lastName: 'User',
        fullName: 'Admin User',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        roles: [user_model.Role(id: '1', name: 'admin', displayName: 'Administrateur')],
      );

      final operatorUser = user_model.User(
        id: '2',
        email: 'operator@aramco-sa.com',
        firstName: 'Operator',
        lastName: 'User',
        fullName: 'Operator User',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        roles: [user_model.Role(id: '2', name: 'operator', displayName: 'Opérateur')],
      );

      expect(adminUser.hasPermission('users.delete'), true);
      expect(adminUser.hasPermission('orders.create'), true);
      
      expect(operatorUser.hasPermission('users.delete'), false);
      expect(operatorUser.hasPermission('orders.create'), true);
    });

    test('État initial de l\'authentification', () {
      final authState = container.read(authProvider);
      
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });

    test('Nom d\'affichage des rôles', () {
      final roles = {
        'admin': 'Administrateur',
        'manager': 'Manager',
        'operator': 'Opérateur',
        'rh': 'Ressources Humaines',
        'comptable': 'Comptable',
        'logistique': 'Logistique',
      };

      roles.forEach((role, expectedDisplayName) {
        final user = user_model.User(
          id: '1',
          email: 'test@aramco-sa.com',
          firstName: 'Test',
          lastName: 'User',
          fullName: 'Test User',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          roles: [user_model.Role(id: '1', name: role, displayName: expectedDisplayName)],
        );

        expect(user.roleDisplayName, expectedDisplayName);
      });
    });

    test('Copie d\'utilisateur avec modifications', () {
      final originalUser = user_model.User(
        id: '1',
        email: 'test@aramco-sa.com',
        firstName: 'John',
        lastName: 'Doe',
        fullName: 'John Doe',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        roles: [user_model.Role(id: '1', name: 'operator', displayName: 'Opérateur')],
      );

      final updatedUser = originalUser.copyWith(
        roles: [user_model.Role(id: '2', name: 'manager', displayName: 'Manager')],
        lastName: 'Smith',
        fullName: 'John Smith',
      );

      expect(updatedUser.id, originalUser.id);
      expect(updatedUser.email, originalUser.email);
      expect(updatedUser.firstName, originalUser.firstName);
      expect(updatedUser.lastName, 'Smith');
      expect(updatedUser.primaryRole, 'manager');
    });

    test('Conversion JSON vers utilisateur et retour', () {
      final originalUser = user_model.User(
        id: '1',
        email: 'test@aramco-sa.com',
        firstName: 'John',
        lastName: 'Doe',
        fullName: 'John Doe',
        isActive: true,
        lastLoginAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        avatar: 'https://example.com/avatar.jpg',
        roles: [user_model.Role(id: '1', name: 'admin', displayName: 'Administrateur')],
      );

      final json = originalUser.toJson();
      final restoredUser = user_model.User.fromJson(json);

      expect(restoredUser.id, originalUser.id);
      expect(restoredUser.email, originalUser.email);
      expect(restoredUser.firstName, originalUser.firstName);
      expect(restoredUser.lastName, originalUser.lastName);
      expect(restoredUser.primaryRole, originalUser.primaryRole);
      expect(restoredUser.avatar, originalUser.avatar);
      expect(restoredUser.isActive, originalUser.isActive);
    });
  });

  group('Tests de validation', () {
    test('Validation des formats d\'email', () {
      final validEmails = [
        'test@aramco-sa.com',
        'user.name@domain.com',
        'user+tag@example.org',
      ];

      final invalidEmails = [
        'invalid-email',
        '@domain.com',
        'user@',
        'user.domain.com',
        '',
      ];

      for (final email in validEmails) {
        expect(RegExp(AppConstants.emailPattern).hasMatch(email), true,
            reason: '$email devrait être valide');
      }

      for (final email in invalidEmails) {
        expect(RegExp(AppConstants.emailPattern).hasMatch(email), false,
            reason: '$email devrait être invalide');
      }
    });
  });
}

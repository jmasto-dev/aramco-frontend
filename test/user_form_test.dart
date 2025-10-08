import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aramco_frontend/core/utils/validators.dart';
import 'package:aramco_frontend/core/models/user.dart';
import 'package:aramco_frontend/presentation/providers/user_provider.dart';

void main() {
  group('User Validation Tests', () {
    test('Valid name should pass validation', () {
      final result = AppValidators.validateName('John Doe');
      expect(result, isNull);
    });

    test('Empty name should fail validation', () {
      final result = AppValidators.validateName('');
      expect(result, equals('Le nom est requis'));
    });

    test('Short name should fail validation', () {
      final result = AppValidators.validateName('A');
      expect(result, equals('Le nom doit contenir au moins 2 caractères'));
    });

    test('Long name should fail validation', () {
      final result = AppValidators.validateName('A' * 51);
      expect(result, equals('Le nom ne doit pas dépasser 50 caractères'));
    });

    test('Valid email should pass validation', () {
      final result = AppValidators.validateEmail('test@example.com');
      expect(result, isNull);
    });

    test('Invalid email should fail validation', () {
      final result = AppValidators.validateEmail('invalid-email');
      expect(result, equals('Veuillez entrer un email valide'));
    });

    test('Empty email should fail validation', () {
      final result = AppValidators.validateEmail('');
      expect(result, equals('L\'email est requis'));
    });

    test('Valid password should pass validation', () {
      final result = AppValidators.validatePassword('Password123!');
      expect(result, isNull);
    });

    test('Short password should fail validation', () {
      final result = AppValidators.validatePassword('Pass1!');
      expect(result, contains('au moins 8 caractères'));
    });

    test('Password without uppercase should fail validation', () {
      final result = AppValidators.validatePassword('password123!');
      expect(result, contains('au moins une majuscule'));
    });

    test('Password without lowercase should fail validation', () {
      final result = AppValidators.validatePassword('PASSWORD123!');
      expect(result, contains('au moins une minuscule'));
    });

    test('Password without number should fail validation', () {
      final result = AppValidators.validatePassword('Password!');
      expect(result, contains('au moins un chiffre'));
    });

    test('Valid phone should pass validation', () {
      final result = AppValidators.validatePhone('+33612345678');
      expect(result, isNull);
    });

    test('Invalid phone should fail validation', () {
      final result = AppValidators.validatePhone('123');
      expect(result, equals('Veuillez entrer un numéro de téléphone valide'));
    });

    test('Password confirmation should match', () {
      final result = AppValidators.validatePasswordConfirmation('Password123!', 'Password123!');
      expect(result, isNull);
    });

    test('Password confirmation should not match', () {
      final result = AppValidators.validatePasswordConfirmation('Password123!', 'Different123!');
      expect(result, equals('Les mots de passe ne correspondent pas'));
    });
  });

  group('User Model Tests', () {
    test('User should be created with valid data', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'employee',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.id, equals('1'));
      expect(user.email, equals('test@example.com'));
      expect(user.firstName, equals('John'));
      expect(user.lastName, equals('Doe'));
      expect(user.role, equals('employee'));
      expect(user.isActive, isTrue);
    });

    test('User should be created from JSON', () {
      final json = {
        'id': '1',
        'email': 'test@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'role': 'employee',
        'is_active': true,
        'created_at': '2023-01-01T00:00:00Z',
        'updated_at': '2023-01-01T00:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('1'));
      expect(user.email, equals('test@example.com'));
      expect(user.firstName, equals('John'));
      expect(user.lastName, equals('Doe'));
      expect(user.role, equals('employee'));
      expect(user.isActive, isTrue);
    });

    test('User should be converted to JSON', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'employee',
        isActive: true,
        createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
      );

      final json = user.toJson();

      expect(json['id'], equals('1'));
      expect(json['email'], equals('test@example.com'));
      expect(json['first_name'], equals('John'));
      expect(json['last_name'], equals('Doe'));
      expect(json['role'], equals('employee'));
      expect(json['is_active'], isTrue);
    });

    test('User copyWith should create new user with updated fields', () {
      final originalUser = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'employee',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedUser = originalUser.copyWith(
        firstName: 'Jane',
        role: 'manager',
      );

      expect(updatedUser.id, equals(originalUser.id));
      expect(updatedUser.email, equals(originalUser.email));
      expect(updatedUser.firstName, equals('Jane'));
      expect(updatedUser.lastName, equals(originalUser.lastName));
      expect(updatedUser.role, equals('manager'));
      expect(updatedUser.isActive, equals(originalUser.isActive));
    });
  });

  group('Password Strength Tests', () {
    test('Empty password should have strength 0', () {
      final strength = AppValidators.calculatePasswordStrength('');
      expect(strength, equals(0));
    });

    test('Short password should have strength 0', () {
      final strength = AppValidators.calculatePasswordStrength('Pass1');
      expect(strength, equals(0));
    });

    test('Password with only lowercase should have low strength', () {
      final strength = AppValidators.calculatePasswordStrength('password');
      expect(strength, equals(1));
    });

    test('Password with lowercase and numbers should have medium strength', () {
      final strength = AppValidators.calculatePasswordStrength('password123');
      expect(strength, equals(2));
    });

    test('Password with lowercase, uppercase, and numbers should have good strength', () {
      final strength = AppValidators.calculatePasswordStrength('Password123');
      expect(strength, equals(4));
    });

    test('Complex password should have maximum strength', () {
      final strength = AppValidators.calculatePasswordStrength('Password123!');
      expect(strength, equals(5));
    });

    test('Very long complex password should have maximum strength', () {
      final strength = AppValidators.calculatePasswordStrength('VeryLongPassword123!');
      expect(strength, equals(6));
    });

    test('Password strength message should be correct', () {
      expect(AppValidators.getPasswordStrengthMessage(0), equals('Très faible'));
      expect(AppValidators.getPasswordStrengthMessage(1), equals('Très faible'));
      expect(AppValidators.getPasswordStrengthMessage(2), equals('Faible'));
      expect(AppValidators.getPasswordStrengthMessage(3), equals('Moyen'));
      expect(AppValidators.getPasswordStrengthMessage(4), equals('Fort'));
      expect(AppValidators.getPasswordStrengthMessage(5), equals('Très fort'));
      expect(AppValidators.getPasswordStrengthMessage(6), equals('Très fort'));
    });
  });

  group('Role Validation Tests', () {
    test('Valid role should pass validation', () {
      final result = AppValidators.validateRole('admin');
      expect(result, isNull);
    });

    test('Invalid role should fail validation', () {
      final result = AppValidators.validateRole('invalid_role');
      expect(result, equals('Veuillez sélectionner un rôle valide'));
    });

    test('Empty role should fail validation', () {
      final result = AppValidators.validateRole('');
      expect(result, equals('Le rôle est requis'));
    });
  });

  group('Multiple Validation Tests', () {
    test('Multiple validators should return first error', () {
      final validators = [
        (String? value) => value?.isEmpty == true ? 'Required' : null,
        (String? value) => value!.length < 5 ? 'Too short' : null,
        (String? value) => value!.length > 10 ? 'Too long' : null,
      ];

      final result = AppValidators.validateMultiple('abc', validators);
      expect(result, equals('Too short'));
    });

    test('Multiple validators should pass if all valid', () {
      final validators = [
        (String? value) => value?.isEmpty == true ? 'Required' : null,
        (String? value) => value!.length < 5 ? 'Too short' : null,
        (String? value) => value!.length > 10 ? 'Too long' : null,
      ];

      final result = AppValidators.validateMultiple('valid', validators);
      expect(result, isNull);
    });
  });

  group('Custom Validation Tests', () {
    test('Custom validator should pass if condition is met', () {
      final result = AppValidators.validateCustom(
        'test@example.com',
        (value) => value.contains('@'),
        'Email must contain @',
      );
      expect(result, isNull);
    });

    test('Custom validator should fail if condition is not met', () {
      final result = AppValidators.validateCustom(
        'testexample.com',
        (value) => value.contains('@'),
        'Email must contain @',
      );
      expect(result, equals('Email must contain @'));
    });

    test('Custom validator should fail for empty value', () {
      final result = AppValidators.validateCustom(
        '',
        (value) => value.contains('@'),
        'Email must contain @',
      );
      expect(result, equals('Ce champ est requis'));
    });
  });

  group('Status Validation Tests', () {
    test('Valid status should pass validation', () {
      final validStatuses = ['active', 'inactive', 'pending'];
      final result = AppValidators.validateStatus('active', validStatuses);
      expect(result, isNull);
    });

    test('Invalid status should fail validation', () {
      final validStatuses = ['active', 'inactive', 'pending'];
      final result = AppValidators.validateStatus('invalid', validStatuses);
      expect(result, equals('Veuillez sélectionner un statut valide'));
    });

    test('Empty status should fail validation', () {
      final validStatuses = ['active', 'inactive', 'pending'];
      final result = AppValidators.validateStatus('', validStatuses);
      expect(result, equals('Le statut est requis'));
    });
  });
}

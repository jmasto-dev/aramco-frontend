import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aramco_frontend/core/models/employee.dart';
import 'package:aramco_frontend/core/models/user.dart';
import 'package:aramco_frontend/core/services/employee_service.dart';
import 'package:aramco_frontend/presentation/providers/employee_provider.dart';

import 'employee_test.mocks.dart';

@GenerateMocks([EmployeeService])
void main() {
  final testUser = User(
    id: 'user1',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@aramco.com',
    role: 'employee',
    createdAt: DateTime(2020, 1, 1),
    updatedAt: DateTime(2020, 1, 1),
  );

  group('Employee Model Tests', () {
    test('Employee should serialize to JSON correctly', () {
      final employee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      final json = employee.toJson();

      expect(json['id'], '1');
      expect(json['userId'], 'user1');
      expect(json['position'], 'Developer');
      expect(json['department'], 'IT');
      expect(json['salary'], 50000.0);
      expect(json['isActive'], true);
    });

    test('Employee should deserialize from JSON correctly', () {
      final json = {
        'id': '1',
        'userId': 'user1',
        'position': 'Developer',
        'department': 'IT',
        'salary': 50000.0,
        'hireDate': '2020-01-01T00:00:00.000Z',
        'isActive': true,
        'createdAt': '2020-01-01T00:00:00.000Z',
        'updatedAt': '2020-01-01T00:00:00.000Z',
        'user': {
          'id': 'user1',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john.doe@aramco.com',
          'role': 'employee',
          'createdAt': '2020-01-01T00:00:00.000Z',
          'updatedAt': '2020-01-01T00:00:00.000Z',
        },
      };

      final employee = Employee.fromJson(json);

      expect(employee.id, '1');
      expect(employee.userId, 'user1');
      expect(employee.position, 'Developer');
      expect(employee.department, 'IT');
      expect(employee.salary, 50000.0);
      expect(employee.isActive, true);
    });

    test('Employee fullName should work correctly', () {
      final employee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      expect(employee.fullName, 'John Doe');
    });

    test('Employee email should work correctly', () {
      final employee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      expect(employee.email, 'john.doe@aramco.com');
    });

    test('Employee yearsOfService should calculate correctly', () {
      final hireDate = DateTime.now().subtract(Duration(days: 365 * 2));
      final employee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: hireDate,
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      expect(employee.yearsOfService, greaterThanOrEqualTo(1));
      expect(employee.yearsOfService, lessThanOrEqualTo(3));
    });

    test('Employee statusText should work correctly', () {
      final activeEmployee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      final inactiveEmployee = Employee(
        id: '2',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: false,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      expect(activeEmployee.statusText, 'Actif');
      expect(inactiveEmployee.statusText, 'Inactif');
    });

    test('Employee formattedDepartment should work correctly', () {
      final itEmployee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      final hrEmployee = Employee(
        id: '2',
        userId: 'user1',
        position: 'Manager',
        department: 'HR',
        hireDate: DateTime(2020, 1, 1),
        salary: 60000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      expect(itEmployee.formattedDepartment, 'Informatique');
      expect(hrEmployee.formattedDepartment, 'Ressources Humaines');
    });

    test('Employee copyWith should work correctly', () {
      final originalEmployee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      final updatedEmployee = originalEmployee.copyWith(
        position: 'Senior Developer',
        salary: 55000.0,
      );

      expect(updatedEmployee.id, originalEmployee.id);
      expect(updatedEmployee.position, 'Senior Developer');
      expect(updatedEmployee.salary, 55000.0);
      expect(updatedEmployee.department, originalEmployee.department);
    });

    test('Employee equality should work correctly', () {
      final employee1 = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      final employee2 = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      final employee3 = Employee(
        id: '2',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      expect(employee1, equals(employee2));
      expect(employee1, isNot(equals(employee3)));
    });

    test('Employee initials should work correctly', () {
      final employee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      expect(employee.initials, 'JD');
    });

    test('Employee without user should return N/A for user fields', () {
      final employee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
      );

      expect(employee.fullName, 'N/A');
      expect(employee.email, 'N/A');
      expect(employee.initials, 'N/A');
    });
  });

  group('Department Enum Tests', () {
    test('Department fromString should work correctly', () {
      expect(Department.fromString('IT'), Department.it);
      expect(Department.fromString('it'), Department.it);
      expect(Department.fromString('informatique'), Department.it);
      expect(Department.fromString('HR'), Department.hr);
      expect(Department.fromString('rh'), Department.hr);
      expect(Department.fromString('ressources humaines'), Department.hr);
      expect(Department.fromString('unknown'), Department.all);
    });

    test('Department displayName should work correctly', () {
      expect(Department.it.displayName, 'Informatique');
      expect(Department.hr.displayName, 'Ressources Humaines');
      expect(Department.sales.displayName, 'Ventes');
      expect(Department.all.displayName, 'Tous');
    });
  });

  group('Position Enum Tests', () {
    test('Position fromString should work correctly', () {
      expect(Position.fromString('Developer'), Position.developer);
      expect(Position.fromString('développeur'), Position.developer);
      expect(Position.fromString('Manager'), Position.itManager);
      expect(Position.fromString('PDG'), Position.ceo);
      expect(Position.fromString('unknown'), Position.all);
    });

    test('Position displayName should work correctly', () {
      expect(Position.developer.displayName, 'Développeur');
      expect(Position.ceo.displayName, 'PDG');
      expect(Position.cto.displayName, 'Directeur Technique');
      expect(Position.all.displayName, 'Tous');
    });
  });

  group('EmployeeFilters Tests', () {
    test('EmployeeFilters should initialize correctly', () {
      const filters = EmployeeFilters();

      expect(filters.searchQuery, '');
      expect(filters.department, Department.all);
      expect(filters.position, Position.all);
      expect(filters.isActive, null);
      expect(filters.hasFilters, false);
    });

    test('EmployeeFilters hasFilters should work correctly', () {
      const filters1 = EmployeeFilters(searchQuery: 'John');
      const filters2 = EmployeeFilters(department: Department.it);
      const filters3 = EmployeeFilters(isActive: true);
      const filters4 = EmployeeFilters();

      expect(filters1.hasFilters, true);
      expect(filters2.hasFilters, true);
      expect(filters3.hasFilters, true);
      expect(filters4.hasFilters, false);
    });

    test('EmployeeFilters copyWith should work correctly', () {
      const originalFilters = EmployeeFilters(
        searchQuery: 'John',
        department: Department.it,
      );

      final updatedFilters = originalFilters.copyWith(
        searchQuery: 'Jane',
        position: Position.developer,
      );

      expect(updatedFilters.searchQuery, 'Jane');
      expect(updatedFilters.department, Department.it);
      expect(updatedFilters.position, Position.developer);
    });

    test('EmployeeFilters toApiParams should work correctly', () {
      const filters = EmployeeFilters(
        searchQuery: 'John',
        department: Department.it,
        position: Position.developer,
        isActive: true,
        salaryMin: 30000.0,
        salaryMax: 80000.0,
      );

      final params = filters.toApiParams();

      expect(params['search'], 'John');
      expect(params['department'], 'it');
      expect(params['position'], 'developer');
      expect(params['is_active'], true);
      expect(params['salary_min'], 30000.0);
      expect(params['salary_max'], 80000.0);
      expect(params.containsKey('manager_id'), false);
    });

    test('EmployeeFilters equality should work correctly', () {
      const filters1 = EmployeeFilters(searchQuery: 'John');
      const filters2 = EmployeeFilters(searchQuery: 'John');
      const filters3 = EmployeeFilters(searchQuery: 'Jane');

      expect(filters1, equals(filters2));
      expect(filters1, isNot(equals(filters3)));
    });
  });

  group('Employee Performance Tests', () {
    test('should handle large employee lists efficiently', () {
      final largeEmployeeList = List.generate(1000, (index) => Employee(
        id: index.toString(),
        userId: 'user$index',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
      ));

      final stopwatch = Stopwatch()..start();

      // Simulate processing large list
      final filtered = largeEmployeeList.where((e) => e.department == 'IT').toList();

      stopwatch.stop();

      expect(filtered.length, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('should handle concurrent operations safely', () async {
      final employee = Employee(
        id: '1',
        userId: 'user1',
        position: 'Developer',
        department: 'IT',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0,
        isActive: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
        user: testUser,
      );

      // Simulate concurrent access
      final futures = List.generate(10, (index) => 
        Future.delayed(Duration(milliseconds: index * 10), () {
          return employee.fullName;
        })
      );

      final results = await Future.wait(futures);

      expect(results.length, 10);
      expect(results.every((result) => result == 'John Doe'), true);
    });
  });
}

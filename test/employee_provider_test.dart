import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aramco_frontend/core/models/employee.dart';
import 'package:aramco_frontend/core/models/api_response.dart';
import 'package:aramco_frontend/core/services/api_service.dart';
import 'package:aramco_frontend/presentation/providers/employee_provider.dart';

import 'employee_provider_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('EmployeeProvider Tests', () {
    late MockApiService mockApiService;
    late ProviderContainer container;

    setUp(() {
      mockApiService = MockApiService();
      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty state', () {
      final provider = container.read(employeeProvider);
      
      expect(provider.employees, isEmpty);
      expect(provider.filteredEmployees, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.currentPage, 1);
      expect(provider.totalPages, 1);
      expect(provider.hasMore, true);
    });

    test('should load employees successfully', () async {
      final testEmployees = [
        {
          'id': '1',
          'user_id': 'user1',
          'position': 'Developer',
          'department': 'IT',
          'hire_date': '2020-01-01T00:00:00.000Z',
          'salary': 50000.0,
          'is_active': true,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
        },
        {
          'id': '2',
          'user_id': 'user2',
          'position': 'Manager',
          'department': 'HR',
          'hire_date': '2019-01-01T00:00:00.000Z',
          'salary': 60000.0,
          'is_active': true,
          'created_at': '2019-01-01T00:00:00.000Z',
          'updated_at': '2019-01-01T00:00:00.000Z',
        },
      ];

      final mockResponse = ApiResponse(
        isSuccess: true,
        data: {
          'data': testEmployees,
          'message': 'Employees loaded successfully',
        },
        message: 'Success',
      );

      when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final notifier = container.read(employeeProvider.notifier);
      await notifier.loadEmployees();

      final provider = container.read(employeeProvider);
      expect(provider.employees.length, 2);
      expect(provider.filteredEmployees.length, 2);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('should handle loading error', () async {
      final mockResponse = ApiResponse(
        isSuccess: false,
        data: {'error': 'Failed to load employees'},
        message: 'Failed to load employees',
      );

      when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final notifier = container.read(employeeProvider.notifier);
      await notifier.loadEmployees();

      final provider = container.read(employeeProvider);
      expect(provider.employees, isEmpty);
      expect(provider.filteredEmployees, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, 'Failed to load employees');
    });

    test('should create employee successfully', () async {
      final newEmployeeData = {
        'user_id': 'user1',
        'position': 'Developer',
        'department': 'IT',
        'hire_date': '2020-01-01T00:00:00.000Z',
        'salary': 50000.0,
        'is_active': true,
      };

      final createdEmployee = {
        'id': '1',
        'user_id': 'user1',
        'position': 'Developer',
        'department': 'IT',
        'hire_date': '2020-01-01T00:00:00.000Z',
        'salary': 50000.0,
        'is_active': true,
        'created_at': '2020-01-01T00:00:00.000Z',
        'updated_at': '2020-01-01T00:00:00.000Z',
      };

      final mockResponse = ApiResponse(
        isSuccess: true,
        data: {
          'data': createdEmployee,
          'message': 'Employee created successfully',
        },
        message: 'Success',
      );

      when(mockApiService.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final notifier = container.read(employeeProvider.notifier);
      final result = await notifier.createEmployee(newEmployeeData);

      expect(result, true);
      final provider = container.read(employeeProvider);
      expect(provider.employees.length, 1);
      expect(provider.employees.first.id, '1');
    });

    test('should handle create employee error', () async {
      final newEmployeeData = {
        'user_id': 'user1',
        'position': 'Developer',
        'department': 'IT',
        'hire_date': '2020-01-01T00:00:00.000Z',
        'salary': 50000.0,
        'is_active': true,
      };

      final mockResponse = ApiResponse(
        isSuccess: false,
        data: {'error': 'Failed to create employee'},
        message: 'Failed to create employee',
      );

      when(mockApiService.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final notifier = container.read(employeeProvider.notifier);
      final result = await notifier.createEmployee(newEmployeeData);

      expect(result, false);
      final provider = container.read(employeeProvider);
      expect(provider.employees, isEmpty);
      expect(provider.error, 'Failed to create employee');
    });

    test('should update employee successfully', () async {
      final existingEmployee = Employee(
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

      final updatedEmployeeData = {
        'position': 'Senior Developer',
        'salary': 55000.0,
      };

      final updatedEmployeeResponse = {
        'id': '1',
        'user_id': 'user1',
        'position': 'Senior Developer',
        'department': 'IT',
        'hire_date': '2020-01-01T00:00:00.000Z',
        'salary': 55000.0,
        'is_active': true,
        'created_at': '2020-01-01T00:00:00.000Z',
        'updated_at': '2020-01-02T00:00:00.000Z',
      };

      final mockResponse = ApiResponse(
        isSuccess: true,
        data: {
          'data': updatedEmployeeResponse,
          'message': 'Employee updated successfully',
        },
        message: 'Success',
      );

      when(mockApiService.put(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      // Add existing employee to state
      final notifier = container.read(employeeProvider.notifier);
      notifier.state = notifier.state.copyWith(
        employees: [existingEmployee],
      );

      final result = await notifier.updateEmployee('1', updatedEmployeeData);

      expect(result, true);
      final provider = container.read(employeeProvider);
      expect(provider.employees.length, 1);
      expect(provider.employees.first.position, 'Senior Developer');
      expect(provider.employees.first.salary, 55000.0);
    });

    test('should delete employee successfully', () async {
      final existingEmployee = Employee(
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

      final mockResponse = ApiResponse(
        isSuccess: true,
        data: {'message': 'Employee deleted successfully'},
        message: 'Success',
      );

      when(mockApiService.delete(any))
          .thenAnswer((_) async => mockResponse);

      // Add existing employee to state
      final notifier = container.read(employeeProvider.notifier);
      notifier.state = notifier.state.copyWith(
        employees: [existingEmployee],
      );

      final result = await notifier.deleteEmployee('1');

      expect(result, true);
      final provider = container.read(employeeProvider);
      expect(provider.employees, isEmpty);
    });

    test('should handle delete employee error', () async {
      final existingEmployee = Employee(
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

      final mockResponse = ApiResponse(
        isSuccess: false,
        data: {'error': 'Failed to delete employee'},
        message: 'Failed to delete employee',
      );

      when(mockApiService.delete(any))
          .thenAnswer((_) async => mockResponse);

      // Add existing employee to state
      final notifier = container.read(employeeProvider.notifier);
      notifier.state = notifier.state.copyWith(
        employees: [existingEmployee],
      );

      final result = await notifier.deleteEmployee('1');

      expect(result, false);
      final provider = container.read(employeeProvider);
      expect(provider.employees.length, 1);
      expect(provider.error, 'Failed to delete employee');
    });

    test('should filter employees correctly', () {
      final employees = [
        Employee(
          id: '1',
          userId: 'user1',
          position: 'Developer',
          department: 'IT',
          hireDate: DateTime(2020, 1, 1),
          salary: 50000.0,
          isActive: true,
          createdAt: DateTime(2020, 1, 1),
          updatedAt: DateTime(2020, 1, 1),
        ),
        Employee(
          id: '2',
          userId: 'user2',
          position: 'Manager',
          department: 'HR',
          hireDate: DateTime(2019, 1, 1),
          salary: 60000.0,
          isActive: true,
          createdAt: DateTime(2019, 1, 1),
          updatedAt: DateTime(2019, 1, 1),
        ),
        Employee(
          id: '3',
          userId: 'user3',
          position: 'Developer',
          department: 'IT',
          hireDate: DateTime(2021, 1, 1),
          salary: 55000.0,
          isActive: false,
          createdAt: DateTime(2021, 1, 1),
          updatedAt: DateTime(2021, 1, 1),
        ),
      ];

      final notifier = container.read(employeeProvider.notifier);
      notifier.state = notifier.state.copyWith(
        employees: employees,
      );

      // Test department filter
      final itFilters = EmployeeFilters(department: Department.it);
      notifier.applyFilters(itFilters);
      var provider = container.read(employeeProvider);
      expect(provider.filteredEmployees.length, 2);
      expect(provider.filteredEmployees.every((e) => e.department == 'IT'), true);

      // Test position filter
      final devFilters = EmployeeFilters(position: Position.developer);
      notifier.applyFilters(devFilters);
      provider = container.read(employeeProvider);
      expect(provider.filteredEmployees.length, 2);
      expect(provider.filteredEmployees.every((e) => e.position == 'Developer'), true);

      // Test active filter
      final activeFilters = EmployeeFilters(isActive: true);
      notifier.applyFilters(activeFilters);
      provider = container.read(employeeProvider);
      expect(provider.filteredEmployees.length, 1);
      expect(provider.filteredEmployees.first.isActive, true);

      // Test search filter
      final searchFilters = EmployeeFilters(searchQuery: 'Manager');
      notifier.applyFilters(searchFilters);
      provider = container.read(employeeProvider);
      expect(provider.filteredEmployees.length, 1);
      expect(provider.filteredEmployees.first.position, 'Manager');

      // Clear filters
      notifier.clearFilters();
      provider = container.read(employeeProvider);
      expect(provider.filteredEmployees.length, 3);
    });

    test('should handle pagination correctly', () async {
      final page1Employees = List.generate(10, (index) => {
        'id': index.toString(),
        'user_id': 'user$index',
        'position': 'Developer',
        'department': 'IT',
        'hire_date': '2020-01-01T00:00:00.000Z',
        'salary': 50000.0,
        'is_active': true,
        'created_at': '2020-01-01T00:00:00.000Z',
        'updated_at': '2020-01-01T00:00:00.000Z',
      });

      final mockResponse1 = ApiResponse(
        isSuccess: true,
        data: {
          'data': page1Employees,
          'pagination': {
            'current_page': 1,
            'last_page': 2,
            'total': 15,
          },
          'message': 'Employees loaded successfully',
        },
        message: 'Success',
      );

      when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse1);

      final notifier = container.read(employeeProvider.notifier);
      await notifier.loadEmployees();

      var provider = container.read(employeeProvider);
      expect(provider.employees.length, 10);
      expect(provider.currentPage, 2);
      expect(provider.totalPages, 2);
      expect(provider.hasMore, true);
    });

    test('should refresh employees correctly', () async {
      final initialEmployees = [
        {
          'id': '1',
          'user_id': 'user1',
          'position': 'Developer',
          'department': 'IT',
          'hire_date': '2020-01-01T00:00:00.000Z',
          'salary': 50000.0,
          'is_active': true,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
        },
      ];

      final refreshedEmployees = [
        {
          'id': '1',
          'user_id': 'user1',
          'position': 'Senior Developer',
          'department': 'IT',
          'hire_date': '2020-01-01T00:00:00.000Z',
          'salary': 55000.0,
          'is_active': true,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-02T00:00:00.000Z',
        },
        {
          'id': '2',
          'user_id': 'user2',
          'position': 'Manager',
          'department': 'HR',
          'hire_date': '2019-01-01T00:00:00.000Z',
          'salary': 60000.0,
          'is_active': true,
          'created_at': '2019-01-01T00:00:00.000Z',
          'updated_at': '2019-01-01T00:00:00.000Z',
        },
      ];

      final mockResponse = ApiResponse(
        isSuccess: true,
        data: {
          'data': refreshedEmployees,
          'message': 'Employees refreshed successfully',
        },
        message: 'Success',
      );

      when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      // Set initial state
      final notifier = container.read(employeeProvider.notifier);
      notifier.state = notifier.state.copyWith(
        employees: [Employee.fromJson(initialEmployees.first)],
      );

      await notifier.refreshEmployees();

      final provider = container.read(employeeProvider);
      expect(provider.employees.length, 2);
      expect(provider.employees.first.position, 'Senior Developer');
      expect(provider.employees.first.salary, 55000.0);
      expect(provider.isLoading, false);
    });

    test('should handle concurrent operations safely', () async {
      final testEmployeeData = {
        'user_id': 'user1',
        'position': 'Developer',
        'department': 'IT',
        'hire_date': '2020-01-01T00:00:00.000Z',
        'salary': 50000.0,
        'is_active': true,
      };

      final createdEmployee = {
        'id': '1',
        'user_id': 'user1',
        'position': 'Developer',
        'department': 'IT',
        'hire_date': '2020-01-01T00:00:00.000Z',
        'salary': 50000.0,
        'is_active': true,
        'created_at': '2020-01-01T00:00:00.000Z',
        'updated_at': '2020-01-01T00:00:00.000Z',
      };

      final mockResponse = ApiResponse(
        isSuccess: true,
        data: {
          'data': createdEmployee,
          'message': 'Employee created successfully',
        },
        message: 'Success',
      );

      when(mockApiService.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final notifier = container.read(employeeProvider.notifier);

      // Simulate concurrent create operations
      final futures = List.generate(5, (index) => 
        notifier.createEmployee({
          ...testEmployeeData,
          'user_id': 'user$index',
        })
      );

      final results = await Future.wait(futures);

      expect(results.every((result) => result), true);
      final provider = container.read(employeeProvider);
      expect(provider.employees.length, 5);
    });

    test('should handle export functionality correctly', () async {
      final mockResponse = ApiResponse(
        isSuccess: true,
        data: {
          'download_url': 'export_data_url',
          'message': 'Employees exported successfully',
        },
        message: 'Success',
      );

      when(mockApiService.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final notifier = container.read(employeeProvider.notifier);
      final result = await notifier.exportEmployees(format: 'csv');

      expect(result, 'export_data_url');
    });

    test('should calculate statistics correctly', () {
      final employees = [
        Employee(
          id: '1',
          userId: 'user1',
          position: 'Developer',
          department: 'IT',
          hireDate: DateTime(2020, 1, 1),
          salary: 50000.0,
          isActive: true,
          createdAt: DateTime(2020, 1, 1),
          updatedAt: DateTime(2020, 1, 1),
        ),
        Employee(
          id: '2',
          userId: 'user2',
          position: 'Manager',
          department: 'HR',
          hireDate: DateTime(2019, 1, 1),
          salary: 60000.0,
          isActive: true,
          createdAt: DateTime(2019, 1, 1),
          updatedAt: DateTime(2019, 1, 1),
        ),
        Employee(
          id: '3',
          userId: 'user3',
          position: 'Developer',
          department: 'IT',
          hireDate: DateTime(2021, 1, 1),
          salary: 55000.0,
          isActive: false,
          createdAt: DateTime(2021, 1, 1),
          updatedAt: DateTime(2021, 1, 1),
        ),
      ];

      final notifier = container.read(employeeProvider.notifier);
      notifier.state = notifier.state.copyWith(
        employees: employees,
      );

      final stats = container.read(employeeStatsProvider);

      expect(stats['total'], 3);
      expect(stats['active'], 2);
      expect(stats['inactive'], 1);
      expect(stats['byDepartment']['Informatique'], 2);
      expect(stats['byDepartment']['Ressources Humaines'], 1);
    });

    test('should toggle employee status correctly', () async {
      final existingEmployee = Employee(
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

      final mockResponse = ApiResponse(
        isSuccess: true,
        data: {
          'data': {
            'id': '1',
            'user_id': 'user1',
            'position': 'Developer',
            'department': 'IT',
            'hire_date': '2020-01-01T00:00:00.000Z',
            'salary': 50000.0,
            'is_active': false,
            'created_at': '2020-01-01T00:00:00.000Z',
            'updated_at': '2020-01-02T00:00:00.000Z',
          },
          'message': 'Employee status updated successfully',
        },
        message: 'Success',
      );

      when(mockApiService.put(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      // Add existing employee to state
      final notifier = container.read(employeeProvider.notifier);
      notifier.state = notifier.state.copyWith(
        employees: [existingEmployee],
      );

      final result = await notifier.toggleEmployeeStatus('1');

      expect(result, true);
      final provider = container.read(employeeProvider);
      expect(provider.employees.first.isActive, false);
    });
  });

  group('EmployeeProvider Security Tests', () {
    late MockApiService mockApiService;
    late ProviderContainer container;

    setUp(() {
      mockApiService = MockApiService();
      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should handle unauthorized access correctly', () async {
      final mockResponse = ApiResponse(
        isSuccess: false,
        data: {'error': 'Unauthorized access'},
        message: 'Unauthorized access',
      );

      when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final notifier = container.read(employeeProvider.notifier);
      await notifier.loadEmployees();

      final provider = container.read(employeeProvider);
      expect(provider.error, 'Unauthorized access');
      expect(provider.employees, isEmpty);
    });

    test('should handle forbidden operations correctly', () async {
      final mockResponse = ApiResponse(
        isSuccess: false,
        data: {'error': 'Forbidden operation'},
        message: 'Forbidden operation',
      );

      when(mockApiService.put(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final notifier = container.read(employeeProvider.notifier);
      final result = await notifier.updateEmployee('1', {'position': 'Senior Developer'});

      expect(result, false);
      final provider = container.read(employeeProvider);
      expect(provider.error, 'Forbidden operation');
    });
  });

  group('EmployeeProvider Performance Tests', () {
    late MockApiService mockApiService;
    late ProviderContainer container;

    setUp(() {
      mockApiService = MockApiService();
      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should handle large datasets efficiently', () async {
      final largeEmployeeList = List.generate(1000, (index) => {
        'id': index.toString(),
        'user_id': 'user$index',
        'position': 'Developer',
        'department': 'IT',
        'hire_date': '2020-01-01T00:00:00.000Z',
        'salary': 50000.0,
        'is_active': true,
        'created_at': '2020-01-01T00:00:00.000Z',
        'updated_at': '2020-01-01T00:00:00.000Z',
      });

      final mockResponse = ApiResponse(
        isSuccess: true,
        data: {
          'data': largeEmployeeList,
          'message': 'Employees loaded successfully',
        },
        message: 'Success',
      );

      when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final stopwatch = Stopwatch()..start();

      final notifier = container.read(employeeProvider.notifier);
      await notifier.loadEmployees();

      stopwatch.stop();

      final provider = container.read(employeeProvider);
      expect(provider.employees.length, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('should handle filtering efficiently', () {
      final largeEmployeeList = List.generate(1000, (index) => Employee(
        id: index.toString(),
        userId: 'user$index',
        position: index % 2 == 0 ? 'Developer' : 'Manager',
        department: index % 3 == 0 ? 'IT' : 'HR',
        hireDate: DateTime(2020, 1, 1),
        salary: 50000.0 + (index * 100),
        isActive: index % 10 != 0,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
      ));

      final notifier = container.read(employeeProvider.notifier);
      notifier.state = notifier.state.copyWith(
        employees: largeEmployeeList,
      );

      final stopwatch = Stopwatch()..start();

      final filters = EmployeeFilters(
        department: Department.it,
        position: Position.developer,
        isActive: true,
      );
      notifier.applyFilters(filters);

      stopwatch.stop();

      final provider = container.read(employeeProvider);
      expect(provider.filteredEmployees.length, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aramco_frontend/core/models/employee.dart';
import 'package:aramco_frontend/core/models/leave_request.dart';
import 'package:aramco_frontend/core/models/performance_review.dart';
import 'package:aramco_frontend/core/models/payslip.dart';
import 'package:aramco_frontend/core/models/api_response.dart';
import 'package:aramco_frontend/core/services/api_service.dart';
import 'package:aramco_frontend/presentation/providers/employee_provider.dart';
import 'package:aramco_frontend/presentation/providers/leave_request_provider.dart';
import 'package:aramco_frontend/presentation/providers/performance_review_provider.dart';
import 'package:aramco_frontend/presentation/providers/payslip_provider.dart';

import 'rh_integration_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('RH Integration Tests', () {
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

    group('Employee-Leave Request Integration', () {
      test('should create leave request for existing employee', () async {
        // Setup employee
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

        final employeeResponse = ApiResponse(
          success: true,
          data: {
            'data': [employee.toJson()],
            'message': 'Employee loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => employeeResponse);

        // Load employee
        final employeeNotifier = container.read(employeeProvider.notifier);
        await employeeNotifier.loadEmployees();

        // Create leave request
        final leaveRequestData = {
          'employee_id': '1',
          'leave_type': 'annual',
          'start_date': '2024-01-01',
          'end_date': '2024-01-05',
          'reason': 'Vacation',
        };

        final leaveRequestResponse = ApiResponse(
          success: true,
          data: {
            'data': {
              'id': '1',
              'employee_id': '1',
              'leave_type': 'annual',
              'start_date': '2024-01-01',
              'end_date': '2024-01-05',
              'status': 'pending',
              'reason': 'Vacation',
              'created_at': '2024-01-01T00:00:00.000Z',
            },
            'message': 'Leave request created successfully',
          },
          message: 'Success',
          statusCode: 201,
        );

        when(mockApiService.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => leaveRequestResponse);

        final leaveNotifier = container.read(leaveRequestProvider.notifier);
        final result = await leaveNotifier.createLeaveRequest(leaveRequestData);

        expect(result, true);
        
        final leaveProvider = container.read(leaveRequestProvider);
        expect(leaveProvider.leaveRequests.length, 1);
        expect(leaveProvider.leaveRequests.first.employeeId, '1');
      });

      test('should validate leave request against employee balance', () async {
        // Setup employee with limited leave balance
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

        final employeeResponse = ApiResponse(
          success: true,
          data: {
            'data': [employee.toJson()],
            'message': 'Employee loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => employeeResponse);

        // Setup existing leave requests
        final existingLeaveRequests = [
          {
            'id': '1',
            'employee_id': '1',
            'leave_type': 'annual',
            'start_date': '2024-01-01',
            'end_date': '2024-01-10',
            'status': 'approved',
            'reason': 'Vacation',
            'created_at': '2024-01-01T00:00:00.000Z',
          }
        ];

        final leaveRequestsResponse = ApiResponse(
          success: true,
          data: {
            'data': existingLeaveRequests,
            'message': 'Leave requests loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any))
            .thenAnswer((_) async => leaveRequestsResponse);

        // Load existing leave requests
        final leaveNotifier = container.read(leaveRequestProvider.notifier);
        await leaveNotifier.loadLeaveRequests();

        // Try to create new leave request that exceeds balance
        final newLeaveRequestData = {
          'employee_id': '1',
          'leave_type': 'annual',
          'start_date': '2024-02-01',
          'end_date': '2024-02-15',
          'reason': 'Additional vacation',
        };

        final errorResponse = ApiResponse(
          success: false,
          data: {'error': 'Insufficient leave balance'},
          message: 'Insufficient leave balance',
          statusCode: 400,
        );

        when(mockApiService.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => errorResponse);

        final result = await leaveNotifier.createLeaveRequest(newLeaveRequestData);

        expect(result, false);
        final leaveProvider = container.read(leaveRequestProvider);
        expect(leaveProvider.error, 'Insufficient leave balance');
      });
    });

    group('Employee-Performance Review Integration', () {
      test('should create performance review for employee', () async {
        // Setup employee
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

        final employeeResponse = ApiResponse(
          success: true,
          data: {
            'data': [employee.toJson()],
            'message': 'Employee loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => employeeResponse);

        // Load employee
        final employeeNotifier = container.read(employeeProvider.notifier);
        await employeeNotifier.loadEmployees();

        // Create performance review
        final reviewData = {
          'employee_id': '1',
          'review_period': '2024-Q1',
          'technical_skills': 4.5,
          'communication': 4.0,
          'teamwork': 4.2,
          'leadership': 3.8,
          'productivity': 4.3,
          'comments': 'Good performance overall',
        };

        final reviewResponse = ApiResponse(
          success: true,
          data: {
            'data': {
              'id': '1',
              'employee_id': '1',
              'review_period': '2024-Q1',
              'technical_skills': 4.5,
              'communication': 4.0,
              'teamwork': 4.2,
              'leadership': 3.8,
              'productivity': 4.3,
              'overall_rating': 4.16,
              'status': 'pending',
              'comments': 'Good performance overall',
              'created_at': '2024-01-01T00:00:00.000Z',
            },
            'message': 'Performance review created successfully',
          },
          message: 'Success',
          statusCode: 201,
        );

        when(mockApiService.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => reviewResponse);

        final reviewNotifier = container.read(performanceReviewProvider.notifier);
        final result = await reviewNotifier.createReview(reviewData);

        expect(result, true);
        
        final reviewProvider = container.read(performanceReviewProvider);
        expect(reviewProvider.reviews.length, 1);
        expect(reviewProvider.reviews.first.employeeId, '1');
        expect(reviewProvider.reviews.first.overallRating, 4.16);
      });

      test('should calculate average rating across reviews', () async {
        // Setup multiple performance reviews for employee
        final reviews = [
          {
            'id': '1',
            'employee_id': '1',
            'review_period': '2024-Q1',
            'technical_skills': 4.5,
            'communication': 4.0,
            'teamwork': 4.2,
            'leadership': 3.8,
            'productivity': 4.3,
            'overall_rating': 4.16,
            'status': 'approved',
            'created_at': '2024-01-01T00:00:00.000Z',
          },
          {
            'id': '2',
            'employee_id': '1',
            'review_period': '2024-Q2',
            'technical_skills': 4.7,
            'communication': 4.2,
            'teamwork': 4.4,
            'leadership': 4.0,
            'productivity': 4.5,
            'overall_rating': 4.36,
            'status': 'approved',
            'created_at': '2024-04-01T00:00:00.000Z',
          },
        ];

        final reviewsResponse = ApiResponse(
          success: true,
          data: {
            'data': reviews,
            'message': 'Performance reviews loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any))
            .thenAnswer((_) async => reviewsResponse);

        final reviewNotifier = container.read(performanceReviewProvider.notifier);
        await reviewNotifier.loadReviews();

        final reviewProvider = container.read(performanceReviewProvider);
        expect(reviewProvider.reviews.length, 2);
        
        // Calculate average rating
        final averageRating = reviewProvider.reviews
            .map((r) => r.overallRating)
            .reduce((a, b) => a + b) / reviewProvider.reviews.length;
        
        expect(averageRating, 4.26);
      });
    });

    group('Employee-Payslip Integration', () {
      test('should generate payslip for employee', () async {
        // Setup employee
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

        final employeeResponse = ApiResponse(
          success: true,
          data: {
            'data': [employee.toJson()],
            'message': 'Employee loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => employeeResponse);

        // Load employee
        final employeeNotifier = container.read(employeeProvider.notifier);
        await employeeNotifier.loadEmployees();

        // Generate payslip
        final payslipData = {
          'employee_id': '1',
          'month': '2024-01',
          'basic_salary': 50000.0,
          'allowances': 5000.0,
          'deductions': 8000.0,
          'overtime': 2000.0,
        };

        final payslipResponse = ApiResponse(
          success: true,
          data: {
            'data': {
              'id': '1',
              'employee_id': '1',
              'month': '2024-01',
              'basic_salary': 50000.0,
              'allowances': 5000.0,
              'deductions': 8000.0,
              'overtime': 2000.0,
              'gross_salary': 57000.0,
              'net_salary': 49000.0,
              'status': 'generated',
              'created_at': '2024-01-31T00:00:00.000Z',
            },
            'message': 'Payslip generated successfully',
          },
          message: 'Success',
          statusCode: 201,
        );

        when(mockApiService.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => payslipResponse);

        final payslipNotifier = container.read(payslipProvider.notifier);
        final result = await payslipNotifier.generatePayslip(payslipData);

        expect(result, true);
        
        final payslipProvider = container.read(payslipProvider);
        expect(payslipProvider.payslips.length, 1);
        expect(payslipProvider.payslips.first.employeeId, '1');
        expect(payslipProvider.payslips.first.netSalary, 49000.0);
      });

      test('should calculate year-to-date earnings', () async {
        // Setup multiple payslips for employee
        final payslips = [
          {
            'id': '1',
            'employee_id': '1',
            'month': '2024-01',
            'basic_salary': 50000.0,
            'allowances': 5000.0,
            'deductions': 8000.0,
            'overtime': 2000.0,
            'gross_salary': 57000.0,
            'net_salary': 49000.0,
            'status': 'generated',
            'created_at': '2024-01-31T00:00:00.000Z',
          },
          {
            'id': '2',
            'employee_id': '1',
            'month': '2024-02',
            'basic_salary': 50000.0,
            'allowances': 5000.0,
            'deductions': 8000.0,
            'overtime': 1500.0,
            'gross_salary': 56500.0,
            'net_salary': 48500.0,
            'status': 'generated',
            'created_at': '2024-02-29T00:00:00.000Z',
          },
        ];

        final payslipsResponse = ApiResponse(
          success: true,
          data: {
            'data': payslips,
            'message': 'Payslips loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any))
            .thenAnswer((_) async => payslipsResponse);

        final payslipNotifier = container.read(payslipProvider.notifier);
        await payslipNotifier.loadPayslips();

        final payslipProvider = container.read(payslipProvider);
        expect(payslipProvider.payslips.length, 2);
        
        // Calculate YTD earnings
        final ytdGross = payslipProvider.payslips
            .map((p) => p.grossSalary)
            .reduce((a, b) => a + b);
        final ytdNet = payslipProvider.payslips
            .map((p) => p.netSalary)
            .reduce((a, b) => a + b);
        
        expect(ytdGross, 113500.0);
        expect(ytdNet, 97500.0);
      });
    });

    group('Cross-Module Data Consistency', () {
      test('should maintain employee data consistency across modules', () async {
        // Setup employee
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

        final employeeResponse = ApiResponse(
          success: true,
          data: {
            'data': [employee.toJson()],
            'message': 'Employee loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => employeeResponse);

        // Load employee in all modules
        final employeeNotifier = container.read(employeeProvider.notifier);
        await employeeNotifier.loadEmployees();

        // Verify employee is accessible across modules
        final employeeProvider = container.read(employeeProvider);
        expect(employeeProvider.employees.length, 1);
        expect(employeeProvider.employees.first.id, '1');

        // Update employee position
        final updatedEmployeeData = {
          'position': 'Senior Developer',
          'salary': 55000.0,
        };

        final updateResponse = ApiResponse(
          success: true,
          data: {
            'data': {
              ...employee.toJson(),
              'position': 'Senior Developer',
              'salary': 55000.0,
              'updated_at': '2024-01-02T00:00:00.000Z',
            },
            'message': 'Employee updated successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.put(any, data: anyNamed('data')))
            .thenAnswer((_) async => updateResponse);

        final updateResult = await employeeNotifier.updateEmployee('1', updatedEmployeeData);
        expect(updateResult, true);

        // Verify update is reflected
        final updatedProvider = container.read(employeeProvider);
        expect(updatedProvider.employees.first.position, 'Senior Developer');
        expect(updatedProvider.employees.first.salary, 55000.0);
      });

      test('should handle cascading deletions appropriately', () async {
        // Setup employee with related data
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

        final employeeResponse = ApiResponse(
          success: true,
          data: {
            'data': [employee.toJson()],
            'message': 'Employee loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => employeeResponse);

        // Load employee
        final employeeNotifier = container.read(employeeProvider.notifier);
        await employeeNotifier.loadEmployees();

        // Setup related data
        final leaveRequests = [
          {
            'id': '1',
            'employee_id': '1',
            'leave_type': 'annual',
            'start_date': '2024-01-01',
            'end_date': '2024-01-05',
            'status': 'approved',
            'created_at': '2024-01-01T00:00:00.000Z',
          }
        ];

        final leaveResponse = ApiResponse(
          success: true,
          data: {
            'data': leaveRequests,
            'message': 'Leave requests loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any))
            .thenAnswer((_) async => leaveResponse);

        final leaveNotifier = container.read(leaveRequestProvider.notifier);
        await leaveNotifier.loadLeaveRequests();

        // Delete employee
        final deleteResponse = ApiResponse(
          success: true,
          data: {'message': 'Employee deleted successfully'},
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.delete(any))
            .thenAnswer((_) async => deleteResponse);

        final deleteResult = await employeeNotifier.deleteEmployee('1');
        expect(deleteResult, true);

        // Verify employee is removed
        final employeeProvider = container.read(employeeProvider);
        expect(employeeProvider.employees.isEmpty);

        // Note: In a real implementation, related data would be handled
        // by the backend with proper cascading rules or soft deletes
      });
    });

    group('Performance and Scalability', () {
      test('should handle large datasets efficiently', () async {
        // Create large dataset
        final employees = List.generate(100, (index) => Employee(
          id: index.toString(),
          userId: 'user$index',
          position: 'Developer',
          department: 'IT',
          hireDate: DateTime(2020, 1, 1),
          salary: 50000.0 + (index * 100),
          isActive: true,
          createdAt: DateTime(2020, 1, 1),
          updatedAt: DateTime(2020, 1, 1),
        ));

        final employeeJsonList = employees.map((e) => e.toJson()).toList();

        final employeeResponse = ApiResponse(
          success: true,
          data: {
            'data': employeeJsonList,
            'message': 'Employees loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => employeeResponse);

        final stopwatch = Stopwatch()..start();

        final employeeNotifier = container.read(employeeProvider.notifier);
        await employeeNotifier.loadEmployees();

        stopwatch.stop();

        final employeeProvider = container.read(employeeProvider);
        expect(employeeProvider.employees.length, 100);
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      test('should handle concurrent operations across modules', () async {
        // Setup employee
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

        final employeeResponse = ApiResponse(
          success: true,
          data: {
            'data': [employee.toJson()],
            'message': 'Employee loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => employeeResponse);

        // Load employee
        final employeeNotifier = container.read(employeeProvider.notifier);
        await employeeNotifier.loadEmployees();

        // Setup concurrent operations
        final leaveRequestData = {
          'employee_id': '1',
          'leave_type': 'annual',
          'start_date': '2024-01-01',
          'end_date': '2024-01-05',
          'reason': 'Vacation',
        };

        final leaveResponse = ApiResponse(
          success: true,
          data: {
            'data': {
              'id': '1',
              'employee_id': '1',
              'leave_type': 'annual',
              'start_date': '2024-01-01',
              'end_date': '2024-01-05',
              'status': 'pending',
              'reason': 'Vacation',
              'created_at': '2024-01-01T00:00:00.000Z',
            },
            'message': 'Leave request created successfully',
          },
          message: 'Success',
          statusCode: 201,
        );

        when(mockApiService.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => leaveResponse);

        final reviewData = {
          'employee_id': '1',
          'review_period': '2024-Q1',
          'technical_skills': 4.5,
          'communication': 4.0,
          'teamwork': 4.2,
          'leadership': 3.8,
          'productivity': 4.3,
          'comments': 'Good performance',
        };

        final reviewResponse = ApiResponse(
          success: true,
          data: {
            'data': {
              'id': '1',
              'employee_id': '1',
              'review_period': '2024-Q1',
              'technical_skills': 4.5,
              'communication': 4.0,
              'teamwork': 4.2,
              'leadership': 3.8,
              'productivity': 4.3,
              'overall_rating': 4.16,
              'status': 'pending',
              'comments': 'Good performance',
              'created_at': '2024-01-01T00:00:00.000Z',
            },
            'message': 'Performance review created successfully',
          },
          message: 'Success',
          statusCode: 201,
        );

        // Simulate concurrent operations
        final leaveNotifier = container.read(leaveRequestProvider.notifier);
        final reviewNotifier = container.read(performanceReviewProvider.notifier);

        final futures = [
          leaveNotifier.createLeaveRequest(leaveRequestData),
          reviewNotifier.createReview(reviewData),
        ];

        final results = await Future.wait(futures);

        expect(results.every((result) => result), true);

        final leaveProvider = container.read(leaveRequestProvider);
        final reviewProvider = container.read(performanceReviewProvider);

        expect(leaveProvider.leaveRequests.length, 1);
        expect(reviewProvider.reviews.length, 1);
      });
    });
  });
}

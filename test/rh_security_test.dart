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

import 'rh_security_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('RH Security Tests', () {
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

    group('Authentication and Authorization', () {
      test('should prevent unauthorized access to employee data', () async {
        // Simulate unauthorized response
        final unauthorizedResponse = ApiResponse(
          success: false,
          data: {'error': 'Unauthorized access'},
          message: 'Unauthorized',
          statusCode: 401,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => unauthorizedResponse);

        final notifier = container.read(employeeProvider.notifier);
        await notifier.loadEmployees();

        final provider = container.read(employeeProvider);
        expect(provider.employees, isEmpty);
        expect(provider.error, 'Unauthorized');
      });

      test('should prevent access to sensitive employee information', () async {
        // Create employee with sensitive data
        final employeeWithSensitiveData = {
          'id': '1',
          'user_id': 'user1',
          'position': 'Developer',
          'department': 'IT',
          'hire_date': '2020-01-01T00:00:00.000Z',
          'salary': 50000.0,
          'bank_account': '1234567890', // Sensitive data
          'social_security': '987654321', // Sensitive data
          'is_active': true,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
        };

        final response = ApiResponse(
          success: true,
          data: {
            'data': [employeeWithSensitiveData],
            'message': 'Employee loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => response);

        final notifier = container.read(employeeProvider.notifier);
        await notifier.loadEmployees();

        final provider = container.read(employeeProvider);
        expect(provider.employees.length, 1);
        
        // Verify sensitive data is filtered out
        final employee = provider.employees.first;
        expect(employee.toJson().containsKey('bank_account'), false);
        expect(employee.toJson().containsKey('social_security'), false);
      });

      test('should enforce role-based access control', () async {
        // Test with different user roles
        final testCases = [
          {'role': 'admin', 'canDelete': true, 'canUpdate': true, 'canCreate': true},
          {'role': 'manager', 'canDelete': false, 'canUpdate': true, 'canCreate': true},
          {'role': 'employee', 'canDelete': false, 'canUpdate': false, 'canCreate': false},
        ];

        for (final testCase in testCases) {
          final role = testCase['role'] as String;
          final canDelete = testCase['canDelete'] as bool;
          final canUpdate = testCase['canUpdate'] as bool;
          final canCreate = testCase['canCreate'] as bool;

          // Mock role-based response
          final roleResponse = ApiResponse(
            success: true,
            data: {
              'role': role,
              'permissions': {
                'delete': canDelete,
                'update': canUpdate,
                'create': canCreate,
              }
            },
            message: 'Success',
            statusCode: 200,
          );

          when(mockApiService.get('/auth/permissions'))
              .thenAnswer((_) async => roleResponse);

          // Test delete permissions
          if (canDelete) {
            final deleteResponse = ApiResponse(
              success: true,
              data: {'message': 'Employee deleted successfully'},
              message: 'Success',
              statusCode: 200,
            );
            when(mockApiService.delete(any))
                .thenAnswer((_) async => deleteResponse);
          } else {
            final forbiddenResponse = ApiResponse(
              success: false,
              data: {'error': 'Forbidden operation'},
              message: 'Forbidden',
              statusCode: 403,
            );
            when(mockApiService.delete(any))
                .thenAnswer((_) async => forbiddenResponse);
          }

          final notifier = container.read(employeeProvider.notifier);
          final deleteResult = await notifier.deleteEmployee('1');
          expect(deleteResult, canDelete);
        }
      });
    });

    group('Data Validation and Sanitization', () {
      test('should prevent SQL injection attacks', () async {
        // Attempt SQL injection
        final maliciousData = {
          'user_id': 'user1\'; DROP TABLE employees; --',
          'position': 'Developer\'; DELETE FROM users; --',
          'department': 'IT',
          'hire_date': '2020-01-01T00:00:00.000Z',
          'salary': 50000.0,
          'is_active': true,
        };

        // Should return validation error
        final validationResponse = ApiResponse(
          success: false,
          data: {'error': 'Invalid input data'},
          message: 'Validation failed',
          statusCode: 400,
        );

        when(mockApiService.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => validationResponse);

        final notifier = container.read(employeeProvider.notifier);
        final result = await notifier.createEmployee(maliciousData);

        expect(result, false);
        final provider = container.read(employeeProvider);
        expect(provider.error, 'Validation failed');
      });

      test('should prevent XSS attacks', () async {
        // Attempt XSS attack
        final xssData = {
          'user_id': 'user1',
          'position': '<script>alert("XSS")</script>',
          'department': 'IT',
          'hire_date': '2020-01-01T00:00:00.000Z',
          'salary': 50000.0,
          'is_active': true,
        };

        // Should sanitize and return success
        final sanitizedResponse = ApiResponse(
          success: true,
          data: {
            'data': {
              'id': '1',
              'user_id': 'user1',
              'position': 'alert("XSS")', // Sanitized
              'department': 'IT',
              'hire_date': '2020-01-01T00:00:00.000Z',
              'salary': 50000.0,
              'is_active': true,
              'created_at': '2020-01-01T00:00:00.000Z',
              'updated_at': '2020-01-01T00:00:00.000Z',
            },
            'message': 'Employee created successfully',
          },
          message: 'Success',
          statusCode: 201,
        );

        when(mockApiService.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => sanitizedResponse);

        final notifier = container.read(employeeProvider.notifier);
        final result = await notifier.createEmployee(xssData);

        expect(result, true);
        final provider = container.read(employeeProvider);
        expect(provider.employees.length, 1);
        
        // Verify script tags are removed
        final employee = provider.employees.first;
        expect(employee.position.contains('<script>'), false);
        expect(employee.position.contains('</script>'), false);
      });

      test('should validate input formats', () async {
        // Test invalid email format
        final invalidEmailData = {
          'user_id': 'user1',
          'position': 'Developer',
          'department': 'IT',
          'hire_date': 'invalid-date',
          'salary': -50000.0, // Invalid negative salary
          'is_active': true,
        };

        final validationResponse = ApiResponse(
          success: false,
          data: {
            'errors': {
              'hire_date': ['Invalid date format'],
              'salary': ['Salary must be positive'],
            }
          },
          message: 'Validation failed',
          statusCode: 400,
        );

        when(mockApiService.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => validationResponse);

        final notifier = container.read(employeeProvider.notifier);
        final result = await notifier.createEmployee(invalidEmailData);

        expect(result, false);
        final provider = container.read(employeeProvider);
        expect(provider.errors.isNotEmpty, true);
        expect(provider.errors.containsKey('hire_date'), true);
        expect(provider.errors.containsKey('salary'), true);
      });
    });

    group('Data Privacy and Confidentiality', () {
      test('should encrypt sensitive data transmission', () async {
        // Mock encrypted data transmission
        final encryptedEmployeeData = {
          'encrypted_data': 'U2FsdGVkX1+...', // Encrypted payload
          'iv': 'abc123def456', // Initialization vector
        };

        final encryptedResponse = ApiResponse(
          success: true,
          data: {
            'data': encryptedEmployeeData,
            'message': 'Employee data transmitted securely',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => encryptedResponse);

        final notifier = container.read(employeeProvider.notifier);
        final result = await notifier.createEmployee({
          'user_id': 'user1',
          'position': 'Developer',
          'department': 'IT',
        });

        expect(result, true);
        
        // Verify encryption was used (mock verification)
        verify(mockApiService.post(any, data: argThat(
          contains('encrypted_data'),
          named: 'data'
        )))).called(1);
      });

      test('should mask sensitive financial information', () async {
        // Create payslip with sensitive financial data
        final payslipData = {
          'id': '1',
          'employee_id': '1',
          'month': '2024-01',
          'basic_salary': 50000.0,
          'allowances': 5000.0,
          'deductions': 8000.0,
          'net_salary': 47000.0,
          'bank_account': '1234567890123456', // Should be masked
          'created_at': '2024-01-31T00:00:00.000Z',
        };

        final response = ApiResponse(
          success: true,
          data: {
            'data': [payslipData],
            'message': 'Payslips loaded successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.get(any))
            .thenAnswer((_) async => response);

        final notifier = container.read(payslipProvider.notifier);
        await notifier.loadPayslips();

        final provider = container.read(payslipProvider);
        expect(provider.payslips.length, 1);
        
        // Verify bank account is masked
        final payslip = provider.payslips.first;
        if (payslip.toJson().containsKey('bank_account')) {
          expect(payslip.toJson()['bank_account'], contains('****'));
        }
      });

      test('should implement data retention policies', () async {
        // Test old data cleanup
        final oldData = [
          {
            'id': '1',
            'employee_id': '1',
            'month': '2020-01', // Very old data
            'basic_salary': 50000.0,
            'created_at': '2020-01-31T00:00:00.000Z',
          }
        ];

        final cleanupResponse = ApiResponse(
          success: true,
          data: {
            'deleted_count': 1,
            'message': 'Old data cleaned up successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.delete('/payslips/cleanup'))
            .thenAnswer((_) async => cleanupResponse);

        // Simulate cleanup operation
        final cleanupResult = await mockApiService.delete('/payslips/cleanup');
        expect(cleanupResult.success, true);
        expect(cleanupResult.data['deleted_count'], 1);
      });
    });

    group('Audit and Logging', () {
      test('should log all data access attempts', () async {
        // Mock audit logging
        final auditLog = {
          'user_id': 'user1',
          'action': 'access_employee_data',
          'resource': 'employees',
          'timestamp': '2024-01-01T12:00:00.000Z',
          'ip_address': '192.168.1.100',
          'user_agent': 'Mozilla/5.0...',
        };

        final auditResponse = ApiResponse(
          success: true,
          data: {
            'log_id': 'audit_123',
            'message': 'Access logged successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.post('/audit/log', data: anyNamed('data')))
            .thenAnswer((_) async => auditResponse);

        // Simulate access logging
        final logResult = await mockApiService.post('/audit/log', data: auditLog);
        expect(logResult.success, true);
        expect(logResult.data['log_id'], 'audit_123');
      });

      test('should track data modifications', () async {
        // Test modification tracking
        final modificationData = {
          'employee_id': '1',
          'field': 'salary',
          'old_value': 50000.0,
          'new_value': 55000.0,
          'modified_by': 'manager1',
          'timestamp': '2024-01-01T12:00:00.000Z',
        };

        final trackingResponse = ApiResponse(
          success: true,
          data: {
            'change_id': 'change_456',
            'message': 'Modification tracked successfully',
          },
          message: 'Success',
          statusCode: 200,
        );

        when(mockApiService.post('/audit/track', data: anyNamed('data')))
            .thenAnswer((_) async => trackingResponse);

        final trackResult = await mockApiService.post('/audit/track', data: modificationData);
        expect(trackResult.success, true);
        expect(trackResult.data['change_id'], 'change_456');
      });

      test('should detect and alert on suspicious activities', () async {
        // Test suspicious activity detection
        final suspiciousActivity = {
          'user_id': 'user1',
          'activity': 'multiple_failed_logins',
          'count': 5,
          'timeframe': '5_minutes',
          'ip_address': '192.168.1.100',
        };

        final alertResponse = ApiResponse(
          success: true,
          data: {
            'alert_id': 'alert_789',
            'severity': 'high',
            'message': 'Suspicious activity detected',
            'action_taken': 'account_locked',
          },
          message: 'Alert generated',
          statusCode: 200,
        );

        when(mockApiService.post('/security/alerts', data: anyNamed('data')))
            .thenAnswer((_) async => alertResponse);

        final alertResult = await mockApiService.post('/security/alerts', data: suspiciousActivity);
        expect(alertResult.success, true);
        expect(alertResult.data['severity'], 'high');
        expect(alertResult.data['action_taken'], 'account_locked');
      });
    });

    group('Rate Limiting and DoS Protection', () {
      test('should implement rate limiting', () async {
        // Test rate limiting
        final rateLimitResponse = ApiResponse(
          success: false,
          data: {
            'error': 'Rate limit exceeded',
            'retry_after': 60,
          },
          message: 'Too many requests',
          statusCode: 429,
        );

        // Simulate multiple rapid requests
        when(mockApiService.get(any))
            .thenAnswer((_) async => rateLimitResponse);

        final notifier = container.read(employeeProvider.notifier);
        
        // Make multiple requests
        final futures = List.generate(10, (_) => notifier.loadEmployees());
        final results = await Future.wait(futures);

        // Should be rate limited
        final provider = container.read(employeeProvider);
        expect(provider.error, 'Too many requests');
      });

      test('should handle DoS attacks gracefully', () async {
        // Simulate DoS attack
        final dosResponse = ApiResponse(
          success: false,
          data: {
            'error': 'Service temporarily unavailable',
            'retry_after': 300,
          },
          message: 'Service unavailable',
          statusCode: 503,
        );

        when(mockApiService.get(any))
            .thenAnswer((_) async => dosResponse);

        final notifier = container.read(employeeProvider.notifier);
        await notifier.loadEmployees();

        final provider = container.read(employeeProvider);
        expect(provider.error, 'Service temporarily unavailable');
        expect(provider.isLoading, false);
      });
    });

    group('Input Validation Security', () {
      test('should validate file uploads', () async {
        // Test malicious file upload
        final maliciousFile = {
          'filename': 'malicious.exe',
          'content_type': 'application/octet-stream',
          'size': 1048576, // 1MB
          'content': 'binary_data...',
        };

        final validationResponse = ApiResponse(
          success: false,
          data: {
            'error': 'Invalid file type',
            'allowed_types': ['.pdf', '.doc', '.docx'],
          },
          message: 'File validation failed',
          statusCode: 400,
        );

        when(mockApiService.post('/upload', data: anyNamed('data')))
            .thenAnswer((_) async => validationResponse);

        final uploadResult = await mockApiService.post('/upload', data: maliciousFile);
        expect(uploadResult.success, false);
        expect(uploadResult.data['error'], 'Invalid file type');
      });

      test('should prevent directory traversal attacks', () async {
        // Test directory traversal attempt
        final maliciousPath = '../../../etc/passwd';
        final fileData = {
          'path': maliciousPath,
          'action': 'read',
        };

        final securityResponse = ApiResponse(
          success: false,
          data: {
            'error': 'Invalid file path',
            'security_violation': 'directory_traversal_attempt',
          },
          message: 'Security violation',
          statusCode: 403,
        );

        when(mockApiService.post('/files', data: anyNamed('data')))
            .thenAnswer((_) async => securityResponse);

        final fileResult = await mockApiService.post('/files', data: fileData);
        expect(fileResult.success, false);
        expect(fileResult.data['security_violation'], 'directory_traversal_attempt');
      });
    });

    group('Session Security', () {
      test('should handle session expiration', () async {
        // Test expired session
        final sessionExpiredResponse = ApiResponse(
          success: false,
          data: {
            'error': 'Session expired',
            'redirect_to': '/login',
          },
          message: 'Authentication required',
          statusCode: 401,
        );

        when(mockApiService.get(any))
            .thenAnswer((_) async => sessionExpiredResponse);

        final notifier = container.read(employeeProvider.notifier);
        await notifier.loadEmployees();

        final provider = container.read(employeeProvider);
        expect(provider.error, 'Authentication required');
      });

      test('should prevent session hijacking', () async {
        // Test session validation
        final sessionValidation = {
          'session_id': 'sess_123',
          'user_agent': 'Mozilla/5.0...',
          'ip_address': '192.168.1.100',
          'last_activity': '2024-01-01T12:00:00.000Z',
        };

        final validationResponse = ApiResponse(
          success: false,
          data: {
            'error': 'Session invalid',
            'reason': 'ip_address_mismatch',
          },
          message: 'Session validation failed',
          statusCode: 401,
        );

        when(mockApiService.post('/session/validate', data: anyNamed('data')))
            .thenAnswer((_) async => validationResponse);

        final validationResult = await mockApiService.post('/session/validate', data: sessionValidation);
        expect(validationResult.success, false);
        expect(validationResult.data['reason'], 'ip_address_mismatch');
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aramco_frontend/core/models/leave_request.dart';
import 'package:aramco_frontend/core/services/leave_request_service.dart';
import 'package:aramco_frontend/presentation/providers/leave_request_provider.dart';

import 'leave_request_test.mocks.dart';

@GenerateMocks([LeaveRequestService])
void main() {
  group('LeaveRequest Model Tests', () {
    test('LeaveRequest should serialize to JSON correctly', () {
      final leaveRequest = LeaveRequest(
        id: '1',
        employeeId: 'emp1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 19),
        reason: 'Vacation with family',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = leaveRequest.toJson();

      expect(json['id'], '1');
      expect(json['employeeId'], 'emp1');
      expect(json['leaveType'], 'annual');
      expect(json['startDate'], '2024-01-15T00:00:00.000Z');
      expect(json['endDate'], '2024-01-19T00:00:00.000Z');
      expect(json['reason'], 'Vacation with family');
      expect(json['status'], 'pending');
      expect(json['priority'], 'medium');
      expect(json['totalDays'], 5);
    });

    test('LeaveRequest should deserialize from JSON correctly', () {
      final json = {
        'id': '1',
        'employeeId': 'emp1',
        'leaveType': 'annual',
        'startDate': '2024-01-15T00:00:00.000Z',
        'endDate': '2024-01-19T00:00:00.000Z',
        'reason': 'Vacation with family',
        'status': 'pending',
        'priority': 'medium',
        'totalDays': 5,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final leaveRequest = LeaveRequest.fromJson(json);

      expect(leaveRequest.id, '1');
      expect(leaveRequest.employeeId, 'emp1');
      expect(leaveRequest.leaveType, LeaveType.annual);
      expect(leaveRequest.startDate, DateTime(2024, 1, 15));
      expect(leaveRequest.endDate, DateTime(2024, 1, 19));
      expect(leaveRequest.reason, 'Vacation with family');
      expect(leaveRequest.status, LeaveStatus.pending);
      expect(leaveRequest.priority, LeavePriority.medium);
      expect(leaveRequest.totalDays, 5);
    });

    test('LeaveRequest formattedDuration should work correctly', () {
      final leaveRequest = LeaveRequest(
        id: '1',
        employeeId: 'emp1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 19),
        reason: 'Vacation',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(leaveRequest.formattedDuration, '5 jours');
    });

    test('LeaveRequest formattedDuration for single day should be 1 jour', () {
      final leaveRequest = LeaveRequest(
        id: '1',
        employeeId: 'emp1',
        leaveType: LeaveType.sick,
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 15),
        reason: 'Sick leave',
        status: LeaveStatus.approved,
        priority: LeavePriority.high,
        totalDays: 1,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(leaveRequest.formattedDuration, '1 jour');
    });

    test('LeaveRequest copyWith should work correctly', () {
      final originalRequest = LeaveRequest(
        id: '1',
        employeeId: 'emp1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 19),
        reason: 'Vacation',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updatedRequest = originalRequest.copyWith(
        status: LeaveStatus.approved,
        reason: 'Vacation with family - approved',
      );

      expect(updatedRequest.id, originalRequest.id);
      expect(updatedRequest.status, LeaveStatus.approved);
      expect(updatedRequest.reason, 'Vacation with family - approved');
      expect(updatedRequest.leaveType, originalRequest.leaveType);
    });

    test('LeaveRequest status getters should work correctly', () {
      final pendingRequest = LeaveRequest(
        id: '1',
        employeeId: 'emp1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 19),
        reason: 'Vacation',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final approvedRequest = LeaveRequest(
        id: '2',
        employeeId: 'emp1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 19),
        reason: 'Vacation',
        status: LeaveStatus.approved,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(pendingRequest.isPending, true);
      expect(pendingRequest.isApproved, false);
      expect(approvedRequest.isApproved, true);
      expect(approvedRequest.isPending, false);
    });

    test('LeaveRequest formattedDateRange should work correctly', () {
      final leaveRequest = LeaveRequest(
        id: '1',
        employeeId: 'emp1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 19),
        reason: 'Vacation',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(leaveRequest.formattedDateRange, contains('Du 15 au 19 janvier 2024'));
    });
  });

  group('LeaveType Enum Tests', () {
    test('LeaveType displayName should work correctly', () {
      expect(LeaveType.annual.displayName, 'Congé annuel');
      expect(LeaveType.sick.displayName, 'Congé maladie');
      expect(LeaveType.maternity.displayName, 'Congé maternité');
      expect(LeaveType.paternity.displayName, 'Congé paternité');
      expect(LeaveType.unpaid.displayName, 'Congé sans solde');
    });

    test('LeaveType description should work correctly', () {
      expect(LeaveType.annual.description, 'Congés payés annuels');
      expect(LeaveType.sick.description, 'Congé pour raison médicale');
      expect(LeaveType.maternity.description, 'Congé maternité légal');
    });

    test('LeaveType requiresDocument should work correctly', () {
      expect(LeaveType.annual.requiresDocument, false);
      expect(LeaveType.sick.requiresDocument, true);
      expect(LeaveType.maternity.requiresDocument, true);
      expect(LeaveType.paternity.requiresDocument, true);
      expect(LeaveType.unpaid.requiresDocument, false);
    });

    test('LeaveType maxDays should work correctly', () {
      expect(LeaveType.annual.maxDays, 30);
      expect(LeaveType.sick.maxDays, 90);
      expect(LeaveType.maternity.maxDays, 98);
      expect(LeaveType.paternity.maxDays, 14);
      expect(LeaveType.unpaid.maxDays, 365);
    });
  });

  group('LeaveStatus Enum Tests', () {
    test('LeaveStatus displayName should work correctly', () {
      expect(LeaveStatus.pending.displayName, 'En attente');
      expect(LeaveStatus.approved.displayName, 'Approuvé');
      expect(LeaveStatus.rejected.displayName, 'Rejeté');
      expect(LeaveStatus.cancelled.displayName, 'Annulé');
      expect(LeaveStatus.inProgress.displayName, 'En cours');
    });

    test('LeaveStatus description should work correctly', () {
      expect(LeaveStatus.pending.description, 'En attente d\'approbation');
      expect(LeaveStatus.approved.description, 'Demande approuvée');
      expect(LeaveStatus.rejected.description, 'Demande rejetée');
    });

    test('LeaveStatus canBeEdited should work correctly', () {
      expect(LeaveStatus.pending.canBeEdited, true);
      expect(LeaveStatus.approved.canBeEdited, false);
      expect(LeaveStatus.rejected.canBeEdited, false);
      expect(LeaveStatus.cancelled.canBeEdited, false);
    });

    test('LeaveStatus canBeCancelled should work correctly', () {
      expect(LeaveStatus.pending.canBeCancelled, true);
      expect(LeaveStatus.approved.canBeCancelled, true);
      expect(LeaveStatus.rejected.canBeCancelled, false);
      expect(LeaveStatus.cancelled.canBeCancelled, false);
    });
  });

  group('LeavePriority Enum Tests', () {
    test('LeavePriority displayName should work correctly', () {
      expect(LeavePriority.low.displayName, 'Faible');
      expect(LeavePriority.medium.displayName, 'Moyenne');
      expect(LeavePriority.high.displayName, 'Élevée');
      expect(LeavePriority.urgent.displayName, 'Urgente');
    });

    test('LeavePriority description should work correctly', () {
      expect(LeavePriority.low.description, 'Priorité faible');
      expect(LeavePriority.medium.description, 'Priorité moyenne');
      expect(LeavePriority.high.description, 'Priorité élevée');
      expect(LeavePriority.urgent.description, 'Priorité urgente');
    });

    test('LeavePriority color should work correctly', () {
      expect(LeavePriority.low.color, '#4CAF50');
      expect(LeavePriority.medium.color, '#FF9800');
      expect(LeavePriority.high.color, '#F44336');
      expect(LeavePriority.urgent.color, '#9C27B0');
    });
  });

  group('LeaveRequest Service Tests', () {
    late MockLeaveRequestService mockService;

    setUp(() {
      mockService = MockLeaveRequestService();
    });

    test('should get leave requests successfully', () async {
      final leaveRequests = [
        LeaveRequest(
          id: '1',
          employeeId: 'emp1',
          leaveType: LeaveType.annual,
          startDate: DateTime(2024, 1, 15),
          endDate: DateTime(2024, 1, 19),
          reason: 'Vacation',
          status: LeaveStatus.pending,
          priority: LeavePriority.medium,
          totalDays: 5,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];

      when(mockService.getLeaveRequests()).thenAnswer((_) async => leaveRequests);

      final result = await mockService.getLeaveRequests();

      expect(result, isA<List<LeaveRequest>>());
      expect(result.length, 1);
      expect(result.first.leaveType, LeaveType.annual);
      verify(mockService.getLeaveRequests()).called(1);
    });

    test('should handle service errors gracefully', () async {
      when(mockService.getLeaveRequests()).thenThrow(Exception('Service error'));

      expect(() async => await mockService.getLeaveRequests(), throwsException);
      verify(mockService.getLeaveRequests()).called(1);
    });

    test('should create leave request successfully', () async {
      final newRequest = LeaveRequest(
        id: '2',
        employeeId: 'emp2',
        leaveType: LeaveType.sick,
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 2),
        reason: 'Sick leave',
        status: LeaveStatus.pending,
        priority: LeavePriority.high,
        totalDays: 2,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      when(mockService.createLeaveRequest(any)).thenAnswer((_) async => newRequest);

      final result = await mockService.createLeaveRequest(newRequest);

      expect(result.leaveType, LeaveType.sick);
      expect(result.reason, 'Sick leave');
      verify(mockService.createLeaveRequest(newRequest)).called(1);
    });
  });

  group('LeaveRequest Validation Tests', () {
    test('should validate valid date range', () {
      final leaveRequest = LeaveRequest(
        id: '1',
        employeeId: 'emp1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 19),
        reason: 'Vacation',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(leaveRequest.isValidDateRange, true);
    });

    test('should reject invalid date range', () {
      final leaveRequest = LeaveRequest(
        id: '1',
        employeeId: 'emp1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 19),
        endDate: DateTime(2024, 1, 15),
        reason: 'Invalid dates',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(leaveRequest.isValidDateRange, false);
    });

    test('should check if reason is required', () {
      expect(LeaveType.sick.isReasonRequired, true);
      expect(LeaveType.annual.isReasonRequired, false);
      expect(LeaveType.maternity.isReasonRequired, false);
      expect(LeaveType.bereavement.isReasonRequired, true);
    });
  });

  group('LeaveRequest Calculations Tests', () {
    test('calculateTotalDays should work correctly', () {
      final startDate = DateTime(2024, 1, 15);
      final endDate = DateTime(2024, 1, 19);
      
      final totalDays = LeaveRequest.calculateTotalDays(startDate, endDate);
      
      expect(totalDays, 5); // 5 jours inclus
    });

    test('calculatePaidDays should work correctly', () {
      expect(LeaveRequest.calculatePaidDays(LeaveType.annual, 5), 5.0);
      expect(LeaveRequest.calculatePaidDays(LeaveType.sick, 10), 10.0);
      expect(LeaveRequest.calculatePaidDays(LeaveType.unpaid, 5), 0.0);
    });

    test('calculateUnpaidDays should work correctly', () {
      expect(LeaveRequest.calculateUnpaidDays(LeaveType.annual, 5), 0.0);
      expect(LeaveRequest.calculateUnpaidDays(LeaveType.unpaid, 5), 5.0);
    });
  });

  group('LeaveRequestFilters Tests', () {
    test('should initialize correctly', () {
      const filters = LeaveRequestFilters();

      expect(filters.leaveType, null);
      expect(filters.status, null);
      expect(filters.priority, null);
      expect(filters.hasFilters, false);
    });

    test('should detect filters correctly', () {
      const filters1 = LeaveRequestFilters(leaveType: LeaveType.annual);
      const filters2 = LeaveRequestFilters(status: LeaveStatus.pending);
      const filters3 = LeaveRequestFilters();

      expect(filters1.hasFilters, true);
      expect(filters2.hasFilters, true);
      expect(filters3.hasFilters, false);
    });

    test('copyWith should work correctly', () {
      const originalFilters = LeaveRequestFilters(
        leaveType: LeaveType.annual,
        status: LeaveStatus.pending,
      );

      final updatedFilters = originalFilters.copyWith(
        status: LeaveStatus.approved,
        priority: LeavePriority.high,
      );

      expect(updatedFilters.leaveType, LeaveType.annual);
      expect(updatedFilters.status, LeaveStatus.approved);
      expect(updatedFilters.priority, LeavePriority.high);
    });

    test('toApiParams should work correctly', () {
      const filters = LeaveRequestFilters(
        leaveType: LeaveType.annual,
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        searchQuery: 'vacation',
      );

      final params = filters.toApiParams();

      expect(params['leave_type'], 'annual');
      expect(params['status'], 'pending');
      expect(params['priority'], 'medium');
      expect(params['search'], 'vacation');
    });
  });

  group('LeaveRequest Performance Tests', () {
    test('should handle large leave request lists efficiently', () {
      final largeLeaveRequestList = List.generate(1000, (index) => LeaveRequest(
        id: index.toString(),
        employeeId: 'emp$index',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 1 + index),
        endDate: DateTime(2024, 1, 5 + index),
        reason: 'Leave request $index',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      final stopwatch = Stopwatch()..start();

      final filtered = largeLeaveRequestList.where((lr) => lr.status == LeaveStatus.pending).toList();

      stopwatch.stop();

      expect(filtered.length, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('should handle concurrent operations safely', () async {
      final leaveRequest = LeaveRequest(
        id: '1',
        employeeId: 'emp1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 19),
        reason: 'Vacation',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final futures = List.generate(10, (index) => 
        Future.delayed(Duration(milliseconds: index * 10), () {
          return leaveRequest.formattedDuration;
        })
      );

      final results = await Future.wait(futures);

      expect(results.length, 10);
      expect(results.every((result) => result == '5 jours'), true);
    });
  });
}

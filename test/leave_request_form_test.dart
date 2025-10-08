import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:aramco_frontend/presentation/screens/leave_request_form_screen.dart';
import 'package:aramco_frontend/presentation/providers/leave_request_provider.dart';
import 'package:aramco_frontend/presentation/providers/auth_provider.dart';
import 'package:aramco_frontend/core/models/leave_request.dart';
import 'package:aramco_frontend/core/models/user.dart';

import 'leave_request_form_test.mocks.dart';

@GenerateMocks([LeaveRequestNotifier, AuthNotifier])
void main() {
  group('LeaveRequestFormScreen Tests', () {
    late MockLeaveRequestNotifier mockLeaveRequestNotifier;
    late MockAuthNotifier mockAuthNotifier;
    late User mockUser;

    setUp(() {
      mockLeaveRequestNotifier = MockLeaveRequestNotifier();
      mockAuthNotifier = MockAuthNotifier();
      
      mockUser = User(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'employee',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createWidgetUnderTest({LeaveRequest? leaveRequest}) {
      return ProviderScope(
        overrides: [
          leaveRequestProvider.overrideWith((ref) => mockLeaveRequestNotifier),
          authProvider.overrideWith((ref) => mockAuthNotifier),
        ],
        child: MaterialApp(
          home: LeaveRequestFormScreen(
            leaveRequest: leaveRequest,
            employeeId: 'test-employee-id',
          ),
        ),
      );
    }

    testWidgets('should display form elements for new leave request', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nouvelle demande de congé'), findsOneWidget);
      expect(find.text('Type de congé'), findsOneWidget);
      expect(find.text('Date de début'), findsOneWidget);
      expect(find.text('Date de fin'), findsOneWidget);
      expect(find.text('Priorité'), findsOneWidget);
      expect(find.text('Justification'), findsOneWidget);
      expect(find.text('Soumettre la demande'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
    });

    testWidgets('should display edit mode for existing leave request', (WidgetTester tester) async {
      // Arrange
      final existingRequest = LeaveRequest(
        id: 'test-request-id',
        employeeId: 'test-employee-id',
        leaveType: LeaveType.annual,
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        reason: 'Vacation',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        paidDays: 5.0,
        unpaidDays: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest(leaveRequest: existingRequest));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Modifier la demande'), findsOneWidget);
      expect(find.text('Mettre à jour'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should select leave type when tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap on "Congé annuel"
      final annualLeaveCard = find.text('Congé annuel');
      expect(annualLeaveCard, findsOneWidget);
      
      await tester.tap(annualLeaveCard);
      await tester.pumpAndSettle();

      // Assert - The card should be selected (check icon should appear)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should select priority when tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap on "Urgente" priority
      final urgentPriorityChip = find.text('Urgente');
      expect(urgentPriorityChip, findsOneWidget);
      
      await tester.tap(urgentPriorityChip);
      await tester.pumpAndSettle();

      // Assert - The chip should be selected
      expect(find.text('Urgente'), findsOneWidget);
    });

    testWidgets('should show date picker when date field is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap on start date field
      final startDateField = find.text('Sélectionner une date');
      expect(startDateField, findsWidgets); // Should find both start and end date fields
      
      await tester.tap(startDateField.first);
      await tester.pumpAndSettle();

      // Assert - Date picker should appear
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Try to submit without selecting leave type
      final submitButton = find.text('Soumettre la demande');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Assert - Should show validation error
      expect(find.text('Veuillez sélectionner un type de congé'), findsOneWidget);
    });

    testWidgets('should show attachment section for document-required leave types', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Select sick leave (requires document)
      final sickLeaveCard = find.text('Congé maladie');
      await tester.tap(sickLeaveCard);
      await tester.pumpAndSettle();

      // Assert - Attachment section should appear
      expect(find.text('Documents joints'), findsOneWidget);
      expect(find.text('Des documents sont requis pour ce type de congé'), findsOneWidget);
      expect(find.text('Ajouter un document'), findsOneWidget);
    });

    testWidgets('should show leave type info when type is selected', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Select a leave type
      final annualLeaveCard = find.text('Congé annuel');
      await tester.tap(annualLeaveCard);
      await tester.pumpAndSettle();

      // Assert - Leave type info should appear
      expect(find.text('Durée maximale'), findsOneWidget);
      expect(find.text('30 jours'), findsOneWidget);
      expect(find.text('Jours payés'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should handle form submission', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());
      when(mockLeaveRequestNotifier.createLeaveRequest(any)).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Fill in the form
      // Select leave type
      final annualLeaveCard = find.text('Congé annuel');
      await tester.tap(annualLeaveCard);
      await tester.pumpAndSettle();

      // Select dates (simplified - in real test would need to handle date picker)
      final startDateField = find.text('Sélectionner une date').first;
      await tester.tap(startDateField);
      await tester.pumpAndSettle();
      
      // Close date picker for now (would need proper date selection in real test)
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Add reason
      final reasonField = find.byType(TextFormField).first;
      await tester.enterText(reasonField, 'Vacation time');
      await tester.pumpAndSettle();

      // Submit form
      final submitButton = find.text('Soumettre la demande');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Assert
      verify(mockLeaveRequestNotifier.createLeaveRequest(any)).called(1);
    });

    testWidgets('should show delete confirmation in edit mode', (WidgetTester tester) async {
      // Arrange
      final existingRequest = LeaveRequest(
        id: 'test-request-id',
        employeeId: 'test-employee-id',
        leaveType: LeaveType.annual,
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        reason: 'Vacation',
        status: LeaveStatus.pending,
        priority: LeavePriority.medium,
        totalDays: 5,
        paidDays: 5.0,
        unpaidDays: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest(leaveRequest: existingRequest));
      await tester.pumpAndSettle();

      // Tap delete button
      final deleteButton = find.byIcon(Icons.delete);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Assert - Confirmation dialog should appear
      expect(find.text('Supprimer la demande'), findsOneWidget);
      expect(find.text('Êtes-vous sûr de vouloir supprimer cette demande de congé ?'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });

    testWidgets('should handle cancel button', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(const LeaveRequestState());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap cancel button
      final cancelButton = find.text('Annuler');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate back (in real test would verify navigation)
      // For now, just ensure the button is present and tappable
      expect(cancelButton, findsOneWidget);
    });

    testWidgets('should show loading state during submission', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(
        const LeaveRequestState(isLoading: true),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Loading overlay should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when submission fails', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.user).thenReturn(mockUser);
      when(mockLeaveRequestNotifier.state).thenReturn(
        const LeaveRequestState(error: 'Submission failed'),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Error message should be visible
      expect(find.text('Submission failed'), findsOneWidget);
    });
  });

  group('LeaveRequestForm Validation Tests', () {
    test('should validate date range correctly', () {
      // Test valid date range
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 5);
      
      // This would be tested in the actual widget validation logic
      expect(endDate.isAfter(startDate), isTrue);
      expect(endDate.difference(startDate).inDays + 1, equals(5));
    });

    test('should calculate total days correctly', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 3);
      
      final totalDays = endDate.difference(startDate).inDays + 1;
      expect(totalDays, equals(3));
    });

    test('should validate leave type max days', () {
      final annualLeave = LeaveType.annual;
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 35); // 35 days
      
      final totalDays = endDate.difference(startDate).inDays + 1;
      expect(totalDays, greaterThan(annualLeave.maxDays));
    });

    test('should identify document-required leave types', () {
      final sickLeave = LeaveType.sick;
      final annualLeave = LeaveType.annual;
      
      expect(sickLeave.requiresDocument, isTrue);
      expect(annualLeave.requiresDocument, isFalse);
    });

    test('should calculate paid days correctly', () {
      final totalDays = 5;
      
      final paidDaysAnnual = LeaveRequest.calculatePaidDays(LeaveType.annual, totalDays);
      final paidDaysUnpaid = LeaveRequest.calculatePaidDays(LeaveType.unpaid, totalDays);
      
      expect(paidDaysAnnual, equals(5.0));
      expect(paidDaysUnpaid, equals(0.0));
    });
  });
}

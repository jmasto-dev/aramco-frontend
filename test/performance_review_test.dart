import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aramco_frontend/core/models/performance_review.dart';
import 'package:aramco_frontend/core/services/performance_review_service.dart';
import 'package:aramco_frontend/presentation/providers/performance_review_provider.dart';

import 'performance_review_test.mocks.dart';

@GenerateMocks([PerformanceReviewService])
void main() {
  group('PerformanceReview Model Tests', () {
    test('PerformanceReview should serialize to JSON correctly', () {
      final review = PerformanceReview(
        id: '1',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 4.5,
        technicalSkills: 4.0,
        communicationSkills: 5.0,
        teamwork: 4.5,
        leadership: 3.5,
        problemSolving: 4.5,
        timeManagement: 4.0,
        adaptability: 5.0,
        strengths: ['Excellent communication', 'Strong problem solver'],
        areasForImprovement: ['Leadership skills', 'Time management'],
        goals: ['Improve leadership skills', 'Complete advanced training'],
        comments: 'Good performance overall with room for growth',
        status: ReviewStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      final json = review.toJson();

      expect(json['id'], '1');
      expect(json['employeeId'], 'emp1');
      expect(json['reviewerId'], 'rev1');
      expect(json['reviewPeriod'], '2024-Q1');
      expect(json['overallRating'], 4.5);
      expect(json['status'], 'completed');
    });

    test('PerformanceReview should deserialize from JSON correctly', () {
      final json = {
        'id': '1',
        'employeeId': 'emp1',
        'reviewerId': 'rev1',
        'reviewPeriod': '2024-Q1',
        'reviewDate': '2024-03-31T00:00:00.000Z',
        'overallRating': 4.5,
        'technicalSkills': 4.0,
        'communicationSkills': 5.0,
        'teamwork': 4.5,
        'leadership': 3.5,
        'problemSolving': 4.5,
        'timeManagement': 4.0,
        'adaptability': 5.0,
        'strengths': ['Excellent communication', 'Strong problem solver'],
        'areasForImprovement': ['Leadership skills', 'Time management'],
        'goals': ['Improve leadership skills', 'Complete advanced training'],
        'comments': 'Good performance overall with room for growth',
        'status': 'completed',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-03-31T00:00:00.000Z',
      };

      final review = PerformanceReview.fromJson(json);

      expect(review.id, '1');
      expect(review.employeeId, 'emp1');
      expect(review.reviewerId, 'rev1');
      expect(review.reviewPeriod, '2024-Q1');
      expect(review.overallRating, 4.5);
      expect(review.status, ReviewStatus.completed);
    });

    test('PerformanceReview copyWith should work correctly', () {
      final originalReview = PerformanceReview(
        id: '1',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 4.5,
        technicalSkills: 4.0,
        communicationSkills: 5.0,
        teamwork: 4.5,
        leadership: 3.5,
        problemSolving: 4.5,
        timeManagement: 4.0,
        adaptability: 5.0,
        strengths: ['Excellent communication'],
        areasForImprovement: ['Leadership skills'],
        goals: ['Improve leadership'],
        comments: 'Good performance',
        status: ReviewStatus.pending,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      final updatedReview = originalReview.copyWith(
        overallRating: 4.8,
        status: ReviewStatus.completed,
        comments: 'Excellent performance',
      );

      expect(updatedReview.id, originalReview.id);
      expect(updatedReview.overallRating, 4.8);
      expect(updatedReview.status, ReviewStatus.completed);
      expect(updatedReview.comments, 'Excellent performance');
      expect(updatedReview.employeeId, originalReview.employeeId);
    });

    test('PerformanceReview formattedDate should work correctly', () {
      final review = PerformanceReview(
        id: '1',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 4.5,
        technicalSkills: 4.0,
        communicationSkills: 5.0,
        teamwork: 4.5,
        leadership: 3.5,
        problemSolving: 4.5,
        timeManagement: 4.0,
        adaptability: 5.0,
        strengths: [],
        areasForImprovement: [],
        goals: [],
        comments: 'Good performance',
        status: ReviewStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      expect(review.formattedReviewDate, '31/03/2024');
    });

    test('PerformanceReview formattedRating should work correctly', () {
      final review = PerformanceReview(
        id: '1',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 4.5,
        technicalSkills: 4.0,
        communicationSkills: 5.0,
        teamwork: 4.5,
        leadership: 3.5,
        problemSolving: 4.5,
        timeManagement: 4.0,
        adaptability: 5.0,
        strengths: [],
        areasForImprovement: [],
        goals: [],
        comments: 'Good performance',
        status: ReviewStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      expect(review.formattedOverallRating, '4.5/5.0');
    });

    test('PerformanceReview status getters should work correctly', () {
      final pendingReview = PerformanceReview(
        id: '1',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 0,
        technicalSkills: 0,
        communicationSkills: 0,
        teamwork: 0,
        leadership: 0,
        problemSolving: 0,
        timeManagement: 0,
        adaptability: 0,
        strengths: [],
        areasForImprovement: [],
        goals: [],
        comments: '',
        status: ReviewStatus.pending,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      final completedReview = PerformanceReview(
        id: '2',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 4.5,
        technicalSkills: 4.0,
        communicationSkills: 5.0,
        teamwork: 4.5,
        leadership: 3.5,
        problemSolving: 4.5,
        timeManagement: 4.0,
        adaptability: 5.0,
        strengths: [],
        areasForImprovement: [],
        goals: [],
        comments: 'Good performance',
        status: ReviewStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      expect(pendingReview.isPending, true);
      expect(pendingReview.isCompleted, false);
      expect(completedReview.isCompleted, true);
      expect(completedReview.isPending, false);
    });

    test('PerformanceReview averageRating should work correctly', () {
      final review = PerformanceReview(
        id: '1',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 4.5,
        technicalSkills: 4.0,
        communicationSkills: 5.0,
        teamwork: 4.5,
        leadership: 3.5,
        problemSolving: 4.5,
        timeManagement: 4.0,
        adaptability: 5.0,
        strengths: [],
        areasForImprovement: [],
        goals: [],
        comments: 'Good performance',
        status: ReviewStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      final average = (4.0 + 5.0 + 4.5 + 3.5 + 4.5 + 4.0 + 5.0) / 7;
      expect(review.averageRating, closeTo(average, 0.01));
    });

    test('PerformanceReview equality should work correctly', () {
      final review1 = PerformanceReview(
        id: '1',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 4.5,
        technicalSkills: 4.0,
        communicationSkills: 5.0,
        teamwork: 4.5,
        leadership: 3.5,
        problemSolving: 4.5,
        timeManagement: 4.0,
        adaptability: 5.0,
        strengths: [],
        areasForImprovement: [],
        goals: [],
        comments: 'Good performance',
        status: ReviewStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      final review2 = PerformanceReview(
        id: '1',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 4.5,
        technicalSkills: 4.0,
        communicationSkills: 5.0,
        teamwork: 4.5,
        leadership: 3.5,
        problemSolving: 4.5,
        timeManagement: 4.0,
        adaptability: 5.0,
        strengths: [],
        areasForImprovement: [],
        goals: [],
        comments: 'Good performance',
        status: ReviewStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      final review3 = PerformanceReview(
        id: '2',
        employeeId: 'emp1',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q1',
        reviewDate: DateTime(2024, 3, 31),
        overallRating: 4.5,
        technicalSkills: 4.0,
        communicationSkills: 5.0,
        teamwork: 4.5,
        leadership: 3.5,
        problemSolving: 4.5,
        timeManagement: 4.0,
        adaptability: 5.0,
        strengths: [],
        areasForImprovement: [],
        goals: [],
        comments: 'Good performance',
        status: ReviewStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 3, 31),
      );

      expect(review1, equals(review2));
      expect(review1, isNot(equals(review3)));
    });
  });

  group('ReviewStatus Enum Tests', () {
    test('ReviewStatus displayName should work correctly', () {
      expect(ReviewStatus.pending.displayName, 'En attente');
      expect(ReviewStatus.inProgress.displayName, 'En cours');
      expect(ReviewStatus.completed.displayName, 'Terminé');
      expect(ReviewStatus.approved.displayName, 'Approuvé');
      expect(ReviewStatus.rejected.displayName, 'Rejeté');
    });

    test('ReviewStatus fromString should work correctly', () {
      expect(ReviewStatus.fromString('Terminé'), ReviewStatus.completed);
      expect(ReviewStatus.fromString('completed'), ReviewStatus.completed);
      expect(ReviewStatus.fromString('unknown'), ReviewStatus.pending);
    });

    test('ReviewStatus color should work correctly', () {
      expect(ReviewStatus.pending.color, '#FF9800');
      expect(ReviewStatus.inProgress.color, '#2196F3');
      expect(ReviewStatus.completed.color, '#4CAF50');
      expect(ReviewStatus.approved.color, '#4CAF50');
      expect(ReviewStatus.rejected.color, '#F44336');
    });
  });

  group('PerformanceReview Service Tests', () {
    late MockPerformanceReviewService mockService;

    setUp(() {
      mockService = MockPerformanceReviewService();
    });

    test('should get performance reviews successfully', () async {
      final reviews = [
        PerformanceReview(
          id: '1',
          employeeId: 'emp1',
          reviewerId: 'rev1',
          reviewPeriod: '2024-Q1',
          reviewDate: DateTime(2024, 3, 31),
          overallRating: 4.5,
          technicalSkills: 4.0,
          communicationSkills: 5.0,
          teamwork: 4.5,
          leadership: 3.5,
          problemSolving: 4.5,
          timeManagement: 4.0,
          adaptability: 5.0,
          strengths: [],
          areasForImprovement: [],
          goals: [],
          comments: 'Good performance',
          status: ReviewStatus.completed,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 3, 31),
        ),
      ];

      when(mockService.getPerformanceReviews()).thenAnswer((_) async => reviews);

      final result = await mockService.getPerformanceReviews();

      expect(result, isA<List<PerformanceReview>>());
      expect(result.length, 1);
      expect(result.first.employeeId, 'emp1');
      verify(mockService.getPerformanceReviews()).called(1);
    });

    test('should handle service errors gracefully', () async {
      when(mockService.getPerformanceReviews()).thenThrow(Exception('Service error'));

      expect(() async => await mockService.getPerformanceReviews(), throwsException);
      verify(mockService.getPerformanceReviews()).called(1);
    });

    test('should get reviews by employee', () async {
      final reviews = [
        PerformanceReview(
          id: '1',
          employeeId: 'emp1',
          reviewerId: 'rev1',
          reviewPeriod: '2024-Q1',
          reviewDate: DateTime(2024, 3, 31),
          overallRating: 4.5,
          technicalSkills: 4.0,
          communicationSkills: 5.0,
          teamwork: 4.5,
          leadership: 3.5,
          problemSolving: 4.5,
          timeManagement: 4.0,
          adaptability: 5.0,
          strengths: [],
          areasForImprovement: [],
          goals: [],
          comments: 'Good performance',
          status: ReviewStatus.completed,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 3, 31),
        ),
      ];

      when(mockService.getPerformanceReviewsByEmployee('emp1')).thenAnswer((_) async => reviews);

      final result = await mockService.getPerformanceReviewsByEmployee('emp1');

      expect(result.length, 1);
      expect(result.first.employeeId, 'emp1');
      verify(mockService.getPerformanceReviewsByEmployee('emp1')).called(1);
    });

    test('should create performance review successfully', () async {
      final newReview = PerformanceReview(
        id: '2',
        employeeId: 'emp2',
        reviewerId: 'rev1',
        reviewPeriod: '2024-Q2',
        reviewDate: DateTime(2024, 6, 30),
        overallRating: 4.0,
        technicalSkills: 4.0,
        communicationSkills: 4.0,
        teamwork: 4.0,
        leadership: 4.0,
        problemSolving: 4.0,
        timeManagement: 4.0,
        adaptability: 4.0,
        strengths: [],
        areasForImprovement: [],
        goals: [],
        comments: 'Average performance',
        status: ReviewStatus.pending,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 30),
      );

      when(mockService.createPerformanceReview(any)).thenAnswer((_) async => newReview);

      final result = await mockService.createPerformanceReview(newReview);

      expect(result.employeeId, 'emp2');
      expect(result.reviewPeriod, '2024-Q2');
      verify(mockService.createPerformanceReview(newReview)).called(1);
    });
  });

  group('PerformanceReview Validation Tests', () {
    test('should validate valid performance review', () {
      final review = PerformanceReview(
